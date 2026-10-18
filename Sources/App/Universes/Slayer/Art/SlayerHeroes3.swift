import Foundation

// Heroes: the Summers family, the other Slayers, Jenny Clawlendar and two of Angel Investigations. Clawd in costume
// like the rest of the cast: hair and clothes drawn over the blocky body, with Clawd's own orange face showing.

let slayerHeroes3: [SlayerHero: Persona] = [
    .dawnClawmers: Persona(name: "Dawn Clawmers", headTop: 20, signature: 3.2, draw: drawDawnClawmers),
    .joyceClawmers: Persona(name: "Joyce Clawmers", weapon: .saber, headTop: 21, signature: 3.4,
                            callout: "Have you tried not being a Slayer?", draw: drawJoyceClawmers),
    .faithLehayne: Persona(name: "Faith Lehayne", weapon: .saber, headTop: 20, signature: 3.0,
                           callout: "Five by five.", draw: drawFaithLehayne),
    .kendraYung: Persona(name: "Kendra Yung", weapon: .saber, headTop: 20, signature: 3.0,
                         callout: "Mr. Pointy.", draw: drawKendraYung),
    .jennyClawlendar: Persona(name: "Jenny Clawlendar", weapon: .lightning,
                              magic: Magic(core: C(0xFFF2C4), glow: C(0xE0961E), jagged: false, touch: true),
                              pivot: (40, 29.5), headTop: 21, signature: 3.4, draw: drawJennyClawlendar),
    .angstel: Persona(name: "Angstel", weapon: .saber, headTop: 17, signature: 3.6,
                      callout: "We help the helpless.", draw: drawAngstel),
    .wesleyWindupPryce: Persona(name: "Wesley Windup-Pryce", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                                headTop: 21, signature: 3.0, callout: "Rogue demon hunter!",
                                draw: drawWesleyWindupPryce),
]

// MARK: - Shared bits

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
private func slayerSpan(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// A swung weapon's angle kept in front of the face: once a swing goes back over the head (or down behind), it
/// stops just past upright (or just past straight down), so it never sweeps across the face or vanishes behind
/// the hair.
private func slayerFrontAngle(_ a: Double) -> Double {
    var n = a.truncatingRemainder(dividingBy: 360)
    if n > 180 { n -= 360 } else if n <= -180 { n += 360 }
    return max(-102, min(110, n))
}

/// An unarmed hero's free arm: up and waving while cheering or calling you urgently, otherwise drawBody's own.
/// `now and then`: only in short bursts, the arm down in between.
private func slayerWave(_ c: PixelCanvas, _ p: Pose, sleeve: Px, nowAndThen: Bool = false) {
    guard p.cheering || (p.ready && p.urgent) else { return }
    if nowAndThen && (p.t / 2.6 - floor(p.t / 2.6)) > 0.3 { return }
    let up = sin(p.t * 10) > 0 ? 1 : 0
    c.rect(38, 26 - up, 3, 7 + up, sleeve); c.rect(38, 24 - up, 3, 2, clawdOrange)
}

// MARK: - Dawn Clawmers

/// Dawn Clawmers: Clawd with very long straight brown hair, a soft blue teen jumper with a white stripe across it,
/// jeans and white trainers. She doesn't fight. Signature: the Key's green energy flickers through her, faint green
/// light running over her in bands, a few motes rising off her hair, then gone.
private func drawDawnClawmers(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0x7EA6D2), jumperD = C(0x5A82B0), stripe = C(0xEEF2F8)
    let hair = C(0x5E3C22), hairL = C(0x80583A), hairD = C(0x3E2614)
    let keyK = slayerSpan(p, 0.08, 0.92)

    drawLegs(c, Look(leg: C(0x41598A)), step: p.step)
    slayerBoots(c, step: p.step, C(0xE8E8EC), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper))
    // The jumper, a white stripe across the chest, a round neck.
    c.rect(18, 33, 20, 5, jumper); c.rect(37, 33, 1, 5, jumperD); c.rect(18, 37, 20, 1, jumperD)
    c.rect(18, 35, 20, 1, stripe); c.rect(25, 33, 6, 1, jumperD)
    // Very long straight hair, a side parting, down past her shoulders to her waist; while the Key flickers through
    // her, her hair and face catch its green.
    let strength = keyK >= 0 ? sin(keyK * .pi) * (0.7 + 0.3 * sin(p.t * 23)) : 0
    let green = C(0x9CFFB0)
    if strength > 0 { c.rect(18, 26, 20, 12, green.alpha(0.22 * strength)) }
    let glowHair = strength > 0.5
    c.pattern(16, 20, [
        "......HHHHHHHHHHHH......",
        "....HHHHHHHHHlHHHHHH....",
        "...HHHlHHHHHHHHHHlHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHH..........HHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        ".dHd................dHd.",
        ".dd..................dd.",
    ], glowHair ? ["H": C(0x625A36), "l": C(0x9CC484), "d": C(0x423C22)] : ["H": hair, "l": hairL, "d": hairD])
    slayerWave(c, p, sleeve: jumper, nowAndThen: true)

    guard keyK >= 0 else { return }
    if strength > 0.6 { c.rect(22, 29, 2, 3, C(0xE8FFE8)); c.rect(32, 29, 2, 3, C(0xE8FFE8)) }   // her eyes light up
    // Motes rising off her, faint enough to stay soft at the edge.
    for i in 0..<5 {
        let f = (keyK * 2.5 + Double(i) * 0.2).truncatingRemainder(dividingBy: 1)
        let x = 17 + i * 5 + Int(sin(f * 6 + Double(i)) * 1.5), y = 30 - Int(f * 14)
        c.px(x, y, C(0x9CFFB0).alpha(0.2 * strength))
    }
}

