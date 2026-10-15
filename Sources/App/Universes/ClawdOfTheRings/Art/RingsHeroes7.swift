import Foundation

// Heroes: Thorin's company, five dwarves at Gimmie's size (his helmet's top is where a Man's brows are) and as broad
// as he is. Every one is Clawd in costume, Clawd's orange face and ink eyes, and each is told apart from the others
// and from Gimmie at a glance by the colour and shape of the beard, what's on the head, the coat and the weapon:
// Thorin black-maned in royal blue with an oak branch and an elven sword, Load Balin-cer bald in a red hood with a
// forked white beard and a staff, Kill-i stubbled and dark-haired with a short bow, File-i blond with a braided
// moustache and two swords, and Groan, Gimmie's father, a round grizzled red beard under a fur hat, with a great axe.

let ringsHeroes7: [LOTRHero: Persona] = [
    .thorin: Persona(name: "Thorin Oakenshell", weapon: .saber, pivot: dwarfHand, headTop: 25,
                     callout: "King under the Mountain, and root in every shell.", draw: drawThorin),
    .balin: Persona(name: "Load Balin-cer", weapon: .saber, pivot: dwarfHand, headTop: 23,
                    callout: "Round-robin, lads: one orc each.", draw: drawBalin),
    .kili: Persona(name: "Kill-i", weapon: .blaster, shot: .arrow, muzzle: (47, 36), handGun: false, headTop: 25,
                   callout: "Orcs don't get a SIGTERM. Only kill -9.", draw: drawKili),
    .fili: Persona(name: "File-i", weapon: .saber, pivot: dwarfHand, headTop: 25,
                   callout: "File-i, at your service: read, write and execute!", draw: drawFili),
    .gloin: Persona(name: "Groan", weapon: .saber, pivot: dwarfHand, bulk: 2, headTop: 21,
                    callout: "Ohh, my back. My gold. My boy. In that order.", draw: drawGloin),
]

/// Where a dwarf's weapon hand is: Gimmie's, lower than a Man's.
private let dwarfHand: (x: Double, y: Double) = (42.5, 36.5)

// MARK: - Thorin Oakenshell

/// Thorin Oakenshell, the dwarf king: long black hair streaked with grey falling past his shoulders, a short trimmed
/// black beard, a royal-blue coat with a heavy dark fur collar and a belt with a silver buckle. An oak branch, leaves
/// still on it, is strapped to his off arm for a shield, and he holds Orcrist, the elven sword: a slim pale blade,
/// curving a little at the tip, with blue runes and a silver crossguard bent toward the point. At rest he holds it up
/// before him, proud.
private func drawThorin(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x2C4C8E), coatShade = C(0x1E3668), coatLight = C(0x4A6EB4)
    let fur = C(0x7A6A5A), furDark = C(0x564A3E), furLight = C(0x9A8A78)
    let hair = C(0x1C1A20), hairSoft = C(0x34323A), grey = C(0x9A9CA4)
    drawDwarfLegs(c, p, trousers: C(0x2A2A34), boot: C(0x1E1A18), toe: C(0x3A3230))
    c.oy += p.breathe
    drawOakBranch(c)
    drawDwarfBody(c, coat: coat, coatShade: coatShade)
    c.rect(27, 33, 2, 6, coatLight)                                           // the coat's front edge
    c.rect(17, 37, 22, 1, C(0x2A1E16)); c.rect(27, 37, 2, 1, C(0xC8D0D8))     // the belt and its buckle
    c.rect(13, 35, 4, 3, coat); c.rect(11, 35, 2, 3, clawdOrange)             // the off arm, its fist round the branch
    // The fur collar, heavy across the shoulders.
    c.pattern(14, 32, [
        "..fFFlF..............FlFFf..",
        ".FFFFfFFFlFFFFFFFFlFFFfFFFF.",
        "..fFF.FFf.FfF.FFf.FfF.fFF...",
    ], ["F": fur, "f": furDark, "l": furLight])
    // Long black hair streaked with grey, a ragged fringe, falling past the shoulders.
    c.pattern(15, 25, [
        "......HHHHHHHHHHHHHH......",
        "...HHHHgHHHHHHHHHHgHHHH...",
        ".HHHHHgHHHHHssHHHHHgHHHHH.",
        "HHHHgHH.H........H.HHgHHHH",
        "HHHgH.................HgHH",
        "HHgH..................HgHH",
        "HHgH..................HgHH",
        "HHgH..................HgHH",
        "HHgH..................HgHH",
        "HHgH..................HgHs",
        "HHgH..................HgH.",
        "HsgH..................sgH.",
        "HHgH..................HH..",
        ".HgH..................H...",
        ".H.H......................",
    ], ["H": hair, "s": hairSoft, "g": grey])
    // The short black beard, trimmed close.
    c.pattern(19, 31, [
        "B................B",
        "BB..............BB",
        "..BBBBBBBBBBBBBB..",
        "....BBBgBBBBBB....",
        "......BBBBBB......",
    ], ["B": C(0x24202A), "g": C(0x5A5660)])
    // Orcrist, held up before him at rest, swung with a pale smear behind a fast stroke.
    let angle = min(20, p.melee ?? -55)
    drawSwordSmear(c, at: dwarfHand, reach: 19, trail: p.melee == nil ? [] : p.trail.map { min(20, $0) })
    prop(c, at: dwarfHand, angle: angle, drawOrcrist)
    c.rect(39, 35, 2, 3, coat); c.rect(41, 35, 2, 3, clawdOrange); c.px(41, 37, clawdShade)   // the fist round the grip
}

