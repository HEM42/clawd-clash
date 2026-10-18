import CoreGraphics

/// One universe, as the app sees it: everything the engine asks a universe for. Each universe's folder has exactly one
/// type conforming to this, in its `<Prefix>Universe.swift`. Members without a default must be written; the rest have
/// sensible defaults. (Its plain numbers, which the hook needs too, are its `UniverseFacts`.)
protocol UniverseModule {
    /// The cast, the places in order, who lives where, arch-enemies, rides, the menu icon and the legend.
    var theme: Theme { get }
    /// Every place's drawing, by key. Keys are unique across universes.
    var places: [Location: Place] { get }
    /// Its trips between places; nil: plain edge and clock wipes (`Wipe`), as Star Clawds keeps.
    var transitions: TransitionSet? { get }
}

extension UniverseModule {
    var transitions: TransitionSet? { nil }
}

extension Universe {
    /// The universe's module. Hand-listed for now; the universe-modules refactor generates this list from the folders.
    var module: UniverseModule {
        switch self {
        case .starWars: return StarClawdsUniverse()
        case .marvel: return MarvelousUniverse()
        case .dc: return DetectiveUniverse()
        case .doctor: return DoctorUniverse()
        case .clawdFiles: return FilesUniverse()
        case .clawdberg: return ClawdbergUniverse()
        case .middleEarth: return RingsUniverse()
        case .slayer: return SlayerUniverse()
        }
    }
}

/// One trip between two places: Marvel's comic panels, the TARDIS's vortex, The Clawd Files' black oil…
protocol Trip {
    var duration: Double { get }
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect)
    /// How much of the crew shows at `k` (0…1): 1 while the trip stays on the ground, less while it leaves it (the
    /// Great Eagle's open sky), so nobody is left standing on thin air.
    func crewShown(_ k: Double) -> Double
}

extension Trip {
    func crewShown(_ k: Double) -> Double { 1 }
}

/// A universe's trips.
struct TransitionSet {
    /// The trip to `to`, coming `from` (if known). `last` is the previous trip if it was this universe's, so it can pick
    /// a different kind.
    let pick: (_ last: Trip?, _ cast: [Cast], _ from: Location?, _ to: Location) -> Trip
}
