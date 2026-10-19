import Foundation

// Every saved id and what it means, for check-universe's "ids" line: one line per character (`id`, its universe's key,
// its name), per place (its key and universe) and per magic user (its look's family and variant). Tools/CheckUniverse
// builds it twice, against this checkout and against a copy of `main`, and compares the two, so it only uses what both
// have: `Universe.allCases`, `Theme.of`, `Location.all(in:)` and the persona's magic. Keep it that way.
//   build/check/ids-head <out.tsv>   (and build/check/ids-main, the same file built against main)

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "/dev/stdout"
var lines: [String] = []
for u in Universe.allCases {
    let theme = Theme.of(u)
    for c in theme.cast {
        let p = theme.persona(c)
        lines.append("id\t\(c.id)\t\(u.key)\t\(p.name)")
        if case .lightning = p.weapon { lines.append("magic\t\(c.id)\t\(u.key)\t\(p.magic.family).\(p.magic.variant)") }
    }
    for l in Location.all(in: u) { lines.append("place\t\(l.rawValue)\t\(u.key)") }
}
try! (lines.joined(separator: "\n") + "\n").write(toFile: out, atomically: true, encoding: .utf8)
