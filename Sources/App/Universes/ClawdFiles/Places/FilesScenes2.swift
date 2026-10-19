import Foundation

// Indoors: Skinnard's office, the Lone Gunclawds' den, Clawder's apartment and the Syndicate's club.

let filesScenes2: [Location: Place] = [
    .skinnardsOffice: Place(name: "Skinnard's Office", panel: 0x1C1A16, still: Scenes.skinnardsOffice,
                            moving: Scenes.skinnardsOfficeLife),
    .gunclawdsDen: Place(name: "The Lone Gunclawds' Den", panel: 0x10140F, still: Scenes.gunclawdsDen,
                         moving: Scenes.gunclawdsDenLife),
    .apartment42: Place(name: "Apartment 42", panel: 0x12161C, still: Scenes.apartment42, moving: Scenes.apartment42Life),
    .syndicateClub: Place(name: "The Syndicate's Club", panel: 0x1A100C, still: Scenes.syndicateClub,
                          moving: Scenes.syndicateClubLife),
]

/// Digits in a 3×5 pixel font, for door numbers.
private let filesDigits: [Character: [String]] = [
    "2": ["###", "..#", "###", "#..", "###"], "4": ["#.#", "#.#", "###", "..#", "..#"],
]

private func filesNumber(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, col: Px) {
    var x = x
    for ch in text {
        guard let rows = filesDigits[ch] else { continue }
        for (dy, row) in rows.enumerated() {
            for (dx, p) in row.enumerated() where p == "#" { c.rect(x + dx * s, y + dy * s, s, s, col) }
        }
        x += 4 * s
    }
}

/// A vertical gradient inside a box (unlike `gradient`, which spans the whole canvas).
private func filesBox(_ c: PixelCanvas, _ x: Int, _ y: Int, _ w: Int, _ h: Int, _ top: Px, _ bottom: Px) {
    guard h > 0 else { return }
    for dy in 0..<h {
        let k = Double(dy) / Double(max(1, h - 1))
        let col = Px(r: UInt8(Double(top.r) + (Double(bottom.r) - Double(top.r)) * k),
                     g: UInt8(Double(top.g) + (Double(bottom.g) - Double(top.g)) * k),
                     b: UInt8(Double(top.b) + (Double(bottom.b) - Double(top.b)) * k), a: 255)
        c.rect(x, y + dy, w, 1, col)
    }
}

/// A line of `w`×`w` dots from (x0, y0) to (x1, y1).
private func filesLine(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ w: Int, _ col: Px) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for k in 0...n { c.rect(x0 + (x1 - x0) * k / n, y0 + (y1 - y0) * k / n, w, w, col) }
}

// MARK: - Skinnard's office

extension Scenes {
    /// Where things stand in Skinnard's office: the window (behind its blinds), the ceiling's depth, the top of the
    /// panelling and the desk.
    static func skinnardFrame(_ c: PixelCanvas, _ g: Int) -> (window: (x: Int, y: Int, w: Int, h: Int), ceiling: Int,
                                                              wainscot: Int, desk: (x: Int, w: Int)) {
        let s = unit(g)
        let ceiling = g > 60 ? 5 * s : 0
        let wainscot = g - 12 * s
        // On the screen saver the window goes most of the way up the wall, as office windows at headquarters do.
        let most = isTall(c) ? (wainscot - ceiling) * 78 / 100 : 42 * s
        let wh = min(most, wainscot - ceiling - 6 * s), ww = min(78 * s, c.w * 30 / 100)
        let wy = max(ceiling + 3 * s, wainscot - wh - 5 * s)
        return ((c.w * 12 / 100, wy, ww, wh), ceiling, wainscot, (c.w * 62 / 100, 74 * s))
    }