// MARK: - Joyce Clawmers

/// Joyce Clawmers: Clawd with short wavy blonde hair, a smart dusty-rose blouse with a white collar, tan slacks and low
/// shoes. She fights with the fire axe from "School Hard", which she only takes up when she has to. Signature: she
/// folds her arms, her brows come down, and she gives you a mum's look, tapping one foot.
private func drawJoyceClawmers(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0xC4848E), blouseD = C(0x9E6470), collar = C(0xF2ECE4)
    let hair = C(0xD6BE8A), hairL = C(0xEEDCB0), hairD = C(0xA88E5C)
    let lookK = slayerSpan(p, 0.08, 0.94)
    let tap = lookK >= 0 && lookK > 0.3 && Int(p.t * 6) % 2 == 0

    drawLegs(c, Look(leg: C(0x8A765C)), step: tap ? 1 : p.step)
    slayerBoots(c, step: tap ? 1 : p.step, C(0x4A3426), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: blouse))
    // The blouse, a neat white collar at the neck and a row of buttons.
    c.rect(18, 33, 20, 5, blouse); c.rect(37, 33, 1, 5, blouseD); c.rect(18, 37, 20, 1, blouseD)
    c.pattern(24, 33, ["CC....CC"], ["C": collar])
    // Short, soft blonde hair, curled under just above her shoulders.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHH.......",
        "...HHHHlHHHHHHlHHHHH....",
        "..HHHHHHHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHlHHHHHHHHHHHHlHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHl................lHH.",
        ".dHH................HHd.",
        "..dd................dd..",
    ], ["H": hair, "l": hairL, "d": hairD])

    if lookK >= 0 {
        // Arms folded across her front (the nubs at her sides are her elbows), brows down, eyes narrowed.
        c.rect(19, 33, 18, 1, blouseD); c.rect(19, 34, 18, 2, C(0xDCA2AC)); c.rect(19, 36, 18, 1, blouseD)
        c.rect(21, 34, 2, 2, clawdOrange); c.rect(33, 34, 2, 2, clawdOrange)
        c.rect(22, 29, 2, 1, clawdOrange); c.rect(32, 29, 2, 1, clawdOrange)
        c.pattern(21, 27, ["BB..........BB", "..BB......BB.."], ["B": C(0x6A4A2A)])
        return
    }
    slayerWave(c, p, sleeve: blouse)
    guard let swing = p.melee else { return }
    // The fire axe: a long wooden haft and a red head with a bright edge, never swung back across her face.
    // (Low, it swings no further back than down-and-forward, its head clear of her legs.)
    let h = slayerHand, a = min(70, slayerFrontAngle(swing))
    let trail = p.trail.map { min(70, slayerFrontAngle($0)) }.filter { abs($0 - a) > 4 }
    slayerSmear(c, h, trail, from: 6, to: 12, C(0xF4E8D0))
    let down = sin(a * .pi / 180), len = down > 0.2 ? max(6, min(11, 6.5 / down)) : 11   // shorter when hanging low
    slayerBar(c, h, a, from: -3, to: len, C(0x7A5230), r: 0.9)
    let head0 = slayerReach(h, a, len - 3), head1 = slayerReach(h, a, len)
    let side = a + 90
    let e0 = slayerReach(head0, side, 4), e1 = slayerReach(head1, side, 4)
    slayerLine(c, head0.x, head0.y, e0.x, e0.y, C(0xC0302A), 1)
    slayerLine(c, head1.x, head1.y, e1.x, e1.y, C(0xC0302A), 1)
    slayerLine(c, e0.x, e0.y, e1.x, e1.y, C(0xE4E8EE), 0.7)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Faith Lehayne

