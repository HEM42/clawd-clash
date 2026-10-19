import Foundation

/// The One Ring on a 28×26 canvas, for the menu bar: a thick gold band seen slightly tilted, lit along its top-left
/// (and on the inner wall facing the light) and shaded to the bottom-right, with a few glints of the fire-letters on
/// it. `mono`: the band in one colour with the hole and the glints left out, for a template image macOS tints, so it
/// still reads as a ring.
func ringsDrawOneRingIcon(_ c: PixelCanvas, mono: Bool = false) {
    let gold = mono ? C(0x000000) : C(0xE8B33A)
    let rows: [String] = [
        "............................",
        "............................",
        "..........HHHHHGGGGGG.......",
        "........HHHHHHHGGGGGGG......",
        "......HHHHHHGGGGGGGGGGG.....",
        ".....HHHHHGGGGGFGGGGGGGG....",
        "....HHHHGGGGSSSSSGGGGGGGS...",
        "...HHHHGGGS........GGFGGG...",
        "...HHHGGSS..........GGGGGS..",
        "..HHHGGS............GGGGGS..",
        "..HHGFGS.............GGGGS..",
        ".HHGGGS..............GGGGS..",
        ".HGGGG...............GGGSS..",
        ".GGGGG..............HGGGSS..",
        ".GGFGG.............GHGGSS...",
        ".GGGGGS............HGGGSS...",
        ".GGGGGG..........HHGGGSS....",
        "..GGGGGG........HHGGGSSS....",
        "..GGGGGGGGGGGHHHGGGGSSS.....",
        "...GGGGGFGGGGGGGGGSSSS......",
        "....GGGGGGGGGGGGSSSSS.......",
        ".....GGGGGGGGGSSSSS.........",
        "......SSSSSSSSSSS...........",
        "............................",
        "............................",
        "............................",
    ]
    // Mono: H and S are the band too, and F (the glints) stays out of the palette, so it falls out as holes.
    var palette: [Character: Px] = ["G": gold, "H": gold, "S": gold]
    if !mono { palette["H"] = C(0xFFE08A); palette["S"] = C(0xA8781E); palette["F"] = C(0xFF6A1E) }
    c.pattern(0, 0, rows, palette)
}
