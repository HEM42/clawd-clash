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

    // Trousers a mid grey-violet, lit down their left side, so the legs under the robe read as legs, not as gaps.
    drawLegs(c, Look(leg: C(0x4A4254)), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 41, 1, 3, C(0x645A70)) } }
    c.oy += p.breathe
    // The tall stiff collar standing up behind his head, curving gently outward from the shoulders to a rounded top.
    c.rect(15, 23, 3, 10, robeD); c.rect(38, 23, 3, 10, robeD)   // its inner face, dark, closing the gap to his head
    c.pattern(12, 21, [
        ".KKK..",
        "KLLK..",
        "KLK...",
        "KLK...",
        "KLK...",
        ".KLK..",
        ".KLK..",
        ".KLK..",
        "..KLK.",
        "..KLK.",
        "...KLK",
        "...KKK",
        "....KK",
    ], ["K": robeD, "L": robeL])
    c.pattern(38, 21, [
        "..KKK.",
        "..KLLK",
        "...KLK",
        "...KLK",
        "...KLK",
        "..KLK.",
        "..KLK.",
        "..KLK.",
        ".KLK..",
        ".KLK..",
        "KLK...",
        "KKK...",
        "KK....",
    ], ["K": robeD, "L": robeL])
    drawBody(c, Look(arm: robe, eye: nil), armLeft: mimeK >= 0 ? 4 : 0, armRight: mimeK >= 0 ? 5 : 0)
    // The bald dome: the head rounded up above Clawd's block, a shine on its crown and two old furrows across it.
    c.rect(20, 24, 16, 1, clawdOrange); c.rect(19, 25, 18, 1, clawdOrange); c.px(36, 25, clawdShade); c.px(35, 24, clawdShade)
    c.rect(22, 24, 3, 1, C(0xF4A68A)); c.rect(21, 25, 2, 1, C(0xF4A68A)); c.px(20, 26, C(0xF4A68A))
    c.rect(26, 25, 5, 1, C(0xB85A3E)); c.rect(27, 26, 3, 1, C(0xC86A4C))
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
        // The barrier: a pale pane of light, brightest where his hands press on it, its face faintly filled.
        for y in 12...44 {
            let near = abs(Double(y) - 29.5) / 17
            let a = max(0.3, 1 - near) * (0.8 + 0.2 * sin(p.t * 8 + Double(y) * 0.7))
            c.px(wall, y, C(0xE4F0FF).alpha(a)); c.px(wall + 1, y, C(0x8CC0FF).alpha(a * 0.55))
            c.px(wall + 2, y, C(0x8CC0FF).alpha(a * 0.2)); c.px(wall + 3, y, C(0x8CC0FF).alpha(a * 0.1))
        }
        // Ripples ringing out across the pane from his hand, curved like a pebble's rings seen edge on.
        for k in 0..<2 {
            let d = frac(p.t * 1.6 + Double(k) * 0.5) * 13 + 2, fade = 0.85 * (1 - d / 15)
            var th = -Double.pi / 2
            while th <= Double.pi / 2 {
                c.px(wall + 1 + Int((cos(th) * d * 0.3).rounded()), 29 + Int((sin(th) * d).rounded()), C(0xFFFFFF, fade))
                th += 0.12
            }
        }
        // The glow where his palm meets it.
        c.rect(wall, 28, 1, 4, white); c.px(wall + 1, 29, C(0xFFFFFF, 0.8)); c.px(wall + 1, 30, C(0xFFFFFF, 0.8))
        return
    }
    if let a = p.melee {
        slayerClaws(c, angle: a, trail: p.trail, sleeve: robe, nail: nail)
    } else {
        // His hand by his side, the long nails hanging.
        c.px(39, 36, nail); c.px(40, 36, nail); c.px(39, 37, nail)
    }
}