/// Faith Lehayne: Clawd with dark wavy hair to her shoulders, a black vest top that leaves her arms bare, tight black
/// leather trousers with a shine down them, and boots. She fights with a knife. Signature: the Mayor's knife, the long
/// blade he gave her, twirled round her fingers and caught.
private func drawFaithLehayne(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0x1A181E), vestD = C(0x0E0C12), leather = C(0x26222C), shine = C(0x4E4858)
    let hair = C(0x2E1C16), hairL = C(0x4E3228), hairD = C(0x1A0E0A)
    let twirlK = slayerSpan(p, 0.1, 0.85)

    drawLegs(c, Look(leg: leather), step: p.step)
    // Just a glint of shine at each knee: a stripe the whole way down made the legs look zebra-striped.
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, 38, shine) } }
    slayerBoots(c, step: p.step, C(0x121014), height: 3)
    c.oy += p.breathe
    drawBody(c, Look(), armRight: twirlK >= 0 ? 2 : 0)
    // The black vest top on thin straps, her shoulders and arms bare.
    c.rect(19, 34, 18, 4, vest); c.rect(36, 34, 1, 4, vestD); c.rect(19, 37, 18, 1, vestD)
    c.rect(21, 33, 2, 1, vest); c.rect(33, 33, 2, 1, vest)
    c.pattern(25, 34, ["l......l"], ["l": C(0x3A3640)])
    c.rect(18, 36, 1, 2, leather); c.rect(37, 36, 1, 2, leather)   // the trousers' waistband
    // Dark wavy hair with volume, a few kinks breaking the outline.
    c.pattern(15, 20, [
        ".......HHHHHHHHHHH.......",
        ".....HHHHHlHHHHHHHHH.....",
        "...HHHHHHHHHHHHHlHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHH...........HHHHHHH.",
        ".HHHH..............HHHHHH",
        "..HHH...............HHHH.",
        ".HHHl...............lHHH.",
        "HHHH.................HHHH",
        ".HHd.................dHH.",
        "..Hd.................dH..",
        ".dd...................dd.",
    ], ["H": hair, "l": hairL, "d": hairD])

    let knife = C(0xD8DEE8), knifeD = C(0x8A94A4), grip = C(0x3A2418), gold = C(0xD8B04A)
    if twirlK >= 0 {
        // Spun round her raised fingers, twice, and caught point down.
        let h = (x: slayerHand.x, y: slayerHand.y - 2)
        let a = -90 + twirlK * 720
        slayerBar(c, h, a + 180, from: 0.5, to: 3, grip, r: 0.8)
        slayerBar(c, h, a, from: 1.5, to: 8, knifeD, r: 0.9)
        slayerBar(c, h, a, from: 1.5, to: 7.5, knife, r: 0.6)
        let g = slayerReach(h, a, 1)
        c.px(Int(g.x.rounded()), Int(g.y.rounded()), gold)
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()), 3, 2, clawdOrange)
        return
    }
    if let a = p.melee {
        let h = slayerHand
        slayerSmear(c, h, p.trail, from: 2, to: 9, C(0xF0F4FF))
        slayerBar(c, h, a, from: -2, to: 1, grip, r: 1)
        slayerBar(c, h, a, from: 2, to: 8.5, knifeD, r: 0.9)
        slayerBar(c, h, a, from: 2, to: 8, knife, r: 0.6)
        let g = slayerReach(h, a, 1.5)
        c.px(Int(g.x.rounded()), Int(g.y.rounded()), gold)
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
    } else {
        // The knife held low and loose, blade down.
        c.rect(39, 36, 1, 2, grip); c.px(39, 36, gold); c.rect(39, 38, 1, 3, knife); c.rect(40, 38, 1, 2, knifeD)
    }
}

