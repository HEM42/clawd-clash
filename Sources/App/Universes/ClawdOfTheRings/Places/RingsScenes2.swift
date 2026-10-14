import Foundation

// The Mines of Mori-ah and Mount Doomscroll (stand-ins until they're drawn).
let ringsScenes2: [Location: Place] = [
    .moria: Place(name: "The Mines of Mori-ah", panel: 0x101216, still: { c, g in c.rect(0, 0, c.w, g, C(0x14161C)) }),
    .mountDoom: Place(name: "Mount Doomscroll", panel: 0x1E0E0A, still: { c, g in c.rect(0, 0, c.w, g, C(0x3A1A12)) }),
]
