import Foundation

/// Every Star Wars place.
let starWarsPlaces: [Location: Place] = [
    .cantina: Place(name: "Mos Eisley Cantina", panel: 0x2B2119, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .deathStar: Place(name: "Death Star", panel: 0x16181D, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .sarlaccPit: Place(name: "Great Pit of Carkoon", panel: 0x2E2418, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .jabbasPalace: Place(name: "Jabba's Palace", panel: 0x241A12, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .supremacy: Place(name: "Supremacy Throne Room", panel: 0x2A0A0D, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .theed: Place(name: "Theed Generator Complex", panel: 0x141A22, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .emperorThrone: Place(name: "Death Star II Throne Room", panel: 0x16181D, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .geonosis: Place(name: "Geonosis", panel: 0x2E1712, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .naboo: Place(name: "Plains of Naboo", panel: 0x14231A, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .executor: Place(name: "Executor Bridge", panel: 0x16181D, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .larsFarm: Place(name: "Lars Homestead", panel: 0x2E2418, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .obiWanHut: Place(name: "Obi-Wan's Hut", panel: 0x2B2119, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .sandcrawler: Place(name: "Jawa Sandcrawler", panel: 0x261A12, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .dagobah: Place(name: "Dagobah", panel: 0x111C15, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .falcon: Place(name: "Millennium Falcon", panel: 0x1E1F21, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .tantive: Place(name: "Tantive IV", panel: 0x1C2229, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .tuskenDesert: Place(name: "Jundland Wastes", panel: 0x2E2418, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .jakku: Place(name: "Jakku", panel: 0x2E2418, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .jediCouncil: Place(name: "Jedi Council Chamber", panel: 0x22180F, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .endor: Place(name: "Forest Moon of Endor", panel: 0x15200F, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .hoth: Place(name: "Battle of Hoth", panel: 0x1C2430, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
    .rancorPit: Place(name: "Rancor Pit", panel: 0x1A140F, still: { c, g in c.gradient(0, g, C(0x2A3A5A), C(0x6A7A9A)); c.ground(g, C(0x3A3E4A), edge: C(0x5A5E6A), speck: C(0x000000, 0.15)) }),
]
