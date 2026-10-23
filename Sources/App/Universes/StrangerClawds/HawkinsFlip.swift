import Foundation

// The Upside Down, literally: now and then, while the Upside Down is on show, the whole scene slowly turns over on its
// horizontal axis, in about a second and a half, until the place and everyone in it are upside down: the crew walking
// on the ceiling, the vines hanging upwards, the spores falling up and the Mind Flayer's storm cloud underneath. A
// little while later (or as soon as the crew moves on) it turns back the same way. Semi-rare, never twice in a row
// (`hawkinsUpsideDownTurn` has the odds); only in the window and the screen saver, where the place fills the frame,
// never on the desktop. Names and speech stay upright, and clicks land on whoever is under the mouse.
//
// The engine does the turning (`SceneFlip`, `SceneFlipClock`, `SceneTurn`); this says where, how often and for how
// long. Kept quiet in everything public: it's a surprise for people to find. To see it while working on it: Preview's
// `place … --flipped` and `edges … --flipped`, `--scene-flip` on a test run (every try there turns over), and the
// Playground's hidden ⌥ item.

/// How often the Upside Down turns over, and for how long: the one place to tune it. The owner asked for "once in a
/// while only, semi rare": something you notice now and then while the Upside Down is on show, not an easter egg
/// you'd never see, and never twice in a row.
///  - `chance` 0.35 a try, a try a few seconds after arriving and then every 15 minutes while it stays on show: about
///    four chances an hour, so roughly one or two turns an hour of the Upside Down on show;
///  - `stay` 20 to 40 seconds upside down each time, with a 1.5-second half-turn each way (`turn`);
///  - `rest` 10 minutes after it's back the right way up before it can turn again.
/// The Playground's hidden ⌥ item still starts it at once, and `--scene-flip` makes every try a hit.
let hawkinsUpsideDownTurn = SceneFlip(places: [.hawkinsUpsideDown], chance: 0.35, every: 15 * 60, rest: 10 * 60,
                                      turn: 1.5, stay: 20...40)
