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
        case .cantina: Cantina.drawBand(c, floorRows: f, t: t)
        case .deathStar, .executor: Scenes.blinkLights(c, g, t: t, seed: self == .deathStar ? 1 : 2)
        case .sarlaccPit: Scenes.sarlaccTentacles(c, g, t: t)
        case .jabbasPalace: Scenes.torches(c, g, t: t)
        case .theed: Scenes.laserGates(c, g, t: t)
        case .emperorThrone: Scenes.spaceBattle(c, g, t: t)
        case .dagobah: Scenes.swampFog(c, g, t: t)
        case .falcon: Scenes.dejarik(c, g, t: t)
        case .sandcrawler: Scenes.crawlerLights(c, g, t: t)
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

    // Jabba / Gamorrean — the throne room: stone, arches, the dais and the rancor grate.
    static func jabbasPalace(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x3A2E24), C(0x5A4636), bands: 4)
        for i in 0..<(c.w * g / 30) { c.px(Int(noise(i * 9) * Double(c.w)), Int(noise(i * 9 + 1) * Double(g)), C(0x2E241C)) }
        var x = 30
        while x + 22 < c.w {
            for y in (g - 30)..<g {
                let top = g - 30, r = 11
                var half = r
                if y - top < r { let dy = Double(r - (y - top)); half = Int((Double(r * r) - dy * dy).squareRoot()) }
                c.rect(x + r - half, y, half * 2, 1, C(0x1E1712))
            }
            x += 52
        }
        // dais with the hookah
        c.rect(4, g - 6, 44, 6, C(0x6E5440)); c.rect(4, g - 6, 44, 1, C(0x8A6E54))
        c.rect(30, g - 14, 3, 8, C(0xB08D57)); c.circle(31, g - 15, 2, C(0xC9A44A))
        // rancor grate in the floor
        c.ground(g, C(0x4A3A2C), edge: C(0x6E5440), speck: C(0x3E3024), seed: 3)
        let gx = c.w / 2 - 15
        c.rect(gx, g + 2, 30, max(3, c.h - g - 4), C(0x1E1712))
        for i in stride(from: gx, to: gx + 30, by: 3) { c.rect(i, g + 2, 1, max(3, c.h - g - 4), C(0x8A7660)) }
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

    // Obi-Wan — his hut in the Jundland Wastes: round window, shelves, a lamp, the old chest.
    static func obiWanHut(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0xB89A74), C(0x8A6E50), bands: 4)
        for i in 0..<(c.w * g / 40) { c.px(Int(noise(i * 5) * Double(c.w)), Int(noise(i * 5 + 1) * Double(g)), C(0x9C8060)) }
        let wx = c.w * 2 / 3, wy = g / 2 - 4
        c.circle(wx, wy, 9, C(0x6E5440)); c.circle(wx, wy, 7, C(0xF2D8A8)); c.rect(wx - 7, wy + 2, 15, 5, C(0xD8B47A))
        c.rect(wx - 7, wy, 15, 1, C(0x6E5440)); c.rect(wx, wy - 7, 1, 14, C(0x6E5440))
        for y in [g - 24, g - 16] { c.rect(16, y, 40, 2, C(0x5A4636)) }
        for (i, x) in stride(from: 18, to: 54, by: 5).enumerated() { c.rect(x, g - 28 + (i % 2), 3, 4, [C(0xB08D57), C(0x8AA0B0), C(0xC86A48)][i % 3]) }
        c.rect(c.w / 3, g - 8, 16, 8, C(0x5A4636)); c.rect(c.w / 3, g - 8, 16, 2, C(0x8A6E54))   // the chest
        c.circle(c.w / 3 + 30, g - 18, 1, C(0xFFD08A)); c.circle(c.w / 3 + 30, g - 18, 5, C(0xFFD08A, 0.12))
        c.ground(g, C(0x7A5E42), edge: C(0x9A7A58), speck: C(0x6A5038), seed: 12)
    }

    // Jawa / R2-D2 — inside the sandcrawler: rusty plates, rivets, and droids waiting to be sold.
    static func sandcrawler(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x4A3424), C(0x6E4A2E), bands: 4)
        for y in stride(from: 6, to: g, by: 10) {
            c.rect(0, y, c.w, 1, C(0x3A2818))
            for x in stride(from: 3, to: c.w, by: 8) { c.px(x, y + 2, C(0x9A6A42)) }
        }
        c.rect(0, 0, c.w, 4, C(0x2E1E12))
        // droids lined up for sale
        for (i, x) in stride(from: 20, to: c.w - 10, by: 26).enumerated() {
            if i % 2 == 0 {
                c.rect(x, g - 9, 6, 7, C(0xC8B48A)); c.ellipse(x + 3, g - 10, 3, 2, C(0xA9AEB8)); c.px(x + 3, g - 10, C(0xE0303A))
                c.rect(x - 1, g - 4, 1, 4, C(0x8A8F9C)); c.rect(x + 6, g - 4, 1, 4, C(0x8A8F9C))
            } else {
                c.rect(x + 1, g - 14, 4, 4, C(0x8A8F9C)); c.rect(x, g - 10, 6, 10, C(0x6E7480)); c.px(x + 2, g - 13, C(0x3BD15A))
            }
        }
        c.ground(g, C(0x3A2818), edge: C(0x8A6A42), speck: C(0x4A3424), seed: 13)
        for x in stride(from: 0, to: c.w, by: 4) { c.rect(x, g + 1, 1, c.h - g - 1, C(0x2A1C10)) }   // floor grating
    }

    static func crawlerLights(_ c: PixelCanvas, _ g: Int, t: Double) {
        for (i, x) in stride(from: 10, to: c.w, by: 40).enumerated() {
            let flick = noise(Int(t * 6) + i * 9) > 0.15
            c.rect(x, 4, 6, 2, flick ? C(0xFFC86A) : C(0x6E4A2E))
            if flick { c.circle(x + 3, 6, 7, C(0xFFC86A, 0.07)) }
        }
    }

    // Yoda — Dagobah: misty swamp, gnarled trees, Yoda's hut glowing in the murk.
    static func dagobah(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x2E4A3A), C(0x6E8A6E), bands: 5)
        for (i, x) in stride(from: 8, to: c.w, by: 38).enumerated() {
            let tw = 5 + Int(noise(i) * 4)
            c.rect(x, 0, tw, g, C(0x2A2A1E))
            c.rect(x - 3, g - 6, tw + 6, 6, C(0x2A2A1E))
            c.rect(x - 6, g - 3, 4, 3, C(0x2A2A1E)); c.rect(x + tw + 2, g - 3, 4, 3, C(0x2A2A1E))
            c.rect(x + tw, g / 3, 10, 2, C(0x2A2A1E))
            for y in stride(from: g / 3 + 2, to: g / 3 + 12, by: 3) { c.px(x + tw + 4, y, C(0x4A6A3A)) }   // hanging moss
        }
        // Yoda's hut
        let hx = c.w * 3 / 5
        c.ellipse(hx, g - 1, 12, 9, C(0x6A6A4A)); c.ellipse(hx - 3, g - 6, 3, 2, C(0xFFC86A)); c.circle(hx - 3, g - 6, 6, C(0xFFC86A, 0.15))
        c.rect(0, g, c.w, c.h - g, C(0x2E3A28))
        c.rect(0, g, c.w, 1, C(0x5A7A4A))
        for i in 0..<(c.w / 3) { c.rect(Int(noise(i * 7) * Double(c.w)), g + 2 + Int(noise(i * 7 + 1) * Double(max(1, c.h - g - 3))), 4, 1, C(0x4A5E3A)) }
    }

    static func swampFog(_ c: PixelCanvas, _ g: Int, t: Double) {
        for i in 0..<3 {
            let y = g - 6 - i * 7
            let off = Int((t * (4 + Double(i) * 2)).truncatingRemainder(dividingBy: Double(c.w)))
            for x in stride(from: -60, to: c.w + 60, by: 60) {
                c.ellipse((x + off) % (c.w + 60), y, 26, 2, C(0xDDE8DD, 0.10))
            }
        }
    }

    // Han / Chewbacca — the Millennium Falcon's hold: curved walls, pipes, the dejarik table.
    static func falcon(_ c: PixelCanvas, _ g: Int) {
        c.gradient(0, g, C(0x8A8A84), C(0x5E5E5A), bands: 4)
        for x in stride(from: 0, to: c.w, by: 18) {
            c.rect(x, 0, 3, g, C(0x4A4A46)); c.rect(x + 1, 0, 1, g, C(0xA8A8A0))
        }
        for y in [g / 4, g / 2] { c.rect(0, y, c.w, 2, C(0x6E6A60)); c.rect(0, y + 2, c.w, 1, C(0x3A3A36)) }
        for x in stride(from: 6, to: c.w, by: 36) { c.rect(x, g / 4 - 6, 10, 4, C(0x3A3A36)); c.px(x + 2, g / 4 - 5, C(0xE0303A)) }
        // the dejarik table
        let tx = c.w / 3
        c.ellipse(tx, g - 4, 13, 3, C(0x3A3A36)); c.rect(tx - 2, g - 4, 4, 4, C(0x2A2A28))
        c.ellipse(tx, g - 5, 11, 2, C(0x1E3A2A))
        c.ground(g, C(0x3A3A36), edge: C(0x8A8A84), speck: C(0x2E2E2A), seed: 14)
        for x in stride(from: 0, to: c.w, by: 3) { c.rect(x, g + 1, 1, c.h - g - 1, C(0x2A2A28)) }
    }

    static func dejarik(_ c: PixelCanvas, _ g: Int, t: Double) {
        let tx = c.w / 3
        let flick = 0.55 + 0.3 * noise(Int(t * 12))
        // two tiny holo monsters squaring off
        c.rect(tx - 7, g - 10, 3, 4, C(0x7AFFB0, flick)); c.px(tx - 6, g - 11, C(0x7AFFB0, flick))
        c.rect(tx + 4, g - 9, 4, 3, C(0x7AC8FF, flick)); c.px(tx + 7, g - 10, C(0x7AC8FF, flick))
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
}
