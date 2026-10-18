import Foundation

/// Doctor Clawd, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DoctorUniverse: UniverseModule {
    var theme: Theme { doctorTheme }
    var places: [Location: Place] { doctorPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in DoctorTrip.pick(after: (last as? DoctorTrip)?.kind, cast: cast, to: to) }
    }
}
