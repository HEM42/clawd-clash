#!/bin/zsh
# check-universe: a checklist for one universe's folder, or for all of them, before it's handed off.
#   Tools/CheckUniverse/check.sh StarClawds            one universe, by its folder in Sources/App/Universes/
#   Tools/CheckUniverse/check.sh --all                 every registered universe
#   BASE=universe-modules Tools/CheckUniverse/check.sh Slayer    the hand-off scope against another branch than main
#   QUICK=1 Tools/CheckUniverse/check.sh --all         no builds of the app, saver, Preview or Transitions, no sheets
# It prints a list per universe: ✓ passes, ✗ fails, ! is worth a look, · is a note. It exits 1 if anything fails.
#
# This part does the files and git: the manifest against NUMBERS, the template's leftovers, what the branch changed,
# file and top-level names, and whether the core names the universe (or the universe another). What only running the
# code can tell (counts, homes, place keys, magic, signatures, nemeses, rides, transitions) is Tools/CheckUniverse/
# main.swift, built through Tools/universes.sh with every registered universe, like Tools/Preview. The ids are
# compared with main's: Tools/CheckUniverse/Ids/main.swift is built twice, here and against a copy of main's Sources
# (`git archive`, so nothing is checked out). Everything it builds and renders goes into build/check/, the sheets
# into build/check/<key>/. Builds run side by side; their logs are in build/check/logs/.
#
# Not done yet: the release-style universal build (an arm64 and x86_64 type check of the dense drawing code). The
# app's type check here flags expressions slower than 300 ms instead, which is what trips those builds up.
set -uo pipefail
cd "${0:A:h}/../.."
ROOT=$PWD
UROOT=Sources/App/Universes
OUT=build/check
BASE=${BASE:-main}
mkdir -p $OUT/logs

