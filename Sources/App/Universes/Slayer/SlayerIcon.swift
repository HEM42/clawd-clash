import Foundation

/// A wooden stake standing point up in front of a rounded gravestone, a crescent moon behind, on a 28×26 canvas, for
/// the menu bar. `mono`: one colour, the stake split off the stone by a thin gap so both still read, for a template
/// image macOS tints.
func drawStakeIcon(_ c: PixelCanvas, mono: Bool = false) {
    let rows: [String] = [
        "...................MMM......",
        ".................MMMM.......",
        "................MMMM........",
        "................MMM.........",
        "................MMM.........",
        "......SSSSSS....MMMM........",
        "....SSSSSSSSSS...MMMM.......",
        "...SSSSSSSSSSSS...MMMMM.....",
        "..SSSSSSSSSSSSSS............",
        "..SSSSSSSS.W.SSS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        "..SSSSSSS.WWW.SS............",
        ".GGGGGGGG.WWW.GGGG..........",
        "GGGGGGGGG.WWW.GGGGGG........",
        "GGGGGGGGGGGGGGGGGGGGG.......",
    ]
    let y0 = 2
    if mono {
        c.pattern(0, y0, rows, ["S": C(0x000000), "W": C(0x000000), "M": C(0x000000), "G": C(0x000000)])
        return
    }
    c.pattern(0, y0, rows, ["S": C(0x9A9EA8), "W": C(0xD2A468), "M": C(0xF4EFC8), "G": C(0x3E5A3A)])
    // The stone's shading and a cross carved in it; the grain down the stake and its pale point.
    for y in (y0 + 8)...(y0 + 20) { c.px(15, y, C(0x6E727C)) }
    c.pattern(4, y0 + 10, [".C.", "CCC", ".C.", ".C."], ["C": C(0x6E727C)])
    for y in (y0 + 10)...(y0 + 22) { c.px(12, y, C(0x8E6234)) }
    c.px(11, y0 + 9, C(0xF0D8A8))
}
