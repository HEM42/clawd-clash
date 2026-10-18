import Foundation

// Tabula Rasa: Clawd Slayer's regeneration. When the session of one of the eight from the episode "Tabula Rasa"
// (Buffy, Willow, Xander, Giles, Anya, Tara, Spyke and Dawn; `Universe.abductees`) has its context compacted, Willow's
// forgetting spell goes off, since a compaction is a session forgetting what it knew. The crystal at their feet glows
// and puffs pale pink smoke, a big "?" pops up over their head and they say who they think they are ("JOAN?" for
// Buffy, the name she picks; "RANDY?" for Spyke, off the label in his coat; "ALEX?" for Xander; "WHO AM I?" for the
// rest). Then the crystal cracks underfoot, as in the episode, and it all comes back: a short shimmer and the caption
// clears. Same session, same face throughout. It runs on The Clawd Files' missing-time clock (`SessionRecord.abducted`,
// `missingTimeLength`).

/// Where the spell is, `k` 0…1 through it: how bright the crystal glows, whether it has cracked (and the burst of
/// it), how much smoke there is, how far up the "?" has popped, the remembering shimmer, and the caption typed so far.
struct SlayerTabulaRasa {
    let glow: Double
    let cracked: Bool
    let crack: Double
    let crystal: Double
    let smoke: Double
    let mark: Double
    let shimmer: Double
    let caption: String?
    /// The middle column of the forgetter's head, measured off their sprite, where the "?" goes.
    let headX: Int

    init(k: Double, cast: Cast) {
        headX = Self.headMiddle(cast)
        func ramp(_ x: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (x - a) / (b - a))) }
        // The crystal glows up, pulses through the spell and goes dark when it cracks; the broken bits fade at the end.
        glow = k < 0.7 ? ramp(k, 0, 0.1) : 0
        cracked = k >= 0.7
        crack = k >= 0.7 ? 1 - ramp(k, 0.7, 0.76) : 0
        crystal = 1 - ramp(k, 0.86, 0.96)
        // The smoke billows from just after the glow, then thins out while they stand there not knowing who they are.
        smoke = ramp(k, 0.06, 0.16) * (1 - ramp(k, 0.4, 0.6))
        // The "?" pops up once the smoke has them, and goes when they remember.
        mark = ramp(k, 0.18, 0.23) * (1 - ramp(k, 0.71, 0.75))
        shimmer = k >= 0.7 ? 1 - ramp(k, 0.74, 0.92) : 0
        let full: String
        switch (cast.universe, cast.isDark, cast.index) {
        case (.slayer, false, SlayerHero.buffyClawmers.rawValue): full = "JOAN?"
        case (.slayer, false, SlayerHero.spyke.rawValue): full = "RANDY?"
        case (.slayer, false, SlayerHero.xanderHarrows.rawValue): full = "ALEX?"
        default: full = "WHO AM I?"
        }
        if k >= 0.24 && k < 0.74 {
            let n = min(full.count, Int((k - 0.24) / 0.08 * Double(full.count)) + 1)
            caption = String(full.prefix(n))
        } else {
            caption = nil
        }
    }

    /// How many sprite pixels the name tag (and the caption over it) moves up to make room for the "?".
    var markRoom: Double { 17 * min(1, mark * 1.5) }

    private static var headMiddles: [Cast: Int] = [:]
    /// The middle of the top few rows of `cast`'s standing sprite (their head and hair, not the body's middle), measured
    /// once and kept.
    private static func headMiddle(_ cast: Cast) -> Int {
        if let hit = headMiddles[cast] { return hit }
        let c = PixelCanvas(Sprite.width, Sprite.height)
        cast.draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: true)
        let top = cast.drawnTop()
        var lo = Int.max, hi = Int.min
        for y in max(0, top)..<min(c.h, top + 6) {
            for x in 0..<c.w where c.buf[(y * c.w + x) * 4 + 3] > 40 { lo = min(lo, x); hi = max(hi, x) }
        }
        let mid = lo <= hi ? (lo + hi + 1) / 2 : Int(Sprite.bodyCenterX)
        headMiddles[cast] = mid
        return mid
    }
}

/// Rows `slayerDrawTabulaRasa`'s canvas reaches above the sprite's top, for the "?".
let slayerTabulaTop = 20
/// Its width; its column `Sprite.bodyCenterX` is the body's middle, the crystal in front of the feet (facing right;
/// mirror it for one facing left). It's `slayerTabulaTop + Sprite.height` tall, its bottom rows lined up with the
/// sprite's.
let slayerTabulaWidth = 72

private let pinkPale = C(0xFFE2F2), pinkLight = C(0xFFA8DA), pinkMid = C(0xE45AB0), pinkDark = C(0x8E2A78)
private let crystalInk = C(0x3E1238)
private let tabulaCream = C(0xFAF0D6), tabulaInk = C(0x2A1C14)   // the speech captions' backing and ink

