#!/usr/bin/env python3
"""Checks a pull request before anyone builds it: what it changes, and what the universe code in it can reach.

    scripts/pr-guard.py 12              PR #12 against origin/main (fetches both)
    scripts/pr-guard.py <base> <head>   any two refs or commits, e.g. main my-branch

A universe is compiled Swift, so it runs with everything the app has: your Accessibility grant, and the power to
rewrite every AI's hook settings. This reads the PR's files with git as plain text and never builds, checks out or
runs any of it. CI runs the copy of this script on main (pull_request_target), so a PR can't edit it to pass itself.

Every changed file is sorted into one of three groups:
  green   a universe's own folder, the docs' pictures, README and CHANGELOG
  yellow  passes, but listed for the maintainer to read closely: registration files and the rest of the app
  red     fails: build and release scripts, repo and editor config, AI instructions, the hook and everything that
          holds your permissions. A contributor never needs these; the maintainer changes them.
Swift lines the PR adds are then checked (universe folders strictly, other files as warnings) for APIs a drawing
has no use for, names that could shadow the SDK's or the app's, hidden Unicode and code hidden off to the right.

Exit status: 0 when nothing failed (warnings included), 1 when something did, 2 on bad usage.
Stdlib only, Python 3.9+, so it runs on a stock Mac and on GitHub's runners.
"""
import os
import re
import subprocess
import sys

# --- Which group a path is in ------------------------------------------------------------------------------------

UNIVERSES = "Sources/App/Universes/"

# Fail: a contributor never needs these. Matched against the whole path.
RED = [
    (r"(^|/)\.", "repo or editor config (a dotfile or dot-folder: .github, .claude, .vscode, .gitattributes…)"),
    (r"\.(sh|zsh|bash|py|rb|js|ts|mjs|pl|command)$", "a script: these run on the maintainer's Mac"),
    (r"(^|/)(Makefile|Package\.swift|[^/]+\.xcodeproj/.*|[^/]+\.xcworkspace/.*)$", "a build or project file"),
    (r"(^|/)(CLAUDE|AGENTS|GEMINI|CONTRIBUTING)\.md$", "instructions for AI assistants or contributors"),
    (r"^(llms\.txt|clawdify_guide\.md)$", "instructions for AI assistants (editing them is prompt injection)"),
    (r"^Sources/Hook/", "the hook, which runs inside every AI session"),
    (r"^Sources/Shared/(StatusStore|Processes|GitRemote|SaverFeed)\.swift$", "compiled into the hook"),
    (r"^Sources/App/(HookInstaller|SaverInstaller|Jump|main)\.swift$", "holds the app's permissions"),
    (r"^Tools/[^/]+/build\.sh$", "a build script"),
]
# Pass without comment.
GREEN = [
    UNIVERSES + r"[^/]+/.+\.swift$",
    r"^docs/.+\.png$",
    r"^(README|CHANGELOG)\.md$",
]
# A new file directly in one of these folders is a new piece of core, not part of a universe.
CORE_FOLDERS = ["Sources/Shared", "Sources/App", "Sources/App/Universes", "Sources/Saver", "Sources"]

# --- What universe code may use ----------------------------------------------------------------------------------

IMPORTS = {"Foundation", "CoreGraphics", "CoreText", "AppKit"}
ATTRIBUTES = {"discardableResult", "escaping", "autoclosure", "inline", "inlinable", "Sendable", "MainActor"}
DIRECTIVES = {"available", "unavailable"}
# Types a universe may extend besides its own. All are structs or enums, so an extension can only add to them.
EXTENDABLE = {"Scenes", "Location", "Cast"}

