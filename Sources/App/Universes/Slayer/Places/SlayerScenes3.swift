import Foundation

// Sunnydale beyond the high school: UC Sunnydale's campus, the Initiative under it, the Mayor's office, Glory's tower,
// the abandoned factory and the Doublemeat Palace. Each has its own key colour so none of them sinks into the night
// places' navy: the campus's autumn sandstone and red brick under a clear sky, the Initiative's clinical white and
// cyan, the Mayor's sage green and brass, the tower's storm grey lit lime-white by the portal, the factory's orange
// brazier on rust, and the Doublemeat Palace's mustard and ketchup under strip lights.
let slayerScenes3: [Location: Place] = [
    .slayerCampus: Place(name: "UC Sunnydale", panel: 0x1E1A12, still: Scenes.slayerCampus, moving: Scenes.slayerCampusLife),
    .slayerInitiative: Place(name: "The Initiative", panel: 0x141A1E, still: Scenes.slayerInitiative, moving: Scenes.slayerInitiativeLife),
    .slayerCityHall: Place(name: "The Mayor's Office", panel: 0x16201A, still: Scenes.slayerCityHall, moving: Scenes.slayerCityHallLife),
    .slayerTower: Place(name: "Glory's Tower", panel: 0x12160F, still: Scenes.slayerTower, moving: Scenes.slayerTowerLife),
    .slayerFactory: Place(name: "The Factory", panel: 0x1C100A, still: Scenes.slayerFactory, moving: Scenes.slayerFactoryLife),
    .slayerDoublemeat: Place(name: "The Doublemeat Palace", panel: 0x221A0C, still: Scenes.slayerDoublemeat, moving: Scenes.slayerDoublemeatLife),
]

// MARK: - Shared bits for these scenes

/// A blocky 3×5 alphabet, only the letters and digits the signs here need.
private let slayerP3Glyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "D": "110101101101110", "E": "111100110100111",
    "L": "100100100100111", "M": "101111111101101", "N": "110101101101101", "O": "010101101101010",
    "P": "110101110100100", "C": "011100100100011", "U": "101101101101111", "T": "111010010010010",
    "1": "010110010010111", "3": "110001010001110", "4": "101101111001001", "R": "110101110101101",
    "S": "011100010001110", "I": "111010010010111", "Y": "101101010010010",
]

/// How wide `text` comes out at `p` pixels a dot.
private func slayerP3SignWidth(_ text: String, _ p: Int) -> Int {
    text.reduce(0) { $0 + ($1 == " " ? 3 : 4) * p } - p
}

/// Lettering in the blocky alphabet, `p` pixels a dot, from its top-left corner.
private func slayerP3Sign(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int) {
    var cx = x
    for ch in text {
        guard let bits = slayerP3Glyphs[ch] else { cx += 3 * p; continue }
        for (i, b) in bits.enumerated() where b == "1" { c.rect(cx + (i % 3) * p, y + (i / 3) * p, p, p, col) }
        cx += 4 * p
    }
}

// MARK: - UC Sunnydale

extension Scenes {
    /// Where things stand on the campus: the clock tower (centre, width, top of its roof, clock centre and radius),
    /// the two halls' roofline, and the two trees.
    static func slayerCampusFrame(_ c: PixelCanvas, _ g: Int) -> (tower: (x: Int, w: Int, top: Int, cy: Int, r: Int),
                                                                eave: Int, trees: [Int]) {
        let s = unit(g), tall = isTall(c)
        let w = (tall ? 32 : 20) * s
        let top = tall ? max(14 * s, g - 236 * s) : 5 * s
        let h = g - top
        let cy = top + h * (tall ? 30 : 46) / 100, r = w * 36 / 100
        let eave = tall ? g - 62 * s : g - 33 * s
        return ((c.w * 58 / 100, w, top, cy, r), eave, [c.w * 7 / 100, c.w * 91 / 100])
    }

    /// UC Sunnydale on an autumn afternoon: a clear sky going gold at the horizon, red-brick halls with sandstone trim
    /// and tiled roofs, an arcade of round arches, the clock tower rising between them, two trees in red and gold, a
    /// noticeboard thick with flyers, a bench and a lamp along the quad's paved walk. On the screen saver the halls
    /// gain a storey, the tower stands at its full height with its belfry and copper-green spire, and the hills and a
    /// few clouds fill the sky behind.
    static func slayerCampus(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerCampusFrame(c, g), tw = f.tower
        let brick = C(0x9A4A34), brickD = C(0x7A3626), brickL = C(0xB25E42)
        let stone = C(0xE2CC98), stoneD = C(0xB89E6A), tile = C(0xB04A2A), tileD = C(0x82331E)
        c.gradient(0, g, C(0x7EB6E2), C(0xF2DCAA), bands: 7)
        if tall {
            // Far hills, blue with distance, and a few clouds.
            c.dunes(base: f.eave - 22 * s, amp: Double(16 * s), freq: 0.011 / Double(s), phase: 1.2, bottom: g, C(0x8C9EB8))
            c.dunes(base: f.eave - 8 * s, amp: Double(10 * s), freq: 0.019 / Double(s), phase: 3.1, bottom: g, C(0x7A8C9C))
            for k in 0..<4 {
                let x = c.w * (12 + k * 26) / 100, y = (24 + Int(noise(k + 300) * 60)) * s
                cloud(c, x, y, (5 + k % 2 * 2) * s, seed: k + 40)
            }
        }
        // On the screen saver, the domed library hall rises behind the left-hand building.
        if tall {
            let dx = c.w * 22 / 100, dw = 46 * s, drum = f.eave - 34 * s
            c.rect(dx - dw / 2 - 6 * s, drum + 14 * s, dw + 12 * s, f.eave - drum, stoneD)
            c.rect(dx - dw / 2, drum, dw, f.eave - drum, stone)
            for x in stride(from: dx - dw / 2 + 3 * s, to: dx + dw / 2 - 3 * s, by: 7 * s) {
                c.rect(x, drum + 5 * s, 3 * s, 10 * s, C(0x2E3A4A)); c.rect(x + 4 * s + s / 2, drum, s, 34 * s, stoneD)
            }
            c.rect(dx - dw / 2 - s, drum, dw + 2 * s, 2 * s, stoneD)
            c.ellipse(dx, drum, dw / 2 + s, 26 * s, C(0x3E7464)); c.ellipse(dx - 4 * s, drum - 2 * s, dw / 2 - 6 * s, 22 * s, C(0x5A9A86))
            c.rect(dx - dw / 2 - 2 * s, drum, dw + 4 * s, 26 * s, stone)
            c.rect(dx - dw / 2 - 2 * s, drum, dw + 4 * s, s, stoneD)
            for x in stride(from: dx - dw / 2 + 2 * s, to: dx + dw / 2, by: 7 * s) {
                c.rect(x, drum + 6 * s, 4 * s, 12 * s, C(0x2E3A4A)); c.ellipse(x + 2 * s, drum + 6 * s, 2 * s, 2 * s, C(0x2E3A4A))
            }
            c.rect(dx - s, drum - 32 * s, 2 * s, 7 * s, C(0xD8C090)); c.rect(dx - 2 * s, drum - 33 * s, 4 * s, s, C(0xB89E6A))
        }
        // The halls, left and right of the tower. The left is red brick with arched windows and an arcade along the
        // ground; the right is pale sandstone with square windows under brick lintels and a deep porch.
        func hall(_ x0: Int, _ x1: Int, pale: Bool) {
            let top = f.eave
            let wall = pale ? C(0xD2B888) : brick, course = pale ? stoneD : brickD, trim = pale ? brick : stone
            c.rect(x0, top, x1 - x0, g - top, wall)
            for y in stride(from: top + 3 * s, to: g, by: (pale ? 5 : 3) * s) { c.rect(x0, y, x1 - x0, max(1, s / 2), course.alpha(0.45)) }
            // The tiled roof, a shallow slope.
            let rh = (pale ? 8 : 6) * s
            for k in 0..<rh {
                c.rect(x0 - s + k, top - rh + k, x1 - x0 + 2 * s - 2 * k, 1, k % 2 == 0 ? tile : tileD)
            }
            c.rect(x0 - 2 * s, top, x1 - x0 + 4 * s, s, trim)
            let floors = tall ? 2 : 1, fh = (g - top - 4 * s) / (floors + 1)
            let step = (pale ? 17 : 13) * s
            for fl in 0..<floors {
                let wy = top + 4 * s + fl * fh
                c.rect(x0, wy + fh - 2 * s, x1 - x0, s, trim.alpha(0.8))
                for x in stride(from: x0 + 6 * s, to: x1 - 8 * s, by: step) {
                    let ww = (pale ? 8 : 6) * s, wh = fh - 6 * s
                    c.rect(x - s, wy - s, ww + 2 * s, wh + 2 * s, pale ? brickD : stoneD)
                    c.rect(x, wy, ww, wh, C(0x2E3A4A))
                    if pale {
                        c.rect(x - s, wy - 2 * s, ww + 2 * s, 2 * s, brick)
                        c.rect(x, wy + wh / 2, ww, max(1, s / 2), C(0xD2B888)); c.rect(x + ww / 2, wy, max(1, s / 2), wh, C(0xD2B888))
                    } else {
                        c.ellipse(x + ww / 2, wy + ww / 2, ww / 2, ww / 2, C(0x2E3A4A))
                        c.rect(x - s, wy - s, s, ww / 2, wall); c.rect(x + ww, wy - s, s, ww / 2, wall)
                        c.rect(x + ww / 2, wy, max(1, s / 2), wh, stoneD)
                    }
                    c.rect(x, wy + 2 * s, s, wh - 2 * s, C(0x6A86A6))   // sky caught in the glass
                }
            }
            let ay = g - fh + s
            c.rect(x0, ay - 2 * s, x1 - x0, s, trim)
            if pale {
                // A deep porch on square stone piers, the entrance doors in its shade.
                c.rect(x0, ay, x1 - x0, g - ay, C(0x4A3426))
                for x in stride(from: x0 + 4 * s, to: x1, by: 20 * s) {
                    c.rect(x, ay - s, 5 * s, g - ay + s, stone); c.rect(x + 4 * s, ay - s, s, g - ay + s, stoneD)
                }
                for x in stride(from: x0 + 12 * s, to: x1 - 8 * s, by: 40 * s) { c.rect(x, ay + 4 * s, 6 * s, g - ay - 4 * s, C(0x6A3A22)) }
            } else {
                // The arcade: round arches in sandstone, the walk in shadow behind them.
                for x in stride(from: x0 + 3 * s, to: x1 - 10 * s, by: 12 * s) {
                    let aw = 9 * s
                    c.rect(x, ay + aw / 2, aw, g - ay - aw / 2, C(0x3A2018))
                    c.ellipse(x + aw / 2, ay + aw / 2, aw / 2, aw / 2, C(0x3A2018))
                    c.rect(x + aw, ay - s, 3 * s, g - ay + s, stoneD); c.rect(x + aw, ay - s, s, g - ay + s, stone)
                }
            }
            c.rect(x0, top + s, x1 - x0, s, (pale ? C(0xE8D4A8) : brickL).alpha(0.5))
        }
        hall(-4 * s, tw.x - tw.w / 2 - 10 * s, pale: false)
        hall(tw.x + tw.w / 2 + 12 * s, c.w + 4 * s, pale: true)
        // The clock tower: a brick shaft with stone quoins, the clock stage, the open belfry, a pointed roof.
        let tx = tw.x - tw.w / 2, th = g - tw.top
        let roofH = th * (tall ? 16 : 18) / 100, bellH = th * (tall ? 10 : 12) / 100
        let bellTop = tw.top + roofH, clockTop = bellTop + bellH
        c.rect(tx, bellTop, tw.w, g - bellTop, brick)
        for y in stride(from: clockTop, to: g, by: 3 * s) { c.rect(tx, y, tw.w, max(1, s / 2), brickD.alpha(0.5)) }
        for y in stride(from: clockTop, to: g, by: 6 * s) {
            c.rect(tx - s, y, 3 * s, 3 * s, stone); c.rect(tx + tw.w - 2 * s, y + 3 * s, 3 * s, 3 * s, stone)
        }
        c.rect(tx, tw.cy, s, g - tw.cy, brickL.alpha(0.6))
        // Tall narrow windows down the shaft.
        for y in stride(from: tw.cy + tw.r + 8 * s, to: g - 14 * s, by: 22 * s) {
            c.rect(tw.x - 2 * s, y, 4 * s, 9 * s, C(0x2E3A4A)); c.rect(tw.x - 2 * s, y, 4 * s, s, stone)
        }
        // The door at the foot.
        c.rect(tw.x - 4 * s, g - 12 * s, 8 * s, 12 * s, C(0x3A2018)); c.ellipse(tw.x, g - 12 * s, 4 * s, 3 * s, C(0x3A2018))
        c.rect(tw.x - 5 * s, g - 16 * s, 10 * s, s, stone)
        // The clock stage: a stone band above and below, the white face with its ring of hour marks.
        c.rect(tx - s, clockTop, tw.w + 2 * s, 2 * s, stone); c.rect(tx - s, tw.cy + tw.r + 3 * s, tw.w + 2 * s, 2 * s, stone)
        c.circle(tw.x, tw.cy, tw.r + s, stoneD); c.circle(tw.x, tw.cy, tw.r, C(0xF4ECD8))
        for k in 0..<12 {
            let a = Double(k) / 12 * 2 * .pi, rr = Double(tw.r) - Double(s) * 1.2
            c.rect(tw.x + Int((sin(a) * rr).rounded()), tw.cy - Int((cos(a) * rr).rounded()), s, s, C(0x3A2A20))
        }
        // The belfry: open arches with the bell in shadow, and the roof above.
        c.rect(tx - s, bellTop, tw.w + 2 * s, bellH, stone)
        let arches = 3, aw = (tw.w - (arches + 1) * 2 * s) / arches
        for k in 0..<arches {
            let ax = tx + 2 * s + k * (aw + 2 * s), ay = bellTop + 2 * s
            c.rect(ax, ay + aw / 2, aw, bellH - 3 * s - aw / 2, C(0x2A1A14)); c.ellipse(ax + aw / 2, ay + aw / 2, aw / 2, aw / 2, C(0x2A1A14))
        }
        c.ellipse(tw.x, bellTop + bellH / 2 + s, max(s, bellH / 5), max(s, bellH / 5), C(0x8A6A2A))
        let green = C(0x5A9A86), greenD = C(0x3E7464)
        for y in 0..<roofH {
            let half = (tw.w / 2 + s) * (y + 1) / roofH
            c.rect(tw.x - half, tw.top + y, half * 2, 1, y % (2 * s) == 0 ? greenD : green)
        }
        c.rect(tw.x, tw.top - 4 * s, max(1, s / 2) + s / 2, 4 * s, C(0x3A2A20))
        c.rect(tx - 2 * s, bellTop - s, tw.w + 4 * s, s, stoneD)
        // The trees: dark trunks, crowns of rust, red and gold.
        for (k, x) in f.trees.enumerated() {
            let crown = tall ? 26 * s : 17 * s, cyy = g - (tall ? 46 : 38) * s
            c.rect(x - 2 * s, cyy, 4 * s, g - cyy, C(0x3A2618)); c.rect(x - 2 * s, cyy, s, g - cyy, C(0x5A3A24))
            slayerLine(c, Double(x), Double(cyy + 6 * s), Double(x - 8 * s), Double(cyy - 2 * s), C(0x3A2618), Double(s) * 0.7)
            for j in 0..<9 {
                let dx = Int((noise(k * 40 + j) - 0.5) * Double(crown * 2)), dy = Int((noise(k * 40 + j + 20) - 0.6) * Double(crown))
                let col = [C(0xC24A1E), C(0xE08A2A), C(0xA8321E), C(0xE8B43A)][j % 4]
                c.ellipse(x + dx, cyy + dy, crown / 2, crown * 2 / 5, col)
            }
            for j in 0..<16 {
                let dx = Int((noise(k * 40 + j + 60) - 0.5) * Double(crown * 2)), dy = Int((noise(k * 40 + j + 80) - 0.6) * Double(crown))
                c.rect(x + dx, cyy + dy, s, s, C(0xF4D06A))
            }
        }
        // The noticeboard, thick with flyers.
        let nx = c.w * 26 / 100, ny = g - 22 * s
        c.rect(nx, ny, 22 * s, 13 * s, C(0x6A4428)); c.rect(nx + s, ny + s, 20 * s, 11 * s, C(0xB89060))
        for k in 0..<6 {
            let col = [C(0xF4F0E0), C(0xF0D04A), C(0xE87A9A), C(0x8AC0E8), C(0xF4F0E0), C(0xA8E07A)][k]
            c.rect(nx + 2 * s + (k % 3) * 6 * s + Int(noise(k + 500) * 2) * s, ny + 2 * s + (k / 3) * 5 * s, 5 * s, 4 * s, col)
        }
        c.rect(nx + 2 * s, ny + 13 * s, 2 * s, 9 * s, C(0x4A2E1A)); c.rect(nx + 18 * s, ny + 13 * s, 2 * s, 9 * s, C(0x4A2E1A))
        // A bench and a lamp along the walk.
        let bx = c.w * 72 / 100
        c.rect(bx, g - 6 * s, 16 * s, 2 * s, C(0x6A4428)); c.rect(bx, g - 10 * s, 16 * s, 2 * s, C(0x6A4428))
        c.rect(bx + s, g - 4 * s, s, 4 * s, C(0x2A2A2A)); c.rect(bx + 14 * s, g - 4 * s, s, 4 * s, C(0x2A2A2A))
        let lx = c.w * 42 / 100
        c.rect(lx, g - 26 * s, s, 26 * s, C(0x2A2E2A)); c.rect(lx - s, g - 2 * s, 3 * s, 2 * s, C(0x2A2E2A))
        c.rect(lx - s, g - 30 * s, 3 * s, 4 * s, C(0xF4E4B0)); c.rect(lx - 2 * s, g - 31 * s, 5 * s, s, C(0x2A2E2A))
        // The hedge and the quad's paved walk.
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0x3E5A2A)); c.rect(0, g - 3 * s, c.w, s, C(0x5A7A36))
        c.ground(g, C(0x5E544A), edge: C(0x8A7C68), speck: C(0x4E463E), seed: 91)
        for x in stride(from: 0, to: c.w, by: 12 * s) { c.rect(x, g + 2 * s, max(1, s / 2), c.h - g, C(0x4A423A)) }
    }

    /// The campus's life: autumn leaves blowing across, the clock's hands going round (a minute a turn, so you see it
    /// move), and on the screen saver a few birds crossing high up.
    static func slayerCampusLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = slayerCampusFrame(c, g), tw = f.tower
        // The hands.
        let m = t / 60 * 2 * .pi, h = t / 720 * 2 * .pi + 1.9
        let ink = C(0x2A1E18), r = Double(tw.r)
        slayerLine(c, Double(tw.x), Double(tw.cy), Double(tw.x) + sin(h) * r * 0.5, Double(tw.cy) - cos(h) * r * 0.5, ink, Double(s) * 0.7)
        slayerLine(c, Double(tw.x), Double(tw.cy), Double(tw.x) + sin(m) * r * 0.8, Double(tw.cy) - cos(m) * r * 0.8, ink, Double(s) * 0.5)
        c.rect(tw.x, tw.cy, s, s, C(0xB08A3A))
        // Leaves on the wind.
        for k in 0..<12 {
            let p = frac(t * (0.05 + 0.03 * noise(k + 600)) + noise(k + 610))
            let x = Int(p * Double(c.w + 40 * s)) - 20 * s
            let y = Int(noise(k + 620) * Double(g - 10 * s)) + Int(sin(t * 2 + Double(k)) * Double(4 * s))
            let col = [C(0xC24A1E), C(0xE08A2A), C(0xE8B43A)][k % 3]
            c.rect(x, y, s, s, col); if Int(t * 3 + Double(k)) % 2 == 0 { c.rect(x + s, y, s, s, col) } else { c.rect(x, y + s, s, s, col) }
        }
        // Birds.
        if tall {
            for k in 0..<4 {
                let x = Int(frac(t * 0.02 + Double(k) * 0.03) * Double(c.w + 60 * s)) - 30 * s + k * 7 * s
                let y = 30 * s + k % 2 * 5 * s, flap = Int(t * 5 + Double(k)) % 2 == 0 ? -s : 0
                c.rect(x - 2 * s, y + flap, 2 * s, s, C(0x3A3A44)); c.rect(x, y, s, s, C(0x3A3A44)); c.rect(x + s, y + flap, 2 * s, s, C(0x3A3A44))
            }
        }
    }
}