/// The spell round the forgetter, on its own canvas, drawn behind them: the pink glow on the ground, the smoke puffing
/// up round them, the crystal at their feet (whole or cracked in two) and the big "?" over their head. `headTop` is the
/// head's top row on the sprite.
func slayerDrawTabulaRasa(_ c: PixelCanvas, _ s: SlayerTabulaRasa, headTop: Int, t: Double) {
    let top = slayerTabulaTop
    let mid = Int(Sprite.bodyCenterX), ground = top + 43   // the row the feet stand on
    let cx = mid + 21                                      // the crystal, out in front, clear of anything held

    // The glow: a pool of pink light on the floor round the crystal, pulsing.
    if s.glow > 0 {
        let g = s.glow * (0.75 + 0.25 * sin(t * 9))
        c.ellipse(cx, ground, 12, 3, pinkLight.alpha(0.22 * g))
        c.ellipse(cx, ground, 7, 2, pinkPale.alpha(0.35 * g))
        c.ellipse(cx, ground - 6, 7, 8, pinkLight.alpha(0.25 * g))
    }

    // The smoke: soft round puffs born at the crystal, billowing up and round the forgetter, growing as they go.
    if s.smoke > 0 {
        for i in 0..<12 {
            let f = frac(t * 0.4 + Double(i) / 12)
            let spread = (noise(i * 23 + 5) - 0.65) * 44          // from in front of them to well behind
            let x = Double(cx) + f * spread + sin(t * 2 + Double(i)) * 1.5
            let y = Double(ground - 2) - f * 34 - noise(i * 11 + 1) * 4
            let r = 2 + Int(f * 5)
            let a = s.smoke * (f < 0.15 ? f / 0.15 : 1 - (f - 0.15) / 0.85)
            c.ellipse(Int(x), Int(y), r, r, pinkLight.alpha(0.42 * a))
            c.ellipse(Int(x) - 1, Int(y) - 1, max(1, r - 2), max(1, r - 2), pinkPale.alpha(0.55 * a))
        }
    }

    // The crystal: a pink shard standing on the floor, its light side to the front-left.
    if s.crystal > 0 {
        let a = s.crystal
        let bright = s.cracked ? 0.0 : s.glow * (0.5 + 0.5 * sin(t * 9))
        let p: [Character: Px] = [
            "o": crystalInk.alpha(a),
            "W": (bright > 0.5 ? C(0xFFFFFF) : pinkPale).alpha(a),
            "L": pinkLight.alpha(a),
            "M": pinkMid.alpha(a),
            "D": pinkDark.alpha(a),
        ]
        if !s.cracked {
            c.pattern(cx - 4, ground - 12, [
                "....o....",
                "...oWo...",
                "..oWWMo..",
                "..oWLMo..",
                ".oWLLMDo.",
                ".oWLLMDo.",
                ".oLLMMDo.",
                ".oLLMDDo.",
                ".oLMMDDo.",
                "..oLMDo..",
                "..oMDDo..",
                "...oDo...",
                "...ooo...",
            ], p)
        } else {
            // Cracked underfoot: the two halves fallen apart, with a chip between them.
            c.pattern(cx - 6, ground - 6, [
                "..o....",
                ".oWo...",
                "oWLMo..",
                "oLLMo..",
                "oLMDo..",
                ".oMDo..",
                "..oo...",
            ], p)
            c.pattern(cx + 2, ground - 4, [
                "..oo.",
                ".oMDo",
                "oLMDo",
                "oLMo.",
                ".oo..",
            ], p)
            c.pattern(cx - 1, ground - 1, ["oo", "oD"], p)
        }
        // The crack: a burst of pink-white splinters flying out from it.
        if s.crack > 0 {
            let d = Int((1 - s.crack) * 7) + 2
            let spark = pinkPale.alpha(min(1, s.crack * 1.6))
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (-1, -1), (1, -1)] {
                for r in max(1, d - 2)...d { c.px(cx + dx * r, ground - 5 + dy * r, spark) }
            }
        }
    }

    // The "?": big, cream with dark ink like the speech captions, popping up over the head and bobbing a little.
    if s.mark > 0 {
        let rise = Int((1 - min(1, s.mark * 1.5)) * 4)
        let bob = Int((sin(t * 5) * 1.2).rounded())
        let bottom = top + headTop - 3 + rise + bob
        let p: [Character: Px] = ["o": tabulaInk.alpha(s.mark), "F": tabulaCream.alpha(s.mark), "P": pinkLight.alpha(s.mark)]
        c.pattern(s.headX - 4, bottom - 14, [
            "..ooooo..",
            ".oFFFFFo.",
            "oFFPooFFo",
            "oFFo.oFFo",
            ".oo..oFFo",
            ".....oFFo",
            "....oFFo.",
            "...oFFo..",
            "...oFFo..",
            "...oooo..",
            ".........",
            "...oooo..",
            "...oFFo..",
            "...oFFo..",
            "...oooo..",
        ], p)
    }
}

/// Remembering: pale pink and white glints twinkling over the forgetter, drawn on their own sprite before its
/// outline. Only on the sprite's solid pixels, so they're solid too and change nothing about the outline.
func slayerTabulaShimmer(_ c: PixelCanvas, _ s: SlayerTabulaRasa, t: Double) {
    guard s.shimmer > 0 else { return }
    let mid = Int(Sprite.bodyCenterX)
    func solid(_ x: Int, _ y: Int) -> Bool { x >= 0 && y >= 0 && x < c.w && y < c.h && c.buf[(y * c.w + x) * 4 + 3] == 255 }
    for i in 0..<26 {
        let phase = frac(t * 2.2 + noise(i * 7))
        guard phase < 0.6 * s.shimmer + 0.1 else { continue }
        let x = mid - 15 + Int(noise(i * 13 + 2) * 31)
        let y = 8 + Int(noise(i * 17 + 9) * 36)
        let col = i % 3 == 0 ? pinkPale : C(0xFFFFFF)
        // A little cross, longer at its brightest.
        let arm = phase < 0.25 ? 2 : 1
        for (dx, dy) in [(0, 0)] + (1...arm).flatMap({ d in [(-d, 0), (d, 0), (0, -d), (0, d)] }) where solid(x + dx, y + dy) {
            c.px(x + dx, y + dy, col)
        }
    }
}
