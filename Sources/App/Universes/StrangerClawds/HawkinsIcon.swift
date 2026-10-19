import Foundation

/// The menu bar icon: a sunflower on a grassy mound, two leaves on its stem, on a 28×26 canvas. Pick one shape the
/// franchise is known by (Vader's helmet, Captain America's shield, the TARDIS, a stake) and keep it bold: it's drawn
/// 19×18 points in the menu bar. `mono`: one colour, for a template image macOS tints to match the bar; leave a thin
/// gap between parts that touch (the flower's head and its stem here) so they still read as two. In colour the app adds
/// a white outline round it, so it reads on a dark menu bar.
func hawkinsMenuIcon(_ c: PixelCanvas, mono: Bool = false) {
    let rows: [String] = [
        "..........PPPP..............",
        "........PPPPPPPP............",
        ".......PPPPPPPPPP...........",
        "......PPPPCCCCPPPP..........",
        "......PPPCCCCCCPPP..........",
        ".....PPPPCCCCCCPPPP.........",
        ".....PPPPCCCCCCPPPP.........",
        "......PPPCCCCCCPPP..........",
        "......PPPPCCCCPPPP..........",
        ".......PPPPPPPPPP...........",
        "........PPPPPPPP............",
        "..........PPPP..............",
        "............................",
        "...........SS...............",
        "...........SS....LLL........",
        "...........SS..LLLLLL.......",
        "..LLLL.....SSLLLLLL.........",
        ".LLLLLLL...SS...............",
        "...LLLLLLLLSS...............",
        "...........SS...............",
        "...GGGGGGGGGGGGGGGGGG.......",
        ".GGGGGGGGGGGGGGGGGGGGGGG....",
        "GGGGGGGGGGGGGGGGGGGGGGGGGG..",
    ]
    let y0 = 2
    if mono {
        c.pattern(0, y0, rows, ["P": C(0x000000), "C": C(0x000000), "S": C(0x000000), "L": C(0x000000), "G": C(0x000000)])
        return
    }
    c.pattern(0, y0, rows, ["P": C(0xF4C430), "C": C(0x6A3E1E), "S": C(0x3E7A2E), "L": C(0x58A03A), "G": C(0x4A8A32)])
    // The petals' shade on the right, seeds in the middle, the mound lit along its top.
    for (x, y) in [(16, 5), (17, 6), (18, 7), (18, 8), (17, 9), (16, 10)] { c.px(x, y0 + y, C(0xD89E1E)) }
    for (x, y) in [(10, 4), (12, 5), (11, 7), (13, 6), (10, 8), (14, 8)] { c.px(x, y0 + y, C(0x4A2A12)) }
    c.rect(4, y0 + 20, 16, 1, C(0x6AB04A))
}