    /// Skinnard's office at FBI headquarters, after dark: warm grey walls over oak panelling, a tall window with its
    /// blinds half down on a wet night and the city's lit windows, the flag on its pole beside it, the FBI seal, a
    /// bookcase and the big desk with its green banker's lamp. On the screen saver, framed commendations climb the wall
    /// to a moulded ceiling.
    static func skinnardsOffice(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = skinnardFrame(c, g)
        c.gradient(0, g, C(0x24221E), C(0x433E35), bands: 7)
        if f.ceiling > 0 {
            c.rect(0, 0, c.w, f.ceiling, C(0x5A5448)); c.rect(0, f.ceiling - s, c.w, s, C(0x7A7262))
            c.rect(0, f.ceiling, c.w, s, C(0x2A2620))
        }
        if tall {
            // Crown moulding; the official portrait and the clock high up; commendations clustered above the window
            // and the desk.
            c.rect(0, f.ceiling, c.w, 3 * s, C(0x4A443A)); c.rect(0, f.ceiling + 3 * s, c.w, s, C(0x5E5648))
            // A picture rail, and the ceiling's two light fittings.
            let rail = f.window.y - 6 * s
            c.rect(0, rail, c.w, s, C(0x4E463A)); c.rect(0, rail + s, c.w, s, C(0x1E1C18, 0.6))
            for lx in [c.w * 30 / 100, c.w * 74 / 100] {
                c.rect(lx - s / 2, f.ceiling + 4 * s, max(1, s), 6 * s, C(0x3A342A))
                c.ellipse(lx, f.ceiling + 12 * s, 9 * s, 3 * s, C(0xD8CCA8)); c.rect(lx - 9 * s, f.ceiling + 12 * s, 18 * s, s, C(0x8A8070))
            }
            // The Director's official portrait, between the window and the desk, and the clock over the bookcase.
            let pw = 30 * s, ph = 38 * s
            let px = (f.window.x + f.window.w + f.desk.x) / 2 + 4 * s, py = max(rail + 10 * s, f.window.y + 6 * s)
            c.rect(px - 2 * s, py - 2 * s, pw + 4 * s, ph + 4 * s, C(0xB89A4A)); c.rect(px, py, pw, ph, C(0x1E2028))
            c.ellipse(px + 15 * s, py + 14 * s, 7 * s, 8 * s, C(0xC8A080)); c.rect(px + 5 * s, py + 24 * s, 20 * s, 14 * s, C(0x22283A))
            c.rect(px + 14 * s, py + 24 * s, 2 * s, 6 * s, C(0xE8E4DA)); c.rect(px + 9 * s, py + 5 * s, 12 * s, 3 * s, C(0x8A8A8A))
            c.rect(px + 9 * s, py + ph + 4 * s, 12 * s, 2 * s, C(0xB89A4A))   // its little brass plate
            let kx = c.w * 92 / 100, ky = rail + 16 * s
            c.circle(kx, ky, 8 * s, C(0x3A2A1C)); c.circle(kx, ky, 7 * s, C(0xE8E4D4))
            c.rect(kx, ky - 5 * s, max(1, s / 2), 5 * s, ink); c.rect(kx, ky, 4 * s, max(1, s / 2), ink)
            // The map of the field offices, pins in it, over the desk.
            let mx = f.desk.x + 6 * s, my = rail + 22 * s, mw = 60 * s, mh = 34 * s
            if my + mh < f.wainscot - 80 * s {
                c.rect(mx - s, my - s, mw + 2 * s, mh + 2 * s, C(0x2A2016)); c.rect(mx, my, mw, mh, C(0xC8C4AE))
                c.ellipse(mx + mw / 2, my + mh / 2, mw * 2 / 5, mh * 2 / 5, C(0xA8B08A))
                c.rect(mx + mw / 2, my + mh / 2 - mh * 2 / 5, mw * 2 / 5, mh / 5, C(0xC8C4AE))
                for i in 0..<14 {
                    c.rect(mx + 6 * s + Int(noise(i + 900) * Double(mw - 12 * s)), my + 5 * s + Int(noise(i + 920) * Double(mh - 10 * s)),
                           s, s, i % 4 == 0 ? C(0x2A4A9A) : C(0xC8202A))
                }
            }
            // The Ten Most Wanted, pinned up in a row under the map.
            let wy = my + mh + 12 * s
            if wy + 16 * s < f.wainscot - 44 * s {
                for k in 0..<4 {
                    let x = mx + 2 * s + k * 15 * s
                    c.rect(x, wy, 12 * s, 16 * s, C(0xE2DECE)); c.rect(x, wy, 12 * s, 3 * s, C(0x8A2A22))
                    c.ellipse(x + 6 * s, wy + 8 * s, 3 * s, 3 * s, C(0x4A4A44)); c.rect(x + 3 * s, wy + 11 * s, 6 * s, 3 * s, C(0x4A4A44))
                    c.rect(x + 2 * s, wy + 15 * s, 8 * s, max(1, s / 2), C(0x6A665A))
                }
            }
            for (cx0, n) in [(f.window.x, 4), (f.desk.x, 3)] {
                for k in 0..<n {
                    let big = (k + n) % 2 == 0
                    let fw = (big ? 18 : 13) * s, fh = (big ? 14 : 10) * s
                    let x = cx0 + k * 21 * s, y = (cx0 == f.window.x ? rail - 4 * s - fh : f.wainscot - 40 * s) - (k % 2) * 6 * s
                    c.rect(x, y, fw, fh, C(0x2A2016)); c.rect(x + s, y + s, fw - 2 * s, fh - 2 * s, C(0xC8BE9E))
                    if k % 3 == 1 { c.rect(x + 3 * s, y + 3 * s, fw - 6 * s, fh - 6 * s, C(0x5A5E5A)) }
                    else { for ly in stride(from: y + 3 * s, to: y + fh - 3 * s, by: 2 * s) { c.rect(x + 3 * s, ly, fw - 6 * s, s, C(0x8A8470)) } }
                    c.circle(x + fw - 3 * s, y + fh - 3 * s, s, C(0xC8A04A))   // the seal
                }
            }
        }
        // The panelling.
        c.rect(0, f.wainscot, c.w, g - f.wainscot, C(0x5A4128)); c.rect(0, f.wainscot, c.w, 2 * s, C(0x7A5A3A))
        for x in stride(from: 4 * s, to: c.w, by: 22 * s) {
            c.rect(x, f.wainscot + 4 * s, 18 * s, g - f.wainscot - 6 * s, C(0x4E3822))
            c.rect(x, f.wainscot + 4 * s, 18 * s, s, C(0x3A2A18))
        }
        // The window: a wet night outside, the lit windows of the buildings across the street.
        let w = f.window
        c.rect(w.x - 2 * s, w.y - 2 * s, w.w + 4 * s, w.h + 4 * s, C(0x3A2A1C))
        filesBox(c, w.x, w.y, w.w, w.h, C(0x0E1420), C(0x1E2A3A))
        for b in 0..<4 {
            let bx = w.x + b * w.w / 4, bh = w.h * (5 + b % 3) / 9
            c.rect(bx + s, w.y + w.h - bh, w.w / 4 - 2 * s, bh, C(0x1A202C))
            for i in 0..<10 {
                let lx = bx + 2 * s + Int(noise(b * 40 + i) * Double(max(1, w.w / 4 - 5 * s)))
                let ly = w.y + w.h - bh + 2 * s + Int(noise(b * 40 + i + 17) * Double(max(1, bh - 4 * s)))
                if noise(b * 40 + i + 33) > 0.35 { c.rect(lx, ly, s, s, C(0xE8C878, 0.7)) }
            }
        }
        c.rect(w.x + w.w / 2 - s / 2, w.y, max(1, s), w.h, C(0x3A2A1C))   // the mullion
        // The blinds, half down: slats with thin gaps over the top, the stack and the cord.
        let blindsEnd = w.y + w.h * 45 / 100
        for y in stride(from: w.y, to: blindsEnd, by: 3 * s) {
            c.rect(w.x, y, w.w, 2 * s, C(0xC4BCA8)); c.rect(w.x, y + 2 * s - max(1, s / 2), w.w, max(1, s / 2), C(0x8E8674))
        }
        c.rect(w.x - s, blindsEnd, w.w + 2 * s, 2 * s, C(0xA8A090))
        c.rect(w.x + w.w - 4 * s, blindsEnd + 2 * s, max(1, s / 2), w.h / 4, C(0xD8D0C0))
        c.rect(w.x - 2 * s, w.y + w.h + 2 * s, w.w + 4 * s, s, C(0x5A4430))   // the sill
        // The flag on its pole, hanging in folds: stripes, the blue canton with its stars, a gold eagle on top.
        let px = w.x + w.w + 9 * s, top = max(f.ceiling + 2 * s, g - 50 * s)
        c.rect(px, top + 3 * s, s, g - top - 3 * s, C(0xB89A4A)); c.rect(px - s, g - 2 * s, 3 * s, 2 * s, C(0x8A7038))
        c.rect(px - s, top, 3 * s, 3 * s, C(0xD8B85A))
        let fh = min(30 * s, g - top - 10 * s), fx = px + s, fy = top + 4 * s
        if fh > 8 * s {
            for y in stride(from: 0, to: fh, by: 2 * s) {
                c.rect(fx, fy + y, 8 * s, s, C(0xA82830)); c.rect(fx, fy + y + s, 8 * s, s, C(0xE8E4DA))
            }
            c.rect(fx, fy, 4 * s, fh * 2 / 5, C(0x24346A))
            for i in 0..<4 { c.rect(fx + s + (i % 2) * 2 * s, fy + s + i * fh / 10, max(1, s / 2), max(1, s / 2), C(0xF2F0EA)) }
            for k in [3, 6] { c.rect(fx + k * s, fy, max(1, s / 2), fh, C(0x000000, 0.25)) }   // the folds
        }
        // The FBI seal: a blue disc in a gold ring.
        let sx = px + 26 * s, sy = max(f.ceiling + 12 * s, w.y + 6 * s)
        if sx + 10 * s < f.desk.x {
            c.circle(sx, sy, 9 * s, C(0xC8A04A)); c.circle(sx, sy, 7 * s, C(0x1E3266)); c.circle(sx, sy, 3 * s, C(0xC8A04A, 0.8))
            for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 5) {
                c.rect(sx + Int(cos(a) * Double(5 * s)), sy + Int(sin(a) * Double(5 * s)), max(1, s / 2), max(1, s / 2), C(0xE8D07A))
            }
        }
        // A bookcase at the end of the room.
        let bx = c.w * 88 / 100, bh = min((tall ? 70 : 52) * s, g - f.ceiling - 3 * s), btop = g - bh
        c.rect(bx, btop, 26 * s, bh, C(0x3A2A1A)); c.rect(bx - s, btop, 28 * s, 2 * s, C(0x4E3822))
        for shelf in stride(from: btop + 3 * s, to: g - 6 * s, by: 9 * s) {
            var x = bx + 2 * s, i = 0
            while x < bx + 24 * s {
                let bw = (1 + Int(noise(shelf + i * 3) * 2)) * s
                let hgt = 6 * s - Int(noise(shelf + i * 5) * 2) * s
                c.rect(x, shelf + 7 * s - hgt, bw, hgt, [C(0x6A2A22), C(0x2A3A5A), C(0x3A4A2E), C(0x8A7448)][i % 4])
                x += bw; i += 1
            }
            c.rect(bx + s, shelf + 7 * s, 24 * s, s, C(0x5A4128))
        }
        // The desk: his high-backed chair behind it, a nameplate, the banker's lamp, a phone and a pile of files.
        let d = f.desk, dtop = g - Self.skinnardDeskH * s
        let chx = d.x + d.w / 2 - 8 * s
        c.rect(chx, g - 36 * s, 16 * s, 16 * s, C(0x1E1410)); c.rect(chx, g - 36 * s, 16 * s, s, C(0x3A281E))
        for k in 0..<3 { c.rect(chx + 3 * s + k * 5 * s, g - 33 * s, max(1, s / 2), 11 * s, C(0x140C08)) }   // the tufting
        c.rect(d.x, dtop, d.w, g - dtop, C(0x34200F)); c.rect(d.x - 2 * s, dtop, d.w + 4 * s, 2 * s, C(0x5A3A1E))
        c.rect(d.x + 4 * s, dtop + 4 * s, 18 * s, 14 * s, C(0x2A1808)); c.rect(d.x + d.w - 22 * s, dtop + 4 * s, 18 * s, 14 * s, C(0x2A1808))
        c.rect(d.x + 12 * s, dtop + 10 * s, 2 * s, s, C(0xC8A04A)); c.rect(d.x + d.w - 14 * s, dtop + 10 * s, 2 * s, s, C(0xC8A04A))
        c.rect(d.x + 26 * s, dtop + 4 * s, 22 * s, 14 * s, C(0x3A2412))   // the modesty panel
        c.rect(d.x + 28 * s, dtop - 3 * s, 16 * s, 3 * s, C(0x2A2A2A)); c.rect(d.x + 29 * s, dtop - 3 * s, 14 * s, s, C(0xC8A04A))
        c.rect(d.x + 7 * s, dtop - 9 * s, s, 7 * s, C(0xB89A4A))
        c.rect(d.x + 2 * s, dtop - 12 * s, 11 * s, 4 * s, C(0x2E6A3A)); c.rect(d.x + 2 * s, dtop - 12 * s, 11 * s, s, C(0x4E8A5A))
        c.rect(d.x + 4 * s, dtop - 2 * s, 7 * s, 2 * s, C(0xB89A4A))
        c.rect(d.x + 50 * s, dtop - 3 * s, 8 * s, 3 * s, C(0x1E1E22)); c.rect(d.x + 51 * s, dtop - 5 * s, 6 * s, 2 * s, C(0x1E1E22))
        for k in 0..<3 {
            c.rect(d.x + 61 * s + k * s / 2, dtop - (k + 1) * 2 * s, 10 * s, 2 * s, [C(0xD8C89A), C(0xC8B888), C(0xE0D4AC)][k])
        }
        // The carpet.
        c.ground(g, C(0x262C38), edge: C(0x3E4656), speck: C(0x1E2430), seed: 52)
    }

    /// The height of Skinnard's desk.
    static let skinnardDeskH = 21

    /// What moves in Skinnard's office: rain running down the open half of the window, the odd flash of lightning,
    /// headlights from the street sweeping striped light across the wall, and the lamp's glow.
    static func skinnardsOfficeLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = skinnardFrame(c, g), w = f.window
        let glassTop = w.y + w.h * 45 / 100 + 2 * s, glassH = w.y + w.h - glassTop
        if glassH > 2 * s {
            if noise(Int(t * 3) + 7) > 0.975 { c.rect(w.x, glassTop, w.w, glassH, C(0xDCE6FF, 0.3)) }
            for i in 0..<Int(w.w / s / 2) {
                let x = w.x + Int(noise(i * 3 + 1) * Double(w.w - s))
                let speed = 0.6 + noise(i * 3 + 2) * 0.8
                let y = glassTop + Int((noise(i * 3) + t * speed).truncatingRemainder(dividingBy: 1) * Double(glassH))
                let len = min(3 * s, glassTop + glassH - y)
                if len > 0 { c.rect(x, y, max(1, s / 2), len, C(0xAABCD8, 0.45)) }
            }
            for i in 0..<6 {   // drops sitting on the glass
                c.rect(w.x + Int(noise(i + 61) * Double(w.w - s)), glassTop + Int(noise(i + 67) * Double(glassH - s)), s, s, C(0xC8D8F0, 0.35))
            }
        }
        // Headlights: every so often the blinds' stripes slide across the wall to the right of the window.
        let k = (t / 11).truncatingRemainder(dividingBy: 1)
        if k < 0.3 {
            let x0 = w.x + w.w + Int(k / 0.3 * Double(c.w / 2))
            let a = sin(k / 0.3 * .pi) * 0.09
            for j in 0..<6 { c.rect(x0, w.y + j * 3 * s, 22 * s, 2 * s, C(0xFFF0C8, a)) }
        }
        // The lamp's pool of light on the desk.
        let d = f.desk, dtop = g - skinnardDeskH * s
        c.rect(d.x - 2 * s, dtop - 8 * s, 19 * s, 8 * s, C(0xFFE8A8, 0.07 + 0.01 * sin(t * 0.7)))
        c.rect(d.x + 3 * s, dtop - 8 * s, 9 * s, s, C(0xFFF0B8, 0.6))
    }
}