// MARK: - The Initiative

extension Scenes {
    /// Where things stand in the Initiative: the ceiling, the blast door, the lift shaft, the cells, and (on the screen
    /// saver) the gallery level and the rock between the base and Lowell House above.
    static func slayerInitiativeFrame(_ c: PixelCanvas, _ g: Int) -> (ceil: Int, door: Int, shaft: (x: Int, w: Int),
                                                                     cells: [Int], cellW: Int, cellTop: Int,
                                                                     gallery: Int?, house: Int?, rock: Int?) {
        let s = unit(g), tall = isTall(c)
        let cellW = 30 * s
        let cells = (0..<3).map { c.w * 63 / 100 + $0 * (cellW + 6 * s) }
        let house = tall ? max(30 * s, (g - 120 * s) * 28 / 100) : nil
        let rock = house.map { $0 + max(24 * s, (g - 120 * s) * 22 / 100) }
        return (rock.map { $0 + 8 * s } ?? 7 * s, c.w * 8 / 100, (c.w * 47 / 100, 26 * s), cells, cellW, g - 36 * s,
                tall ? g - 78 * s : nil, house, rock)
    }

    /// The Initiative, the secret army base under UC Sunnydale: bright white panelled walls under strip lights, a
    /// steel-blue band along them, the blast door of Room 314 in its yellow and black hazard frame, a wall console of
    /// readouts, the lift doors, and the holding cells on the right with a demon pacing behind the force field. On the
    /// screen saver a gallery with observation windows runs above, steel beams hold up the ceiling, the lift shaft
    /// climbs through the rock, and at the top is Lowell House, the frat house the lift comes up in.
    static func slayerInitiative(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = slayerInitiativeFrame(c, g)
        let panel = C(0xA2AEB8), panelL = C(0xBCC8D0), seam = C(0x7A8894), band = C(0x3E5A72), kick = C(0x4A5662)
        // The walls: white panels with seams, a blue band, a dark kick plate.
        c.rect(0, f.ceil, c.w, g - f.ceil, panel)
        for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, f.ceil, s, g - f.ceil, seam); c.rect(x + s, f.ceil, s, g - f.ceil, panelL) }
        let by = g - 20 * s
        c.rect(0, by, c.w, 4 * s, band); c.rect(0, by, c.w, s, C(0x5A7A94))
        c.rect(0, g - 6 * s, c.w, 6 * s, kick); c.rect(0, g - 6 * s, c.w, s, C(0x6A7682))
        if let gal = f.gallery, let rock = f.rock, let house = f.house {
            // Lowell House at the top: wood panelling, a worn sofa, a lamp, a picture, floorboards.
            c.gradient(0, house, C(0x3A2418), C(0x5A3A26), bands: 4)
            for x in stride(from: 0, to: c.w, by: 18 * s) { c.rect(x, 0, s, house, C(0x2E1C12)) }
            c.rect(0, house - 14 * s, c.w, s, C(0x7A5232))
            c.rect(0, house - 3 * s, c.w, 3 * s, C(0x6A4428)); c.rect(0, house - 3 * s, c.w, s, C(0x8A6038))
            let sx = c.w * 18 / 100
            c.rect(sx, house - 11 * s, 34 * s, 8 * s, C(0x4A5A3A)); c.rect(sx - 3 * s, house - 14 * s, 4 * s, 11 * s, C(0x3E4E30))
            c.rect(sx + 33 * s, house - 14 * s, 4 * s, 11 * s, C(0x3E4E30)); c.rect(sx + s, house - 16 * s, 32 * s, 6 * s, C(0x56663E))
            c.rect(sx + 50 * s, house - 22 * s, s, 19 * s, C(0x2A1A10)); c.rect(sx + 47 * s, house - 27 * s, 7 * s, 5 * s, C(0xE8C878))
            c.rect(c.w * 76 / 100, house - 30 * s, 16 * s, 12 * s, C(0x8A6A3A)); c.rect(c.w * 76 / 100 + 2 * s, house - 28 * s, 12 * s, 8 * s, C(0x3A5A6A))
            // The lift's hidden door in the panelling.
            c.rect(f.shaft.x - f.shaft.w / 2, house - 26 * s, f.shaft.w, 23 * s, C(0x4A2E1C))
            c.rect(f.shaft.x, house - 26 * s, s, 23 * s, C(0x2E1C12))
            // The rock between: rubble and stones in a dark matrix, conduits running down through it.
            c.rect(0, house, c.w, rock - house, C(0x3A322C))
            for k in 0..<(c.w * (rock - house) / (160 * s * s)) {
                let x = Int(noise(k + 700) * Double(c.w)), y = house + Int(noise(k + 710) * Double(rock - house))
                let r = (2 + Int(noise(k + 720) * 5)) * s
                c.ellipse(x, y, r + r / 2, r, [C(0x463C34), C(0x30282A), C(0x4E443A)][k % 3]); c.rect(x - r, y - r + s, r, s, C(0x5A5046))
            }
            for x in [c.w * 30 / 100, c.w * 66 / 100] {
                c.rect(x, house, 3 * s, rock - house, C(0x6A7076)); c.rect(x, house, s, rock - house, C(0x8A9096))
            }
            // The ceiling's steel beams, and the columns down to the gallery.
            c.rect(0, rock, c.w, 8 * s, C(0x5A646C)); c.rect(0, rock + 7 * s, c.w, s, C(0x3A444C))
            for x in stride(from: 6 * s, to: c.w, by: 40 * s) {
                c.rect(x, rock + 8 * s, 4 * s, gal - rock - 8 * s, C(0x9AA6AE)); c.rect(x, rock + 8 * s, s, gal - rock - 8 * s, panelL)
            }
            // Big ducts along the top of the hall.
            let dy = rock + 14 * s
            c.rect(0, dy, c.w, 9 * s, C(0x7A868E)); c.rect(0, dy, c.w, s, C(0xA4B0B8)); c.rect(0, dy + 8 * s, c.w, s, C(0x5A646C))
            for x in stride(from: 20 * s, to: c.w, by: 56 * s) { c.rect(x, dy - s, 2 * s, 11 * s, C(0x5A646C)) }
            // Two big screens on the upper wall: a green map of Sunnydale with the hostiles' tags, and a readout.
            for (k, x) in [c.w * 14 / 100, c.w * 70 / 100].enumerated() {
                let sy = dy + 24 * s, sw = 60 * s, sh = max(16 * s, (gal - 40 * s - sy) * 7 / 10)
                c.rect(x - 2 * s, sy - 2 * s, sw + 4 * s, sh + 4 * s, C(0x3E4850)); c.rect(x, sy, sw, sh, C(0x0E1A20))
                if k == 0 {
                    for j in 0..<9 {
                        let y0 = sy + Int(noise(j + 760) * Double(sh)), x0 = x + Int(noise(j + 770) * Double(sw))
                        c.rect(x, y0, sw, max(1, s / 2) + s / 2, C(0x2A6A4A)); c.rect(x0, sy, s, sh, C(0x2A6A4A))
                    }
                    for j in 0..<4 { c.rect(x + Int(noise(j + 780) * Double(sw - 3 * s)), sy + Int(noise(j + 790) * Double(sh - 3 * s)), 2 * s, 2 * s, C(0xE84A3A)) }
                } else {
                    for y in stride(from: sy + 3 * s, to: sy + sh - 2 * s, by: 4 * s) {
                        c.rect(x + 3 * s, y, (8 + Int(noise(y + 800) * 40)) * s, 2 * s, C(0x4AD0E8))
                    }
                }
            }
            // Strip lights under the ducts.
            for x in stride(from: 10 * s, to: c.w, by: 48 * s) { c.rect(x, dy + 12 * s, 26 * s, 2 * s, C(0xF0F6F8)) }
            // The gallery: observation windows, scientists in white coats at them, a railing along its edge.
            for x in stride(from: 14 * s, to: c.w - 40 * s, by: 64 * s) where abs(x + 20 * s - f.shaft.x) > 40 * s {
                let wy = gal - 30 * s
                c.rect(x - s, wy - s, 42 * s, 22 * s, C(0x5A646C))
                c.rect(x, wy, 40 * s, 20 * s, C(0x1E2C36)); c.rect(x, wy, 40 * s, 3 * s, C(0x2E4656))
                for (j, px) in [8, 22].enumerated() where noise(x + j) > 0.35 {
                    c.rect(x + px * s, wy + 9 * s, 6 * s, 11 * s, C(0xE8EEF0)); c.circle(x + px * s + 3 * s, wy + 7 * s, 2 * s, C(0xC8A080))
                }
            }
            c.rect(0, gal, c.w, 4 * s, C(0x6A7682)); c.rect(0, gal, c.w, s, C(0x9AA6AE))
            c.rect(0, gal - 9 * s, c.w, s, C(0x6A7682))
            for x in stride(from: 0, to: c.w, by: 8 * s) { c.rect(x, gal - 9 * s, s, 9 * s, C(0x6A7682)) }
            // The lift shaft: a steel frame and dark glass climbing from the floor through the ceiling and the rock.
            let sx0 = f.shaft.x - f.shaft.w / 2
            c.rect(sx0 - 2 * s, house, f.shaft.w + 4 * s, g - house, C(0x5A646C))
            c.rect(sx0, house, f.shaft.w, g - house, C(0x22303A))
            for y in stride(from: house + 6 * s, to: g - 30 * s, by: 24 * s) {
                slayerLine(c, Double(sx0), Double(y), Double(sx0 + f.shaft.w), Double(y + 24 * s), C(0x3A4852), Double(s) * 0.6)
                c.rect(sx0, y, f.shaft.w, s, C(0x4A5862))
            }
            for x in [f.shaft.x - 4 * s, f.shaft.x + 3 * s] { c.rect(x, house, s, g - house, C(0x8A949C)) }
        } else {
            // The ceiling: strip lights in a grey soffit.
            let ch = f.ceil
            c.rect(0, 0, c.w, ch, C(0x7A868E)); c.rect(0, ch - s, c.w, s, C(0x5A646C))
            for x in stride(from: 10 * s, to: c.w, by: 48 * s) { c.rect(x, s, 26 * s, ch - 3 * s, C(0xF0F6F8)); c.rect(x, ch - 3 * s, 26 * s, s, C(0xC8D8E0)) }
            for x in stride(from: 23 * s, to: c.w, by: 48 * s) { c.ellipse(x, f.ceil + 2 * s, 20 * s, 8 * s, C(0xFFFFFF, 0.16)) }
        }
        // The lift doors and their floor light.
        let lx = f.shaft.x - 11 * s, lh = 28 * s
        c.rect(lx - 2 * s, g - lh - 2 * s, 26 * s, lh + 2 * s, C(0x5A646C))
        c.rect(lx, g - lh, 22 * s, lh, C(0x9AA4AC)); c.rect(lx + 11 * s, g - lh, s, lh, C(0x5A646C))
        c.rect(lx, g - lh, 22 * s, s, C(0xC0CAD0))
        c.rect(lx + 9 * s, g - lh - 6 * s, 4 * s, 3 * s, C(0x1A2228))
        // Room 314's blast door: hazard stripes round a heavy steel door, the number stencilled above.
        let dx = f.door, dw = 34 * s, dh = 32 * s
        for y in (g - dh - 3 * s)..<g {
            for x in (dx - 3 * s)..<(dx + dw + 3 * s) where x < dx || x >= dx + dw || y < g - dh {
                c.px(x, y, ((x + y) / (3 * s)) % 2 == 0 ? C(0xE8C020) : C(0x1E1E1E))
            }
        }
        c.rect(dx, g - dh, dw, dh, C(0x6A747C))
        c.rect(dx, g - dh, dw, s, C(0x9AA4AC)); c.rect(dx + dw / 2, g - dh, s, dh, C(0x3E464E))
        for y in stride(from: g - dh + 5 * s, to: g - 2 * s, by: 7 * s) { c.rect(dx + 2 * s, y, dw - 4 * s, s, C(0x5A646C)) }
        c.rect(dx + dw / 2 - 4 * s, g - dh / 2 - 3 * s, 8 * s, 6 * s, C(0x4A545C)); c.circle(dx + dw / 2, g - dh / 2, 2 * s, C(0x8A949C))
        slayerP3Sign(c, dx + dw + 10 * s, g - dh, "314", C(0x2E3A44), 2 * s)
        c.rect(dx + dw + 6 * s, g - 20 * s, 5 * s, 7 * s, C(0x2A3238)); c.rect(dx + dw + 7 * s, g - 19 * s, 3 * s, 2 * s, C(0x4AE0F0))
        // The console: a bank of readouts.
        let kx = c.w * 25 / 100, ky = g - 30 * s
        c.rect(kx, ky, 44 * s, 18 * s, C(0x3E4850)); c.rect(kx, ky, 44 * s, s, C(0x6A7682))
        for k in 0..<3 {
            c.rect(kx + 2 * s + k * 14 * s, ky + 3 * s, 12 * s, 8 * s, C(0x0E1A20))
            for j in 0..<3 { c.rect(kx + 3 * s + k * 14 * s, ky + 4 * s + j * 2 * s, (3 + Int(noise(k * 5 + j) * 8)) * s, s, k == 1 ? C(0x7AE8A0) : C(0x4AD0E8)) }
        }
        for k in 0..<8 { c.rect(kx + 3 * s + k * 5 * s, ky + 13 * s, 2 * s, 2 * s, [C(0xE84A3A), C(0x4AE07A), C(0xE8C020)][k % 3]) }
        // The holding cells: deep recesses, a bench, emitters top and bottom, a status light over each.
        for (k, x) in f.cells.enumerated() {
            let top = f.cellTop
            c.rect(x - 2 * s, top - 2 * s, f.cellW + 4 * s, g - top + 2 * s, C(0x6A7682))
            c.rect(x, top, f.cellW, g - top, C(0x1E2A32))
            c.rect(x + 2 * s, g - 9 * s, f.cellW - 4 * s, 2 * s, C(0x5A6670)); c.rect(x + 4 * s, g - 7 * s, s, 7 * s, C(0x4A5660))
            c.rect(x + f.cellW - 5 * s, g - 7 * s, s, 7 * s, C(0x4A5660))
            c.rect(x, top, f.cellW, 2 * s, C(0x8A949C)); c.rect(x, g - 2 * s, f.cellW, 2 * s, C(0x8A949C))
            for e in stride(from: x + 2 * s, to: x + f.cellW - s, by: 4 * s) { c.rect(e, top + s, s, s, C(0x7AF0FF)); c.rect(e, g - s, s, s, C(0x7AF0FF)) }
            c.rect(x + f.cellW / 2 - 3 * s, top - 7 * s, 6 * s, 3 * s, C(0x2A3238))
            c.rect(x + f.cellW / 2 - 2 * s, top - 6 * s, s, s, C(0x4AE07A)); c.rect(x + f.cellW / 2 + s, top - 6 * s, s, s, k == 1 ? C(0xE84A3A) : C(0x4AE07A))
        }
        // The polished floor, the strip lights caught in it.
        c.ground(g, C(0x3A4248), edge: C(0x6A7682), speck: C(0x343C42), seed: 47)
        for x in stride(from: 23 * s, to: c.w, by: 48 * s) { c.rect(x - 8 * s, g + 3 * s, 16 * s, s, C(0x5A666E)) }
    }

    /// The Initiative's life: the force fields shimmer across the cells, a hostile paces behind the middle one, the red
    /// warning light over Room 314 turns, and on the screen saver the lift car rides up and down its shaft.
    static func slayerInitiativeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerInitiativeFrame(c, g)
        let top = f.cellTop + 2 * s, h = g - 2 * s - top
        // The demon in the middle cell: a hunched shape with horns and two glowing eyes, pacing.
        let mx = f.cells[1] + f.cellW / 2 + Int(sin(t * 0.6) * Double(7 * s))
        let hide = C(0x4A5A36)
        c.rect(mx - 5 * s, g - 17 * s, 10 * s, 13 * s, hide); c.circle(mx + 2 * s, g - 19 * s, 4 * s, hide)
        c.rect(mx - 4 * s, g - 4 * s, 2 * s, 4 * s, hide); c.rect(mx + 2 * s, g - 4 * s, 2 * s, 4 * s, hide)
        c.rect(mx - s, g - 25 * s, s, 3 * s, C(0xC8B890)); c.rect(mx + 5 * s, g - 25 * s, s, 3 * s, C(0xC8B890))
        c.rect(mx + s, g - 20 * s, s, s, C(0xF0E040)); c.rect(mx + 4 * s, g - 20 * s, s, s, C(0xF0E040))
        // The fields.
        for (k, x) in f.cells.enumerated() {
            let a = 0.16 + 0.06 * sin(t * 3 + Double(k))
            c.rect(x, top, f.cellW, h, C(0x5AE8FF, a))
            let scan = top + Int(frac(t * 0.5 + Double(k) * 0.33) * Double(h))
            c.rect(x, scan, f.cellW, s, C(0xB0F8FF, 0.5))
            for j in 0..<3 {
                let vx = x + Int(frac(noise(k * 9 + j) + t * 0.15 * Double(j + 1)) * Double(f.cellW - s))
                c.rect(vx, top, s, h, C(0x9AF4FF, 0.18))
            }
        }
        // The warning light over the blast door: a red beacon pulsing.
        let bx = f.door + 17 * s, byy = g - 32 * s - 8 * s
        let on = 0.5 + 0.5 * sin(t * 5)
        c.rect(bx - 2 * s, byy, 4 * s, 3 * s, C(0x8A1A14)); c.rect(bx - 2 * s, byy, 4 * s, 3 * s, C(0xFF3A2A, on))
        c.ellipse(bx, byy + s, 12 * s, 6 * s, C(0xFF2A1A, 0.14 * on))
        // The lift's floor light, and the car itself on the screen saver.
        c.rect(f.shaft.x - 2 * s, g - 33 * s, 4 * s, s, C(0xF0B030, frac(t / 8) < 0.5 ? 1 : 0.3))
        if let house = f.house {
            let travel = Double(g - 34 * s - house)
            let k = 0.5 - 0.5 * cos(t * 2 * .pi / 24)
            let cy = house + Int(k * travel), cw = f.shaft.w - 4 * s
            let cx = f.shaft.x - cw / 2
            c.rect(f.shaft.x, house, s, max(0, cy - house), C(0x2A3238))
            c.rect(cx, cy, cw, 30 * s, C(0x8A949C)); c.rect(cx, cy, cw, 2 * s, C(0xC0CAD0))
            c.rect(cx + 2 * s, cy + 4 * s, cw - 4 * s, 24 * s, C(0xE8F0F2, 0.85)); c.rect(cx + cw / 2, cy + 4 * s, s, 24 * s, C(0x8A949C))
        }
    }
}

