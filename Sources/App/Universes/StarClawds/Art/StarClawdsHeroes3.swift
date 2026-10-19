import Foundation

// Star Wars heroes: Grogu to Kuiil.

let starWarsHeroes3: [SWHero: Persona] = [
    .grogu: Persona(name: "Grogoo", canSit: false, headTop: 23, signature: 3.2,
                  draw: drawGrogu),
    .babuFrik: Persona(name: "Babu Flick", canSit: false, headTop: 16,
                  draw: drawBabuFrik),
    .mando: Persona(name: "The Mandoclawdrian", weapon: .blaster, muzzle: (58, 32), headTop: 19,
                  soloFire: (1.25, 0.7),
                  draw: drawMando),
    .k2so: Persona(name: "Kay-2-Snark", weapon: .blaster, muzzle: (52, 32), headTop: 14,
                  soloFire: (1.05, 0.85),
                  draw: drawK2so),
    .gonk: Persona(name: "Gonky the Power Box", canSit: false, headTop: 23,
                  draw: drawGonk),
    .cassian: Persona(name: "Cassius Andoor", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  soloFire: (0.95, 0.5),
                  draw: drawCassian),
    .bix: Persona(name: "Bix Caffeine", headTop: 19,
                  draw: drawBix),
    .cobbVanth: Persona(name: "Cobb Vance", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  soloFire: (1.0, 0.15),
                  draw: drawCobbVanth),
    .pitDroid: Persona(name: "Pit Bot", canSit: false, headTop: 16,
                  draw: drawPitDroid),
    .kuiil: Persona(name: "Kwill", weapon: .blaster, canSit: false, muzzle: (50, 18), headTop: 7, callout: "I have spoken.",
                  soloFire: (1.3, 0.35),
                  draw: drawKuiil),
]

// MARK: - Shared

/// Sets the canvas up the way Clawd Wars drew its heroes and says where the parts go:
/// - hit, a hero didn't shake about as a whole, only its gun did (`shake`, in x);
/// - cheering, only the upper body hopped and the feet stayed on the ground (`ground`: the origin for legs, crates and
///   anything else that stays down);
/// - `base`: the origin of the upper body before its breathing bob.
private func heroRig(_ c: PixelCanvas, _ p: Pose) -> (ground: Int, base: Int, shake: Int) {
    var shake = 0
    if p.hit && !p.walking { shake = p.dx; c.ox -= p.dx; c.oy -= p.hop }
    let base = c.oy
    let ground = base - (p.cheering && !p.walking ? cheerHop(p.t) : 0)
    return (ground, base, shake)
}

/// The upper body's bob, on each hero's own rhythm as in Clawd Wars: a step's bob while walking, none while cheering
/// (the hop is already in the origin). While shooting it breathes on the engine's rhythm instead, so the muzzle flash
/// (drawn by the engine at its own bob) stays on the barrel.
private func heroBob(_ p: Pose, _ rate: Double, over: Double = 0.6) -> Int {
    if p.walking { return p.step == 0 ? -1 : 0 }
    if p.cheering { return 0 }
    if p.fire != nil, p.who.weapon == .blaster { return p.breathe }
    return sin(p.t * rate) > over ? -1 : 0
}

/// Where a hero holds its gun relative to its resting place: it kicks back as it fires and bobs up and down with a
/// cheer, but Clawd Wars' heroes never raised it while waiting or checking it (the smoke shows that).
private func heroGunY(_ p: Pose) -> Int { p.cheering ? p.gunY : -p.recoil }

/// A glint of light on the toe of each two-row boot (not when sitting), lifting with the leg as it steps.
private func drawBootShine(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, step >= 0 && i % 2 == step ? 41 : 42, col) }
}

/// A Mandalorian helmet: the T visor.
private func drawMandoHelmet(_ c: PixelCanvas, _ main: Px, _ shine: Px) {
    c.pattern(17, 19, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHhhHHHHHHHHHHHHHH..",
        ".HHhHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHKKKKKKKKKKKKHHHHH",
        "HHHHHKKKKKKKKKKKKHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        ".HHHHHHHHKKKKHHHHHHHH.",
        "..HHHHHHHHHHHHHHHHHH..",
    ], ["H": main, "h": shine, "K": ink])
}

/// The E-11 blaster rifle K-2SO carries.
private func drawE11(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [
        "......SSSL.....",
        ".......K.K.....",
        "KK.KKKKKKKKKKKK",
        "KKKKKKkKkKkKKK.",
        "....KK..MM.....",
        "....KK..MM.....",
    ], ["S": C(0x2C2C33), "L": C(0x7FC8FF), "K": C(0x1E1E24), "k": C(0x5A5A64), "M": C(0x3A3A42)])
}

// MARK: - Grogu