/// The oak branch Thorin bears for a shield, strapped upright along his off arm: a thick length of bark, a twig with a
/// leaf off one side and a sprig of oak leaves at the top.
private func drawOakBranch(_ c: PixelCanvas) {
    let rows = [
        ".L.L...",
        "LLLwL..",
        ".LwLL..",
        "..wW...",
        ".WWWW..",
        ".WbWW..",
        ".WWWWw.",
        ".WWbW.w",
        ".WWWW.L",
        ".bWWW..",
        ".WWWb..",
        ".WWWW..",
        ".WbWW..",
        ".WWWW..",
        ".WWbW..",
        "..WW...",
    ]
    c.pattern(8, 26, Array(rows.prefix(max(0, 43 - c.oy - 26 + 1))),                 // never through the floor
              ["W": C(0x6A4A2C), "b": C(0x4A3020), "w": C(0x5A3E24), "L": C(0x5A8A3A)])
}

/// Orcrist, pointing right from (20, 20) of a prop canvas: a dark grip and silver pommel, a silver crossguard whose ends
/// bend toward the point, and a slim pale blade, 16 px, its back rising a pixel at the tip, with three blue runes.
private func drawOrcrist(_ s: PixelCanvas) {
    s.pattern(16, 17, [
        ".......c................",
        "......c.................",
        "......c..............BBb",
        "PGGGGGcBBrBBBrBBBrBBBBb.",
        ".GGGGGcEEEEEEEEEEEEEEE..",
        "......c.................",
        ".......c................",
    ], ["P": C(0xC8CCD4), "G": C(0x2A2A3A), "c": C(0xB8C0CC), "B": C(0xDCEAF6), "b": C(0xF4FAFF),
        "E": C(0x9DB4CC), "r": C(0x7FC0FF)])
}

// MARK: - Load Balin-cer

