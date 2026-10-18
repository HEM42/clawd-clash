import Foundation

// Solo practice: a Claude that's working with nobody to fight doesn't just fire straight ahead (at whoever happens to be
// standing there, asleep). It works through sets of 7–10 s each, picked at random from what it can do: its kata or a
// flourish, shots and spells into the sky, fiddling with its gun, a portal that sometimes fizzles, stretches, squats,
// hovering cross-legged in meditation, or its own signature move. Stateless (picked from the clock), so the screen
// saver plays the same sets.

enum Drill: CaseIterable {
    case kata          // melee: its practice kata (Characters.swift)
    case flourish      // melee: the weapon swung up, round and back down, again and again
    case checkWeapon   // a gun in the hand: raised, looked over, smoke blown off
    case skyShots      // ranged: shots up into the sky
    case crackle       // magic: flickering between the fingers
    case skyCast       // magic: a stream up into the sky that now and then sputters out
    case portal        // sorcery: a ring of sparks opened in the air, which sometimes fizzles
    case meditate      // Jedi, Sith and mystics: sat cross-legged, floating off the ground
    case squats        // down onto its haunches and back up
    case stretch       // leaning slowly over to one side, then the other
    case hops          // those that can't sit: hopping on the spot
    case signature     // its own move, over and over
    case bespoke       // something only it does (`UniverseModule.drills`)

    /// Feet on the ground: a flyer doesn't take off on a sortie in the middle of it.
    var grounded: Bool {
        switch self { case .meditate, .squats, .stretch, .hops, .bespoke: return true; default: return false }
    }
}

/// The set being played right now, `e` seconds into it.
struct DrillPlay {
    let kind: Drill
    let e: Double
    let length: Double
    /// Which set this is, so each one can play out its own way (which portals fizzle…).
    let seed: Int
}

/// Set while a solo character is drawn, like `idleHabit`.
var soloDrill: DrillPlay?

/// Set while a drill draws its character: changes to the pose (a hammer held up, legs running…), made after the
/// usual ones.
var drillPose: ((inout Pose) -> Void)?

/// Previews: practise this instead of the scheduled set.
var forcedDrill: DrillPlay?

extension Cast {
    /// Who floats cross-legged, as its universe says (`UniverseModule.meditation`): force users in Star Clawds (Jedi
    /// and Sith alike), sorcerers and other mystics elsewhere.
    private var meditates: Bool {
        guard persona.canSit else { return false }
        switch universe.module.meditation.who {
        case .never: return false
        case .casters: return weapon == .lightning
        case .castersAndSabers: return weapon == .lightning || weapon == .saber
        case .heroes(let only): return !isDark && only.contains(index)
        }
    }

    /// What this character practises, with its favourites in more than once.
    var drills: [Drill] {
        let p = persona
        var list: [Drill] = []
        switch weapon {
        case .saber: list += [.kata, .kata, .flourish]
        case .blaster: list += [.skyShots, .skyShots] + (p.handGun ? [.checkWeapon] : [])
        case .lightning: list += p.magic.gadget ? [.crackle] : [.skyCast, .crackle] + (p.magic.jagged || p.magic.notes ? [] : [.portal, .portal])
        case .none: break
        }
        if hasSignature { list += [.signature, .signature] }
        if p.fidgets {
            list += p.canSit ? [.squats, .stretch] : [.hops, .stretch]
        }
        if meditates { list += [.meditate, .meditate] }
        if Self.bespokeDrill(for: self) != nil { list += [.bespoke, .bespoke, .bespoke] }
        return list
    }

    /// The set playing at `t`: back to back while it works, a different one from the last each time.
    func drill(at t: Double) -> DrillPlay? {
        if let forced = forcedDrill { return forced }
        let list = drills
        guard !list.isEmpty else { return nil }
        let lt = t + Double(id) * 4.3
        let period = 7 + 3 * noise(id * 13 + 5)
        let cycle = Int(floor(lt / period))
        func pick(_ n: Int) -> Drill { list[min(list.count - 1, Int(noise(n * 37 + id * 11) * Double(list.count)))] }
        var kind = pick(cycle)
        if list.count > 1, Set(list).count > 1, kind == pick(cycle - 1) {
            kind = list.first { $0 != kind } ?? kind
        }
        return DrillPlay(kind: kind, e: lt - Double(cycle) * period, length: period, seed: cycle &* 7919 &+ id)
    }