// MARK: - Kendra Yung

/// Kendra Yung: Clawd with her hair in long thin braids, pulled back from her face, a practical rust-red top with a
/// belt and loose olive trousers. She fights with a stake, which she has named. Signature: she holds Mr. Pointy up
/// proudly, high over her head, and it glints.
private func drawKendraYung(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0xA8502E), topD = C(0x803A20), topL = C(0xC66A44), belt = C(0x3A2A1E)
    let hair = C(0x1C1412), braid = C(0x56402E), tie = C(0xC8A040)
    let pointK = slayerSpan(p, 0.08, 0.9)

    drawLegs(c, Look(leg: C(0x5C603C)), step: p.step)
    slayerBoots(c, step: p.step, C(0x2A2018), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: top), armRight: pointK >= 0 ? 7 : 0)
    // The top, a belt at the waist.
    c.rect(18, 33, 20, 5, top); c.rect(37, 33, 1, 5, topD); c.rect(18, 36, 20, 1, belt); c.px(27, 36, tie)
    c.rect(18, 33, 1, 3, topL); c.rect(25, 33, 6, 1, topD)
    // Braids: a few bold rows pulled straight back over her head, then two thick braids hanging long behind each
    // shoulder, tied off in gold. (Fewer, bolder lines than a fine weave, which read as a chequered band when small.)
    c.pattern(16, 20, [
        "......HHbHHHbHHHbH......",
        "....HbHHbHHHbHHHbHHb....",
        "...HHbHHbHHHbHHHbHHbH...",
        "..HHbHHHbHHHbHHHbHHHbH..",
        "..HHbHHHbHHHbHHHbHHHbH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".bHb................bHb.",
        ".b.b................b.b.",
        ".t.t................t.t.",
    ], ["H": hair, "b": braid, "t": tie])

    if pointK >= 0 {
        // Mr. Pointy held high, upright, and a glint running up to his tip.
        let lift = min(1, pointK * 4) * min(1, (1 - pointK) * 4)
        let h = (x: slayerHand.x - 1, y: slayerHand.y - 7 - lift * 2)
        slayerStake(c, angle: -90, trail: [], from: h)
        if pointK > 0.35 && pointK < 0.75 {
            let gy = Int(h.y.rounded()) - 10
            c.px(Int(h.x.rounded()), gy - 1, white)
            c.px(Int(h.x.rounded()) - 1, gy, C(0xFFF4C0)); c.px(Int(h.x.rounded()) + 1, gy, C(0xFFF4C0))
            c.px(Int(h.x.rounded()), gy - 2, C(0xFFF4C0, 0.2))
        }
        return
    }
    if let a = p.melee {
        slayerStake(c, angle: a, trail: p.trail)
    } else {
        slayerStakeHeld(c)
    }
}

// MARK: - Jenny Clawlendar

