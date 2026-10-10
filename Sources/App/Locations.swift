import AppKit

// Window-mode backdrops: one Star Wars location per character, drawn as pixel art in code.
// The first-spawned Claude decides where the crew is (or pick one from the Location menu).
// Every scene gets a canvas of w×h pixels whose bottom `floorRows` rows are the ground the crew stands on.

enum Location: String, CaseIterable {
    case cantina, deathStar, sarlaccPit, jabbasPalace, supremacy, theed, emperorThrone, geonosis, naboo, executor
    case larsFarm, obiWanHut, sandcrawler, dagobah, falcon, tantive, tuskenDesert, jakku, jediCouncil, endor, hoth, rancorPit

    var name: String {
        switch self {
        case .cantina: return "Mos Eisley Cantina"
        case .deathStar: return "Death Star"
        case .sarlaccPit: return "Great Pit of Carkoon"
        case .jabbasPalace: return "Jabba's Palace"
        case .supremacy: return "Supremacy Throne Room"
        case .theed: return "Theed Generator Complex"
        case .emperorThrone: return "Death Star II Throne Room"
        case .geonosis: return "Geonosis"
        case .naboo: return "Plains of Naboo"
        case .executor: return "Executor Bridge"
        case .larsFarm: return "Lars Homestead"
        case .obiWanHut: return "Obi-Wan's Hut"
        case .sandcrawler: return "Jawa Sandcrawler"
        case .dagobah: return "Dagobah"
        case .falcon: return "Millennium Falcon"
        case .tantive: return "Tantive IV"
        case .tuskenDesert: return "Jundland Wastes"
        case .jakku: return "Jakku"
        case .jediCouncil: return "Jedi Council Chamber"
        case .endor: return "Forest Moon of Endor"
        case .hoth: return "Battle of Hoth"
        case .rancorPit: return "Rancor Pit"
        }
    }

    static func home(of leader: Leader) -> Location {
        switch leader {
        case .vader: return .deathStar
        case .boba: return .sarlaccPit
        case .jabba, .gamorrean: return .jabbasPalace
        case .trooper: return .cantina
        case .kylo: return .supremacy
        case .maul: return .theed
        case .emperor: return .emperorThrone
        case .dooku: return .geonosis
        case .rogr: return .naboo
        case .ig88: return .executor
        case .atst: return .endor
        case .atat: return .hoth
        case .rancor: return .rancorPit
        case .greedo: return .cantina
        }
    }

    static func home(of hero: Companion) -> Location {
        switch hero {
        case .luke: return .larsFarm
        case .obiwan: return .obiWanHut
        case .jawa, .r2d2: return .sandcrawler
        case .yoda: return .dagobah
        case .han, .chewie: return .falcon
        case .leia, .c3po: return .tantive
        case .quigon: return .tuskenDesert
        case .rey: return .jakku
        case .mace, .ahsoka: return .jediCouncil
        case .ewok: return .endor
        case .tauntaun: return .hoth
        }
    }

    /// Background tint for the card area, so the whole window feels like the place.
    var panel: NSColor {
        func c(_ hex: UInt32) -> NSColor {
            NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                    blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
        }
        switch self {
        case .cantina, .obiWanHut: return c(0x2B2119)
        case .deathStar, .emperorThrone, .executor: return c(0x16181D)
        case .sarlaccPit, .tuskenDesert, .larsFarm, .jakku: return c(0x2E2418)
        case .jabbasPalace: return c(0x241A12)
        case .supremacy: return c(0x2A0A0D)
        case .theed: return c(0x141A22)
        case .geonosis: return c(0x2E1712)
        case .naboo: return c(0x14231A)
        case .sandcrawler: return c(0x261A12)
        case .dagobah: return c(0x111C15)
        case .falcon: return c(0x1E1F21)
        case .tantive: return c(0x1C2229)
        case .jediCouncil: return c(0x22180F)
        case .endor: return c(0x15200F)
        case .hoth: return c(0x1C2430)
        case .rancorPit: return c(0x1A140F)
        }
    }

    /// The parts of the scene that never move (cached per window size).
    func drawStatic(_ c: PixelCanvas, floorRows f: Int) {
        let g = c.h - f    // ground line
        switch self {
        case .cantina: Cantina.drawRoom(c, floorRows: f)
        case .deathStar: Scenes.deathStar(c, g)
        case .sarlaccPit: Scenes.sarlaccPit(c, g)
        case .jabbasPalace: Scenes.jabbasPalace(c, g)
        case .supremacy: Scenes.supremacy(c, g)
        case .theed: Scenes.theed(c, g)
        case .emperorThrone: Scenes.emperorThrone(c, g)
        case .geonosis: Scenes.geonosis(c, g)
        case .naboo: Scenes.naboo(c, g)
        case .executor: Scenes.executor(c, g)
        case .larsFarm: Scenes.larsFarm(c, g)
        case .obiWanHut: Scenes.obiWanHut(c, g)
        case .sandcrawler: Scenes.sandcrawler(c, g)
        case .dagobah: Scenes.dagobah(c, g)
        case .falcon: Scenes.falcon(c, g)
        case .tantive: Scenes.tantive(c, g)
        case .tuskenDesert: Scenes.tuskenDesert(c, g)
        case .jakku: Scenes.jakku(c, g)
        case .jediCouncil: Scenes.jediCouncil(c, g)
        case .endor: Scenes.endor(c, g)
        case .hoth: Scenes.hoth(c, g)
        case .rancorPit: Scenes.rancorPit(c, g)
        }
    }

    /// The moving bits, drawn every frame on a transparent canvas of the same size.
    func drawAnimated(_ c: PixelCanvas, floorRows f: Int, t: Double) {
        let g = c.h - f
        switch self {
        case .cantina:
            // Tonight's band: the Modal Nodes or, on some nights, the Max Rebo Band (re-rolled on each visit).
            if Cantina.maxReboTonight { Scenes.maxReboBand(c, g - 4, t: t, at: 2) } else { Cantina.drawBand(c, floorRows: f, t: t) }
            Cantina.drawBarCrowd(c, floorRows: f, t: t)
        case .deathStar, .executor: Scenes.blinkLights(c, g, t: t, seed: self == .deathStar ? 1 : 2)
        case .sarlaccPit: Scenes.sarlaccTentacles(c, g, t: t)
        case .jabbasPalace: Scenes.jabbaLamps(c, g, t: t); Scenes.maxReboBand(c, g, t: t)
        case .theed: Scenes.laserGates(c, g, t: t)
        case .emperorThrone: Scenes.spaceBattle(c, g, t: t)
        case .dagobah: Scenes.swampFog(c, g, t: t)
        case .falcon: Scenes.dejarik(c, g, t: t)
        case .sandcrawler: Scenes.crawlerLights(c, g, t: t)
        case .obiWanHut: Scenes.obiWanHologram(c, g, t: t)
        case .hoth: Scenes.snowfall(c, g, t: t)
        case .rancorPit: Scenes.grateLight(c, g, t: t)
        default: break
        }
    }
}

// MARK: - Drawing helpers

func lerp(_ a: Px, _ b: Px, _ t: Double) -> Px {
    let k = max(0, min(1, t))
    return Px(r: UInt8(Double(a.r) + (Double(b.r) - Double(a.r)) * k), g: UInt8(Double(a.g) + (Double(b.g) - Double(a.g)) * k),
              b: UInt8(Double(a.b) + (Double(b.b) - Double(a.b)) * k), a: UInt8(Double(a.a) + (Double(b.a) - Double(a.a)) * k))
}

extension PixelCanvas {
    /// Vertical gradient from row y0 (top colour) to y1 (bottom colour), quantised into bands like old pixel art.
    func gradient(_ y0: Int, _ y1: Int, _ top: Px, _ bottom: Px, bands: Int = 6) {
        guard y1 > y0 else { return }
        for y in y0..<y1 {
            let k = (Double(y - y0) / Double(y1 - y0) * Double(bands)).rounded(.down) / Double(bands)
            rect(0, y, w, 1, lerp(top, bottom, k))
        }
    }

    func circle(_ cx: Int, _ cy: Int, _ r: Int, _ col: Px) {
        guard r > 0 else { px(cx, cy, col); return }
        for dy in -r...r {
            let half = Int((Double(r * r - dy * dy)).squareRoot().rounded())
            rect(cx - half, cy + dy, half * 2 + 1, 1, col)
        }
    }

    func ellipse(_ cx: Int, _ cy: Int, _ rx: Int, _ ry: Int, _ col: Px) {
        guard rx > 0, ry > 0 else { return }
        for dy in -ry...ry {
            let k = 1 - Double(dy * dy) / Double(ry * ry)
            let half = Int((Double(rx) * k.squareRoot()).rounded())
            rect(cx - half, cy + dy, half * 2 + 1, 1, col)
        }
    }

    func stars(_ y0: Int, _ y1: Int, density: Int = 40, seed: Int = 0, x0: Int = 0, x1: Int? = nil) {
        let xe = x1 ?? w
        guard y1 > y0, xe > x0 else { return }
        for i in 0..<((xe - x0) * (y1 - y0) / density) {
            let x = x0 + Int(noise(i * 3 + seed * 1000) * Double(xe - x0))
            let y = y0 + Int(noise(i * 3 + 1 + seed * 1000) * Double(y1 - y0))
            px(x, y, white.alpha(noise(i * 3 + 2 + seed * 1000) > 0.8 ? 0.95 : 0.5))
        }
    }

    /// Rolling dunes or hills: fills from a wavy line down to `bottom`.
    func dunes(base: Int, amp: Double, freq: Double, phase: Double, bottom: Int, _ col: Px, shade: Px? = nil) {
        for x in 0..<w {
            let top = base - Int((sin(Double(x) * freq + phase) * 0.6 + sin(Double(x) * freq * 2.3 + phase * 1.7) * 0.4) * amp)
            if top < bottom { rect(x, top, 1, bottom - top, col) }
            if let shade, top < bottom { px(x, top, shade) }
        }
    }

    /// Ground strip with a highlighted edge and speckles.
    func ground(_ g: Int, _ col: Px, edge: Px, speck: Px, seed: Int = 0) {
        rect(0, g, w, h - g, col)
        rect(0, g, w, 1, edge)
        for i in 0..<(w * (h - g) / 6) {
            px(Int(noise(i * 11 + 3 + seed) * Double(w)), g + 1 + Int(noise(i * 11 + 4 + seed) * Double(max(1, h - g - 1))), speck)
        }
    }
}