// MARK: - The Lone Gunclawds' den

extension Scenes {
    /// Where things stand in the den: the bank of monitors (columns × rows of screens), the reel-to-reel and the door.
    static func denFrame(_ c: PixelCanvas, _ g: Int) -> (bank: (x: Int, y: Int, cols: Int, rows: Int, cw: Int, ch: Int),
                                                         deck: (x: Int, y: Int), door: Int, ceiling: Int) {
        let s = unit(g)
        let ceiling = g > 60 ? 5 * s : 0
        let cw = 16 * s, ch = 12 * s
        let rows = max(1, min(isTall(c) ? 5 : 3, (g - 17 * s - ceiling - 4 * s) / (ch + 2 * s)))
        let bankY = g - 17 * s - rows * (ch + 2 * s)
        return ((c.w * 10 / 100, bankY, 4, rows, cw, ch), (c.w * 66 / 100, g - 40 * s), c.w * 87 / 100, ceiling)
    }

    /// The Lone Gunclawds' den: a windowless cinderblock room crammed with surveillance gear. A wall of mismatched
    /// monitors on steel shelving, a workbench of keyboards, wires and coffee mugs, a reel-to-reel tape deck, a grainy
    /// alien poster, and a steel door with a column of deadbolts. On the screen saver, shelves of tape boxes and a map
    /// full of pins rise above it all.
    static func gunclawdsDen(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = denFrame(c, g)
        c.gradient(0, g, C(0x1A1E18), C(0x30342A), bands: 6)
        // Cinderblocks.
        for (row, y) in stride(from: g - 6 * s, to: f.ceiling, by: -6 * s).enumerated() {
            c.rect(0, y, c.w, max(1, s / 2), C(0x14170F))
            for x in stride(from: (row % 2) * 6 * s, to: c.w, by: 12 * s) { c.rect(x, y - 6 * s, max(1, s / 2), 6 * s, C(0x14170F)) }
        }
        if f.ceiling > 0 {
            c.rect(0, 0, c.w, f.ceiling, C(0x2A2C26)); c.rect(0, f.ceiling - s, c.w, s, C(0x44463C))
            // Cables run along the ceiling and drop to the gear.
            for (i, col) in [C(0x1A1A1A), C(0x6A2222), C(0x22305A)].enumerated() {
                c.rect(0, f.ceiling + (i + 1) * s, c.w, max(1, s / 2), col)
            }
        }
        if tall {
            // Shelves of tape boxes (six at most), the map with its pins, and a bare bulb hanging on its flex.
            let shelfBottom = f.bank.y - 12 * s, top = max(f.ceiling + 10 * s, shelfBottom - 6 * 12 * s)
            let bulbY = max(f.ceiling + 8 * s, top - 30 * s)
            c.rect(c.w * 30 / 100, f.ceiling, max(1, s / 2), bulbY - f.ceiling, C(0x1A1A1A))
            c.rect(c.w * 30 / 100 - s, bulbY, 2 * s, 2 * s, C(0x3A3A3A)); c.ellipse(c.w * 30 / 100, bulbY + 4 * s, 2 * s, 2 * s, C(0xFFF0B8))
            c.ellipse(c.w * 30 / 100, bulbY + 4 * s, 9 * s, 7 * s, C(0xFFE8A0, 0.06))
            for y in stride(from: top, to: shelfBottom, by: 12 * s) {
                c.rect(c.w * 6 / 100, y + 10 * s, c.w * 40 / 100, s, C(0x4A4C44))
                var x = c.w * 6 / 100, i = 0
                while x < c.w * 46 / 100 - 6 * s {
                    let bw = (4 + Int(noise(y + i) * 3)) * s
                    c.rect(x, y + 3 * s, bw - s, 7 * s, [C(0x8A7A5A), C(0x6A6A6E), C(0xA89A6A)][i % 3])
                    c.rect(x + s, y + 5 * s, bw - 3 * s, s, C(0xE8E2CC, 0.7))
                    x += bw; i += 1
                }
            }
            let mx = c.w * 56 / 100, my = top + 6 * s, mw = c.w * 30 / 100, mh = min(60 * s, shelfBottom - my)
            if mh > 20 * s {
                c.rect(mx - s, my - s, mw + 2 * s, mh + 2 * s, C(0x2A2A22)); c.rect(mx, my, mw, mh, C(0xC8C0A0))
                for i in 0..<7 {   // land masses
                    c.ellipse(mx + Int(noise(i + 300) * Double(mw)), my + Int(noise(i + 310) * Double(mh)),
                              (6 + Int(noise(i + 320) * 10)) * s, (4 + Int(noise(i + 330) * 6)) * s, C(0x8A9A6A))
                }
                for i in 0..<12 {
                    c.rect(mx + Int(noise(i + 340) * Double(mw - 2 * s)), my + Int(noise(i + 350) * Double(mh - 2 * s)), s, s, C(0xC8202A))
                }
            }
        }
        // The alien poster: a grey face with big black eyes.
        let pxx = c.w * 52 / 100, py = max(f.ceiling + 4 * s, g - 44 * s)
        if py + 22 * s < g - 12 * s {
            c.rect(pxx, py, 16 * s, 22 * s, C(0x0E120E))
            c.ellipse(pxx + 8 * s, py + 9 * s, 5 * s, 7 * s, C(0x9AA89A)); c.rect(pxx + 6 * s, py + 15 * s, 4 * s, 3 * s, C(0x9AA89A))
            c.ellipse(pxx + 6 * s, py + 9 * s, 2 * s, s + s / 2, C(0x050805)); c.ellipse(pxx + 10 * s, py + 9 * s, 2 * s, s + s / 2, C(0x050805))
        }
        // The steel shelving and its monitors (the pictures come with the moving layer).
        let b = f.bank, bw = b.cols * (b.cw + 2 * s)
        c.rect(b.x - 2 * s, b.y - 2 * s, s * 2, g - b.y + 2 * s, C(0x4A4C48)); c.rect(b.x + bw, b.y - 2 * s, 2 * s, g - b.y + 2 * s, C(0x4A4C48))
        for r in 0..<b.rows {
            for k in 0..<b.cols {
                let x = b.x + k * (b.cw + 2 * s), y = b.y + r * (b.ch + 2 * s)
                let casing = [C(0x8A8676), C(0x5A5A5E), C(0x9A9282), C(0x3E3E42)][(r * 3 + k) % 4]
                c.rect(x, y, b.cw, b.ch, casing); c.rect(x, y + b.ch - s, b.cw, s, C(0x000000, 0.35))
                c.rect(x + 2 * s, y + 2 * s, b.cw - 4 * s, b.ch - 5 * s, C(0x0A120C))
                c.rect(x + b.cw - 3 * s, y + b.ch - 3 * s, s, s, C(0x3A3A3A))
            }
            c.rect(b.x - 2 * s, b.y + r * (b.ch + 2 * s) + b.ch, bw + 4 * s, 2 * s, C(0x5A5C56))
        }
        // The workbench, chest high to a Clawd: keyboards, a tangle of wire, mugs, papers, and a stool.
        let wbTop = g - 15 * s
        c.rect(b.x - 4 * s, wbTop, bw + 32 * s, 3 * s, C(0x6A5A44)); c.rect(b.x - 4 * s, wbTop, bw + 32 * s, s, C(0x8A7658))
        for lx in [b.x - 2 * s, b.x + bw / 2, b.x + bw + 24 * s] { c.rect(lx, wbTop + 3 * s, 2 * s, g - wbTop - 3 * s, C(0x4A3E2E)) }
        c.rect(b.x - 2 * s, g - 5 * s, bw + 28 * s, s, C(0x3A3026))   // the shelf underneath, boxes of tapes on it
        for k in 0..<4 { c.rect(b.x + 4 * s + k * 9 * s, g - 9 * s, 7 * s, 4 * s, [C(0x8A7A5A), C(0x6A6A6E)][k % 2]) }
        c.rect(b.x + 4 * s, wbTop - 2 * s, 18 * s, 2 * s, C(0xB8B4A4)); c.rect(b.x + 5 * s, wbTop - 2 * s, 16 * s, max(1, s / 2), C(0x8A8676))
        c.rect(b.x + 30 * s, wbTop - 2 * s, 18 * s, 2 * s, C(0x6A6A6E)); c.rect(b.x + 31 * s, wbTop - 2 * s, 16 * s, max(1, s / 2), C(0x4A4A4E))
        c.rect(b.x + 52 * s, wbTop - 4 * s, 3 * s, 4 * s, C(0xE8E4D8)); c.rect(b.x + 57 * s, wbTop - 4 * s, 3 * s, 4 * s, C(0x8A3A2A))
        c.rect(b.x + bw + 6 * s, wbTop - 2 * s, 12 * s, 2 * s, C(0xE8DCB8)); c.rect(b.x + bw + 7 * s, wbTop - 3 * s, 10 * s, s, C(0xD8CCA8))
        let st = b.x + bw + 30 * s   // the stool
        c.rect(st, g - 10 * s, 9 * s, 2 * s, C(0x8A2A22)); c.rect(st + s, g - 8 * s, s, 8 * s, C(0x5A5C56)); c.rect(st + 7 * s, g - 8 * s, s, 8 * s, C(0x5A5C56))
        for i in 0..<5 {
            let x0 = b.x + Int(noise(i + 400) * Double(bw)), x1 = x0 + (Int(noise(i + 410) * 16) - 8) * s
            filesLine(c, x0, b.y + b.rows * (b.ch + 2 * s) - s, x1, wbTop, max(1, s / 2), [C(0x1A1A1A), C(0x8A2222), C(0x2A3A7A)][i % 3])
        }
        // The reel-to-reel: two reels (turned by the moving layer), the meters, the tape between them.
        let dk = f.deck
        c.rect(dk.x, dk.y, 34 * s, 26 * s, C(0x3A3A3E)); c.rect(dk.x, dk.y, 34 * s, s, C(0x5A5A60)); c.rect(dk.x + 33 * s, dk.y, s, 26 * s, C(0x26262A))
        for rx in Self.denReels(dk, s) { c.circle(rx, dk.y + 8 * s, 7 * s, C(0xA8ACB4)); c.circle(rx, dk.y + 8 * s, 2 * s, C(0x2A2A2E)) }
        c.rect(dk.x + 8 * s, dk.y + 15 * s, 18 * s, max(1, s / 2), C(0x5A3A20))
        c.rect(dk.x + 5 * s, dk.y + 18 * s, 8 * s, 4 * s, C(0xD8C890)); c.rect(dk.x + 20 * s, dk.y + 18 * s, 8 * s, 4 * s, C(0xD8C890))
        for k in 0..<4 { c.rect(dk.x + 6 * s + k * 6 * s, dk.y + 24 * s, 3 * s, s, C(0x1E1E22)) }   // the buttons
        c.rect(dk.x - 2 * s, dk.y + 26 * s, 38 * s, g - dk.y - 26 * s, C(0x3E342A)); c.rect(dk.x - 2 * s, dk.y + 26 * s, 38 * s, s, C(0x5A4C3C))
        c.rect(dk.x + 2 * s, dk.y + 30 * s, 30 * s, max(1, s / 2), C(0x2A2218))
        // The door, bolted five times over, and its peephole.
        let dx = f.door, dh = min(42 * s, g - f.ceiling - 3 * s)
        c.rect(dx - s, g - dh - s, 22 * s, dh + s, C(0x2E302A))
        c.rect(dx, g - dh, 20 * s, dh, C(0x4E524C)); c.rect(dx, g - dh, 20 * s, s, C(0x6A6E66)); c.rect(dx + 19 * s, g - dh, s, dh, C(0x34382F))
        for i in 0..<5 { c.rect(dx + 14 * s, g - dh + 5 * s + i * min(6 * s, dh / 7), 4 * s, 2 * s, C(0xC8A04A)) }
        c.rect(dx + 9 * s, g - dh + 7 * s, s, s, C(0x0A0A0A))
        // The concrete floor.
        c.ground(g, C(0x2E2E28), edge: C(0x48483E), speck: C(0x24241F), seed: 61)
    }

