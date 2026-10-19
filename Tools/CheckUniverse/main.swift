import AppKit

// The part of check-universe that has to run the code: a universe's counts, homes, place keys, magic, signatures,
// nemeses, rides and transitions, as the registry sees them. Built through Tools/universes.sh with every registered
// universe, like Tools/Preview, by Tools/CheckUniverse/check.sh, which runs it and prints its lines among its own.
//   build/check/check-universe facts        every universe: its key and number, places, rides and Preview batches (TSV)
//   build/check/check-universe check <key>  the checklist lines for one universe, one per line:
//                                           "✓ …" passes, "✗ …" fails, "! …" worth a look, "· …" a note
// It never touches the merged `places` before it has checked the keys are unique: a key used twice would stop it in
// the merge's assertion instead of being reported.

let args = Array(CommandLine.arguments.dropFirst())
guard let mode = args.first else { print("usage: check-universe facts | check <key>"); exit(2) }

/// "1 place", "3 places".
func count(_ n: Int, _ one: String, _ many: String? = nil) -> String { "\(n) \(n == 1 ? one : many ?? one + "s")" }

/// The first few of `list`, and how many more there are.
func some(_ list: [String], _ n: Int = 6) -> String {
    list.count <= n ? list.joined(separator: ", ") : list.prefix(n).joined(separator: ", ") + " and \(list.count - n) more"
}

/// Every place key, with the universes that declare a drawing for it.
let placeOwners: [String: [Universe]] = Universe.allCases.reduce(into: [:]) { all, u in
    for l in u.module.places.keys { all[l.rawValue, default: []].append(u) }
}
let placesAreUnique = placeOwners.values.allSatisfy { $0.count == 1 }

switch mode {
case "facts":
    for u in Universe.allCases {
        print("universe\t\(u.key)\t\(u.rawValue)\t\(u.title)")
        for l in u.module.theme.places { print("place\t\(u.key)\t\(l.rawValue)") }
        for l in u.module.places.keys where !u.module.theme.places.contains(l) { print("place\t\(u.key)\t\(l.rawValue)") }
        for r in u.module.rides { print("ride\t\(u.key)\t\(r.key)") }
        for b in u.module.preview.batches { print("batch\t\(u.key)\t\(b.name)") }
    }
    exit(0)
case "check":
    break
default:
    print("unknown mode \(mode)"); exit(2)
}

guard args.count > 1, let u = Universe(key: args[1]) else { print("✗ no registered universe with key \(args.count > 1 ? args[1] : "?")"); exit(1) }
let module = u.module, theme = module.theme
let cast = theme.cast

/// Two canvases drawn alike, pixel for pixel.
func same(_ a: PixelCanvas, _ b: PixelCanvas) -> Bool { a.w == b.w && a.h == b.h && a.buf == b.buf }

// MARK: Counts, and HEM last

do {
    var bad: [String] = []
    if theme.villains.count != u.villainCount { bad.append("the Theme has \(theme.villains.count) villains, the facts \(u.villainCount)") }
    if theme.heroes.count != u.heroCount { bad.append("the Theme has \(theme.heroes.count) heroes, the facts \(u.heroCount)") }
    // HEM: the last hero, the enum's `hem` case, drawn by the engine's HEM (`hemPersona`) in a few poses.
    let last = Cast(universe: u, isDark: false, index: theme.heroes.count - 1)
    let engine = hemPersona(u)
    if theme.heroes.last?.name != engine.name { bad.append("the last hero is \(theme.heroes.last?.name ?? "nobody"), not HEM") }
    if let hemCase = module.preview.caseName("hem"), hemCase != last { bad.append("the enum's `hem` isn't the last hero") }
    if let p = theme.heroes.last {
        for (t, sig) in [(0.3, nil), (1.1, 0.5), (2.0, 0.8)] as [(Double, Double?)] {
            var pose = Pose(who: last, t: t, lt: t, mode: .idle, role: .none, walking: false)
            pose.signature = sig
            let a = PixelCanvas(Sprite.width, Sprite.height), b = PixelCanvas(Sprite.width, Sprite.height)
            p.draw(a, pose); engine.draw(b, pose)
            if !same(a, b) { bad.append("the last hero isn't drawn by the engine's HEM"); break }
        }
    }
    let line = "counts: \(theme.villains.count) villains, \(theme.heroes.count) heroes (from the enums); HEM is the last hero"
    print(bad.isEmpty ? "✓ \(line)" : "✗ counts: " + bad.joined(separator: "; "))
}

// MARK: Homes, and every place drawn