// MARK: - The Mayor's office

extension Scenes {
    /// Where things stand in the Mayor's office: the cornice (or the dome's base on the screen saver), the fan, the
    /// window, the desk and the flag.
    static func slayerCityHallFrame(_ c: PixelCanvas, _ g: Int) -> (cornice: Int, fan: (x: Int, y: Int, r: Int),
                                                                   window: (x: Int, y: Int, w: Int, h: Int), desk: Int,
                                                                   flag: Int, dome: Bool) {
        let s = unit(g), tall = isTall(c)
        let cornice = tall ? g - 134 * s : 4 * s
        let fan = (x: c.w * 43 / 100, y: tall ? g - 52 * s : 9 * s, r: (tall ? 26 : 18) * s)
        let wy = tall ? cornice + 16 * s : 11 * s
        let window = (x: c.w * 78 / 100, y: wy, w: 46 * s, h: g - 24 * s - wy)
        return (cornice, fan, window, c.w * 50 / 100, c.w * 31 / 100, tall)
    }

    /// The Mayor's office at City Hall, all good cheer and civic pride: sage-green walls above cherry panelling with a
    /// brass rail, the big mahogany desk with its blotter, a framed photo and a box of hand wipes, the high-backed green
    /// leather chair, the flag on its pole with a gold eagle, his tall cabinet of things a mayor shouldn't keep, the
    /// sunny window behind venetian blinds, and a green carpet. On the screen saver a coffered dome rises overhead
    /// round its oculus, and a wall of portraits shows every Mayor of Sunnydale for a hundred years, all of them him.
    static func slayerCityHall(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = slayerCityHallFrame(c, g)
        let sage = C(0x6E8466), sageD = C(0x5E7458), cherry = C(0x5A2A22), cherryL = C(0x7A3A2C), cherryD = C(0x3A1A16)
        let brass = C(0xC8A04A), cream = C(0xE4D8B8)
        let wain = g - 22 * s
        // The ceiling: a cream cornice, or the dome on the screen saver.
        if f.dome {
            // A coffered dome seen from the floor: bands of coffers round it, ribs running up to the oculus.
            let base = f.cornice, cx = c.w / 2, ry = base - 6 * s, rx = c.w * 54 / 100
            c.rect(0, 0, c.w, base, C(0x6A5A40))
            for y in (base - ry)..<base {
                let k = Double(base - y) / Double(ry), half = Int(Double(rx) * (1 - k * k).squareRoot())
                let band = Int(k * 7)
                c.rect(cx - half, y, half * 2, 1, band % 2 == 0 ? C(0xD8C89C) : C(0xC4B286))
            }
            for band in 0..<6 {
                let th = (Double(band) + 0.5) / 7 * .pi / 2
                let y = base - Int(sin(th) * Double(ry)), ringR = cos(th) * Double(rx)
                let n = 14 - band * 2
                for j in 0..<n {
                    let ph = -1.35 + 2.7 * (Double(j) + 0.5) / Double(n)
                    let x = cx + Int(sin(ph) * ringR), cw = max(2 * s, Int(Double(12 * s) * cos(ph) * cos(th) + Double(s)))
                    let chh = max(3 * s, Int(Double(8 * s) * cos(th)))
                    c.rect(x - cw / 2, y - chh / 2, cw, chh, C(0x8A7A52)); c.rect(x - cw / 2 + s, y - chh / 2 + s, max(1, cw - 2 * s), max(1, chh - 2 * s), C(0xA8966A))
                    c.rect(x - cw / 2 + s, y - chh / 2 + s, max(1, cw - 2 * s), s, C(0x6A5A3A))
                }
            }
            for j in 0..<9 {
                let ph = -1.4 + 2.8 * Double(j) / 8
                var last: (Double, Double)? = nil
                for q in 0...10 {
                    let th = Double(q) / 10 * 1.35
                    let pt = (Double(cx) + sin(ph) * cos(th) * Double(rx), Double(base) - sin(th) * Double(ry))
                    if let l = last { slayerLine(c, l.0, l.1, pt.0, pt.1, C(0xE8DCB8), Double(s) * 0.5) }
                    last = pt
                }
            }
            let oy = base - ry * 96 / 100
            c.ellipse(cx, oy + 3 * s, rx * 14 / 100, 7 * s, C(0xC8A04A))
            c.ellipse(cx, oy + 3 * s, rx * 11 / 100, 5 * s, C(0xA8D4F0))
            // A soft shaft of light falling from the oculus.
            for y in (oy + 8 * s)..<g {
                let k = Double(y - oy) / Double(g - oy)
                let half = Int(Double(rx) * 0.1 + k * Double(24 * s))
                c.rect(cx - half + Int(k * Double(30 * s)), y, 2 * half, 1, C(0xFFF4D0, 0.06))
            }
        } else {
            c.rect(0, 0, c.w, f.cornice, cream)
        }
        // The walls: sage stripes over cherry panelling, a cream cornice along the top.
        c.rect(0, f.cornice, c.w, wain - f.cornice, sage)
        for x in stride(from: 0, to: c.w, by: 6 * s) { c.rect(x, f.cornice, 2 * s, wain - f.cornice, sageD) }
        c.rect(0, wain, c.w, 22 * s, cherry); c.rect(0, wain, c.w, s, cherryL)
        for x in stride(from: 4 * s, to: c.w, by: 20 * s) {
            c.rect(x, wain + 4 * s, 16 * s, 14 * s, cherryD.alpha(0.6)); c.rect(x + s, wain + 5 * s, 14 * s, s, cherryL.alpha(0.5))
        }
        c.rect(0, wain - 2 * s, c.w, 2 * s, brass); c.rect(0, wain - s, c.w, s, C(0x8A6A2A))
        if f.dome {
            c.rect(0, f.cornice, c.w, 5 * s, cream); c.rect(0, f.cornice + 5 * s, c.w, s, C(0xB4A276))
            for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, f.cornice + 2 * s, 2 * s, 2 * s, C(0xC8BA94)) }
            // The portrait wall: the Mayors of Sunnydale down the years, every one of them the same pink, smiling man.
            for (r, py) in [f.cornice + 14 * s, f.cornice + 46 * s].enumerated() {
                for k in 0..<12 {
                    let px = 10 * s + k * 28 * s + r * 14 * s
                    guard px + 20 * s < f.window.x - 12 * s else { continue }
                    let i = r * 12 + k
                    c.rect(px, py, 20 * s, 26 * s, brass); c.rect(px + s, py + s, 18 * s, 24 * s, [C(0x3A2A20), C(0x2A3A3A), C(0x4A3A2A)][i % 3])
                    c.rect(px + 4 * s, py + 17 * s, 12 * s, 8 * s, [C(0x1A1A22), C(0x3A2A1A), C(0x2A2A3A)][i % 3])
                    c.rect(px + 8 * s, py + 17 * s, 4 * s, 2 * s, C(0xF0ECE0))
                    c.circle(px + 10 * s, py + 11 * s, 4 * s, C(0xE8B49A))
                    c.rect(px + 6 * s, py + 6 * s, 8 * s, 2 * s, [C(0x6A4A2A), C(0xC8C8C8), C(0x3A2A1A), C(0x8A6A3A)][i % 4])
                    if i % 3 == 1 { c.rect(px + 8 * s, py + 14 * s, 4 * s, 2 * s, C(0x8A6A3A)) }   // the whiskers of 1903
                    if i % 4 == 2 { c.rect(px + 5 * s, py + 5 * s, 10 * s, 2 * s, C(0x1A1A1A)); c.rect(px + 7 * s, py + s, 6 * s, 4 * s, C(0x1A1A1A)) }   // a top hat
                    c.rect(px + 8 * s, py + 13 * s, 4 * s, s, C(0x9A4A3A))
                }
            }
        } else {
            c.rect(0, f.cornice, c.w, s, C(0xB4A276))
        }
        // The window: green drapes, venetian blinds with the Sunnydale sun behind them.
        let w = f.window
        c.rect(w.x - 3 * s, w.y - 3 * s, w.w + 6 * s, w.h + 5 * s, cherryD)
        c.rect(w.x, w.y, w.w, w.h, C(0xF4E8B0))
        c.rect(w.x, w.y + w.h * 2 / 3, w.w, w.h / 3, C(0xA8C8E0))
        for y in stride(from: w.y, to: w.y + w.h, by: 3 * s) { c.rect(w.x, y + s, w.w, s, C(0xC8B888)); c.rect(w.x, y + 2 * s, w.w, s, C(0xE4D49C)) }
        c.rect(w.x + w.w / 2 - s / 2, w.y, s, w.h, cherryD)
        c.rect(w.x - 8 * s, w.y - 4 * s, w.w + 16 * s, 3 * s, brass)
        for side in [w.x - 9 * s, w.x + w.w + 2 * s] {
            c.rect(side, w.y - s, 7 * s, w.h + 3 * s, C(0x2E5A3A)); c.rect(side + 2 * s, w.y - s, s, w.h + 3 * s, C(0x3E7A4E))
            c.rect(side + 5 * s, w.y - s, s, w.h + 3 * s, C(0x1E3A26))
        }
        // The cabinet, tall and locked.
        let kx = c.w * 6 / 100, kh = min(46 * s, g - f.cornice - 4 * s), ky = g - kh
        c.rect(kx, ky, 30 * s, kh, cherry); c.rect(kx, ky, 30 * s, 2 * s, cherryL); c.rect(kx - s, ky - 2 * s, 32 * s, 2 * s, cherryD)
        c.rect(kx + 14 * s + s / 2, ky + 2 * s, s, kh - 6 * s, cherryD)
        for dx in [kx + 2 * s, kx + 16 * s] { c.rect(dx, ky + 4 * s, 12 * s, kh - 12 * s, cherryD.alpha(0.5)); c.rect(dx + s, ky + 5 * s, 10 * s, s, cherryL.alpha(0.6)) }
        c.rect(kx + 12 * s, ky + kh / 2, 2 * s, 3 * s, brass); c.rect(kx + 17 * s, ky + kh / 2, 2 * s, 3 * s, brass)
        c.rect(kx + 2 * s, g - 4 * s, 26 * s, 4 * s, cherryD)
        // The flag on its pole: stripes, a blue canton of stars, the gold eagle on top.
        let fx = f.flag, ftop = g - min(52 * s, g - f.cornice - 6 * s)
        c.rect(fx, ftop, s, g - ftop, brass); c.rect(fx - 3 * s, g - 2 * s, 7 * s, 2 * s, brass)
        c.rect(fx - 2 * s, ftop - 2 * s, 5 * s, 2 * s, C(0xE0B850)); c.rect(fx - s, ftop - 4 * s, 3 * s, 2 * s, C(0xE0B850))
        let fw = 16 * s, fh = 24 * s, fy = ftop + 2 * s
        for k in 0..<(fh / s) {
            let sway = Int(sin(Double(k) * 0.4) * Double(s))
            c.rect(fx + s + sway, fy + k * s, fw - k * s / 3, s, (k / 2) % 2 == 0 ? C(0xB02A2A) : C(0xF0ECE0))
        }
        c.rect(fx + s, fy, 8 * s, 10 * s, C(0x22306A))
        for k in 0..<6 { c.rect(fx + 2 * s + (k % 3) * 2 * s, fy + 2 * s + (k / 3) * 4 * s, s, s, C(0xF0ECE0)) }
        // The chair behind the desk, and the desk.
        let dx = f.desk, dw = 60 * s, dt = g - 17 * s
        c.rect(dx + 20 * s, dt - 18 * s, 20 * s, 20 * s, C(0x1E4A30)); c.rect(dx + 21 * s, dt - 17 * s, 18 * s, s, C(0x2E6A44))
        for k in 0..<3 { c.rect(dx + 23 * s + k * 6 * s, dt - 14 * s, s, s, brass) }
        c.rect(dx, dt, dw, 3 * s, C(0x6A2E22)); c.rect(dx, dt, dw, s, C(0x8A4A34))
        c.rect(dx + 2 * s, dt + 3 * s, dw - 4 * s, 14 * s, C(0x4A2018))
        for px in [dx + 4 * s, dx + dw - 22 * s] {
            c.rect(px, dt + 5 * s, 18 * s, 10 * s, C(0x3A1812)); c.rect(px + s, dt + 6 * s, 16 * s, s, C(0x6A2E22))
        }
        c.rect(dx + 23 * s, dt + 6 * s, 14 * s, 3 * s, brass); c.rect(dx + 24 * s, dt + 7 * s, 12 * s, s, C(0x8A6A2A))   // the nameplate
        c.rect(dx + 18 * s, dt - s, 24 * s, s, C(0x2E5A3A))    // the blotter
        c.rect(dx + 5 * s, dt - 6 * s, 6 * s, 6 * s, brass); c.rect(dx + 6 * s, dt - 5 * s, 4 * s, 4 * s, C(0x8AA0B8))   // the photo
        c.rect(dx + 46 * s, dt - 3 * s, 6 * s, 3 * s, C(0xF0F4F8)); c.rect(dx + 48 * s, dt - 4 * s, 2 * s, s, C(0xF0F4F8))   // the hand wipes
        c.rect(dx + 30 * s, dt - 3 * s, s, 2 * s, C(0x1A1A1A)); c.rect(dx + 33 * s, dt - 3 * s, s, 2 * s, C(0x1A1A1A))
        // The light through the blinds on the carpet, and the carpet itself with its border.
        c.ground(g, C(0x24402E), edge: C(0x3E6A4A), speck: C(0x1E3626), seed: 73)
        c.rect(0, g + 3 * s, c.w, s, C(0x8A6A2A).alpha(0.6))
        for k in 0..<4 { c.rect(w.x - 30 * s + k * 6 * s, g + 5 * s, 22 * s, s, C(0xF4E8B0, 0.12)) }
        // The ceiling fan's motor and rod; its blades turn in the moving layer.
        let fn = f.fan
        c.rect(fn.x, f.cornice, s, fn.y - f.cornice, C(0x6A5A3A))
        c.rect(fn.x - 3 * s, fn.y - s, 7 * s, 3 * s, brass); c.rect(fn.x - 2 * s, fn.y + 2 * s, 5 * s, s, C(0x8A6A2A))
    }

    /// The Mayor's office's life: the ceiling fan turning slowly, its shadow sweeping, and dust in the window light.
    static func slayerCityHallLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerCityHallFrame(c, g), fn = f.fan
        let wood = C(0x4A2018), woodL = C(0x7A3A2C)
        for k in 0..<4 {
            let a = t * 1.4 + Double(k) * .pi / 2
            let dx = Int((cos(a) * Double(fn.r)).rounded()), dy = Int((sin(a) * Double(fn.r) * 0.18).rounded())
            slayerLine(c, Double(fn.x), Double(fn.y + s), Double(fn.x + dx), Double(fn.y + s + dy), sin(a) > 0 ? woodL : wood, Double(s) * 0.9)
        }
        c.rect(fn.x - s, fn.y, 3 * s, 2 * s, C(0xC8A04A))
        let w = f.window
        for k in 0..<10 {
            let ph = frac(t * 0.03 + noise(k + 840))
            let x = w.x - Int(ph * Double(50 * s)) + Int(noise(k + 850) * Double(w.w))
            let y = w.y + Int(frac(noise(k + 860) + t * 0.015) * Double(g - w.y))
            c.px(x, y, C(0xFFF4C8, 0.3 + 0.3 * sin(t * 2 + Double(k))))
        }
    }
}