if [[ $# -eq 0 ]]; then
    print "usage: Tools/CheckUniverse/check.sh <Folder> … | --all"; exit 2
fi

# MARK: NUMBERS and the manifests

typeset -A num_key num_folder num_status
while read -r n k f st; do
    [[ -z $n || $n == \#* ]] && continue
    num_key[$n]=$k; num_folder[$n]=$f; num_status[$n]=$st
done < $UROOT/NUMBERS

# Every folder's manifest, as key=value pairs: conf_<field>[folder].
typeset -A conf_number conf_key conf_title conf_prefix conf_entry conf_template
all_folders=()
for conf in $UROOT/*/universe.conf(N); do
    f=${${conf:h}:t}
    all_folders+=($f)
    while IFS='=' read -r k v; do
        k=${k//[[:space:]]/}; [[ -z $k || $k == \#* ]] && continue
        v=${v%%\#*}; v=${v#"${v%%[![:space:]]*}"}; v=${v%"${v##*[![:space:]]}"}
        case $k in
            number) conf_number[$f]=$v ;; key) conf_key[$f]=$v ;; title) conf_title[$f]=$v ;;
            prefix) conf_prefix[$f]=$v ;; entry) conf_entry[$f]=$v ;; template) conf_template[$f]=$v ;;
        esac
    done < $conf
done

folders=()
if [[ $1 == --all ]]; then
    # In number order.
    for f in ${(f)"$(for g in $all_folders; do print -r -- "${conf_number[$g]-999}	$g"; done | sort -n | cut -f2)"}; do
        [[ $f == _* ]] || folders+=($f)
    done
else
    for a in "$@"; do
        f=${${a%/}:t}
        [[ -f $UROOT/$f/universe.conf ]] || { print "no universe.conf in $UROOT/$f/"; exit 2 }
        folders+=($f)
    done
fi

# MARK: Builds, side by side

# build <name> <command…>: in the background, its output in build/check/logs/<name>.log.
typeset -A jobs_pid
build() {
    local name=$1; shift
    ( "$@" ) >$OUT/logs/$name.log 2>&1 &
    local pid=$!   # (`jobs_pid[$name]=$!` would store the text "$!")
    jobs_pid[$name]=$pid
}
typeset -A built   # name → 0 (fine) or the exit status

registry_ok=1
if ! source Tools/universes.sh 2>$OUT/logs/universes.log; then
    registry_ok=0
fi
TARGET=(-swift-version 5 -target "$(uname -m)-apple-macos13.0")
JOBS=(-j "$(sysctl -n hw.ncpu)")
TOOL_SRC=(Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift)

# Main's ids, from a copy of its Sources (rebuilt only when main moves).
main_ids() {
    local rev=$(git rev-parse "main^{commit}") src=$OUT/main-src
    if [[ -x $OUT/ids-main && $(cat $src/.rev 2>/dev/null) == $rev ]]; then return 0; fi
    rm -rf $src; mkdir -p $src
    git archive main Sources Tools | tar -x -C $src || return 1
    local list=(${(s: :)$(grep -o 'Sources/App/{[^}]*}\.swift' $src/Tools/Preview/build.sh | head -1)})
    (
        cd $src
        if [[ -f Tools/universes.sh ]]; then
            source Tools/universes.sh || exit 1
            eval "srcs=($list \$UNIVERSE_APP Sources/Shared/*.swift)"
        else
            eval "srcs=($list Sources/App/Universes/**/*.swift(N) Sources/Shared/*.swift)"
        fi
        swiftc $TARGET $JOBS $srcs $ROOT/Tools/CheckUniverse/Ids/main.swift -o $ROOT/$OUT/ids-main
    ) || return 1
    print $rev > $src/.rev
}

if (( registry_ok )); then
    build checker swiftc $TARGET $JOBS $TOOL_SRC $UNIVERSE_APP Sources/Shared/*.swift Tools/CheckUniverse/main.swift -o $OUT/check-universe
    build ids swiftc $TARGET $JOBS $TOOL_SRC $UNIVERSE_APP Sources/Shared/*.swift Tools/CheckUniverse/Ids/main.swift -o $OUT/ids-head
    build ids-main main_ids
    build hook swiftc $TARGET Sources/Shared/*.swift $UNIVERSE_FACTS Sources/Hook/main.swift -o $OUT/hook
    if [[ -z ${QUICK:-} ]]; then
        # The app and the screen saver are type-checked, not compiled (./build.sh would clear build/); the app's check
        # also flags expressions slower than 300 ms, which is what trips up the universal release build.
        build app swiftc -typecheck $TARGET $JOBS -Xfrontend -warn-long-expression-type-checking=300 \
            Sources/Shared/*.swift Sources/App/*.swift $UNIVERSE_APP Sources/Saver/*.swift
        build saver swiftc -typecheck $TARGET $JOBS -parse-as-library -module-name ClawdClashSaver \
            Sources/Shared/*.swift Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Accents,Habits,Drills,Icon,Rides}.swift \
            $UNIVERSE_APP Sources/Saver/*.swift
        build preview Tools/Preview/build.sh
        build transitions Tools/Transitions/build.sh
    fi
fi
for name pid in ${(kv)jobs_pid}; do wait $pid; built[$name]=$?; done

# MARK: What the tools know

facts=$OUT/facts.tsv
: > $facts
(( ${built[checker]:-1} == 0 )) && $OUT/check-universe facts > $facts 2>$OUT/logs/facts.log
# ukey for a folder, from the manifest.
typeset -A place_keys ride_keys batches
while IFS=$'\t' read -r kind k a b; do
    case $kind in
        place) place_keys[$k]+="$a " ;;
        ride) ride_keys[$k]+="$a " ;;
    esac
done < $facts

(( ${built[ids]:-1} == 0 )) && $OUT/ids-head $OUT/ids-head.tsv 2>$OUT/logs/ids-head-run.log
(( ${built[ids-main]:-1} == 0 )) && $OUT/ids-main $OUT/ids-main.tsv 2>$OUT/logs/ids-main-run.log

# MARK: Names: top-level declarations, and who mentions whom

# Every top-level declaration in the universes' folders: folder, file, line, name, and "private" or "open".
read -r -d '' DECLS <<'PERL'
my $root = shift;
for my $file (@ARGV) {
    my ($folder) = $file =~ m{^\Q$root\E/([^/]+)/};
    open my $fh, '<', $file or next;
    while (my $line = <$fh>) {
        next unless $line =~ /^((?:@\w+(?:\([^)]*\))?\s+)*)((?:(?:public|internal|private|fileprivate|final|nonisolated|indirect)\s+)*)(func|let|var|struct|enum|class|protocol|typealias|actor)\s+([A-Za-z_]\w*)(.*)$/;
        my ($mods, $kind, $name, $rest) = ($2, $3, $4, $5);
        my $vis = $mods =~ /\b(?:private|fileprivate)\b/ ? 'private' : 'open';
        my @names = ($name);
        if ($kind eq 'let' || $kind eq 'var') {
            # More names on the same line, `let a = 1, b = 2`: split at the commas outside brackets.
            my ($depth, $piece, @pieces) = (0, '');
            for my $ch (split //, $rest) {
                if ($ch =~ /[(\[{]/) { $depth++ } elsif ($ch =~ /[)\]}]/) { $depth-- }
                if ($ch eq ',' && $depth == 0) { push @pieces, $piece; $piece = ''; next }
                $piece .= $ch;
            }
            push @pieces, $piece;
            shift @pieces;   # the first name's own type and value
            for (@pieces) { push @names, $1 if /^\s*([A-Za-z_]\w*)\s*(?::[^=]*)?=(?!=)/ }
        }
        print "$folder\t$file\t$.\t$_\t$vis\n" for @names;
    }
}
PERL
decls=$OUT/decls.tsv
perl -e "$DECLS" $UROOT ${(f)"$(find $UROOT -mindepth 2 -name '*.swift' | sort)"} > $decls

# The core-blind lint: every line of code (comments left out) that names a universe's top-level names, its constant
# (`.key`, or `key: "key"`), its place keys or its ride keys (`.key` or "key"), anywhere but its own folder. Inside
# another universe's folder, words that universe has too (its own names, keys and enum cases: Marvelous' Falcon isn't
# Star Clawds' ship) don't count. Tokens: universe key, kind (name, universe, key or case), token.
tokens=$OUT/tokens.tsv
: > $tokens
for f in $all_folders; do
    [[ $f == _* ]] && continue
    k=${conf_key[$f]-}
    # Not the showcase's and reel's names (Promo/ is built into its tool alone): `ride` and `beam` there would match
    # every local of that name.
    awk -F'\t' -v f="$f" -v k="$k" '$1==f && $5=="open" && $2 !~ /\/Promo\// {print k "\tname\t" $4}' $decls >> $tokens
    print -r -- "$k	universe	$k" >> $tokens
    for p in ${(z)place_keys[$k]-} ${(z)ride_keys[$k]-}; do print -r -- "$k	key	$p" >> $tokens; done
    for c in ${(f)"$(grep -hE '^[[:space:]]*case [a-z]' $UROOT/$f/*Facts.swift(N) | sed -E 's/^[[:space:]]*case //; s/\/\/.*//; s/[=][^,]*//g' | tr ',' '\n' | tr -d ' ')"}; do
        [[ -n $c ]] && print -r -- "$k	case	$c" >> $tokens
    done
done
read -r -d '' LINT <<'PERL'
my ($root, $tokens, $folders) = (shift, shift, shift);
my %folder_of = map { split /=/ } split / /, $folders;   # key=Folder
my %key_of = reverse %folder_of;
my (%tok, %own);   # universe → kind → [tokens]; universe → every word it has
open my $t, '<', $tokens or die;
while (<$t>) { chomp; my ($u, $kind, $w) = split /\t/; push @{ $tok{$u}{$kind} //= [] }, $w; $own{$u}{$w} = 1 }
my %re;   # "u/owner" → the pattern for u's words, less owner's
sub pattern {
    my ($u, $owner) = @_;
    my $key = "$u/" . ($owner // '');
    return $re{$key} if exists $re{$key};
    my $mine = defined $owner ? $own{$owner} // {} : {};
    my $alt = sub { my @w = grep { !$mine->{$_} } @{ $tok{$u}{$_[0]} // [] }; @w ? join('|', map { quotemeta } sort { length $b <=> length $a } @w) : undef };
    my @alts;
    if (my $n = $alt->('name')) { push @alts, "\\b(?:$n)\\b" }
    if (my $n = $alt->('universe')) { push @alts, "\\.(?:$n)\\b", "key: \"(?:$n)\"" }
    if (my $n = $alt->('key')) { push @alts, "\\.(?:$n)\\b", "\"(?:$n)\"" }
    return $re{$key} = @alts ? qr/(@{[join '|', @alts]})/ : undef;
}
for my $file (@ARGV) {
    my ($folder) = $file =~ m{^\Q$root\E/([^/]+)/};
    my $owner = defined $folder ? $key_of{$folder} : undef;
    open my $fh, '<', $file or next;
    my $in_block = 0;
    while (my $line = <$fh>) {
        chomp $line;
        my $code = $line;
        if ($in_block) { next unless $code =~ s{^.*?\*/}{}; $in_block = 0 }
        $code =~ s{/\*.*?\*/}{}g;
        if ($code =~ s{/\*.*$}{}) { $in_block = 1 }
        $code =~ s{//.*$}{};
        $code =~ s{^\s*#.*$}{} if $file =~ /\.sh$/;
        next unless $code =~ /\S/;
        for my $u (sort keys %folder_of) {
            next if defined $owner && $u eq $owner;
            my $re = pattern($u, $owner) or next;
            while ($code =~ /$re/g) { my $hit = $1; $hit =~ s/^(?:key: )?[."]|"$//g; print "$u\t$file:$.\t$hit\t$line\n" }
        }
    }
}
PERL
lint=$OUT/lint.tsv
folder_map=()
for f in $all_folders; do [[ $f == _* ]] || folder_map+=("${conf_key[$f]-}=$f"); done
lint_files=(${(f)"$(find Sources Tools -name '*.swift' -o -name '*.sh' | grep -v '^Tools/CheckUniverse/' | sort)"} build.sh release.sh)
perl -e "$LINT" $UROOT $tokens "${folder_map[*]}" $lint_files > $lint

# Known exceptions: the owner's own artwork and reels (MakeSocial's cover, MakeIcon, the main promo, the bloopers and
# the Royale teaser in RenderPromo's main.swift), the baseline's list of reels, and in the app the old apps' migration
# (a fresh install takes after Clawd Wars, Avengers or Justice League) and About's "Thanks to" list.
exempt() {
    local where=$1 line=$2
    [[ $where == Tools/MakeSocial/* || $where == Tools/MakeIcon/* || $where == Tools/RenderPromo/main.swift:* \
        || $where == Tools/Baseline/* ]] && return 0
    [[ $where == Sources/App/Overlay.swift:* ]] || return 1
    [[ $line == *com.rodclemen.* || $line == *'var first = Universe.'* || $line =~ '^\s*\("[^"]+", "[^"]+", \[' ]]
}

# MARK: The checklist

failed=0
# say <mark> <text>: one line of the list.
say() { print -r -- "  $1 $2"; [[ $1 == ✗ ]] && failed=1; return 0 }
some() { local n=${N:-6}; (( $# <= n )) && print -r -- "${(j:, :)@}" || print -r -- "${(j:, :)@[1,n]} and $(( $# - n )) more" }

branch=$(git symbolic-ref --short -q HEAD || print detached)

# The repo as a whole: the registry and the never-shown guard on globs.
print "The repo"
if (( registry_ok )); then
    say ✓ "registry: every manifest agrees with NUMBERS (Tools/universes.sh)"
else
    say ✗ "registry: $(cat $OUT/logs/universes.log | head -3)"
fi
globs=(${(f)"$(grep -lE 'Universes/\*\*/' build.sh release.sh Tools/*.sh Tools/*/*.sh Tools/*/main.swift 2>/dev/null | grep -v '^Tools/CheckUniverse/')"})
if (( ${#globs} )); then say ✗ "a Universes/** glob is back in $(some $globs): it would compile the template"
else say ✓ "no Universes/** glob in any build script or tool header"; fi
build_names=(hook)
[[ -z ${QUICK:-} ]] && build_names=(app saver hook preview transitions)
broken=()
for b in checker ids ids-main $build_names; do (( ${built[$b]:-1} == 0 )) || broken+=($b); done
if (( ! registry_ok )); then
    say ✗ "builds: none, the registry didn't add up"
elif (( ${#broken} )); then
    say ✗ "builds: $(some $broken) failed (see $OUT/logs/<name>.log)"
else
    say ✓ "builds: ${(j:, :)build_names}, check-universe and the ids dumps (here and main's)${QUICK:+ (QUICK: app, saver, Preview and Transitions skipped)}"
fi
[[ -z ${QUICK:-} ]] && say · "not done: the release-style universal type check (arm64 and x86_64); the app's type check flags slow expressions instead"
print

all_names=$OUT/all-swift-names.txt
find Sources Tools -name '*.swift' | awk -F/ '{print $NF}' | sort > $all_names

for f in $folders; do
    dir=$UROOT/$f
    n=${conf_number[$f]-} k=${conf_key[$f]-} prefix=${conf_prefix[$f]-} entry=${conf_entry[$f]-}
    print "${conf_title[$f]-$f} ($k, $n)"

    # Manifest and numbers.
    bad=()
    [[ -n $n ]] || bad+=("no number"); [[ -n $k ]] || bad+=("no key"); [[ -n ${conf_title[$f]-} ]] || bad+=("no title")
    [[ -n $prefix ]] || bad+=("no prefix"); [[ -n $entry ]] || bad+=("no entry")
    if [[ -n $n ]]; then
        if [[ -z ${num_key[$n]-} ]]; then bad+=("number $n isn't in NUMBERS: ask the owner for one")
        elif [[ ${num_key[$n]} != $k || ${num_folder[$n]} != $f ]]; then bad+=("NUMBERS has $n as ${num_key[$n]} in ${num_folder[$n]}/")
        fi
        [[ $n == <-> ]] && (( n >= 900 )) && bad+=("number $n: 900 and up is kept for the template")
    fi
    for g in $all_folders; do
        [[ $g == $f ]] && continue
        [[ -n $k && ${conf_key[$g]-} == $k ]] && bad+=("key $k is $g's too")
        [[ -n $n && ${conf_number[$g]-} == $n ]] && bad+=("number $n is $g's too")
        [[ -n $prefix && ${conf_prefix[$g]-} == $prefix ]] && bad+=("prefix $prefix is $g's too")
        [[ -n $entry && ${conf_entry[$g]-} == $entry ]] && bad+=("entry $entry is $g's too")
    done
    [[ -n $entry ]] && ! grep -qE "^(struct|final class|class|enum) $entry\b" $dir/**/*.swift(N) && bad+=("its entry $entry isn't declared in the folder")
    if (( ${#bad} )); then say ✗ "manifest: ${(j:; :)bad}"
    else say ✓ "manifest: number $n matches NUMBERS (${num_status[$n]}), key and folder match; key, prefix and entry are its own"; fi

    # Not the template (the same tests as Tools/universes.sh's guard 8, and a few more).
    bad=()
    if [[ $f != _* ]]; then
        [[ $k == template ]] && bad+=("key = template")
        [[ $n == 999 ]] && bad+=("number = 999")
        [[ $prefix == Template ]] && bad+=("prefix = Template")
        [[ $entry == TemplateUniverse ]] && bad+=("entry = TemplateUniverse")
        [[ ${conf_template[$f]-} == yes ]] && bad+=("template = yes")
        tfiles=($dir/**/Template*(N:t))
        (( ${#tfiles} )) && bad+=("files named Template…: $(some $tfiles)")
        samples=(${(M)${(z)place_keys[$k]-}:#sample*})
        (( ${#samples} )) && bad+=("place keys sample…: $(some $samples)")
        grep -rlq CLAWD_TEMPLATE $dir 2>/dev/null && bad+=("a CLAWD_TEMPLATE line")
    fi
    if (( ${#bad} )); then say ✗ "not the template: $f/ still says ${(j:, :)bad}: give it its own key, number and prefix from NUMBERS"
    else say ✓ "not the template: no template key, number, prefix, file, sample place or CLAWD_TEMPLATE left"; fi

    # Hand-off scope.
    if [[ $branch == main || $branch == universe-modules ]]; then
        say · "hand-off scope: skipped on $branch (only a hand-off branch is checked)"
    elif ! git rev-parse -q --verify "$BASE^{commit}" >/dev/null; then
        say ! "hand-off scope: no $BASE to compare with"
    else
        changed=(${(f)"$(git diff --name-only "$BASE...HEAD")"})
        inside=(${(M)changed:#$dir/*})
        outside=(${changed:#$dir/*})
        if (( ${#inside} == 0 )); then
            say · "hand-off scope: $branch changes nothing in $f/ since $BASE, so it isn't its hand-off"
        elif (( ${#outside} )); then
            say ✗ "hand-off scope: ${#outside} files outside $f/ changed since $BASE: $(some $outside)"
        else
            say ✓ "only this folder changed since $BASE (${#inside} files under $f/)"
        fi
    fi

    # File names: the prefix, and unique in the repo (Swift needs that).
    files=($dir/**/*.swift(N:t))
    unprefixed=(${files:#$prefix*})
    clash=()
    for x in $files; do (( $(grep -cx -- "$x" $all_names) > 1 )) && clash+=($x); done
    if (( ${#unprefixed} || ${#clash} )); then
        msg=()
        (( ${#unprefixed} )) && msg+=("${#unprefixed} of ${#files} don't start with $prefix: $(some $unprefixed)")
        (( ${#clash} )) && msg+=("used elsewhere in the repo too: $(some ${(u)clash})")
        say ✗ "file names: ${(j:; :)msg}"
    else
        say ✓ "file names: all ${#files} start with $prefix, none clash with another file in the repo"
    fi

    # Top-level names: prefixed (any letter case), or private.
    lower=${(L)prefix}
    loose=(${(f)"$(awk -F'\t' -v f="$f" -v p="$lower" '$1==f && $5=="open" && index(tolower($4), p) != 1 {print $4}' $decls | sort -u)"})
    if (( ${#loose} )); then
        awk -F'\t' -v f="$f" -v p="$lower" '$1==f && $5=="open" && index(tolower($4), p) != 1 {sub(/^.*\/Universes\/[^\/]+\//, "", $2); print $4 "\t" $2 ":" $3}' $decls \
            | sort > $OUT/$k-unprefixed.txt
        say ✗ "top-level names: ${#loose} aren't prefixed ($prefix…) or private: $(N=8 some $loose) (all in $OUT/$k-unprefixed.txt)"
    else
        say ✓ "top-level names: every one that isn't private starts with $prefix"
    fi

    # What only running it can tell.
    if (( ${built[checker]:-1} == 0 )); then
        while IFS= read -r l; do say ${l%% *} "${l#* }"; done < <($OUT/check-universe check $k 2>&1 || print "✗ check-universe stopped: see above")
    else
        say ✗ "counts, homes, places, magic, signatures, nemeses, rides, transitions: not checked, check-universe didn't build"
    fi

    # Ids: every id, place and magic look main has must be the same here.
    if [[ -s $OUT/ids-head.tsv && -s $OUT/ids-main.tsv ]]; then
        main_lines=(${(f)"$(awk -F'\t' -v k="$k" '$3==k' $OUT/ids-main.tsv)"})
        if (( ${#main_lines} == 0 )); then
            say · "ids: new since main, nothing to compare"
        else
            gone=(${(f)"$(awk -F'\t' -v k="$k" 'NR==FNR {if ($3==k) seen[$0]=1; next} $3==k && !seen[$0] {print $1 " " $2 " (" $4 ")"}' $OUT/ids-head.tsv $OUT/ids-main.tsv)"})
            ids_main=$(awk -F'\t' -v k="$k" '$1=="id" && $3==k' $OUT/ids-main.tsv | wc -l | tr -d ' ')
            ids_head=$(awk -F'\t' -v k="$k" '$1=="id" && $3==k' $OUT/ids-head.tsv | wc -l | tr -d ' ')
            if (( ${#gone} )); then
                say ✗ "ids: ${#gone} of main's ids, places or magic looks differ here: $(N=4 some $gone)"
            else
                extra=$(( ids_head - ids_main ))
                say ✓ "ids: all $ids_main of main's ids have the same character, places and magic looks as on main$( (( extra > 0 )) && print "; $extra new")"
            fi
        fi
    else
        say ✗ "ids: not compared, the ids dumps didn't build or run (see $OUT/logs/)"
    fi

    # Core-blind: nobody outside the folder names it, and it names no other universe.
    core=() tools=() others=()
    while IFS=$'\t' read -r u where tok line; do
        exempt $where "$line" && continue
        file=${where%:*}
        if [[ $u == $k ]]; then
            [[ $file == $UROOT/* ]] && continue      # another universe naming this one: reported on that one
            if [[ $file == Sources/* ]]; then core+=("$tok ($where)"); else tools+=("$tok ($where)"); fi
        elif [[ $file == $dir/* ]]; then
            others+=("$u's $tok (${where#$dir/})")
        fi
    done < $lint
    if (( ${#core} || ${#others} )); then
        msg=()
        (( ${#core} )) && msg+=("the core names it: $(N=4 some ${(u)core})")
        (( ${#others} )) && msg+=("it names another universe: $(N=4 some ${(u)others})")
        say ✗ "core-blind: ${(j:; :)msg}"
    else
        say ✓ "the core doesn't name this universe; this universe doesn't name any other"
    fi
    (( ${#tools} )) && say ! "tools that name it (not the owner's own art): $(N=4 some ${(u)tools})"

    # Slow expressions in its code (the app's type check).
    if [[ -z ${QUICK:-} && -f $OUT/logs/app.log ]]; then
        slow=(${(f)"$(grep -E "^$dir/.*to type-check" $OUT/logs/app.log | sed -E "s|^$dir/||; s|: warning: .* took ([0-9]+)ms.*|, \\1 ms|" | sort -u)"})
        (( ${#slow} )) && say ! "slow to type-check (over 300 ms, risky for a release build): $(N=4 some $slow)"
    fi

    # Sheets to look at.
    if [[ -z ${QUICK:-} && ${built[preview]:-1} == 0 && ${built[transitions]:-1} == 0 ]]; then
        sheets=$OUT/$k
        rm -rf $sheets; mkdir -p $sheets
        ok=1
        for b in ${(f)"$(awk -F'\t' -v k="$k" '$1=="batch" && $2==k {print $3}' $facts)"}; do
            build/preview cast $sheets/cast-$b.png $b >/dev/null 2>>$sheets/errors.log || ok=0
        done
        build/preview place $sheets/places.png $k >/dev/null 2>>$sheets/errors.log || ok=0
        rides=(${(z)ride_keys[$k]-})
        (( ${#rides} )) && { build/preview rides $sheets/rides.png $rides >/dev/null 2>>$sheets/errors.log || ok=0 }
        two=(${(z)place_keys[$k]-})
        SHEET_ONLY=1 W=640 H=400 build/transitions $sheets/transitions $two[1] ${two[2]:-$two[1]} >/dev/null 2>>$sheets/errors.log || ok=0
        count=$(find $sheets -name '*.png' | wc -l | tr -d ' ')
        [[ -s $sheets/errors.log ]] || rm -f $sheets/errors.log
        if (( ok )); then say ✓ "sheets written to $sheets/ ($count: cast batches, places, rides, transitions)"
        else say ✗ "sheets: some didn't render (see $sheets/errors.log)"; fi
    fi
    print
done

exit $failed
