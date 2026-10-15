import Foundation

/// The bike crossing the full moon, on a 28×26 canvas, for the menu bar: a big pale moon and, in silhouette across it,
/// the boy on his bike with the little alien in the basket. `mono`: the moon in one colour with the bike cut out of it,
/// so it reads as a hole, for a template image macOS tints.
func drawMoonBikeIcon(_ c: PixelCanvas, mono: Bool = false) {
    // The rider, the basket and its passenger, and the two wheels, against the lower half of the moon.
    let bike: [String] = [
        "...........HH.......",
        "..........HHHH......",
        "...........HH...EE..",
        "..........HHHH.EEEE.",
        ".........HHHHHH.EE..",
        "........HH.HHHHBBBB.",
        "........H...HH.BBB..",
        ".........H..H...H...",
        "..WWW...HHHHH..WWW..",
        ".W...W.H.H....W...W.",
        "W..H..WH..H..W..H..W",
        "W.HHH.HHHHHHHW.HHH.W",
        "W..H..W......W..H..W",
        ".W...W........W...W.",
        "..WWW..........WWW..",
    ]
    let (cx, cy, r) = (14.0, 12.5, 12.5)
    let bx = 4, by = 9
    func inBike(_ x: Int, _ y: Int) -> Bool {
        let row = y - by, col = x - bx
        guard row >= 0, row < bike.count, col >= 0, col < bike[row].count else { return false }
        return bike[row][bike[row].index(bike[row].startIndex, offsetBy: col)] != "."
    }
    let moon = C(0xF6EFC4), crater = C(0xE2D79E), rim = C(0xC8BC84)
    for y in 0..<26 {
        for x in 0..<28 {
            let dx = Double(x) + 0.5 - cx, dy = Double(y) + 0.5 - cy
            let d = (dx * dx + dy * dy).squareRoot()
            guard d <= r else { continue }
            if mono {
                if !inBike(x, y) { c.px(x, y, C(0x000000)) }
                continue
            }
            c.px(x, y, d > r - 1 ? rim : moon)
        }
    }
    guard !mono else { return }
    for (x, y, w) in [(7, 5, 3), (17, 4, 2), (20, 9, 2), (11, 2, 2)] { c.rect(x, y, w, 2, crater) }
    c.pattern(bx, by, bike, ["H": ink, "E": ink, "B": ink, "W": ink])
}