/// Jenny Clawlendar: Clawd with dark chin-length hair and a fringe, a long plum cardigan to her knees over a rust
/// patterned dress, her laptop tucked under one arm and the Orb of Thessulah in her other hand. The Orb is the Romani
/// spirit vessel of the Ritual of Restoration, the one that gives a vampire back his soul: it never fires anything, it
/// glows. So when she casts it lights from within, pale gold, and whoever she holds it up to is bathed in amber light,
/// motes drifting up round them (a touch, not a stream). Signature: she holds it up high, and it lights slowly.
private func drawJennyClawlendar(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0x6A3A5E), cardiD = C(0x4A2842), cardiL = C(0x8A5478), dress = C(0xB8622E), dot = C(0xE8A060)
    let hair = C(0x2E1E1A), hairL = C(0x4C342C), hairD = C(0x1A100E)
    let orbK = slayerSpan(p, 0.06, 0.94)

    drawLegs(c, Look(leg: C(0x3A2A30)), step: p.step)
    slayerBoots(c, step: p.step, C(0x1E1418), height: 2)
    // Casting (a fight, practice, or waiting on you): the Orb raised and lit; her signature: held up high.
    let casting = p.zap != nil
    let raise = orbK >= 0 ? 4 : casting ? max(2, p.armRaise) : p.armRaise
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armRight: raise)
    // The dress showing down the middle, the long cardigan open over it and hanging to her knees.
    c.rect(18, 33, 20, 5, cardi); c.rect(24, 33, 8, 5, dress)
    for (x, y) in [(25, 34), (28, 33), (30, 35), (26, 36), (29, 37)] { c.px(x, y, dot) }
    c.rect(23, 33, 1, 5, cardiL); c.rect(32, 33, 1, 5, cardiD); c.rect(37, 33, 1, 5, cardiD)
    c.rect(17, 38, 7, seatedPose ? 1 : 2, cardi); c.rect(32, 38, 7, seatedPose ? 1 : 2, cardi)
    c.rect(24, 38, 8, seatedPose ? 1 : 2, dress)
    if !seatedPose { c.rect(17, 39, 7, 1, cardiD); c.rect(32, 39, 7, 1, cardiD); c.rect(17, 38, 1, 2, cardiL) }
    // Dark hair, chin-length with a straight fringe.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHHH......",
        "...HHHHHlHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHlHHH...",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................lHH.",
        ".HHd................dHH.",
        "..dd................dd..",
    ], ["H": hair, "l": hairL, "d": hairD])
    // The laptop, shut, tucked under her left arm: a chunky nineties machine, charcoal, its lid's light edge and the
    // seam between lid and base showing, a green power light on its front, her hand round it.
    let lap = C(0x3A3D45), lapL = C(0x7A7F8A), lapD = C(0x22242A)
    c.rect(11, 30, 4, 9, lap); c.rect(11, 30, 1, 9, lapL); c.rect(11, 30, 4, 1, lapL)
    c.rect(13, 31, 1, 8, lapD); c.rect(14, 38, 1, 1, lapD); c.px(12, 37, C(0x6CE08A))
    c.rect(14, 33, 2, 3, cardi)

    // The Orb of Thessulah on her palm: clear glass at rest, lit from within, pale gold, when she casts.
    let lit = orbK >= 0 ? max(0, min(1, (orbK - 0.25) * 3)) * min(1, (1 - orbK) * 6) : casting ? 1 : 0
    let ox = 40, oy = 28 - raise
    c.rect(ox - 1, oy + 4, 3, 2, clawdOrange)
    let glass = lit > 0.5 ? C(0xFFE89A) : C(0xC8D8E4), rim = lit > 0.5 ? C(0xE0A030) : C(0x8AA0B4)
    c.pattern(ox - 2, oy, [".rrr.", "rgggr", "rgwgr", ".rrr."], ["r": rim, "g": glass, "w": white])
    if lit > 0 {
        for k in 0..<8 {
            let g = Double(k) * .pi / 4 + p.t * 2
            let r = 4.0 + sin(p.t * 7 + Double(k)) * 0.6
            c.px(ox + Int((cos(g) * r).rounded()), oy + 2 + Int((sin(g) * r).rounded()), C(0xFFD860).alpha(0.22 * lit))
        }
    }
}

// MARK: - Angstel

