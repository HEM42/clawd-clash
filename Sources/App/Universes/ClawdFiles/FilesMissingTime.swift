import Foundation

// Missing time: The Clawd Files' regeneration. When the session of one of the seven FBI agents (`Universe.abductees`)
// has its context compacted, the agent is abducted: a beam of light comes down, they rise up out of it and out of
// sight, nothing for a beat, then they're set back down where they stood, and MISSING TIME types itself out over
// their head. Same session, same face, some time gone.

/// Where an abduction is, `k` 0…1 through it: how high the agent is lifted (sprite pixels), how visible they are,
/// how strong the beam is, and the caption typed so far.
struct MissingTime {
    let lift: Double
    let alpha: Double
    let beam: Double
    let caption: String?

    init(k: Double) {
        func ease(_ x: Double) -> Double { 0.5 - 0.5 * cos(max(0, min(1, x)) * .pi) }
        switch k {
        case ..<0.12:   // the beam comes down
            lift = 0; alpha = 1; beam = ease(k / 0.12)
        case ..<0.38:   // up they go, fading into the light
            let e = ease((k - 0.12) / 0.26)
            lift = 70 * e; alpha = 1 - e; beam = 1
        case ..<0.5:    // gone
            lift = 70; alpha = 0; beam = 1
        case ..<0.72:   // set back down
            let e = ease((k - 0.5) / 0.22)
            lift = 70 * (1 - e); alpha = e; beam = 1
        default:        // the beam goes, the caption stays a moment
            lift = 0; alpha = 1; beam = max(0, 1 - (k - 0.72) / 0.12)
        }
        let full = "MISSING TIME"
        if k >= 0.72 {
            let n = min(full.count, Int((k - 0.72) / 0.12 * Double(full.count)) + 1)
            caption = String(full.prefix(n))
        } else {
            caption = nil
        }
    }
}

/// The abduction beam on its own canvas, `w`×`h` pixels: a pale green column, brighter at its heart, widening a
/// little towards the ground, with motes rising in it. `strength` 0…1.
func drawAbductionBeam(_ c: PixelCanvas, strength: Double, t: Double) {
    guard strength > 0 else { return }
    let cx: Int = c.w / 2
    let width = Double(c.w), rows = Double(max(1, c.h - 1))
    let outer: Px = C(0xC8FFE0, 0.22 * strength), inner: Px = C(0xF0FFF6, 0.22 * strength)
    for y in 0..<c.h {
        let k: Double = Double(y) / rows
        let half: Int = Int(width * (0.3 + 0.2 * k))
        let core: Int = half / 3
        c.rect(cx - half, y, half * 2, 1, outer)
        c.rect(cx - core, y, max(1, core * 2), 1, inner)
    }
    for i in 0..<7 {
        let f: Double = frac(t * 0.35 + Double(i) / 7)
        let dx: Int = Int((noise(i * 19 + 3) - 0.5) * width * 0.6)
        let dy: Int = Int(f * rows)
        c.px(cx + dx, c.h - 1 - dy, C(0xF0FFF6, strength * (1 - f) * 0.8))
    }
}

extension MissingTime: CompactionLook {
    /// The beam of light, behind the agent.
    func layers(cast: Cast, x: CGFloat, y: CGFloat, lift: CGFloat, scale: CGFloat, facing: CGFloat, t: Double) -> [StageLayer] {
        let beam = PixelCanvas(24, Sprite.height + 90)
        drawAbductionBeam(beam, strength: self.beam, t: t)
        guard let img = beam.makeImage() else { return [] }
        let w = CGFloat(beam.w) * scale, h = CGFloat(beam.h) * scale
        return [StageLayer(image: img, rect: CGRect(x: (x - w / 2).rounded(), y: y, width: w, height: h))]
    }
}
