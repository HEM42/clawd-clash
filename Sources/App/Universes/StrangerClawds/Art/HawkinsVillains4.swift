import Foundation

// Villains: the Upside Down's small fry, who only ever turn up as agents (`agentOnly` in HawkinsFacts.swift): a
// Demodog, Dart (Dustin's pet, before he grew), a Demobat and a flayed rat. Creatures on their own four legs, smaller
// than Clawd, in the Democlawgon's grey-brown hide or the Mind Flayer's black smoke. Eerie, never gory.

let hawkinsVillains4: [HawkinsVillain: Persona] = [
    .demodog: Persona(name: "Demodog", weapon: .saber, canSit: false, pivot: (44, 33), headTop: 26, draw: drawDemodog),
    .dart: Persona(name: "Dart", headTop: 31, draw: drawDart),
    .demobat: Persona(name: "Demobat", motion: .fly, canSit: false, headTop: 20, fidgets: false, draw: drawDemobat),
    .flayedRat: Persona(name: "Flayed rat", canSit: false, headTop: 31, draw: drawFlayedRat),
]

private let skin = C(0x8E7E72), skinD = C(0x5E5048), skinL = C(0xB4A494)
private let flesh = C(0xB83A4A), fleshD = C(0x6A1A26), tooth = C(0xF0E8DA), claw = C(0x2E2824)

// MARK: - Demodog

/// A Demodog: a young Demogorgon on all fours, lean and low like a hound, its grey-brown hide slick and ridged along
/// the spine, the ribs showing in strokes, long thin legs with black claws, a whip of a tail. Its head is a closed bud
/// pointing forward that opens into five petals round a ring of small teeth when it lunges or sniffs the air.
private func drawDemodog(_ c: PixelCanvas, _ p: Pose) {
    let sniff = !p.walking && p.melee == nil && Int(p.lt * 0.6) % 4 == 0
    let open = p.melee != nil ? 1.0 : sniff ? 0.6 : 0
    let by = p.breathe

    // The tail, low behind it, curling up at the tip.
    hawkinsLine(c, 20, 32 + Double(by), 13, 35, skin, 0.9); hawkinsLine(c, 13, 35, 9, 33, skinD, 0.6)
    // Four long, thin legs, the hind pair bent back at the hock, black claws at the toes.
    for (i, lx) in [20, 24, 32, 36].enumerated() {
        let f = hawkinsFoot(p, i)
        c.rect(lx, 36, 2, f - 36 + 1, skin); c.rect(lx + 1, 36, 1, f - 36, skinD)
        if i < 2 { c.px(lx - 1, 38, skin) }
        c.rect(lx + 1, f, 2, 1, claw)
    }

    c.oy += by
    // The lean body: a deep chest tapering to the hips, lit along the spine, the ribs in short strokes, a ridge of
    // knobbles down its back.
    c.pattern(18, 29, [
        "....LLLLLLLLLLLLLLLLL...",
        "..LSSSSSSSSSSSSSSSSSSSS.",
        ".SSSSdSSdSSdSSSSSSSSSSSS",
        "SSSSSSdSSdSSdSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSSSSSSDD",
        ".SSSSSSSSSdSdSdSSSSSSDD.",
        "..DDDDDDDDDDDDDDDDDDDD..",
    ], ["S": skin, "d": skinD, "D": skinD, "L": skinL])
    for x in stride(from: 21, to: 39, by: 3) { c.px(x, 28, skinD) }
    c.px(25, 31, C(0xDCD2C2)); c.px(33, 30, C(0xDCD2C2))

    // The head on its neck, forward of the chest: shut, a bud with the seams of its petals; open, five petals
    // peeling back, pink inside, round the dark mouth and its ring of teeth.
    let hc = (x: 45.5, y: 31.5)
    c.rect(40, 30, 4, 4, skin); c.rect(40, 30, 4, 1, skinL)
    if open < 0.3 {
        c.pattern(43, 28, [".SSSS..", "SLSdSS.", "SLSSdSS", "SSdSSdS", "SSSdSSD", ".SSSSD."],
                  ["S": skin, "L": skinL, "d": skinD, "D": skinD])
    } else {
        let r = 1.5 + open * 1.2
        for i in 0..<5 {
            let a = Double(i) * 72 + sin(p.t * 3 + Double(i)) * 4
            hawkinsBar(c, hc, a, from: r - 0.5, to: r + 1.5 + open * 2.5, skin, r: 1.1)
            hawkinsBar(c, hc, a, from: r, to: r + 1 + open * 2, flesh, r: 0.45)
        }
        for y in -3...3 {
            for x in -3...3 where Double(x * x + y * y) <= r * r {
                c.px(Int(hc.x) + x, Int(hc.y) + y, Double(x * x + y * y) <= (r - 1) * (r - 1) ? fleshD : flesh)
            }
        }
        for i in 0..<8 {
            let a = Double(i) * .pi / 4
            c.px(Int((hc.x + cos(a) * (r - 0.6)).rounded()), Int((hc.y + sin(a) * (r - 0.6)).rounded()), tooth)
        }
    }
}