/// Grogu: very small, very green, enormous ears, a beige robe. Lifts a hand to the Force now and then. Signature: a
/// blue cookie (the macarons from Nevarro), both hands, nibbled down bite by bite, crumbs flying.
private func drawGrogu(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let green = C(0x9BBF78), ear = C(0x8DB06A), inner = C(0xC98F7A), robe = C(0xC8AE80), robeDark = C(0xA08A60)
    _ = heroRig(c, p)
    c.oy += heroBob(p, 3)
    for y in 34...43 {
        let k = (y - 34) / 3
        c.rect(20 - k, y, 16 + k * 2, 1, robe)
        c.px(20 - k, y, robeDark); c.px(35 + k, y, robeDark)
    }
    c.rect(21, 34, 14, 1, robeDark)
    // The coarse robe: its collar lit, folds falling in short strokes, the far side in shadow.
    let robeLight = C(0xDCC498), robeFold = C(0xB49A6E)
    c.rect(22, 35, 12, 1, robeLight)
    for (x, y, h) in [(24, 37, 3), (31, 38, 4), (27, 40, 3)] { c.rect(x, y, 1, h, robeFold) }
    for y in 36...43 { c.px(35 + (y - 34) / 3 - 1, y, robeFold) }
    c.rect(19, 43, 18, 1, robeDark)                                 // the hem in shadow
    // The ears: light along the top edge, shaded underneath, the pink inside.
    let earLight = C(0xB0D08E), earDark = C(0x749458)
    c.pattern(8, 24, ["El...........", "EEllE........", ".EEEElllEE...", "..EEeeeeEEEEE", "....ddddddEEE"],
              ["E": ear, "e": inner, "l": earLight, "d": earDark])
    c.pattern(35, 24, ["...........lE", "........EllEE", "...EElllEEEE.", "EEEEEeeeeEE..", "EEEdddddd...."],
              ["E": ear, "e": inner, "l": earLight, "d": earDark])
    // The head: the light on his crown, a few wisps of white hair, wrinkles over the eyes, the far side shaded,
    // and a glint in each eye.
    c.pattern(21, 23, [
        "....GGlllGG....",
        "..GGllGGGGGGG..",
        ".GGlGwGGGwGGGs.",
        "GGGGGGGGGGGGGGs",
        "GGGwwGGGGGwwGGs",
        "GGGKKKGGGGKKKGs",
        "GGGKKWGGGGKKWGs",
        "GGGKKKGGGGKKKGs",
        "GGGGGGGGGGGGGGs",
        ".GGGGGGddGGGGs.",
        "..GGGGGGGGGss..",
    ], ["G": green, "K": ink, "W": white, "d": C(0x7A9A5A), "l": C(0xB4D494), "w": C(0x86A866), "s": C(0x84A462)])
    c.px(25, 22, C(0xEDEDE4)); c.px(28, 22, C(0xEDEDE4)); c.px(31, 22, C(0xD8D8CC))
    if let s = p.signature, s > 0.08, s < 0.92 {
        let k = (s - 0.08) / 0.84
        let bites = min(4, Int(k * 5)), chew = Int(k * 18) % 2
        let y = 33 + chew
        c.rect(27, 32, 3, 1, ink)                                    // mouth open, munching
        if bites < 4 {
            // The cookie: two blue shells and the cream between, a bite out of the top for every bite taken.
            let blue = C(0x3E8CE8), blueDark = C(0x2A62B0)
            c.rect(24, y, 8, 2, blue); c.rect(24, y + 2, 8, 1, C(0xF4ECD8)); c.rect(24, y + 3, 8, 2, blueDark)
            c.px(24, y, C(0, 0)); c.px(31, y + 4, C(0, 0))
            if bites > 0 { c.rect(32 - bites * 2, y, bites * 2, 2 + min(bites, 2), C(0x9BBF78)) }   // bitten: his chin shows
        }
        c.rect(22, y + 1, 3, 3, green); c.rect(31, y + 1, 3, 3, green)   // little hands either side
        for i in 0..<2 {                                             // crumbs falling
            let f = frac(k * 4 + Double(i) * 0.5)
            c.px(25 + i * 5 + Int(f * 2), 35 + Int(f * 6), C(0x6FA8E8).alpha(1 - f))
        }
        return
    }
    // The Force: a little hand up, and a shimmer in front of it.
    let force = !p.walking && sin(t * 0.7) > 0.5
    c.rect(36, force ? 31 : 36, 2, 2, green)
    if force {
        let f = (t * 2).truncatingRemainder(dividingBy: 1)
        c.px(40 + Int(f * 4), 30, C(0xBFE0FF).alpha(1 - f)); c.px(41 + Int(f * 3), 32, C(0xFFFFFF).alpha(1 - f))
    }
}

// MARK: - Babu Frik