/// Load Balin-cer, the old and kindly one: a bald orange dome with a shine on it, his red hood pushed back so it frames
/// the head and drapes over the shoulders, white tufts at the temples and white brows, and a long snow-white beard
/// that forks in two below the chest, the points to his knees. A dusty plum coat, and a tall wooden staff with an iron
/// knob and a gold band, planted on the floor at rest like a walking stick and swung like a club.
private func drawBalin(_ c: PixelCanvas, _ p: Pose) {
    let hood = C(0xB02A26), hoodDark = C(0x82201E), hoodLight = C(0xCC4438)
    let coat = C(0x5E4A6E), coatShade = C(0x45364F)
    let white = C(0xF4F4F8), whiteShade = C(0xC8CCD8)
    drawDwarfLegs(c, p, trousers: C(0x4A3E36), boot: C(0x2E2218), toe: C(0x46362A))
    c.oy += p.breathe
    // The hood, pushed back: a red ring round the head, behind it.
    c.pattern(14, 23, [
        ".......RRRRRRRRRRRRRR.......",
        ".....RRRRRRlRRRRRRRRRRR.....",
        "...RRRRlRRRRRRRRRRRRRRRRR...",
        "..RRRRRRRRRRRRRRRRRRRRRRRd..",
        ".RRRRRRRRRRRRRRRRRRRRRRRRRd.",
        ".RRR....................RRd.",
        "RRRd....................RRRd",
        "RRRd....................RRRd",
        "RRd......................RRd",
        "RRd......................RRd",
        ".Rd......................Rd.",
    ], ["R": hood, "d": hoodDark, "l": hoodLight])
    drawDwarfBody(c, coat: coat, coatShade: coatShade)
    c.rect(13, 35, 4, 3, coat)                                                // the off arm
    // The bald dome, shining.
    c.pattern(18, 24, [
        "....OOOOOOOOOOOO....",
        "..OOOOOOOOOOOOOOOO..",
        ".OOOssOOOOOOOOOOOOS.",
        "OOOsOOOOOOOOOOOOOOOS",
    ], ["O": clawdOrange, "s": C(0xF2A888), "S": clawdShade])
    // The hood's fold over the shoulders, under the beard.
    c.pattern(14, 33, ["..RRRlRRRRRRRRRRRRRRRRlRRR..", "...dRRdRRdRRdRRdRRdRRdRRd..."], ["R": hood, "d": hoodDark, "l": hoodLight])
    // White tufts at the temples and white brows over the eyes.
    c.pattern(17, 28, ["WW..................WW", "WWs..WWW......WWW..sWW", "sW..................Ws"],
              ["W": white, "s": whiteShade])
    // The long beard, white, forking in two below the chest.
    c.pattern(18, 31, [
        "WW................WW",
        "WWW..............WWW",
        "WWWWWWWWWWWWWWWWWWWW",
        "WWWWWsWWWWWWWWsWWWWW",
        ".WWWWWWWWWWWWWWWWWW.",
        ".WWsWWWWWWWWWWWWsWW.",
        "..WWWWWWWsWWWWWWWW..",
        "..WWWWWW....WWWWWW..",
        "..WWWWWs....sWWWWW..",
        "..WWWWW......WWWWW..",
        "..WsWW........WWsW..",
        "..WWW..........WWW..",
        "..W..............W..",
    ], ["W": white, "s": whiteShade])
    c.rect(23, 33, 10, 1, whiteShade)                                         // the moustache's edge
    // The staff: planted at rest, swung with a long smear (it's heavy).
    let angle = min(20, p.melee ?? -90)
    drawHeavySmear(c, angle: angle, reach: 13, half: 3, trail: p.melee == nil ? [] : p.trail.map { min(20, $0) })
    prop(c, at: dwarfHand, angle: angle, drawStaff)
    c.rect(39, 35, 2, 3, coat); c.rect(41, 35, 2, 3, clawdOrange); c.px(41, 37, clawdShade)
}

/// Load Balin-cer's staff, pointing right from (20, 20) of a prop canvas: an iron ferrule at the butt, 6 px behind the
/// hand, a long wooden shaft, a gold band and a squared iron knob at the head, 16 px ahead.
private func drawStaff(_ s: PixelCanvas) {
    let wood = C(0x7A5230), woodDark = C(0x5A3A1E), iron = C(0x8A8E96), ironDark = C(0x5E626A)
    s.rect(14, 20, 2, 2, ironDark)
    s.rect(16, 20, 17, 1, wood); s.rect(16, 21, 17, 1, woodDark)
    for x in [19, 24, 29] { s.px(x, 20, woodDark) }
    s.rect(33, 19, 1, 4, C(0xC8A040))
    s.pattern(34, 18, [".II.", "IIIi", "IlIi", "IIIi", "IIIi", ".ii."], ["I": iron, "i": ironDark, "l": C(0xB8BCC4)])
}

// MARK: - Kill-i