    /// Where the reel-to-reel's two reels turn.
    static func denReels(_ dk: (x: Int, y: Int), _ s: Int) -> [Int] { [dk.x + 9 * s, dk.x + 25 * s] }

    /// What moves in the den: every monitor showing something (scrolling green text, static, a waveform, a radar sweep,
    /// a grainy surveillance shot), flickering; the reels turning; the deck's red record light blinking.
    static func gunclawdsDenLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = denFrame(c, g), b = f.bank
        for r in 0..<b.rows {
            for k in 0..<b.cols {
                let i = r * b.cols + k
                let x = b.x + k * (b.cw + 2 * s) + 2 * s, y = b.y + r * (b.ch + 2 * s) + 2 * s
                let w = b.cw - 4 * s, h = b.ch - 5 * s
                let bright = noise(i * 31 + Int(t * 6)) > 0.95 ? 0.4 : 1.0
                switch i % 6 {
                case 0, 5:   // text scrolling up
                    let col = i % 6 == 0 ? C(0x6AFF8A, 0.75 * bright) : C(0x8AC8FF, 0.7 * bright)
                    let off = Int(t * 2)
                    for line in 0..<max(1, h / (2 * s)) {
                        let len = Int(noise((line + off) * 7 + i) * Double(w - s))
                        c.rect(x + s / 2, y + line * 2 * s + s / 2, max(s, len), max(1, s / 2), col)
                    }
                case 1:      // static
                    let frame = Int(t * 15)
                    for py in stride(from: 0, to: h, by: max(1, s / 2)) {
                        for qx in stride(from: 0, to: w, by: max(1, s / 2)) where noise(frame * 977 + py * 61 + qx + i) > 0.55 {
                            c.rect(x + qx, y + py, max(1, s / 2), max(1, s / 2), C(0xD8DCD8, 0.6 * bright))
                        }
                    }
                case 2:      // a waveform
                    for qx in 0..<w {
                        let v = sin(Double(qx) / Double(s) * 0.9 + t * 5) * sin(t * 1.3 + Double(qx) * 0.05)
                        c.rect(x + qx, y + h / 2 + Int(v * Double(h / 2 - s)), 1, max(1, s / 2), C(0xFFD24A, 0.8 * bright))
                    }
                case 3:      // radar: the sweep going round, a blip
                    let cx = x + w / 2, cy = y + h / 2, rad = min(w, h) / 2 - s / 2
                    c.circle(cx, cy, rad, C(0x2A6A3A, 0.4 * bright))
                    let a = t * 2
                    filesLine(c, cx, cy, cx + Int(cos(a) * Double(rad)), cy + Int(sin(a) * Double(rad)), max(1, s / 2), C(0x8AFFA0, 0.85 * bright))
                    if sin(a) > 0.7 { c.rect(cx + rad / 2, cy + rad / 3, s, s, C(0xFF6A4A)) }
                default:     // a grainy surveillance shot: a figure in a doorway
                    c.rect(x, y, w, h, C(0x5A6A5A, 0.5 * bright))
                    c.rect(x + w / 2 - s, y + h / 4, 2 * s, h * 3 / 4, C(0x1A221A, 0.8))
                    if Int(t * 2) % 2 == 0 { c.rect(x + s, y + s, s, s, C(0xFF3A3A)) }
                }
            }
        }
        // The reels.
        let dk = f.deck
        for (n, rx) in denReels(dk, s).enumerated() {
            let a0 = t * (n == 0 ? 2.2 : 1.6)
            for k in 0..<3 {
                let a = a0 + Double(k) * 2 * .pi / 3
                filesLine(c, rx + Int(cos(a) * Double(2 * s)), dk.y + 8 * s + Int(sin(a) * Double(2 * s)),
                          rx + Int(cos(a) * Double(6 * s)), dk.y + 8 * s + Int(sin(a) * Double(6 * s)), max(1, s / 2), C(0x3A3A40))
            }
        }
        if Int(t * 1.5) % 2 == 0 { c.rect(dk.x + 30 * s, dk.y + 19 * s, s, s, C(0xFF2A2A)) }
        // The needles in the meters.
        for (n, mx) in [dk.x + 9 * s, dk.x + 24 * s].enumerated() {
            let v = 0.5 + 0.5 * sin(t * (3 + Double(n)) + noise(Int(t * 4) + n) * 2)
            filesLine(c, mx, dk.y + 22 * s, mx - 3 * s + Int(v * Double(6 * s)), dk.y + 18 * s, max(1, s / 2), C(0x2A2020))
        }
    }
}

