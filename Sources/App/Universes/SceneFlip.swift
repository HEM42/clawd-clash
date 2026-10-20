import CoreGraphics
import Foundation

/// A place that now and then turns the whole scene over (`UniverseModule.sceneFlip`, nil for every universe that
/// doesn't ask for it): on a rare arrival there, the picture slowly turns on its horizontal axis until the place and
/// everyone in it are upside down, stays that way a while, and turns back, or turns back at once when the crew moves
/// on. Only where the place fills the frame: the window's scene and the screen saver, never the desktop. Names and
/// speech stay upright and readable, and clicks land on whoever is under the mouse, turned or not. The universe says
/// where and how often; the window and the screen saver each keep a `SceneFlipClock` and draw it with `SceneTurn`.
struct SceneFlip {
    /// The places it can happen at.
    let places: Set<Location>
    /// The chance that a try turns it over: one try a moment after arriving at one of them, then one every `every`
    /// seconds while the place stays on show.
    var chance = 0.1
    /// Seconds between tries while the place stays on show; nil: only on arriving.
    var every: Double? = nil
    /// Seconds after it's back the right way up before it can turn over again, so it never comes twice in a row.
    var rest = 0.0
    /// How long the half-turn takes, each way, in seconds.
    var turn = 1.5
    /// How long it stays over, in seconds, picked afresh each time.
    var stay: ClosedRange<Double> = 30...60
    /// How long after arriving (and after the transition there) it starts to turn, in seconds.
    var wait: ClosedRange<Double> = 3...9
}

/// When a view's scene turns over and back (`SceneFlip`): one per view that shows a place (the window's scene, each
/// screen-saver view), asked every frame.
final class SceneFlipClock {
    /// `--scene-flip`: every arrival at a place that can turn over does, a moment after it lands. For checking it.
    static let always = CommandLine.arguments.contains("--scene-flip")

    private var place: Location?
    private var flip: SceneFlip?
    /// Turning over from `start`, and back from `back`.
    private var over: (start: Double, back: Double)?
    /// Turning back early (the crew moved on): from how far over it was, starting when.
    private var early: (start: Double, from: Double, turn: Double)?
    private var last = 0.0
    /// When the next try is, and when it was last back the right way up.
    private var nextTry = Double.infinity
    private var lastBack = -Double.infinity

    /// How far over the scene at `place` is at `now`: 0 the right way up, 1 upside down, eased through the half-turn.
    /// `settled`: when the arrival there is over (its transition done), so nothing turns while the scene is changing.
    func amount(at place: Location, now: Double, settled: Double = 0) -> Double {
        if place != self.place {
            // Leaving somewhere mid-turn (or upside down): it turns back, wherever the crew went.
            let was = last
            if was > 0 { early = (now, was, flip?.turn ?? 1.5); lastBack = now + (flip?.turn ?? 1.5) }
            self.place = place
            flip = place.universe.module.sceneFlip.flatMap { $0.places.contains(place) ? $0 : nil }
            over = nil
            nextTry = flip == nil ? .infinity : max(now, settled) + (Self.always ? 1 : .random(in: flip!.wait))
        }
        // A try: it turns over now, by chance, unless it was over only a little while ago.
        if over == nil, now >= nextTry, let f = flip {
            if Self.always || (now - lastBack >= f.rest && Double.random(in: 0..<1) < f.chance) {
                over = (now, now + f.turn + .random(in: f.stay))
            }
            nextTry = f.every.map { now + $0 } ?? .infinity
        }
        var k = 0.0
        if let o = over, let f = flip {
            if now >= o.back + f.turn {
                over = nil
                lastBack = now
                if let e = f.every { nextTry = max(nextTry, now + e) }
            }
            else if now >= o.back { k = 1 - Self.ease((now - o.back) / f.turn) }
            else if now >= o.start { k = Self.ease((now - o.start) / f.turn) }
        }
        if let e = early {
            let p = (now - e.start) / e.turn
            if p >= 1 { early = nil } else { k = max(k, e.from * (1 - Self.ease(p))) }
        }
        last = k
        return k
    }

    /// Start turning over now, at the place on show (the Playground's hidden trigger), if it's a place that can.
    @discardableResult
    func start(now: Double) -> Bool {
        guard let f = flip else { return false }
        if let o = over, now >= o.start, now < o.back {
            over = (o.start, max(o.back, now + .random(in: f.stay)))   // already turning or over: it stays a while longer
        } else {
            over = (now, now + f.turn + .random(in: f.stay))
        }
        return true
    }

    /// Whether the place on show can turn over at all (for the Playground's hidden trigger).
    var canTurn: Bool { flip != nil }

    private static func ease(_ k: Double) -> Double {
        let u = max(0, min(1, k))
        return u * u * (3 - 2 * u)
    }
}

/// The scene turned part of the way over about a level line, `axis` (in the drawing's own coordinates, y up): as if
/// the picture spun on its horizontal axis, seen straight on. Heights squash towards the axis and come out the other
/// side mirrored; labels keep their size and stay upright, only moved to where their spot went.
struct SceneTurn {
    /// 0 the right way up … 1 upside down.
    let amount: Double
    let axis: CGFloat

    static func upright(axis: CGFloat = 0) -> SceneTurn { SceneTurn(amount: 0, axis: axis) }

    var isTurned: Bool { amount > 0.0005 }
    /// How tall the picture is drawn, signed: 1 the right way up, -1 upside down, 0 edge on.
    var scale: CGFloat { amount >= 1 ? -1 : CGFloat(cos(amount * .pi)) }

    /// Where height `y` ends up.
    func y(_ y: CGFloat) -> CGFloat { axis + (y - axis) * scale }

    /// A picture `minY`…`minY + height` turned: where it's drawn now, how tall, and whether it's upside down.
    func span(_ minY: CGFloat, _ height: CGFloat) -> (minY: CGFloat, height: CGFloat, upsideDown: Bool) {
        let a = y(minY), b = y(minY + height)
        return (min(a, b), abs(b - a), scale < 0)
    }

    /// Where a click at height `y` was on the picture the right way up; nil while it's too near edge on to hit
    /// anything.
    func unturn(_ y: CGFloat) -> CGFloat? {
        guard isTurned else { return y }
        guard abs(scale) > 0.2 else { return nil }
        return axis + (y - axis) / scale
    }

    /// How much of a label shows: names and speech fade out as the picture goes edge on and back in, upright, as it
    /// settles the other way up.
    var labelAlpha: CGFloat {
        let s = abs(scale)
        let k = max(0, min(1, (s - 0.45) / 0.45))
        return k * k * (3 - 2 * k)
    }
}
