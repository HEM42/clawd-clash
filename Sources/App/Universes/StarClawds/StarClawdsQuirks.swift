import Foundation

// Star Clawds' stage quirk (`StageQuirks`): HEM and Princess Laya's buns.

/// What HEM says to Princess Laya when he ends up next to her.
let starClawdsBunLines = ["Cute buns. Amateur.", "Nice buns. Mine are bigger.", "Bun for bun, I win."]

/// HEM standing next to Princess Laya, both out of the fight: for five seconds in every twenty he turns to her and
/// has a word about buns (a different one each time).
func starClawdsBunTalk(_ a: OnStage, others: [OnStage], zoom z: CGFloat, t: Double) -> (facing: CGFloat, line: String)? {
    guard a.cast.universe.isHem(a.cast.id), !a.leaving else { return nil }
    guard let laya = others.first(where: { $0.cast == .hero(SWHero.leia) && !$0.walking && !$0.leaving && abs($0.x - a.x) < 90 * z })
    else { return nil }
    let cycle = t / 20 + a.phase
    guard frac(cycle) < 0.25 else { return nil }
    return (laya.x > a.x ? 1 : -1, starClawdsBunLines[Int(floor(cycle)) % starClawdsBunLines.count])
}