/// Babu Frik: a tiny Anzellan droidsmith, mostly head (wrinkled, a white tuft, a bulbous nose), his loupe of lenses
/// out in front of one eye, standing on a crate to reach the work, sparks flying from his tool. Hey hey!
private func drawBabuFrik(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let skin = C(0xE2B49A), wrinkle = C(0xC0907A), nose = C(0xD49480), hair = C(0xF2F2F2)
    let coat = C(0x4A2E22), wood = C(0x8A6238), woodDark = C(0x6A4A2A), brass = C(0x9A7A3A)
    let rig = heroRig(c, p)
    // The crate he stands on.
    c.oy = rig.ground
    c.rect(17, 37, 22, 7, wood)
    c.rect(17, 37, 22, 1, C(0xA87A48))
    c.rect(17, 40, 22, 1, woodDark)
    c.rect(17, 37, 1, 7, woodDark); c.rect(38, 37, 1, 7, woodDark); c.rect(27, 38, 1, 6, woodDark)
    // Its grain in short strokes, a nail in each board's corner, the bottom in shadow.
    c.rect(20, 39, 3, 1, C(0x7A5530)); c.rect(31, 38, 3, 1, C(0x7A5530)); c.rect(22, 42, 3, 1, C(0x7A5530))
    c.rect(32, 42, 2, 1, C(0x7A5530))
    for x in [18, 26, 28, 37] { c.px(x, 38, C(0x4A3420)); c.px(x, 41, C(0x4A3420)) }
    c.rect(18, 43, 20, 1, C(0x5A3E22))
    c.oy = rig.base + heroBob(p, 5)
    // A very small body in a dark coat: lapels, buttons, a tool belt, little boots.
    c.rect(24, 35, 2, 2, coat); c.rect(30, 35, 2, 2, coat)
    c.rect(24, 36, 2, 1, C(0x2A1A12)); c.rect(30, 36, 2, 1, C(0x2A1A12))
    c.rect(23, 31, 11, 5, coat)
    c.rect(23, 31, 11, 1, C(0x6A4434))
    c.px(26, 32, C(0x6A4434)); c.px(30, 32, C(0x6A4434)); c.px(28, 33, C(0x9A7A3A)); c.px(33, 32, C(0x34201A))
    c.rect(33, 31, 1, 5, C(0x34201A))
    c.rect(23, 34, 11, 1, C(0x2A1A12)); c.px(24, 34, brass); c.rect(31, 34, 2, 1, C(0x9AA0AE))
    // The head.
    c.pattern(20, 16, [
        ".....H..H.H.....",
        "....HHHHHHHH....",
        "...HHHHHHHHHH...",
        "..SSSSSSSSSSSS..",
        ".SSSwSSSSSSwSSS.",
        ".SSSSSSSSSSSSSSS",
        "SSSwwSSSSSSwwSSS",
        "GGGGGGGGGGGGGGGG",
        "SSSSKSSSSSSSSSSS",
        "SSSSSSSSSSSSNNNS",
        "SSSSSSSSSSSNNNNS",
        ".SSSSSSSSSSSNNS.",
        ".SSSSMMMMSSSSSS.",
        "..SSSSSSSSSSSS..",
        "....SSSSSSSS....",
    ], ["H": hair, "S": skin, "w": wrinkle, "N": nose, "G": C(0x3A2A22), "K": ink, "M": C(0x8A4A3A)])
    c.rect(24, 18, 7, 1, C(0xC8C8CC)); c.px(24, 17, C(0xC8C8CC))      // the tuft's roots in shadow
    c.rect(22, 19, 3, 1, C(0xF6E2D4)); c.px(21, 20, C(0xF6E2D4))      // the light on his brow
    c.rect(32, 25, 2, 1, C(0xEAB4A2))                                  // and on his nose
    c.rect(21, 23, 3, 1, C(0x5A4636))                                  // the light along his heavy brow
    // The loupe: lenses on an arm out in front of his near eye, the big one wobbling as he peers.
    let peer = sin(t * 2.2) > 0.3 ? 1 : 0
    c.rect(35, 23, 3, 1, brass)
    c.circle(37, 24, 2, brass); c.circle(37, 24, 1, C(0x8FD8FF))
    c.circle(41 + peer, 24, 3, brass); c.circle(41 + peer, 24, 2, C(0xBFEFFF)); c.px(41 + peer, 24, ink)
    c.circle(36, 20, 1, brass)                                             // a spare lens flipped up
    // His hand and tool, and the sparks.
    c.rect(34, 32, 3, 2, skin)
    c.rect(37, 32, 4, 1, C(0x9AA0AE))
    if !p.walking, (t / 1.5).truncatingRemainder(dividingBy: 1) < 0.3 { drawSparks(c, x: 41.5, y: 32.5, t: t, size: 2) }
}

// MARK: - The Mandalorian

/// The Mandalorian: beskar helmet and armour, a brown cape, the long Amban rifle.
private func drawMando(_ c: PixelCanvas, _ p: Pose) {
    let beskar = C(0xC9CDD6), suit = C(0x6A6252)
    let rig = heroRig(c, p)
    c.oy = rig.base + heroBob(p, 3.5)
    // Seated, the cape still reaches the floor: it's clipped at the hem as if he were standing.
    let seat = p.seated ? 4 : 0
    c.oy -= seat; c.baseY += seat
    drawCape(c, t: p.t, speed: 1.2, color: C(0x5A4430), edge: C(0x3E2E20))
    // A fold falling down each side of the cape, swaying with it.
    for y in 34...42 where y + c.oy <= 43 {
        let k = Double(y - 27) / 16
        let hw = 10.5 + k * 4.5
        let sway = sin(p.t * 1.2 + k * 2.2) * k * 1.6
        let l = Int((Sprite.bodyCenterX - hw + sway).rounded())
        let r = Int((Sprite.bodyCenterX + hw + sway).rounded()) - 1
        c.px(l + 2, y, C(0x4A3826)); c.px(r - 2, y, C(0x4A3826))
        if y >= 39 { c.px(l + 1, y, C(0x6E5640)) }
    }
    c.oy += seat; c.baseY -= seat
    let look = Look(body: suit, shade: C(0x4E4838), leg: C(0x5A5446), arm: suit, eye: nil)
    c.oy = rig.ground
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x3A2E22), step: p.step, rows: 2)               // worn brown boots
    drawBootShine(c, step: p.step, C(0x6A5A48))
    c.oy = rig.base + heroBob(p, 3.5)
    drawBody(c, look)
    c.rect(15, 34, 3, 2, C(0x9AA0AC)); c.rect(15, 34, 3, 1, beskar)   // the vambrace
    c.rect(38, 35, 3, 1, C(0x3E3628))                                  // a glove
    drawMandoHelmet(c, beskar, C(0xF2F4F8))
    c.rect(37, 24, 1, 7, C(0xA8AEBA)); c.rect(21, 32, 15, 1, C(0xA8AEBA))   // the helmet's far side and rim in shadow
    c.rect(20, 20, 3, 1, C(0xF2F4F8))                                  // the light along the dome
    // The beskar chest plates, lit along the top, a seam down the middle and a rivet either side.
    c.rect(19, 33, 18, 3, beskar)
    c.rect(19, 33, 18, 1, C(0xE8ECF2))
    c.rect(28, 34, 1, 2, C(0x8E949F)); c.px(21, 34, C(0x8E949F)); c.px(34, 34, C(0x8E949F)); c.rect(36, 34, 1, 2, C(0xA8AEBA))
    // The belt, a buckle and pouches at the hip.
    c.rect(18, 36, 20, 1, C(0x3A2A1C))
    c.rect(27, 36, 2, 1, C(0x9AA0AC)); c.px(27, 36, C(0xE8ECF2))
    c.rect(20, 36, 2, 2, C(0x4A3826)); c.rect(33, 36, 2, 2, C(0x4A3826))
    c.oy += heroGunY(p); c.ox += rig.shake
    c.pattern(38, 31, [
        "...........SS.......",
        "KKKKKKKKKKKKKKKKKKKK",
        "KKWW................",
        "KK..................",
    ], ["K": C(0x2E2A26), "W": C(0x6A4A2A), "S": C(0x8A8F9C)])
}