// MARK: - Glory's tower

extension Scenes {
    /// Where things stand at Glory's tower: its centre, its width at the foot and at the top, the platform at the top
    /// (off the top of the window's strip), the levels of planking, and the portal over the platform.
    static func slayerTowerFrame(_ c: PixelCanvas, _ g: Int) -> (x: Int, base: Int, top: Int, plat: Int, levels: [Int],
                                                               portal: (x: Int, y: Int, rx: Int, ry: Int)?) {
        let s = unit(g), tall = isTall(c), x = c.w * 50 / 100
        let plat = tall ? max(64 * s, g - 214 * s) : -40 * s
        var levels: [Int] = [], y = g - 15 * s
        while y > plat + 8 * s { levels.append(y); y -= (13 + Int(noise(y / s + 870) * 7)) * s }
        levels.append(plat)
        let portal = tall ? (x: x, y: plat - 30 * s, rx: 9 * s, ry: 26 * s) : nil
        return (x, (tall ? 150 : 140) * s, 48 * s, plat, levels, portal)
    }

    /// How wide the tower is at row `y`.
    static func slayerTowerWidth(_ f: (x: Int, base: Int, top: Int, plat: Int, levels: [Int], portal: (x: Int, y: Int, rx: Int, ry: Int)?),
                                 _ g: Int, _ y: Int) -> Int {
        let k = max(0, min(1, Double(g - y) / Double(max(1, g - f.plat))))
        return f.base + Int(Double(f.top - f.base) * k)
    }

