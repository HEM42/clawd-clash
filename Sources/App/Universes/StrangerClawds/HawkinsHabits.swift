import Foundation

// Stranger Clawds' habits, the things that make the universe behave like the show rather than just look like it, all
// through the engine's stage quirks (`StageQuirks`, in HawkinsUniverse.swift):
//  - the nosebleed: once a fight she was in is over, Eleven's nose bleeds and she wipes it with the back of her hand,
//    the end of her signature on its own (`afterDuel`, `afterDuelFrom`);
//  - Vecna's clock: while Vecna is on stage, now and then a hero standing still has a ghostly grandfather clock loom up
//    behind them for a moment, its pendulum swinging, and fade away (`prop`, with `jitter` keeping an eye out for him);
//  - the babysitter: now and then Steve turns to the nearest of the Party kids, steps over towards them with his bat
//    on his shoulder and tells them to stay close (`remark`, and `jitter` for the steps).

// MARK: - The nosebleed

/// How far into Eleven's signature (the Eggo, then the nosebleed and the wipe) her after-fight nosebleed starts.
let hawkinsNosebleedFrom = 0.6

// MARK: - The babysitter

/// The kids Steve keeps an eye on.
let hawkinsParty: Set<Cast> = [.hero(HawkinsHero.eleven), .hero(HawkinsHero.mikeWheeler), .hero(HawkinsHero.dustinHenderson),
                               .hero(HawkinsHero.lucasSinclawd), .hero(HawkinsHero.willByers), .hero(HawkinsHero.maxMayfield),
                               .hero(HawkinsHero.ericaSinclair)]

/// What Steve tells them, one a time round.
let hawkinsBabysitterLines = ["Stay close.", "Nobody goes in there.", "Stay where I can see you.", "Curfew's at ten."]

/// Previews: show Steve minding the kids (his bat on his shoulder) whatever the stage is doing.
var hawkinsMindingForced = false

/// When Steve was last minding the kids (the system clock), and which way: his drawing puts his bat on his shoulder
/// while it's recent, and his steps over (`jitter`) go that way.
private var hawkinsMinding: (at: Double, toward: CGFloat, k: Double)?

private let hawkinsBabysitPeriod = 38.0, hawkinsBabysitLength = 7.0

/// Whether Steve has his bat on his shoulder right now, minding the kids.
var hawkinsSteveMinding: Bool {
    if hawkinsMindingForced { return true }
    guard let m = hawkinsMinding else { return false }
    return ProcessInfo.processInfo.systemUptime - m.at < 0.25
}

/// Steve, out of the fight and standing still, with one of the Party about: for seven seconds in every 38 or so he
/// turns to the nearest of them and tells them to stay close.
func hawkinsBabysitter(_ a: OnStage, others: [OnStage], zoom z: CGFloat, t: Double) -> (facing: CGFloat, line: String)? {
    guard a.cast == .hero(HawkinsHero.steveHarringclawd), !a.leaving else { return nil }
    let cycle = t / hawkinsBabysitPeriod + a.phase
    let e = frac(cycle) * hawkinsBabysitPeriod
    guard e < hawkinsBabysitLength else { return nil }
    let kids = others.filter { hawkinsParty.contains($0.cast) && !$0.leaving && abs($0.x - a.x) < 200 * z }
    guard let kid = kids.min(by: { abs($0.x - a.x) < abs($1.x - a.x) }) else { return nil }
    let toward: CGFloat = kid.x > a.x ? 1 : -1
    hawkinsMinding = (ProcessInfo.processInfo.systemUptime, toward, e / hawkinsBabysitLength)
    return (toward, hawkinsBabysitterLines[Int(floor(cycle)) % hawkinsBabysitterLines.count])
}

// MARK: - The stage's jitter: Steve's steps, and keeping an eye out for Vecna

/// Whether Vecna was on stage when the last of this universe's characters was looked at (`hawkinsStageJitter` runs
/// just before `hawkinsVecnaClock` for each of them).
private var hawkinsVecnaAbout = false

/// Steve's few steps over to the kids while he minds them (a step every half second, sprite pixels), and a note of
/// whether Vecna is about, for his clock.
func hawkinsStageJitter(_ a: OnStage, others: [OnStage], place: Location?, t: Double) -> (dx: Int, up: Int, line: String?) {
    let vecna = Cast.villain(HawkinsVillain.vecna)
    hawkinsVecnaAbout = a.cast == vecna || others.contains { $0.cast == vecna && !$0.leaving }
    guard a.cast == .hero(HawkinsHero.steveHarringclawd), !a.walking, !a.leaving, hawkinsSteveMinding,
          let m = hawkinsMinding else { return (0, 0, nil) }
    // Over in the first second and a half, back to his spot in the last one.
    let e = m.k * hawkinsBabysitLength
    let out = min(1, e / 1.5) * min(1, (hawkinsBabysitLength - e) / 1.0)
    let moving = e < 1.5 || e > hawkinsBabysitLength - 1.0
    return (Int((Double(m.toward) * 9 * out).rounded()), moving && frac(t * 2) < 0.5 ? 1 : 0, nil)
}

