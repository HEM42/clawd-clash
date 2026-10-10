import Foundation

// Shared state between the Claude Code hook binary (writer) and the overlay app (reader).
// Lives at ~/.claude/vader-status/state.json.

struct SessionRecord: Codable {
    var state: String      // idle | thinking | working | waiting
    var updated: Double
    var leader: Int?       // which dark-side Clawd represents this session (0 = Vader)
    var project: String?   // last path component of the session's cwd
    var lastTool: Double?  // last PreToolUse, so brief "thinking" gaps between tools still read as working
    var pid: Int32?        // the claude process, so the session disappears as soon as it exits
    var created: Double?   // when the session first appeared, for spawn order
}

struct AgentRecord: Codable {
    var id: String
    var session: String
    var type: String
    var character: Int     // index into Companion
    var started: Double
    var lastSeen: Double
    var task: String?      // the Agent tool's short description, e.g. "Find hook events"
}

/// An Agent tool call seen in PreToolUse, waiting for its SubagentStart (which only carries the type).
struct PendingAgent: Codable {
    var session: String
    var type: String
    var task: String
    var at: Double
}

struct StatusFile: Codable {
    var sessions: [String: SessionRecord] = [:]
    var agents: [AgentRecord] = []
    var pending: [PendingAgent]? = []
}

enum Mood: String {
    case idle, thinking, working, waiting
}

/// One Claude Code session as the overlay should draw it.
struct SessionSnapshot {
    let id: String
    let leader: Int
    let project: String
    var mood: Mood
    var agents: [AgentRecord]
    var live = true        // false = found in the process table but its hooks never fired
    var pid: Int32?        // the claude process, for jumping to its terminal
}

enum StatusPaths {
    static let dir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/vader-status", isDirectory: true)
    static let state = dir.appendingPathComponent("state.json")
    static let lock = dir.appendingPathComponent("state.lock")
}

enum StatusStore {
    static let companionCount = 13
    static let leaderCount = 11

    // Stale timeouts: Stop never fires when the user hits Esc, so states must decay on their own.
    static let thinkingTTL: Double = 10 * 60
    static let workingTTL: Double = 30 * 60
    static let waitingTTL: Double = 15 * 60
    static let agentTTL: Double = 20 * 60
    static let sessionTTL: Double = 3 * 60 * 60
    /// A "thinking" this soon after a tool call is just the gap between tools.
    static let toolGrace: Double = 3

    static func load() -> StatusFile? {
        guard let data = try? Data(contentsOf: StatusPaths.state) else { return nil }
        return try? JSONDecoder().decode(StatusFile.self, from: data)
    }

    static func withLock(_ body: (inout StatusFile) -> Void) {
        try? FileManager.default.createDirectory(at: StatusPaths.dir, withIntermediateDirectories: true)
        let fd = open(StatusPaths.lock.path, O_CREAT | O_RDWR, 0o644)
        if fd >= 0 { flock(fd, LOCK_EX) }
        defer { if fd >= 0 { flock(fd, LOCK_UN); close(fd) } }
        var status = load() ?? StatusFile()
        body(&status)
        if let data = try? JSONEncoder().encode(status) {
            try? data.write(to: StatusPaths.state, options: .atomic)
        }
    }