// MARK: - Dart

/// Dart, the slug Dustin found in his bin and named D'Artagnan: a small, slimy, olive-brown creature low to the
/// ground on four stubby legs, a pale belly, a frilly little head that's still shut tight, and a thin tail. It
/// shuffles about, and now and then its head twitches open a crack and shuts again, with a little chirp.
private func drawDart(_ c: PixelCanvas, _ p: Pose) {
    let body = C(0x6A6440), bodyD = C(0x48422A), bodyL = C(0x8E8858), belly = C(0xC4B88A), slime = C(0xE0E4C0)
    let chirp = !p.walking && Int(p.lt * 1.3) % 5 == 0

    // The thin tail, trailing behind along the ground.
    hawkinsLine(c, 23, 39, 15, 41, body, 0.7); hawkinsLine(c, 15, 41, 11, 40, bodyD, 0.5)
    // Four stubby legs.
    for (i, lx) in [23, 26, 32, 35].enumerated() {
        let f = hawkinsFoot(p, i)
        c.rect(lx, 40, 2, f - 40 + 1, body); c.px(lx + 1, f, bodyD)
    }
    c.oy += p.breathe
    // The slug body, glistening, lit on top with a slick shine, its pale belly underneath.
    c.pattern(21, 33, [
        "....LLLLLLLLL.....",
        "..LSSSSSSlSSSSS...",
        ".SSSSdSSSSSdSSSSS.",
        "SSSSSSSSSSSSSSSSSS",
        "SSBBBBBBBBBBBBBSSD",
        ".DDBBBBBBBBBBBDDD.",
        "...DDDDDDDDDDDD...",
    ], ["S": body, "d": bodyD, "D": bodyD, "L": bodyL, "l": slime, "B": belly])
    c.px(26, 34, slime); c.px(33, 35, slime)
    // The little head at the front, shut tight in folded frills; a crack of pink as it chirps.
    c.pattern(38, 32, [".SSS.", "SLSdS", "SSdSS", "SdSSS", ".SSD."], ["S": body, "L": bodyL, "d": bodyD, "D": bodyD])
    if chirp {
        c.rect(40, 33, 2, 3, flesh); c.px(40, 34, fleshD); c.px(42, 33, body); c.px(42, 35, body)
        if Int(p.lt * 8) % 2 == 0 { c.px(44, 31, C(0xF4F0E0, 0.5)); c.px(45, 30, C(0xF4F0E0, 0.3)) }
    }
}

// MARK: - Demobat

