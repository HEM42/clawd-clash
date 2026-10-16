import Foundation

/// Spiral Hill under a big moon, on a 28×26 canvas, for the menu bar: the pale full moon and, in silhouette across
/// its lower half, the hill curling up into its spiral. `mono`: the moon in one colour with the hill cut out of it, so
/// it reads as a hole, for a template image macOS tints.
func drawSpiralHillIcon(_ c: PixelCanvas, mono: Bool = false) {
    let hill = PixelCanvas(28, 26)
    burtonSpiralHill(hill, x: 1, base: 26, w: 25, h: 19, burtonInk)
    let (cx, cy, r) = (14.0, 12.5, 12.5)
    let moon = C(0xF4EFCF), crater = C(0xE2DAAE), rim = C(0xC8BE8C)
    for y in 0..<26 {
        for x in 0..<28 {
            let dx = Double(x) + 0.5 - cx, dy = Double(y) + 0.5 - cy
            let d = (dx * dx + dy * dy).squareRoot()
            guard d <= r else { continue }
            if mono {
                if !hill.isDrawn(x, y) { c.px(x, y, C(0x000000)) }
                continue
            }
            c.px(x, y, d > r - 1 ? rim : moon)
        }
    }
    guard !mono else { return }
    for (x, y, w) in [(8, 4, 3), (17, 3, 2), (20, 8, 2), (12, 7, 2)] { c.rect(x, y, w, 2, crater) }
    c.paste(hill)
}