    /// Glory's tower from "The Gift": a rickety scaffold of poles and planks lashed together in a vacant lot, braced
    /// with crossed timbers, a zigzag of stairs climbing it, under a storm sky lit sickly lime-white from above. Oil
    /// drums and a broken chain-link fence at its foot, Sunnydale's rooftops low behind. On the screen saver the whole
    /// tower climbs to its platform, Dawn a small figure at the edge, the portal a tear of green-white light over her,
    /// the clouds wheeling round it.
    static func slayerTower(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerTowerFrame(c, g)
        c.gradient(0, g, C(0x26302A), C(0x10141A), bands: 7)
        // The storm clouds, lit from the portal: heavy banks, brighter towards the light.
        let cy = f.portal?.y ?? -30 * s
        for k in 0..<(tall ? 26 : 12) {
            let ang = noise(k + 900) * 2 * .pi, d = (0.25 + 0.75 * noise(k + 910)) * Double(c.w) * 0.55
            let x = f.x + Int(cos(ang) * d), y = cy + Int(sin(ang) * d * 0.35) + (tall ? 0 : 20 * s)
            let lit = max(0, 1 - d / (Double(c.w) * 0.55))
            let rw = (24 + Int(noise(k + 920) * 30)) * s, rh = (5 + Int(noise(k + 930) * 5)) * s
            let body = lerp(C(0x28322E), C(0x6A8A5E), lit * 0.8), rim = lerp(C(0x34403A), C(0xA8C890), lit * 0.8)
            for q in 0..<3 {
                let qx = x + (q - 1) * rw * 2 / 3, qy = y - (q == 1 ? rh / 2 : 0), qr = q == 1 ? rh + 2 * s : rh
                c.ellipse(qx, qy - s, rw / 2 + 2 * s, qr, rim.alpha(0.8))
                c.ellipse(qx, qy + s, rw / 2 + 2 * s, qr, body.alpha(0.9))
            }
        }
        // The glow from the top.
        for k in 0..<8 {
            c.ellipse(f.x, cy, (40 + k * 32) * s, (30 + k * 20) * s, C(0xC8FF9A, 0.03))
        }
        // Sunnydale low behind: rooftops, a water tower, a few lit windows.
        let roof = g - 14 * s
        var x = 0, i = 0
        while x < c.w {
            let bw = (14 + Int(noise(i + 940) * 22)) * s, bh = (6 + Int(noise(i + 950) * 14)) * s
            c.rect(x, roof - bh, bw, g - roof + bh, C(0x141A1C))
            if noise(i + 960) > 0.5 { c.rect(x + 3 * s, roof - bh + 3 * s, s, s, C(0xE8C878, 0.7)) }
            x += bw; i += 1
        }
        let wt = c.w * 86 / 100
        c.rect(wt - 6 * s, roof - 30 * s, 12 * s, 8 * s, C(0x141A1C)); c.rect(wt - 5 * s, roof - 22 * s, s, 12 * s, C(0x141A1C))
        c.rect(wt + 4 * s, roof - 22 * s, s, 12 * s, C(0x141A1C)); c.ellipse(wt, roof - 30 * s, 6 * s, 2 * s, C(0x141A1C))
        // The tower: poles, planks, crossed braces, lashings.
        let pole = C(0x4A4232), poleL = C(0x8AA070), plank = C(0x5A5038), dark = C(0x2A2620)
        let fr = [-0.5, -0.17, 0.17, 0.5]
        for (j, q) in fr.enumerated() {
            var last: (Double, Double)? = nil
            for y in stride(from: g, through: f.plat - 6 * s, by: -4 * s) {
                let wob = (noise(j * 50 + y / (8 * s)) - 0.5) * Double(s)
                let pt = (Double(f.x) + q * Double(slayerTowerWidth(f, g, y)) + wob, Double(y))
                if let l = last { slayerLine(c, l.0, l.1, pt.0, pt.1, pole, Double(s) * 1.1) }
                last = pt
            }
        }
        for (n, y) in f.levels.enumerated() {
            let w = slayerTowerWidth(f, g, y), lw = n + 1 < f.levels.count ? slayerTowerWidth(f, g, f.levels[n + 1]) : w
            let x0 = f.x - w / 2, nextY = n + 1 < f.levels.count ? f.levels[n + 1] : y
            // The planking, a few boards missing.
            for k in stride(from: x0 - 3 * s, to: x0 + w + 3 * s, by: 6 * s) where noise(n * 31 + k / s) > 0.12 {
                c.rect(k, y, 6 * s - (noise(n * 17 + k) > 0.8 ? s : 0), 2 * s, plank)
            }
            c.rect(x0 - 3 * s, y, w + 6 * s, max(1, s / 2) + s / 2, poleL.alpha(0.7)); c.rect(x0 - 3 * s, y + 2 * s, w + 6 * s, s, dark)
            // Crossed braces in each bay, up to the next level.
            guard nextY < y else { continue }
            for b in 0..<3 {
                let qa = fr[b], qb = fr[b + 1]
                let ax = Double(f.x) + qa * Double(w), bx = Double(f.x) + qb * Double(w)
                let ax2 = Double(f.x) + qa * Double(lw), bx2 = Double(f.x) + qb * Double(lw)
                if (n + b) % 2 == 0 {
                    slayerLine(c, ax, Double(y), bx2, Double(nextY + 2 * s), dark, Double(s) * 0.6)
                } else {
                    slayerLine(c, bx, Double(y), ax2, Double(nextY + 2 * s), dark, Double(s) * 0.6)
                }
            }
            // The stairs: a flight in the middle bay, zigzagging up.
            let mid0 = Double(f.x) + fr[1] * Double(w), mid1 = Double(f.x) + fr[2] * Double(w)
            let (sx0, sx1) = n % 2 == 0 ? (mid0, mid1) : (mid1, mid0)
            let steps = max(3, (y - nextY) / (3 * s))
            for k in 0..<steps {
                let kk = Double(k) / Double(steps)
                let px = sx0 + (sx1 - sx0) * kk, py = Double(y) - Double(y - nextY) * kk
                c.rect(Int(px) - 2 * s, Int(py), 4 * s, s, plank)
            }
            slayerLine(c, sx0, Double(y - 6 * s), sx1, Double(nextY - 6 * s), pole, Double(s) * 0.5)
            // Rope lashings at the joints.
            for q in fr { c.rect(f.x + Int(q * Double(w)) - s, y - s, 3 * s, s, C(0x9A8A5A)) }
        }
        if tall, let p = f.portal {
            // The platform, its railing, and Dawn at the edge of it.
            let w = slayerTowerWidth(f, g, f.plat)
            c.rect(f.x - w / 2 - 6 * s, f.plat - s, w + 12 * s, 3 * s, plank)
            c.rect(f.x - w / 2 - 6 * s, f.plat - 8 * s, w + 12 * s, s, pole)
            for k in stride(from: f.x - w / 2 - 6 * s, to: f.x + w / 2 + 7 * s, by: 6 * s) { c.rect(k, f.plat - 8 * s, s, 7 * s, pole) }
            let dx = f.x + 5 * s
            c.rect(dx - 2 * s, f.plat - 11 * s, 4 * s, 10 * s, C(0x6A4A6A)); c.circle(dx, f.plat - 13 * s, 2 * s, C(0xE8C0A0))
            c.rect(dx - 2 * s, f.plat - 15 * s, 4 * s, 2 * s, C(0x5A3A22)); c.rect(dx + 2 * s, f.plat - 14 * s, s, 5 * s, C(0x5A3A22))
            // The portal: a tall tear of light, white at the heart, green at the edges.
            c.ellipse(p.x, p.y, p.rx * 3, p.ry + 8 * s, C(0xA8FF8A, 0.12))
            c.ellipse(p.x, p.y, p.rx * 2, p.ry + 4 * s, C(0xA8FF8A, 0.2))
            for y in (p.y - p.ry)...(p.y + p.ry) {
                let k = 1 - pow(Double(y - p.y) / Double(p.ry), 2)
                let half = Int(Double(p.rx) * k)
                c.rect(p.x - half, y, 2 * half + 1, 1, C(0x9AF07A)); c.rect(p.x - half / 2, y, half + 1, 1, C(0xF0FFE8))
            }
        }
        // The lot: oil drums, the broken fence, gravel.
        for (k, dx) in [c.w * 12 / 100, c.w * 15 / 100, c.w * 80 / 100].enumerated() {
            c.rect(dx, g - 10 * s, 7 * s, 10 * s, [C(0x5A3A2A), C(0x3A4A4A), C(0x5A3A2A)][k])
            c.rect(dx, g - 7 * s, 7 * s, s, C(0x2A2A2A)); c.rect(dx, g - 3 * s, 7 * s, s, C(0x2A2A2A)); c.rect(dx, g - 10 * s, 7 * s, s, C(0x7A6A5A))
        }
        for (x0, x1) in [(0, c.w * 9 / 100), (c.w * 88 / 100, c.w)] {
            c.rect(x0, g - 18 * s, x1 - x0, s, C(0x5A6266))
            for x in stride(from: x0, to: x1, by: 10 * s) { c.rect(x, g - 18 * s, s, 18 * s, C(0x5A6266)) }
            for y in stride(from: g - 17 * s, to: g, by: 2 * s) {
                for x in stride(from: x0 + (y / (2 * s)) % 2 * s, to: x1, by: 2 * s) { c.px(x, y, C(0x6A7276, 0.6)) }
            }
        }
        c.ground(g, C(0x24261E), edge: C(0x4A5236), speck: C(0x34362A), seed: 33)
    }