# Names that reach files, processes, the network, other apps, the system or the app's own sensitive code. Drawing
# code has no use for any of them. Checked as whole identifiers in code (strings and comments removed).
BANNED = set("""
    Process NSTask posix_spawn posix_spawnp popen execv execve execvp execl execlp vfork dlopen dlsym dlclose
    NSAppleScript OSAScript NSUserAppleScriptTask NSUserUnixTask NSAppleEventDescriptor
    URLSession URLRequest URLSessionTask NWConnection NWListener NWEndpoint CFSocket URL NSURL
    FileManager FileHandle Pipe fopen freopen openat creat unlinkat renameat fchmod chown lchown symlink symlinkat
    contentsOf contentsOfFile contentsOfURL atomically
    NSWorkspace NSPasteboard NSRunningApplication NSApplication NSApp UserDefaults NSUserDefaults CFPreferences
    getenv setenv unsetenv putenv environment CommandLine Bundle CFBundle CFBundleGetFunctionPointerForName
    NSClassFromString NSSelectorFromString NSStringFromSelector Selector perform setValue forKey forKeyPath
    unsafeBitCast NSKeyedUnarchiver NSKeyedArchiver NSPredicate NSExpression NSInvocation
    CGDisplayCreateImage SCStream SCShareableContent
    Timer DispatchQueue DispatchSource Thread OperationQueue NotificationCenter DistributedNotificationCenter
    sysctl sysctlbyname ptrace
    Darwin Glibc ObjectiveC
    HookInstaller SaverInstaller StatusStore StatusPaths SaverFeed Jump ClaudeProcesses Processes GitRemote
""".split())
BANNED_PREFIXES = ("objc_", "class_", "method_", "sel_", "object_", "imp_", "proc_", "mach_", "task_", "AXUIElement",
                   "AXIsProcessTrusted", "AXObserver", "CGEvent", "CGWindowList", "SecItem", "SecKeychain",
                   "SecTrust", "kSec", "NSXPC", "xpc_", "launch_", "SMAppService", "SMJob")
# libc calls with everyday names (a door can `open`): only a bare call or reference counts, not `.open` or `open:`.
BARE_CALLS = {"open", "close", "read", "write", "unlink", "remove", "rename", "mkdir", "rmdir", "chmod", "link",
              "truncate", "system", "fork", "exit", "kill", "signal", "raise", "abort", "socket", "connect", "bind",
              "listen", "accept", "send", "recv", "sendto", "dup", "dup2", "pipe", "atexit", "_exit"}
# Allowed, but worth a look when a PR adds them.
REVIEW = {"ProcessInfo": "reads the process environment", "NSLock": "a lock: check what it guards",
          "withUnsafeMutableBytes": "raw memory", "withUnsafeBytes": "raw memory",
          "bindMemory": "raw memory", "assumingMemoryBound": "raw memory"}

MAX_UNIVERSE_FILE_LINES = 2000
MAX_LINE = 260
HIDDEN_CHARS = re.compile("[؜​-‏‪-‮⁠-⁤⁦-⁩﻿­  ]")

# Prefixes for names new to the universes that predate this guard (their old names stay as they are). A new
# universe's prefix is its `<Prefix>Roster.swift`, as the clawdify guide lays out.
PREFIXES = {
    "StarClawds": ["starWars", "starClawds"], "MarvelousClawds": ["marvel"], "DetectiveClawds": ["dc", "detective"],
    "DoctorClawd": ["doctor"], "ClawdFiles": ["files"], "StevieClawdberg": ["clawdberg", "cb"],
    "ClawdOfTheRings": ["rings", "middleEarth"],
}