    /// Draw it practising `d`. Idle habits it already has (a flourish, its signature) play on a loop as if it were
    /// idle; the rest are drawn here.
    func drawDrill(_ c: PixelCanvas, _ d: DrillPlay, t: Double) {
        soloDrill = d
        defer { soloDrill = nil; idleHabit = nil }
        let ramp = min(1, d.e / 0.8, (d.length - d.e) / 0.8)   // easing in and out of a set
        switch d.kind {
        case .bespoke:
            Self.bespokeDrill(for: self)?(c, self, d, t)
        case .kata, .skyShots, .skyCast, .portal:
            drawPersona(c, self, t: t, mode: .working, walking: false, role: .none)
        case .flourish, .checkWeapon, .crackle, .signature:
            let kind: IdleHabit = d.kind == .flourish ? .flourish : d.kind == .checkWeapon ? .checkWeapon
                : d.kind == .crackle ? .crackle : .signature
            let length = kind == .signature ? signatureLength ?? kind.length : kind.length
            let e = d.e.truncatingRemainder(dividingBy: length + 0.7)
            let play = e < length ? HabitPlay(kind: kind, e: e, length: length) : nil
            idleHabit = play
            drawPersona(c, self, t: t, mode: .idle, walking: false, role: .none)
            if let play { applyHabitTransform(c, play) }
        case .squats:
            let down = d.e > 0.4 && d.e < d.length - 0.4 && frac(d.e / 1.3) > 0.5
            drawPersona(c, self, t: t, mode: .idle, walking: false, role: .none, sitting: down)
        case .hops:
            drawPersona(c, self, t: t, mode: .idle, walking: false, role: .none)
            c.shift(dx: 0, dy: -Int((3 * abs(sin(d.e * .pi / 0.55)) * ramp).rounded()))
        case .meditate:
            let rise = 6 * (0.5 - 0.5 * cos(.pi * max(0, ramp)))
            let lift = Int((rise + (ramp >= 1 ? sin(d.e * 1.8) : 0)).rounded())
            c.baseY = -lift
            drawPersona(c, self, t: t, mode: .idle, walking: false, role: .none, sitting: true)
            if ramp > 0.3 { drawMeditationMotes(c, t: t, lift: lift) }
        case .stretch:
            // Drawn standing, then everything above the hips leant over, forward then back; the feet stay put.
            let body = PixelCanvas(c.w, c.h)
            drawPersona(body, self, t: t, mode: .idle, walking: false, role: .none)
            let hips = 37
            c.paste(body.onlyRows(hips..<c.h))
            let upper = body.onlyRows(0..<hips)
            let lean = sin(d.e * 2 * .pi / 3.2)
            let angle = 11 * (abs(lean) > 0.8 ? (lean > 0 ? 1 : -1) : lean / 0.8) * max(0, ramp)
            let waist = (Sprite.bodyCenterX, Double(hips))
            c.paste(upper.rotated(angle, about: waist, into: c.w, c.h, at: waist))
        }
    }

    /// Bits of rock (Star Wars) or motes of its magic floating round someone meditating, `lift` pixels up.
    private func drawMeditationMotes(_ c: PixelCanvas, t: Double, lift: Int) {
        let (ox, oy, by) = (c.ox, c.oy, c.baseY)
        c.ox = 0; c.oy = 0; c.baseY = 0
        defer { c.ox = ox; c.oy = oy; c.baseY = by }
        let rock = universe.module.meditation.stones
        for k in 0..<3 {
            let a = t * 0.9 + Double(k) * 2.1
            let x = Sprite.bodyCenterX + cos(a) * 17, y = 36 - Double(lift) + sin(a * 1.3) * 4 - Double(k)
            if rock {
                c.rect(Int(x), Int(y), k == 1 ? 2 : 1, 2, C(0x8A7E6E))
                c.px(Int(x), Int(y), C(0xB0A490))
            } else {
                let m = persona.magic
                c.px(Int(x), Int(y), (Int(t * 6) + k) % 3 == 0 ? m.core : m.glow.alpha(0.8))
            }
        }
    }
}

// MARK: - Effects for `drawPersona`

/// A shot fired up and away into the sky from the muzzle, every `period` on clock `t`.
func drawSkyShot(_ c: PixelCanvas, t: Double, period: Double, muzzle: (x: Double, y: Double), style: ShotStyle) {
    let f = frac(t / period)
    guard f < 0.4 else { return }
    let k = f / 0.4
    let from = (muzzle.x + 1, muzzle.y - 1)
    let head = (from.0 + k * 24, from.1 - k * 46)
    drawProjectile(c, style, from: from, head: head, t: t, alpha: k > 0.75 ? (1 - k) / 0.25 : 1)
}

