---
name: avengers-clawd-wars-spec
description: "Decisions for Avengers: Clawd Wars, a Marvel reskin of the user's Clawd Wars macOS app (github.com/rodclemen/clawd-wars)"
metadata:
  node_type: memory
  type: project
  originSessionId: 6dec5bb7-1a75-4576-a901-c669f11bce9a
  modified: 2026-10-12T17:23:49.771Z
---

Avengers: Clawd Wars = the sister app of Clawd Wars (user: never call it a fork; it's Clawd Wars' brother/sister) (Swift, pixel sprites drawn in code), Marvel theme. Decided 2026-10-12:
- Roster: user wants as many as possible; 2026-10-12 grew to 94 heroes + 83 villains ("I want them all!"), 32 places. Classic cartoon/comic look by default, MCU look only where it reads better on screen.
- Sides: Claude gets the heroes by default; with only Claude sessions running, heroes and villains mix.
- Combat: melee (shield, hammer, claws), ranged (repulsors, webs, arrows), magic/energy in place of Force lightning; Cap's shield deflects. Flyers fly or hover (Iron Man etc.), Spider-Man swings.
- Drop Han vs Greedo. Keep a Falcon-style pickup (Quinjet/Milano) for a few characters and the Jabba-style laugher.
- Locations: 22 first wave plus 10 more (Baxter Building, Jotunheim, Muspelheim, Hala, Genosha, Madripoor, Sokovia, Worldship, Harlem, K'un-Lun); first wave was (Avengers Tower, Sanctum, Wakanda, Asgard, Sakaar, Knowhere, Titan, Helicarrier, Xavier's, Hell's Kitchen, Vormir, Quantum Realm, Latveria, Hydra base, Daily Bugle, Ego's planet, Kamar-Taj, the Raft, NY 2012, Dark Dimension, Attilan, Savage Land).
- Separate app from Clawd Wars for now; may later merge into one app with a theme picker, so keep theme content separate from the engine.
- Free/personal distribution.

**Why:** the user wants the same app with a different universe, and may unify themes later.
**How to apply:** keep theme-specific code (characters, locations, set pieces) isolated from the engine.