// MARK: - The scenes

enum Scenes {
    // Vader — a Death Star corridor: grey panels, light strips, and a viewport onto space.
    static func deathStar(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x4A4E57), C(0x2C2F36), bands: 4)
        c.rect(0, 0, c.w, 5, C(0x1E2025))
        for y in stride(from: 9, to: g - 4, by: 9) { c.rect(0, y, c.w, 1, C(0x23262C)) }
        for x in stride(from: 0, to: c.w, by: 24) { c.rect(x, 5, 1, g - 5, C(0x23262C)) }
        // wall light panels
        for x in stride(from: 6, to: c.w, by: 24) {
            for y in stride(from: 12, to: g - 10, by: 18) {
                c.rect(x, y, 10, 3, C(0x9EA6B2)); c.rect(x + 1, y + 1, 8, 1, C(0xE8F0FF))
            }
        }
        // viewport with a planet
        let vx = c.w * 2 / 3, vw = min(70, c.w / 3), vh = max(14, g / 2)
        c.rect(vx - 2, 8, vw + 4, vh + 4, C(0x15171B))
        c.rect(vx, 10, vw, vh, C(0x05060A))
        c.stars(10, 10 + vh, density: 25, seed: 3, x0: vx, x1: vx + vw)
        c.circle(vx + vw * 3 / 4, 10 + vh * 2 / 3, max(4, vh / 3), C(0x3A6FB0))
        c.circle(vx + vw * 3 / 4 - 1, 10 + vh * 2 / 3 - 1, max(3, vh / 3 - 2), C(0x5C92D6))
        for x in stride(from: vx + vw / 3, to: vx + vw, by: vw / 3) { c.rect(x, 10, 1, vh, C(0x15171B)) }
        c.ground(g, C(0x1C1E23), edge: C(0x6E7480), speck: C(0x2A2D33), seed: 1)
        for x in stride(from: 0, to: c.w, by: 12) { c.rect(x, g + 2, 6, 1, C(0x30343B)) }
    }

    static func blinkLights(_ c: PixelCanvas, _ g: Int, t: Double, seed: Int) {
        let n = max(4, c.w / 30)
        for i in 0..<n {
            let x = Int(noise(i * 5 + seed * 77) * Double(c.w - 6)) + 2
            let y = g - 5 - Int(noise(i * 5 + 1 + seed * 77) * 6)
            let on = noise(Int(t * 3) + i * 13 + seed) > 0.4
            let col = [C(0xE0303A), C(0x3BD15A), C(0x3A7BEA), C(0xFFD23D)][i % 4]
            c.rect(x, y, 2, 1, on ? col : col.alpha(0.25))
        }
    }

    // Boba — the Great Pit of Carkoon: dunes, Jabba's sail barge, and the sarlacc.
    static func sarlaccPit(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x9FC3E0), C(0xF2DCB0), bands: 5)
        c.dunes(base: g - 10, amp: 3, freq: 0.05, phase: 1, bottom: g, C(0xD8B47A), shade: C(0xE8C892))
        // the sail barge (Khetanna), hovering in the distance
        let bx = c.w / 5, by = max(14, g / 3)
        c.rect(bx, by, 46, 5, C(0x8A6A48)); c.rect(bx + 4, by + 5, 38, 2, C(0x6E5236))
        c.rect(bx - 3, by + 1, 3, 3, C(0x8A6A48))
        for sx in [bx + 12, bx + 26] { c.rect(sx, by - 12, 1, 12, C(0x5A4636)); c.rect(sx + 1, by - 11, 8, 9, C(0xE6D6B4)) }
        c.rect(bx + 4, by + 9, 40, 1, C(0xC9A87A, 0.4))           // shadow on the sand
        // the pit
        let px = c.w * 3 / 4
        c.ellipse(px, g - 3, 26, 5, C(0xC09A62))
        c.ellipse(px, g - 3, 18, 3, C(0x8A6A40))
        c.ellipse(px, g - 3, 8, 2, C(0x3A2416))
        for i in 0..<6 { c.px(px - 6 + i * 2, g - 4, C(0xF4EEDC)) }  // beak teeth
        c.ground(g, C(0xDCB97E), edge: C(0xEACB94), speck: C(0xC9A468), seed: 2)
    }

    static func sarlaccTentacles(_ c: PixelCanvas, _ g: Int, t: Double) {
        let px = Double(c.w * 3 / 4)
        for i in 0..<3 {
            let side = Double(i - 1)
            let base = (px + side * 5, Double(g - 3))
            let sway = sin(t * 2 + Double(i)) * 3
            let tip = (base.0 + side * 6 + sway, base.1 - 7 - cos(t * 1.7 + Double(i)) * 2)
            c.glowLine(base.0, base.1, tip.0, tip.1, core: C(0x8A5A3A), glow: C(0, 0), coreR: 0.8, glowR: 0.9)
        }
    }

    // Jabba / Gamorrean — the throne room in Return of the Jedi: smoky amber sandstone with rounded alcoves and light
    // falling from vents above, Han Solo frozen in carbonite on the wall, Jabba's tiered dais with cushions and the
    // hookah, and the round trapdoor over the rancor pit in front of it.
    static func jabbasPalace(_ c: PixelCanvas, _ g: Int) {
        // Walls: dark, smoky ceiling down to warm sandstone.
        c.gradient(0, g, C(0x1A110B), C(0x6E4C30), bands: 7)
        for i in 0..<(c.w * g / 22) {   // plaster grain
            c.px(Int(noise(i * 9) * Double(c.w)), Int(noise(i * 9 + 1) * Double(g)), C(0x2A1C12, 0.35))
        }
        // A ledge running along the back wall.
        c.rect(0, g - 34, c.w, 2, C(0x8A6444, 0.55)); c.rect(0, g - 32, c.w, 1, C(0x2A1C12, 0.6))

        // Rounded alcoves, softly lit from inside (between the throne end and the band).
        var ax = 150
        while ax + 26 < c.w - 70 {
            let top = g - 28, r = 9
            for y in top..<(g - 2) {
                var half = r
                if y - top < r { let dy = Double(r - (y - top)); half = Int((Double(r * r) - dy * dy).squareRoot()) }
                let k = Double(y - top) / Double(g - 2 - top)
                c.rect(ax + r - half, y, half * 2, 1, lerp(C(0x2A1A10), C(0x5A3A22), k))
            }
            c.ellipse(ax + r, g - 8, 6, 3, C(0xFFB050, 0.10))      // the glow of whatever's burning in there
            ax += 48
        }

        // Vents high in the wall, with dusty light shafts falling from them.
        for (i, vx) in [96, 210, 300].enumerated() where vx < c.w - 70 {
            c.ellipse(vx, 6, 5, 2, C(0xFFD9A0, 0.55)); c.ellipse(vx, 6, 3, 1, C(0xFFF0D0, 0.8))
            for y in 8..<(g - 2) {
                let spread = 3 + (y - 8) / 4, shift = (y - 8) / 3 * (i % 2 == 0 ? 1 : -1)
                c.rect(vx - spread + shift, y, spread * 2, 1, C(0xFFD9A0, 0.05))
            }
        }

        // Han Solo in carbonite, hanging on the wall.
        let hx = 112, hy = g - 40
        c.rect(hx - 1, hy - 1, 20, 34, C(0x3A3530))                   // shadow / mount
        c.rect(hx, hy, 18, 32, C(0x5E6266))                            // the slab
        c.rect(hx, hy, 18, 1, C(0x8C9196)); c.rect(hx, hy, 1, 32, C(0x7A7F84))
        c.rect(hx + 17, hy, 1, 32, C(0x44474B)); c.rect(hx, hy + 31, 18, 1, C(0x44474B))
        c.rect(hx + 2, hy + 2, 14, 28, C(0x6A6E72))                    // the relief panel
        c.circle(hx + 9, hy + 9, 3, C(0x7E8388)); c.px(hx + 8, hy + 8, C(0x9AA0A5))   // face
        c.rect(hx + 3, hy + 4, 2, 5, C(0x7E8388)); c.rect(hx + 13, hy + 4, 2, 5, C(0x7E8388))  // hands up
        c.rect(hx + 6, hy + 13, 7, 12, C(0x767A7F)); c.rect(hx + 7, hy + 25, 2, 4, C(0x767A7F)); c.rect(hx + 10, hy + 25, 2, 4, C(0x767A7F))
        c.rect(hx + 5, hy + 12, 9, 1, C(0x9AA0A5, 0.6))
        for (i, col) in [C(0xFF5A3A), C(0x6CFF7A), C(0xFFD24A)].enumerated() { c.px(hx + 4 + i * 2, hy + 29, col) }   // the control panel

        // Jabba's dais: two curved tiers, cushions and the hookah.
        func tier(_ x0: Int, _ w: Int, _ top: Int, _ h: Int, _ face: Px, _ lip: Px) {
            for y in top..<(top + h) {
                let dy = Double(y - top) / Double(max(1, h - 1))
                let curve = Int((1 - dy) * 4)                         // rounded front edge
                c.rect(x0, y, w - curve, 1, face)
            }
            c.rect(x0, top, w - 4, 1, lip)
        }
        tier(0, 84, g - 6, 6, C(0x5A3E28), C(0x8A6444))
        tier(0, 66, g - 12, 6, C(0x6A4A30), C(0x9A7452))
        c.rect(8, g - 15, 18, 3, C(0x8E2A1E)); c.rect(8, g - 15, 18, 1, C(0xB8452E))   // cushions
        c.rect(28, g - 14, 12, 2, C(0x7A5A1E)); c.rect(28, g - 14, 12, 1, C(0xA88A3A))
        // the hookah: base, glass bowl, stem, and a hose curling back toward the throne
        let kx = 52
        c.rect(kx - 3, g - 14, 7, 2, C(0x8A6A2A))
        c.ellipse(kx, g - 18, 3, 3, C(0x7AB0A0, 0.85)); c.px(kx - 1, g - 19, C(0xD8F0E8))
        c.rect(kx, g - 30, 1, 10, C(0xC9A44A)); c.ellipse(kx, g - 31, 2, 1, C(0xE0B85A))
        for i in 0..<14 { c.px(kx - 2 - i, g - 22 + Int(sin(Double(i) * 0.45) * 3), C(0x6A3A2A)) }

        // Floor, and the round trapdoor over the rancor pit in front of the dais.
        c.ground(g, C(0x5A4230), edge: C(0x8A6444), speck: C(0x4A3424), seed: 3)
        let tx = 104, ty = g + (c.h - g) / 2
        c.ellipse(tx, ty, 17, max(2, (c.h - g) / 2 - 1), C(0x2A1C12))
        c.ellipse(tx, ty, 15, max(1, (c.h - g) / 2 - 2), C(0x120B07))
        for i in stride(from: tx - 14, through: tx + 14, by: 3) { c.rect(i, ty - (c.h - g) / 2 + 2, 1, max(1, c.h - g - 4), C(0x8A7660)) }
    }

    /// Jabba's hanging braziers (flickering) and smoke drifting up from the hookah.
    static func jabbaLamps(_ c: PixelCanvas, _ g: Int, t: Double) {
        for (i, x) in [78, 176, 268].enumerated() where x < c.w - 70 {
            let f = noise(Int(t * 9) + i * 7)
            c.rect(x, 0, 1, g - 44, C(0x2A1C12))                       // chain
            c.rect(x - 3, g - 44, 7, 2, C(0x6E4A24)); c.rect(x - 2, g - 42, 5, 1, C(0x4A3018))
            c.rect(x - 1, g - 47, 3, 3, C(0xFF8A2A)); c.px(x + (f > 0.5 ? 1 : 0), g - 48, C(0xFFE27A))
            c.circle(x, g - 45, 7, C(0xFF9A2A, 0.07 + f * 0.05))
        }
        // hookah smoke: a few soft puffs rising and drifting
        for i in 0..<4 {
            let p = (t * 0.25 + Double(i) * 0.25).truncatingRemainder(dividingBy: 1)
            let y = g - 32 - Int(p * 26), x = 52 + Int(sin(p * 5 + Double(i)) * 4 + p * 8)
            c.circle(x, y, 1 + Int(p * 3), C(0xD8CFC0, 0.18 * (1 - p)))
        }
    }

    static func torches(_ c: PixelCanvas, _ g: Int, t: Double) {
        for (i, x) in stride(from: 52, to: c.w - 4, by: 52).enumerated() {
            let f = noise(Int(t * 10) + i * 7)
            c.rect(x, g - 22, 2, 4, C(0x3A2C22))
            c.rect(x, g - 25, 2, 3, C(0xFF9A2A))
            c.px(x + (f > 0.5 ? 1 : 0), g - 26, C(0xFFE27A))
            c.circle(x + 1, g - 23, 5, C(0xFF9A2A, 0.08 + f * 0.05))
        }
    }

    // Kylo — Snoke's throne room on the Supremacy: red curtains and a black mirrored floor.
    static func supremacy(_ c: PixelCanvas, _ g: Int) {
        c.rect(0, 0, c.w, g, C(0xA8111A))
        for x in stride(from: 0, to: c.w, by: 7) {
            c.rect(x, 0, 2, g, C(0x7E0C13))
            c.rect(x + 3, 0, 1, g, C(0xC21C26))
        }
        // the throne and two Praetorian guards
        let tx = c.w / 2
        c.rect(tx - 6, g - 18, 12, 18, C(0x111114)); c.rect(tx - 8, g - 4, 16, 4, C(0x1A1A1F))
        for gx in [tx - 40, tx + 34] {
            c.rect(gx, g - 16, 6, 16, C(0xC8202A)); c.rect(gx + 1, g - 19, 4, 3, C(0xC8202A))
            c.rect(gx + 6, g - 22, 1, 20, C(0x8A8F9C))
        }
        c.rect(0, g, c.w, c.h - g, C(0x0C0B0D))
        c.rect(0, g, c.w, 1, C(0x3A0A0E))
        for x in stride(from: 0, to: c.w, by: 7) { c.rect(x + 3, g + 1, 1, c.h - g - 1, C(0x5A0C12, 0.6)) }   // reflections
    }

    // Maul — the Theed generator complex: catwalks, pipes, and the laser gates.
    static func theed(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x1A2230), C(0x2E3A4C), bands: 5)
        for y in [g / 3, g * 2 / 3] {
            c.rect(0, y, c.w, 3, C(0x48546A)); c.rect(0, y, c.w, 1, C(0x7A889E))
            for x in stride(from: 4, to: c.w, by: 10) { c.rect(x, y + 3, 1, 5, C(0x3A4456)) }
        }
        for x in stride(from: 12, to: c.w, by: 40) {
            c.rect(x, 0, 4, g, C(0x3A4456)); c.rect(x + 1, 0, 1, g, C(0x5A6A82))
        }
        // the laser corridor at the back, with its round frames
        let lx = c.w * 3 / 5
        for i in 0..<4 { c.rect(lx + i * 12, g - 26, 3, 26, C(0x56647C)) }
        c.ground(g, C(0x262C38), edge: C(0x8A98B0), speck: C(0x2E3644), seed: 4)
    }

    static func laserGates(_ c: PixelCanvas, _ g: Int, t: Double) {
        let lx = c.w * 3 / 5
        let on = (t.truncatingRemainder(dividingBy: 4)) < 2.6
        for i in 0..<3 where on {
            c.glowLine(Double(lx + i * 12 + 7), Double(g - 25), Double(lx + i * 12 + 7), Double(g - 1),
                       core: C(0xFFD6D6), glow: C(0xFF2A2A), coreR: 0.4, glowR: 1.6, strength: 0.85)
        }
    }

    // The Emperor — the Death Star II throne room: the great round window onto Endor and the fleet.
    static func emperorThrone(_ c: PixelCanvas, _ g: Int) {
        c.rect(0, 0, c.w, g, C(0x1E2026))
        let cx = c.w / 2, cy = g / 2 + 2, r = max(12, min(g / 2 - 2, c.w / 5))
        c.circle(cx, cy, r + 2, C(0x3A3D46))
        c.circle(cx, cy, r, C(0x04050A))
        c.stars(cy - r, cy + r, density: 18, seed: 6, x0: cx - r, x1: cx + r)
        c.circle(cx + r / 3, cy + r / 3, r / 3, C(0x2E6A3A)); c.circle(cx + r / 3 - 1, cy + r / 3 - 1, r / 3 - 2, C(0x4A8A50))
        for k in 0..<8 {                        // window spokes
            let a = Double(k) * .pi / 4
            c.glowLine(Double(cx), Double(cy), Double(cx) + cos(a) * Double(r), Double(cy) + sin(a) * Double(r),
                       core: C(0x3A3D46), glow: C(0, 0), coreR: 0.6, glowR: 0.7)
        }
        c.circle(cx, cy, 3, C(0x3A3D46))
        // steps and the throne
        for i in 0..<3 { c.rect(cx - 30 + i * 6, g - 3 - i * 2, 60 - i * 12, 2, C(0x2E3138)) }
        c.rect(cx - 5, g - 16, 10, 10, C(0x15161A))
        c.ground(g, C(0x15161A), edge: C(0x4A4E57), speck: C(0x1E2026), seed: 6)
    }

    static func spaceBattle(_ c: PixelCanvas, _ g: Int, t: Double) {
        let cx = c.w / 2, cy = g / 2 + 2, r = max(12, min(g / 2 - 2, c.w / 5))
        for i in 0..<3 {
            let k = Int(t * 2) + i * 17
            let x = cx - r / 2 + Int(noise(k) * Double(r)), y = cy - r / 2 + Int(noise(k + 1) * Double(r / 2))
            if noise(k + 2) > 0.45 {
                c.px(x, y, C(0xFFE27A)); c.px(x + 1, y, C(0xFF9A2A, 0.6))
                c.glowLine(Double(x - 6), Double(y + 2), Double(x - 2), Double(y + 1), core: C(0x7AFF8A), glow: C(0, 0), coreR: 0.4, glowR: 0.5)
            }
        }
    }

    // Dooku — Geonosis: an orange sky, red mesas and rock spires.
    static func geonosis(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xE89A5A), C(0xF2C48A), bands: 5)
        c.circle(c.w / 6, g / 4, 4, C(0xFFF0C8))
        for (i, x) in stride(from: 10, to: c.w, by: 34).enumerated() {
            let hgt = Int(Double(g) * (0.35 + noise(i * 3) * 0.35))
            let wid = 6 + Int(noise(i * 3 + 1) * 8)
            c.rect(x, g - hgt, wid, hgt, C(0xA8442E))
            c.rect(x - 2, g - hgt / 2, wid + 4, hgt / 2, C(0xA8442E))
            c.rect(x, g - hgt, 2, hgt, C(0xC86A48))
        }
        c.dunes(base: g - 4, amp: 2, freq: 0.07, phase: 0, bottom: g, C(0xB85A3A))
        c.ground(g, C(0xB0583A), edge: C(0xD07A54), speck: C(0x96462C), seed: 7)
    }

    // R0-GR — the plains of Naboo, with the Trade Federation's tanks on the horizon.
    static func naboo(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x6FA8E0), C(0xCFE6F2), bands: 5)
        for (i, x) in stride(from: 20, to: c.w, by: 70).enumerated() {      // clouds
            c.ellipse(x, 8 + Int(noise(i) * 6), 9, 2, C(0xF4F8FC))
        }
        c.dunes(base: g - 12, amp: 4, freq: 0.03, phase: 2, bottom: g, C(0x6FA05A), shade: C(0x8ABF6E))
        c.dunes(base: g - 5, amp: 3, freq: 0.05, phase: 0.5, bottom: g, C(0x5A8A48))
        for (i, x) in stride(from: c.w / 3, to: c.w, by: 40).enumerated() {  // MTTs
            let y = g - 10 - Int(noise(i + 9) * 3)
            c.rect(x, y, 10, 4, C(0x9A8A6E)); c.rect(x + 7, y - 2, 4, 3, C(0x9A8A6E)); c.px(x + 10, y - 1, C(0x5A4E3A))
        }
        c.ground(g, C(0x5E8E4A), edge: C(0x7AAE60), speck: C(0x4E7A3E), seed: 8)
    }

    // IG-88 — the Executor's bridge: the big angled windows, crew pits and consoles.
    static func executor(_ c: PixelCanvas, _ g: Int) {
        c.rect(0, 0, c.w, g, C(0x2A2D34))
        let top = 6, bottom = g - 14
        c.rect(0, top, c.w, bottom - top, C(0x05060A))
        c.stars(top, bottom, density: 22, seed: 9)
        for (i, x) in stride(from: 30, to: c.w, by: 90).enumerated() {        // star destroyers outside
            let y = top + 6 + Int(noise(i + 4) * Double(max(1, bottom - top - 12)))
            for k in 0..<12 { c.rect(x + k, y + k / 3, 24 - k * 2, 1, C(0x8A8F9C, 0.8)) }
        }
        for x in stride(from: 0, to: c.w, by: 22) { c.rect(x, top, 2, bottom - top, C(0x2A2D34)) }
        c.rect(0, bottom, c.w, 14, C(0x3A3D46))
        for x in stride(from: 8, to: c.w - 20, by: 40) { c.rect(x, bottom + 3, 24, 6, C(0x1A1C21)) }   // crew pits
        c.ground(g, C(0x22252B), edge: C(0x6E7480), speck: C(0x2C2F36), seed: 10)
    }

    // Luke — the Lars homestead at twin-sunset: the dome, the vaporators, the dunes.
    static func larsFarm(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x5A4A8A), C(0xF2A85A), bands: 6)
        let sy = max(8, g / 2)
        c.circle(c.w * 2 / 3, sy, 5, C(0xFFE8B0)); c.circle(c.w * 2 / 3 + 14, sy + 4, 4, C(0xFFD08A))
        c.circle(c.w * 2 / 3, sy, 9, C(0xFFE8B0, 0.15)); c.circle(c.w * 2 / 3 + 14, sy + 4, 8, C(0xFFD08A, 0.15))
        c.dunes(base: g - 6, amp: 3, freq: 0.04, phase: 1.2, bottom: g, C(0xC8945A), shade: C(0xDCAA6E))
        // the dome entrance
        let dx = c.w / 4
        c.ellipse(dx, g, 14, 9, C(0xD8C8A8)); c.ellipse(dx, g, 14, 1, C(0xB8A888))
        c.rect(dx - 4, g - 6, 8, 6, C(0x3A2C22))
        // moisture vaporators
        for x in [dx + 30, c.w - 40] where x < c.w - 4 {
            c.rect(x, g - 22, 2, 22, C(0xB9BEC8))
            for y in [g - 20, g - 14, g - 8] { c.rect(x - 2, y, 6, 1, C(0x8A8F9C)) }
            c.rect(x - 1, g - 24, 4, 2, C(0xD7DCE4))
        }
        c.ground(g, C(0xD0A066), edge: C(0xE6BA80), speck: C(0xB88A52), seed: 11)
    }

    // Obi-Wan — inside his domed hut in the Jundland Wastes (A New Hope): a cave-like plaster dome, desert sun
    // through the round window, the open chest that held Anakin's lightsaber, his robe on a peg, a sleeping nook,
    // and the projector where Leia's message plays (animated in `obiWanHologram`).
    static func obiWanHut(_ c: PixelCanvas, _ g: Int) {
        // Warm plaster walls.
        c.gradient(0, g, C(0xC8AC84), C(0xA4865F), bands: 5)
        for i in 0..<(c.w * g / 30) { c.px(Int(noise(i * 5) * Double(c.w)), Int(noise(i * 5 + 1) * Double(g)), C(0x9A7C58, 0.5)) }
        // The dome: rough rock outside an arch spanning the room, with a smoothed plaster rim.
        for x in 0..<c.w {
            let u = (Double(x) / Double(c.w - 1)) * 2 - 1                  // -1 … 1 across the room
            let curve = Int(3 + (1 - (1 - u * u).squareRoot()) * Double(g - 14))
            c.rect(x, 0, 1, curve, C(0x5E4630))
            for i in 0..<(curve / 3) { c.px(x, Int(noise(x * 13 + i) * Double(curve)), C(0x4A3524)) }
            c.px(x, curve, C(0xE0C8A0)); c.px(x, curve + 1, C(0xB8996E))
        }

        // The round window, with a beam of desert sun falling across the room.
        let wx = c.w / 2 + 40, wy = g / 2 - 2
        c.circle(wx, wy, 8, C(0x7A5E40)); c.circle(wx, wy, 6, C(0xFFF1CF))
        c.rect(wx - 6, wy, 13, 1, C(0x7A5E40)); c.rect(wx, wy - 6, 1, 13, C(0x7A5E40))
        for y in wy..<g {
            let d = y - wy, x0 = wx - 6 - d * 3 / 2
            c.rect(x0, y, 12 + d / 2, 1, C(0xFFF1CF, 0.10))
        }

        // His robe on a peg.
        let rx = 16
        c.rect(rx, g - 34, 3, 1, C(0x5A4030))
        for y in 0..<20 { let half = 2 + y / 4; c.rect(rx + 1 - half, g - 33 + y, half * 2 + 1, 1, C(0x6A4A30)) }
        c.rect(rx - 1, g - 33, 4, 3, C(0x4E3624))                              // the hood

        // The sleeping nook: a curved recess with cushions.
        let nx = c.w - 120
        c.ellipse(nx + 22, g - 10, 24, 12, C(0x8A6C4A)); c.rect(nx - 2, g - 10, 48, 10, C(0xA4865F))
        c.rect(nx + 2, g - 9, 40, 4, C(0xC9B08A)); c.rect(nx + 4, g - 11, 9, 3, C(0x8E5A3A)); c.rect(nx + 31, g - 11, 9, 3, C(0x7A8A6A))

        // The chest that held Anakin's lightsaber, lid open, the hilt glinting inside.
        let cx = 30
        c.rect(cx, g - 9, 20, 9, C(0x5A4030)); c.rect(cx, g - 9, 20, 1, C(0x8A6A48))
        c.rect(cx + 1, g - 16, 18, 6, C(0x4A3424)); c.rect(cx + 1, g - 16, 18, 1, C(0x7A5A3C))   // lid, up
        c.rect(cx + 6, g - 10, 8, 1, C(0xB8BEC6)); c.px(cx + 9, g - 10, C(0x2A2A2E)); c.px(cx + 13, g - 11, C(0xFFFFFF))

        // Floor, the round woven rug and the low table with the hologram projector.
        c.ground(g, C(0x8A6C4A), edge: C(0xB8996E), speck: C(0x7A5E40), seed: 12)
        let mid = 92                                   // left of centre, where the crew doesn't stand in front of it
        c.ellipse(mid, g + (c.h - g) / 2, 34, max(2, (c.h - g) / 2 - 1), C(0x9A4A30))
        c.ellipse(mid, g + (c.h - g) / 2, 28, max(1, (c.h - g) / 2 - 2), C(0xB8683E))
        c.ellipse(mid, g + (c.h - g) / 2, 16, max(1, (c.h - g) / 2 - 3), C(0x9A4A30))
        c.rect(mid - 9, g - 6, 18, 2, C(0x6A4A30)); c.rect(mid - 7, g - 4, 2, 4, C(0x5A4030)); c.rect(mid + 5, g - 4, 2, 4, C(0x5A4030))
        c.ellipse(mid, g - 7, 3, 1, C(0x8A8F9C)); c.px(mid, g - 8, C(0x9AD8FF))
    }

    /// Leia's message flickering above the projector ("Help me, Obi-Wan Kenobi"), and dust drifting in the sunbeam.
    static func obiWanHologram(_ c: PixelCanvas, _ g: Int, t: Double) {
        let mid = 92, base = g - 9
        let flicker = noise(Int(t * 14)) > 0.12 ? 1.0 : 0.35
        let a = (0.55 + 0.15 * sin(t * 9)) * flicker
        let blue = C(0x8AD4FF, a), dim = C(0x5AA8E8, a * 0.7)
        c.rect(mid - 4, base - 18, 9, 18, C(0x6ABFFF, 0.06 * flicker))   // the projection cone
        // Leia: the buns, head, gown
        c.rect(mid - 1, base - 18, 3, 4, blue)                                       // head
        c.rect(mid - 4, base - 17, 2, 2, blue); c.rect(mid + 3, base - 17, 2, 2, blue)   // the side buns
        c.px(mid, base - 16, dim)                                                     // face shadow
        c.rect(mid, base - 14, 1, 2, dim)                                             // neck
        for y in 0..<10 { let half = 1 + y / 3; c.rect(mid - half, base - 12 + y, half * 2 + 1, 1, y % 2 == 0 ? blue : dim) }
        if noise(Int(t * 5)) > 0.8 { c.rect(mid - 3, base - 10 + Int(noise(Int(t * 20)) * 10), 7, 1, C(0xFFFFFF, 0.4)) }  // a scan glitch
        // dust motes in the sunbeam
        let wx = c.w / 2 + 40, wy = g / 2 - 2
        for i in 0..<7 {
            let p = (t * 0.05 + Double(i) / 7).truncatingRemainder(dividingBy: 1)
            let y = wy + 4 + Int(p * Double(g - wy - 6)), x = wx - 4 - Int(p * Double(g - wy) * 1.2) + Int(sin(t + Double(i)) * 2)
            c.px(x, y, C(0xFFF6E0, 0.5 * (1 - abs(p - 0.5) * 2)))
        }
    }

    // Jawa / R2-D2 — the sandcrawler's hold: rusty plates, sagging cables, a magnet crane with an R2 unit dangling
    // from it, and heaps of scavenged junk — broken droid heads, arms, wheels, pipes and crates — piled everywhere.
    static func sandcrawler(_ c: PixelCanvas, _ g: Int) {
        // Rusty hull plates with rivets, dark at the ceiling.
        c.gradient(0, g, C(0x24180F), C(0x5A3C24), bands: 5)
        for y in stride(from: 8, to: g, by: 11) {
            c.rect(0, y, c.w, 1, C(0x1E140C))
            for x in stride(from: 4, to: c.w, by: 9) { c.px(x, y + 2, C(0x8A5E3A)) }
        }
        for x in stride(from: 0, to: c.w, by: 46) { c.rect(x, 0, 3, g, C(0x2E1E12)); c.rect(x + 1, 0, 1, g, C(0x4A3220)) }   // ribs
        for i in 0..<(c.w * g / 26) {   // rust streaks
            let x = Int(noise(i * 7 + 2) * Double(c.w)), y = Int(noise(i * 7 + 3) * Double(g))
            c.rect(x, y, 1, 1 + Int(noise(i * 7 + 4) * 4), C(0x7A4426, 0.35))
        }
        c.rect(0, 0, c.w, 5, C(0x1A110A))
        // The Jawas' dark doorway at the back (their eyes glow in it — see crawlerLights).
        let dx = c.w / 2 + 70
        c.rect(dx, g - 26, 18, 26, C(0x0E0905)); c.rect(dx - 1, g - 27, 20, 1, C(0x6E4A2E))

        // Cables sagging from the ceiling.
        for (i, x0) in stride(from: 10, to: c.w - 30, by: 57).enumerated() {
            let span = 30 + i % 3 * 8, sag = 7 + i % 2 * 5
            for x in 0..<span {
                let u = Double(x) / Double(span) * 2 - 1
                c.px(x0 + x, 5 + Int(Double(sag) * (1 - u * u)), i % 2 == 0 ? C(0x1A1A1A) : C(0x6A2A1E))
            }
        }

        // The magnet crane, with an R2 unit hanging off it.
        let mx = c.w / 2 - 54
        c.rect(mx - 30, 5, 60, 2, C(0x3A2818)); c.rect(mx, 7, 1, 14, C(0x2A2A2A))
        c.rect(mx - 4, 21, 9, 3, C(0x5A5A62)); c.rect(mx - 4, 21, 9, 1, C(0x8A8A92))
        drawJunkDroidDome(c, mx, 26, tilt: 1)

        // Junk everywhere: low heaps along the back wall, tall piles at both ends.
        func heap(_ cx: Int, _ rx: Int, _ ry: Int, seed: Int) {
            c.ellipse(cx, g, rx, ry, C(0x3A281A))
            c.ellipse(cx, g + 1, rx - 2, ry - 2, C(0x4A3422))
            // parts scattered over its surface
            // packed all the way into the heap, back to front, so the surface is solid junk
            let n = rx * ry / 7
            for i in 0..<n {
                let u = noise(seed * 100 + i * 3) * 2 - 1
                let x = cx + Int(u * Double(rx - 3))
                let surface = g - Int(Double(ry) * (1 - u * u).squareRoot()) + 2
                let depth = Int(pow(noise(seed * 100 + i * 3 + 1), 2) * Double(max(1, g - surface)))
                drawJunkPart(c, x, min(g, surface + depth), kind: Int(noise(seed * 100 + i * 3 + 2) * 9), seed: seed * 31 + i)
            }
        }
        heap(22, 44, 40, seed: 1)               // the big pile on the left
        heap(c.w - 24, 46, 44, seed: 2)         // and the right
        heap(c.w / 2 - 80, 30, 16, seed: 3)     // lower ones behind the crew
        heap(c.w / 2 - 20, 22, 9, seed: 6)
        heap(c.w / 2 + 34, 32, 13, seed: 4)
        heap(c.w / 2 + 112, 24, 18, seed: 5)

        // Floor grating, littered.
        c.ground(g, C(0x3A2818), edge: C(0x8A6A42), speck: C(0x4A3424), seed: 13)
        for x in stride(from: 0, to: c.w, by: 4) { c.rect(x, g + 1, 1, c.h - g - 1, C(0x2A1C10)) }
        for i in 0..<14 {   // bolts, nuts and scraps on the floor
            let x = Int(noise(i * 17 + 5) * Double(c.w)), y = g + 2 + Int(noise(i * 17 + 6) * Double(max(1, c.h - g - 3)))
            c.rect(x, y, 1 + i % 3, 1, [C(0x9A9AA2), C(0x8A5E3A), C(0x6E7480)][i % 3])
        }
    }

    /// An R2-style dome head (dented, one eye out).
    static func drawJunkDroidDome(_ c: PixelCanvas, _ x: Int, _ y: Int, tilt: Int = 0) {
        c.rect(x - 4, y, 9, 6, C(0xC8CCD4)); c.ellipse(x, y, 4, 3, C(0xA9AEB8))
        c.rect(x - 4, y + 2, 9, 1, C(0x3A62A8)); c.px(x - 1 + tilt, y - 1, C(0x1A1A22)); c.px(x + 2, y + 3, C(0x3A62A8))
        c.rect(x - 3, y + 6, 2, 2, C(0x8A8F9C)); c.rect(x + 2, y + 6, 2, 2, C(0x8A8F9C))
    }

    /// One piece of scavenged junk, by `kind`.
    static func drawJunkPart(_ c: PixelCanvas, _ x: Int, _ y: Int, kind: Int, seed: Int) {
        let rust = C(0x8A5E3A), metal = C(0x8A8F9C), dark = C(0x4A4E58), gold = C(0xC9A44A)
        switch kind {
        case 0: drawJunkDroidDome(c, x, y - 4)                                             // R2 dome
        case 1: c.ellipse(x, y - 2, 3, 3, gold); c.px(x - 1, y - 3, C(0x2A2A2E)); c.px(x + 1, y - 3, C(0xFFD24A))   // protocol droid head, one eye lit
        case 2: c.rect(x - 4, y - 5, 9, 6, C(0x6E6A5A)); c.rect(x - 4, y - 5, 9, 1, C(0x8A8670)); c.px(x, y - 3, C(0x2A2A2E))   // GONK box
        case 3: c.rect(x - 3, y - 3, 7, 3, dark); c.rect(x - 4, y - 1, 9, 1, metal); c.px(x + 3, y - 3, C(0xE0303A))   // mouse droid
        case 4: c.circle(x, y - 2, 2, C(0x2A2A2E)); c.px(x, y - 2, metal)                    // wheel
        case 5: for i in 0..<6 { c.px(x - 3 + i, y - 1 - (i > 3 ? i - 3 : 0), metal) }; c.rect(x + 3, y - 4, 2, 2, dark)   // a bent droid arm
        case 6: c.rect(x - 4, y - 2, 8, 2, rust); c.px(x - 4, y - 2, C(0xA87048))           // pipe
        case 7: c.rect(x - 3, y - 4, 7, 5, C(0x6A4A2C)); c.rect(x - 3, y - 4, 7, 1, C(0x8A6A42)); c.rect(x - 3, y - 2, 7, 1, C(0x4A3220))   // crate
        default: c.rect(x - 2, y - 2, 5, 2, [rust, metal, dark, gold][seed % 4])               // scrap plate
        }
    }

    /// Flickering work lights, Jawa eyes blinking in the doorway, and sparks from a broken droid on the pile.
    static func crawlerLights(_ c: PixelCanvas, _ g: Int, t: Double) {
        for (i, x) in stride(from: 24, to: c.w, by: 46).enumerated() {
            let flick = noise(Int(t * 6) + i * 9) > 0.15
            c.rect(x, 5, 6, 2, flick ? C(0xFFC86A) : C(0x6E4A2E))
            if flick { c.circle(x + 3, 7, 8, C(0xFFC86A, 0.07)) }
        }
        // two pairs of Jawa eyes in the doorway, blinking out of step
        let dx = c.w / 2 + 70
        for (j, (ex, ey)) in [(dx + 4, g - 18), (dx + 11, g - 14)].enumerated() {
            let blink = (t * 0.6 + Double(j) * 0.37).truncatingRemainder(dividingBy: 1) < 0.06
            if !blink {
                c.px(ex, ey, C(0xFFD84A)); c.px(ex + 2, ey, C(0xFFD84A))
                c.circle(ex + 1, ey, 3, C(0xFFD84A, 0.10))
            }
        }
        // sparks spitting from a droid on the right pile
        let sp = (t * 1.3).truncatingRemainder(dividingBy: 1)
        if sp < 0.25 {
            let sx = c.w - 30, sy = g - 26
            for k in 0..<5 {
                let a = Double(k) * 1.1 + t * 7, d = sp * 18
                c.px(sx + Int(cos(a) * d), sy - Int(abs(sin(a)) * d) + Int(sp * sp * 30), C(0xFFE27A, 1 - sp * 4))
            }
        }
        // the crane's R2 swaying a little
        let mx = c.w / 2 - 54, sway = Int(sin(t * 1.2) * 1.4)
        if sway != 0 { c.px(mx + sway * 3, 31, C(0xC8CCD4, 0.25)) }
    }

    // Yoda — Dagobah (The Empire Strikes Back): misty layered swamp, the gnarled tree over the dark side cave,
    // Luke's X-wing sinking nose-up in the bog, vines and moss, and Yoda's mud hut glowing in the murk.
    static func dagobah(_ c: PixelCanvas, _ g: Int) {
        // Murky green air, palest in the fog band near the ground.
        c.gradient(0, g / 2, C(0x14241A), C(0x3E5A44), bands: 5)
        c.gradient(g / 2, g, C(0x3E5A44), C(0x7A9478), bands: 4)
        // Far trees: pale silhouettes in the mist.
        for i in 0..<9 {
            let x = Int(noise(i * 5 + 40) * Double(c.w)), tw = 3 + i % 3
            c.rect(x, 0, tw, g, C(0x4E6A54, 0.55))
            c.ellipse(x + tw / 2, 6 + i % 3 * 4, 14 + i % 4 * 3, 6, C(0x405C46, 0.5))
        }

        // The gnarled tree over the dark side cave (left), roots arching over its mouth.
        let tx = 46
        c.rect(tx - 8, 0, 16, g - 18, C(0x1E1C14))
        for (j, (dx, w)) in [(-14, 6), (10, 5), (-4, 4)].enumerated() {   // twisted trunk strands
            for y in 0..<(g - 18) { c.rect(tx + dx / 2 + Int(sin(Double(y) * 0.15 + Double(j)) * 3), y, w, 1, C(0x2A2618)) }
        }
        c.ellipse(tx, g - 4, 26, 14, C(0x1E1C14))                          // the root mass
        c.ellipse(tx + 2, g - 2, 11, 9, C(0x050806))                      // the cave mouth
        c.ellipse(tx + 2, g - 1, 7, 5, C(0x020302))
        for (rx, rw) in [(-24, 10), (20, 12), (-34, 8)] {                 // roots arching into the ground
            for k in 0..<rw { c.px(tx + rx + k, g - 3 - Int(sin(Double(k) / Double(rw) * .pi) * 6), C(0x2A2618)) }
        }
        // its branches with hanging moss
        for (bx, by, bl) in [(tx, 12, 40), (tx - 6, 22, -30)] {
            for k in 0..<abs(bl) { c.px(bx + (bl > 0 ? k : -k), by - k / 6, C(0x1E1C14)); c.px(bx + (bl > 0 ? k : -k), by - k / 6 + 1, C(0x1E1C14)) }
            for k in stride(from: 4, to: abs(bl), by: 5) {
                let mx = bx + (bl > 0 ? k : -k)
                c.rect(mx, by - k / 6 + 2, 1, 4 + k % 7, C(0x5A7A44))
            }
        }

        // Mid trees: dark, twisted, with vines.
        for (i, x) in [118, 158, 236, 288].enumerated() {
            let tw = 5 + i % 2 * 2
            for y in 0..<g { c.rect(x + Int(sin(Double(y) * 0.11 + Double(i)) * 2), y, tw, 1, C(0x26281C)) }
            c.rect(x - 3, g - 4, tw + 6, 4, C(0x26281C))
            for k in 0..<3 { let vx = x + tw + 2 + k * 4; c.rect(vx, 0, 1, 10 + (i + k) % 3 * 7, C(0x4A6A3A)) }
        }

        // Ground: muddy bank, and the bog spreading under the X-wing on the right.
        c.rect(0, g, c.w, c.h - g, C(0x2A3420))
        c.rect(0, g, c.w, 1, C(0x5A7A4A))
        for i in 0..<(c.w / 3) { c.rect(Int(noise(i * 7) * Double(c.w)), g + 2 + Int(noise(i * 7 + 1) * Double(max(1, c.h - g - 3))), 3, 1, C(0x3E4E30)) }
        let bx = c.w - 120
        c.rect(bx - 40, g, 140, c.h - g, C(0x1E2E26))
        c.rect(bx - 40, g, 140, 1, C(0x4E6A5A))
        for i in 0..<10 { c.rect(bx - 26 + Int(noise(i * 3 + 70) * 110), g + 2 + i % 3 * 2, 6, 1, C(0x5E7E6E, 0.5)) }   // ripples

        // Luke's X-wing, nose up and half sunk: a thick fuselage rising out of the bog, two S-foils splayed in an X
        // with engines at their roots, red stripes and the canopy. Drawn in its own units, scaled up by `xs`.
        let xw = bx - 18, xs = 1.7
        func part(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ col: Px) {   // local units, y up from the water
            let x0 = xw + Int((x * xs).rounded()), x1 = xw + Int(((x + w) * xs).rounded())
            let y0 = g - Int(((y + h) * xs).rounded()), y1 = g - Int((y * xs).rounded())
            c.rect(x0, y0, max(1, x1 - x0), max(1, y1 - y0), col)
        }
        let white = C(0xDCDCD4), shade = C(0x9A9A92), red = C(0xC03A2A)
        for k in 0..<34 {                                                  // fuselage, tapering to the nose
            let y = Double(k) * 0.75, thick = k > 26 ? 2.0 : 4.0
            part(Double(k), y - 1, 1, thick, white); part(Double(k), y - 1, 1, 1, shade)
        }
        part(33, 24, 3, 2, C(0xC8C8C0))                                    // nose tip
        part(8, 4, 3, 4, red); part(20, 13, 3, 4, red)                     // stripes
        part(13, 10, 5, 3, C(0x2E4A6A)); part(14, 12, 1, 1, C(0x8AB0D0))   // canopy
        for k in 0..<18 {                                                  // the S-foils
            part(4 - Double(k) / 3, 6 + Double(k), 3, 1, k % 6 == 0 ? red : white)        // one wing up and back
            part(6 + Double(k) / 2, 1 - Double(k) / 4, 3, 1, white.alpha(max(0, 1 - Double(k) / 8)))   // one going under
        }
        part(-2, 17, 2, 5, C(0x6A6A70))                                    // wing-tip cannon
        part(1, 4, 5, 4, C(0x8A8A90)); part(2, 5, 1, 1, C(0xFF8A3A))       // engine
        c.rect(xw - 10, g, Int(60 * xs), 1, C(0x8AA89A, 0.5))              // where it meets the water
        c.ellipse(xw + Int(24 * xs), g + 1, Int(30 * xs), 1, C(0x8AA89A, 0.18))   // its reflection

        // Yoda's hut on the far right: a mud dome with a glowing round window and doorway.
        let hx = c.w - 26
        c.ellipse(hx, g - 1, 16, 12, C(0x5A5438)); c.ellipse(hx, g - 2, 14, 10, C(0x6E6644))
        c.circle(hx - 5, g - 7, 2, C(0xFFC86A)); c.circle(hx - 5, g - 7, 7, C(0xFFC86A, 0.14))
        c.rect(hx + 3, g - 6, 4, 6, C(0x2A2414)); c.rect(hx + 4, g - 5, 2, 5, C(0xFFB050, 0.6))
        c.rect(hx + 8, g - 14, 2, 4, C(0x4A4430))                          // the chimney
    }

    /// Drifting fog, fireflies, bubbles rising in the bog, and eyes surfacing in the water now and then.
    static func swampFog(_ c: PixelCanvas, _ g: Int, t: Double) {
        for i in 0..<3 {
            let y = g - 6 - i * 7
            let off = Int((t * (4 + Double(i) * 2)).truncatingRemainder(dividingBy: Double(c.w)))
            for x in stride(from: -60, to: c.w + 60, by: 60) {
                c.ellipse((x + off) % (c.w + 60), y, 26, 2, C(0xDDE8DD, 0.10))
            }
        }
        // fireflies
        for i in 0..<8 {
            let x = Int(noise(i * 11 + 3) * Double(c.w)) + Int(sin(t * 0.7 + Double(i)) * 6)
            let y = g / 3 + Int(noise(i * 11 + 4) * Double(g / 2)) + Int(cos(t * 0.9 + Double(i) * 2) * 3)
            let on = (t * 0.8 + Double(i) * 0.31).truncatingRemainder(dividingBy: 1) < 0.6
            if on { c.px(x, y, C(0xE8FF8A)); c.circle(x, y, 2, C(0xE8FF8A, 0.15)) }
        }
        // bubbles in the bog
        let bx = c.w - 120
        for i in 0..<3 {
            let p = (t * 0.5 + Double(i) * 0.33).truncatingRemainder(dividingBy: 1)
            if p < 0.3 { c.circle(bx - 20 + i * 37, g + 3, p < 0.2 ? 1 : 0, C(0xA8C8B8, 0.7)) }
        }
        // something in the water, watching
        let e = (t * 0.07).truncatingRemainder(dividingBy: 1)
        if e > 0.82 && e < 0.94 { c.px(bx + 68, g + 3, C(0xFFE84A)); c.px(bx + 71, g + 3, C(0xFFE84A)) }
    }

    // Han / Chewbacca — the Millennium Falcon's main hold (A New Hope): curved hull with ribs, walls crowded with
    // pipes, valves and blinking panels, the dejarik table with its curved padded bench, and a round hatch down the
    // corridor to the cockpit, where hyperspace streaks past the window (animated in `dejarik`).
    static func falcon(_ c: PixelCanvas, _ g: Int) {
        // Walls: warm grey, darker up into the curve of the hull.
        c.gradient(0, g, C(0x3A3934), C(0x8E8A7E), bands: 6)
        // The hull curving overhead at both ends.
        for x in 0..<c.w {
            let u = Double(x) / Double(c.w - 1) * 2 - 1
            let curve = Int(pow(abs(u), 3) * Double(g / 2))
            if curve > 0 { c.rect(x, 0, 1, curve, C(0x262521)) }
            c.px(x, curve, C(0x5A5850))
        }
        // Ribs.
        for x in stride(from: 6, to: c.w, by: 34) { c.rect(x, 0, 4, g, C(0x5E5B52)); c.rect(x + 1, 0, 1, g, C(0xA6A294)); c.rect(x + 3, 0, 1, g, C(0x3A3934)) }
        // Pipes and conduits along the walls.
        for (y, col, hi) in [(10, C(0x6E5A48), C(0x9A8268)), (15, C(0x4E5A5E), C(0x7A8A90)), (g - 30, C(0x6A6658), C(0x9A9688))] {
            c.rect(0, y, c.w, 3, col); c.rect(0, y, c.w, 1, hi)
            for x in stride(from: 20, to: c.w, by: 47) { c.rect(x, y - 1, 3, 5, C(0x3A3934)) }   // clamps
        }
        // Panels, vents, valve wheels and a hose loop, scattered between the ribs.
        for (i, x) in stride(from: 14, to: c.w - 20, by: 34).enumerated() {
            let y = 22 + (i % 3) * 7
            switch i % 4 {
            case 0:   // a light panel
                c.rect(x, y, 14, 8, C(0x2E2D29)); c.rect(x + 1, y + 1, 12, 6, C(0x3E3D38))
                for k in 0..<4 { c.px(x + 2 + k * 3, y + 3, [C(0xE0303A), C(0x6CFF7A), C(0xFFD24A), C(0x5AB4FF)][(i + k) % 4]) }
            case 1:   // a vent
                c.rect(x, y, 16, 9, C(0x4A4840)); for k in 0..<4 { c.rect(x + 1, y + 1 + k * 2, 14, 1, C(0x2A2925)) }
            case 2:   // valve wheel on a pipe stub
                c.rect(x + 6, y - 2, 3, 12, C(0x6E5A48)); c.circle(x + 7, y + 3, 4, C(0x8A3A2A)); c.circle(x + 7, y + 3, 2, C(0x3A3934)); c.px(x + 7, y + 3, C(0xC86A48))
            default:  // a hose looping down
                for k in 0..<14 { c.px(x + k, y + Int(sin(Double(k) / 13 * .pi) * 6), C(0x2A2A2A)); c.px(x + k, y + 1 + Int(sin(Double(k) / 13 * .pi) * 6), C(0x2A2A2A)) }
            }
        }

        // The round hatch to the cockpit corridor (right), with the cockpit window at the end of it.
        let hx = c.w - 66, hy = g - 20
        c.circle(hx, hy, 19, C(0x4A4840)); c.circle(hx, hy, 17, C(0xB0AC9E)); c.circle(hx, hy, 15, C(0x16161A))
        c.rect(hx - 15, hy + 9, 31, 12, C(0x16161A))                       // the opening goes down to the floor
        c.rect(hx - 17, hy + 2, 2, 19, C(0xB0AC9E)); c.rect(hx + 16, hy + 2, 2, 19, C(0xB0AC9E))
        c.ellipse(hx, hy - 2, 9, 6, C(0x05060C))                            // the cockpit window, far down the corridor
        c.ellipse(hx, hy - 2, 9, 6, C(0x2A3A5A, 0.4))
        for k in 0..<4 { c.rect(hx - 9 + k * 5, hy - 8, 1, 12, C(0x2A2A2E)) }   // window frame struts
        c.rect(hx - 11, hy + 5, 22, 2, C(0x3A3934))                        // the console under it

        // The dejarik table with its curved padded bench (left).
        let tx = 74
        for y in 0..<14 {                                                  // the bench: a padded half-ring behind the table
            let half = Int(Double(26) * (1 - pow(Double(13 - y) / 14, 2)).squareRoot())
            c.rect(tx - half, g - 18 + y, half * 2, 1, y % 4 == 0 ? C(0xBCB6A2) : C(0xD8D2BC))
        }
        c.rect(tx - 26, g - 6, 52, 6, C(0xC8C2AC)); c.rect(tx - 26, g - 6, 52, 1, C(0xE8E2CC))
        c.ellipse(tx, g - 7, 14, 3, C(0x3A3A36)); c.rect(tx - 2, g - 6, 4, 6, C(0x2A2A28))
        for k in 0..<7 { c.rect(tx - 12 + k * 4, g - 8, 2, 1, k % 2 == 0 ? C(0x2E5A3A) : C(0x1E3A2A)) }   // the board
        c.ellipse(tx, g - 7, 12, 2, C(0x1E3A2A, 0.4))

        // Deck plates with a lit strip.
        c.ground(g, C(0x3A3A36), edge: C(0x9A968A), speck: C(0x2E2E2A), seed: 14)
        for x in stride(from: 0, to: c.w, by: 3) { c.rect(x, g + 1, 1, c.h - g - 1, C(0x2A2A28)) }
        c.rect(0, g + 2, c.w, 1, C(0xFFD8A0, 0.25))
    }

    /// The dejarik monsters squaring off, Luke's training remote hovering and zapping, and hyperspace streaking past
    /// the cockpit window down the corridor.
    static func dejarik(_ c: PixelCanvas, _ g: Int, t: Double) {
        let tx = 74
        let flick = 0.55 + 0.3 * noise(Int(t * 12))
        let hop = Int(sin(t * 3) * 1.2)
        c.rect(tx - 8, g - 13 + hop, 3, 4, C(0x7AFFB0, flick)); c.px(tx - 7, g - 14 + hop, C(0x7AFFB0, flick))
        c.rect(tx + 4, g - 12 - hop, 4, 3, C(0x7AC8FF, flick)); c.px(tx + 7, g - 13 - hop, C(0x7AC8FF, flick))

        // The training remote, bobbing above the bench, firing a little zap now and then.
        let rx = 132 + Int(sin(t * 0.9) * 10), ry = g - 40 + Int(cos(t * 1.7) * 4)
        c.circle(rx, ry, 3, C(0x3A3A3E)); c.circle(rx, ry, 2, C(0x5A5A62))
        c.px(rx - 1, ry - 1, C(0x9A9AA2)); c.px(rx + 1, ry, C(0xFF5A3A))
        for k in [-4, 4] { c.px(rx + k, ry, C(0x8A8A92)) }                 // its little antennae
        let z = (t * 0.7).truncatingRemainder(dividingBy: 1)
        if z < 0.12 { for k in 0..<10 { c.px(rx - 3 - k * 2, ry + 2 + k, C(0xFF4A3A, 1 - z * 6)) } }

        // Hyperspace past the cockpit window.
        let hx = c.w - 66, hy = g - 22
        for i in 0..<12 {
            let a = Double(i) * 2.4 + 0.3
            let p = (t * 1.6 + noise(i * 13)).truncatingRemainder(dividingBy: 1)
            let r0 = p * 7, r1 = min(9, r0 + 2 + p * 4)
            let x0 = hx + Int(cos(a) * r0), y0 = hy + Int(sin(a) * r0 * 0.65)
            let x1 = hx + Int(cos(a) * r1), y1 = hy + Int(sin(a) * r1 * 0.65)
            c.px(x0, y0, C(0xDDEEFF, 0.5 * p)); c.px(x1, y1, C(0xFFFFFF, 0.9 * p))
            if abs(x1 - x0) > 1 || abs(y1 - y0) > 1 { c.px((x0 + x1) / 2, (y0 + y1) / 2, C(0xC8E0FF, 0.7 * p)) }
        }
    }

    // Leia / C-3PO — the Tantive IV: white ribbed corridor.
    static func tantive(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xF2F4F6), C(0xC8CED6), bands: 4)
        for x in stride(from: 0, to: c.w, by: 16) {
            c.rect(x, 0, 4, g, C(0xDDE2E8)); c.rect(x, 0, 1, g, C(0xA8B0BA))
        }
        c.rect(0, 0, c.w, 4, C(0xA8B0BA))
        for x in stride(from: 6, to: c.w, by: 32) { c.rect(x, 4, 8, 2, C(0xFFFFFF)) }
        c.ellipse(c.w * 3 / 4, g / 2, 10, g / 3, C(0xA8B0BA)); c.ellipse(c.w * 3 / 4, g / 2, 8, g / 3 - 2, C(0x8A939E))
        c.ground(g, C(0xB8C0CA), edge: C(0xFFFFFF), speck: C(0xA8B0BA), seed: 15)
    }

    // Qui-Gon — the Jundland Wastes: canyon rocks, Tusken Raiders and a bantha.
    static func tuskenDesert(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x8AB8E0), C(0xF0DCB0), bands: 5)
        c.circle(c.w / 5, 7, 3, C(0xFFF4D0)); c.circle(c.w / 5 + 9, 9, 2, C(0xFFE8B0))
        for (i, x) in stride(from: 0, to: c.w, by: 60).enumerated() {
            let hgt = g / 2 + Int(noise(i) * Double(g / 4))
            // rough, flat-topped mesa with sloping flanks and a sunlit ledge
            for k in 0..<34 {
                let flank = max(0, abs(k - 17) - 9) * 2
                let rough = Int(noise(k + i * 31) * 3)
                let top = g - hgt + flank + rough
                c.rect(x + k, top, 1, g - top, k < 17 ? C(0xC0905E) : C(0xA8784C))
            }
            c.rect(x + 10, g - hgt + 6, 12, 1, C(0xD8A878))
        }
        // a Tusken on a rock, gaffi stick raised
        let tx = c.w * 2 / 3
        c.rect(tx - 6, g - 10, 14, 10, C(0x9A7048))
        c.rect(tx, g - 18, 3, 8, C(0xC8B48A)); c.rect(tx, g - 21, 3, 3, C(0xD8C8A8)); c.px(tx + 1, g - 20, C(0x2A1C10))
        c.rect(tx + 3, g - 24, 1, 10, C(0x5A4636)); c.rect(tx + 2, g - 25, 3, 1, C(0x8A8F9C))
        // a bantha
        let bx = c.w / 3
        c.ellipse(bx, g - 6, 9, 5, C(0x5A4232)); c.rect(bx - 7, g - 3, 2, 3, C(0x4A3424)); c.rect(bx + 5, g - 3, 2, 3, C(0x4A3424))
        c.circle(bx + 9, g - 8, 3, C(0x4A3424)); c.px(bx + 12, g - 10, C(0xE8DCC0)); c.px(bx + 12, g - 7, C(0xE8DCC0))
        c.ground(g, C(0xD8B07A), edge: C(0xE8C894), speck: C(0xC09A66), seed: 16)
    }

    // Rey — Jakku: dunes and the half-buried Star Destroyer.
    static func jakku(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xA8C8E0), C(0xF4DCA8), bands: 5)
        let sx = c.w / 2
        // the half-buried Star Destroyer: a sunlit top face and a shadowed side
        for k in 0..<40 {
            c.rect(sx - 34 + k, g - 24 + k / 3, 76 - k, 1, k < 6 ? C(0xA8AEB8) : C(0x7A808C))
            c.px(sx + 42 - k, g - 24 + k / 3, C(0x4E535C))
        }
        for k in 0..<7 { c.rect(sx - 14 + k * 7, g - 21, 1, 7, C(0x5A606A)) }
        c.rect(sx - 6, g - 29, 12, 5, C(0x8A909A)); c.rect(sx - 6, g - 29, 12, 1, C(0xB8BEC8))
        c.dunes(base: g - 6, amp: 4, freq: 0.035, phase: 0.3, bottom: g, C(0xDDB477), shade: C(0xEACB94))
        c.ground(g, C(0xE0B87C), edge: C(0xF0CC94), speck: C(0xC8A066), seed: 17)
    }

    // Mace Windu / Ahsoka — the Jedi Council chamber: tall windows onto the Coruscant skyline.
    static func jediCouncil(_ c: PixelCanvas, _ g: Int) {
        c.rect(0, 0, c.w, g, C(0x6E5236))
        let top = 4, bottom = g - 8
        for x in stride(from: 4, to: c.w - 14, by: 24) {
            for y in top..<bottom {
                let k = Double(y - top) / Double(max(1, bottom - top))
                c.rect(x, y, 18, 1, lerp(C(0xF2A85A), C(0xE87A6A), k))
            }
            for (i, bx) in stride(from: x, to: x + 18, by: 3).enumerated() {        // skyscrapers
                let hgt = 6 + Int(noise(i + x) * Double(max(4, bottom - top - 6)))
                c.rect(bx, bottom - hgt, 3, hgt, C(0x3A2A3A))
                if noise(i * 3 + x) > 0.6 { c.px(bx + 1, bottom - hgt + 2, C(0xFFE27A)) }
            }
            c.rect(x - 2, top, 2, bottom - top, C(0x4A3624))
        }
        for x in stride(from: 10, to: c.w, by: 32) { c.rect(x, g - 9, 10, 9, C(0x4A3624)); c.rect(x + 1, g - 12, 8, 3, C(0x5A4430)) }   // council seats
        c.ground(g, C(0x8A6A48), edge: C(0xB08A60), speck: C(0x7A5C3E), seed: 18)
        for x in stride(from: 0, to: c.w, by: 10) { c.rect(x, g + 2, 5, 1, C(0x9A7A56)) }
    }

    // AT-ST / Ewoks — the forest moon of Endor: giant redwoods, ferns, and the Ewok village up in the trees.
    static func endor(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3E5A3A), C(0x6E8A5A), bands: 5)
        for (i, x) in stride(from: 4, to: c.w, by: 28).enumerated() {        // distant trunks
            c.rect(x + Int(noise(i) * 10), 0, 4, g, C(0x4A5E3A))
        }
        for (i, x) in stride(from: 14, to: c.w, by: 56).enumerated() {       // giant redwoods
            let tw = 9 + Int(noise(i + 20) * 5)
            c.rect(x, 0, tw, g, C(0x5A3A26)); c.rect(x + 1, 0, 2, g, C(0x7A5236)); c.rect(x + tw - 2, 0, 2, g, C(0x3E2618))
            c.rect(x - 3, g - 4, tw + 6, 4, C(0x5A3A26))
            if i % 2 == 0 {                                                   // an Ewok hut on a platform
                let py = g / 3
                c.rect(x - 10, py, tw + 20, 2, C(0x8A6238))
                c.ellipse(x + tw / 2, py - 4, 7, 4, C(0x9A7A48)); c.rect(x + tw / 2 - 1, py - 3, 3, 3, C(0x3A2416))
                c.rect(x + tw + 10, py + 2, 1, 10, C(0x8A6238, 0.8))         // rope ladder
            }
        }
        for (i, x) in stride(from: 0, to: c.w, by: 9).enumerated() {        // ferns
            let fh = 3 + Int(noise(i * 3 + 40) * 4)
            c.rect(x, g - fh, 1, fh, C(0x3E7A30)); c.px(x - 1, g - fh + 1, C(0x5A9A40)); c.px(x + 1, g - fh + 1, C(0x5A9A40))
        }
        c.ground(g, C(0x3A2E1E), edge: C(0x5A4A2E), speck: C(0x4E3E26), seed: 19)
    }

    // AT-AT — the Battle of Hoth: snowfield, grey sky, the shield generator and the trench.
    static func hoth(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xA8B4C4), C(0xDCE4EC), bands: 5)
        c.dunes(base: g - 14, amp: 6, freq: 0.03, phase: 0.8, bottom: g, C(0xC8D2DE), shade: C(0xE8EEF4))   // mountains
        c.dunes(base: g - 6, amp: 2, freq: 0.06, phase: 0.2, bottom: g, C(0xE4EAF0))
        // shield generator: a big dish on a tower
        let sx = c.w * 4 / 5
        c.rect(sx, g - 18, 4, 18, C(0x8A8F9C))
        c.ellipse(sx + 2, g - 20, 10, 3, C(0x9AA0A8)); c.ellipse(sx + 2, g - 21, 8, 2, C(0xC8CED6))
        c.px(sx + 2, g - 24, C(0xE0303A))
        // the Rebel trench with a turret
        let tx = c.w / 5
        c.rect(tx - 20, g - 2, 40, 2, C(0x8A939E))
        c.rect(tx - 3, g - 6, 7, 4, C(0x6E7480)); c.rect(tx + 3, g - 5, 6, 1, C(0x3A3D46))
        c.ground(g, C(0xEEF2F6), edge: C(0xFFFFFF), speck: C(0xD0D8E2), seed: 20)
    }

    static func snowfall(_ c: PixelCanvas, _ g: Int, t: Double) {
        for i in 0..<(c.w / 3) {
            let x = Int((noise(i * 5) * Double(c.w) + t * (6 + noise(i * 5 + 1) * 6)).truncatingRemainder(dividingBy: Double(c.w)))
            let y = Int((noise(i * 5 + 2) * Double(g) + t * (10 + noise(i * 5 + 3) * 10)).truncatingRemainder(dividingBy: Double(g)))
            c.px(x, y, white.alpha(0.8))
        }
    }

    // The Rancor — its pit under Jabba's palace: rough stone, bones, the keeper's gate, light through the grate.
    static func rancorPit(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2A2018), C(0x4A3A2C), bands: 5)
        for i in 0..<(c.w * g / 14) {                                         // rough cave stone
            c.rect(Int(noise(i * 5) * Double(c.w)), Int(noise(i * 5 + 1) * Double(g)), 2, 1,
                   noise(i * 5 + 2) > 0.5 ? C(0x3A2E22) : C(0x564434))
        }
        // the keeper's gate: a heavy barred door
        let gx = c.w * 3 / 4
        c.rect(gx - 12, g - 26, 24, 26, C(0x1A140F))
        for x in stride(from: gx - 11, to: gx + 12, by: 4) { c.rect(x, g - 26, 2, 26, C(0x6E6A60)) }
        c.rect(gx - 13, g - 27, 26, 2, C(0x8A8274))
        // bones scattered about
        for (i, x) in stride(from: 10, to: c.w - 10, by: 23).enumerated() {
            let y = g + 2 + Int(noise(i * 3) * 3)
            c.rect(x, y, 6, 1, C(0xE8DCC0)); c.px(x - 1, y - 1, C(0xE8DCC0)); c.px(x + 6, y + 1, C(0xE8DCC0))
            if i % 3 == 0 { c.ellipse(x + 10, g - 2, 3, 2, C(0xE8DCC0)); c.px(x + 9, g - 2, C(0x2A2018)); c.px(x + 11, g - 2, C(0x2A2018)) }
        }
        c.ground(g, C(0x3A2E22), edge: C(0x5A4A38), speck: C(0x2E241A), seed: 21)
        for (i, x) in stride(from: 10, to: c.w - 10, by: 23).enumerated() {  // bones on top of the floor
            let y = g + 2 + Int(noise(i * 3) * 3)
            c.rect(x, y, 6, 1, C(0xE8DCC0)); c.px(x - 1, y - 1, C(0xE8DCC0))
        }
    }

    static func grateLight(_ c: PixelCanvas, _ g: Int, t: Double) {
        // light falling through the grate above, with dust drifting in it
        let x0 = c.w / 3
        for y in 0..<g {
            let spread = y / 4
            c.rect(x0 - 6 - spread, y, 12 + spread * 2, 1, C(0xF2D8A0, 0.07))
        }
        for x in stride(from: x0 - 6, to: x0 + 7, by: 3) { c.rect(x, 0, 1, 2, C(0x1A140F)) }
        for i in 0..<10 {
            let y = Int((noise(i * 7) * Double(g) + t * (3 + noise(i * 7 + 1) * 3)).truncatingRemainder(dividingBy: Double(g)))
            c.px(x0 - 6 + Int(noise(i * 7 + 2) * 12) + y / 8, y, C(0xF2D8A0, 0.5))
        }
    }

    /// The Max Rebo Band in Jabba's palace, as in the original Return of the Jedi: Max Rebo at his red ball jett
    /// organ, Sy Snootles singing into the mic, Droopy McCool (eyeless Kitonak) on his chindinkalu flute.
    static func maxReboBand(_ c: PixelCanvas, _ g: Int, t: Double, at x: Int? = nil) {
        let x0 = x ?? c.w - 64                           // Jabba's palace: the right side of the throne room
        guard x != nil || x0 > 60 else { return }
        func bob(_ k: Double) -> Int { (t * 2.2 + k).truncatingRemainder(dividingBy: 1) < 0.5 ? 0 : -1 }

        // Max Rebo: small blue Ortolan with floppy ears and a trunk, at the red ball organ
        c.oy = bob(0)
        let blue = C(0x5A8AD8), blueDark = C(0x3E6AB0)
        c.ellipse(x0 + 8, g - 7, 6, 5, blue)
        c.rect(x0 + 1, g - 12, 4, 5, blueDark); c.rect(x0 + 12, g - 12, 4, 5, blueDark)       // ears
        c.px(x0 + 6, g - 9, C(0x101010)); c.px(x0 + 10, g - 9, C(0x101010))                  // eyes
        c.rect(x0 + 8, g - 7, 1, 4, blueDark); c.px(x0 + 9, g - 3, blueDark)                  // trunk
        c.oy = 0
        c.ellipse(x0 + 8, g - 3, 7, 3, C(0xC8303A))                                           // the organ
        for k in 0..<5 { c.px(x0 + 3 + k * 2, g - 5, (Int(t * 5) + k) % 4 == 0 ? C(0xFFE27A) : white) }

        // Sy Snootles: thin yellow-green singer with a long-lipped snout, at a microphone stand
        let sx = x0 + 26
        c.oy = bob(0.33)
        let sy = C(0xB8C860), syDark = C(0x8A9A40)
        c.rect(sx + 1, g - 9, 1, 9, syDark); c.rect(sx + 4, g - 9, 1, 9, syDark)            // spindly legs
        c.ellipse(sx + 3, g - 11, 3, 3, sy)                                                    // body
        c.rect(sx + 2, g - 17, 3, 4, sy)                                                       // head
        c.px(sx + 2, g - 16, C(0x101010)); c.px(sx + 4, g - 16, C(0x101010))
        c.rect(sx + 5, g - 15, 4, 1, C(0xD86A7A))                                              // the long lips
        c.oy = 0
        c.rect(sx + 9, g - 15, 1, 15, C(0x9AA0A8)); c.rect(sx + 8, g - 16, 3, 2, C(0x3A3A42)) // mic stand

        // Droopy McCool: chubby, eyeless pale Kitonak playing his chindinkalu flute
        let dx = x0 + 44
        c.oy = bob(0.66)
        let pale = C(0xD8D4CC), paleDark = C(0xB0ACA4)
        c.ellipse(dx + 6, g - 7, 6, 7, pale)
        c.rect(dx + 2, g - 3, 9, 3, paleDark)
        c.rect(dx + 4, g - 11, 5, 1, paleDark)                                                 // folds where eyes would be
        c.rect(dx + 7, g - 9, 8, 1, C(0x8A6A48))                                               // the slim wooden flute
        c.px(dx + 9, g - 9, C(0x5A4636)); c.px(dx + 11, g - 9, C(0x5A4636)); c.px(dx + 13, g - 9, C(0x5A4636))
        c.oy = 0

        // notes
        let f = (t / 1.4).truncatingRemainder(dividingBy: 1)
        c.pattern(x0 + 20, g - 24 - Int(f * 8), ["..N", "..N", "NNN", "NN."], ["N": C(0xFFC86A, 1 - f)])
    }
}
