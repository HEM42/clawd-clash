import Foundation

// Shared state between the Claude Code hook binary (writer) and the overlay app (reader).
// Lives at ~/.claude/vader-status/state.json.

struct SessionRecord: Codable {
    var state: String      // idle | thinking | working | waiting
    var updated: Double
    var leader: Int?       // cast id of this session's character (see Cast: <100 dark side, 100+ light side)
    var project: String?   // last path component of the session's cwd
    var lastTool: Double?  // last PreToolUse, so brief "thinking" gaps between tools still read as working
    var pid: Int32?        // the claude process, so the session disappears as soon as it exits
    var created: Double?   // when the session first appeared, for spawn order
    var since: Double?     // when `state` last changed (status durations, long-idle sleep, ignored "!")
    var activity: String?  // what it's doing right now, e.g. "Edit Overlay.swift" or "Bash: swift build"
    var prompt: String?    // your last prompt (trimmed)
    var reply: String?     // Claude's last reply (trimmed), from Stop
    var title: String?     // Claude Code's session title
    var model: String?
    var tools: Int?        // tool calls this session
    var prompts: Int?      // prompts this session
    var assistant: String? // "claude" or "codex" (nil = claude, from before Codex support)
}

struct AgentRecord: Codable {
    var id: String
    var session: String
    var type: String
    var character: Int     // legacy hero index (Companion); `cast` supersedes it
    var cast: Int?         // cast id: <100 villains (Leader), 100+ heroes (Companion)
    var started: Double
    var lastSeen: Double
    var task: String?      // the Agent tool's short description, e.g. "Find hook events"
    var activity: String?  // the agent's current tool call
    var tools: Int?
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
    var record: SessionRecord?   // everything the hooks know (nil for sessions without hooks)
    var assistant = "claude"     // which AI runs this session: "claude", "codex", "qwen", "gemini" or "copilot"
    var stalled = false          // hooks say idle, but the process has been busy for a minute: not reporting
    var hookSilent = false       // started after our hooks were installed and ran a turn, yet never reported (e.g. Codex: not approved)
    var cwd: String?
}

enum StatusPaths {
    static let dir = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/vader-status", isDirectory: true)
    static let state = dir.appendingPathComponent("state.json")
    static let lock = dir.appendingPathComponent("state.lock")
}

