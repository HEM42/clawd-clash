import Foundation

// The One Ring, the menu bar icon (a stand-in until it's drawn).
func drawOneRingIcon(_ c: PixelCanvas, mono: Bool = false) {
    let gold = mono ? C(0x000000) : C(0xE8B33A)
    for y in 0..<26 { for x in 0..<28 {
        let dx = Double(x) - 13.5, dy = Double(y) - 12.5, r: Double = (dx * dx + dy * dy).squareRoot()
        if r >= 8 && r <= 12 { c.px(x, y, gold) }
    } }
}