// MARK: - Vecna's clock

/// Previews: show the clock behind everyone, this far (0…1) through it.
var hawkinsClockForced: Double?

private let hawkinsClockPeriod = 21.0, hawkinsClockLength = 3.6

/// A hero standing still while Vecna is on stage: about one cycle in three (every 21 s, on its own beat) a ghostly
/// grandfather clock looms up behind them, its pendulum swinging and a red glow on its face, and fades away.
func hawkinsVecnaClock(_ a: OnStage, ground y: CGFloat, scale: CGFloat, t: Double) -> StageLayer? {
    guard !a.cast.isDark, a.cast.universe == .hawkins, !a.cast.universe.isHem(a.cast.id), !a.leaving, !a.walking else { return nil }
    let k: Double
    if let forced = hawkinsClockForced { k = forced } else {
        guard hawkinsVecnaAbout else { return nil }
        let lt = t / hawkinsClockPeriod + a.phase + Double(a.cast.index) * 0.37
        let cycle = Int(floor(lt)), e = frac(lt) * hawkinsClockPeriod
        guard e < hawkinsClockLength, noise(cycle * 13 + a.cast.index * 7) < 0.34 else { return nil }
        k = e / hawkinsClockLength
    }
    let c = PixelCanvas(18, Sprite.height)
    hawkinsDrawClock(c, k: k, t: t)
    guard let img = c.makeImage() else { return nil }
    let x = a.x - a.facing * 25 * scale
    return StageLayer(image: img, rect: CGRect(x: (x - 9 * scale).rounded(), y: y, width: 18 * scale, height: CGFloat(c.h) * scale))
}

/// The grandfather clock from Vecna's mind, `k` 0…1 through its moment: a tall dark case with a crown on top, the
/// pale face with its hands at the hour, the pendulum swinging in its window, a red glow on it, faint and see-through
/// throughout, faded in and out. Standing on the sprite's ground row (43).
func hawkinsDrawClock(_ c: PixelCanvas, k: Double, t: Double) {
    let fade = min(1, k / 0.25) * min(1, (1 - k) / 0.3)
    guard fade > 0 else { return }
    let a = 0.5 * fade
    let wood = C(0x3A1E1A, a), woodL = C(0x6A3A2E, a), woodD = C(0x1E0E0E, a), face = C(0xE8D8C4, a), red = C(0xE8343A)
    // The case: a plinth, the long trunk with the pendulum's window, the hood with the face, the crown.
    c.rect(3, 41, 12, 3, wood); c.rect(3, 41, 12, 1, woodL)
    c.rect(4, 22, 10, 19, wood); c.rect(4, 22, 1, 19, woodL); c.rect(13, 22, 1, 19, woodD)
    c.rect(6, 25, 6, 13, woodD)                                  // the window
    c.rect(3, 10, 12, 12, wood); c.rect(3, 10, 1, 12, woodL); c.rect(14, 10, 1, 12, woodD)
    c.rect(5, 6, 8, 4, wood); c.rect(7, 4, 4, 2, wood); c.rect(5, 6, 8, 1, woodL); c.px(8, 3, woodL); c.px(9, 3, woodL)
    // The face, its twelve marks and the two hands, the red glow over it pulsing.
    c.ellipse(9, 15, 4, 4, face)
    for h in 0..<12 {
        let r = Double(h) / 12 * 2 * .pi
        c.px(9 + Int((sin(r) * 3.6).rounded()), 15 - Int((cos(r) * 3.6).rounded()), woodD)
    }
    c.rect(9, 12, 1, 4, woodD); c.rect(9, 15, 3, 1, woodD)
    c.ellipse(9, 15, 6, 6, red.alpha(0.18 * fade * (0.7 + 0.3 * sin(t * 6))))
    // The pendulum: a rod from under the face, its brass bob swinging across the window.
    let swing = sin(t * 2 * .pi / 1.6) * 2.2
    let bob = (x: 9.0 + swing, y: 34.0)
    c.glowLine(9, 25, bob.x, bob.y - 2, core: C(0xB8A060, a), glow: C(0, 0), coreR: 0.4, glowR: 0.5)
    c.ellipse(Int(bob.x.rounded()), Int(bob.y), 2, 2, C(0xD8B850, a))
}