enum StatusStore {
    static let companionCount = 15
    static let leaderCount = 15

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
    /// Brings other AIs' payloads to the Claude Code shape `apply` reads: Copilot's camelCase fields, Gemini CLI's
    /// event names (BeforeAgent → UserPromptSubmit, AfterTool → PostToolUse…), tool input sent as a JSON string.
    static func normalize(_ input: [String: Any], assistant: String, event: String?) -> [String: Any] {
        var j = input
        let renames = ["sessionId": "session_id", "hookEventName": "hook_event_name", "toolName": "tool_name",
                       "toolArgs": "tool_input", "transcriptPath": "transcript_path", "agentId": "agent_id",
                       "agentName": "agent_type", "agentDescription": "description"]
        for (from, to) in renames where j[to] == nil { if let v = j[from] { j[to] = v } }
        if let text = j["tool_input"] as? String, let data = text.data(using: .utf8),
           let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] { j["tool_input"] = obj }
        if let event { j["hook_event_name"] = event }
        if assistant == "gemini" {
            let names = ["BeforeAgent": "UserPromptSubmit", "AfterAgent": "Stop", "BeforeTool": "PreToolUse", "AfterTool": "PostToolUse"]
            if let e = j["hook_event_name"] as? String, let mapped = names[e] { j["hook_event_name"] = mapped }
            if j["last_assistant_message"] == nil, let reply = j["prompt_response"] { j["last_assistant_message"] = reply }
            if (j["notification_type"] as? String) == "ToolPermission" { j["notification_type"] = "permission_prompt" }
        }
        return j
    }

    static func apply(event json: [String: Any], assistant: String = "claude", now: Double = Date().timeIntervalSince1970) {
        let event = json["hook_event_name"] as? String ?? ""
        let session = json["session_id"] as? String ?? "default"
        let agentId = json["agent_id"] as? String
        let project = (json["cwd"] as? String).map { URL(fileURLWithPath: $0).lastPathComponent }
        let owner = agentId == nil ? ClaudeProcesses.hookOwner() : nil

        withLock { s in
            prune(&s, now: now)
            if event != "SessionEnd" {
                if s.sessions[session] == nil {
                    var rec = SessionRecord(state: "idle", updated: now, leader: nextLeader(s.sessions, assistant: assistant), project: project)
                    rec.assistant = assistant
                    rec.created = now
                    s.sessions[session] = rec
                }
                if s.sessions[session]?.leader == nil {
                    let leader = nextLeader(s.sessions, assistant: assistant)
                    s.sessions[session]?.leader = leader
                }
                if let project, agentId == nil { s.sessions[session]?.project = project }
                if let owner { s.sessions[session]?.pid = owner }
            }
            func set(_ state: String) {
                if s.sessions[session]?.state != state || s.sessions[session]?.since == nil { s.sessions[session]?.since = now }
                s.sessions[session]?.state = state
                s.sessions[session]?.updated = now
            }
            func touchAgent(_ id: String) {
                if let i = s.agents.firstIndex(where: { $0.id == id }) { s.agents[i].lastSeen = now }
            }
            func clip(_ v: Any?, _ n: Int) -> String? {
                guard let t = (v as? String)?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
                let flat = t.replacingOccurrences(of: "\n", with: " ")
                return flat.count > n ? String(flat.prefix(n - 1)) + "…" : flat
            }
            if let title = clip(json["session_title"], 80) { s.sessions[session]?.title = title }

            switch event {
            case "SessionStart":
                set("idle")
                if let m = json["model"] as? String { s.sessions[session]?.model = m }
                else if let m = (json["model"] as? [String: Any])?["id"] as? String { s.sessions[session]?.model = m }
            case "UserPromptSubmit":
                set("thinking")
                s.sessions[session]?.prompt = clip(json["prompt"], 240)
                let promptsCount = (s.sessions[session]?.prompts ?? 0) + 1
                    s.sessions[session]?.prompts = promptsCount
                s.sessions[session]?.activity = nil
            case "PreToolUse":
                let activity = describeTool(json["tool_name"] as? String ?? "", json["tool_input"] as? [String: Any] ?? [:])
                if let a = agentId {
                    touchAgent(a)
                    if let i = s.agents.firstIndex(where: { $0.id == a }) {
                        s.agents[i].activity = activity
                        s.agents[i].tools = (s.agents[i].tools ?? 0) + 1
                    }
                } else {
                    set("working")
                    s.sessions[session]?.lastTool = now
                    s.sessions[session]?.activity = activity
                    let toolsCount = (s.sessions[session]?.tools ?? 0) + 1
                    s.sessions[session]?.tools = toolsCount
                    // Remember the task of each agent Claude launches; SubagentStart picks it up.
                    let tool = json["tool_name"] as? String ?? ""
                    if ["Agent", "Task", "task", "agent"].contains(tool), let input = json["tool_input"] as? [String: Any],
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
                if agentId == nil {
                    set("waiting")
                    let tool = describeTool(json["tool_name"] as? String ?? "", json["tool_input"] as? [String: Any] ?? [:])
                    s.sessions[session]?.activity = "Asking to: " + tool
                }
            case "Notification":
                let type = json["notification_type"] as? String ?? ""
                let message = (json["message"] as? String ?? "").lowercased()
                if type == "permission_prompt" || message.contains("permission") { set("waiting") }
            case "Stop", "StopFailure", "Interrupt":
                set("idle")
                s.sessions[session]?.lastTool = nil
                s.sessions[session]?.activity = nil
                if let r = clip(json["last_assistant_message"], 240) { s.sessions[session]?.reply = r }
            case "SubagentStart":
                let id = agentId ?? UUID().uuidString
                if !s.agents.contains(where: { $0.id == id }) {
                    let type = json["agent_type"] as? String ?? "agent"
                    // Oldest queued launch of this type in this session (any type as a fallback).
                    var pending = s.pending ?? []
                    let match = pending.firstIndex { $0.session == session && $0.type == type }
                        ?? pending.firstIndex { $0.session == session }
                    let task = match.map { pending.remove(at: $0).task } ?? clip(json["description"], 80)
                    s.pending = pending
                    s.agents.append(AgentRecord(
                        id: id, session: session, type: type,
                        character: 0, cast: nextAgentCast(s, session: session),
                        started: now, lastSeen: now, task: task))
                }
            case "SubagentStop":
                if let a = agentId, s.agents.contains(where: { $0.id == a }) {
                    s.agents.removeAll { $0.id == a }
                } else if agentId == nil || assistant == "copilot" {
                    // No id, or (Copilot) an id its SubagentStart didn't give us: the oldest agent of that type.
                    let type = json["agent_type"] as? String
                    if let i = s.agents.firstIndex(where: { $0.session == session && $0.type == type })
                        ?? s.agents.lastIndex(where: { $0.session == session }) {
                        s.agents.remove(at: i)
                    }
                }
            case "SessionEnd":
                s.sessions[session] = nil
                s.agents.removeAll { $0.session == session }
            default:
                break
            }
        }
    }

    /// A short, human description of a tool call: "Edit Overlay.swift", "Bash: swift build", "Grep fightRoles".
    static func describeTool(_ tool: String, _ input: [String: Any]) -> String {
        func str(_ k: String) -> String? { (input[k] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
        func file(_ k: String) -> String? { str(k).map { ($0 as NSString).lastPathComponent } }
        func short(_ v: String, _ n: Int = 48) -> String {
            let flat = v.replacingOccurrences(of: "\n", with: " ")
            return flat.count > n ? String(flat.prefix(n - 1)) + "…" : flat
        }
        switch tool {
        case "Bash", "shell", "exec_command", "local_shell", "run_shell_command":
            return "Bash: " + short(str("description") ?? str("command") ?? (input["command"] as? [String])?.joined(separator: " ") ?? "")
        case "apply_patch":   // Codex edits files with patches: name the first file it touches
            let patch = str("command") ?? str("input") ?? ""
            let file = patch.components(separatedBy: "\n").first { $0.hasPrefix("*** ") && $0.contains("File: ") }
                .map { ($0.components(separatedBy: "File: ").last ?? "") as NSString }
            return "Edit " + (file?.lastPathComponent ?? "files")
        case "Read", "Edit", "Write", "MultiEdit": return "\(tool) \(file("file_path") ?? "")"
        // Qwen Code's tools
        case "read_file", "read_many_files": return "Read " + (file("file_path") ?? file("absolute_path") ?? file("path") ?? "files")
        case "write_file": return "Write " + (file("file_path") ?? file("absolute_path") ?? "")
        case "edit", "replace": return "Edit " + (file("file_path") ?? file("absolute_path") ?? "")
        case "grep_search", "search_file_content": return "Grep " + short(str("pattern") ?? "", 32)
        case "glob": return "Glob " + short(str("pattern") ?? "", 32)
        case "web_fetch": return "Fetch " + (str("url").flatMap { URL(string: $0)?.host } ?? "the web")
        case "web_search", "google_web_search": return "Search: " + short(str("query") ?? "", 40)
        case "todo_write", "write_todos": return "Updating todos"
        case "list_directory": return "List " + (file("dir_path") ?? file("path") ?? "files")
        case "task", "agent": return "Agent: " + short(str("description") ?? "", 40)
        case "NotebookEdit": return "Edit \(file("notebook_path") ?? "")"
        case "Grep": return "Grep " + short(str("pattern") ?? "", 32)
        case "Glob": return "Glob " + short(str("pattern") ?? "", 32)
        case "WebFetch": return "Fetch " + (str("url").flatMap { URL(string: $0)?.host } ?? "")
        case "WebSearch": return "Search: " + short(str("query") ?? "", 40)
        case "Agent", "Task": return "Agent: " + short(str("description") ?? "", 40)
        case "Skill": return "Skill " + (str("skill") ?? "")
        case "TodoWrite": return "Updating todos"
        default:
            if tool.hasPrefix("mcp__") {   // mcp__server__tool → "server: tool"
                let parts = tool.dropFirst(5).components(separatedBy: "__")
                return parts.count >= 2 ? "\(parts[0]): \(parts.dropFirst().joined(separator: " "))" : tool
            }
            return tool
        }
    }

    /// A random hero not already on screen (repeats only once all of them are out).
    // MARK: Cast and sides
    //
    // Cast ids: 0..<leaderCount are the dark side (Leader), 100..<100+companionCount the light side (Companion).
    // One AI running: every new character is random from the whole cast. Two AIs running (Claude and Codex):
    // the AI that was there first keeps the side it mostly has, the other AI takes the opposite, and each one's
    // agents join their session's side. Each side is preferred as much as possible; if it's all on screen
    // already, the other side lends someone.

    static let heroBase = 100
    static func isDark(_ cast: Int) -> Bool { cast < heroBase }
    static var darkCast: [Int] { Array(0..<leaderCount) }
    static var lightCast: [Int] { Array(heroBase..<(heroBase + companionCount)) }

    static func assistantOf(_ r: SessionRecord) -> String { r.assistant ?? "claude" }

    /// The side `assistant` should use right now, or nil when it's the only AI running (anything goes).
    static func side(for assistant: String, in sessions: [String: SessionRecord]) -> Bool? {
        let live = sessions.values.filter { $0.leader != nil }
        guard live.contains(where: { assistantOf($0) != assistant }) else { return nil }
        // Whoever has been running longest keeps the side it mostly has (ties: its first character's side).
        // (A record without `created` predates that field, so it's older than any that has one.)
        guard let first = live.min(by: { ($0.created ?? 0) < ($1.created ?? 0) }) else { return nil }
        let firstAI = assistantOf(first)
        let theirs = live.filter { assistantOf($0) == firstAI }.sorted { ($0.created ?? 0) < ($1.created ?? 0) }
        let dark = theirs.filter { isDark($0.leader!) }.count, light = theirs.count - dark
        let firstSideDark = dark == light ? isDark(theirs[0].leader!) : dark > light
        return firstAI == assistant ? firstSideDark : !firstSideDark
    }

    /// Character for a new session: random from the whole cast, or from this AI's side when two AIs are running
    /// (borrowing from the other side only when its own is all on screen). Vader and Kylo never spawn back to back.
    static func nextLeader(_ sessions: [String: SessionRecord], assistant: String = "claude") -> Int {
        let used = Set(sessions.values.compactMap(\.leader))
        let latest = sessions.values.filter { $0.leader != nil }.max { ($0.created ?? $0.updated) < ($1.created ?? $1.updated) }
        let pool: [Int]
        switch side(for: assistant, in: sessions) {
        case .some(true): pool = darkCast.filter { !used.contains($0) }.isEmpty ? lightCast : darkCast
        case .some(false): pool = lightCast.filter { !used.contains($0) }.isEmpty ? darkCast : lightCast
        case nil: pool = darkCast + lightCast
        }
        return pickLeader(used: used, previous: latest?.leader, pool: pool)
    }

    /// Character for a new agent: its session's side when two AIs are running, otherwise anyone;
    /// someone not already on screen whenever possible.
    static func nextAgentCast(_ s: StatusFile, session: String) -> Int {
        let onScreen = Set(s.agents.compactMap { $0.cast ?? (heroBase + $0.character) } + s.sessions.values.compactMap(\.leader))
        var pool = darkCast + lightCast
        if let rec = s.sessions[session], let leader = rec.leader, side(for: assistantOf(rec), in: s.sessions) != nil {
            pool = isDark(leader) ? darkCast : lightCast
        }
        let free = pool.filter { !onScreen.contains($0) }
        return (free.isEmpty ? pool : free).randomElement()!
    }

    /// `seed` makes the choice deterministic (for sessions found by the process scan, re-evaluated every refresh).
    static func pickLeader(used: Set<Int>, previous: Int?, seed: UInt64? = nil, pool: [Int]? = nil) -> Int {
        let pool = pool ?? darkCast
        var free = pool.filter { !used.contains($0) }
        if free.isEmpty { free = pool }                      // the whole pool is on screen: repeats are fine
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
                                          mood: mood(rec, now: now), agents: [], pid: rec.pid, record: rec,
                                          assistant: assistantOf(rec), cwd: rec.pid.flatMap { ClaudeProcesses.cwd($0) }))
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
                let leader = pickLeader(used: used, previous: previous, seed: UInt64(p.pid) &* 2654435761,
                                        pool: darkCast + lightCast)
                used.insert(leader)
                previous = leader
                result.append(SessionSnapshot(id: "pid-\(p.pid)", leader: leader, project: p.project,
                                              mood: .idle, agents: [], live: false, pid: p.pid,
                                              assistant: p.assistant, cwd: ClaudeProcesses.cwd(p.pid)))
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