    /// The tower's life: green energy crawling up the poles, a lightning flash now and then, and on the screen saver
    /// the portal crackling, bolts forking out of it.
    static func slayerTowerLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerTowerFrame(c, g)
        let fr = [-0.5, -0.17, 0.17, 0.5]
        // Energy crawling along the poles.
        for j in 0..<3 {
            let q = fr[(j * 3 + Int(t * 0.7)) % 4], seed = Int(t * 8) * 7 + j * 101
            let lo = g - Int(frac(t * 0.25 + Double(j) * 0.37) * Double(g - max(f.plat, 0)))
            var last: (Double, Double)? = nil
            for k in 0..<6 {
                let y = lo - k * 4 * s
                guard y > 0 else { break }
                let pt = (Double(f.x) + q * Double(slayerTowerWidth(f, g, y)) + (noise(seed + k) - 0.5) * Double(5 * s), Double(y))
                if let l = last { slayerLine(c, l.0, l.1, pt.0, pt.1, C(0xD8FFB8, 0.85), Double(s) * 0.4) }
                last = pt
            }
        }
        // Lightning: a bright flicker of the whole sky, and a fork.
        let ph = frac(t / 7)
        if ph < 0.06 {
            let a = ph < 0.02 || (ph > 0.035 && ph < 0.05) ? 0.10 : 0.0
            c.rect(0, 0, c.w, g, C(0xE8FFE0, a))
            var x = Double(c.w) * (0.15 + 0.7 * noise(Int(t / 7) + 990)), y = 0.0
            while y < Double(g) * 0.6 {
                let nx = x + (noise(Int(y) + Int(t / 7) * 13) - 0.5) * Double(18 * s), ny = y + Double(10 * s)
                slayerLine(c, x, y, nx, ny, C(0xF0FFE8, 0.9), Double(s) * 0.5)
                x = nx; y = ny
            }
        }
        // The portal crackles.
        if let p = f.portal {
            for k in 0..<5 {
                let seed = Int(t * 10) * 11 + k * 37
                let a0 = noise(seed) * 2 * .pi
                var x = Double(p.x), y = Double(p.y) + (noise(seed + 1) - 0.5) * Double(p.ry)
                for q in 0..<5 {
                    let nx = x + cos(a0) * Double(8 * s) + (noise(seed + q + 2) - 0.5) * Double(8 * s)
                    let ny = y + sin(a0) * Double(5 * s) + (noise(seed + q + 9) - 0.5) * Double(8 * s)
                    slayerLine(c, x, y, nx, ny, C(0xE8FFD8, 0.9 - Double(q) * 0.15), Double(s) * 0.5)
                    x = nx; y = ny
                }
            }
            let pulse = 0.5 + 0.5 * sin(t * 4)
            c.ellipse(p.x, p.y, p.rx * 2, p.ry, C(0xC8FFB0, 0.08 + 0.1 * pulse))
        }
    }
}

// MARK: - The abandoned factory

extension Scenes {
    /// Where things stand in the factory: the brazier, the catwalks (lowest first), the swinging chain's pivot and
    /// length, and the roof line with its skylights on the screen saver.
    static func slayerFactoryFrame(_ c: PixelCanvas, _ g: Int) -> (brazier: Int, walks: [Int], chain: (x: Int, y: Int, len: Int),
                                                                  roof: Int?) {
        let s = unit(g), tall = isTall(c)
        let walks = tall ? [g - 42 * s, g - 100 * s, g - 158 * s] : [g - 42 * s]
        let roof = tall ? max(24 * s, g - 236 * s) : nil
        let chain = (x: c.w * 57 / 100, y: roof.map { $0 + 10 * s } ?? 0, len: tall ? (g - 26 * s - (roof ?? 0) - 10 * s) : g - 26 * s)
        return (c.w * 38 / 100, walks, chain, roof)
    }

    /// A length of chain from (x0, y0) to (x1, y1), links alternating light and dark.
    static func slayerChain(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ s: Int, light: Px, dark: Px) {
        let n = max(1, Int(hypot(x1 - x0, y1 - y0) / Double(2 * s)))
        for k in 0...n {
            let kk = Double(k) / Double(n)
            let x = Int(x0 + (x1 - x0) * kk), y = Int(y0 + (y1 - y0) * kk)
            if k % 2 == 0 { c.rect(x - s / 2, y, max(1, s), 2 * s, light) } else { c.rect(x - s, y, 2 * s, max(1, s), dark) }
        }
    }

    /// The abandoned factory where Spike and Drusilla held court: rusted corrugated walls and old brick, a catwalk on
    /// I-beams across the back with stairs up to it, chains hanging from the dark with hooks on the ends, pipes and a
    /// great seized flywheel, crates, Spike's wheelchair parked by them, and the big iron brazier in the middle throwing
    /// orange light over everything. On the screen saver two more catwalks cross above, a gantry crane's beam runs
    /// under the roof, and moonlight falls in cold shafts through the broken sawtooth skylights.
    static func slayerFactory(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = slayerFactoryFrame(c, g), bx = f.brazier
        let rust = C(0x3A2216), rustD = C(0x24140E), iron = C(0x2A2624), ironL = C(0x4A403A)
        c.gradient(0, g, C(0x140C0A), rust, bands: 6)
        // Corrugated panels on the upper wall, old brick below them.
        let brickTop = g - 30 * s
        for x in stride(from: 0, to: c.w, by: 3 * s) { c.rect(x, 0, s, brickTop, rustD.alpha(0.5)) }
        for x in stride(from: 0, to: c.w, by: 36 * s) { c.rect(x, 0, s, brickTop, C(0x0E0806, 0.6)) }
        for k in 0..<12 {
            let x = Int(noise(k + 1100) * Double(c.w)), y = Int(noise(k + 1110) * Double(brickTop))
            c.rect(x, y, (3 + Int(noise(k + 1120) * 6)) * s, (10 + Int(noise(k + 1130) * 20)) * s, C(0x6A3418, 0.25))   // rust streaks
        }
        c.rect(0, brickTop, c.w, g - brickTop, C(0x3A1E16))
        for (row, y) in stride(from: brickTop, to: g, by: 4 * s).enumerated() {
            c.rect(0, y, c.w, s, C(0x1E100C))
            for x in stride(from: row % 2 == 0 ? 0 : 4 * s, to: c.w, by: 8 * s) { c.rect(x, y, s, 4 * s, C(0x1E100C)) }
        }
        // The brazier's light on the walls.
        for k in 0..<5 { c.ellipse(bx, g - 14 * s, (70 + k * 36) * s, (36 + k * 18) * s, C(0xFF8A2A, 0.05)) }
        if let roof = f.roof {
            // The sawtooth roof with its broken skylights, moonlight leaking in.
            c.rect(0, 0, c.w, roof, C(0x0A0606))
            let bay = 60 * s
            for x0 in stride(from: 0, to: c.w, by: bay) {
                for k in 0..<bay {
                    let h = (bay - k) * (roof - 6 * s) / bay
                    c.rect(x0 + k, roof - h, 1, h, C(0x1A100C))
                }
                // The glazing on the steep face, panes missing.
                for y in stride(from: 6 * s, to: roof - 2 * s, by: 5 * s) {
                    for q in 0..<3 where noise(x0 + y + q * 7) > 0.3 {
                        c.rect(x0 + q * 3 * s + s, y, 2 * s, 4 * s, C(0x3A4A6A))
                    }
                }
                c.rect(x0, 6 * s, s, roof - 6 * s, iron)
            }
            c.rect(0, roof, c.w, 3 * s, iron); c.rect(0, roof, c.w, s, ironL)
            // The moonlight's shafts, falling at a slant.
            for x0 in stride(from: 4 * s, to: c.w, by: bay * 2) {
                for y in roof..<(g - 8 * s) {
                    let d = Double(y - roof) * 0.35
                    c.rect(x0 + Int(d), y, 8 * s, 1, C(0x9AB4E8, 0.07))
                }
            }
            // The gantry crane's beam, and the hoist block hanging under it.
            let gy = roof + 12 * s
            c.rect(0, gy, c.w, 6 * s, iron); c.rect(0, gy, c.w, s, ironL); c.rect(0, gy + 5 * s, c.w, s, C(0x16100E))
            for x in stride(from: 0, to: c.w, by: 10 * s) { slayerLine(c, Double(x), Double(gy + s), Double(x + 5 * s), Double(gy + 5 * s), C(0x16100E), Double(s) * 0.4) }
            c.rect(c.w * 22 / 100, gy + 6 * s, 10 * s, 6 * s, C(0xA88A2A)); c.rect(c.w * 22 / 100, gy + 6 * s, 10 * s, s, C(0xC8A84A))
            slayerChain(c, Double(c.w * 22 / 100 + 5 * s), Double(gy + 12 * s), Double(c.w * 22 / 100 + 5 * s), Double(f.walks[1] - 20 * s), s,
                        light: C(0x6A5A4A), dark: C(0x3A302A))
            // Big factory windows between the upper catwalks, grimy and broken.
            for x in stride(from: 30 * s, to: c.w - 40 * s, by: 90 * s) {
                let wy = f.walks[2] + 10 * s, wh = f.walks[1] - f.walks[2] - 22 * s
                c.rect(x - 2 * s, wy - 2 * s, 44 * s, wh + 4 * s, iron)
                c.rect(x, wy, 40 * s, wh, C(0x1E2434))
                for yy in stride(from: wy, to: wy + wh, by: 6 * s) {
                    for xx in stride(from: x, to: x + 40 * s, by: 8 * s) {
                        let n = noise(xx * 3 + yy)
                        c.rect(xx + s, yy + s, 6 * s, 4 * s, n > 0.85 ? C(0x0A0A10) : n > 0.5 ? C(0x2E3A50) : C(0x3A4458))
                    }
                }
            }
        }
        // The flywheel, seized with rust, on the back wall at the right.
        let fx = c.w * 84 / 100, fy = f.walks[0] - (f.roof == nil ? 2 * s : 14 * s), fr = (f.roof == nil ? 15 : 24) * s
        c.circle(fx, fy, fr, iron); c.circle(fx, fy, fr - 3 * s, C(0x24140E))
        for k in 0..<6 {
            let a = Double(k) / 6 * .pi
            slayerLine(c, Double(fx) - cos(a) * Double(fr - 2 * s), Double(fy) - sin(a) * Double(fr - 2 * s),
                       Double(fx) + cos(a) * Double(fr - 2 * s), Double(fy) + sin(a) * Double(fr - 2 * s), iron, Double(s) * 0.8)
        }
        c.circle(fx, fy, 3 * s, ironL); c.rect(fx - fr, fy - fr / 2, 3 * s, 3 * s, C(0x7A3A1A))
        // Pipes along the wall.
        for (k, py) in [brickTop - 6 * s, brickTop - 10 * s].enumerated() {
            c.rect(0, py, c.w, 2 * s, k == 0 ? C(0x4A3A2A) : C(0x3A3A36)); c.rect(0, py, c.w, max(1, s / 2), C(0x6A5240))
            for x in stride(from: 30 * s + k * 50 * s, to: c.w, by: 110 * s) { c.rect(x, py - s, 3 * s, 4 * s, ironL) }
        }
        // The catwalks: grating on I-beams, a railing, posts down to the floor.
        for (n, wy) in f.walks.enumerated() {
            let x0 = n == 1 ? c.w * 30 / 100 : 0, x1 = n == 1 ? c.w : c.w * (n == 0 ? 100 : 76) / 100
            c.rect(x0, wy, x1 - x0, 3 * s, iron); c.rect(x0, wy, x1 - x0, s, C(0x6A5A4A))
            for x in stride(from: x0, to: x1, by: 2 * s) { c.rect(x, wy + s, s, s, C(0x16100E)) }
            c.rect(x0, wy - 8 * s, x1 - x0, s, ironL); c.rect(x0, wy - 4 * s, x1 - x0, max(1, s / 2), iron)
            for x in stride(from: x0 + 2 * s, to: x1, by: 12 * s) { c.rect(x, wy - 8 * s, s, 8 * s, iron) }
            let floorY = n == 0 ? g : f.walks[n - 1]
            for x in stride(from: x0 + 20 * s, to: x1 - 2 * s, by: 80 * s) where n == 0 || abs(x - bx) > 30 * s {
                c.rect(x, wy + 3 * s, 4 * s, floorY - wy - 3 * s, iron); c.rect(x, wy + 3 * s, s, floorY - wy - 3 * s, ironL)
            }
        }
        // The stairs up to the first catwalk, on the left.
        let sx = c.w * 4 / 100, rise = g - f.walks[0], steps = rise / (4 * s)
        for k in 0..<steps {
            let x = sx + k * 4 * s, y = g - (k + 1) * 4 * s
            c.rect(x, y, 6 * s, s, ironL); c.rect(x, y + s, 6 * s, s, iron)
        }
        slayerLine(c, Double(sx), Double(g - 8 * s), Double(sx + steps * 4 * s), Double(f.walks[0] - 8 * s), ironL, Double(s) * 0.5)
        // Chains hanging from the dark, hooks on the ends.
        for (k, x) in [c.w * 18 / 100, c.w * 27 / 100, c.w * 68 / 100, c.w * 74 / 100].enumerated() {
            let top = f.roof.map { $0 + 18 * s } ?? 0, end = f.walks[0] - (6 + k * 5) * s - (f.roof == nil ? 0 : 30 * s)
            slayerChain(c, Double(x), Double(top), Double(x), Double(end), s, light: C(0x5A4A3E), dark: C(0x2E2620))
            c.rect(x - s, end + 2 * s, s, 3 * s, C(0x6A5A4A)); c.rect(x - s, end + 5 * s, 3 * s, s, C(0x6A5A4A)); c.rect(x + s, end + 3 * s, s, 2 * s, C(0x6A5A4A))
        }
        // Crates, and Spike's wheelchair parked beside them.
        let cx = c.w * 74 / 100
        for (k, (dx, dy, w)) in [(0, 0, 16), (16, 0, 14), (5, -12, 13)].enumerated() {
            let x = cx + dx * s, h = 12 * s, y = g - h + dy * s
            c.rect(x, y, w * s, h, [C(0x5A3E24), C(0x4A3420), C(0x624428)][k]); c.rect(x, y, w * s, s, C(0x7A5A34))
            slayerLine(c, Double(x + s), Double(y + s), Double(x + w * s - s), Double(y + h - s), C(0x3A2814), Double(s) * 0.5)
        }
        let wx = c.w * 63 / 100, wheel = C(0x8A8A90), frame = C(0x3A3A42), seat = C(0x5A1A1E)
        c.rect(wx + 2 * s, g - 24 * s, 3 * s, 12 * s, seat); c.rect(wx + 2 * s, g - 25 * s, 3 * s, s, frame)   // the back
        c.rect(wx + 1 * s, g - 25 * s, s, 15 * s, frame); c.rect(wx - s, g - 26 * s, 3 * s, s, wheel)          // a push handle
        c.rect(wx + 2 * s, g - 13 * s, 12 * s, 3 * s, seat); c.rect(wx + 2 * s, g - 13 * s, 12 * s, s, C(0x7A2A2E))
        slayerLine(c, Double(wx + 13 * s), Double(g - 11 * s), Double(wx + 17 * s), Double(g - 3 * s), frame, Double(s) * 0.6)
        c.rect(wx + 15 * s, g - 3 * s, 5 * s, s, frame)                                                          // the footrest
        c.circle(wx + 6 * s, g - 8 * s, 8 * s, wheel); c.circle(wx + 6 * s, g - 8 * s, 7 * s, C(0x1E1814))
        for k in 0..<4 {
            let a = Double(k) / 4 * .pi
            slayerLine(c, Double(wx + 6 * s) - cos(a) * Double(7 * s), Double(g - 8 * s) - sin(a) * Double(7 * s),
                       Double(wx + 6 * s) + cos(a) * Double(7 * s), Double(g - 8 * s) + sin(a) * Double(7 * s), C(0x5A5A60), Double(s) * 0.35)
        }
        c.circle(wx + 6 * s, g - 8 * s, s, wheel); c.circle(wx + 17 * s, g - 2 * s, 2 * s, wheel)
        // The brazier: an iron bowl on three legs, heaped with glowing coals.
        c.ellipse(bx, g - 1 * s, 26 * s, 3 * s, C(0xFF8A2A, 0.18))
        slayerLine(c, Double(bx - 9 * s), Double(g), Double(bx - 5 * s), Double(g - 14 * s), iron, Double(s) * 1.0)
        slayerLine(c, Double(bx + 9 * s), Double(g), Double(bx + 5 * s), Double(g - 14 * s), iron, Double(s) * 1.0)
        c.rect(bx - s / 2, g - 14 * s, s, 14 * s, iron)
        c.rect(bx - 11 * s, g - 22 * s, 22 * s, 3 * s, ironL); c.rect(bx - 10 * s, g - 19 * s, 20 * s, 3 * s, iron)
        c.rect(bx - 8 * s, g - 16 * s, 16 * s, 2 * s, iron)
        for k in 0..<10 { c.rect(bx - 10 * s + k * 2 * s, g - 23 * s - Int(noise(k + 1150) * 2) * s, 2 * s, 2 * s, [C(0xFF6A1A), C(0xC8401A), C(0xFFB040)][k % 3]) }
        // The concrete floor, oil stains, the brazier's pool of light.
        c.ground(g, C(0x2E2420), edge: C(0x5A3A26), speck: C(0x241A16), seed: 29)
        c.ellipse(bx, g + 4 * s, 40 * s, 3 * s, C(0xFF8A2A, 0.12))
        for k in 0..<4 { c.ellipse(Int(noise(k + 1160) * Double(c.w)), g + 4 * s + k % 2 * 2 * s, (6 + k * 2) * s, s, C(0x14100E, 0.6)) }
    }