// MARK: - Apartment 42

extension Scenes {
    /// Where things stand in Clawder's apartment: the window with its tape X, the couch, the TV and the fish tank.
    static func aptFrame(_ c: PixelCanvas, _ g: Int) -> (window: (x: Int, y: Int, w: Int, h: Int), couch: (x: Int, w: Int),
                                                         tv: (x: Int, y: Int), tank: (x: Int, y: Int, w: Int, h: Int),
                                                         ceiling: Int) {
        let s = unit(g)
        let ceiling = g > 60 ? 4 * s : 0
        let wh = min(isTall(c) ? 70 * s : 34 * s, g - ceiling - 20 * s), ww = min(isTall(c) ? 40 * s : 32 * s, c.w * 14 / 100)
        let window = (x: c.w * 7 / 100, y: max(ceiling + 3 * s, g - 22 * s - wh), w: ww, h: wh)
        let tank = (x: c.w * 68 / 100, y: g - 36 * s, w: 40 * s, h: 20 * s)
        return (window, (c.w * 27 / 100, 72 * s), (c.w * 27 / 100 + 84 * s, g - 31 * s), tank, ceiling)
    }

    /// Apartment 42, Clawder's place, late at night: a dim room with only the TV and the fish tank for light. The
    /// window has a tape X stuck across it (the signal for Mister X), a worn leather couch he sleeps on more than his
    /// bed, a small TV on a stand, the fish tank bubbling on its cabinet, and the door with its brass 42, his trench
    /// coat on the hook beside it. Two photos hang over the couch and a radiator sits under the window. On the screen
    /// saver, shelves of videotapes and books go up the wall to a ceiling lamp, under a cornice and a picture rail hung
    /// with frames, a heating pipe climbing the corner.
    static func apartment42(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = aptFrame(c, g)
        c.gradient(0, g, C(0x161A22), C(0x2C323C), bands: 6)
        if f.ceiling > 0 { c.rect(0, 0, c.w, f.ceiling, C(0x22262E)); c.rect(0, f.ceiling - s, c.w, s, C(0x383E48)) }
        // A skirting board.
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0x3A3E46))
        if tall { aptUpperWall(c, g, s: s, ceiling: f.ceiling) }
        // Two photos over the couch: a girl in a school photo, and a blurred light in a night sky.
        for (k, px) in [f.couch.x + 14 * s, f.couch.x + 44 * s].enumerated() where g - 40 * s > f.ceiling + 2 * s {
            let py = g - 40 * s
            c.rect(px - s, py - s, 12 * s, 10 * s, C(0x5A4430)); c.rect(px, py, 10 * s, 8 * s, k == 0 ? C(0x8A9AAA) : C(0x14182A))
            if k == 0 {
                c.rect(px + 4 * s, py + 2 * s, 3 * s, 3 * s, C(0xD8A888)); c.rect(px + 3 * s, py + 2 * s, 5 * s, s, C(0x3A2A1E))
                c.rect(px + 3 * s, py + 5 * s, 5 * s, 3 * s, C(0x6A3A3A))
            } else {
                c.rect(px + 4 * s, py + 3 * s, 2 * s, s, C(0xE8F0D8)); c.rect(px + 3 * s, py + 4 * s, 4 * s, max(1, s / 2), C(0xC8D8C0, 0.6))
            }
        }
        if tall {
            // The ceiling lamp, and shelves of tapes and books.
            c.rect(c.w / 2, f.ceiling, s, 10 * s, C(0x3A3A3A)); c.ellipse(c.w / 2, f.ceiling + 12 * s, 7 * s, 3 * s, C(0x8A7A5A))
            let sx = c.w * 40 / 100, bottom = g - 44 * s, top = max(f.ceiling + 30 * s, bottom - 5 * 12 * s)
            for y in stride(from: top, to: bottom, by: 12 * s) {
                c.rect(sx, y + 10 * s, c.w * 26 / 100, s, C(0x4A3A2A))
                var x = sx, i = 0
                while x < sx + c.w * 26 / 100 - 4 * s {
                    let bw = (2 + Int(noise(y * 3 + i) * 2)) * s
                    c.rect(x, y + 3 * s, bw - max(1, s / 2), 7 * s, [C(0x1E1E22), C(0x2E2E34), C(0x6A3A2A), C(0x3A4A5A)][i % 4])
                    x += bw; i += 1
                }
            }
        }
        // The window: the city at night, and the tape X across it.
        let w = f.window
        c.rect(w.x - 2 * s, w.y - 2 * s, w.w + 4 * s, w.h + 4 * s, C(0x8A8C88))
        filesBox(c, w.x, w.y, w.w, w.h, C(0x0A0E18), C(0x1A2234))
        for i in 0..<14 {
            let lx = w.x + Int(noise(i + 500) * Double(w.w - s)), ly = w.y + w.h / 3 + Int(noise(i + 520) * Double(w.h * 2 / 3 - s))
            c.rect(lx, ly, s, s, C(0xE8C878, 0.55))
        }
        c.rect(w.x + w.w / 2, w.y, s, w.h, C(0x8A8C88)); c.rect(w.x, w.y + w.h / 2, w.w, s, C(0x8A8C88))
        filesLine(c, w.x + 2 * s, w.y + 2 * s, w.x + w.w - 4 * s, w.y + w.h - 4 * s, 2 * s, C(0xE8DCB0))
        filesLine(c, w.x + w.w - 4 * s, w.y + 2 * s, w.x + 2 * s, w.y + w.h - 4 * s, 2 * s, C(0xE8DCB0))
        c.rect(w.x - 3 * s, w.y + w.h + 2 * s, w.w + 6 * s, s, C(0x6A6C68))
        // The radiator under it, painted over many times, standing on the floor.
        let rw = w.w - 6 * s, rx = w.x + 3 * s
        if g - (w.y + w.h) > 18 * s {
            c.rect(rx, g - 13 * s, rw, 10 * s, C(0x5A5E5A))
            for x in stride(from: rx + s, to: rx + rw - s, by: 3 * s) { c.rect(x, g - 12 * s, 2 * s, 9 * s, C(0x6E726C)); c.rect(x, g - 12 * s, s, 9 * s, C(0x7E827C)) }
            c.rect(rx, g - 13 * s, rw, s, C(0x7E827C)); c.rect(rx + rw, g - 7 * s, 3 * s, s, C(0x4A4E4A))
        }
        // The couch: worn black-brown leather.
        let cx = f.couch.x, cw = f.couch.w, back = g - 21 * s
        c.rect(cx, back, cw, 12 * s, C(0x2E1C14)); c.rect(cx, back, cw, s, C(0x4E3022))
        c.rect(cx - 6 * s, back + 5 * s, 7 * s, g - back - 6 * s, C(0x3A2418)); c.rect(cx + cw - s, back + 5 * s, 7 * s, g - back - 6 * s, C(0x3A2418))
        c.rect(cx - 6 * s, back + 5 * s, 7 * s, s, C(0x5A3A26)); c.rect(cx + cw - s, back + 5 * s, 7 * s, s, C(0x5A3A26))
        c.rect(cx, g - 10 * s, cw, 7 * s, C(0x3A2418)); c.rect(cx, g - 10 * s, cw, s, C(0x5A3A26))
        for k in 1..<3 {   // the seams between the cushions
            c.rect(cx + k * cw / 3, g - 10 * s, max(1, s / 2), 7 * s, C(0x22140E)); c.rect(cx + k * cw / 3, back + s, max(1, s / 2), 11 * s, C(0x22140E))
        }
        c.rect(cx - 5 * s, g - s, 2 * s, s, C(0x1A100A)); c.rect(cx + cw + 3 * s, g - s, 2 * s, s, C(0x1A100A))   // the feet
        c.rect(cx + 4 * s, back + 2 * s, 8 * s, 2 * s, C(0x5A3A26, 0.6))   // a shine on the leather
        c.rect(cx + 8 * s, g - 13 * s, 14 * s, 4 * s, C(0x7A6A5A)); c.rect(cx + 8 * s, g - 13 * s, 14 * s, s, C(0x8A7A6A))   // a blanket left on it
        // The TV on its stand (its picture comes with the moving layer).
        let tv = f.tv
        c.rect(tv.x, tv.y + 15 * s, 24 * s, g - tv.y - 15 * s, C(0x2A2420)); c.rect(tv.x, tv.y + 15 * s, 24 * s, s, C(0x3E3630))
        c.rect(tv.x + 3 * s, tv.y + 19 * s, 18 * s, 5 * s, C(0x221C18)); c.rect(tv.x + 5 * s, tv.y + 21 * s, 6 * s, 2 * s, C(0x1A1A1E))   // the VCR
        c.rect(tv.x + 2 * s, tv.y, 20 * s, 15 * s, C(0x2A2A2E)); c.rect(tv.x + 2 * s, tv.y, 20 * s, s, C(0x3E3E44))
        c.rect(tv.x + 3 * s, tv.y + 2 * s, 15 * s, 11 * s, C(0x0C1018))
        c.rect(tv.x + 19 * s, tv.y + 3 * s, 2 * s, 2 * s, C(0x6A6A6E)); c.rect(tv.x + 19 * s, tv.y + 7 * s, 2 * s, 2 * s, C(0x6A6A6E))
        filesLine(c, tv.x + 12 * s, tv.y, tv.x + 7 * s, tv.y - 8 * s, max(1, s / 2), C(0x8A8A8E))
        filesLine(c, tv.x + 12 * s, tv.y, tv.x + 17 * s, tv.y - 8 * s, max(1, s / 2), C(0x8A8A8E))
        // The fish tank on its cabinet: water, gravel, a plant, the hood's light.
        let tk = f.tank
        c.rect(tk.x - 2 * s, tk.y + tk.h, tk.w + 4 * s, g - tk.y - tk.h, C(0x2A2018)); c.rect(tk.x - 2 * s, tk.y + tk.h, tk.w + 4 * s, s, C(0x3E3024))
        c.rect(tk.x - s, tk.y - s, tk.w + 2 * s, tk.h + 2 * s, C(0x1A1A1E))
        c.rect(tk.x, tk.y, tk.w, tk.h, C(0x1E5A6A))
        c.rect(tk.x, tk.y + tk.h - 3 * s, tk.w, 3 * s, C(0x8A7A5A))
        for i in 0..<tk.w / s { if noise(i + 600) > 0.6 { c.rect(tk.x + i * s, tk.y + tk.h - 3 * s, s, s, C(0xB8A880)) } }
        for k in 0..<3 {
            let px = tk.x + 6 * s + k * 12 * s
            for y in stride(from: tk.y + tk.h - 3 * s, to: tk.y + 4 * s + k * 2 * s, by: -s) {
                c.rect(px + Int(sin(Double(y) * 0.4 + Double(k)) * Double(s)), y, s, s, C(0x3A8A4A))
            }
        }
        c.rect(tk.x - s, tk.y - 2 * s, tk.w + 2 * s, 2 * s, C(0x2A2A2E))
        // The door and its number.
        let dx = c.w * 88 / 100, dh = min(38 * s, g - f.ceiling - 3 * s)
        c.rect(dx - s, g - dh - s, 20 * s, dh + s, C(0x6A6C68)); c.rect(dx, g - dh, 18 * s, dh, C(0x4A3426))
        c.rect(dx + 2 * s, g - dh + 3 * s, 14 * s, dh / 2 - 4 * s, C(0x3E2A1E)); c.rect(dx + 2 * s, g - dh / 2 + 2 * s, 14 * s, dh / 2 - 5 * s, C(0x3E2A1E))
        c.rect(dx + 14 * s, g - dh / 2, 2 * s, 2 * s, C(0xC8A04A))
        if dh > 20 * s { filesNumber(c, "42", x: dx + 5 * s, y: g - dh + 5 * s, s: max(1, s), col: C(0xD8B85A)) }
        // His trench coat on the hook beside the door: the collar, the belt hanging loose, a fold down the back.
        let hx = dx - 9 * s, hy = g - min(34 * s, dh - 2 * s)
        c.rect(hx + 3 * s, hy - s, 2 * s, 2 * s, C(0xC8A04A))
        c.rect(hx + s, hy, 6 * s, 3 * s, C(0x7A6A4A)); c.rect(hx, hy + 3 * s, 8 * s, 18 * s, C(0x8A7A56))
        c.rect(hx, hy + 3 * s, s, 18 * s, C(0x6A5A3E)); c.rect(hx + 4 * s, hy + 4 * s, max(1, s / 2), 17 * s, C(0x6A5A3E))
        c.rect(hx - s, hy + 10 * s, 10 * s, s, C(0x6A5A3E)); c.rect(hx + 7 * s, hy + 11 * s, s, 5 * s, C(0x6A5A3E))
        // The floor: worn boards.
        c.ground(g, C(0x3A2C22), edge: C(0x5A4434), speck: C(0x2E221A), seed: 71)
        for x in stride(from: 0, to: c.w, by: 14 * s) { c.rect(x, g + 1, max(1, s / 2), c.h - g - 1, C(0x2A1E16)) }
    }

    /// The apartment's upper wall on the screen saver: a cornice under the ceiling, a heating pipe up the corner, and a
    /// picture rail with frames hung from it on their wires (a map, a seascape, an old photo, a print of the moon).
    private static func aptUpperWall(_ c: PixelCanvas, _ g: Int, s: Int, ceiling: Int) {
        c.rect(0, ceiling, c.w, 3 * s, C(0x2A2E36)); c.rect(0, ceiling + 3 * s, c.w, s, C(0x3A404A))
        c.rect(c.w * 2 / 100, ceiling + 4 * s, 3 * s, g - ceiling - 7 * s, C(0x4A4E52)); c.rect(c.w * 2 / 100, ceiling + 4 * s, s, g - ceiling - 7 * s, C(0x5E6266))
        for y in stride(from: ceiling + 30 * s, to: g - 10 * s, by: 60 * s) { c.rect(c.w * 2 / 100 - s, y, 5 * s, 2 * s, C(0x34383E)) }
        let rail = g - 140 * s
        guard rail > ceiling + 30 * s else { return }
        // Old wallpaper above the rail: faint stripes, a small figure between them, a water stain from the flat above.
        for x in stride(from: 0, to: c.w, by: 12 * s) {
            c.rect(x, ceiling + 4 * s, s, rail - ceiling - 4 * s, C(0x3A4250, 0.22))
            for y in stride(from: ceiling + 10 * s + (x / (12 * s)) % 2 * 9 * s, to: rail - 4 * s, by: 18 * s) {
                c.rect(x + 5 * s, y, 2 * s, 2 * s, C(0x3A4250, 0.45)); c.rect(x + 6 * s, y - s, max(1, s / 2), 4 * s, C(0x3A4250, 0.3))
            }
        }
        c.ellipse(c.w * 70 / 100, ceiling + 10 * s, 26 * s, 9 * s, C(0x4A4030, 0.18)); c.ellipse(c.w * 70 / 100, ceiling + 9 * s, 18 * s, 6 * s, C(0x5A4C36, 0.14))
        c.rect(0, rail, c.w, 2 * s, C(0x3A3026)); c.rect(0, rail, c.w, max(1, s / 2), C(0x5A4A3A))
        let frames: [(x: Int, w: Int, h: Int, drop: Int)] = [(c.w * 20 / 100, 22 * s, 16 * s, 6 * s), (c.w * 44 / 100, 16 * s, 12 * s, 8 * s),
                                                               (c.w * 58 / 100, 26 * s, 18 * s, 5 * s), (c.w * 80 / 100, 14 * s, 14 * s, 9 * s)]
        for (k, fr) in frames.enumerated() {
            let top = rail + 2 * s + fr.drop
            filesLine(c, fr.x + fr.w / 2, rail + 2 * s, fr.x + 2 * s, top, max(1, s / 2), C(0x6A6A6A))
            filesLine(c, fr.x + fr.w / 2, rail + 2 * s, fr.x + fr.w - 2 * s, top, max(1, s / 2), C(0x6A6A6A))
            c.rect(fr.x - s, top - s, fr.w + 2 * s, fr.h + 2 * s, C(0x4A3828))
            let ix = fr.x + s, iy = top + s, iw = fr.w - 2 * s, ih = fr.h - 2 * s
            switch k {
            case 0:   // a map, pale with roads
                c.rect(ix, iy, iw, ih, C(0xC8C4A8)); c.rect(ix, iy + ih / 2, iw, s, C(0x9A6A4A)); c.rect(ix + iw / 3, iy, s, ih, C(0x9A6A4A))
                c.ellipse(ix + iw * 2 / 3, iy + ih / 3, iw / 6, ih / 6, C(0x8AA8B8))
            case 1:   // a seascape at dusk
                filesBox(c, ix, iy, iw, ih / 2, C(0x5A4A6A), C(0xC88A5A)); c.rect(ix, iy + ih / 2, iw, ih - ih / 2, C(0x2A3A5A))
            case 2:   // an old photo of the family, sepia
                c.rect(ix, iy, iw, ih, C(0xA8946A))
                for (u, h) in [(4, 9), (9, 11), (14, 8), (19, 7)] where u * s + 3 * s < iw {
                    c.rect(ix + u * s, iy + ih - h * s, 3 * s, h * s, C(0x5A4A32)); c.rect(ix + u * s, iy + ih - h * s - 2 * s, 3 * s, 2 * s, C(0x7A6446))
                }
            default:  // a print of the moon
                c.rect(ix, iy, iw, ih, C(0x0E1018)); c.circle(ix + iw / 2, iy + ih / 2, min(iw, ih) / 3, C(0xD8D8CC))
                c.circle(ix + iw / 2 + s, iy + ih / 2 - s, max(1, min(iw, ih) / 10), C(0xA8A89C))
            }
        }
    }

    /// What moves in Apartment 42: the TV's flickering blue light washing over the couch, the fish swimming back and
    /// forth with bubbles rising, the tank's glow, and the tape X catching the lamplight.
    static func apartment42Life(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = aptFrame(c, g)
        // The TV: its picture changing, and its light thrown on the couch and the floor.
        let tv = f.tv
        let lum = 0.55 + 0.45 * noise(Int(t * 5))
        c.rect(tv.x + 3 * s, tv.y + 2 * s, 15 * s, 11 * s, C(0x6A8AC8, 0.5 * lum))
        c.rect(tv.x + 4 * s, tv.y + 3 * s + Int(noise(Int(t * 5) + 9) * 7) * s, 13 * s, s, C(0xE8F0FF, 0.6 * lum))
        c.rect(f.couch.x - 6 * s, g - 22 * s, tv.x - f.couch.x + 6 * s, 22 * s, C(0x8AB0FF, 0.07 * lum))
        c.rect(f.couch.x - 10 * s, g, tv.x - f.couch.x + 30 * s, 4 * s, C(0x8AB0FF, 0.05 * lum))
        // The tank: its glow, the fish and the bubbles.
        let tk = f.tank
        c.rect(tk.x, tk.y, tk.w, tk.h - 3 * s, C(0x6AD8E8, 0.08 + 0.03 * sin(t)))
        for k in 0..<3 {
            let span = Double(tk.w - 6 * s)
            let p = (sin(t * (0.4 + Double(k) * 0.17) + Double(k) * 2) + 1) / 2
            let dir = cos(t * (0.4 + Double(k) * 0.17) + Double(k) * 2) > 0
            let fx = tk.x + 2 * s + Int(p * span), fy = tk.y + 3 * s + k * 4 * s + Int(sin(t * 1.3 + Double(k)) * Double(s))
            let col = [C(0xFF8A2A), C(0xFFD24A), C(0xE8E8F0)][k]
            c.rect(fx, fy, 3 * s, 2 * s, col)
            c.rect(dir ? fx - s : fx + 3 * s, fy, s, 2 * s, col.alpha(0.7))   // the tail, behind it
            c.rect(dir ? fx + 2 * s : fx, fy, max(1, s / 2), max(1, s / 2), ink)
        }
        for i in 0..<5 {
            let k = (t * 0.5 + Double(i) / 5).truncatingRemainder(dividingBy: 1)
            c.rect(tk.x + tk.w - 5 * s + Int(sin(k * 9) * Double(s)), tk.y + tk.h - 4 * s - Int(k * Double(tk.h - 5 * s)), s, s, C(0xE8FCFF, 0.7))
        }
        // The tape X catching the light now and then (he's signalling).
        let w = f.window, glow = 0.12 + 0.12 * max(0, sin(t * 0.8))
        filesLine(c, w.x + 2 * s, w.y + 2 * s, w.x + w.w - 4 * s, w.y + w.h - 4 * s, 2 * s, C(0xFFF4C8, glow))
        filesLine(c, w.x + w.w - 4 * s, w.y + 2 * s, w.x + 2 * s, w.y + w.h - 4 * s, 2 * s, C(0xFFF4C8, glow))
    }
}

