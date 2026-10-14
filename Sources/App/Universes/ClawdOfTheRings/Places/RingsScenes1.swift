import Foundation

// Bag Endpoint and the Prancing Ponytail (stand-ins until they're drawn).
let ringsScenes1: [Location: Place] = [
    .bagEnd: Place(name: "Bag Endpoint", panel: 0x1C2A16, still: { c, g in c.rect(0, 0, c.w, g, C(0x6FA8DC)) }),
    .prancingPony: Place(name: "The Prancing Ponytail", panel: 0x221810, still: { c, g in c.rect(0, 0, c.w, g, C(0x4A3020)) }),
]
