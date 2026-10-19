#!/bin/zsh
# The universes, from their folders: sourced (`source Tools/universes.sh`, from the repo root) by build.sh, every tool's
# build script and the build commands in the tools' headers. It reads every Sources/App/Universes/*/universe.conf,
# checks each against NUMBERS, writes the registry Swift into build/gen/ and sets the source lists the builds use
# instead of a Universes/** glob:
#   UNIVERSE_FACTS   each universe's *Facts.swift and the generated list: all the hook needs to know about them
#   UNIVERSE_APP     the engine files in Universes/ and every registered folder's Swift (not Promo/), with the
#                    generated lists: what the app, the screen saver and the tools compile
#   UNIVERSE_PROMO   every registered folder's Promo/*.swift but its showcase, with the generated list of the
#                    trailers (`Promo/<Prefix>Reel.swift`): RenderPromo only, drawn with its kit
#   UNIVERSE_SHOWCASE  every registered folder's Promo/<Prefix>Showcase.swift, with the generated list of them
#                    (RenderShowcase only: they're drawn with that tool's kit)
# and writes build/gen/universes.tsv (number, key, title, folder, prefix, reel, cask) for release.sh.
# Folders starting with `_` (the template) are skipped unless TEMPLATE=1. Anything that doesn't add up stops the build
# with a plain message.
#
# TEMPLATE=1 is for trying the template (Sources/App/Universes/_Template/), never for a release: its folder is
# registered, number 999 and up are let through, and `-D CLAWD_TEMPLATE` goes at the front of UNIVERSE_FACTS and
# UNIVERSE_APP, so every build that compiles them compiles the template's files too (each is wrapped in
# `#if CLAWD_TEMPLATE`, and is nothing without the flag). Its generated files go to build/gen-template/, so a template
# build next to a normal one never changes what the normal one sees.

_uroot=Sources/App/Universes
_utemplate=0
[[ ${TEMPLATE:-} == 1 ]] && _utemplate=1
_ugen=build/gen
(( _utemplate )) && _ugen=build/gen-template
mkdir -p $_ugen

_ufail() { print -u2 "universes: $*"; return 1 }
# Writes stdin to a generated file, swapping it in whole and only when it changed, so builds running side by side (each
# sourcing this) never read a half-written file.
_uput() { cat > $1.$$ && { cmp -s $1.$$ $1 && rm -f $1.$$ || mv -f $1.$$ $1 } }