// MARK: - K-2SO

/// K-2SO: a tall reprogrammed Imperial security droid, black, with a small head and round white eyes.
private func drawK2so(_ c: PixelCanvas, _ p: Pose) {
    let black = C(0x2C2E34)
    let look = Look(body: black, shade: C(0x1E2024), leg: C(0x3A3C44), arm: black, eye: nil)
    let lit = C(0x4E525C), seam = C(0x16171B), glow = C(0x8A929E)
    let rig = heroRig(c, p)
    c.oy = rig.ground
    drawLegs(c, look, step: p.step)
    if !seatedPose {                                                // the long shins lit down one edge, a knee joint
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            c.rect(lx, 36, 1, p.step >= 0 && i % 2 == p.step ? 6 : 7, C(0x50535C)); c.px(lx + 1, 39, C(0x26282E))
        }
    }
    c.oy = rig.base + heroBob(p, 2.5)
    drawBody(c, look)
    // The head: the light along its dome, the far side and underside in shadow, and the eyes lit inside.
    c.pattern(19, 14, [
        "...KKllllKKKKKK...",
        ".KKllKKKKKKKKKKKd.",
        "KKlKKKKKKKKKKKKKKd",
        "KKKKKKKKKKEEEKKEEE",
        "KKKKKKKKKKEeEKKEeE",
        "KKKKKKKKKKKKKKKKKd",
        ".KKKKKKKKKKKKKKKd.",
        "...dddddddddddd...",
        ".......NnNN.......",
        "......NnNNNN......",
        ".....NNnNNNNN.....",
        ".....NNNNNNNd.....",
    ], ["K": black, "E": C(0xDCE4EC), "e": C(0xFFFFFF), "N": C(0x4A4C54), "n": C(0x6A6E78),
        "l": lit, "d": C(0x1E2024)])
    c.rect(18, 26, 20, 4, black)                // over the face: a droid's body, no eyes
    // The shoulders and chest: plates lit along the top, seams between them with rivets, a scratch or two.
    c.rect(18, 26, 19, 1, lit)
    c.rect(18, 30, 19, 1, seam); c.rect(27, 31, 1, 2, seam)
    for (x, y) in [(23, 28), (32, 28), (25, 32), (30, 32)] { c.px(x, y, glow) }
    c.px(34, 27, C(0x3E4048)); c.px(33, 28, C(0x3E4048)); c.px(21, 35, C(0x3E4048))
    c.rect(20, 28, 2, 2, C(0xDCE4EC))           // the Imperial mark on the shoulder
    c.rect(18, 33, 20, 1, C(0x4A4C54))
    c.rect(18, 34, 19, 1, seam)                  // the waist joint under the belt line, with a vent
    c.px(23, 35, C(0x16171B)); c.px(25, 35, C(0x16171B)); c.px(31, 35, C(0x16171B)); c.px(33, 35, C(0x16171B))
    c.px(15, 33, lit); c.px(38, 33, lit)         // the light on his hands
    c.oy += heroGunY(p); c.ox += rig.shake
    drawE11(c, x: 37, y: 30)
}

// MARK: - GNK Power Droid

