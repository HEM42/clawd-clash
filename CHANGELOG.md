# Changelog

Avengers: Clawd Wars is a fork of [Clawd Wars](https://github.com/rodclemen/clawd-wars) 2.28.1. Its history up to the fork is in [CHANGELOG-clawd-wars.md](CHANGELOG-clawd-wars.md).

## 0.1.0 — unreleased

### Changed
- **New name and identity: Avengers: Clawd Wars.** It installs as `Avengers Clawd Wars.app` (bundle ID `com.rodclemen.avengersclawdwars`) and can sit on the same Mac as Clawd Wars. Its hook binary is `avengers-hook`, and each app only adds, replaces or removes hook entries whose command contains its own binary name, so the two never strip each other's hooks from `~/.claude/settings.json` or the other AIs' settings. Session state lives in `~/.claude/avengers-status`, the screen-saver feed in `~/Library/Application Support/Avengers Clawd Wars`, and the Copilot hook file is `~/.copilot/hooks/avengers-clawd-wars.json`. The cast and locations are still Star Wars for now.

### Added
- **The Marvel cast: 46 heroes and 46 villains** (`Sources/App/Roster.swift`, art in `Sources/App/Art/`). Avengers, Guardians of the Galaxy, X-Men, the Fantastic Four and street-level heroes against Thanos, Loki, Ultron, Doom, Magneto, Spider-Man's rogues, Hydra and more. The Ultron Sentry and the Doombot only ever turn up as agents. Their art is a plain coloured stand-in for now.
- **Fighting styles.** Melee fighters (shields, hammers, claws, fists, blades) duel and knock shots aside; ranged fighters each have their own kind of shot: repulsor and photon blasts, Cyclops' and the Sentinels' beams, Spider-Man's webs, Hawkeye's arrows, bullets, the Human Torch's fireballs, Iceman's ice, Gambit's charged cards, Bullseye's knives and the Goblin's pumpkin bombs. Magic users stream forked lightning or a steady ray in their own colours: Doctor Strange orange, Scarlet Witch red, Loki green, Thanos purple, Storm white.
- **Flight.** Iron Man, Thor, Captain Marvel, Vision, Storm and the other flyers take off when they move along the line and land where they're going, and fly up and away when their agent is done. Doctor Strange, Magneto, MODOK and other hoverers float a few pixels off the ground. Spider-Man swings in arcs on a web line.
- **Arch-enemies face off first**: Captain America and Red Skull, Thor and Loki, Spider-Man and the Green Goblin or Venom, Wolverine and Sabretooth, Black Panther and Killmonger and more are paired with each other whenever both are fighting, in the overlay and the screen saver. This replaces Han and Greedo.
- **Ships pick people up.** When Captain America, Black Widow, Hawkeye, Nick Fury or the Hulk finish, the Quinjet lands for them; the Guardians get the Milano. This replaces the Millennium Falcon.
- **22 Marvel locations** as places for the window and the screen saver, from Avengers Tower to the Savage Land (`Sources/App/Places/`). Stand-in skies for now.
- **`Tools/Preview`**: contact sheets of every character in every pose, of two characters fighting, of the locations at window and screen-saver size, and of the ships.

### Changed
- **Claude Code plays the heroes.** When another AI (Codex, Qwen, Gemini, Copilot) is running, Claude Code's sessions and agents are heroes and the other AI's are villains; with only Claude running, anyone can turn up.
- **One drawing pipeline for everyone** (`Sources/App/Pose.swift`): heroes and villains now share the same moods, fight poses, idle habits and sitting rules, and each character is a `Persona` with its drawing function, so adding one is one entry in an art file.
- **The menu bar icon is Captain America's shield**, in colour or monochrome.

### Removed
- The Star Wars cast, locations, Han shooting first and the cantina band.
