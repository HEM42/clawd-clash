import AppKit

// The Mos Eisley cantina (A New Hope) as the window-mode backdrop, drawn as pixel art in code:
// white-plaster adobe walls with arched booth alcoves, hanging lamps, the curved bar with its
// bottle shelf, a packed-earth floor, and Figrin D'an and the Modal Nodes on their little stage.

enum Cantina {
    /// Pixel size of the backdrop on screen.
    static let pixel: CGFloat = 2      // matches the crew's pixels at the window's Small size

    // Palette
    static let plaster = C(0xD9CBB0), plasterShade = C(0xB8A88C), plasterDark = C(0x9C8C70)
    static let ceiling = C(0x2A1E16), alcove = C(0x3B2B1F), alcoveDeep = C(0x2A1F16)
    static let wood = C(0x5A4636), barTop = C(0x3A2C22), barFront = C(0x8C7B60), barGroove = C(0x6E5F48)
    static let floor = C(0x4E3D2E), floorSpeck = C(0x5E4A38), floorEdge = C(0x6A5642)
    static let lamp = C(0xF2D08A), glow = C(0xFFC86A)

    /// The static part of the room, `w`×`h` pixels, with `floorRows` rows of floor at the bottom.
    static func drawRoom(_ c: PixelCanvas, floorRows: Int) {
        let w = c.w, h = c.h
        let wallBottom = h - floorRows

        // Back wall: warm plaster, a little darker toward the floor, with a lumpy hand-finished texture.
        for y in 0..<wallBottom {
            let k = Double(y) / Double(max(1, wallBottom))
            let col = k < 0.55 ? plaster : (k < 0.8 ? plasterShade : plasterDark)
            c.rect(0, y, w, 1, col)
        }
        for i in 0..<(w * h / 40) {
            let x = Int(noise(i * 7) * Double(w)), y = Int(noise(i * 7 + 1) * Double(wallBottom))
            c.px(x, y, noise(i * 7 + 2) > 0.5 ? plasterShade.alpha(0.6) : C(0xEFE4CF, 0.7))
        }

        // Ceiling with beams
        c.rect(0, 0, w, 5, ceiling)
        for x in stride(from: 6, to: w, by: 22) { c.rect(x, 5, 3, 2, ceiling) }

        // Regions the bar and the band stand occupy, so alcoves don't sit behind them.
        let band = 0..<min(w, bandWidth)
        let barStart = Int(Double(w) * 0.56), barEnd = min(w - 4, barStart + max(60, w / 3))

        // Arched booth alcoves along the back wall
        let archH = max(14, Int(Double(wallBottom) * 0.62))
        var x = bandWidth + 6
        while x + 26 < w {
            if !(x + 26 > barStart - 4 && x < barEnd + 4) && !band.contains(x) {
                drawAlcove(c, x: x, bottom: wallBottom, width: 26, height: archH)
            }
            x += 46
        }

        // Hanging lamps and soft light shafts
        for lx in stride(from: 18, to: w, by: 46) {
            c.rect(lx, 7, 1, 3, ceiling)
            c.rect(lx - 2, 10, 5, 2, lamp)
            c.rect(lx - 1, 12, 3, 1, glow)
            for y in 13..<wallBottom {
                let spread = (y - 13) / 3
                c.rect(lx - 1 - spread, y, 3 + spread * 2, 1, glow.alpha(0.07))
            }
        }

        // The bar: bottle shelf on the wall, then the curved counter
        if barEnd - barStart > 30 {
            let shelfY = wallBottom - 22
            c.rect(barStart + 4, shelfY, barEnd - barStart - 8, 2, wood)
            c.rect(barStart + 4, shelfY - 9, barEnd - barStart - 8, 1, wood)
            let bottleColors = [C(0x5FD0C8), C(0xE07A3A), C(0x9BE84A), C(0xD94F8A), C(0xF2D08A), C(0x7A8CFF)]
            var bx = barStart + 6
            var i = 0
            while bx < barEnd - 6 {
                let col = bottleColors[i % bottleColors.count]
                let tall = 3 + Int(noise(i * 5) * 4)
                c.rect(bx, shelfY - tall, 2, tall, col.alpha(0.9))
                c.px(bx, shelfY - tall - 1, col.alpha(0.6))
                if noise(i * 5 + 1) > 0.5 { c.rect(bx, shelfY - 8 - 6, 2, 6, col.alpha(0.85)) }
                bx += 3 + Int(noise(i * 5 + 2) * 2)
                i += 1
            }
            let counterTop = wallBottom - 11
            for y in counterTop..<wallBottom {
                // gently curved ends
                let inset = y == counterTop ? 3 : (y == counterTop + 1 ? 1 : 0)
                c.rect(barStart + inset, y, barEnd - barStart - inset * 2, 1, y < counterTop + 2 ? barTop : barFront)
            }
            for gx in stride(from: barStart + 4, to: barEnd - 3, by: 5) { c.rect(gx, counterTop + 3, 1, 7, barGroove) }
            c.rect(barStart, counterTop + 2, barEnd - barStart, 1, C(0xA8977A))   // brass rail
        }

        // Band stage
        c.rect(band.lowerBound + 2, wallBottom - 4, band.count - 4, 4, wood)
        c.rect(band.lowerBound + 2, wallBottom - 4, band.count - 4, 1, C(0x7A6450))

        // Packed-earth floor
        c.rect(0, wallBottom, w, floorRows, floor)
        c.rect(0, wallBottom, w, 1, floorEdge)
        for i in 0..<(w * floorRows / 6) {
            let fx = Int(noise(i * 11 + 3) * Double(w)), fy = wallBottom + 1 + Int(noise(i * 11 + 4) * Double(max(1, floorRows - 1)))
            c.px(fx, fy, floorSpeck)
        }
    }