do {
    let listed = Set(theme.places)
    var bad: [String] = []
    let homeless = cast.filter { !listed.contains(theme.home($0)) }
    if !homeless.isEmpty { bad.append("homes outside its places: " + some(homeless.map { "\($0.name) (\(theme.home($0).rawValue))" })) }
    let undrawn = theme.places.filter { module.places[$0] == nil }
    if !undrawn.isEmpty { bad.append("listed but never drawn: " + some(undrawn.map(\.rawValue))) }
    let twice = Dictionary(grouping: theme.places, by: { $0 }).filter { $0.value.count > 1 }.keys
    if !twice.isEmpty { bad.append("listed twice: " + some(twice.map(\.rawValue).sorted())) }
    print(bad.isEmpty ? "✓ homes: every character's home is one of its \(count(theme.places.count, "place")), each one drawn"
                      : "✗ homes: " + bad.joined(separator: "; "))
    let unlisted = module.places.keys.filter { !listed.contains($0) }.map(\.rawValue).sorted()
    if !unlisted.isEmpty { print("! places drawn but not in the Theme's list, so never shown: " + some(unlisted)) }
}

// MARK: Place keys

do {
    let mine = module.places.keys.map(\.rawValue)
    let clashes = mine.compactMap { k -> String? in
        let others = placeOwners[k, default: []].filter { $0 != u }
        return others.isEmpty ? nil : "\(k) (also \(others.map(\.key).joined(separator: ", ")))"
    }.sorted()
    let sum = Universe.allCases.reduce(0) { $0 + $1.module.places.count }
    if !clashes.isEmpty {
        print("✗ place keys: used by another universe too: " + some(clashes))
    } else if placesAreUnique, places.count == sum {
        print("✓ place keys: \(mine.count), unique across all \(Universe.allCases.count) universes; the merge holds all \(sum)")
    } else {
        print("✗ place keys: \(mine.count) unique here, but the merge holds \(placeOwners.count) of \(sum) (another universe repeats a key)")
    }
}

// MARK: Magic

do {
    var seen: [String: [Cast]] = [:]
    for v in Universe.allCases {
        let th = v.module.theme
        for c in th.cast {
            let p = th.persona(c)
            if case .lightning = p.weapon { seen["\(p.magic.family).\(p.magic.variant)", default: []].append(c) }
        }
    }
    let users = seen.values.flatMap { $0 }.filter { $0.universe == u }
    let clashes = seen.filter { $0.value.count > 1 && $0.value.contains { $0.universe == u } }
        .map { "\($0.value.map(\.name).joined(separator: " and ")) both draw \($0.key)" }.sorted()
    print(clashes.isEmpty ? "✓ magic: \(count(users.count, "magic user")), each with its own look (family and variant) across every universe"
                          : "✗ magic: " + some(clashes, 4))
}

// MARK: Signatures

do {
    // Drawn at nine moments through it (0.1, 0.2 … 0.9) and at rest, each on three clocks (a yap can come and go with
    // the clock): alike every time means it never reads `p.signature`. A climb (Shellob's thread) is drawn by whoever
    // places the sprite, so it counts as used.
    var unused: [String] = []
    var with = 0
    for c in cast {
        guard let len = c.signatureLength else { continue }
        with += 1
        if c.persona.climb != nil { continue }
        var differs = false
        clocks: for t in [0.3, 0.52, 0.77] {
            let rest = PixelCanvas(Sprite.width, Sprite.height)
            c.draw(rest, t: t, mode: .idle, walking: false, role: .none, asSession: true, habits: false)
            for k in stride(from: 0.1, through: 0.9, by: 0.1) {
                let s = PixelCanvas(Sprite.width, Sprite.height)
                forcedHabit = HabitPlay(kind: .signature, e: len * k, length: len)
                c.draw(s, t: t, mode: .idle, walking: false, role: .none, asSession: true)
                forcedHabit = nil
                if !same(rest, s) { differs = true; break clocks }
            }
        }
        if !differs { unused.append("\(c.name) (signature: \(len))") }
    }
    print(unused.isEmpty ? "✓ signatures: \(with) of \(cast.count) characters have one, and every drawing uses it"
                         : "✗ signatures: drawn the same at rest and through it, so never used: " + some(unused))
}

// MARK: Nemeses

do {
    var bad: [String] = []
    var pairs = Set<String>()
    for (a, b) in theme.nemeses {
        if a.universe != u || b.universe != u { bad.append("\(a.name) and \(b.name) aren't both from here") }
        if a.isDark == b.isDark { bad.append("\(a.name) and \(b.name) are on the same side") }
        if !cast.contains(a) || !cast.contains(b) { bad.append("\(a.id) or \(b.id) isn't in the cast") }
        let key = [a.id, b.id].sorted().map(String.init).joined(separator: "-")
        if !pairs.insert(key).inserted { bad.append("\(a.name) and \(b.name) are paired twice") }
    }
    print(bad.isEmpty ? "✓ nemeses: \(count(theme.nemeses.count, "pair")), each a hero and a villain from here"
                      : "✗ nemeses: " + some(bad, 4))
}

