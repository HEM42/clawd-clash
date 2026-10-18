import Foundation

// HEM: the one character in every universe, with the same face in each: big buns, wire glasses, a scowl and a
// salt-and-pepper goatee. He's the last hero of every cast (`Universe.hem`), kept out of the regular pools and turning
// up only now and then (`Universe.hemOdds`). Star Clawds: Laya's white robe and a blaster (and a word for her about
// buns, `Overlay`). Marvelous Clawds: a purple-and-gold captain with an H and its shield. Detective Clawds: Harlee's
// jacket, dyed buns and a toy wand. Doctor Clawd: a tweed jacket, a red bow tie, a fez (fezzes are cool) and a sonic
// screwdriver. The Clawd Files: a tan trench coat, an FBI lanyard and a flashlight. Stevie Clawdberg: a fedora, a
// leather jacket and a bullwhip. Clawd of the Rings: Éowyn's Rohan helmet, which comes off to let the buns out, its
// white crest, mail, a green-and-gold cloak, a sword and the sun-horse shield. Clawd Slayer: a Watcher's tweed jacket and tie, and a
// wooden stake. Signature, everywhere: he shakes his fist at you.


/// HEM in universe `u`: his costume is the universe's (`UniverseModule.hem`), the rest of him is the same everywhere.
func hemPersona(_ u: Universe) -> Persona {
    let costume = u.module.hem
    return costume.persona { drawHem($0, $1, costume) }
}

/// HEM's costume in one universe. His face, buns, body and fist-shaking signature are the engine's (this file); the
/// costume is the universe's, drawn at fixed moments of him, in this order: `legs`, then (after the breath) his body
/// in `top`'s colours and `chest` over it, `hat` over his hair, his face, `overFace`, and `prop` in his hand (or
/// `shield` on his off arm while he shakes his fist).
struct HemCostume {
    /// His persona here (weapon, shot or magic, muzzle, pivot, headTop), drawn by `draw`.
    let persona: (_ draw: @escaping (PixelCanvas, Pose) -> Void) -> Persona
    /// Before the breath: trousers, shoes, a robe's hem, a cloak behind him.
    let legs: (PixelCanvas, Pose) -> Void
    /// The top of his costume over his body: its colour and shade, his left arm and his right.
    let top: (main: Px, shade: Px, arm: Px, armRight: Px)
    /// What shows over the top: a shirt, a lanyard, a bow tie, an emblem.
    let chest: (PixelCanvas, Pose) -> Void
    /// What he holds: `out` when he's pointing it at someone, `lift` px up with the pose's `armRaise` (`raisesArm`).
    let prop: (_ c: PixelCanvas, _ p: Pose, _ out: Bool, _ lift: Int) -> Void
    /// His buns dyed (Harlee's pink and blue): each one's colour and shade, left then right; brown at the roots.
    var dyedBuns: (left: (Px, Px), right: (Px, Px))? = nil
    /// Over his hair, under his face: a helmet, a fez, a fedora.
    var hat: ((PixelCanvas, Pose) -> Void)? = nil
    /// Over his face (Éowyn's helmet, Harlee's heart), given where the helmet is if it comes off (`helmetOff`).
    var overFace: ((PixelCanvas, Pose, HemHelmet) -> Void)? = nil
    /// On his off arm while he shakes his fist, `seated` or not (Captain's shield, Éowyn's).
    var shield: ((PixelCanvas) -> Void)? = nil
    /// His right arm rises with the pose's `armRaise` (a sonic screwdriver, a flashlight).
    var raisesArm = false
    /// He never holds it forward: a sword held low (Éowyn).
    var holdsLow = false
    /// A helmet he takes off in his signature, `s` (0…1) through it, before he starts shaking his fist at 0.25.
    var helmetOff: ((_ s: Double?) -> HemHelmet)? = nil
}

/// A helmet coming off in HEM's signature: `rise` px lifted off his head (0: on); `buns`: nil while they're tucked
/// up in it, else how many px low they hang as they tumble out; `pull`: his fist up pulling it off, px above its place.
typealias HemHelmet = (rise: Int, buns: Int?, pull: Int?)

let hemShade = C(0xB85F40)
private let hairMain = C(0x4A2E18), hairDark = C(0x2E1C0E), hairPart = C(0x6E4A2C)
/// His hair colour, for a strand escaping a helmet.
let hemHair = hairMain
private let wire = C(0xD5DAE2), beard = C(0x2A221C), beardGrey = C(0xA8A8A8)
/// Where a tool's tip (the sonic screwdriver, the flashlight's lens) is, held out: the beam leaves from there, raised
/// by the pose's `armRaise`.
let hemSonicTip = (x: 46.0, y: 30.0)