/// A GNK power droid: a walking battery box on stubby feet. Gonk.
private func drawGonk(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let step = Int(t * (p.walking ? 8 : 2)) % 2
    let body = C(0x8C8A78), dark = C(0x5A5848), light = C(0xAEAC98)
    let rig = heroRig(c, p)
    c.ox += step == 0 ? 0 : 1
    c.oy = rig.ground
    let deep = C(0x44433A), rivet = C(0xC4C2AE), rust = C(0x7A6648)
    for (fx, up) in [(20, step == 0 ? 0 : 1), (32, step == 1 ? 0 : 1)] {   // the stubby feet, lit on the toe
        c.rect(fx, 38 + up, 4, 6 - up, dark)
        c.px(fx, 43, C(0x76745F)); c.rect(fx + 3, 38 + up, 1, 6 - up, deep)
    }
    c.oy = rig.base
    c.rect(17, 23, 22, 16, body)
    c.rect(17, 23, 22, 2, light)
    c.rect(17, 25, 1, 13, C(0x9E9C88))                              // the near edge lit
    c.rect(36, 23, 3, 16, dark)
    c.rect(36, 23, 3, 1, C(0x7A7864)); c.rect(36, 26, 3, 1, deep); c.rect(36, 36, 3, 1, deep)   // the side's ribs
    c.rect(17, 30, 22, 2, dark)
    c.rect(17, 30, 19, 1, deep)
    // Panel seams with rivets at the corners, the two grilles slotted, a scrape and a patch of rust.
    c.rect(26, 25, 1, 5, C(0x76745F)); c.px(26, 33, C(0x76745F)); c.px(26, 37, C(0x76745F))
    for (x, y) in [(18, 26), (34, 26), (18, 37), (34, 37), (27, 33)] { c.px(x, y, rivet) }
    c.rect(20, 34, 6, 3, dark); c.rect(28, 34, 6, 3, dark)
    for x in [21, 23, 25, 29, 31, 33] { c.rect(x, 34, 1, 3, deep) }
    c.rect(20, 37, 6, 1, C(0x9E9C88)); c.rect(28, 37, 6, 1, C(0x9E9C88))
    c.px(30, 27, C(0x6E6C5C)); c.px(31, 28, C(0x6E6C5C)); c.px(32, 28, C(0xA4A28E))
    c.rect(19, 32, 2, 1, rust); c.px(20, 33, rust)
    c.rect(28, 27, 4, 2, deep); c.px(29, 27, C(0x2A2A24))            // a power socket
    c.px(21, 27, Int(t * 2) % 2 == 0 ? C(0xFF4A3A) : C(0x7A2A20))
    c.px(23, 27, C(0x4AD86A))
}

// MARK: - Cassian Andor

/// Cassian Andor: dark hair, stubble, the navy jacket, a blaster pistol. He keeps glancing over his shoulder.
private func drawCassian(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x3A4250), jacketDark = C(0x2A303C), hair = C(0x2A1C14)
    let look = Look(leg: C(0x2E2A26), arm: jacket, eye: nil)
    let rig = heroRig(c, p)
    c.oy = rig.ground
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x4A3424), step: p.step, rows: 2)               // worn brown boots
    c.oy = rig.base + heroBob(p, 4.5)
    drawBody(c, look)
    c.rect(15, 35, 3, 1, jacketDark); c.rect(38, 35, 3, 1, jacketDark)   // the sleeves' cuffs
    c.pattern(18, 22, [
        "..HHHHHlHHHHHHHHH...",
        ".HHHHHHHHHHlHHHHHHH.",
        "HHHHhHHHlHHHHHhHHHHH",
        "HH.H............H.HH",
    ], ["H": hair, "h": C(0x3E2A1E), "l": C(0x4A3426)])
    let glance = !p.walking && sin(p.t * 0.8) > 0.75 ? -1 : 0       // a look back, just in case
    c.rect(22 + glance, 29, 2, 3, ink); c.rect(32 + glance, 29, 2, 3, ink)
    for x in stride(from: 21, through: 34, by: 2) { c.px(x, 32, C(0x8A4A34)) }   // stubble
    // The jacket: the collar turned up, the zip and its pull, pocket flaps, the shoulders catching the light.
    c.rect(18, 33, 20, 5, jacket)
    c.rect(18, 33, 20, 1, C(0x5A4430))                             // the collar
    c.px(19, 33, C(0x6E5640)); c.px(36, 33, C(0x44321F))
    c.rect(19, 34, 3, 1, C(0x56627A)); c.rect(33, 34, 2, 1, C(0x56627A))
    c.rect(27, 34, 1, 4, jacketDark); c.px(27, 35, C(0x9AA0AE))
    c.rect(21, 36, 4, 1, jacketDark); c.rect(30, 36, 4, 1, jacketDark)
    c.px(23, 36, C(0x6A7284)); c.px(32, 36, C(0x6A7284))           // the flaps' press studs
    c.rect(37, 33, 1, 5, jacketDark)
    c.rect(18, 37, 20, 1, jacketDark)                              // the hem's shadow
    c.oy += heroGunY(p); c.ox += rig.shake
    drawPistol(c, x: 40, y: 31)
}

// MARK: - Bix Caleen