/// Kill-i, the young archer: long dark-brown hair, loose to the shoulders and parted in the middle, no beard, just
/// stubble on the chin, so his whole face shows. A dark-brown leather coat over a dark-blue tunic (at the neck and in
/// the sleeves), a small quiver of grey-fletched arrows on his back and a short recurved dwarf bow held out in front.
/// Shooting, he nocks an arrow and draws the string back before each shot, the way Leggolas does.
private func drawKili(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6E4C30), coatShade = C(0x523822), coatLight = C(0x8A6240)
    let tunic = C(0x2E3E5E), tunicShade = C(0x22304A)
    let hair = C(0x3A2416), hairLight = C(0x56361E)
    drawDwarfLegs(c, p, trousers: C(0x2E2A30), boot: C(0x2A1E14), toe: C(0x40302A))
    c.oy += p.breathe
    // The quiver, on his back, the grey fletchings over his shoulder.
    c.pattern(11, 25, [
        "W.W...",
        ".WFW..",
        "..QQQ.",
        "..QQQq",
        "...QQq",
        "...QQQ",
        "...QQq",
        "....QQ",
    ], ["W": C(0xD8DCE0), "F": C(0x8A8E96), "Q": C(0x5A3A22), "q": C(0x40281A)])
    drawDwarfBody(c, coat: coat, coatShade: coatShade)
    c.rect(17, 33, 22, 1, clawdOrange); c.px(38, 33, clawdShade)             // a bare chin: the coat starts lower
    c.rect(17, 34, 22, 1, coatLight)
    c.pattern(25, 34, ["TTTTTT", ".TTTT."], ["T": tunic])                    // the tunic at the neck
    c.rect(17, 37, 22, 1, C(0x2A1C12)); c.px(27, 37, C(0xA8ACB4))          // the belt
    for i in 0..<4 { c.rect(19 + i * 3, 36 - i, 3, 1, C(0x2A1C12)) }          // the quiver strap
    c.rect(13, 35, 4, 3, tunic); c.px(13, 37, tunicShade)                     // the off arm
    // The stubble: a dark dusting on the jaw and chin.
    for (x, y) in [(20, 32), (35, 32), (21, 33), (23, 33), (25, 32), (27, 33), (29, 33), (31, 32), (33, 33), (26, 33), (30, 32)] {
        c.px(x, y, C(0x6A3A26))
    }
    // Long dark hair, parted in the middle, loose to the shoulders.
    c.pattern(15, 25, [
        ".......HHHHHHHHHHHH.......",
        "....HHHHHHHHhHHHHHHHH.....",
        "..HHHHhHHHHHhHHHHHHhHHHH..",
        ".HHHhHH............HhHHH..",
        "HHHh.................hHHH.",
        "HHHh.................hHHH.",
        "HHHh..................HHH.",
        "HHH...................hHH.",
        "HHh...................HHH.",
        ".Hh...................hH..",
        ".H.....................H..",
    ], ["H": hair, "h": hairLight])
    c.rect(27, 25, 2, 1, hair)
    // The short bow, held out; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    drawShortBow(c, pull: pull)
    c.rect(39, 35, 4, 2, tunic)
    c.rect(43, 35, 2, 3, clawdOrange)
    if nocked {
        let tail = 41 - pull
        c.rect(tail, 36, 48 - tail, 1, C(0x6A4A2A))
        c.px(48, 36, C(0xC8CCD4)); c.px(49, 36, C(0xE8ECF4))
        c.px(tail, 35, C(0x8A8E96)); c.px(tail, 37, C(0x8A8E96))
        c.rect(tail - 1, 36, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// A short recurved dwarf bow gripped at (45, 36), 13 px tall, its tips curling forward, the string back at x 41 and
/// drawn back `pull` pixels more at the middle.
private func drawShortBow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x6A4428), limbDark = C(0x4A2E1A), grip = C(0x2A1C12), horn = C(0xD8C8A8), string = C(0xE0E0E8)
    for y in 30...42 where y + c.oy <= 43 {
        let d = abs(y - 36)
        let x = d <= 2 ? 45 : d <= 4 ? 44 : d == 5 ? 43 : 44
        c.px(x, y, d <= 1 ? grip : d == 6 ? horn : d % 2 == 0 ? limbDark : limb)
    }
    for y in 31...41 where y + c.oy <= 43 {
        let d = Double(abs(y - 36)) / 5
        c.px(42 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

// MARK: - File-i

/// File-i, Kill-i's brother: thick blond hair to the shoulders with a small braid at each temple, and a blond
/// moustache whose ends are braided down past his chin, silver clasps near the tips, a little blond beard between them.
/// A brown-gold coat under a dark leather vest, and two short swords with brass hilts, one in each fist: they rest
/// raised in a V, and in a fight the off-hand blade mirrors the swing of the other.
private func drawFili(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x9A7036), coatShade = C(0x76522A), coatLight = C(0xB88A48)
    let vest = C(0x3A2A1E), vestLight = C(0x4E3A2A)
    let hair = C(0xE0B04E), hairShade = C(0xB88A34), hairLight = C(0xF4D47A), clasp = C(0xC8CCD4)
    drawDwarfLegs(c, p, trousers: C(0x4A3A28), boot: C(0x2E2016), toe: C(0x46342A))
    c.oy += p.breathe
    drawDwarfBody(c, coat: coat, coatShade: coatShade)
    c.rect(17, 33, 22, 1, coatLight)
    c.rect(21, 33, 14, 6, vest); c.rect(21, 33, 1, 6, vestLight); c.rect(34, 33, 1, 6, vestLight)
    c.rect(17, 37, 22, 1, C(0x2A1C12)); c.px(27, 37, C(0xC8A040))           // the belt and its brass buckle
    // Thick blond hair to the shoulders, a braid at each temple.
    c.pattern(15, 25, [
        "......HHHHHHHHHHHHHH......",
        "...HHHHlHHHHHHHHHlHHHH....",
        ".HHHHHHHHHHHHHHHHHHHHHHH..",
        ".HHhHHHHlHHHHHHHHHlHHhHHH.",
        "HHHhHHHH.H......H.HHHhHHH.",
        "HHHh.b..............b.hHH.",
        "HHhH.H..............H.HhH.",
        "HHhH.b..............b.HhH.",
        "HHhH.H..............H.HhH.",
        "HhH..c..............c..hH.",
        ".hH....................H..",
        ".H.....................H..",
    ], ["H": hair, "h": hairShade, "l": hairLight, "b": hairShade, "c": clasp])
    // The moustache, braided down past his chin, and the short beard between the braids.
    c.pattern(21, 32, [
        "..HHHHHHHHHH..",
        ".HHHlHHHHlHHH.",
        ".Hh..HHHH..hH.",
        ".hH...hH...Hh.",
        ".Hh........hH.",
        ".cc........cc.",
        ".hH........Hh.",
        "..h........h..",
    ], ["H": hair, "h": hairShade, "l": hairLight, "c": clasp])
    // Two short swords: the near one swung along the stroke, the off-hand one mirroring it; up in a V at rest.
    let angle = min(28, p.melee ?? -50)
    let off = (180 - angle).truncatingRemainder(dividingBy: 360)
    let offHand = (x: 14.5, y: 36.5)
    if p.melee != nil {
        drawSwordSmear(c, at: offHand, reach: 13, trail: p.trail.map { 180 - min(28, $0) })
        drawSwordSmear(c, at: dwarfHand, reach: 13, trail: p.trail.map { min(28, $0) })
    }
    prop(c, at: offHand, angle: off, drawShortSword)
    c.rect(15, 35, 2, 3, coat); c.rect(13, 35, 2, 3, clawdOrange); c.px(13, 37, clawdShade)   // the off fist
    prop(c, at: dwarfHand, angle: angle, drawShortSword)
    c.rect(39, 35, 2, 3, coat); c.rect(41, 35, 2, 3, clawdOrange); c.px(41, 37, clawdShade)
}

/// One of File-i's short swords, pointing right from (20, 20) of a prop canvas: a brass pommel, a leather grip, a
/// brass crossguard and a broad straight 11 px blade.
private func drawShortSword(_ s: PixelCanvas) {
    let brass = C(0xC8A040), blade = C(0xC8D0D8), edge = C(0x8A929C)
    s.px(16, 20, brass); s.rect(17, 20, 4, 2, C(0x3A2818))
    s.rect(21, 18, 1, 6, brass); s.px(21, 18, C(0xE0C060))
    s.rect(22, 20, 11, 1, blade); s.rect(22, 21, 10, 1, edge); s.px(33, 20, C(0xE8EEF4))
}

// MARK: - Groan

/// Groan, Gimmie's father, and plainly so: the same red-orange beard, but older and rounder. A tall fur hat with ear
/// flaps and a gold band round it, bushy grizzled brows, and a huge round bushy beard, red going grey, that hides his
/// chest and spills out past his sides, no braids. Dark-green sleeves with gold arm rings (he's fond of gold), and a
/// heavy single-bladed axe with a bearded crescent blade, a back spike and a gold rune on it, held upright at rest.
private func drawGloin(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x8A6E52), furDark = C(0x6A5440), furLight = C(0xA88C6E), gold = C(0xD8B040)
    let beard = C(0xB04A22), beardDark = C(0x7E3016), beardLight = C(0xD0683A), grey = C(0xA89C96), greyLight = C(0xCCC4BE)
    let sleeve = C(0x3A5230), sleeveShade = C(0x2A3C22)
    drawDwarfLegs(c, p, trousers: C(0x4A3A2A), boot: C(0x3A2A1A), toe: C(0x4E3A26))
    c.oy += p.breathe
    drawDwarfBody(c, coat: sleeve, coatShade: sleeveShade)
    // The fur hat: tall and round, a gold band, ear flaps down the cheeks.
    c.pattern(16, 21, [
        "......FFFfFFFFfFFFF.....",
        "...FFfFFFFFFlFFFFFfFF...",
        "..FFFFFFlFFFfFFFFFFFFF..",
        ".FfFFFFFFFFFFFFFlFFFfFF.",
        ".FFFFfFFFFFFFFFFFFFFFFF.",
        ".GGGGGGGGGGgGGGGGGGGGGG.",
        "DDDDDDDDDDDDDDDDDDDDDDDD",
        "DDD..................DDD",
        "DfD..................DfD",
        ".D....................D.",
    ], ["F": fur, "f": furDark, "l": furLight, "D": furDark, "G": gold, "g": C(0xC83A2A)])
    // Bushy brows, red going grey.
    c.pattern(20, 29, ["gHHHg......gHHHg", ".H...........H.."], ["H": beard, "g": grey])
    // The beard: great and round, past his sides, red shot through with grey.
    c.pattern(14, 31, [
        "...HH.................HH....",
        "..HHHd...............dHHH...",
        ".HHgHHHHdHHHHHHHHHHdHHHHgH..",
        "HHHgHHHHHlHHggHHHlHHHHHgHHHH",
        "HHHHHHgHHHHHGgGHHHHHgHHHHHHH",
        "HdHHHHHHHHHgHHHgHHHHHHHHHdHH",
        "HHHHHlHHHgHHHHHHHHHgHlHHHHHH",
        "HHHgHHHHHHHHHgGHHHHHHHHHgHHH",
        ".HHHHHHgHHHHHHHHHHHgHHHHHHd.",
        "..HdHHHHHHHlHHHHHHHHHHHdHH..",
        "....HHHgHHHHHHHHHHgHHHHH....",
        ".......dHHHHgHHHHHHd........",
    ], ["H": beard, "d": beardDark, "l": beardLight, "g": grey, "G": greyLight])
    c.pattern(22, 33, ["dddGGddddddd"], ["d": beardDark, "G": grey])          // the moustache's edge
    // The off arm out past the beard, a gold ring round the wrist.
    c.rect(11, 35, 3, 3, sleeve); c.rect(13, 35, 1, 3, gold); c.px(11, 37, sleeveShade)
    // The axe, upright at rest, swung with a long smear (it's heavy); the floor stops a low stroke.
    let angle = min(5, p.melee ?? -80)
    drawHeavySmear(c, angle: angle, reach: 9, half: 6, trail: p.melee == nil ? [] : p.trail.map { min(5, $0) })
    prop(c, at: dwarfHand, angle: angle, drawGloinAxe)
    c.rect(40, 35, 1, 3, gold); c.rect(41, 35, 2, 3, C(0x5A3A1E)); c.px(41, 37, C(0x3E2812))   // the ring and the glove
}

/// Groan's axe, pointing right from (20, 20) of a prop canvas: a long haft with an iron butt, an iron socket with a
/// spike out of its back, and one great bearded crescent blade on the other side, a gold rune set in it.
private func drawGloinAxe(_ s: PixelCanvas) {
    let haft = C(0x5A3A1E), haftLight = C(0x7A5230), iron = C(0x9AA4B0), ironDark = C(0x6A727E), edge = C(0xD8E0E8)
    s.rect(14, 20, 19, 1, haft); s.rect(14, 21, 19, 1, C(0x40280E)); s.rect(18, 20, 10, 1, haftLight)
    s.rect(13, 20, 1, 2, ironDark)
    s.pattern(23, 18, [
        "......s......",
        ".....sss.....",
        "....KKKKK....",
        "....KKKKK....",
        "....BBBBb....",
        "...BBGGBBb...",
        "..BBBBGBBBb..",
        ".BBBBBBBBBBb.",
        "BBBBBBBBBBBBb",
        "EEEEEEEEEEEEE",
    ], ["s": ironDark, "K": ironDark, "B": iron, "b": ironDark, "E": edge, "G": C(0xD8B040)])
}

// MARK: - Shared helpers

/// Short thick dwarf legs in heavy boots, the toes forward (Gimmie's), folded under when sitting.
private func drawDwarfLegs(_ c: PixelCanvas, _ p: Pose, trousers: Px, boot: Px, toe: Px) {
    if seatedPose {
        for lx in [19, 23, 32, 36] { c.rect(lx - 1, 39, 4, 1, boot); c.px(lx + 2, 39, toe) }
        return
    }
    for (i, lx) in [19, 23, 32, 36].enumerated() {
        let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
        c.rect(lx, 37, 3, bottom - 38, trousers)
        c.rect(lx, bottom - 1, 3, 2, boot); c.px(lx + 3, bottom, boot)
        c.px(lx, bottom - 1, toe)
    }
}

/// A dwarf's body: broader than Clawd's and lower down (Gimmie's), the ink eyes, and the coat from the chin down.
private func drawDwarfBody(_ c: PixelCanvas, coat: Px, coatShade: Px) {
    c.rect(17, 28, 22, 11, clawdOrange)
    c.rect(38, 28, 1, 11, clawdShade)
    c.rect(22, 30, 2, 3, ink); c.rect(32, 30, 2, 3, ink)
    c.rect(17, 33, 22, 6, coat)
    c.rect(38, 33, 1, 6, coatShade); c.rect(17, 38, 22, 1, coatShade)
}

/// The pale smear behind a fast sword stroke from `at`, `reach` pixels long.
private func drawSwordSmear(_ c: PixelCanvas, at h: (x: Double, y: Double), reach: Double, trail: [Double]) {
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(h.x + u.x * 4, h.y + u.y * 4, h.x + u.x * reach, h.y + u.y * reach, core: C(0xE8EEF4),
                   glow: C(0xA8B4C0), coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
}

/// The long smear behind a heavy weapon's stroke (Gimmie's): across the head, `reach` out from the hand, `half` wide.
private func drawHeavySmear(_ c: PixelCanvas, angle: Double, reach: Double, half: Double, trail: [Double]) {
    for (i, a) in heavySmear(angle, trail).enumerated() {
        let u = unit(a), n = (x: -u.y, y: u.x), fade: Double = 0.38 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let m = (x: dwarfHand.x + u.x * reach, y: dwarfHand.y + u.y * reach)
        c.glowLine(m.x - n.x * half, m.y - n.y * half, m.x + n.x * half, m.y + n.y * half, core: C(0xD8E0E8),
                   glow: C(0x9AA4B0), coreR: 0.6, glowR: 1.4, strength: fade)
    }
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`. Nothing is drawn below the floor (row 43).
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h where y0 + y + c.oy <= 43 {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a sword's. Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}