/// A Demobat: a bat-like thing from the Upside Down, its leathery wings dark grey with red-black veins, a short body,
/// a long whip of a tail with a barb on the end, four little clawed feet tucked under it, and a petal mouth at the
/// front that opens in a shriek. It flaps as it flies, and hangs in the air, wings beating slowly, when it stops.
private func drawDemobat(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x3A3236), hideD = C(0x221C20), hideL = C(0x5A4E52), vein = C(0x5E1820), mouth = C(0xB83A4A)
    let fast = p.flying || p.walking
    let flap = sin(p.t * (fast ? 14 : 6))
    let bob = Int((sin(p.t * 3) * 1.5).rounded())
    c.oy += bob - (p.flying ? 0 : 6)
    let up = Int((flap * 5).rounded())

    // The tail, a long whip curling behind and down, the barb at its tip.
    hawkinsLine(c, 24, 29, 16, 32, hide, 0.7); hawkinsLine(c, 16, 32, 11, 30, hide, 0.5)
    c.pattern(8, 28, [".K", "KK", ".K"], ["K": hideD])
    // The four little feet tucked under it, claws hooked.
    for x in [26, 28, 32, 34] { c.rect(x, 30, 2, 2, hideD); c.px(x + 1, 32, claw) }

    // The wings: from the shoulders out and up (or down) with each beat, the leather in strokes between their bones,
    // the veins in red-black; the near wing over the body, the far one behind.
    for side in [-1.0, 1.0] {
        let sx = 30.0 + side * 2, sy = 27.0
        let tip = (x: sx + side * 15, y: sy - Double(up) - 3)
        let mid = (x: sx + side * 8, y: sy - Double(up) * 0.6 - 1)
        for i in 0..<5 {
            let f = Double(i) / 4
            let ex = tip.x + (sx + side * 6 - tip.x) * f, ey = tip.y + (sy + 5 - tip.y) * f
            hawkinsLine(c, mid.x, mid.y, ex, ey, i % 2 == 0 ? hide : hideD, 1.2)
        }
        hawkinsLine(c, sx, sy, mid.x, mid.y, hideL, 0.6); hawkinsLine(c, mid.x, mid.y, tip.x, tip.y, hideL, 0.5)
        hawkinsLine(c, mid.x, mid.y + 1, mid.x + side * 3, mid.y + 3, vein, 0.35)
    }
    // The short body, lit along the top, and the head with its petal mouth.
    c.pattern(24, 25, [".LLLLLLLLL..", "SSSSSdSSSSSS", "SSdSSSSSdSSS", "SSSSSSSSSSSD", ".DDDDDDDDDD."],
              ["S": hide, "d": hideD, "D": hideD, "L": hideL])
    let shriek = !fast && Int(p.lt * 0.8) % 3 == 0
    c.pattern(36, 24, shriek ? ["S.S.", ".SmS", "SmmS", ".SmS", "S.S."] : [".SS.", "SSLS", "SSSS", "SSdS", ".SS."],
              ["S": hide, "L": hideL, "d": hideD, "m": mouth])
}

// MARK: - The flayed rat

/// A flayed rat, one of the rats the Mind Flayer takes over: a scruffy grey-brown rat, low and hunched, its fur in
/// strokes, dark threads of the Mind Flayer's smoke running through it, its eyes glowing red, a long bare tail. It
/// creeps along, then stops dead and twitches its head round, listening for its master.
private func drawFlayedRat(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x6E6258), furD = C(0x4C4238), furL = C(0x8E8274), pink = C(0xC48A8E), smoke = C(0x1A161E)
    let twitch = !p.walking && Int(p.lt * 1.1) % 4 == 0 ? (Int(p.lt * 10) % 2 == 0 ? -1 : 1) : 0

    // The long bare tail, trailing behind along the ground.
    hawkinsLine(c, 23, 39, 15, 41.5, pink, 0.6); hawkinsLine(c, 15, 41.5, 9, 40.5, C(0xA06A70), 0.45)
    // Four short legs, pink little feet.
    for (i, lx) in [24, 27, 32, 35].enumerated() {
        let f = hawkinsFoot(p, i)
        c.rect(lx, 40, 2, f - 40 + 1, furD); c.px(lx + 1, f, pink)
    }
    c.oy += p.breathe
    // The hunched body, its fur in strokes lit along the back, dark threads of smoke through it.
    c.pattern(22, 33, [
        "....LLLLLLLL.....",
        "..LFFlFFlFFFFF...",
        ".FFfFFfFFfFFfFF..",
        "FFFFfFFFFfFFFfFF.",
        "FFfFFFFfFFFFFFFFF",
        ".DDDDDDDDDDDDDDD.",
    ], ["F": fur, "f": furD, "D": furD, "L": furL, "l": furL])
    c.pattern(25, 34, ["k...k....", ".k...kk..", "..k....k."], ["k": smoke])
    // The head, low and forward with its pointed snout, round ears, whiskers, and the red glowing eye.
    c.pattern(37, 32 + twitch, [
        ".EE.....",
        "EpE.....",
        "FFFFF...",
        "FFrFFFF.",
        "FFFFFFFP",
        ".fFFf...",
    ], ["E": furD, "p": pink, "F": fur, "f": furD, "r": C(0xFF3A3A), "P": pink])
    c.px(39, 34 + twitch, C(0xB01A24, 0.5))
    c.rect(43, 33 + twitch, 3, 1, C(0xC8C0B8)); c.rect(43, 37 + twitch, 3, 1, C(0xC8C0B8))
}