def git(*args, check=True):
    r = subprocess.run(["git", *args], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if check and r.returncode != 0:
        sys.exit("git %s failed: %s" % (" ".join(args), r.stderr.decode(errors="replace").strip()))
    return r.stdout


def show(rev, path):
    """A file's bytes at `rev`, or None if it isn't there."""
    r = subprocess.run(["git", "show", "%s:%s" % (rev, path)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return r.stdout if r.returncode == 0 else None


# --- Swift, as far as the checks need it -------------------------------------------------------------------------

def code_only(src):
    """`src` with comments blanked to spaces and string contents to `_`, same length and line breaks, so positions
    still match. Code inside string interpolation `\\( … )` stays: a call hidden there still counts."""
    out = list(src)
    n = len(src)
    stack = [["code", 0]]          # ["code", parens] (parens > 0 only inside an interpolation) or ["str", hashes, multiline]
    i = 0

    def blank(a, b, ch):
        for k in range(a, min(b, n)):
            if out[k] != "\n":
                out[k] = ch

    while i < n:
        top = stack[-1]
        if top[0] == "code":
            if src.startswith("//", i):
                j = src.find("\n", i)
                j = n if j < 0 else j
                blank(i, j, " ")
                i = j
                continue
            if src.startswith("/*", i):
                depth, j = 1, i + 2
                while j < n and depth:
                    if src.startswith("/*", j):
                        depth, j = depth + 1, j + 2
                    elif src.startswith("*/", j):
                        depth, j = depth - 1, j + 2
                    else:
                        j += 1
                blank(i, j, " ")
                i = j
                continue
            h = 0
            while i + h < n and src[i + h] == "#":
                h += 1
            if i + h < n and src[i + h] == '"':
                multi = src.startswith('"""', i + h)
                stack.append(["str", h, multi])
                i += h + (3 if multi else 1)
                continue
            if len(stack) > 1:      # inside an interpolation: its closing paren goes back to the string
                if src[i] == "(":
                    top[1] += 1
                elif src[i] == ")":
                    if top[1] == 0:
                        stack.pop()
                        i += 1
                        continue
                    top[1] -= 1
            i += max(h, 1)
            continue
        _, h, multi = top
        close = ('"""' if multi else '"') + "#" * h
        if src.startswith(close, i):
            stack.pop()
            i += len(close)
            continue
        if src[i] == "\\" and src.startswith("#" * h, i + 1):
            k = i + 1 + h
            if k < n and src[k] == "(":
                stack.append(["code", 0])
                i = k + 1
                continue
            blank(i, k + 1, "_")
            i = k + 1
            continue
        if src[i] == "\n" and not multi:   # unterminated: don't let it swallow the file
            stack.pop()
            continue
        blank(i, i + 1, "_")
        i += 1
    return "".join(out)


def depths(code):
    """The bracket depth ((, [ and { together) at the start of each line of `code`."""
    result, d = [], 0
    for line in code.split("\n"):
        result.append(d)
        for ch in line:
            if ch in "([{":
                d += 1
            elif ch in ")]}":
                d = max(0, d - 1)
    return result


DECL = re.compile(
    r"^\s*(?P<attrs>(?:@\w+(?:\([^)]*\))?\s+)*)"
    r"(?P<mods>(?:(?:public|internal|private|fileprivate|open|package|static|final|indirect|lazy|nonisolated"
    r"(?:\(unsafe\))?|override|convenience|required|mutating|nonmutating|prefix|postfix|infix)\s+)*)"
    r"(?P<kind>func|let|var|struct|class|enum|protocol|typealias|extension|actor|macro|operator|precedencegroup"
    r"|import)\b\s*(?P<rest>.*)$")


def top_level(code):
    """(line number, private?, kind, name, rest) for each declaration at the top level of a file."""
    found = []
    lines = code.split("\n")
    for no, (line, d) in enumerate(zip(lines, depths(code)), 1):
        if d:
            continue
        m = DECL.match(line)
        if not m:
            continue
        rest = m.group("rest")
        name = re.match(r"[A-Za-z_][A-Za-z0-9_]*|\S*", rest).group(0)
        private = bool(re.search(r"\b(private|fileprivate)\b", m.group("mods")))
        found.append((no, private, m.group("kind"), name, rest))
    return found


def universe_names(rev, folder):
    """Every top-level name a universe folder declares at `rev`, private ones included."""
    names = set()
    out = git("ls-tree", "-r", "--name-only", rev, "--", folder, check=False).decode()
    for path in out.splitlines():
        if path.endswith(".swift"):
            src = show(rev, path)
            if src is not None:
                names |= {t[3] for t in top_level(code_only(src.decode("utf-8", "replace")))}
    return names


def core_names(rev):
    """Every non-private top-level name outside the universe folders: a universe redeclaring one, or overloading it,
    could change what the app's own code calls."""
    names = set()
    out = git("ls-tree", "-r", "--name-only", rev, "--", "Sources", check=False).decode()
    for path in out.splitlines():
        if path.endswith(".swift") and not re.match(UNIVERSES + r"[^/]+/", path):
            src = show(rev, path)
            if src is not None:
                names |= {t[3] for t in top_level(code_only(src.decode("utf-8", "replace"))) if not t[1]}
    return names


# --- The checks --------------------------------------------------------------------------------------------------

class Report:
    def __init__(self):
        self.fails, self.warns, self.yellow, self.green = [], [], [], []

    def fail(self, where, why):
        self.fails.append((where, why))

    def warn(self, where, why):
        self.warns.append((where, why))


def added_lines(base, head, path):
    """Line numbers (in `head`'s file) that the PR adds or changes."""
    diff = git("diff", "--no-color", "--no-ext-diff", "-U0", "%s...%s" % (base, head), "--", path).decode("utf-8", "replace")
    nums = set()
    for m in re.finditer(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", diff, re.M):
        start, count = int(m.group(1)), int(m.group(2) or "1")
        nums.update(range(start, start + count))
    return nums


def check_swift(rep, base, head, path, src, added, strict, folder=None, prefixes=None, own_types=None,
                known_here=None, core=None):
    """Checks the lines a PR adds to a Swift file. `strict` (a universe's own folder) fails what elsewhere warns."""
    flag = rep.fail if strict else rep.warn
    code = code_only(src)
    tick = code.replace("`", " ")
    # Everyday names the file declares itself (a door's `open`, a sword's `raise`): using those is fine, but a call
    # still has to be to the file's own function.
    local = {w for w in BARE_CALLS if re.search(r"(\b(let|var|case|func|guard let|if let)\s+|,\s*)%s\b\s*[=:,)]|"
                                                 r"\b%s\s*:|[{,(]\s*%s\s*(,|\bin\b)" % (w, w, w), tick)}
    own_funcs = {w for w in BARE_CALLS
                 if re.search(r"\bfunc\s+%s\b|\b%s\s*:\s*(@escaping\s+)?\(" % (w, w), tick)}
    what = "universe code can't use this" if strict else "check why it's needed"
    raw_lines, code_lines = src.split("\n"), code.split("\n")
    for no in sorted(added):
        if no > len(code_lines):
            continue
        raw, line = raw_lines[no - 1], code_lines[no - 1]
        at = "%s:%d" % (path, no)
        if len(raw) > MAX_LINE:
            flag(at, "line is %d characters long (at most %d), which hides code off the right of a review"
                 % (len(raw), MAX_LINE))
        if re.search(r"\S {40,}\S", line):
            flag(at, "code after a long run of spaces, where a review won't see it")
        if any(ord(ch) > 127 for ch in line):
            flag(at, "non-ASCII character in code (only strings and comments may have them)")
        words = re.sub(r"`", " ", line)
        for m in re.finditer(r"[A-Za-z_][A-Za-z0-9_]*", words):
            w = m.group(0)
            before = words[:m.start()].rstrip()
            after = words[m.end():].lstrip()
            if w in BANNED or w.startswith(BANNED_PREFIXES):
                flag(at, "`%s` reaches files, processes, the network, other apps or the app's own sensitive code: "
                         "%s" % (w, what))
            elif w in BARE_CALLS and not before.endswith(".") and not after.startswith(":") \
                    and not re.search(r"\b(let|var|case|func)\s*$", before) \
                    and (w not in local or (after.startswith("(") and w not in own_funcs)):
                flag(at, "`%s` is a system call: %s" % (w, what))
            elif w in REVIEW:
                rep.warn(at, "`%s`: %s" % (w, REVIEW[w]))
        for m in re.finditer(r"@(\w+)", line):
            if m.group(1) not in ATTRIBUTES:
                flag(at, "attribute `@%s` isn't allowed in universe code" % m.group(1))
        for m in re.finditer(r"#(\w+)", line):
            if m.group(1) not in DIRECTIVES:
                flag(at, "`#%s` isn't allowed in universe code (compiler directives and macros)" % m.group(1))
        if re.search(r"\b(Foundation|AppKit|CoreGraphics|CoreText|Swift)\s*\.\s*[a-z_]", line):
            flag(at, "a module-qualified function call; universe code calls functions by plain name")
    if not strict:
        return
    lines = len(raw_lines)
    if lines > MAX_UNIVERSE_FILE_LINES:
        rep.fail(path, "%d lines; split it (at most %d per file, so every file can be reviewed)"
                 % (lines, MAX_UNIVERSE_FILE_LINES))
    if os.path.basename(path) == "main.swift":
        rep.fail(path, "a file called main.swift runs its top-level code at launch")
    for no, private, kind, name, rest in top_level(code):
        if no not in added:
            continue
        at = "%s:%d" % (path, no)
        if kind == "import":
            if not re.fullmatch(r"\s*[A-Za-z]+\s*", rest) or rest.strip() not in IMPORTS:
                rep.fail(at, "`import %s`: universe code imports only %s" % (rest.strip(), ", ".join(sorted(IMPORTS))))
            continue
        if kind in ("operator", "precedencegroup", "macro") or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            rep.fail(at, "custom operators, macros and multi-name declarations aren't allowed at the top level")
            continue
        if kind == "extension":
            if re.match(r"[A-Za-z_][A-Za-z0-9_.]*\s*(<[^>]*>)?\s*:", rest):
                rep.fail(at, "`extension %s` adds a conformance; declare it on your own type instead" % name)
            elif name not in EXTENDABLE and name not in own_types:
                rep.fail(at, "`extension %s`: a universe extends only %s, or its own types"
                         % (name, ", ".join(sorted(EXTENDABLE))))
            continue
        if private:
            continue
        if name in core:
            rep.fail(at, "`%s` is already a name in the app's own code; a universe redeclaring or overloading it "
                         "could change what the app calls. Pick a %s… name" % (name, prefixes[0]))
            continue
        if name in known_here:
            continue
        if not any(name.lower().startswith(p.lower()) for p in prefixes):
            rep.fail(at, "new top-level `%s`: make it private, or start it with %s (a plain name can shadow one of "
                         "the SDK's, e.g. `chmod`, and change the app's own code)"
                     % (name, " or ".join("`%s…`" % p for p in prefixes)))
        elif re.search(r"=\s*\{", rest):
            rep.warn(at, "`%s` is set by running a closure; check what it does" % name)


def check_ids(rep, head):
    """Cast ids are `universe * 1000 + local`, villains 0..<heroBase and heroes from heroBase: no universe may spill
    into the next one's ids or its own heroes'."""
    src = show(head, "Sources/Shared/Universe.swift")
    store = show(head, "Sources/Shared/StatusStore.swift")
    if src is None or store is None:
        rep.fail("Sources/Shared/Universe.swift", "missing")
        return
    src = code_only(src.decode("utf-8", "replace"))
    m = re.search(r"static let heroBase = (\d+)", store.decode("utf-8", "replace"))
    hero_base = int(m.group(1)) if m else 100
    cases = re.findall(r"^\s*case (\w+) = (\d+)\s*$", src, re.M)
    raws = [int(r) for _, r in cases]
    if len(set(raws)) != len(raws):
        rep.fail("Sources/Shared/Universe.swift", "two universes share a raw value: %s" % cases)

    def counts(var):
        body = re.search(r"var %s: Int \{(.*?)\n    \}" % var, src, re.S)
        return dict(re.findall(r"case \.(\w+): return (\d+)", body.group(1))) if body else {}

    villains, heroes = counts("villainCount"), counts("heroCount")
    for name, _ in cases:
        if name not in villains or name not in heroes:
            rep.fail("Sources/Shared/Universe.swift", "couldn't find the villain and hero counts of `%s`" % name)
            continue
        if int(villains[name]) > hero_base:
            rep.fail("Sources/Shared/Universe.swift", "`%s` has %s villains; ids run out at %d (they'd become heroes')"
                     % (name, villains[name], hero_base))
        if hero_base + int(heroes[name]) > 1000:
            rep.fail("Sources/Shared/Universe.swift", "`%s` has %s heroes; ids run out at %d (they'd become the next "
                     "universe's)" % (name, heroes[name], 1000 - hero_base))


def classify(rep, status, path, old_mode, new_mode, head):
    """Puts a changed file in its group; True if it's a universe file to check as such."""
    if new_mode in ("120000", "160000") or old_mode in ("120000", "160000"):
        rep.fail(path, "symlinks and submodules aren't allowed")
        return False
    for pattern, why in RED:
        if re.search(pattern, path):
            rep.fail(path, ("deletes " if status == "D" else "") + why + ": ask the maintainer")
            return False
    if new_mode == "100755" and status != "D":
        rep.fail(path, "an executable file")
        return False
    if status == "A" and os.path.dirname(path) in CORE_FOLDERS:
        rep.fail(path, "a new file in the app's core: universe code goes in its own folder under " + UNIVERSES)
        return False
    if status != "D":
        data = show(head, path)
        if data is not None and b"\0" not in data[:8000] and HIDDEN_CHARS.search(data.decode("utf-8", "replace")):
            rep.fail(path, "has invisible or text-direction Unicode characters, which can make code read differently "
                           "from how it runs")
    if any(re.search(p, path) for p in GREEN):
        rep.green.append(path)
        return path.startswith(UNIVERSES) and status != "D"
    rep.yellow.append(path)
    return False


def main(argv):
    if len(argv) == 2 and argv[1].isdigit():
        pr = argv[1]
        git("fetch", "--quiet", "--no-tags", "origin",
            "+refs/pull/%s/head:refs/pr-guard/head" % pr, "+refs/heads/main:refs/pr-guard/main")
        base, head = "refs/pr-guard/main", "refs/pr-guard/head"
        title = "PR #%s" % pr
    elif len(argv) == 3:
        base, head = argv[1], argv[2]
        title = "%s...%s" % (base, head)
    else:
        print(__doc__.split("\n\n")[1], file=sys.stderr)
        return 2
    os.chdir(git("rev-parse", "--show-toplevel").decode().strip())
    merge_base = git("merge-base", base, head).decode().strip()

    rep = Report()
    raw = git("diff", "--raw", "-z", "--no-renames", "--no-abbrev", "%s...%s" % (base, head)).decode("utf-8", "replace")
    parts = raw.split("\0")
    universe_files = []
    for meta, path in zip(parts[0::2], parts[1::2]):
        if not meta.startswith(":"):
            continue
        old_mode, new_mode, _, _, status = meta[1:].split()
        if classify(rep, status[0], path, old_mode, new_mode, head):
            universe_files.append(path)

    core = core_names(merge_base)
    for path in rep.yellow:
        if path.endswith(".swift") and show(head, path) is not None:
            src = show(head, path).decode("utf-8", "replace")
            check_swift(rep, base, head, path, src, added_lines(base, head, path), strict=False)
    folders = {}
    for path in universe_files:
        folders.setdefault(path[len(UNIVERSES):].split("/")[0], []).append(path)
    for folder, paths in sorted(folders.items()):
        root = UNIVERSES + folder
        prefixes = PREFIXES.get(folder)
        if prefixes is None:
            files = git("ls-tree", "-r", "--name-only", head, "--", root).decode().splitlines()
            rosters = [os.path.basename(f)[:-len("Roster.swift")] for f in files if f.endswith("Roster.swift")]
            if len(rosters) != 1 or not rosters[0]:
                rep.fail(root, "a new universe has exactly one <Prefix>Roster.swift, whose prefix its top-level "
                               "names share (see clawdify_guide.md)")
                continue
            prefixes = [rosters[0]]
        before = universe_names(merge_base, root)
        own_types = set()
        for f in git("ls-tree", "-r", "--name-only", head, "--", root).decode().splitlines():
            if f.endswith(".swift"):
                own_types |= {t[3] for t in top_level(code_only(show(head, f).decode("utf-8", "replace")))
                              if t[2] in ("struct", "enum", "class")}
        for path in paths:
            src = show(head, path).decode("utf-8", "replace")
            check_swift(rep, base, head, path, src, added_lines(base, head, path), strict=True, folder=folder,
                        prefixes=prefixes, own_types=own_types, known_here=before, core=core - before)

    check_ids(rep, head)

    out = ["## PR guard: %s" % title, ""]
    if rep.fails:
        out += ["### ❌ Can't be merged as it is (%d)" % len(rep.fails), ""]
        out += ["- `%s`: %s" % f for f in rep.fails] + [""]
    if rep.yellow or rep.warns:
        out += ["### ⚠️ For the maintainer to read closely", ""]
        out += ["- `%s`" % p for p in rep.yellow]
        out += ["- `%s`: %s" % w for w in rep.warns] + [""]
    out += ["### ✅ %d file%s in a universe folder or the docs" % (len(rep.green), "" if len(rep.green) == 1 else "s"),
            "", "Nothing here was built or run: the guard reads the PR as text." if not rep.fails else
            "If one of these blocks something you need, say so in the PR and the maintainer will look at it.", ""]
    text = "\n".join(out)
    print(text)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as f:
            f.write(text + "\n")
    return 1 if rep.fails else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
