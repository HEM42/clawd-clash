import Foundation

// Doctor Clawd's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum DoctorHero: Int, CaseIterable {
    // The Doctors
    case doctorTen
    case doctorOne, doctorTwo, doctorThree, doctorFour, doctorFive, doctorSix, doctorSeven, doctorEight, doctorNine
    case doctorEleven, doctorTwelve, doctorThirteen, doctorFourteen, doctorFifteen
    case warDoctor, fugitiveDoctor
    // Companions and allies
    case susan, ian, barbara, jamie, zoe, brigadier, jo, sarahJane, leelah, kCanine
    case romanah, nyssa, tegan, pery, mel, ace
    case rose, jack, martha, donna, wilf
    case amy, rory, river, clara, vasta, jenny, stracks
    case bill, nardoll, yaz, graham, ryan, dan
    case ruby, belinda, kate, osgoode
    case hem   // always last (`Universe.hem`)


    /// The Doctors themselves (the sonic screwdriver's owners, and who a regeneration moves between), in order.
    static let doctors: [DoctorHero] = [.doctorOne, .doctorTwo, .doctorThree, .doctorFour, .doctorFive, .doctorSix,
                                        .doctorSeven, .doctorEight, .doctorNine, .doctorTen, .doctorEleven,
                                        .doctorTwelve, .doctorThirteen, .doctorFourteen, .doctorFifteen]
    var isDoctor: Bool { DoctorHero.doctors.contains(self) || self == .warDoctor || self == .fugitiveDoctor }
}

enum DoctorVillain: Int, CaseIterable {
    case dalick
    // Time Lords and named villains
    case master, burntMaster, velvetMaster, snakeskinMaster, sexton, missy, spyMaster
    case davross, ranee, omegah, rascilon, toyfaker, sootekh, grateIntelligence, valeyarn
    // The monsters
    case supremeDalick, dalickEmperor, mondasianCyberperson, cyberperson, cyberController, sontaron
    case weepingAngle, silents, odd, zygone, silurean, seaDevvil, iceWarior, autom, judoom, slitheem, sycorex
    case vashtaNerado, emptyKid, clockworkDroid, candyman, cassandro, maestro
    // Agent-only small fry
    case adipoze, cybermite, toclafayne


    var isDalick: Bool { [.dalick, .supremeDalick, .dalickEmperor].contains(self) }
}

extension Universe {
    /// Doctor Clawd: number 3, for good (its ids are 3000 and up).
    static let doctor = Universe(number: 3)
}

enum DoctorFacts {
    static let entry = UniverseEntry(universe: .doctor, key: "doctor", title: "Doctor Clawd", facts: facts)
    static let facts = UniverseFacts(
        villainCount: DoctorVillain.allCases.count, heroCount: DoctorHero.allCases.count,
        agentOnly: [39, 40, 41],             // Adipoze, Cybermite, Toclafayne
        // The Doctors in order (One … Fifteen): a compacted Doctor regenerates into the next.
        compaction: .regenerate(order: [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 10, 11, 12, 13, 14].map { StatusStore.heroBase + $0 })
    )
}
