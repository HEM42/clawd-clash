#!/bin/zsh
# Starts a new universe from the template: copies Sources/App/Universes/_Template/ to Sources/App/Universes/<Folder>/,
# renames its files, types, helpers and place keys to the universe's own, fills in its universe.conf and takes out the
# lines that keep the template out of normal builds. What comes out builds and runs at once, with the template's
# sample characters and place in it, ready to grow into the real thing (clawdify_guide.md has the rest).
#   Tools/new-universe.sh <Folder> <Prefix> <key> "<Title>" <number>
#   Tools/new-universe.sh HarborClawds Harbor harbor "Harbor Clawds" 12
#     Folder  the folder's name, matching its NUMBERS line            (HarborClawds)
#     Prefix  starts every file and type, lower-cased every helper     (Harbor: HarborHero, harborTheme, harborMeadow)
#     key     the universe's key: saved in settings, forever           (harbor)
#     Title   the name people see                                      ("Harbor Clawds")
#     number  its permanent number, from its NUMBERS line              (12)
# The number has to be handed out first: the owner adds `<number> <key> <Folder> reserved` to
# Sources/App/Universes/NUMBERS before work starts.
set -euo pipefail
setopt extendedglob
cd "${0:A:h}/.."

USAGE='usage: Tools/new-universe.sh <Folder> <Prefix> <key> "<Title>" <number>'
(( $# == 5 )) || { print -u2 -- "$USAGE"; exit 2 }
FOLDER=$1 PREFIX=$2 KEY=$3 TITLE=$4 NUMBER=$5
ROOT=Sources/App/Universes
SRC=$ROOT/_Template
DEST=$ROOT/$FOLDER
fail() { print -u2 -- "new-universe: $*"; exit 1 }

# What each argument may be.
[[ $FOLDER =~ '^[A-Z][A-Za-z0-9]*$' ]] || fail "the folder ($FOLDER) is a name like HarborClawds: letters and digits, a capital first"
[[ $PREFIX =~ '^[A-Z][A-Za-z0-9]*$' ]] || fail "the prefix ($PREFIX) is a name like Harbor: letters and digits, a capital first"
[[ $KEY =~ '^[a-z][A-Za-z0-9]*$' ]] || fail "the key ($KEY) is a name like harbor: letters and digits, a small letter first"
[[ -n ${TITLE//[[:space:]]/} ]] || fail "the title is empty"
[[ $TITLE != *[\"\\]* ]] || fail "the title can't have a double quote or a backslash in it"
[[ $NUMBER =~ '^[0-9]+$' ]] || fail "the number ($NUMBER) is a whole number, from NUMBERS"
(( NUMBER < 900 )) || fail "$NUMBER: 900 and up is kept for the template; ask the owner for a number"
[[ $KEY != template && $PREFIX != Template ]] || fail "template is the template's own key and prefix: pick your universe's"
[[ -d $SRC ]] || fail "no template at $SRC"
[[ ! -e $DEST ]] || fail "$DEST/ is there already"

# The number has to be this universe's in NUMBERS, and the key and prefix nobody else's.
line=$(awk -v n=$NUMBER '$1 == n' $ROOT/NUMBERS)
[[ -n $line ]] || fail "NUMBERS has no line for $NUMBER: ask the owner to add \`$NUMBER $KEY $FOLDER reserved\` first"
read -r n k f st <<< "$line"
[[ $k == $KEY && $f == $FOLDER ]] || fail "NUMBERS has $NUMBER as $k in $f/, not $KEY in $FOLDER/"
for conf in $ROOT/*/universe.conf(N); do
    [[ ${conf:h:t} == _* ]] && continue
    grep -qE "^key[[:space:]]*=[[:space:]]*$KEY([[:space:]]|$)" $conf && fail "${conf:h:t}/ already has the key $KEY"
    grep -qE "^prefix[[:space:]]*=[[:space:]]*$PREFIX([[:space:]]|$)" $conf && fail "${conf:h:t}/ already has the prefix $PREFIX"
done

LOWER=${(L)PREFIX[1]}${PREFIX[2,-1]}            # Harbor → harbor, StarClawds → starClawds
SLUG=${${${(L)TITLE}//[^a-z0-9]##/-}##-}; SLUG=${SLUG%%-}   # "Harbor Clawds" → harbor-clawds
SMALL=${${TITLE//[^A-Za-z0-9]##/-}##-}; SMALL=${SMALL%%-}   # "Harbor Clawds" → Harbor-Clawds

print "→ copying the template to $DEST/"
cp -R $SRC $DEST
# Its files: Template… → <Prefix>…
for file in $DEST/**/Template*(N.); do mv $file ${file:h}/$PREFIX${${file:t}#Template}; done

# Its place keys (`sampleMeadow`) become the prefix's (`harborMeadow`), here and wherever they're used.
places=(${(f)"$(grep -rhoE 'Location\("sample[A-Za-z0-9_]+"' $DEST | sed -E 's/^Location\("sample//; s/"$//' | sort -u || true)"})

print "→ renaming it to $PREFIX ($KEY, $NUMBER)"
export KEY PREFIX LOWER TITLE SLUG SMALL NUMBER PLACES="${(j: :)places}"
for file in $DEST/**/*.swift(N.); do
    perl -0pi -e '
        # The lines that keep the template out of normal builds, and its isTemplate (the default, false, is yours).
        s/^#if CLAWD_TEMPLATE\b[^\n]*\n//mg;
        s/^#endif\s*\/\/ CLAWD_TEMPLATE[^\n]*\n?//mg;
        s/\n    \/\/\/ Only the template says true[^\n]*\n(?:    \/\/\/[^\n]*\n)*    var isTemplate: Bool \{ true \}\n/\n/;
        # The universe: its constant, its key, its number and its title.
        s/\bstatic let template = Universe\(number: 999\)/static let $ENV{KEY} = Universe(number: $ENV{NUMBER})/g;
        s/\.template\b/.$ENV{KEY}/g;
        s/"template"/"$ENV{KEY}"/g;
        s/REEL=template\b/REEL=$ENV{KEY}/g;
        s/Sample Universe/$ENV{TITLE}/g;
        s/sample-universe/$ENV{SLUG}/g;
        s/Sample-Universe/$ENV{SMALL}/g;
        # Types and files Template…, helpers template…, place keys sample…
        s/\bTemplate(?=[A-Z])/$ENV{PREFIX}/g;
        s/\btemplate(?=[A-Z])/$ENV{LOWER}/g;
        for my $p (split / /, $ENV{PLACES}) { s/\bsample\Q$p\E\b/$ENV{LOWER}$p/g }
    ' $file
done

cat > $DEST/universe.conf <<CONF
# $TITLE's manifest, read by Tools/universes.sh. The number and key are forever (NUMBERS has the same line).
number = $NUMBER
key    = $KEY
title  = $TITLE
prefix = $PREFIX
entry  = ${PREFIX}Universe
reel   = $KEY
cask   =
detail = 0 characters, 0 places   # redrawn to the detail bar so far, for clawd-plans' status; bump it with each batch
CONF

# The registry has to take it as it is: anything left of the template, or a clash, stops here.
if ! ( source Tools/universes.sh ) >/dev/null; then
    fail "$DEST/ doesn't register (see above): fix it, or delete the folder and try again"
fi
print "✓ $DEST/ is ready: $TITLE, number $NUMBER, key $KEY, prefix $PREFIX"
print "  Next: ./build.sh --no-install to see it in the app, Tools/Preview/build.sh for its sheets,"
print "  and Tools/CheckUniverse/check.sh $FOLDER before you hand it off. clawdify_guide.md has the rest."
