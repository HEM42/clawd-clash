import Foundation

/// Doctor Clawd, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DoctorUniverse: UniverseModule {
    var theme: Theme { doctorTheme }
    var places: [Location: Place] { doctorPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in DoctorTrip.pick(after: (last as? DoctorTrip)?.kind, cast: cast, to: to) }
    }

    var preview: PreviewInfo {
        .of(.doctor, heroes: "doctorHeroes", [doctorHeroes1, doctorHeroes2, doctorHeroes3, doctorHeroes4, doctorHeroes5, doctorHeroes6, doctorHeroes7],
            villains: "doctorVillains", [doctorVillains1, doctorVillains2, doctorVillains3, doctorVillains4, doctorVillains5])
    }
}