    /// The factory's life: the brazier's flames leaping and its sparks rising, the light on the walls breathing with
    /// it, and one chain with its hook swaying in a draught.
    static func slayerFactoryLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerFactoryFrame(c, g), bx = f.brazier
        let flick = noise(Int(t * 10) + 1200)
        c.ellipse(bx, g - 30 * s, 34 * s, 22 * s, C(0xFF9A3A, 0.06 + 0.05 * flick))
        // The flames: a few tongues, wide at the coals and licking up to points, a hot yellow heart in each.
        let base = g - 22 * s
        for k in 0..<5 {
            let extra = k == 2 ? 6 : 0, n = Int(noise(Int(t * 8) * 7 + k * 13) * 9)
            let h = Double((10 + n + extra) * s)
            let cx = Double(bx - 8 * s + k * 4 * s), w0 = Double((k == 2 ? 6 : 4) * s)
            let sway = sin(t * 3 + Double(k) * 1.7) * Double(2 * s)
            for y in stride(from: 0, to: Int(h), by: max(1, s)) {
                let kk = Double(y) / h, half = w0 * (1 - kk) * (1 - kk * 0.3)
                let x = Int(cx + sway * kk * kk - half)
                let col = kk < 0.35 ? C(0xFFD060) : kk < 0.7 ? C(0xFF9A2A) : C(0xE85A1A)
                c.rect(x, base - y, max(s, Int(half * 2)), max(1, s), col)
                if kk < 0.5, half > Double(s) { c.rect(Int(cx + sway * kk * kk - half / 3), base - y, max(1, Int(half * 2 / 3)), max(1, s), C(0xFFF0B0)) }
            }
        }
        for k in 0..<8 {
            let p = frac(t * 0.4 + noise(k + 1210))
            let x = bx + Int((noise(k + 1220) - 0.5) * Double(20 * s)) + Int(sin(t * 2 + Double(k)) * Double(3 * s))
            let y = g - 28 * s - Int(p * Double(40 * s))
            c.rect(x, y, s, s, C(0xFFC060, 1 - p))
        }
        // The chain and hook, swinging from its pivot.
        let a = sin(t * 0.9) * 0.12
        let ex = Double(f.chain.x) + sin(a) * Double(f.chain.len), ey = Double(f.chain.y) + cos(a) * Double(f.chain.len)
        slayerChain(c, Double(f.chain.x), Double(f.chain.y), ex, ey, s, light: C(0x6A5A4A), dark: C(0x34302A))
        let hx = Int(ex), hy = Int(ey)
        c.rect(hx - s, hy, 2 * s, 4 * s, C(0x7A6A5A)); c.rect(hx - s, hy + 4 * s, 4 * s, s, C(0x7A6A5A)); c.rect(hx + 2 * s, hy + 2 * s, s, 2 * s, C(0x7A6A5A))
    }
}

// MARK: - The Doublemeat Palace

extension Scenes {
    /// Where things stand in the Doublemeat Palace: the ceiling, the front window, the counter, the menu board, the
    /// fryer, the neon sign, and (on the screen saver) the giant burger sign outside.
    static func slayerDoublemeatFrame(_ c: PixelCanvas, _ g: Int) -> (ceil: Int, window: (x: Int, y: Int, w: Int, h: Int),
                                                                     counter: (x: Int, w: Int, top: Int),
                                                                     menu: (x: Int, y: Int, w: Int, h: Int), fryer: Int,
                                                                     neon: (x: Int, y: Int), burger: (x: Int, y: Int, r: Int)?) {
        let s = unit(g), tall = isTall(c)
        let ceil = tall ? 10 * s : 4 * s
        let wy = tall ? ceil + 24 * s : 10 * s
        let window = (x: c.w * 3 / 100, y: wy, w: (tall ? 96 : 76) * s, h: g - 20 * s - wy)
        let counter = (x: c.w * 30 / 100, w: c.w * 52 / 100, top: g - 15 * s)
        let my = tall ? g - 78 * s : 10 * s
        let menu = (x: counter.x + 6 * s, y: my, w: counter.w - 12 * s, h: 24 * s)
        let burger = tall ? (x: window.x + window.w / 2, y: window.y + 34 * s, r: 24 * s) : nil
        return (ceil, window, counter, menu, counter.x + counter.w - 30 * s, (window.x + 8 * s, window.y + window.h - 14 * s), burger)
    }

