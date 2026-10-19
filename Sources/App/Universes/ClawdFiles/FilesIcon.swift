import Foundation

/// A flying saucer on a 28×26 canvas, for the menu bar: the dome on top, the rim with its lights, and the beam it
/// throws down. `mono`: one colour with the lights and the dome's window left out, so they read as holes in it, and the
/// beam as a few bars, for a template image macOS tints.
func filesDrawSaucerIcon(_ c: PixelCanvas, mono: Bool = false) {
    let rows: [String] = [
        "............................",
        "...........DDDDDD...........",
        ".........DDDWWWWDDD.........",
        "........DDDDWWWWDDDD........",
        "....HHHHHHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHHHHHHHH..",
        ".HHLHHHLHHHLHHHHLHHHLHHHLHH.",
        "..hhhhhhhhhhhhhhhhhhhhhhhh..",
        "....hhhhhhhhhhhhhhhhhhhh....",
        "...........bbbbbb...........",
        "..........bbbbbbbb..........",
        ".........bbbbbbbbbb.........",
        "........bbbbbbbbbbbb........",
        ".......bbbbbbbbbbbbbb.......",
        "......bbbbbbbbbbbbbbbb......",
        ".....bbbbbbbbbbbbbbbbbb.....",
        "....bbbbbbbbbbbbbbbbbbbb....",
        "...bbbbbbbbbbbbbbbbbbbbbb...",
    ]
    if mono {
        let k = C(0x000000)
        c.pattern(0, 2, Array(rows.prefix(9)), ["D": k, "H": k, "h": k])
        for (i, y) in [12, 15, 18].enumerated() { c.rect(9 - i * 2, y, 10 + i * 4, 1, k) }   // the beam, in bars
        return
    }
    c.pattern(0, 2, rows, ["D": C(0x9AA8B0), "W": C(0xC8F4E0), "H": C(0xC4CCD2), "h": C(0x6E7880),
                           "L": C(0x8AFFB4), "b": C(0xB8FFD8, 0.35)])
}