/// Bix Caleen: the mechanic of Ferrix, dark curls, a work jacket and a tool belt. Unarmed; now and then she lifts
/// her comm to call in.
private func drawBix(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let coat = C(0x6A5A44), coatDark = C(0x4E4232), hair = C(0x2A1A12)
    let calling = !p.walking && (t / 7).truncatingRemainder(dividingBy: 1) < 0.45
    let look = Look(leg: C(0x3A3430), arm: coat)
    let rig = heroRig(c, p)
    c.oy = rig.ground
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x5A4230), step: p.step, rows: 2)               // scuffed work boots
    c.oy = rig.base + heroBob(p, 4)
    drawBody(c, look, armRight: calling ? 5 : 0)
    c.rect(15, 35, 3, 1, coatDark); c.rect(38, calling ? 30 : 35, 3, 1, coatDark)   // the sleeves rolled at the cuff
    c.pattern(16, 19, [
        "....HH.HHHH.HH.HH.....",
        "..HHHlHHHHHlHHHHlHHH..",
        ".HHHhHHlHHhHHHHhHHlHH.",
        "HHlHHHHHHHHHlHHHHHHHHH",
        "HHhHHHHlHHHHHHHHHhHHHH",
        "HHHH..............HHHH",
        ".HH................HHH",
        ".HH.................HH",
    ], ["H": hair, "h": C(0x4A3020), "l": C(0x5E3E28)])
    // The work jacket, open at the neck over a pale shirt, the front edge and its folds shaded, oil on one pocket.
    c.rect(18, 33, 20, 5, coat)
    c.rect(26, 33, 4, 1, C(0xB8A88A)); c.px(27, 34, C(0xB8A88A)); c.px(28, 34, C(0xB8A88A))
    c.rect(25, 33, 1, 3, coatDark); c.rect(30, 33, 1, 3, coatDark)
    c.rect(19, 33, 2, 1, C(0x84725A)); c.px(21, 34, coatDark); c.px(34, 34, coatDark)
    c.rect(32, 34, 2, 1, C(0x3E3428))
    c.rect(37, 33, 1, 5, coatDark)
    c.rect(18, 36, 20, 1, C(0x3A2A1E))                             // tool belt…
    c.rect(27, 36, 2, 1, C(0xB8A060))
    c.rect(24, 37, 2, 1, C(0x2A1E14)); c.rect(29, 37, 2, 1, C(0x2A1E14))   // pouches
    c.rect(21, 37, 2, 1, C(0x9AA0AE)); c.rect(32, 37, 3, 1, C(0x9AA0AE))
    c.px(21, 37, C(0xD0D4DC)); c.px(34, 37, C(0x6A707C))
    if calling {                                                   // …and the comm, its light blinking
        c.rect(39, 26, 2, 4, C(0x2A2A30))
        c.px(39, 26, Int(t * 4) % 2 == 0 ? C(0x4AD86A) : C(0x1E5A2A))
        let f = (t * 1.5).truncatingRemainder(dividingBy: 1)
        c.px(42 + Int(f * 3), 24 - Int(f * 2), C(0xBFE0FF).alpha(1 - f))
        c.px(43 + Int(f * 3), 26 - Int(f * 2), C(0xBFE0FF).alpha(1 - f))
    }
}

// MARK: - Cobb Vanth

/// Cobb Vanth, marshal of Freetown: sandy hair, a red scarf, a long brown duster with the marshal's badge, a pistol
/// that's always got a little smoke curling off the muzzle.
private func drawCobbVanth(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let coat = C(0x6A4A30), coatDark = C(0x4E3622), hair = C(0x9A7A4E)
    let look = Look(leg: C(0x4A4038), arm: coat)
    let rig = heroRig(c, p)
    c.oy = rig.base + heroBob(p, 3.5)
    c.rect(17, 36, 3, 6, coatDark); c.rect(36, 36, 3, 6, coatDark)  // the duster's tails
    c.rect(17, 36, 1, 6, coat); c.px(17, 41, C(0x3A2818)); c.px(38, 41, C(0x3A2818))   // lit edge, frayed hems
    c.oy = rig.ground
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x5A3E26), step: p.step, rows: 3)               // tall riding boots
    c.oy = rig.base + heroBob(p, 3.5)
    drawBody(c, look)
    c.rect(15, 35, 3, 1, coatDark); c.rect(38, 35, 3, 1, coatDark)   // the duster's cuffs
    c.pattern(18, 22, [
        "...HHHHHHlHHHHHHH...",
        ".HHHHlHHHHHHHlHHHHH.",
        "HHHHhHHHHHlHHHHhHHHH",
        "HH................HH",
    ], ["H": hair, "h": C(0x7A5A36), "l": C(0xC0A070)])
    c.rect(25, 32, 6, 1, C(0x7A5A36))                              // the moustache
    // The scarf, knotted at the front, the light along its top fold.
    c.rect(18, 33, 20, 2, C(0x9A3A2A))
    c.rect(19, 33, 4, 1, C(0xB84A36)); c.rect(32, 33, 3, 1, C(0xB84A36))
    c.rect(26, 33, 3, 2, C(0x7A2A1E)); c.px(27, 33, C(0xB84A36))
    // The duster: its lapel running down, the gun belt under it, the badge with a glint.
    c.rect(18, 35, 20, 3, coat)
    c.px(24, 35, coatDark); c.px(25, 36, coatDark); c.rect(28, 35, 1, 2, coatDark)
    c.rect(37, 35, 1, 3, coatDark)
    c.rect(18, 37, 20, 1, C(0x3A2818)); c.rect(26, 37, 2, 1, C(0xB8BCC4))
    c.px(32, 35, C(0xD8DCE4)); c.px(31, 36, C(0xD8DCE4)); c.px(33, 36, C(0xD8DCE4))   // the badge
    c.px(32, 36, C(0xA8ACB4)); c.px(32, 35, C(0xFFFFFF))
    c.oy += heroGunY(p); c.ox += rig.shake
    drawPistol(c, x: 40, y: 31, body: C(0x3A3A40), trim: C(0xB8BCC4))
    if !p.walking {                                                // smoke curling off the barrel
        for i in 0..<2 {
            let k = (t / 2.2 + Double(i) * 0.5).truncatingRemainder(dividingBy: 1)
            c.px(47 + Int((sin(k * 9) * 1.5).rounded()), 30 - Int(k * 9), C(0xD8D8D8).alpha(0.6 * (1 - k)))
        }
    }
}