private func drawHem(_ c: PixelCanvas, _ p: Pose, _ costume: HemCostume) {
    // Signature: the fist goes up by his shoulder and shakes at you while he yells. A helmet to take off first
    // (Éowyn's) starts it shaking later.
    let shakeFrom = costume.helmetOff == nil ? 0.08 : 0.25
    let shaking = p.signature.map { $0 > shakeFrom && $0 < 0.92 } ?? false
    let helmet: HemHelmet = costume.helmetOff?(p.signature) ?? (0, nil, nil)
    let fistUp = shaking || helmet.pull != nil
    let frame = Int(p.t * 9) % 2

    costume.legs(c, p)

    c.oy += p.breathe
    // The body, wider than plain Clawd's, and the top of his costume over it.
    let top = costume.top
    c.rect(17, 26, 22, 12, clawdOrange); c.rect(38, 26, 1, 12, hemShade)
    c.rect(17, 34, 22, 4, top.main); c.rect(38, 34, 1, 4, top.shade); c.rect(20, 34, 16, 1, top.shade)   // the turtleneck's roll
    costume.chest(c, p)
    // Arms: hands on hips at rest, the right one forward to fight.
    let forward = !shaking && !costume.holdsLow && (!p.resting || p.melee != nil)
    c.rect(14, 33, 3, 3, top.arm)
    let lift = costume.raisesArm ? p.armRaise : 0
    if !fistUp { c.rect(39, (forward ? 31 : 33) - lift, 3, 3, top.armRight) }
    if !forward { c.px(16, 35, clawdOrange); if !fistUp { c.px(39, 35, clawdOrange) } }

    if costume.helmetOff == nil {
        drawHemHead(c, dyed: costume.dyedBuns)
    } else if helmet.rise > 0 {   // the hair under the helmet, and the buns once they're out of it
        drawHemHead(c, buns: helmet.buns != nil, bunDrop: helmet.buns ?? 0)
    }
    costume.hat?(c, p)
    drawHemFace(c, yelling: shaking && frame == 1)
    costume.overFace?(c, p, helmet)

    if let lift = helmet.pull, !shaking {
        // His arm up, the fist at the helmet's cheek piece pulling it off, then back down by his shoulder until it
        // starts to shake.
        c.rect(39, 32 - lift, 3, 2 + lift, top.armRight)
        c.pattern(39, 27 - lift, [".FFFF.", "FfFfFF", "FFFFFF", "FFFFFs", ".FFss."], ["F": clawdOrange, "f": hemShade, "s": hemShade])
        costume.shield?(c)
        return
    }

    if shaking {
        // The fist by his shoulder, a pixel up and over every other frame, with shake ticks; the anger mark.
        let fx = 39 + frame, fy = 27 - frame
        c.pattern(fx, fy, [".FFFF.", "FfFfFF", "FFFFFF", "FFFFFs", ".FFss."], ["F": clawdOrange, "f": hemShade, "s": hemShade])
        let tick = C(0xFFFFFF, 0.85)
        for (dx, dy) in (frame == 0 ? [(7, 0), (7, 3), (2, -2)] : [(-1, -2), (7, -1), (7, 2)]) {
            c.px(fx + dx, fy + dy, tick); c.px(fx + dx, fy + dy + 1, tick)
        }
        c.pattern(33, 21, [".R.R.", "RR.RR", ".....", "RR.RR", ".R.R."], ["R": C(0xE8323A)])
        costume.shield?(c)
        return
    }

    costume.prop(c, p, forward || p.zap != nil, lift)
}

/// The buns (bigger than Laya's: his are 7 across) and the centre-parted hair; `dyed`, each bun its own colours with
/// brown at the roots (Harlee's pink and blue). `buns: false` leaves them tucked up (in a helmet); `bunDrop` hangs them
/// that many px low, tumbling out of it.
private func drawHemHead(_ c: PixelCanvas, dyed: (left: (Px, Px), right: (Px, Px))? = nil, buns: Bool = true, bunDrop: Int = 0) {
    let bun = ["..BBB..", ".BBbBB.", "BBbBBbB", "BbBBbBB", "BBbBBbB", ".BBbBB.", "..BBB.."]
    if let d = dyed {
        c.pattern(10, 24, bun, ["B": d.left.0, "b": d.left.1]); c.pattern(39, 24, bun, ["B": d.right.0, "b": d.right.1])
        c.rect(16, 26, 1, 3, hairMain); c.rect(39, 26, 1, 3, hairMain)   // brown at the roots
    } else if buns {
        let y = 24 + bunDrop
        c.pattern(10, y, bun, ["B": hairMain, "b": hairDark]); c.pattern(39, y, bun, ["B": hairMain, "b": hairDark])
    }
    c.pattern(17, 21, [
        "....BBBBBBlBBBBBBB....",
        "..BBBBBBBBlBBBBBBBBB..",
        ".BBBBbBBBBlBBBBbBBBBB.",
        "BBBBBBB...l....BBBBBBB",
        "BBB................BBB",
    ], ["B": hairMain, "b": hairDark, "l": hairPart])
}

/// Brows sloping in, wire glasses over squinting eyes, the mustache turned down into the frown and the goatee.
private func drawHemFace(_ c: PixelCanvas, yelling: Bool) {
    for (x, y) in [(20, 26), (21, 26), (22, 27), (23, 27), (24, 27), (35, 26), (34, 26), (33, 27), (32, 27), (31, 27)] { c.px(x, y, beard) }
    c.px(27, 27, hemShade); c.px(28, 27, hemShade)
    for x0 in [20, 30] {
        c.rect(x0, 28, 6, 1, wire); c.rect(x0, 31, 6, 1, wire); c.rect(x0, 28, 1, 4, wire); c.rect(x0 + 5, 28, 1, 4, wire)
        c.rect(x0 + 1, 29, 4, 2, C(0xF2E0D4))
    }
    c.rect(26, 29, 4, 1, wire); c.px(19, 29, wire); c.px(36, 29, wire)
    c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
    c.pattern(22, 32, [
        "..MMMMMMMM..",
        ".MMMMMMMMMM.",
        yelling ? ".MMppppppMM." : ".MM.pppp.MM.",
        yelling ? "..MpppppMM.." : "..MgMMMgMM..",
        "..gMMgMMgM..",
        "...MgMMgM...",
        "....gMMg....",
    ], ["M": beard, "g": beardGrey, "p": yelling ? C(0x5A2418) : C(0x8E4A38)])
}
