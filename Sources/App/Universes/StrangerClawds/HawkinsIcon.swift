import Foundation

/// The menu bar icon: the Party's walkie-talkie, a chunky black handset with its long aerial, the grille, a red light
/// and the talk button on its side, with the signal going out from it in two red arcs, on a 28×26 canvas. `mono`: one
/// colour, for a template image macOS tints; the arcs stand clear of the handset by a pixel, so they still read as
/// apart. In colour the app adds a white outline round it, so it reads on a dark menu bar.
func hawkinsMenuIcon(_ c: PixelCanvas, mono: Bool = false) {
    let rows: [String] = [
        "....A.......................",
        "....A.......................",
        "....A.......................",
        "....A.......................",
        "....A.......................",
        "....A.......................",
        "....A.......................",
        "...AA.......................",
        "..BBBBBBBBBB................",
        "..BBBBBBBBBB................",
        "..BBGGGGGGBB................",
        "..BBBBBBBBBB................",
        "..BBGGGGGGBB................",
        "..BBBBBBBBBBT...............",
        "..BBGGGGGGBBT...............",
        "..BBBBBBBBBBT...............",
        "..BBBBBBBBBB................",
        "..BBBRBBBBBB................",
        "..BBBBBBBBBB................",
        "..BBBKKKKBBB................",
        "..BBBKKKKBBB................",
        "..BBBBBBBBBB................",
        "...BBBBBBBB.................",
    ]
    // The signal: two arcs opening up and to the right from the top of the handset, two pixels thick, kept a pixel
    // clear of the handset and its aerial.
    let y0 = 1
    func arcs(_ col: Px) {
        for r in [7.0, 8.0, 12.0, 13.0] {
            for i in 0...60 {
                let a = (-62 + Double(i) * 82 / 60) * .pi / 180
                let x = 7 + Int((cos(a) * r).rounded()), y = y0 + 11 + Int((sin(a) * r).rounded())
                if x >= 14 || (x >= 7 && y < y0 + 7) { c.px(x, y, col) }
            }
        }
    }
    if mono {
        c.pattern(0, y0, rows, ["A": C(0x000000), "B": C(0x000000), "T": C(0x000000)])
        arcs(C(0x000000))
        return
    }
    c.pattern(0, y0, rows, ["A": C(0x2A2A30), "B": C(0x34343C), "G": C(0x14141A), "T": C(0x5A5A64), "R": C(0xF0383A),
                            "K": C(0x6A6A74)])
    arcs(C(0xF04A4A))
    // The handset lit down its left edge and along the top, shaded down its right; the aerial's knob.
    c.rect(2, y0 + 8, 1, 14, C(0x5A5A66)); c.rect(2, y0 + 8, 10, 1, C(0x5A5A66)); c.rect(11, y0 + 9, 1, 13, C(0x1E1E24))
    c.px(4, y0, C(0x6A6A74))
}