    private static func drawAlcove(_ c: PixelCanvas, x: Int, bottom: Int, width: Int, height: Int) {
        let top = bottom - height
        let r = width / 2
        for y in top..<bottom {
            var half = r
            if y - top < r {                                    // round arch
                let dy = Double(r - (y - top))
                half = Int((Double(r * r) - dy * dy).squareRoot().rounded())
            }
            c.rect(x + r - half - 1, y, half * 2 + 2, 1, C(0xEFE4CF))   // bright plaster rim
            c.rect(x + r - half, y, half * 2, 1, y > bottom - height / 3 ? alcoveDeep : alcove)
        }
        // round table, a little lamp on it, and a booth bench
        c.rect(x + 3, bottom - 5, width - 6, 2, wood)
        c.rect(x + r - 4, bottom - 8, 8, 2, C(0x6E5440))
        c.rect(x + r - 1, bottom - 6, 2, 6, C(0x3A2C22))
        c.rect(x + r - 1, bottom - 11, 2, 3, glow.alpha(0.9))
        c.rect(x + r - 3, bottom - 12, 6, 1, glow.alpha(0.25))
    }

    /// Width of the band stage: room for the four Modal Nodes or the Max Rebo Band.
    static let bandWidth = 66

    /// Which band is playing: the Modal Nodes, or (at random) the Max Rebo Band. Re-rolled on each visit.
    static var maxReboTonight = Bool.random()

    /// Figrin D'an and the Modal Nodes as seen in the cantina: four Bith bobbing to the beat — Figrin D'an
    /// (kloo horn), Doikk Na'ts (Fizzz), Ickabel G'ont and Tedn Dahai (fanfars).
    static func drawBand(_ c: PixelCanvas, floorRows: Int, t: Double) {
        let base = c.h - floorRows - 4
        let skin = C(0xE3D8C4), skinShade = C(0xBDB09A), robe = C(0x2E2A30)
        let black = C(0x161618), silver = C(0xC9CED6), brass = C(0xD8B048), brassDark = C(0xA8842E)
        enum Instrument { case kloo, fizzz, fanfar, bandfill, ommni }
        let band: [Instrument] = [.kloo, .fizzz, .fanfar, .fanfar]
        for (i, instrument) in band.enumerated() {
            let x = 4 + i * 11
            let beat = Int((t * 2.2 + Double(i) * 0.29).truncatingRemainder(dividingBy: 1) * 2)   // on/off the beat
            c.oy = beat == 0 ? 0 : -1
            c.rect(x + 1, base - 9, 6, 9, robe)                              // robe
            c.pattern(x, base - 18, [
                "..SSSS..",
                ".SSSSSS.",
                "SSSSSSSS",
                "SsSSSSsS",
                "SEESSEES",
                "SEESSEES",
                ".SSSSSS.",
                "..SssS..",
                "...SS...",
            ], ["S": skin, "s": skinShade, "E": C(0x101010)])                // the big Bith head
            switch instrument {
            case .kloo:                                                      // long black clarinet-like horn
                c.rect(x + 4, base - 10, 1, 9, black)
                for k in [base - 8, base - 6, base - 4] { c.px(x + 4, k, silver) }
                c.rect(x + 3, base - 2, 3, 2, silver)                        // flared bell
            case .fizzz:                                                     // small silver whistle, held sideways
                c.rect(x + 4, base - 10, 5, 1, silver); c.px(x + 8, base - 11, silver)
            case .fanfar:                                                    // brass horn, bell up and forward
                c.rect(x + 5, base - 10, 1, 3, brass); c.rect(x + 6, base - 11, 2, 1, brass)
                c.rect(x + 8, base - 13, 2, 3, brass); c.px(x + 9, base - 14, brassDark)
            case .bandfill:                                                  // big curved bass horn
                c.rect(x + 4, base - 10, 1, 7, brassDark)
                c.rect(x + 4, base - 3, 4, 1, brassDark); c.rect(x + 7, base - 9, 1, 6, brass)
                c.rect(x + 6, base - 12, 3, 3, brass); c.px(x + 7, base - 12, brassDark)
            case .ommni:                                                     // ommni box with glowing keys
                c.rect(x + 1, base - 8, 7, 4, black)
                for k in 0..<3 { c.px(x + 2 + k * 2, base - 7, (Int(t * 4) + k) % 3 == 0 ? C(0x7AFFB0) : silver) }
            }
            c.oy = 0
        }
        // music notes drifting up
        for n in 0..<2 {
            let f = (t / 1.6 + Double(n) * 0.5).truncatingRemainder(dividingBy: 1)
            c.pattern(14 + n * 22, base - 22 - Int(f * 10), ["..N", "..N", "NNN", "NN."], ["N": C(0x3A2C22, 1 - f)])
        }
    }