// MARK: - The Syndicate's club

extension Scenes {
    /// Where things stand in the club: the fireplace (centre, opening width and height), the chairs either side and the
    /// side table's ashtray.
    static func clubFrame(_ c: PixelCanvas, _ g: Int) -> (fire: (cx: Int, w: Int, h: Int), chairs: [Int], ashtray: (x: Int, y: Int),
                                                          ceiling: Int) {
        let s = unit(g)
        let ceiling = g > 60 ? 5 * s : 0
        let cx = c.w * 52 / 100
        return ((cx, 30 * s, 20 * s), [cx - 60 * s, cx + 36 * s], (cx + 70 * s, g - 17 * s), ceiling)
    }

    /// The Syndicate's club on 46th Street: a room of dark panelled wood and old money. A stone fireplace with a portrait
    /// above the mantel, oxblood wingback chairs either side, a side table with a decanter and a smouldering cigar, a
    /// tall window with green velvet curtains, a brass lamp and a red rug. On the screen saver, bookcases rise to a
    /// coffered ceiling and a chandelier.
    static func syndicateClub(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = clubFrame(c, g)
        c.gradient(0, g, C(0x22140C), C(0x3A2416), bands: 6)
        // The panelling: tall raised panels with lighter frames, and a dado rail.
        let dado = g - 14 * s
        for x in stride(from: 3 * s, to: c.w, by: 20 * s) {
            c.rect(x, f.ceiling + 4 * s, 16 * s, dado - f.ceiling - 7 * s, C(0x2E1A0E))
            c.rect(x, f.ceiling + 4 * s, 16 * s, s, C(0x4A2E1A)); c.rect(x, f.ceiling + 4 * s, s, dado - f.ceiling - 7 * s, C(0x4A2E1A))
            c.rect(x, dado + 3 * s, 16 * s, 9 * s, C(0x2E1A0E)); c.rect(x, dado + 3 * s, 16 * s, s, C(0x4A2E1A))
        }
        c.rect(0, dado, c.w, 2 * s, C(0x5A3820))
        if f.ceiling > 0 { c.rect(0, 0, c.w, f.ceiling, C(0x1A0E08)); c.rect(0, f.ceiling - s, c.w, s, C(0x6A4628)) }
        if tall {
            // Coffered ceiling, the chandelier, and bookcases either side.
            for x in stride(from: 0, to: c.w, by: 24 * s) { c.rect(x, 0, 2 * s, f.ceiling + 2 * s, C(0x3A2414)) }
            let ch = c.w / 2
            c.rect(ch, f.ceiling, s, 14 * s, C(0xB89A4A))
            c.rect(ch - 10 * s, f.ceiling + 14 * s, 21 * s, 2 * s, C(0xB89A4A))
            for k in -2...2 {
                c.rect(ch + k * 5 * s, f.ceiling + 11 * s, s, 3 * s, C(0xF2F0EA)); c.rect(ch + k * 5 * s, f.ceiling + 9 * s, s, 2 * s, C(0xFFD27A))
            }
            for bx in [c.w * 4 / 100, c.w * 78 / 100] {
                let top = f.ceiling + 24 * s, bottom = g - 66 * s   // clear of the window and its pelmet
                guard bottom - top > 20 * s else { continue }
                c.rect(bx, top, c.w * 18 / 100, bottom - top, C(0x1E1008))
                for y in stride(from: top + 2 * s, to: bottom - 9 * s, by: 10 * s) {
                    var x = bx + 2 * s, i = 0
                    while x < bx + c.w * 18 / 100 - 4 * s {
                        let bw = (2 + Int(noise(y + i * 7) * 2)) * s
                        c.rect(x, y + 8 * s - (6 + Int(noise(y + i) * 2)) * s, bw - max(1, s / 2), (6 + Int(noise(y + i) * 2)) * s,
                               [C(0x5A1E16), C(0x1E3A2A), C(0x6A5030), C(0x2A1E3A)][i % 4])
                        x += bw; i += 1
                    }
                    c.rect(bx, y + 8 * s, c.w * 18 / 100, s, C(0x4A2E1A))
                }
            }
        }
        // The window, behind heavy green velvet.
        let wx = c.w * 10 / 100, wh = min(40 * s, dado - f.ceiling - 8 * s), wy = dado - wh - 2 * s
        if wh > 10 * s {
            filesBox(c, wx, wy, 20 * s, wh, C(0x0A0E18), C(0x141C2A))
            c.rect(wx + 10 * s, wy, s, wh, C(0x3A2414)); c.rect(wx, wy + wh / 2, 20 * s, s, C(0x3A2414))
            for (x, dir) in [(wx - 6 * s, 1), (wx + 16 * s, -1)] {
                c.rect(x, wy - 4 * s, 10 * s, wh + 8 * s, C(0x1E3A2A))
                for k in stride(from: 2 * s, to: 10 * s, by: 3 * s) { c.rect(x + k, wy - 4 * s, max(1, s / 2), wh + 8 * s, C(0x142A1E)) }
                c.rect(x + (dir > 0 ? 6 : 0) * s, wy + wh / 2, 4 * s, 2 * s, C(0xC8A04A))   // the tie-back
            }
            c.rect(wx - 8 * s, wy - 6 * s, 36 * s, 2 * s, C(0x8A6A30))
        }
        // The fireplace: the stone surround, the black opening and its grate, the mantel, the portrait above.
        let fp = f.fire, fbase = g, ftop = fbase - fp.h
        c.rect(fp.cx - fp.w / 2 - 8 * s, ftop - 6 * s, fp.w + 16 * s, fp.h + 6 * s, C(0x6A6258))
        c.rect(fp.cx - fp.w / 2 - 8 * s, ftop - 6 * s, fp.w + 16 * s, s, C(0x8A8276))
        c.rect(fp.cx - fp.w / 2, ftop, fp.w, fp.h, C(0x0E0806))
        c.rect(fp.cx - fp.w / 2 + 3 * s, fbase - 3 * s, fp.w - 6 * s, s, C(0x2A2220))
        for k in 0..<4 { c.rect(fp.cx - fp.w / 2 + 4 * s + k * (fp.w - 8 * s) / 3, fbase - 4 * s, s, 3 * s, C(0x2A2220)) }
        c.rect(fp.cx - fp.w / 2 + 5 * s, fbase - 5 * s, fp.w - 10 * s, 2 * s, C(0x3A2216))   // logs
        c.rect(fp.cx - fp.w / 2 - 12 * s, ftop - 9 * s, fp.w + 24 * s, 3 * s, C(0x3A2010)); c.rect(fp.cx - fp.w / 2 - 12 * s, ftop - 9 * s, fp.w + 24 * s, s, C(0x5A3420))
        c.rect(fp.cx - fp.w / 2 - 6 * s, ftop - 13 * s, 3 * s, 4 * s, C(0xB89A4A)); c.rect(fp.cx + fp.w / 2 + 3 * s, ftop - 13 * s, 3 * s, 4 * s, C(0xB89A4A))
        let ph = min(24 * s, ftop - 12 * s - f.ceiling - 4 * s), pw = 20 * s
        if ph > 10 * s {
            let py = ftop - 12 * s - ph
            c.rect(fp.cx - pw / 2 - 2 * s, py - 2 * s, pw + 4 * s, ph + 4 * s, C(0xB89A4A))
            c.rect(fp.cx - pw / 2, py, pw, ph, C(0x1E1A12))
            c.ellipse(fp.cx, py + ph / 3, 4 * s, 5 * s, C(0x8A6A50)); c.rect(fp.cx - 6 * s, py + ph / 2 + 2 * s, 12 * s, ph / 2 - 2 * s, C(0x1A1E26))
            c.rect(fp.cx - s, py + ph / 2 + 2 * s, 2 * s, 3 * s, C(0xE8E4D8))
        }
        // The wingback chairs, oxblood leather with brass studs.
        for cx in f.chairs {
            let top = g - 27 * s
            c.rect(cx + 3 * s, top, 16 * s, 17 * s, C(0x5A1A16)); c.rect(cx + 3 * s, top, 16 * s, s, C(0x7A2A22))
            for k in 0..<3 { c.rect(cx + 6 * s + k * 5 * s, top + 3 * s, max(1, s / 2), 11 * s, C(0x461410)) }   // the buttoning
            c.rect(cx, top + 4 * s, 4 * s, 21 * s, C(0x4A1410)); c.rect(cx + 18 * s, top + 4 * s, 4 * s, 21 * s, C(0x4A1410))
            c.rect(cx, top + 4 * s, 4 * s, s, C(0x6A2018)); c.rect(cx + 18 * s, top + 4 * s, 4 * s, s, C(0x6A2018))
            c.rect(cx + 3 * s, g - 10 * s, 16 * s, 6 * s, C(0x6A2018)); c.rect(cx + 3 * s, g - 10 * s, 16 * s, s, C(0x8A3428))
            for k in 0..<7 { c.rect(cx + 4 * s + k * 2 * s, g - 4 * s, max(1, s / 2), max(1, s / 2), C(0xC8A04A)) }
            c.rect(cx + s, g - 3 * s, 2 * s, 3 * s, C(0x2A1408)); c.rect(cx + 19 * s, g - 3 * s, 2 * s, 3 * s, C(0x2A1408))
        }
        // The side table: a crystal decanter and the ashtray (its cigar smokes in the moving layer).
        let a = f.ashtray
        c.rect(a.x - 8 * s, a.y, 18 * s, 2 * s, C(0x3A2010)); c.rect(a.x - 8 * s, a.y, 18 * s, s, C(0x5A3420))
        c.rect(a.x - 6 * s, a.y + 2 * s, 2 * s, g - a.y - 2 * s, C(0x2A1408)); c.rect(a.x + 6 * s, a.y + 2 * s, 2 * s, g - a.y - 2 * s, C(0x2A1408))
        c.rect(a.x - 6 * s, g - 5 * s, 14 * s, s, C(0x2A1408))
        c.rect(a.x - 6 * s, a.y - 8 * s, 5 * s, 8 * s, C(0xC89A5A, 0.6)); c.rect(a.x - 5 * s, a.y - 10 * s, 3 * s, 2 * s, C(0xD8DCE0, 0.7))
        c.rect(a.x - 6 * s, a.y - 8 * s, s, 6 * s, C(0xF0E8D8, 0.4))   // a glint on the crystal
        c.rect(a.x + s, a.y - s, 5 * s, s, C(0x8A8E96)); c.rect(a.x + 2 * s, a.y - 2 * s, 3 * s, s, C(0x5A3A20))
        // A brass floor lamp by the window.
        let lx = c.w * 28 / 100
        c.rect(lx, g - 30 * s, s, 30 * s, C(0xB89A4A)); c.rect(lx - 2 * s, g - s, 5 * s, s, C(0xB89A4A))
        c.rect(lx - 4 * s, g - 34 * s, 9 * s, 4 * s, C(0xC8A870)); c.rect(lx - 4 * s, g - 30 * s, 9 * s, s, C(0xFFE8A8, 0.5))
        // The rug, red with a border, on dark boards.
        c.ground(g, C(0x2A1A10), edge: C(0x3E2818), speck: C(0x1E1208), seed: 83)
        c.rect(c.w / 6, g + s, c.w * 2 / 3, max(1, c.h - g - 2 * s), C(0x5A1A16))
        c.rect(c.w / 6 + 2 * s, g + 2 * s, c.w * 2 / 3 - 4 * s, s, C(0xB89A4A, 0.5))
    }

