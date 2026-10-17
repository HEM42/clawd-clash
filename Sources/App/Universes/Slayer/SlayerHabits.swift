import Foundation

// Clawd Slayer's habits, the things that make the universe behave like the show rather than just look like it:
//  - Hush: while the Gentlemen are on stage nobody has a voice, and every line comes up an empty bubble (the overlay
//    asks `slayerHushes` and `slayerHushed`);
//  - the full moon: on the nights the real moon is full, Ozz and Veruka stay wolves (`slayerFullMoon`, read by their
//    own drawing code);
//  - the First Evil, now and then, outside its signature, becomes one of the Big Bads before it for a few seconds,
//    their whole self, as in "Lessons" (`slayerFirstEvilGuise`, read by its drawing code);
//  - Mayor Wilclaws wipes his hands after every duel he was in or watched (`SlayerAfterDuel`, kept by the overlay and
//    the screen saver).

// MARK: - Hush

/// Whether `who` being on stage takes everyone's voice away: the Gentlemen, as in "Hush".
func slayerHushes(_ who: Cast) -> Bool { who == .villain(SlayerVillain.gentlemen) }

/// A line with the words taken out of it: the same bubble, the same width (the font is monospaced), nothing in it.
/// No-break spaces, so the text keeps its width when it's measured.
func slayerHushed(_ line: String) -> String { String(repeating: "\u{00A0}", count: max(3, line.count)) }

// MARK: - The full moon

/// Previews and docs: force the full moon on (true) or off (false); nil follows the real sky.
var slayerMoonOverride: Bool?

/// The real moon, worked out from the date: days into the synodic month (29.53 days) since a known new moon,
/// 6 January 2000, 18:14 UTC. Good to within a day, which is all a werewolf needs.
private let slayerSynodicMonth = 29.530588853
private let slayerKnownNewMoon = 947_182_440.0   // 2000-01-06 18:14 UTC

/// How many days into its cycle the moon is at `date` (0 new, about 14.77 full).
func slayerMoonAge(_ date: Date) -> Double {
    let days = (date.timeIntervalSince1970 - slayerKnownNewMoon) / 86_400
    let age = days.truncatingRemainder(dividingBy: slayerSynodicMonth)
    return age < 0 ? age + slayerSynodicMonth : age
}

/// Whether it's a full-moon night at `date`: the moon within a day of full, and dark out (6 pm to 6 am, local time).
/// By day Ozz and Veruka are themselves, as in the show.
func slayerIsFullMoonNight(_ date: Date, calendar: Calendar = .current) -> Bool {
    guard abs(slayerMoonAge(date) - slayerSynodicMonth / 2) < 1 else { return false }
    let hour = calendar.component(.hour, from: date)
    return hour >= 18 || hour < 6
}

private var slayerMoonCache: (minute: Int, full: Bool)?

/// Is tonight a full moon, right now? Worked out once a minute (it's asked every frame Ozz or Veruka is drawn).
var slayerFullMoon: Bool {
    if let forced = slayerMoonOverride { return forced }
    let now = Date(), minute = Int(now.timeIntervalSince1970 / 60)
    if let hit = slayerMoonCache, hit.minute == minute { return hit.full }
    let full = slayerIsFullMoonNight(now)
    slayerMoonCache = (minute, full)
    return full
}

// MARK: - The First Evil's guises

/// The Big Bads the First Evil can be, whole, as in "Lessons": the Old Master, the Mayor, Glory and Adam.
let slayerFirstEvilGuises: [SlayerVillain] = [.oldMaster, .mayorWilclaws, .glorificlaws, .adamm]

/// Previews: show this guise (an index into `slayerFirstEvilGuises`) `k` 0…1 through it; nil follows the clock.
var slayerForcedGuise: (index: Int, k: Double)?

private let slayerGuisePeriod = 29.0, slayerGuiseLength = 3.6

/// Who the First Evil is being right now, if anyone, and how far through (0…1). Its own clock: about one cycle in
/// two (every 29 s) it takes a guise for 3.6 s, never during its signature (which only borrows the faces).
func slayerFirstEvilGuise(_ p: Pose) -> (who: Cast, k: Double)? {
    if let f = slayerForcedGuise {
        return (.villain(slayerFirstEvilGuises[f.index % slayerFirstEvilGuises.count]), f.k)
    }
    guard p.signature == nil, !seatedPose else { return nil }
    let lt = p.lt + 11, cycle = Int(floor(lt / slayerGuisePeriod))
    let e = lt - Double(cycle) * slayerGuisePeriod
    guard e < slayerGuiseLength, noise(cycle * 17 + 5) < 0.55 else { return nil }
    let pick = min(slayerFirstEvilGuises.count - 1, Int(noise(cycle * 29 + 3) * Double(slayerFirstEvilGuises.count)))
    return (.villain(slayerFirstEvilGuises[pick]), e / slayerGuiseLength)
}

// MARK: - The Mayor's wet wipe

/// Mayor Wilclaws wipes his hands after every duel, as fussy about germs as he is about manners. He doesn't fight
/// (he's unarmed), so it's the duels he watches, cheering: once he's no longer part of a fight and has stopped
/// walking, his signature (the packet of wet wipes) plays right through. The overlay and the screen saver each keep
/// one of these, and ask it every frame.
struct SlayerAfterDuel {
    private var fighting: Set<String> = []          // in a fight, or watching one, last time asked
    private var pending: [String: Double] = [:]     // the fight just ended (when): waiting for him to stand still
    private var wiping: [String: Double] = [:]      // wiping since

    /// Whether `who` does this at all.
    static func wipes(_ who: Cast) -> Bool { who == .villain(SlayerVillain.mayorWilclaws) }

    /// The wipe to play for `key` now, if any. `inFight`: fighting or cheering this frame; `free`: standing still on
    /// stage, not walking, leaving or sitting.
    mutating func wipe(_ key: String, _ who: Cast, inFight: Bool, free: Bool, now: Double) -> HabitPlay? {
        guard Self.wipes(who), let length = who.signatureLength else { return nil }
        if inFight {
            fighting.insert(key); pending[key] = nil; wiping[key] = nil
            return nil
        }
        if fighting.remove(key) != nil { pending[key] = now }
        if let ended = pending[key] {
            if now - ended > 20 { pending[key] = nil }          // walked about too long: the moment's gone
            else if free { pending[key] = nil; wiping[key] = now }
        }
        guard let start = wiping[key] else { return nil }
        let e = now - start
        guard e < length else { wiping[key] = nil; return nil }
        return HabitPlay(kind: .signature, e: e, length: length)
    }
}