// MARK: Rides

do {
    var bad: [String] = []
    let keys = module.rides.map(\.key)
    let others = Universe.allCases.filter { $0 != u }.flatMap { v in v.module.rides.map { ($0.key, v.key) } }
    for (k, v) in others where keys.contains(k) { bad.append("\(k) is \(v)'s too") }
    let taken = Set(cast.compactMap { theme.ride($0)?.key })
    let unlisted = taken.subtracting(keys).sorted()
    if !unlisted.isEmpty { bad.append("taken but not in `rides` (so not on Preview's sheet): " + some(unlisted)) }
    if bad.isEmpty {
        print(keys.isEmpty ? "· rides: none" : "✓ rides: \(keys.count) (\(keys.joined(separator: ", "))), unique across every universe")
    } else {
        print("✗ rides: " + bad.joined(separator: "; "))
    }
}

// MARK: Transitions

var tripCount = 0
if let set = module.transitions {
    if !placesAreUnique {
        print("! transitions: not run, a place key is used twice (see place keys)")
    } else {
        // A small screen-saver frame, the universe's first two places.
        let W = 320, H = 200, P = 4
        func image(_ l: Location) -> CGImage {
            let cw = W / P, ch = H / P, floor = max(8, ch / 8)
            let still = PixelCanvas(cw, ch); l.drawStatic(still, floorRows: floor)
            let moving = PixelCanvas(cw, ch); l.drawAnimated(moving, floorRows: floor, t: 1.3)
            let ctx = frame()
            ctx.interpolationQuality = .none
            for img in [still.makeImage(), moving.makeImage()].compactMap({ $0 }) { ctx.draw(img, in: CGRect(x: 0, y: 0, width: W, height: H)) }
            return ctx.makeImage()!
        }
        func frame() -> CGContext {
            CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4, space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
        }
        /// The share of pixels that differ noticeably between two frames.
        func differ(_ a: CGContext, _ b: CGImage) -> Double {
            let ref = frame(); ref.draw(b, in: CGRect(x: 0, y: 0, width: W, height: H))
            let pa = a.data!.assumingMemoryBound(to: UInt8.self), pb = ref.data!.assumingMemoryBound(to: UInt8.self)
            var n = 0
            for i in 0..<(W * H) where (0..<3).contains(where: { abs(Int(pa[i * 4 + $0]) - Int(pb[i * 4 + $0])) > 24 }) { n += 1 }
            return Double(n) / Double(W * H)
        }
        let from = theme.places[0], to = theme.places.count > 1 ? theme.places[1] : theme.places[0]
        let old = image(from), new = image(to)
        let every = set.every(from, to)
        tripCount = every.count
        var bad: [String] = [], loose: [String] = []
        for shown in every {
            let d = shown.trip.duration
            if !(d.isFinite && d > 0) { bad.append("\(shown.title) lasts \(d) s") ; continue }
            var last: CGContext?
            for i in 0...10 {
                let ctx = frame()
                shown.trip.draw(ctx, old: old, new: new, k: Double(i) / 10, in: CGRect(x: 0, y: 0, width: W, height: H))
                last = ctx
            }
            // It should end on the new place (a caption or a crew coming back may still be on it).
            if let last, differ(last, new) > 0.02 { loose.append(shown.title) }
        }
        let durations = every.map(\.trip.duration).filter(\.isFinite)
        let range = durations.isEmpty ? "" : String(format: "; durations %.1f–%.1f s", durations.min()!, durations.max()!)
        if !bad.isEmpty {
            print("✗ transitions: " + some(bad))
        } else {
            print("✓ transitions: \(count(every.count, "kind")), each renders start to end\(range)")
        }
        if !loose.isEmpty { print("! transitions that don't end on the new place's picture (fine if they leave something over it): " + some(loose)) }
    }
} else {
    print("· transitions: none of its own, the plain edge and clock wipes")
}

// MARK: Size

do {
    let n = cast.count, heroes = theme.heroes.count, villains = theme.villains.count, places = theme.places.count
    var off: [String] = []
    if !(80...110).contains(n) { off.append("\(n) characters (the guide asks 80–110)") }
    if heroes < 20 { off.append("\(heroes) heroes (the guide's minimum is 20)") }
    if villains < 20 { off.append("\(villains) villains (the guide's minimum is 20)") }
    if !(15...25).contains(places) { off.append("\(places) places (the guide asks about 20)") }
    if module.transitions != nil, !(8...15).contains(tripCount) { off.append("\(tripCount) transitions (the guide asks 8–15)") }
    print(off.isEmpty ? "✓ size: \(n) characters, \(places) places, in the guide's range" : "! size: " + off.joined(separator: "; "))
}
