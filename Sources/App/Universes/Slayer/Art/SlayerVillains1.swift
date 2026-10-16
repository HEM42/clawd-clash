import Foundation

// Villains: the vampires. Clawd in costume like the rest of the cast; a vampire's game face is a ridged brow, yellow
// eyes and a pair of fangs over Clawd's own orange face.

let slayerVillains1: [SlayerVillain: Persona] = [
    .oldMaster: Persona(name: "The Old Master", weapon: .saber, headTop: 21, signature: 3.4,
                        callout: "Here endeth the lesson.", draw: drawOldMaster),
]

// MARK: - The Old Master

/// The Old Master: the ancient vampire under Sunnydale, in his long black robes with a tall stiff collar, bald, with
/// bat-like pointed ears, a heavy ridged brow, yellow eyes and fangs, and long pale nails he fights with. Signature:
/// trapped in his sunken church, he presses both hands flat against the invisible barrier in front of him, like a
/// mime, and it shimmers where he touches it.
private func drawOldMaster(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x1C1820), robeD = C(0x0E0C12), robeL = C(0x3A3442), nail = C(0xE8E0C8)
    let ridge = C(0x9A4A30), eye = C(0xF2D040)
    let mimeK = p.signature.map { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x2A2430)), step: p.step)
    c.oy += p.breathe
    // The tall collar standing up behind his head.
    c.rect(15, 22, 3, 12, robeD); c.rect(38, 22, 3, 12, robeD); c.rect(16, 21, 2, 1, robeD); c.rect(38, 21, 2, 1, robeD)
    c.rect(16, 23, 1, 10, robeL); c.rect(39, 23, 1, 10, robeL)
    drawBody(c, Look(arm: robe, eye: nil), armLeft: mimeK >= 0 ? 4 : 0, armRight: mimeK >= 0 ? 5 : 0)
    // The robe from the shoulders down, hanging over the legs to the shins: four feet still show below its hem.
    c.rect(18, 34, 20, 4, robe); c.rect(37, 34, 1, 4, robeD); c.rect(22, 34, 1, 4, robeL); c.rect(33, 34, 1, 4, robeL)
    c.rect(17, 38, 22, seatedPose ? 1 : 3, robe); c.rect(17, seatedPose ? 38 : 40, 22, 1, robeD)
    // Pointed ears, the ridged brow, yellow eyes, the bat's nose and the fangs.
    c.pattern(16, 23, ["O.", "OO", "OO"], ["O": clawdOrange]); c.pattern(38, 23, [".O", "OO", "OO"], ["O": clawdOrange])
    c.px(16, 22, ridge); c.px(39, 22, ridge)
    c.pattern(21, 27, ["RRRR......RRRR", ".RR........RR."], ["R": ridge])
    c.rect(22, 29, 2, 2, eye); c.px(23, 30, ink); c.rect(32, 29, 2, 2, eye); c.px(32, 30, ink)
    c.pattern(26, 30, ["R..R", ".RR."], ["R": ridge])
    c.rect(25, 32, 6, 1, C(0x5A2418)); c.px(26, 33, white); c.px(29, 33, white)

    if mimeK >= 0 {
        // Both hands up flat on the barrier, and the barrier shimmering round them.
        c.rect(15, 29, 3, 3, clawdOrange); c.rect(40, 28, 3, 3, clawdOrange)
        for k in 0..<3 { c.px(43, 28 + k, nail) }
        let wall = 44
        for y in 14...44 {
            let near = abs(Double(y) - 29.5) / 16
            let a = max(0.15, 1 - near) * (0.7 + 0.3 * sin(p.t * 8 + Double(y) * 0.7))
            c.px(wall, y, C(0xBFDCFF).alpha(a)); c.px(wall + 1, y, C(0x7FB2FF).alpha(a * 0.45))
        }
        // Ripples spreading up and down the barrier from his hand.
        let ring = Int(p.t * 8) % 6
        for d in [ring, ring + 6] where d < 12 {
            c.px(wall - 1, 29 - d, C(0xFFFFFF, 0.8 - Double(d) * 0.06)); c.px(wall - 1, 30 + d, C(0xFFFFFF, 0.8 - Double(d) * 0.06))
        }
        return
    }
    if let a = p.melee {
        slClaws(c, angle: a, trail: p.trail, sleeve: robe, nail: nail)
    } else {
        // His hand by his side, the long nails hanging.
        c.px(39, 36, nail); c.px(40, 36, nail); c.px(39, 37, nail)
    }
}