typeset -A _unum_key _unum_folder _unum_status
while read -r n k f st; do
    [[ -z $n || $n == \#* ]] && continue
    _unum_key[$n]=$k; _unum_folder[$n]=$f; _unum_status[$n]=$st
done < $_uroot/NUMBERS

UNIVERSE_FACTS=() UNIVERSE_APP=() UNIVERSE_PROMO=() UNIVERSE_SHOWCASE=()
_ushowcases=() _ureels=()
typeset -A _useen_num _useen_key
_urows=()
for conf in $_uroot/*/universe.conf(N); do
    folder=${${conf:h}:t}
    [[ $folder == _* ]] && (( ! _utemplate )) && continue
    typeset -A m=()
    while IFS='=' read -r k v; do
        k=${k//[[:space:]]/}; [[ -z $k || $k == \#* ]] && continue
        v=${v%%\#*}; v=${v#"${v%%[![:space:]]*}"}; v=${v%"${v##*[![:space:]]}"}   # no comment, trimmed
        m[$k]=$v
    done < $conf
    n=${m[number]-}
    # A copy of the template that still has some of it: said plainly here, before it turns into a confusing clash
    # with the template's own names further on. Copying with Tools/new-universe.sh renames all of it.
    if [[ $folder != _* ]]; then
        _uleft=()
        [[ ${m[key]-} == template ]] && _uleft+=("\`key = template\`: give it its own key and number from NUMBERS")
        [[ $n == 999 ]] && _uleft+=("\`number = 999\`: give it its own number from NUMBERS")
        [[ ${m[prefix]-} == Template ]] && _uleft+=("\`prefix = Template\`: give it a prefix of its own")
        [[ ${m[entry]-} == TemplateUniverse ]] && _uleft+=("\`entry = TemplateUniverse\`: name its entry <Prefix>Universe")
        [[ ${m[template]-} == yes ]] && _uleft+=("\`template = yes\` in its universe.conf: take that line out")
        _ufiles=($_uroot/$folder/**/Template*(N:t))
        (( ${#_ufiles} )) && _uleft+=("files named Template… (${_ufiles[1]}${${_ufiles[2]-}:+ and $(( ${#_ufiles} - 1 )) more}): start them with its prefix")
        _uplaces=(${(f)"$(grep -rhoE 'Location\("sample[A-Za-z0-9_]*' $_uroot/$folder 2>/dev/null | sed 's/^Location("//' | sort -u || true)"})
        (( ${#_uplaces} )) && _uleft+=("place keys starting sample… (${_uplaces[1]}): start them with its prefix")
        grep -rlq CLAWD_TEMPLATE $_uroot/$folder 2>/dev/null \
            && _uleft+=("a CLAWD_TEMPLATE line: take out the first and last line of each file that has one")
        if (( ${#_uleft} )); then
            for l in $_uleft; do print -u2 -r -- "universes: $folder/ is a copy of the template and still says $l"; done
            _ufail "Tools/new-universe.sh copies the template with all of that renamed"
            return 1
        fi
    fi
    for f in number key title prefix entry; do [[ -n ${m[$f]-} ]] || { _ufail "$conf has no $f"; return 1 }; done
    # Number 999, key template, anything from 900 up and `template = yes` are the template's alone, and only in a
    # TEMPLATE=1 build.
    if (( ! _utemplate )); then
        (( n < 900 )) || { _ufail "$folder has number $n: 900 and up is kept for the template (TEMPLATE=1 builds only)"; return 1 }
        [[ ${m[key]-} != template && ${m[template]-} != yes ]] \
            || { _ufail "$folder is the template, which only a TEMPLATE=1 build takes"; return 1 }
    fi
    [[ -n ${_unum_key[$n]-} ]] || { _ufail "$folder has number $n, which NUMBERS doesn't list: ask the owner for a number"; return 1 }
    [[ ${_unum_key[$n]-} == ${m[key]-} && ${_unum_folder[$n]-} == $folder ]] \
        || { _ufail "$folder (number $n, key ${m[key]-}) doesn't match NUMBERS (${_unum_key[$n]-}, ${_unum_folder[$n]-})"; return 1 }
    [[ -z ${_useen_num[$n]-} ]] || { _ufail "$folder and ${_useen_num[$n]-} both have number $n"; return 1 }
    [[ -z ${_useen_key[${m[key]-}]-} ]] || { _ufail "$folder and ${_useen_key[${m[key]-}]-} both have key ${m[key]-}"; return 1 }
    _useen_num[$n]=$folder; _useen_key[${m[key]-}]=$folder
    UNIVERSE_FACTS+=($_uroot/$folder/*Facts.swift(N))
    UNIVERSE_APP+=(${(f)"$(find $_uroot/$folder -name '*.swift' -not -path '*/Promo/*' | sort)"})
    UNIVERSE_PROMO+=(${(f)"$(find $_uroot/$folder -path '*/Promo/*' -name '*.swift' -not -name '*Showcase.swift' | sort)"})
    if [[ -f $_uroot/$folder/Promo/${m[prefix]-}Showcase.swift ]]; then
        UNIVERSE_SHOWCASE+=($_uroot/$folder/Promo/${m[prefix]-}Showcase.swift); _ushowcases+=("$n	${m[prefix]-}")
    fi
    if [[ -f $_uroot/$folder/Promo/${m[prefix]-}Reel.swift ]]; then _ureels+=("$n	${m[prefix]-}"); fi
    _urows+=("$n	${m[key]-}	${m[title]-}	$folder	${m[prefix]-}	${m[entry]-}	${m[reel]-}	${m[cask]-}")
done
UNIVERSE_PROMO=(${UNIVERSE_PROMO:#})

# A shipped universe can't quietly disappear: its saved ids would point at nothing.
for n st in ${(kv)_unum_status}; do
    [[ $st == shipped && -z ${_useen_num[$n]-} ]] && { _ufail "${_unum_folder[$n]-} (number $n) is shipped but its folder is missing"; return 1 }
done

_urows=(${(on)_urows})   # by number
{
    print "// Generated by Tools/universes.sh from the universes' folders: don't edit, don't commit."
    print "/// Every universe, from its facts file, in number order."
    print "let registeredUniverses: [UniverseEntry] = ["
    for r in $_urows; do print "    ${${(s:	:)r}[5]}Facts.entry,"; done
    print "]"
} | _uput $_ugen/UniverseList.swift
{
    print "// Generated by Tools/universes.sh from the universes' folders: don't edit, don't commit."
    print "/// Every universe's module."
    print "let registeredModules: [Universe: UniverseModule] = ["
    for r in $_urows; do local -a c=("${(@s:	:)r}"); print "    .${c[2]}: ${c[6]}(),"; done
    print "]"
} | _uput $_ugen/UniverseModules.swift
{
    for r in $_urows; do local -a c=("${(@s:	:)r}"); print -r -- "${c[1]}	${c[2]}	${c[3]}	${c[4]}	${c[5]}	${c[7]}	${c[8]}"; done
} | _uput $_ugen/universes.tsv
{
    print "// Generated by Tools/universes.sh from the universes' folders: don't edit, don't commit."
    print "/// Every universe's showcase (\`Promo/<Prefix>Showcase.swift\`), in number order."
    print "let registeredShowcases: [Showcase] = ["
    for r in ${(on)_ushowcases}; do print "    ${${(s:	:)r}[2]}Showcase(),"; done
    print "]"
} | _uput $_ugen/UniverseShowcases.swift
{
    print "// Generated by Tools/universes.sh from the universes' folders: don't edit, don't commit."
    print "/// Every universe's own trailer (\`Promo/<Prefix>Reel.swift\`), in number order."
    print "let registeredReels: [PromoReel] = ["
    for r in ${(on)_ureels}; do print "    ${${(s:	:)r}[2]}Reel(),"; done
    print "]"
} | _uput $_ugen/UniverseReels.swift

UNIVERSE_FACTS+=($_ugen/UniverseList.swift)
UNIVERSE_SHOWCASE+=($_ugen/UniverseShowcases.swift)
UNIVERSE_PROMO+=($_ugen/UniverseReels.swift)
UNIVERSE_APP=($_uroot/*.swift(N) $UNIVERSE_APP $_ugen/UniverseList.swift $_ugen/UniverseModules.swift)
if (( _utemplate )); then
    UNIVERSE_FACTS=(-D CLAWD_TEMPLATE $UNIVERSE_FACTS)
    UNIVERSE_APP=(-D CLAWD_TEMPLATE $UNIVERSE_APP)
fi
unset _uroot _ugen _utemplate _unum_key _unum_folder _unum_status _useen_num _useen_key _urows _ushowcases _ureels \
    _uleft _ufiles _uplaces
return 0
