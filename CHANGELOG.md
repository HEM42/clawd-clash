# Changelog

Clawd Clash brings Clawd Wars (Star Wars) and Avengers: Clawd Wars (Marvel) together in one app. Their history before that is in [CHANGELOG-clawd-wars.md](CHANGELOG-clawd-wars.md) (up to 2.28.3) and [CHANGELOG-avengers-clawd-wars.md](CHANGELOG-avengers-clawd-wars.md) (0.1.0).

## 3.0.0 (unreleased)

### Added
- **Two universes, one app.** Pick **Star Wars** or **Marvel** from the new **Universe** menu. A scene only ever shows one universe: switching recasts everyone (each character becomes the one in the same place on the same side of the other cast), moves the scene to one of the new universe's places, changes the menu bar icon (Vader's helmet or Captain America's shield) and the Status Symbols character, and new sessions and agents are cast from it. Star Wars brings Clawd Wars' 81 characters and 22 places; Marvel brings 193 characters and 43 places.
- **The screen saver chooses its own universe**: its **Options…** button in System Settings offers the same universe as the app, Star Wars, Marvel, or Random (a new pick on each trip somewhere new).
- **Each universe keeps its own rules.** Star Wars: Han and Greedo face off first and Han shoots first, the Falcon picks Han up, whoever came first keeps their side when two AIs run, and Vader and Kylo never lead back to back. Marvel: arch-enemies face off first, the Quinjet and the Milano pick people up, flyers take to the air, and Claude Code plays the heroes when another AI runs.
- **Keep Characters on Top** (Settings, desktop mode): on, the crew stands above every window as before; off, it lives on the desktop itself, just above the icons and behind your windows. In window mode the same item is still Keep Window on Top.
- **A new icon**: Darth Vader's saber clashing on Captain America's shield, one from each universe.
- **A screen-saver thumbnail for both universes**: the Clawd Clash title over Luke and Vader, Captain America and Thanos, in System Settings' screen saver list (it was the Avengers one).

### Changed
- **The Star Wars cast is Clawd Wars' own, ported frame by frame.** All 81 characters were rebuilt on the shared pipeline and checked pixel by pixel against Clawd Wars' drawing code in hundreds of poses each. Star Wars also keeps Clawd Wars' gun handling: no gun raised while waiting or cheering, heroes check their guns without raising them, the flash stays at the resting muzzle, bolts run as they did, and each hero keeps its own practice rhythm (`Persona.soloFire`). The Emperor's crackle is pale blue and white again.
- **One engine for both**: every character in both universes is a `Persona` drawn through the same pose pipeline (`Pose.swift`), and each universe is a `Theme` in its own folder (`Sources/App/Universes/StarWars`, `.../Marvel`).
- **Upgrading from Clawd Wars or Avengers: Clawd Wars takes care of itself.** On launch, Clawd Clash takes over every AI the old app had connected: hooks that still run the old app's hook, and the AIs a Homebrew upgrade of the old cask disconnected. The old app, if it's still running, is quit. Clawd Clash starts in the universe of the app it replaces, and Star Wars keeps Clawd Wars' cast ids. (A copy run from `build/` doesn't take over; its banner says the AI still reports to the old app and to connect it from the menu.)
- **New identity**: `Clawd Clash.app`, `com.rodclemen.clawdclash`, the `clawd-clash-hook` binary and `~/.claude/clawd-clash`.
