import Foundation

// Stevie Clawdberg's stage quirks (`StageQuirks`): Captain Clawd and the Croc Clock, T. Wrecks's glass of water.

/// Captain Clawd at the Croc Clock's tick (in Pirate Town, or with the Croc Clock about as an agent): every three
/// seconds a jump and a shiver, sprite pixels; now and then he mutters about it.
func clawdbergClawkFlinch(_ a: OnStage, others: [OnStage], place: Location?, t: Double) -> (dx: Int, up: Int, line: String?) {
    guard a.cast == .villain(ClawdbergVillain.captainClawk), !a.leaving, !a.walking else { return (0, 0, nil) }
    let croc = Cast.villain(ClawdbergVillain.crocClock)
    guard others.contains(where: { $0.cast == croc && !$0.leaving }) || place == .pirateTown else { return (0, 0, nil) }
    let tick = frac(t / 3 + a.phase)
    let line = frac(t / 18 + a.phase) < 0.12 ? "Tick… tock…" : nil
    guard tick < 0.1 else { return (0, 0, line) }
    return (Int(t * 30) % 2 == 0 ? 1 : -1, 2, line)
}

/// A glass of water on the ground in front of T. Wrecks, its surface rippling in rings with each of his footsteps
/// (every half second walking, a heavy thud every two standing still).
func clawdbergWaterGlass(_ a: OnStage, ground y: CGFloat, scale: CGFloat, t: Double) -> StageLayer? {
    guard a.cast == .villain(ClawdbergVillain.tWrecks), !a.leaving else { return nil }
    let x = a.x + a.facing * 34 * scale
    let c = PixelCanvas(11, Sprite.height)
    let beat = frac(t / (a.walking ? 0.5 : 2))
    let glass = C(0xDCEAF2, 0.55), rim = C(0xF4FAFF, 0.9), water = C(0x6AA8D8, 0.6)
    c.rect(3, 36, 5, 8, glass); c.rect(3, 36, 1, 8, rim); c.rect(7, 36, 1, 8, rim); c.rect(3, 43, 5, 1, rim)
    c.rect(4, 38, 3, 5, water)
    // The surface: flat, then rings running out and fading after each step.
    let ring = max(0, 1 - beat * 3)
    c.rect(4, 38, 3, 1, C(0xC8E8FF, 0.6 + 0.4 * ring))
    if ring > 0 {
        let r = Int((beat * 3 * 3).rounded())
        c.px(5 - min(1, r), 37, C(0xFFFFFF, ring)); c.px(5 + min(1, r), 37, C(0xFFFFFF, ring))
        c.px(5, 38, C(0x3A78B8, ring))
    }
    c.addOutline(C(0xFFFFFF, 0.5))
    guard let img = c.makeImage() else { return nil }
    return StageLayer(image: img, rect: CGRect(x: (x - 5.5 * scale).rounded(), y: y, width: 11 * scale, height: CGFloat(c.h) * scale))
}