    /// Apply one Claude Code hook event (the JSON Claude Code pipes to the hook on stdin).
    static func apply(event json: [String: Any], now: Double = Date().timeIntervalSince1970) {
        let event = json["hook_event_name"] as? String ?? ""
        let session = json["session_id"] as? String ?? "default"
        let agentId = json["agent_id"] as? String
        let project = (json["cwd"] as? String).map { URL(fileURLWithPath: $0).lastPathComponent }
        let owner = agentId == nil ? ClaudeProcesses.hookOwner() : nil

        withLock { s in
            prune(&s, now: now)
            if event != "SessionEnd" {
                if s.sessions[session] == nil {
                    var rec = SessionRecord(state: "idle", updated: now, leader: nextLeader(s.sessions), project: project)
                    rec.created = now
                    s.sessions[session] = rec
                }
                if s.sessions[session]?.leader == nil {
                    let leader = nextLeader(s.sessions)
                    s.sessions[session]?.leader = leader
                }
                if let project, agentId == nil { s.sessions[session]?.project = project }
                if let owner { s.sessions[session]?.pid = owner }
            }
            func set(_ state: String) {
                s.sessions[session]?.state = state
                s.sessions[session]?.updated = now
            }
            func touchAgent(_ id: String) {
                if let i = s.agents.firstIndex(where: { $0.id == id }) { s.agents[i].lastSeen = now }
            }

            switch event {
            case "SessionStart":
                set("idle")
            case "UserPromptSubmit":
                set("thinking")
            case "PreToolUse":
                if let a = agentId { touchAgent(a) } else {
                    set("working")
                    s.sessions[session]?.lastTool = now
                    // Remember the task of each agent Claude launches; SubagentStart picks it up.
                    let tool = json["tool_name"] as? String ?? ""
                    if tool == "Agent" || tool == "Task", let input = json["tool_input"] as? [String: Any],
                       let task = (input["description"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !task.isEmpty {
                        s.pending = (s.pending ?? []) + [PendingAgent(session: session,
                            type: input["subagent_type"] as? String ?? "general-purpose", task: task, at: now)]
                    }
                }
            case "PostToolUse", "PostToolUseFailure":
                if let a = agentId { touchAgent(a) } else {
                    set("thinking")
                    s.sessions[session]?.lastTool = now
                }
            case "PermissionRequest":
                if agentId == nil { set("waiting") }
            case "Notification":
                let type = json["notification_type"] as? String ?? ""
                let message = (json["message"] as? String ?? "").lowercased()
                if type == "permission_prompt" || message.contains("permission") { set("waiting") }
            case "Stop", "StopFailure":
                set("idle")
                s.sessions[session]?.lastTool = nil
            case "SubagentStart":
                let id = agentId ?? UUID().uuidString
                if !s.agents.contains(where: { $0.id == id }) {
                    let type = json["agent_type"] as? String ?? "agent"
                    // Oldest queued launch of this type in this session (any type as a fallback).
                    var pending = s.pending ?? []
                    let match = pending.firstIndex { $0.session == session && $0.type == type }
                        ?? pending.firstIndex { $0.session == session }
                    let task = match.map { pending.remove(at: $0).task }
                    s.pending = pending
                    s.agents.append(AgentRecord(
                        id: id, session: session, type: type,
                        character: nextCharacter(s.agents),
                        started: now, lastSeen: now, task: task))
                }
            case "SubagentStop":
                if let a = agentId {
                    s.agents.removeAll { $0.id == a }
                } else if let i = s.agents.lastIndex(where: { $0.session == session }) {
                    s.agents.remove(at: i)
                }
            case "SessionEnd":
                s.sessions[session] = nil
                s.agents.removeAll { $0.session == session }
            default:
                break
            }
        }
    }

    /// A random hero not already on screen (repeats only once all of them are out).
    static func nextCharacter(_ agents: [AgentRecord]) -> Int {
        let used = Set(agents.map(\.character))
        return (0..<companionCount).filter { !used.contains($0) }.randomElement() ?? Int.random(in: 0..<companionCount)
    }

    /// Villain for a new session: a random free villain, except that Vader and Kylo
    /// never spawn one right after the other.
    static func nextLeader(_ sessions: [String: SessionRecord]) -> Int {
        let used = Set(sessions.values.compactMap(\.leader))
        let latest = sessions.values.filter { $0.leader != nil }.max { ($0.created ?? $0.updated) < ($1.created ?? $1.updated) }
        return pickLeader(used: used, previous: latest?.leader)
    }

    /// `seed` makes the choice deterministic (for sessions found by the process scan, re-evaluated every refresh).
    static func pickLeader(used: Set<Int>, previous: Int?, seed: UInt64? = nil) -> Int {
        var free = (0..<leaderCount).filter { !used.contains($0) }
        if free.isEmpty { free = Array(0..<leaderCount) }   // more sessions than villains: repeats are fine
        let rivals: Set<Int> = [0, 1]                        // Vader, Kylo
        if let p = previous, rivals.contains(p) {
            let spaced = free.filter { !rivals.contains($0) || $0 == p }
            if !spaced.isEmpty { free = spaced }
        }
        if let seed { return free[Int(seed % UInt64(free.count))] }
        return free.randomElement()!
    }

    static func prune(_ s: inout StatusFile, now: Double) {
        s.agents.removeAll { now - $0.lastSeen > agentTTL }
        s.sessions = s.sessions.filter { now - $0.value.updated < sessionTTL && isAlive($0.value.pid) }
        let sessions = Set(s.sessions.keys)
        s.agents.removeAll { !sessions.contains($0.session) && now - $0.started > 60 }
        s.pending = (s.pending ?? []).filter { now - $0.at < 120 && sessions.contains($0.session) }
    }

    static func isAlive(_ pid: Int32?) -> Bool {
        guard let pid else { return true }
        return kill(pid, 0) == 0 || errno != ESRCH
    }

    /// Drop idle sessions with no agents (e.g. terminals closed without a clean exit). They return on their next event.
    static func forgetIdleSessions() {
        withLock { s in
            let busy = Set(s.agents.map(\.session))
            s.sessions = s.sessions.filter { $0.value.state != "idle" || busy.contains($0.key) }
        }
    }

    static func mood(_ rec: SessionRecord, now: Double) -> Mood {
        let age = now - rec.updated
        let m = Mood(rawValue: rec.state) ?? .idle
        switch m {
        case .thinking where age > thinkingTTL, .working where age > workingTTL, .waiting where age > waitingTTL:
            return .idle
        case .thinking where now - (rec.lastTool ?? 0) < toolGrace:
            return .working
        default:
            return m
        }
    }

    /// Every live session in spawn order (an idle Vader placeholder if there are none).
    /// `processes` (from `ClaudeProcesses.running()`) adds sessions whose hooks never fired and drops dead ones.
    static func snapshot(_ s: StatusFile, now: Double = Date().timeIntervalSince1970,
                         processes: [ClaudeProcesses.Info]? = nil) -> [SessionSnapshot] {
        var live = s.sessions.filter { now - $0.value.updated < sessionTTL && isAlive($0.value.pid) }
        if let processes {
            let running = Set(processes.map(\.pid))
            live = live.filter { $0.value.pid.map { running.contains($0) } ?? true }
        }
        var used = Set(live.values.compactMap(\.leader))
        var result: [SessionSnapshot] = []
        var previous: Int?
        // Spawn order, so "who came after whom" is meaningful.
        for (id, rec) in live.sorted(by: { ($0.value.created ?? $0.value.updated) < ($1.value.created ?? $1.value.updated) }) {
            var leader = rec.leader ?? -1
            if leader < 0 {   // records written before leaders existed
                leader = pickLeader(used: used, previous: previous, seed: UInt64(abs(id.hashValue)))
                used.insert(leader)
            }
            previous = leader
            result.append(SessionSnapshot(id: id, leader: leader, project: rec.project ?? "",
                                          mood: mood(rec, now: now), agents: [], pid: rec.pid))
        }
        if let processes {
            // Records from before pids were tracked are matched to a process by project folder.
            var claimed = Set(live.values.compactMap(\.pid))
            for rec in live.values where rec.pid == nil {
                if let p = processes.first(where: { !claimed.contains($0.pid) && $0.project == rec.project }) {
                    claimed.insert(p.pid)
                    if let i = result.firstIndex(where: { $0.project == rec.project && $0.pid == nil }) {
                        result[i].pid = p.pid
                    }
                }
            }
            for p in processes where !claimed.contains(p.pid) {
                // Seeded by pid so the same process keeps the same villain across refreshes.
                let leader = pickLeader(used: used, previous: previous, seed: UInt64(p.pid) &* 2654435761)
                used.insert(leader)
                previous = leader
                result.append(SessionSnapshot(id: "pid-\(p.pid)", leader: leader, project: p.project,
                                              mood: .idle, agents: [], live: false, pid: p.pid))
            }
        }
        if result.isEmpty {   // no Claude running: an idle Vader keeps the spot warm
            result.append(SessionSnapshot(id: "home", leader: 0, project: "", mood: .idle, agents: []))
        }

        let agents = s.agents.filter { now - $0.lastSeen <= agentTTL }.sorted { $0.started < $1.started }
        for a in agents {
            // Agents whose session we never heard from stand with the first villain.
            let i = result.firstIndex { $0.id == a.session } ?? 0
            result[i].agents.append(a)
        }
        return result
    }
}