    /// The Doublemeat Palace, where Buffy flipped burgers in season six: mustard-yellow walls over red tiles, the
    /// steel-topped counter with its tills, the menu board of lit burger pictures under the name, the fryer and the heat
    /// lamps behind, the silly hat hanging on its peg by the staff door, and the front window with a neon OPEN sign and
    /// the car park at night beyond. On the screen saver the window rises tall enough to show the giant burger on its
    /// pole outside, and a banner for the Doublemeat Medley hangs over the counter.
    static func slayerDoublemeat(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = slayerDoublemeatFrame(c, g)
        let mustard = C(0xB88A2A), mustardL = C(0xD0A23A), ketchup = C(0x8A2420), ketchupD = C(0x6A1A16), steel = C(0x9AA0A6)
        // The walls: mustard above, red tile below with its grout.
        c.rect(0, f.ceil, c.w, g - f.ceil, mustard)
        for x in stride(from: 0, to: c.w, by: 40 * s) { c.rect(x, f.ceil, 20 * s, g - f.ceil, mustardL.alpha(0.25)) }
        let tile = g - 22 * s
        c.rect(0, tile, c.w, 22 * s, ketchup)
        for y in stride(from: tile, to: g, by: 4 * s) { c.rect(0, y, c.w, max(1, s / 2), ketchupD) }
        for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, tile, max(1, s / 2), 22 * s, ketchupD) }
        c.rect(0, tile - 2 * s, c.w, 2 * s, C(0xE8D8A8))
        // The ceiling: tiles and strip lights.
        c.rect(0, 0, c.w, f.ceil, C(0xD8D0B8))
        for x in stride(from: 0, to: c.w, by: 20 * s) { c.rect(x, 0, s, f.ceil, C(0xB8B098)) }
        for x in stride(from: 30 * s, to: c.w, by: 80 * s) { c.rect(x, max(0, f.ceil - 3 * s), 30 * s, 2 * s, C(0xFFFFF4)) }
        c.rect(0, f.ceil - s, c.w, s, C(0x8A8270))
        // The front window: the car park at night, a lamp post, the neon sign hung in the glass.
        let w = f.window
        c.rect(w.x - 3 * s, w.y - 3 * s, w.w + 6 * s, w.h + 5 * s, C(0x5A5A60))
        c.gradient(w.y, w.y + w.h, C(0x0E1426), C(0x22283A), bands: 4)
        c.rect(0, w.y, w.x, w.h, mustard); c.rect(w.x + w.w, w.y, c.w - w.x - w.w, w.h, mustard)
        if tall { for x in stride(from: 40 * s, to: c.w, by: 40 * s) where x > w.x + w.w { c.rect(x, w.y, 20 * s, w.h, mustardL.alpha(0.25)) } }
        c.stars(w.y, w.y + w.h / 2, density: 90, seed: 14, x0: w.x, x1: w.x + w.w)
        c.rect(w.x, w.y + w.h - 8 * s, w.w, 8 * s, C(0x2A2A30))
        for x in stride(from: w.x + 4 * s, to: w.x + w.w, by: 14 * s) { c.rect(x, w.y + w.h - 5 * s, 8 * s, s, C(0xE8E0C0, 0.6)) }
        c.rect(w.x + w.w - 14 * s, w.y + w.h - 12 * s, 12 * s, 6 * s, C(0x3A4A6A)); c.rect(w.x + w.w - 12 * s, w.y + w.h - 15 * s, 8 * s, 3 * s, C(0x3A4A6A))
        if let b = f.burger {
            // The giant burger on its pole: a bun, two patties, lettuce, all lit by bulbs round the rim.
            c.rect(b.x - 2 * s, b.y, 4 * s, w.y + w.h - 8 * s - b.y, C(0x6A6A70)); c.rect(b.x - 2 * s, b.y, s, w.y + w.h - 8 * s - b.y, C(0x9A9AA0))
            c.ellipse(b.x, b.y, b.r + 6 * s, b.r + 2 * s, C(0xFFD060, 0.12))
            c.ellipse(b.x, b.y - b.r / 3, b.r, b.r * 2 / 3, C(0xD89A3A))
            c.rect(b.x - b.r, b.y - b.r / 3, 2 * b.r + 1, b.r / 3 + s, C(0xD89A3A))
            c.ellipse(b.x - b.r / 3, b.y - b.r * 2 / 3, b.r / 3, b.r / 6, C(0xF0C060))
            for k in 0..<6 { c.rect(b.x - b.r / 2 + k * b.r / 6, b.y - b.r / 2 + (k % 2) * 3 * s, 2 * s, s, C(0xF8ECC8)) }   // sesame
            c.rect(b.x - b.r - 2 * s, b.y + s, 2 * b.r + 4 * s, 3 * s, C(0x6ABA3A))
            c.rect(b.x - b.r, b.y + 4 * s, 2 * b.r, 5 * s, C(0x5A2A16)); c.rect(b.x - b.r - s, b.y + 9 * s, 2 * b.r + 2 * s, 2 * s, C(0xF0C030))
            c.rect(b.x - b.r, b.y + 11 * s, 2 * b.r, 5 * s, C(0x5A2A16))
            c.ellipse(b.x, b.y + 18 * s, b.r, 4 * s, C(0xC88A30))
        }
        c.rect(w.x + w.w / 2 - s / 2, w.y, s, w.h, C(0x5A5A60))
        // The neon sign in the window, dark until the moving layer lights it.
        slayerP3Sign(c, f.neon.x, f.neon.y, "OPEN", C(0x5A1A2A), s)
        // The menu board: the name in lights, three pictures of burgers and fries, rows of prices.
        let m = f.menu
        c.rect(m.x - 2 * s, m.y - 2 * s, m.w + 4 * s, m.h + 4 * s, C(0x2A1A10))
        c.rect(m.x, m.y, m.w, m.h, C(0x3A2416))
        let tw = slayerP3SignWidth("DOUBLEMEAT", 2 * s)
        slayerP3Sign(c, m.x + (m.w - tw) / 2, m.y + 2 * s, "DOUBLEMEAT", C(0xF0C030), 2 * s)
        let pw = (m.w - 8 * s) / 3
        for k in 0..<3 {
            let px = m.x + 2 * s + k * (pw + 2 * s), py = m.y + 14 * s
            c.rect(px, py, pw, m.h - 16 * s, C(0xF4E8C8))
            let bx = px + pw / 4, by = py + (m.h - 16 * s) / 2
            if k == 1 {
                for j in 0..<4 { c.rect(bx + j * 2 * s, by - 3 * s, s, 5 * s, C(0xE8B030)) }
                c.rect(bx - s, by, 8 * s, 3 * s, C(0xC82A20))
            } else {
                c.ellipse(bx + 3 * s, by - s, 4 * s, 2 * s, C(0xD89A3A)); c.rect(bx - s, by, 9 * s, s, C(0x5A2A16))
                c.rect(bx - s, by + s, 9 * s, s, C(0x6ABA3A)); c.rect(bx - s, by + 2 * s, 9 * s, s, C(0x5A2A16))
            }
            for j in 0..<2 { c.rect(px + pw / 2 + 2 * s, py + 2 * s + j * 3 * s, pw / 2 - 4 * s, s, C(0x6A4A2A)) }
        }
        if tall {
            // The banner for the Medley, strung over the counter.
            let by = f.ceil + 20 * s, bw = slayerP3SignWidth("DOUBLEMEAT MEDLEY", 3 * s) + 16 * s, bx = c.w * 60 / 100 - bw / 2
            c.rect(bx, by, bw, 23 * s, C(0xC82A20)); c.rect(bx, by, bw, 2 * s, C(0xE84A3A)); c.rect(bx, by + 21 * s, bw, 2 * s, C(0x8A1A16))
            for k in 0..<2 { slayerLine(c, Double(bx + k * bw), Double(by), Double(bx + k * bw + (k == 0 ? -10 : 10) * s), Double(f.ceil), C(0x3A3A3A), Double(s) * 0.4) }
            slayerP3Sign(c, bx + 8 * s, by + 4 * s, "DOUBLEMEAT MEDLEY", C(0xF8E8A0), 3 * s)
            // Posters of the specials either side, a wall clock, and the employees of the month under a gold star.
            let mid = (by + 23 * s + m.y) / 2
            for (k, px) in [m.x - 4 * s, m.x + m.w - 40 * s].enumerated() {
                let py = mid - 17 * s
                guard py > by + 26 * s else { continue }
                c.rect(px, py, 44 * s, 34 * s, C(0xF4E8C8)); c.rect(px, py, 44 * s, 3 * s, C(0xC82A20))
                c.ellipse(px + 22 * s, py + 14 * s, 12 * s, 6 * s, C(0xD89A3A)); c.rect(px + 9 * s, py + 17 * s, 26 * s, 3 * s, C(0x5A2A16))
                c.rect(px + 9 * s, py + 20 * s, 26 * s, 2 * s, k == 0 ? C(0x6ABA3A) : C(0xF0C030)); c.rect(px + 9 * s, py + 22 * s, 26 * s, 3 * s, C(0x5A2A16))
                c.rect(px + 10 * s, py + 25 * s, 24 * s, 3 * s, C(0xC88A30))
            }
            let ckx = m.x + m.w / 2, cky = mid - 4 * s
            if cky - 10 * s > by + 26 * s {
                c.circle(ckx, cky, 9 * s, C(0x3A3A40)); c.circle(ckx, cky, 8 * s, C(0xF8F4E8))
                slayerLine(c, Double(ckx), Double(cky), Double(ckx), Double(cky - 6 * s), C(0x2A2A2A), Double(s) * 0.5)
                slayerLine(c, Double(ckx), Double(cky), Double(ckx + 4 * s), Double(cky + 2 * s), C(0x2A2A2A), Double(s) * 0.5)
                c.rect(ckx, cky, s, s, C(0xC82A20))
                for k in 0..<3 {
                    let fx = ckx - 26 * s + k * 18 * s, fy = cky + 14 * s
                    guard fy + 14 * s < m.y - 4 * s else { break }
                    c.rect(fx, fy, 14 * s, 14 * s, C(0xC8A04A)); c.rect(fx + s, fy + s, 12 * s, 12 * s, C(0x8AA0B8))
                    c.rect(fx + 3 * s, fy + 8 * s, 8 * s, 5 * s, C(0xC82A20)); c.circle(fx + 7 * s, fy + 6 * s, 3 * s, [C(0xE8C0A0), C(0xC89070), C(0xE8C0A0)][k])
                    c.rect(fx + 4 * s, fy + 2 * s, 6 * s, 2 * s, [C(0xE8D070), C(0x3A2A1A), C(0x8A4A2A)][k])
                }
                for k in 0..<5 { c.rect(ckx - 2 * s + (k % 3 - 1) * s * (k / 3 == 0 ? 2 : 1), cky + 10 * s + k / 3 * s, s, s, C(0xF0C030)) }
            }
        }
        // Behind the counter: a steel splashback, the heat lamps, the fryer.
        let ct = f.counter
        c.rect(ct.x, ct.top - 12 * s, ct.w, 12 * s, C(0x7A8086)); c.rect(ct.x, ct.top - 12 * s, ct.w, s, C(0xB0B6BC))
        for k in 0..<3 {
            let lx = ct.x + 12 * s + k * 22 * s
            c.rect(lx + 4 * s, m.y + m.h + 2 * s, s, ct.top - 18 * s - m.y - m.h, C(0x3A3A3A))
            c.rect(lx, ct.top - 18 * s, 9 * s, 3 * s, C(0x3A3A3A)); c.rect(lx + s, ct.top - 15 * s, 7 * s, s, C(0xFF8A3A))
            c.ellipse(lx + 4 * s, ct.top - 6 * s, 7 * s, 5 * s, C(0xFF8A3A, 0.14))
        }
        let fx = f.fryer
        c.rect(fx, ct.top - 14 * s, 22 * s, 14 * s, steel); c.rect(fx, ct.top - 14 * s, 22 * s, s, C(0xD0D6DC))
        c.rect(fx + 2 * s, ct.top - 13 * s, 18 * s, 3 * s, C(0x8A6A1A))
        c.rect(fx + 3 * s, ct.top - 18 * s, 6 * s, 5 * s, C(0x5A5A5A, 0.8)); c.rect(fx + 13 * s, ct.top - 18 * s, 6 * s, 5 * s, C(0x5A5A5A, 0.8))
        c.rect(fx + 5 * s, ct.top - 22 * s, s, 4 * s, C(0x2A2A2A)); c.rect(fx + 15 * s, ct.top - 22 * s, s, 4 * s, C(0x2A2A2A))
        // The counter: red front with a yellow stripe, steel top, the tills, a napkin box and a tray.
        c.rect(ct.x, ct.top, ct.w, g - ct.top, ketchup); c.rect(ct.x, ct.top, ct.w, 2 * s, steel); c.rect(ct.x, ct.top + 2 * s, ct.w, s, C(0x5A5A60))
        c.rect(ct.x, ct.top + 6 * s, ct.w, 2 * s, C(0xF0C030))
        for x in stride(from: ct.x + 12 * s, to: ct.x + ct.w, by: 24 * s) { c.rect(x, ct.top + 9 * s, s, g - ct.top - 9 * s, ketchupD) }
        for tx in [ct.x + 14 * s, ct.x + ct.w / 2 + 4 * s] {
            c.rect(tx, ct.top - 7 * s, 12 * s, 7 * s, C(0x3A3A40)); c.rect(tx + 2 * s, ct.top - 11 * s, 8 * s, 4 * s, C(0x2A2A30))
            c.rect(tx + 3 * s, ct.top - 10 * s, 6 * s, 2 * s, C(0x6AE08A)); c.rect(tx + 2 * s, ct.top - 5 * s, 8 * s, 2 * s, C(0x5A5A60))
        }
        c.rect(ct.x + ct.w / 2 - 14 * s, ct.top - 4 * s, 6 * s, 4 * s, steel); c.rect(ct.x + ct.w / 2 - 13 * s, ct.top - 5 * s, 4 * s, s, C(0xF8F8F0))
        c.rect(ct.x + ct.w - 46 * s, ct.top - s, 14 * s, s, C(0xC82A20))
        // The staff door and the silly hat on its peg: a tall red and yellow cap with a little burger on top.
        let dx = c.w * 88 / 100
        c.rect(dx, g - 34 * s, 22 * s, 34 * s, C(0x6A4A2A)); c.rect(dx, g - 34 * s, 22 * s, s, C(0x8A6A3A))
        c.rect(dx + 18 * s, g - 18 * s, 2 * s, 3 * s, steel); c.rect(dx + 6 * s, g - 30 * s, 10 * s, 6 * s, C(0x8A6A3A))
        let hx = dx - 18 * s, hy = g - 36 * s
        c.rect(hx + 6 * s, hy + 16 * s, 2 * s, 3 * s, C(0x3A3A3A))
        c.rect(hx, hy + 6 * s, 14 * s, 10 * s, C(0xC82A20)); c.rect(hx, hy + 12 * s, 14 * s, 2 * s, C(0xF0C030))
        c.rect(hx + s, hy + 2 * s, 12 * s, 4 * s, C(0xF0C030)); c.rect(hx - 4 * s, hy + 14 * s, 7 * s, 2 * s, C(0xC82A20))
        c.ellipse(hx + 7 * s, hy + s, 5 * s, 2 * s, C(0xD89A3A)); c.rect(hx + 2 * s, hy + 2 * s, 10 * s, s, C(0x5A2A16))
        c.rect(hx + 2 * s, hy + 3 * s, 10 * s, s, C(0x6ABA3A))
        // The floor: muted red and cream tiles.
        c.ground(g, C(0x4A2A22), edge: C(0x8A5A3A), speck: C(0x3E221C), seed: 17)
        for x in stride(from: 0, to: c.w, by: 10 * s) {
            for y in stride(from: g + s + (x / (10 * s)) % 2 * 4 * s, to: c.h, by: 8 * s) { c.rect(x, y, 10 * s, 4 * s, C(0x5A3A2A, 0.5)) }
        }
    }

    /// The Doublemeat Palace's life: the neon OPEN buzzing in the window (a letter dropping out now and then), the
    /// fryer's oil bubbling, and on the screen saver the bulbs round the giant burger chasing.
    static func slayerDoublemeatLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = slayerDoublemeatFrame(c, g)
        let fl = Int(t * 7), off = noise(fl * 13 + 21) > 0.9 ? Int(noise(fl + 3) * 4) : -1
        let pink = C(0xFF5A8A)
        c.ellipse(f.neon.x + 7 * s, f.neon.y + 2 * s, 12 * s, 6 * s, C(0xFF5A8A, 0.15))
        for (i, ch) in "OPEN".enumerated() where i != off {
            slayerP3Sign(c, f.neon.x + i * 4 * s, f.neon.y, String(ch), pink, s)
        }
        // The fryer: little bubbles rising and popping in the oil.
        let ct = f.counter
        for k in 0..<6 {
            let p = frac(t * 1.3 + noise(k + 1300))
            let x = f.fryer + 3 * s + Int(noise(k + 1310) * Double(16 * s)), y = ct.top - 11 * s - Int(p * Double(2 * s))
            c.rect(x, y, s, s, C(0xF8E0A0, 1 - p))
        }
        if Int(t * 2) % 2 == 0 { c.rect(f.fryer + 8 * s, ct.top - 15 * s, s, s, C(0xFFFFFF, 0.3)) }
        // The bulbs round the burger.
        if let b = f.burger {
            for k in 0..<16 {
                let a = Double(k) / 16 * 2 * .pi, on = (k + Int(t * 6)) % 4 == 0
                c.rect(b.x + Int(cos(a) * Double(b.r + 4 * s)), b.y + 2 * s + Int(sin(a) * Double(b.r + 2 * s)), s, s, on ? C(0xFFF8C0) : C(0xA88A40))
            }
        }
    }
}
