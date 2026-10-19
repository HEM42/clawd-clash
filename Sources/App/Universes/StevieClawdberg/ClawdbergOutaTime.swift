import Foundation

// 88 mph: Stevie Clawdberg's regeneration. When the session of one of Back to the Future's time travellers (Marty,
// Doc Brawn, Jennifer, Einstein the Dog, and Old Biff, who stole the DeLorean himself; `Universe.abductees`) has its
// context compacted, they hit 88 miles per hour: blue sparks crackle over them, a white flash, and they're gone,
// leaving two lines of fire burning on the ground where they went. A beat later three sonic booms bring them back
// where they stood, and OUTATIME (the DeLorean's number plate) types itself out over their head. Same session, same
// face. It runs on the engine's missing-time clock (`SessionRecord.abducted`, `missingTimeLength`).

/// Where a trip is, `k` 0…1 through it: how visible the traveller is, how strong the sparks, the flash and the fire
/// trails are, and the caption typed so far.
struct ClawdbergOutaTime {
    let alpha: Double
    let sparks: Double
    let flash: Double
    let trails: Double
    let caption: String?

    init(k: Double) {
        switch k {
        case ..<0.2:    // the sparks build
            alpha = 1; sparks = k / 0.2; flash = 0; trails = 0
        case ..<0.24:   // the flash, and gone
            alpha = 1 - (k - 0.2) / 0.04; sparks = 1; flash = 1; trails = (k - 0.2) / 0.04
        case ..<0.58:   // the fire burns where they went
            alpha = 0; sparks = 0; flash = 0; trails = 1 - (k - 0.24) / 0.34 * 0.6
        case ..<0.68:   // the booms: three flashes, and back
            let b = (k - 0.58) / 0.1
            alpha = b > 0.66 ? 1 : 0; sparks = 0.6; flash = Int(b * 6) % 2 == 0 ? 0.8 : 0; trails = 0.4 * (1 - b)
        default:        // the sparks die away, the caption stays a moment
            alpha = 1; sparks = max(0, 0.6 - (k - 0.68) / 0.1); flash = 0; trails = 0
        }
        let full = "OUTATIME"
        if k >= 0.68 {
            let n = min(full.count, Int((k - 0.68) / 0.12 * Double(full.count)) + 1)
            caption = String(full.prefix(n))
        } else {
            caption = nil
        }
    }
}

/// Where the traveller stands on `clawdbergDrawOutaTime`'s canvas (its body's middle), the fire trails running ahead of them.
let clawdbergOutaTimeAnchor = 24
/// The width of `clawdbergDrawOutaTime`'s canvas; it's `Sprite.height` tall, its rows lined up with the traveller's sprite.
let clawdbergOutaTimeWidth = 150

/// The 88 mph effects on their own canvas: blue-white sparks crackling round the traveller, the white flash, and the
/// two fire trails burning along the ground ahead of where they stood (facing right; mirror it for a traveller facing
/// left).
func clawdbergDrawOutaTime(_ c: PixelCanvas, _ o: ClawdbergOutaTime, t: Double) {
    let x0 = clawdbergOutaTimeAnchor, feet = 43
    if o.trails > 0 {
        let len = Int(Double(c.w - x0) * min(1, o.trails * 3))
        for (i, y) in [feet - 1, feet + 1].enumerated() {
            for x in 0..<len {
                let f = Double(x) / Double(max(1, len))
                let flick = noise(x * 5 + i * 41 + Int(t * 18)) * 0.35
                let col = noise(x * 3 + i + Int(t * 12)) > 0.6 ? C(0xFFE45A) : C(0xFF6A1A)
                let strength: Double = 0.75 - f * 0.5 + flick
                c.px(x0 - 6 + x, y, col.alpha(o.trails * strength))
                let lick: Double = o.trails * 0.6 * (1 - f)
                if noise(x * 7 + i * 13 + Int(t * 10)) > 0.7 { c.px(x0 - 6 + x, y - 1, C(0xFF9A2A, lick)) }
            }
        }
    }
    if o.sparks > 0 {
        let n = Int(4 + o.sparks * 8)
        for i in 0..<n {
            let seed = i * 9 + Int(t * 16) * 31
            let sx: Double = Double(x0) + (noise(seed) - 0.5) * 34
            let sy: Double = 12 + noise(seed + 1) * 32
            let ex: Double = sx + (noise(seed + 2) - 0.5) * 8
            let ey: Double = sy + (noise(seed + 3) - 0.5) * 8
            c.glowLine(sx, sy, ex, ey, core: C(0xE8F4FF), glow: C(0x5AA8FF), coreR: 0.5, glowR: 1.6, strength: o.sparks)
        }
    }
    if o.flash > 0 {
        c.ellipse(x0, 30, 22, 18, C(0xFFFFFF, 0.55 * o.flash))
        c.ellipse(x0, 30, 12, 12, C(0xFFFFFF, 0.8 * o.flash))
    }
}

extension ClawdbergOutaTime: CompactionLook {
    /// The sparks, the flash and the fire trails, from the traveller's feet back the way it faces.
    func layers(cast: Cast, x: CGFloat, y: CGFloat, lift: CGFloat, scale: CGFloat, facing: CGFloat, t: Double) -> [StageLayer] {
        let fx = PixelCanvas(clawdbergOutaTimeWidth, Sprite.height)
        clawdbergDrawOutaTime(fx, self, t: t)
        guard let img = fx.makeImage() else { return [] }
        let w = CGFloat(fx.w) * scale, h = CGFloat(fx.h) * scale
        let left = facing < 0 ? x - (CGFloat(fx.w - clawdbergOutaTimeAnchor)) * scale : x - CGFloat(clawdbergOutaTimeAnchor) * scale
        return [StageLayer(image: img, rect: CGRect(x: left.rounded(), y: y, width: w, height: h), mirrored: facing < 0)]
    }
}