    /// What moves in the club: the fire in the hearth and its glow on the floor, the cigar's thread of smoke curling up
    /// off the ashtray, and a haze of old smoke drifting under the ceiling.
    static func syndicateClubLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = clubFrame(c, g), fp = f.fire
        // The fire: tongues of flame over the logs, each flickering on its own.
        let x0 = fp.cx - fp.w / 2 + 4 * s, n = max(1, (fp.w - 8 * s) / s)
        for i in 0..<n {
            let flick = noise(i * 13 + Int(t * 10)) * 0.6 + 0.4 * sin(t * 7 + Double(i))
            let h = max(1, Int(Double(fp.h - 6 * s) * (0.35 + 0.4 * flick)))
            let x = x0 + i * s, base = g - 5 * s
            c.rect(x, base - h, s, h, C(0xD84A1A, 0.85))
            c.rect(x, base - h * 2 / 3, s, h * 2 / 3, C(0xFF8A2A, 0.85))
            c.rect(x, base - h / 3, s, h / 3, C(0xFFD25A, 0.9))
        }
        let glow = 0.1 + 0.04 * sin(t * 9) + 0.03 * noise(Int(t * 12))
        c.rect(fp.cx - fp.w, g, fp.w * 2, min(6 * s, c.h - g), C(0xFF8A3A, glow))
        c.rect(fp.cx - fp.w / 2, g - fp.h, fp.w, fp.h, C(0xFF8A3A, glow * 0.5))
        // The cigar's smoke, wavering up and away.
        let a = f.ashtray
        for i in 1...12 {
            let y = a.y - 2 * s - i * 2 * s
            let x = a.x + 6 * s + Int(sin(t * 0.9 + Double(i) * 0.55) * Double(i) * Double(s) / 3)
            c.rect(x, y, max(1, s / 2) + (i > 6 ? s / 2 : 0), 2 * s, C(0xC8C4BC, 0.55 - Double(i) * 0.04))
        }
        c.rect(a.x + 5 * s, a.y - 2 * s, s, s, C(0xFF5A1A, 0.7 + 0.3 * sin(t * 1.5)))
        // A layer of old smoke hanging under the ceiling: long soft banks drifting each their own way, thickest at the top.
        for k in 0..<4 {
            let y = f.ceiling + 4 * s + k * 4 * s
            let speed = (3 + Double(k)) * (k % 2 == 0 ? 1 : -1)
            let shift = Int((t * speed * Double(s)).truncatingRemainder(dividingBy: Double(c.w)))
            let alpha = 0.16 - Double(k) * 0.03
            for j in 0..<5 {
                let x = ((j * c.w / 5 + shift + k * 37 * s) % c.w + c.w) % c.w
                let rx = c.w / 10 + Int(noise(j * 7 + k) * Double(c.w / 16)), ry = 2 * s + k % 2 * s
                for dx in [-c.w, 0, c.w] {   // wrapping round the edges
                    c.ellipse(x + dx, y, rx, ry, C(0xB8B4AC, alpha))
                    c.ellipse(x + dx + rx / 3, y - s, rx / 2, max(1, ry - s), C(0xD0CCC4, alpha * 0.6))
                }
            }
        }
    }
}