// MARK: - Pit Droid

/// A pit droid: a gangly tan droid with a flat dish of a head and a cluster of lenses. Now and then it gets bonked on
/// the nose and folds up into a neat little package, then springs back open.
private func drawPitDroid(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let tan = C(0xC9A46A), tanLight = C(0xE2C48A), dark = C(0x8A6E44), metal = C(0x5A5C64), lens = C(0xE0602A)
    let rig = heroRig(c, p)
    c.oy = rig.ground
    if !p.walking, abs((t / 8).truncatingRemainder(dividingBy: 1) - 0.6) < 0.075 {
        c.rect(22, 37, 12, 6, tan)
        c.rect(22, 37, 12, 1, tanLight)
        c.rect(22, 42, 12, 1, dark)
        c.rect(27, 38, 1, 4, dark); c.px(23, 38, dark); c.px(32, 41, dark)   // the folded panels' seams and rivets
        c.ellipse(28, 36, 7, 1, dark)                              // the head, folded flat on top
        c.px(31, 39, Int(t * 6) % 2 == 0 ? lens : dark)
        return
    }
    let joint = C(0x9A9CA4), worn = C(0xAE8A56)
    for (i, lx) in [23, 31].enumerated() {
        let up = p.step == i ? 1 : 0
        c.rect(lx, 34, 2, 9 - up, dark)
        c.rect(lx, 34, 1, 9 - up, C(0xA8885A))                      // the leg lit down one side
        c.px(lx, 38 - up, joint)                                    // a knee joint
        c.rect(lx - 1, 42 - up, 4, 1, metal); c.px(lx - 1, 42 - up, joint)
    }
    c.oy = rig.base + heroBob(p, 6)
    // The body: lit along the top and down the near edge, a seam with rivets, a vent, scuffs and a red marking.
    c.rect(22, 27, 12, 8, tan)
    c.rect(22, 27, 12, 1, tanLight); c.rect(22, 28, 1, 6, C(0xD6B67C))
    c.rect(22, 34, 12, 1, dark); c.rect(33, 27, 1, 8, dark)
    c.rect(22, 30, 11, 1, worn); c.px(24, 29, dark); c.px(31, 29, dark)
    c.rect(25, 32, 3, 1, dark); c.px(29, 32, C(0xC05A2A)); c.px(30, 32, C(0xC05A2A))
    c.px(31, 28, worn); c.px(32, 29, worn); c.px(24, 33, worn)
    c.rect(19, 28, 3, 1, dark); c.rect(18, 28, 1, 6, dark)          // long arms
    c.px(21, 28, joint); c.px(18, 28, joint)                        // their joints
    if !p.walking && sin(t * 3) > 0.4 {                            // one up, waving
        c.rect(34, 28, 4, 1, dark); c.rect(37, 22, 1, 6, dark)
        c.px(37, 28, joint); c.px(37, 22, metal)
    } else {
        c.rect(34, 28, 3, 1, dark); c.rect(37, 28, 1, 6, dark)
        c.px(37, 28, joint); c.px(37, 33, metal)
    }
    c.rect(27, 20, 2, 7, metal)                                    // the neck…
    c.rect(27, 20, 1, 7, C(0x7A7C84)); c.px(28, 23, C(0x3A3C44))
    c.ellipse(28, 18, 10, 2, tan)                                  // …and the flat head
    c.rect(19, 18, 19, 1, tanLight)
    c.rect(20, 19, 17, 1, C(0xB08C56)); c.rect(21, 20, 15, 1, dark)   // the dish shaded underneath
    c.px(23, 17, worn); c.px(32, 17, worn)                          // scuffs on top
    c.circle(34, 21, 2, metal); c.circle(34, 21, 1, lens); c.px(31, 21, lens)
    c.px(33, 20, C(0x8A8C94)); c.px(34, 21, C(0xFFB070))            // the lens rim lit, a glint in it
}

// MARK: - Kuiil