/// Magic sent up into the sky from `hand` in bursts; one burst in three or so sputters out halfway with a pop of sparks.
func drawSkyCast(_ c: PixelCanvas, _ m: Magic, hand: (Double, Double), t: Double, seed: Int) -> Bool {
    let period = 1.7, burst = Int(floor(t / period)), f = frac(t / period)
    guard f < 0.6 else { return false }
    let fizzles = noise(seed &+ burst * 17) < 0.35
    let top = (hand.0 + 16, hand.1 - 30)
    if fizzles && f > 0.25 {
        // Sputtering: a short broken stub, then a few sparks.
        if f < 0.4, noise(Int(t * 30)) > 0.4 {
            drawMagic(c, m, from: hand, to: (hand.0 + 5, hand.1 - 9), t: t)
        }
        let s = (f - 0.25) / 0.35
        for i in 0..<4 {
            let a = -2.4 + Double(i) * 0.6 + noise(burst * 5 + i) * 0.4
            let r = 3 + s * 7
            c.px(Int(hand.0 + 5 + cos(a) * r), Int(hand.1 - 9 + sin(a) * r + s * 4), (i % 2 == 0 ? m.core : m.glow).alpha(1 - s))
        }
        return true
    }
    drawMagic(c, m, from: hand, to: top, t: t)
    return true
}

/// A sling-ring portal opened in the air in front: sparks spinning round a growing ring, held a moment and closed.
/// Some fizzle: the ring wobbles, breaks up and the sparks fall away.
func drawPortal(_ c: PixelCanvas, _ m: Magic, t: Double, seed: Int) -> Bool {
    let period = 3.6, n = Int(floor(t / period)), f = frac(t / period)
    guard f < 0.85 else { return false }
    let fizzles = noise(seed &+ n * 23) < 0.4
    let centre = (59.0, 29.0)
    let grow = min(1, f / 0.3)
    var r = 11 * (0.5 - 0.5 * cos(.pi * grow))
    var scatter = 0.0
    if fizzles, f > 0.45 {
        scatter = (f - 0.45) / 0.4
        r *= 1 + 0.2 * sin(t * 40) * (1 - scatter)
    } else if f > 0.7 {
        r *= 1 - (f - 0.7) / 0.15                  // closing
    }
    guard r > 0.5 else { return true }
    let sparks = 22
    for i in 0..<sparks {
        let a = Double(i) / Double(sparks) * 2 * .pi + t * 5
        var x = centre.0 + cos(a) * r * 0.55, y = centre.1 + sin(a) * r   // seen edge on: taller than it is wide
        if scatter > 0 {
            x += (noise(n * 31 + i) - 0.5) * 10 * scatter
            y += scatter * scatter * 14 + (noise(n * 13 + i) - 0.5) * 4 * scatter
        }
        let lit = noise(Int(t * 25) + i * 3) > 0.25
        guard lit || scatter > 0 else { continue }
        c.px(Int(x.rounded()), Int(y.rounded()), (i % 3 == 0 ? m.core : m.glow).alpha(scatter > 0 ? 1 - scatter : 1))
    }
    if scatter == 0, grow >= 1 {
        // The flicker of somewhere else inside.
        for i in 0..<3 {
            let y = centre.1 - r * 0.6 + noise(Int(t * 8) + i * 7) * r * 1.2
            c.px(Int(centre.0 + (noise(Int(t * 8) + i) - 0.5) * r * 0.5), Int(y), m.glow.alpha(0.45))
        }
    }
    return true
}

// MARK: - Bespoke drills

/// Draws one character's own drill: the canvas, who, the set, and the clock.
typealias BespokeDrill = (PixelCanvas, Cast, DrillPlay, Double) -> Void

/// Drawn standing about as it would idle, with `pose` changes on top.
func standing(_ c: PixelCanvas, _ who: Cast, t: Double, pose: ((inout Pose) -> Void)? = nil) {
    drillPose = pose
    drawPersona(c, who, t: t, mode: .idle, walking: false, role: .none)
    drillPose = nil
}

/// A smooth 0→1 over the first `rise` seconds of a set and back to 0 over its last ones.
func setRamp(_ d: DrillPlay, rise: Double = 0.8) -> Double {
    let k = max(0, min(1, d.e / rise, (d.length - d.e) / rise))
    return 0.5 - 0.5 * cos(k * .pi)
}

extension Cast {
    /// A character's own drills, from its universe (`UniverseModule.drills`): where one says something about it better
    /// than the general ones.
    static func bespokeDrill(for who: Cast) -> BespokeDrill? { who.universe.module.drills[who] }
}



