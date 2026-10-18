import Foundation

// Clawd of the Rings's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum RingsVillain: Int, CaseIterable {
    case sauron, saruman, witchKing, nazgul, balrog, gollum, uruk, orc, shelob
    case wormtongue, lurtz, gothmog, mouthOfSauron, watcher, oliphaunt, barrowWight, warg
    case denethor, ugluk, grishnakh, shagrat, ologHai, caveTroll, kingOfTheDead, corsair, haradrim, easterling, oldManWillow
    case lotho, billFerny, sharkey, necromancer, smaug, azog, bolg, goblinKing, mirkwoodSpider, masterOfLaketown

}

enum RingsHero: Int, CaseIterable {
    case gandalf, frodo, sam, pippin, aragorn, legolas, gimli, boromir, galadriel
    case merry, bilbo, elrond, arwen, theoden, faramir, treebeard, bombadil, gandalfWhite, eowyn
    case radagast, glorfindel, haldir, celeborn, eomer, butterbur, rosie, farmerMaggot, quickbeam, strider
    case thorin, balin, kili, fili, gloin, bard, beorn, thranduil
    case hem   // always last (`Universe.hem`)

}

extension Universe {
    /// Clawd of the Rings: number 6, for good (its ids are 6000 and up).
    static let middleEarth = Universe(number: 6)
}

enum RingsFacts {
    static let entry = UniverseEntry(universe: .middleEarth, key: "middleEarth", title: "Clawd of the Rings", facts: facts)
    static let facts = UniverseFacts(
        villainCount: RingsVillain.allCases.count, heroCount: RingsHero.allCases.count,
        // Gandclawd the Grey and the White, Arrogorn and Stride-r, Sarumanual and Sharkey, Sourun and the Necro-maintainer.
        guises: [[UniverseFacts.heroBase, UniverseFacts.heroBase + 17], [UniverseFacts.heroBase + 4, UniverseFacts.heroBase + 28], [1, 30], [0, 31]],
        // Smaug the Stashed, only ever on his hoard in the Lonely Mount-point.
        homebound: [32: "erebor"]
    )
}
