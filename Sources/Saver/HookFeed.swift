import Foundation

extension SaverFeed {
    /// With Clawd Clash closed: the crew straight from what the hooks keep writing (`~/.claude/clawd-clash/state.json`),
    /// so the saver still shows the sessions that are running. Rougher than the app's feed: the saver's sandbox can't
    /// scan processes, so sessions without hooks don't show, and one that died without saying goodbye stays until its
    /// state times out. No events either (the app makes those). Nil when no session is running.
    /// `last` is the app's last feed, for the place and the projects' colours.
    static func fromHooks(now: Double, last: SaverFeed?) -> SaverFeed? {
        guard let file = StatusStore.load() else { return nil }
        let accents = Dictionary((last?.sessions ?? []).compactMap { s in s.accent.map { (s.project, $0) } },
                                 uniquingKeysWith: { a, _ in a })
        let sessions: [Session] = StatusStore.snapshot(file, now: now).filter { $0.id != "home" }.map { s in
            // How long it's held this mood, and what that makes it, as the app judges it.
            let since = s.record.flatMap { $0.state == s.mood.rawValue ? $0.since : nil } ?? s.record?.updated ?? now
            let held = now - since
            let resting = s.mood == .idle && s.record != nil
            // Urgent after 60 s, asleep after 300, sitting after 120: the same thresholds as the app's; keep them in step.
            return Session(
                id: s.id, cast: s.leader, assistant: s.group, project: s.project, accent: accents[s.project],
                mood: s.mood.rawValue, urgent: s.mood == .waiting && held > 60, asleep: resting && held > 300,
                sitting: resting && held > 120, unknown: false, focused: nil, since: since,
                activity: s.mood == .background ? s.record?.background?.first.map { "Waiting on: " + $0 }
                    : s.mood == .idle ? nil : s.record?.activity, prompt: s.record?.prompt,
                agents: s.agents.map { Agent(id: $0.id, cast: $0.cast ?? StatusStore.heroBase + $0.character, task: $0.label.isEmpty ? "Agent" : $0.label) })
        }
        guard !sessions.isEmpty else { return nil }
        let universe = file.shownUniverse
        return SaverFeed(at: now, location: last?.location ?? Location.all(in: universe)[0].rawValue, sessions: sessions, events: [],
                         universe: universe.rawValue, mixed: file.mixed, removed: file.removed)
    }
}