/// Angstel: Clawd with dark hair gelled up in spikes, a long black coat to his shins with the collar up, a dark shirt
/// under it. He fights with a broadsword. Signature: "Smile Time": for a second he is a felt puppet, yarn hair, a big
/// hinged mouth and googly eyes, then he's himself again, eyes down, embarrassed.
private func drawAngstel(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1C1C22), coatD = C(0x0E0E12), coatL = C(0x3A3A44), shirt = C(0x34303A)
    let hair = C(0x2A201C), hairL = C(0x4A3A32), hairD = C(0x16100E)
    let s = p.signature ?? -1
    let puppet = s > 0.18 && s < 0.66
    let shy = s >= 0.66 && s < 0.95
    let felt = C(0xE6A272), feltD = C(0xC48456)

    // The long coat's skirts hang behind the legs, down past the knees: all four legs (charcoal trousers, a shade
    // lighter than the coat) stay in front of it, so they read as legs rather than a dark doorway between two panels.
    if !seatedPose {
        c.rect(17, 38, 8, 3, coat); c.rect(31, 38, 8, 3, coat)
        c.rect(17, 40, 8, 1, coatD); c.rect(31, 40, 8, 1, coatD); c.rect(17, 38, 1, 2, coatL)
    }
    drawLegs(c, Look(leg: C(0x484852)), step: p.step)
    slayerBoots(c, step: p.step, C(0x0E0E10), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: puppet ? felt : clawdOrange, shade: puppet ? feltD : clawdShade, arm: coat,
                     eye: puppet ? nil : ink))
    // The long coat: open over the dark shirt, its skirts (above) hanging on down past the knees.
    c.rect(18, 33, 20, 5, coat); c.rect(24, 33, 8, 5, shirt)
    c.rect(23, 33, 1, 5, coatL); c.rect(32, 33, 1, 5, coatD); c.rect(37, 33, 1, 5, coatD)
    if seatedPose { c.rect(17, 38, 7, 1, coat); c.rect(32, 38, 7, 1, coat) }
    // The turned-up collar.
    c.rect(17, 31, 2, 3, coat); c.rect(37, 31, 2, 3, coat); c.px(17, 31, coatL)

    if puppet {
        // Felt: yarn hair in fat tufts, googly eyes, a big hinged mouth that flaps, a stitch line down his middle.
        let tuft = C(0x3A2A22)
        c.pattern(17, 21, [
            "...TT..TTT..TT..TT..",
            "..TTTTTTTTTTTTTTTTT.",
            ".TTTTTTTTTTTTTTTTTTT",
            ".TTTTTTTTTTTTTTTTTTTT",
            ".TT...............TT.",
        ], ["T": tuft])
        c.pattern(20, 27, [".WWW....WWW.", "WWWWW..WWWWW", "WWKKW..WWKKW", "WWKKW..WWKKW", ".WWW....WWW."],
                  ["W": white, "K": ink])
        let open = Int(p.t * 7) % 2 == 0 ? 1 : 0
        c.rect(22, 32, 12, 1, C(0x5A1A1A)); c.rect(23, 33 - 0, 10, open, C(0xB03A3A))
        c.px(28, 26, feltD); c.px(28, 25, feltD)
        return
    }
    // Spiky dark hair, gelled up.
    c.pattern(16, 17, [
        "......H...H..H...H......",
        ".....HH..HH.HH..HH.H....",
        "....HHHHHHHHHHHHHHHH....",
        "...HHHHlHHHHHlHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..dHHHHHHHHHHHHHHHHHHd..",
        "..dHHHHHHHHHHHHHHHHHHd..",
        "..dH..H.........H...Hd..",
    ], ["H": hair, "l": hairL, "d": hairD])
    // A brooding brow.
    c.rect(21, 28, 3, 1, hairD); c.rect(32, 28, 3, 1, hairD)
    if shy {
        // Back to himself: eyes down, a blush.
        c.rect(22, 29, 2, 1, clawdOrange); c.rect(32, 29, 2, 1, clawdOrange)
        c.rect(20, 32, 2, 1, C(0xF08A80)); c.rect(34, 32, 2, 1, C(0xF08A80))
    }
    guard let a = p.melee else { return }
    // The broadsword: a long steel blade, a crossguard and a dark grip.
    let h = slayerHand
    slayerSmear(c, h, p.trail, from: 4, to: 15, C(0xE4ECF8))
    slayerBar(c, h, a, from: -2, to: 1.5, C(0x2A1E18), r: 0.9)
    slayerBar(c, h, a, from: 3, to: 15, C(0x8A94A4), r: 1)
    slayerBar(c, h, a, from: 3, to: 14.5, C(0xD8DEE8), r: 0.6)
    let g = slayerReach(h, a, 2.2)
    let g0 = slayerReach(g, a - 90, 2.5), g1 = slayerReach(g, a + 90, 2.5)
    slayerLine(c, g0.x, g0.y, g1.x, g1.y, C(0xA8AEB8), 0.6)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Wesley Windup-Pryce