/// Kuiil, the Ugnaught moisture farmer, riding his blurrg: a squat grey-brown biped with a huge wide-mouthed head.
/// Kuiil has a white beard, goggles on his cap and a long rifle. He has spoken.
private func drawKuiil(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let hide = C(0x8A8070), hideDark = C(0x6A6254), belly = C(0xB0A48A)
    let skin = C(0xD9A07A), beard = C(0xF0EEE6), leather = C(0x6A4A2E)
    // The blurrg has its own, slower gait.
    let step = p.walking ? Int(t * 6) % 2 : -1
    let bob = p.walking ? (step == 0 ? -1 : 0) : heroBob(p, 2, over: 0.7)
    let rig = heroRig(c, p)
    c.oy = rig.ground
    let hideLight = C(0xA49A86), hideDeep = C(0x58513F), leatherDark = C(0x4E3420), leatherLight = C(0x86603C)
    for (i, lx) in [22, 32].enumerated() {                         // the blurrg's legs: lit down the front, a wrinkle
        let up = step == i ? 1 : 0
        c.rect(lx, 35, 5, 8 - up, hideDark)
        c.rect(lx, 35, 1, 7 - up, C(0x7A7262)); c.rect(lx + 4, 35, 1, 7 - up, hideDeep)
        c.rect(lx + 2, 38 - up, 1, 2, hideDeep)
        c.rect(lx - 1, 42 - up, 7, 1, C(0x4A4438))
        c.px(lx - 1, 42 - up, C(0x8A8070)); c.px(lx + 2, 42 - up, C(0x8A8070)); c.px(lx + 5, 42 - up, C(0x8A8070))   // claws
    }
    c.oy = rig.base + bob
    let sway = sin(t * 2.5) * 1.5
    c.glowLine(16, 31, 5, 36 + sway, core: hideDark, glow: C(0, 0), coreR: 1.4, glowR: 1.5)   // tail
    c.glowLine(15, 30.5, 9, 33.5 + sway * 0.5, core: C(0x7A7262), glow: C(0, 0), coreR: 0.5, glowR: 0.6)   // lit along the top
    c.ellipse(28, 31, 13, 6, hide)
    c.ellipse(29, 34, 10, 2, belly)
    // The hide: the light along its back, rough in short strokes, the belly creased, the underside in shadow.
    c.rect(21, 26, 5, 1, hideLight); c.rect(33, 26, 4, 1, hideLight); c.rect(18, 27, 2, 1, hideLight)
    for (x, y) in [(20, 28), (26, 28), (33, 28), (23, 31), (37, 30), (17, 31)] { c.rect(x, y, 2, 1, hideDark) }
    for (x, y) in [(29, 30), (35, 32)] { c.rect(x, y, 1, 2, hideDark) }
    for x in [23, 27, 31, 35] { c.px(x, 34, C(0x988C72)) }
    c.rect(22, 36, 14, 1, C(0x988C72))
    c.ellipse(49, 30, 10, 6, hide)                                 // the big head
    let chomp = !p.walking && sin(t * 1.7) > 0.85 ? 1 : 0
    // The head: lit along the brow, warty in short strokes, the far side shaded.
    c.rect(42, 26, 4, 1, hideLight); c.rect(54, 25, 3, 1, hideLight)
    c.rect(45, 28, 2, 1, hideDark); c.rect(55, 29, 2, 1, hideDark); c.px(48, 29, hideDark)
    c.rect(58, 28, 1, 3, hideDark)
    c.rect(43, 32, 16, 1 + chomp, C(0x3A2A24))                     // the wide mouth
    c.rect(44, 33 + chomp, 14, 2, belly)
    c.rect(44, 34 + chomp, 14, 1, C(0x988C72))                    // the jaw shaded underneath
    c.rect(46, 24, 8, 1, hideDark)
    c.rect(51, 26, 2, 2, ink); c.px(51, 26, C(0x6A6458))          // the eye, a glint in it
    c.rect(40, 35, 2, 3, hideDark)                                  // a stubby arm
    c.px(40, 37, hideDeep)
    // The saddle: lit along the top, stitched, a girth strap down its side with a buckle.
    c.rect(21, 24, 13, 2, leather)
    c.rect(21, 24, 13, 1, leatherLight); for x in stride(from: 22, through: 32, by: 2) { c.px(x, 25, leatherDark) }
    c.rect(25, 26, 1, 7, leatherDark); c.px(25, 30, C(0xA89060))
    // Kuiil up top: the tunic lit down the near edge, folds, a belt with a buckle and a pouch.
    c.rect(23, 15, 10, 9, leather)
    c.rect(23, 17, 1, 7, leatherLight); c.rect(32, 15, 1, 9, leatherDark)
    c.px(26, 19, leatherDark); c.px(29, 18, leatherDark); c.px(27, 22, leatherDark)
    c.rect(23, 21, 10, 1, C(0x3A2818)); c.px(27, 21, C(0xA89060))
    c.rect(24, 22, 2, 2, C(0x5A4028))
    c.rect(23, 9, 10, 7, skin)
    c.rect(23, 10, 1, 3, C(0xE8B892)); c.rect(32, 10, 1, 2, C(0xB88060))   // the face lit on one side, shaded on the other
    // The cap: the light along its crown, a band, the goggles' lenses catching it.
    c.rect(22, 7, 12, 3, C(0x5A4A3A))
    c.rect(23, 7, 6, 1, C(0x7A6A58)); c.rect(22, 9, 12, 1, C(0x463A2C))
    c.rect(25, 8, 3, 2, C(0x9A7A3A)); c.rect(29, 8, 3, 2, C(0x9A7A3A))   // goggles on the cap
    c.px(25, 8, C(0xD8B868)); c.px(29, 8, C(0xD8B868)); c.px(28, 8, C(0x3A2E22))
    c.px(29, 11, ink); c.px(32, 11, ink)
    c.rect(31, 12, 3, 2, C(0xC07A5A))                              // snout
    c.px(33, 12, C(0x9A5A40))
    // The white beard, in strands with a shadow under them.
    c.pattern(22, 12, ["W..........", "WW.......W.", "WWsWWWsWWW.", ".WWWsWWWW..", "..WsWWsW..."], ["W": beard, "s": C(0xC8C4B8)])
    c.oy += heroGunY(p); c.ox += rig.shake
    c.rect(32, 18, 3, 2, skin)                                     // hand…
    c.pattern(30, 17, ["....KKKKKKKKKKKKKKKKKKK", "WWWWKK.................", "WW....................."],
              ["K": C(0x2E2A26), "W": C(0x6A4A2A)])                // …and rifle
    c.rect(36, 17, 14, 1, C(0x4A4440)); c.px(34, 18, C(0x5A5450))    // the barrel's sheen, the trigger guard
    c.px(31, 18, C(0x8A6440)); c.px(30, 19, C(0x8A6440))             // the stock's grain
}