    /// The bar crowd: Wuher the bartender polishing a glass behind the counter, and Dr. Cornelius Evazan
    /// with Ponda Baba leaning on the end of the bar, looking for trouble.
    static func drawBarCrowd(_ c: PixelCanvas, floorRows: Int, t: Double) {
        let w = c.w, wallBottom = c.h - floorRows
        let barStart = Int(Double(w) * 0.56), barEnd = min(w - 4, barStart + max(60, w / 3))
        guard barEnd - barStart > 30 else { return }
        let counterTop = wallBottom - 11
        let skin = C(0xD8A888), skinShade = C(0xB88868)

        // Wuher: balding, stubbly, apron, behind the counter (only head and shoulders show)
        let wx = barStart + (barEnd - barStart) * 2 / 3
        c.rect(wx - 3, counterTop - 4, 8, 4, C(0x6E5A44))                      // shirt
        c.rect(wx - 1, counterTop - 4, 4, 4, C(0xC8BCA0))                      // apron bib
        c.rect(wx - 2, counterTop - 10, 6, 6, skin)                            // head
        c.rect(wx - 2, counterTop - 10, 6, 1, C(0x5A4A3A))                     // thin hair
        c.px(wx - 1, counterTop - 8, C(0x2A1A10)); c.px(wx + 2, counterTop - 8, C(0x2A1A10))
        c.rect(wx - 1, counterTop - 6, 4, 1, skinShade)                        // stubble
        // polishing a glass, rag going round and round
        let k = Int(t * 6) % 4
        c.rect(wx + 5, counterTop - 4 - (k == 1 || k == 2 ? 1 : 0), 2, 3, C(0xBFE0F0, 0.8))
        c.px(wx + 4 + (k % 2), counterTop - 3, white)

        // Dr. Cornelius Evazan: scarred face, dark coat, at the near end of the bar
        let ex = barStart - 10
        c.rect(ex, wallBottom - 10, 6, 10, C(0x3A3028))                        // coat
        c.rect(ex + 1, wallBottom - 3, 1, 3, C(0x2A221C)); c.rect(ex + 4, wallBottom - 3, 1, 3, C(0x2A221C))
        c.rect(ex, wallBottom - 16, 6, 6, C(0xC89878))                         // face
        c.rect(ex, wallBottom - 16, 6, 1, C(0x3A2A1E))                         // hair
        c.px(ex + 1, wallBottom - 14, C(0x2A1A10)); c.px(ex + 4, wallBottom - 14, C(0x2A1A10))
        c.px(ex + 2, wallBottom - 13, C(0x8A4A3A)); c.px(ex + 3, wallBottom - 12, C(0x8A4A3A))   // the scars
        c.px(ex + 4, wallBottom - 12, C(0x8A4A3A))
        c.rect(ex + 6, wallBottom - 9, 3, 1, C(0x3A3028))                      // elbow on the bar

        // Ponda Baba: Aqualish — walrus face with tusks, brown coat, just behind him
        let px = barStart - 20
        c.rect(px, wallBottom - 10, 7, 10, C(0x5A4A32))                        // coat
        c.rect(px + 1, wallBottom - 3, 1, 3, C(0x3A2E20)); c.rect(px + 5, wallBottom - 3, 1, 3, C(0x3A2E20))
        c.rect(px, wallBottom - 16, 7, 6, C(0x7A6A58))                         // big jowly face
        c.px(px + 1, wallBottom - 15, C(0x101010)); c.px(px + 5, wallBottom - 15, C(0x101010))
        c.px(px + 2, wallBottom - 11, C(0xF0E6CC)); c.px(px + 4, wallBottom - 11, C(0xF0E6CC))  // tusks
        c.rect(px + 1, wallBottom - 13, 5, 1, C(0x5A4A3A))
    }
}