/// Wesley Windup-Pryce, in his Angel look: Clawd with short dark hair, stubble, a brown leather jacket over a dark
/// shirt and dark jeans, a pistol in his hand and another on his hip. Signature: "Rogue demon hunter!": he flicks his
/// jacket back off the holstered pistol and strikes a pose, the gun in his hand pointed at the sky.
private func drawWesleyWindupPryce(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x5E3E28), jacketD = C(0x3E2818), jacketL = C(0x7E5638), shirt = C(0x2A2A32)
    let hair = C(0x3A2A20), hairL = C(0x5A4232), hairD = C(0x22180E), stubble = C(0x9A5236)
    let flickK = slayerSpan(p, 0.1, 0.9)

    drawLegs(c, Look(leg: C(0x2A3040)), step: p.step)
    slayerBoots(c, step: p.step, C(0x1E1612), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket), armLeft: flickK >= 0 ? 1 : 0)
    // The leather jacket, open over the dark shirt.
    c.rect(18, 33, 20, 5, jacket); c.rect(24, 33, 8, 5, shirt)
    c.rect(23, 33, 1, 5, jacketL); c.rect(32, 33, 1, 5, jacketD); c.rect(37, 33, 1, 5, jacketD)
    c.rect(18, 37, 20, 1, jacketD); c.rect(24, 37, 8, 1, shirt)
    c.rect(22, 33, 2, 1, jacketL); c.rect(32, 33, 2, 1, jacketL)   // collar points
    // Stubble: a shadow along his jaw that climbs his cheeks into sideburns, rather than a dotted row (which read as a
    // mouth).
    let shadow = C(0xB8603E)
    c.rect(18, 32, 20, 1, shadow); c.rect(18, 28, 2, 4, shadow); c.rect(36, 28, 2, 4, shadow)
    for x in [19, 21, 24, 27, 30, 33, 35] { c.px(x, 32, stubble) }
    c.px(18, 30, stubble); c.px(19, 31, stubble); c.px(36, 31, stubble); c.px(37, 30, stubble)
    // Short, slightly untidy dark hair.
    c.pattern(16, 21, [
        "......HHHHHHHHHHH.......",
        "....HHHHlHHHHHHHHH.H....",
        "...HHHHHHHHHlHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHH..............HHH..",
        "..dH................Hd..",
    ], ["H": hair, "l": hairL, "d": hairD])
    // The holster on his left hip, with the second pistol in it.
    let flipped = flickK >= 0
    c.rect(19, 35, 3, 3, C(0x3A2416)); c.rect(19, 35, 3, 1, C(0x2A2A30))
    if flipped {
        // The jacket's left side swept back behind him, the holster bared.
        // It flares out wide, the hem flung furthest, and swings in again.
        let sweep = min(1, flickK * 5) * min(1, (1 - flickK) * 5)
        for (i, y) in (33...37).enumerated() {
            let back = Int((sweep * [4, 5, 5, 6, 6][i]).rounded())
            c.rect(18 - back, y, 4 + min(back, 2), 1, y == 37 ? jacketD : jacket)
            if back > 1 { c.px(18 - back, y, jacketL) }
        }
        c.rect(19, 35, 3, 3, C(0x3A2416)); c.rect(19, 35, 3, 1, C(0x2A2A30)); c.px(21, 36, C(0x8A8F9C))
        // The pistol in his right hand, pointed at the sky.
        c.rect(38, 30, 3, 3, jacket); c.rect(39, 28, 2, 2, clawdOrange)
        c.pattern(39, 21, ["K.", "KT", "KK", "KK", "KK", "KK", "KK"], ["K": C(0x2A2A30), "T": C(0x8A8F9C)])
        return
    }
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, jacket)
    drawPistol(c, x: 40, y: 31)
}
