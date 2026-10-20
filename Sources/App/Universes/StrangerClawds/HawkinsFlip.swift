import Foundation

// The Upside Down, literally: now and then, on arriving at the Upside Down, the whole scene slowly turns over on its
// horizontal axis, in about a second and a half, until the place and everyone in it are upside down: the crew walking
// on the ceiling, the vines hanging upwards, the spores falling up and the Mind Flayer's storm cloud underneath. Half a
// minute to a minute later (or as soon as the crew moves on) it turns back the same way. About one arrival in ten;
// only in the window and the screen saver, where the place fills the frame, never on the desktop. Names and speech
// stay upright, and clicks land on whoever is under the mouse.
//
// The engine does the turning (`SceneFlip`, `SceneFlipClock`, `SceneTurn`); this says where, how often and for how
// long. Kept quiet in everything public: it's a surprise for people to find. To see it while working on it: Preview's
// `place … --flipped` and `edges … --flipped`, `--scene-flip` on a test run (every arrival there turns over), and the
// Playground's hidden ⌥ item.

/// The Upside Down turning over: one arrival in ten, a 1.5-second half-turn, 30 to 60 seconds upside down.
let hawkinsSceneFlip = SceneFlip(places: [.hawkinsUpsideDown], chance: 0.1, turn: 1.5, stay: 30...60)
