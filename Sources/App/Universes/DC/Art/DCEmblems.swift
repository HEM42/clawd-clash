import Foundation

// The Detective Claws chest marks, shared by the heroes, the villains and the places: the C-shield (for Clawd) in
// place of the S-shield, a claw mark in place of the bat, a lamp in place of the lantern symbol and a flame in place
// of the Flash's bolt. Each keeps the size, place and colours of the mark it replaces.

/// How big an emblem is, in canvas pixels.
enum DCEmblemSize {
    case small    // C-shield 7×5, lamp 5×4, flame 4×4
    case medium   // C-shield 7×6, lamp 6×5, flame 6×4
    case large    // C-shield 9×6, lamp 7×6, flame 5×6
}

/// The C-shield, its top-left at (`x`, `y`): the five-sided shield with a C in `letter` on a `field` ground (nil:
/// just the C). The C's top bar runs along the shield's top edge and its stem down the left, open to the right.
func drawCShield(_ c: PixelCanvas, x: Int, y: Int, size: DCEmblemSize, letter: Px, field: Px?) {
    let rows: [String]
    switch size {
    case .small: rows = ["FCCCCCF", "CCFFFFF", ".CFFFF.", "..CCC..", "...C..."]
    case .medium: rows = ["CCCCCCC", "CCFFFFF", ".CFFFF.", ".CCCCF.", "..FFF..", "...C..."]
    case .large: rows = ["CCCCCCCCC", "CCFFFFFFF", ".CFFFFFF.", "..CCCCC..", "...FFF...", "....C...."]
    }
    var palette: [Character: Px] = ["C": letter]
    if let field { palette["F"] = field }
    c.pattern(x, y, rows, palette)
}

/// A claw mark: three parallel slashes rising to the right, `thickness` pixels wide each, centred in the
/// `width`×`height` box at (`x`, `y`).
func drawClawMark(_ c: PixelCanvas, x: Int, y: Int, width: Int, height: Int, color: Px, thickness: Int = 1) {
    let gap = thickness + 2
    let span = 2 * gap + thickness + height - 1
    let x0 = x + max(0, (width - span) / 2)
    for i in 0..<3 {
        for r in 0..<height {
            c.rect(x0 + i * gap + (height - 1 - r), y + r, thickness, 1, color)
        }
    }
}

/// The lamp emblem, its top-left at (`x`, `y`): an oil lamp's flame over its bowl in `lamp`, on a `field` disc
/// (nil: the lamp straight on the suit). `rim` rings the disc where the emblem had one.
func drawLampEmblem(_ c: PixelCanvas, x: Int, y: Int, size: DCEmblemSize, lamp: Px, field: Px?, rim: Px? = nil) {
    let rows: [String]
    switch size {
    case .small: rows = [".RRR.", "RFLFR", "RLLLR", ".RRR."]
    case .medium: rows = [".FFFF.", "FFLFFF", "FFLLFF", "FLLLLF", ".FFFF."]
    case .large: rows = ["...L...", "..LLL..", "..LLL..", "...L...", ".LLLLL.", "..LLL.."]
    }
    var palette: [Character: Px] = ["L": lamp]
    if let field { palette["F"] = field }
    palette["R"] = rim ?? field
    c.pattern(x, y, rows, palette)
}

/// The flame emblem, its top-left at (`x`, `y`): a small flame in `flame`, on a `field` disc where the bolt had one.
func drawFlameEmblem(_ c: PixelCanvas, x: Int, y: Int, size: DCEmblemSize, flame: Px, field: Px?) {
    let rows: [String]
    switch size {
    case .small: rows = ["..L.", ".LL.", "LLLL", ".LL."]
    case .medium: rows = [".FFFF.", "FFLFFF", "FLLLFF", ".FFFF."]
    case .large: rows = ["...L.", "..LL.", ".LLL.", ".LLLL", ".LLL.", "..L.."]
    }
    var palette: [Character: Px] = ["L": flame]
    if let field { palette["F"] = field }
    c.pattern(x, y, rows, palette)
}
