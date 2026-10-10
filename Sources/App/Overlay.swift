import AppKit
import ServiceManagement

/// Borderless, transparent, never-key panel that floats above every app (and full-screen spaces).
final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect { frameRect }
}

/// One character on screen. Positions are screen coordinates of the body centre.
private struct Actor {
    enum Kind { case leader(Leader), companion(Companion) }
    let key: String
    var kind: Kind
    var x: CGFloat
    var targetX: CGFloat
    var facing: CGFloat          // +1 right, -1 left while standing
    var walkDir: CGFloat = 0     // non-zero while walking
    let born: Double
    var leaving: Double?
    let phase: Double
    var mood: Mood = .idle
    var mode: VaderMode = .idle
    var label = ""
    var pid: Int32?

    var isLeader: Bool { if case .leader = kind { return true } else { return false } }
}

private struct Fight { let a: String, b: String }

private let fadeIn = 0.5
private let fadeOut = 0.6
private let fightLinger = 3.0      // keep fighting through brief gaps between tool calls

final class OverlayController: NSObject {
    private let panel: OverlayPanel
    private let view: OverlayView
    private var sessions: [SessionSnapshot] = []
    private var actors: [Actor] = []
    private var fights: [Fight] = []
    private var cheering: Set<String> = []
    private var fightUntil: [String: Double] = [:]
    private var home = NSPoint.zero    // Vader's resting spot (between his feet)
    private var demo = CommandLine.arguments.contains("--demo")
    private var demoStart = 0.0
    // Playground: villains picked from the menu, in the order added (which decides who fights whom).
    private var playground: [Int]? = CommandLine.arguments.first { $0.hasPrefix("--playground=") }
        .map { $0.dropFirst(13).split(separator: ",").compactMap { Int($0) } }
    private var playgroundAgents: [Int] = CommandLine.arguments.first { $0.hasPrefix("--agents=") }
        .map { $0.dropFirst(9).split(separator: ",").compactMap { Int($0) } } ?? []
    private var playgroundMood: Mood = .working
    private var dragging = false
    private var dragOffset = NSPoint.zero
    private var lastTick = Date().timeIntervalSince1970
    private let start = Date().timeIntervalSince1970
    private var frameCount = 0
    private let debug = ProcessInfo.processInfo.environment["VADER_DEBUG"] != nil
    private var lastDebug = 0
    private var processes: [ClaudeProcesses.Info] = []
    private var lastScan = 0.0
    private var cpuSamples: [Int32: (at: Double, cpu: Double)] = [:]
    private var busyUntil: [Int32: Double] = [:]
    fileprivate var items: [DrawItem] = []

    private var zoom: CGFloat {
        get { let z = UserDefaults.standard.double(forKey: "zoom"); return z > 0 ? z : 1 }
        set { UserDefaults.standard.set(newValue, forKey: "zoom") }
    }

    private var showLabels: Bool {
        get { UserDefaults.standard.object(forKey: "labels") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "labels") }
    }

    // Layout constants in points at zoom 1.
    private static let leaderScale: CGFloat = 3
    private static let companionScale: CGFloat = 2
    private static let leaderReach: (fwd: CGFloat, back: CGFloat) = (105, 50)
    private static let agentReach: (fwd: CGFloat, back: CGFloat) = (72, 28)
    private static let gap: CGFloat = 8
    private static let duelDistance: CGFloat = 170
    private static let walkSpeed: CGFloat = 150
    /// Example agent tasks for the Playground and Demo Mode.
    private static let sampleTasks = ["Find hook events", "Review Overlay.swift", "Run the test suite", "Plan the refactor",
                                      "Search for usages", "Fix failing build", "Write changelog", "Audit permissions",
                                      "Explore codebase", "Check git history", "Draft README", "Profile CPU usage",
                                      "Verify the fix"]
    /// Empty canvas rows under the feet (8 px at leader scale), allowed to hang off the bottom of the screen.
    private static let footroom: CGFloat = 8 * leaderScale

    override init() {
        panel = OverlayPanel(contentRect: NSRect(x: 0, y: 0, width: 10, height: 10),
                             styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        view = OverlayView()
        super.init()
        view.controller = self

        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.contentView = view

        home = savedHome()
        refreshStatus()
        snapActors()
        tick()
        panel.orderFrontRegardless()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in self?.refreshStatus() }
        let frame = Timer(timeInterval: 1.0 / 30, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(frame, forMode: .common)
    }

    // MARK: Placement

    private func savedHome() -> NSPoint {
        let d = UserDefaults.standard
        if d.object(forKey: "anchorX") != nil {
            let p = NSPoint(x: d.double(forKey: "anchorX"), y: d.double(forKey: "anchorY"))
            let feet = NSPoint(x: p.x, y: p.y + Self.footroom * zoom)
            if NSScreen.screens.contains(where: { $0.frame.insetBy(dx: -20, dy: -20).contains(feet) }) { return p }
        }
        let mouse = NSEvent.mouseLocation
        let vf = (NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        return NSPoint(x: vf.maxX - 140 * zoom, y: vf.minY - Self.footroom * zoom)
    }

    private func saveHome() {
        UserDefaults.standard.set(home.x, forKey: "anchorX")
        UserDefaults.standard.set(home.y, forKey: "anchorY")
    }

    /// The screen the crew is standing on. `p` is the home point (bottom of the canvas); the feet are
    /// `footroom` above it, and that's what counts — the empty rows under the feet may hang off the edge.
    private func screen(at p: NSPoint) -> NSScreen? {
        let feet = NSPoint(x: p.x, y: p.y + Self.footroom * zoom + 1)
        return NSScreen.screens.first { $0.frame.contains(feet) } ?? NSScreen.main
    }

    /// Keep the lead villain fully on its screen, with the feet allowed right down to the bottom edge.
    /// While dragging, the screen under the cursor wins, so on stacked monitors the crew can stand on the
    /// bottom edge of the upper one instead of tipping over onto the lower one. Feet dropped within
    /// 12 pt of a bottom edge snap onto it.
    private func clampHome(_ p: NSPoint, cursor: NSPoint? = nil) -> NSPoint {
        let byCursor = cursor.flatMap { c in NSScreen.screens.first { $0.frame.contains(c) } }
        guard let f = (byCursor ?? screen(at: p) ?? NSScreen.main)?.frame else { return p }
        let s = Self.leaderScale * zoom
        let floor = f.minY - Self.footroom * zoom
        var y = min(max(p.y, floor), f.maxY - CGFloat(Sprite.height) * s)
        if y - floor < 12 { y = floor }
        return NSPoint(x: min(max(p.x, f.minX + 18 * s), f.maxX - 18 * s), y: y)
    }

    // MARK: Status

    private func refreshStatus() {
        let now = Date().timeIntervalSince1970
        if let playground {
            sessions = playgroundSessions(playground)
        } else if demo {
            sessions = demoSessions(now - demoStart)
        } else {
            if now - lastScan > 3 {
                processes = ClaudeProcesses.running()
                lastScan = now
                sampleCPU(now)
            }
            sessions = StatusStore.snapshot(StatusStore.load() ?? StatusFile(), now: now, processes: processes)
            // Sessions without hooks can't report status, but a busy Claude burns CPU (idle ≈ 0.3%,
            // working ≈ 5–10%), so treat sustained CPU as "working" for them.
            for i in sessions.indices where !sessions[i].live {
                if let pid = sessions[i].pid, (busyUntil[pid] ?? 0) > now { sessions[i].mood = .working }
            }
        }
        relayout()
    }

    private func sampleCPU(_ now: Double) {
        var next: [Int32: (at: Double, cpu: Double)] = [:]
        for p in processes {
            guard let cpu = ClaudeProcesses.cpuSeconds(p.pid) else { continue }
            if let prev = cpuSamples[p.pid], now > prev.at {
                let usage = (cpu - prev.cpu) / (now - prev.at)
                if usage > 0.03 { busyUntil[p.pid] = now + 6 }
            }
            next[p.pid] = (now, cpu)
        }
        cpuSamples = next
        busyUntil = busyUntil.filter { $0.value > now }
    }

    /// Build the formation and give every actor a target position.
    ///
    /// Leaders pair up (1st & 2nd Claude, 3rd & 4th…) facing each other so they can fight; each leader's
    /// agents stand on its outer side. The whole line extends toward the side of the screen with more room,
    /// and if it still doesn't fit, everyone walks along until it does.
    private func relayout() {
        let now = Date().timeIntervalSince1970
        let z = zoom

        struct Unit { let key: String; let kind: Actor.Kind; var facing: CGFloat; let fwd, back: CGFloat
            var fixedDistance: CGFloat?; var session: SessionSnapshot?; var agent: AgentRecord? }
        var units: [Unit] = []
        var newFights: [Fight] = []

        func agentUnit(_ a: AgentRecord, _ facing: CGFloat) -> Unit {
            Unit(key: "A:" + a.id, kind: .companion(Companion(rawValue: a.character % Companion.allCases.count) ?? .luke),
                 facing: facing, fwd: Self.agentReach.fwd * z, back: Self.agentReach.back * z, agent: a)
        }
        func leaderUnit(_ s: SessionSnapshot, _ facing: CGFloat) -> Unit {
            Unit(key: "L:" + s.id, kind: .leader(Leader(index: s.leader)), facing: facing,
                 fwd: Self.leaderReach.fwd * z, back: Self.leaderReach.back * z, session: s)
        }

        // Everyone on screen, in their natural order (each villain followed by its agents).
        struct Member { var unit: Unit; let weapon: Weapon; let isLeader: Bool; let order: Int }
        var members: [Member] = []
        for s in sessions {
            members.append(Member(unit: leaderUnit(s, 1), weapon: Leader(index: s.leader).weapon, isLeader: true,
                                  order: members.count))
            for ag in s.agents {
                let who = Companion(rawValue: ag.character % Companion.allCases.count) ?? .luke
                members.append(Member(unit: agentUnit(ag, 1), weapon: who.weapon, isLeader: false, order: members.count))
            }
        }

        // Who fights whom:
        //  1. Claudes always fight Claudes (saber duels first).
        //  2. Agents fight agents — their own or other Claudes' (saber duels first).
        //  3. A leftover Claude and a leftover agent fight each other (one Claude + one agent = Vader vs Luke).
        //  4. Anyone still left over cheers the fighters on. R2-D2 and C-3PO are unarmed bystanders.
        // A lone Claude with nobody to fight just practises its kata when working.
        var pairs: [(Member, Member)] = []
        func pairUp(_ pool: inout [Member]) {
            for saberFirst in [true, false] {
                var k = 0
                while k < pool.count {
                    let eligible = { (a: Member, b: Member) in !saberFirst || (a.weapon == .saber && b.weapon == .saber) }
                    guard let m = pool.indices.dropFirst(k + 1).first(where: { eligible(pool[k], pool[$0]) }) else { k += 1; continue }
                    pairs.append((pool[k], pool[m]))
                    pool.remove(at: m); pool.remove(at: k)
                }
            }
        }
        var villains = members.filter { $0.isLeader && $0.weapon != .none }
        let unarmedVillains = members.filter { $0.isLeader && $0.weapon == .none }
        var agents = members.filter { !$0.isLeader && $0.weapon != .none }
        pairUp(&villains)
        pairUp(&agents)
        if let v = villains.first, let a = agents.first {
            pairs.append((v, a))
            villains.removeFirst(); agents.removeFirst()
        }
        var pool = agents
        if !pairs.isEmpty { pool += villains + unarmedVillains }   // a lone Claude with no opponents practises instead
        cheering = Set(pool.map(\.unit.key))
        let paired = Set(pairs.flatMap { [$0.0.unit.key, $0.1.unit.key] })

        // Lay out pairs and everyone else, keeping roughly the natural order so the line is stable.
        var groups: [[Member]] = pairs.map { [$0.0, $0.1] }
        groups += members.filter { !paired.contains($0.unit.key) }.map { [$0] }
        groups.sort { $0.map(\.order).min()! < $1.map(\.order).min()! }

        for g in groups {
            if g.count == 1 {
                units.append(g[0].unit)
                continue
            }
            var a = g[0].unit, b = g[1].unit
            a.facing = 1; b.facing = -1
            newFights.append(Fight(a: a.key, b: b.key))
            if fightIsCloseQuarters(g[0].weapon, g[1].weapon) {
                // Close enough that the two blades cross, whatever the sprite sizes.
                let sa = g[0].isLeader ? Self.leaderScale : Self.companionScale
                let sb = g[1].isLeader ? Self.leaderScale : Self.companionScale
                b.fixedDistance = (13.5 * (sa + sb) + 29.7 * min(sa, sb)) * z
            }
            units.append(a)
            units.append(b)
        }
        fights = newFights
        fightUntil = fightUntil.filter { $0.value > now - 60 }

        // Positions along the formation axis (f), Vader at 0.
        func left(_ u: Unit) -> CGFloat { u.facing > 0 ? u.back : u.fwd }
        func right(_ u: Unit) -> CGFloat { u.facing > 0 ? u.fwd : u.back }
        var f: [CGFloat] = []
        for (k, u) in units.enumerated() {
            if k == 0 { f.append(0); continue }
            f.append(f[k - 1] + (u.fixedDistance ?? (right(units[k - 1]) + Self.gap * z + left(u))))
        }
        // The first-spawned villain stands on the saved spot; everyone else lines up from there.
        let vaderIndex = units.firstIndex { u in u.session?.id == sessions.first?.id } ?? 0
        let origin = f.isEmpty ? 0 : f[vaderIndex]
        f = f.map { $0 - origin }

        // Direction: toward the side of the screen with more room.
        let sf = screen(at: home)?.frame ?? NSRect(x: -1e5, y: 0, width: 2e5, height: 1e5)
        let dir: CGFloat = (sf.maxX - home.x) >= (home.x - sf.minX) ? 1 : -1
        var lo = CGFloat.greatestFiniteMagnitude, hi = -CGFloat.greatestFiniteMagnitude
        for (k, u) in units.enumerated() {
            let x = home.x + dir * f[k]
            let ext = (dir * u.facing > 0) ? (u.back, u.fwd) : (u.fwd, u.back)
            lo = min(lo, x - ext.0); hi = max(hi, x + ext.1)
        }
        var shift: CGFloat = 0
        if hi > sf.maxX - 4 { shift = sf.maxX - 4 - hi }
        if lo + shift < sf.minX + 4 { shift = sf.minX + 4 - lo }

        // Reconcile actors.
        var seen = Set<String>()
        for (k, u) in units.enumerated() {
            seen.insert(u.key)
            let target = home.x + dir * f[k] + shift
            let facing = dir * u.facing
            var mood = Mood.idle, mode = VaderMode.idle, label = ""
            let pid = u.session?.pid
            if let s = u.session {
                mood = s.mood
                mode = s.mood == .idle && !s.agents.isEmpty ? .standGuard : VaderMode(s.mood)
                label = s.project.isEmpty ? (s.id == "home" ? "" : Leader(index: s.leader).name) : s.project
            }
            if let a = u.agent { label = Self.agentLabel(a) }
            if let idx = actors.firstIndex(where: { $0.key == u.key && $0.leaving == nil }) {
                actors[idx].targetX = target
                actors[idx].facing = facing
                actors[idx].kind = u.kind
                actors[idx].mood = mood; actors[idx].mode = mode; actors[idx].label = label
                actors[idx].pid = pid
            } else {
                var a = Actor(key: u.key, kind: u.kind, x: target, targetX: target, facing: facing,
                              born: now, phase: Double(abs(u.key.hashValue) % 1000) / 97)
                a.mood = mood; a.mode = mode; a.label = label; a.pid = pid
                actors.append(a)
            }
        }
        for idx in actors.indices where actors[idx].leaving == nil && !seen.contains(actors[idx].key) {
            actors[idx].leaving = now
        }
    }

    private func snapActors() {
        for i in actors.indices {
            actors[i].x = actors[i].targetX
            actors[i].walkDir = 0
        }
    }

    private func playgroundSessions(_ villains: [Int]) -> [SessionSnapshot] {
        let crew = playgroundAgents.map {
            AgentRecord(id: "pg-a\($0)", session: "pg", type: "playground", character: $0, started: Double($0), lastSeen: 0,
                        task: Self.sampleTasks[$0 % Self.sampleTasks.count])
        }
        guard !villains.isEmpty else {
            return [SessionSnapshot(id: "home", leader: 0, project: "", mood: .idle, agents: crew)]
        }
        // Agents join the first villain. Empty project → the label shows the villain's name.
        return villains.enumerated().map { i, l in
            SessionSnapshot(id: "pg-\(l)", leader: l, project: "", mood: playgroundMood, agents: i == 0 ? crew : [])
        }
    }

    private func demoSessions(_ t: Double) -> [SessionSnapshot] {
        func agents(_ chars: [Int], session: String) -> [AgentRecord] {
            chars.map { AgentRecord(id: "demo-\($0)", session: session, type: "demo", character: $0,
                                    started: Double($0), lastSeen: 0, task: Self.sampleTasks[$0 % Self.sampleTasks.count]) }
        }
        func s(_ leader: Int, _ mood: Mood, _ crew: [Int] = []) -> SessionSnapshot {
            SessionSnapshot(id: "demo-\(leader)", leader: leader, project: "project-\(leader + 1)",
                            mood: mood, agents: agents(crew, session: "demo-\(leader)"))
        }
        switch Int(t / 6) % 10 {
        case 0: return [s(0, .idle)]
        case 1: return [s(0, .thinking)]
        case 2: return [s(0, .working)]
        case 3: return [s(0, .waiting)]
        case 4: return [s(0, .working, [0, 1, 2])]
        case 5: return [s(0, .working, [0]), s(1, .working)]                                   // Vader vs Kylo: duel
        case 6: return [s(0, .working), s(3, .working, [1])]                                   // Boba shoots, Vader deflects
        case 7: return [s(0, .thinking, [4]), s(1, .working), s(2, .working), s(5, .working)]  // Maul vs Emperor
        case 8: return [s(0, .working, [3]), s(4, .working, [5])]                             // Stormtrooper vs Vader
        default: return [s(0, .idle, [0, 3, 4])]
        }
    }

    // MARK: Frame loop

    private func tick() {
        let now = Date().timeIntervalSince1970
        let dt = CGFloat(min(0.1, now - lastTick))
        lastTick = now
        actors.removeAll { $0.leaving.map { now - $0 > fadeOut } ?? false }

        for i in actors.indices {
            let d = actors[i].targetX - actors[i].x
            if dragging || abs(d) < 0.5 {
                actors[i].x = actors[i].targetX
                actors[i].walkDir = 0
            } else {
                let stepLen = min(abs(d), Self.walkSpeed * zoom * dt)
                actors[i].x += d > 0 ? stepLen : -stepLen
                actors[i].walkDir = d > 0 ? 1 : -1
            }
        }

        // Idle scenes only breathe, so 10 fps is plenty; full 30 fps when anything is moving.
        frameCount += 1
        let busy = dragging || !fights.isEmpty || actors.contains {
            $0.walkDir != 0 || $0.leaving != nil || now - $0.born < fadeIn || !$0.isLeader
                || $0.mode == .working || $0.mode == .waiting
        }
        guard busy || frameCount % 3 == 0 else { return }

        items = buildItems(now: now)

        // Fit the window around everything that's drawn.
        var bounds = NSRect.null
        for item in items { bounds = bounds.union(item.rect) }
        if bounds.isNull { bounds = NSRect(x: home.x, y: home.y, width: 1, height: 1) }
        bounds = bounds.insetBy(dx: -4, dy: -4).integral
        if bounds != panel.frame { panel.setFrame(bounds, display: false) }

        let mouse = NSEvent.mouseLocation
        let passThrough = !(dragging || leaderHitRects().contains { $0.contains(mouse) })
        if panel.ignoresMouseEvents != passThrough { panel.ignoresMouseEvents = passThrough }

        view.needsDisplay = true
    }

    private func leaderHitRects() -> [NSRect] {
        let s = Self.leaderScale * zoom
        return actors.filter { $0.isLeader && $0.leaving == nil }.map {
            NSRect(x: $0.x - 16 * s, y: home.y + 5 * s, width: 32 * s, height: 35 * s)
        }
    }

    struct DrawItem {
        var image: CGImage?
        var text: NSAttributedString?
        let rect: NSRect
        var mirrored = false
        var alpha: CGFloat = 1
        var boxed = false      // text drawn on a dark rounded box so it reads on any wallpaper
        var agentBox = false   // agents' task boxes get a blue tint to tell them from project names
    }

    private func buildItems(now: Double) -> [DrawItem] {
        let t = now - start
        let z = zoom
        let ls = Self.leaderScale * z, cs = Self.companionScale * z
        var out: [DrawItem] = []
        var overlay: [DrawItem] = []

        // Fight roles for pairs that have arrived (not walking); the odd one out cheers.
        func weapon(_ a: Actor) -> Weapon {
            switch a.kind { case .leader(let w): return w.weapon; case .companion(let w): return w.weapon }
        }
        var roles: [String: FightRole] = [:]
        var fx: [(Actor, Actor)] = []
        for fight in fights {
            guard let a = actors.first(where: { $0.key == fight.a && $0.leaving == nil }),
                  let b = actors.first(where: { $0.key == fight.b && $0.leaving == nil }),
                  a.walkDir == 0, b.walkDir == 0 else { continue }
            let (l, r) = a.x <= b.x ? (a, b) : (b, a)
            let (lRole, rRole) = fightRoles(weapon(l), weapon(r))
            roles[l.key] = lRole; roles[r.key] = rRole
            fx.append((l, r))
        }
        for a in actors where cheering.contains(a.key) && a.walkDir == 0 && a.leaving == nil { roles[a.key] = .cheer }
        if debug, Int(now * 2) != lastDebug {
            lastDebug = Int(now * 2)
            let line = actors.map { a in
                "\(a.key) x=\(Int(a.x)) tgt=\(Int(a.targetX)) walk=\(Int(a.walkDir)) face=\(Int(a.facing)) mood=\(a.mood) role=\(roles[a.key].map { "\($0)" } ?? "-")"
            }.joined(separator: " | ")
            FileHandle.standardError.write("fights=\(fights.count) \(line)\n".data(using: .utf8)!)
        }

        let screenFrame = screen(at: home)?.frame ?? .infinite
        // Companions first so leaders (and their sabers) draw on top.
        for actor in actors.sorted(by: { !$0.isLeader && $1.isLeader }) {
            let walking = actor.walkDir != 0
            let facing = walking ? actor.walkDir : actor.facing
            let canvas = PixelCanvas(Sprite.width, Sprite.height)
            let scale: CGFloat
            let y: CGFloat
            switch actor.kind {
            case .leader(let who):
                let role = roles[actor.key]
                drawLeader(canvas, who, t: t, mode: role != nil ? .working : actor.mode,
                           walking: walking, role: role ?? .none)
                scale = ls; y = home.y
            case .companion(let who):
                let role = roles[actor.key]
                drawCompanion(canvas, who, t: role != nil ? t : t + actor.phase, walking: walking, role: role ?? .none)
                scale = cs; y = home.y + (ls - cs) * 8
            }
            canvas.addOutline(C(0xFFFFFF, 0.92))
            guard let img = canvas.makeImage() else { continue }

            var alpha = min(1, (now - actor.born) / fadeIn)
            var drop = (1 - alpha) * 24
            if let left = actor.leaving {
                let f = min(1, (now - left) / fadeOut)
                alpha = min(alpha, 1 - f)
                drop = -f * 30
            }
            let mirrored = facing < 0
            let bodyX = (mirrored ? CGFloat(Sprite.width) - CGFloat(Sprite.bodyCenterX) : CGFloat(Sprite.bodyCenterX)) * scale
            let rect = NSRect(x: (actor.x - bodyX).rounded(), y: y + CGFloat(drop) * z,
                              width: CGFloat(Sprite.width) * scale, height: CGFloat(Sprite.height) * scale)
            out.append(DrawItem(image: img, rect: rect, mirrored: mirrored, alpha: CGFloat(alpha)))

            // Speech bubble on whichever side of the head fits on screen (Claudes only).
            var bubbleSpan: (minX: CGFloat, maxX: CGFloat, maxY: CGFloat)?
            if actor.isLeader && (actor.mood == .thinking || actor.mood == .waiting) {
                let bc = PixelCanvas(Bubble.width, Bubble.height)
                drawBubble(bc, mood: actor.mood, t: t)
                if let bimg = bc.makeImage() {
                    let w = CGFloat(Bubble.width) * ls, h = CGFloat(Bubble.height) * ls
                    let by = y + CGFloat(Sprite.height - 1 - Bubble.height) * ls
                    let rightX = actor.x + 13 * ls
                    let onRight = rightX + w <= screenFrame.maxX
                    let bx = onRight ? rightX : actor.x - 13 * ls - w
                    bubbleSpan = (bx, bx + w, by + h)
                    overlay.append(DrawItem(image: bimg, rect: NSRect(x: bx.rounded(), y: by, width: w, height: h),
                                            mirrored: !onRight, alpha: CGFloat(alpha)))
                }
            }

            // R0-GR acknowledges orders and Jabba laughs, now and then.
            let callouts: [Leader: String] = [.rogr: "Roger roger!", .jabba: "Ho ho ho!"]
            if case .leader(let who) = actor.kind, let line = callouts[who], actor.walkDir == 0,
               (t / 5 + actor.phase).truncatingRemainder(dividingBy: 1) < 0.3 {
                let callout = NSAttributedString(string: line, attributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: max(9, 10 * z), weight: .heavy),
                    .foregroundColor: NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: alpha),
                    .strokeColor: NSColor.black.withAlphaComponent(alpha),
                    .strokeWidth: -4.0,
                ])
                let size = callout.size()
                // On the side away from the speech bubble, level with the head.
                let onLeft = bubbleSpan.map { $0.minX > actor.x } ?? (facing > 0)
                let cx = min(max(onLeft ? actor.x - 16 * ls - size.width : actor.x + 16 * ls, screenFrame.minX + 2),
                             screenFrame.maxX - size.width - 2)
                overlay.append(DrawItem(text: callout, rect: NSRect(x: cx.rounded(), y: y + 33 * ls,
                                                                    width: size.width, height: size.height)))
            }

            // Project name (Claudes) or task (agents) just above the head, clear of any speech bubble.
            if showLabels && !actor.label.isEmpty {
                let font = actor.isLeader ? NSFont.monospacedSystemFont(ofSize: max(9, 10 * z), weight: .bold)
                                          : NSFont.monospacedSystemFont(ofSize: max(8, 8.5 * z), weight: .semibold)
                let centered = NSMutableParagraphStyle()
                centered.alignment = .center
                let lines = wrapLabel(actor.label, font: font, maxWidth: (actor.isLeader ? 110 : 88) * z)
                let text = NSAttributedString(string: lines.joined(separator: "\n"), attributes: [
                    .font: font,
                    .foregroundColor: NSColor.white.withAlphaComponent(alpha),
                    .paragraphStyle: centered,
                ])
                let textSize = text.size()
                let size = NSSize(width: textSize.width + 10 * z, height: textSize.height + 4 * z)
                var lx = actor.x - size.width / 2
                if let b = bubbleSpan {
                    if b.minX > actor.x { lx = min(lx, b.minX - size.width - 2 * z) }
                    else { lx = max(lx, b.maxX + 2 * z) }
                }
                // Never past the screen edge.
                lx = min(max(lx, screenFrame.minX + 2), screenFrame.maxX - size.width - 2)
                let headTop: CGFloat
                switch actor.kind {
                case .leader(let who): headTop = CGFloat(Sprite.height - who.headTop) * ls + 8 * z
                case .companion(let who): headTop = CGFloat(Sprite.height - who.headTop) * cs + 5 * z
                }
                do {
                    var ly = y + CGFloat(drop) * z + headTop
                    // Pulled back over a speech bubble by the edge clamp? Sit on top of the bubble instead.
                    if let b = bubbleSpan, lx < b.maxX, lx + size.width > b.minX { ly = max(ly, b.maxY + 3 * z) }
                    overlay.append(DrawItem(text: text, rect: NSRect(x: lx.rounded(), y: ly,
                                                                     width: size.width, height: size.height),
                                            alpha: CGFloat(alpha), boxed: true, agentBox: !actor.isLeader))
                }
            }
        }

        // Bolts, deflections, lightning and sparks between fighters.
        for (l, r) in fx {
            let margin = 24.0
            let dist = Double((r.x - l.x) / ls)
            let width = Int(dist + margin * 2)
            guard width > 0, width < 4000 else { continue }
            let left = l.x - CGFloat(margin) * ls
            func fighter(_ a: Actor, side: Double) -> Fighter {
                let sc = a.isLeader ? ls : cs
                let lift = a.isLeader ? 0 : (ls - cs) * 8
                var muzzle = (x: 52.0, y: 32.0)
                if case .companion(let who) = a.kind { muzzle = who.muzzle }
                return Fighter(weapon: weapon(a), x: Double((a.x - left) / ls), k: Double(sc / ls),
                               top: Double((CGFloat(Sprite.height) * (ls - sc) - lift) / ls), side: side, muzzle: muzzle)
            }
            let c = PixelCanvas(width, Sprite.height)
            drawFightFX(c, t: t, left: fighter(l, side: 1), right: fighter(r, side: -1))
            if let img = c.makeImage() {
                overlay.append(DrawItem(image: img, rect: NSRect(x: left.rounded(), y: home.y,
                                                                 width: CGFloat(width) * ls,
                                                                 height: CGFloat(Sprite.height) * ls)))
            }
        }
        return out + overlay
    }

    /// What an agent is doing: its task description, else a readable version of its type.
    static func agentLabel(_ a: AgentRecord) -> String {
        if let task = a.task, !task.isEmpty { return task }
        switch a.type {
        case "general-purpose", "agent", "claude": return "Agent"
        case "playground", "demo": return ""
        default: return a.type.replacingOccurrences(of: "-", with: " ").capitalized
        }
    }

    /// Word-wrap a project name onto at most two lines of `maxWidth`; whatever still doesn't fit gets "…".
    private func wrapLabel(_ label: String, font: NSFont, maxWidth: CGFloat) -> [String] {
        func width(_ s: String) -> CGFloat { (s as NSString).size(withAttributes: [.font: font]).width }
        guard width(label) > maxWidth else { return [label] }
        // Break on spaces, dashes and underscores (keeping the dash/underscore at the end of the line).
        var words: [String] = []
        var current = ""
        for ch in label {
            current.append(ch)
            if ch == " " || ch == "-" || ch == "_" { words.append(current); current = "" }
        }
        if !current.isEmpty { words.append(current) }

        var lines: [String] = [""]
        for w in words {
            let candidate = lines[lines.count - 1] + w
            if width(candidate.trimmingCharacters(in: .whitespaces)) <= maxWidth || lines[lines.count - 1].isEmpty {
                lines[lines.count - 1] = candidate
            } else {
                lines.append(w)
            }
        }
        lines = lines.map { $0.trimmingCharacters(in: .whitespaces) }
        // Hard-split a single long word, and squeeze anything past two lines into the second with an ellipsis.
        if width(lines[0]) > maxWidth {
            // One word too long for a line: fill the first line with as much as fits.
            let all = lines.joined(separator: " ")
            var n = all.count
            while n > 1 && width(String(all.prefix(n))) > maxWidth { n -= 1 }
            lines = [String(all.prefix(n)), String(all.dropFirst(n))]
        }
        var second = ""
        for line in lines.dropFirst() {
            let joiner = second.isEmpty || second.hasSuffix("-") || second.hasSuffix("_") ? "" : " "
            second += joiner + line
        }
        if width(second) > maxWidth {
            while !second.isEmpty && width(second + "…") > maxWidth { second.removeLast() }
            second = second.trimmingCharacters(in: .whitespaces) + "…"
        }
        return [lines[0], second]
    }

    // MARK: Dragging

    private var dragStart = NSPoint.zero

    func beginDrag() {
        dragging = true
        let m = NSEvent.mouseLocation
        dragStart = m
        dragOffset = NSPoint(x: m.x - home.x, y: m.y - home.y)
    }

    func continueDrag() {
        let m = NSEvent.mouseLocation
        home = clampHome(NSPoint(x: (m.x - dragOffset.x).rounded(), y: (m.y - dragOffset.y).rounded()), cursor: m)
        relayout()
        snapActors()
    }

    func endDrag() {
        dragging = false
        let m = NSEvent.mouseLocation
        if hypot(m.x - dragStart.x, m.y - dragStart.y) < 4 {
            jump(at: m)    // a click, not a drag
        } else {
            saveHome()
        }
    }

    /// Clicking a villain brings its Claude session's terminal/editor window to the front.
    private func jump(at point: NSPoint) {
        let s = Self.leaderScale * zoom
        guard let actor = actors.first(where: {
            $0.isLeader && $0.leaving == nil
                && NSRect(x: $0.x - 16 * s, y: home.y + 5 * s, width: 32 * s, height: 35 * s).contains(point)
        }) else { return }
        guard let pid = actor.pid else { NSSound.beep(); return }
        Jump.toSession(pid: pid)
    }

    // MARK: Menu

    func menu() -> NSMenu {
        let m = NSMenu()
        for s in sessions {
            let leader = Leader(index: s.leader)
            let status: String = {
                switch s.mood {
                case .idle: return s.agents.isEmpty ? "Idle" : "Idle (agents running)"
                case .thinking: return "Thinking…"
                case .working: return "Working"
                case .waiting: return "Needs your attention"
                }
            }()
            let project = s.project.isEmpty ? "" : " — \(s.project)"
            m.addItem(disabled: "\(leader.name)\(project): \(s.live ? status : "no live status (restart this Claude session)")")
            for a in s.agents {
                let who = Companion(rawValue: a.character % Companion.allCases.count) ?? .luke
                m.addItem(disabled: "     \(who.name) — \(a.task ?? a.type)")
            }
        }
        if demo { m.addItem(disabled: "(demo mode)") }
        if playground != nil { m.addItem(disabled: "(playground)") }
        m.addItem(.separator())

        let size = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        let sub = NSMenu()
        for (title, z) in [("Small", 0.67), ("Medium", 1.0), ("Large", 1.33), ("Huge", 1.75)] {
            let item = NSMenuItem(title: title, action: #selector(setZoom(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = z
            item.state = abs(zoom - z) < 0.01 ? .on : .off
            sub.addItem(item)
        }
        size.submenu = sub
        m.addItem(size)
        m.addItem(action: "Show Project Names", #selector(toggleLabels), target: self, on: showLabels)
        m.addItem(playgroundMenu())
        m.addItem(action: "Demo Mode", #selector(toggleDemo), target: self, on: demo)
        m.addItem(action: "Forget Idle Sessions", #selector(forgetIdle), target: self)
        m.addItem(action: "Reset Position", #selector(resetPosition), target: self)
        m.addItem(action: "Launch at Login", #selector(toggleLogin), target: self,
                  on: SMAppService.mainApp.status == .enabled)
        m.addItem(.separator())
        if HookInstaller.isInstalled {
            m.addItem(action: "Remove Claude Code Hooks", #selector(removeHooks), target: self)
        } else {
            m.addItem(action: "Install Claude Code Hooks", #selector(installHooks), target: self)
        }
        m.addItem(.separator())
        m.addItem(action: "Quit", #selector(quit), target: self)
        return m
    }

    @objc private func setZoom(_ sender: NSMenuItem) {
        zoom = sender.representedObject as? Double ?? 1
        home = clampHome(home)
        relayout()
        snapActors()
    }

    @objc private func toggleLabels() { showLabels.toggle() }

    private func playgroundMenu() -> NSMenuItem {
        let root = NSMenuItem(title: "Playground", action: nil, keyEquivalent: "")
        let pm = NSMenu()
        let picked = playground ?? []
        pm.addItem(disabled: "Villains — they pair up in the order you add them")
        let weapons: [Leader: String] = [.vader: "red saber", .kylo: "crossguard saber", .maul: "double saber",
                                         .boba: "EE-3 blaster", .trooper: "E-11 blaster", .emperor: "Force lightning",
                                         .rogr: "E-5 blaster", .dooku: "curved-hilt saber",
                                         .gamorrean: "vibro-axe", .jabba: "unarmed — laughs", .ig88: "blaster rifle"]
        for l in Leader.allCases {
            let order = picked.firstIndex(of: l.rawValue).map { "   #\($0 + 1)" } ?? ""
            let item = NSMenuItem(title: "\(l.name) (\(weapons[l] ?? ""))\(order)",
                                  action: #selector(togglePlaygroundVillain(_:)), keyEquivalent: "")
            item.target = self
            item.tag = l.rawValue
            item.state = picked.contains(l.rawValue) ? .on : .off
            pm.addItem(item)
        }
        pm.addItem(.separator())
        pm.addItem(disabled: "Agents — they join the first villain")
        for c in Companion.allCases {
            let item = NSMenuItem(title: c.name, action: #selector(togglePlaygroundAgent(_:)), keyEquivalent: "")
            item.target = self
            item.tag = c.rawValue
            item.state = playground != nil && playgroundAgents.contains(c.rawValue) ? .on : .off
            pm.addItem(item)
        }
        pm.addItem(.separator())
        let moodItem = NSMenuItem(title: "Villains Are…", action: nil, keyEquivalent: "")
        let mm = NSMenu()
        for (title, mood) in [("Working (fighting)", Mood.working), ("Thinking", .thinking),
                              ("Waiting for you", .waiting), ("Idle", .idle)] {
            let item = NSMenuItem(title: title, action: #selector(setPlaygroundMood(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mood.rawValue
            item.state = playgroundMood == mood ? .on : .off
            mm.addItem(item)
        }
        moodItem.submenu = mm
        pm.addItem(moodItem)
        pm.addItem(.separator())
        pm.addItem(action: "Add All Villains", #selector(addAllVillains), target: self)
        if playground != nil {
            pm.addItem(action: "Exit Playground", #selector(exitPlayground), target: self)
        }
        root.submenu = pm
        return root
    }

    private func enterPlayground() {
        if playground == nil {
            playground = []
            playgroundAgents = []
            demo = false
        }
    }

    @objc private func togglePlaygroundVillain(_ sender: NSMenuItem) {
        enterPlayground()
        if let i = playground!.firstIndex(of: sender.tag) { playground!.remove(at: i) } else { playground!.append(sender.tag) }
        refreshStatus()
    }

    @objc private func togglePlaygroundAgent(_ sender: NSMenuItem) {
        enterPlayground()
        if let i = playgroundAgents.firstIndex(of: sender.tag) { playgroundAgents.remove(at: i) } else { playgroundAgents.append(sender.tag) }
        refreshStatus()
    }

    @objc private func setPlaygroundMood(_ sender: NSMenuItem) {
        enterPlayground()
        playgroundMood = Mood(rawValue: sender.representedObject as? String ?? "") ?? .working
        refreshStatus()
    }

    @objc private func addAllVillains() {
        enterPlayground()
        for l in Leader.allCases where !playground!.contains(l.rawValue) { playground!.append(l.rawValue) }
        refreshStatus()
    }

    @objc private func exitPlayground() {
        playground = nil
        refreshStatus()
    }

    @objc private func toggleDemo() {
        playground = nil
        demo.toggle()
        demoStart = Date().timeIntervalSince1970
        refreshStatus()
    }

    @objc private func forgetIdle() {
        StatusStore.forgetIdleSessions()
        refreshStatus()
    }

    @objc private func resetPosition() {
        UserDefaults.standard.removeObject(forKey: "anchorX")
        UserDefaults.standard.removeObject(forKey: "anchorY")
        home = savedHome()
        relayout()
        snapActors()
    }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            alert("Couldn't change Launch at Login", error.localizedDescription)
        }
    }

    @objc private func installHooks() {
        do { try HookInstaller.install() } catch { alert("Couldn't install hooks", error.localizedDescription) }
    }

    @objc private func removeHooks() {
        do { try HookInstaller.uninstall() } catch { alert("Couldn't remove hooks", error.localizedDescription) }
    }

    @objc private func quit() { NSApp.terminate(nil) }

    private func alert(_ title: String, _ text: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = title
        a.informativeText = text
        a.runModal()
    }

    fileprivate var panelOrigin: NSPoint { panel.frame.origin }
}

private extension VaderMode {
    init(_ mood: Mood) {
        switch mood {
        case .idle: self = .idle
        case .thinking: self = .thinking
        case .working: self = .working
        case .waiting: self = .waiting
        }
    }
}

private extension NSMenu {
    func addItem(disabled title: String) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        addItem(item)
    }

    func addItem(action title: String, _ selector: Selector, target: AnyObject, on: Bool = false) {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        item.target = target
        item.state = on ? .on : .off
        addItem(item)
    }
}

final class OverlayView: NSView {
    weak var controller: OverlayController?

    override var isOpaque: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext, let controller else { return }
        ctx.clear(bounds)
        ctx.interpolationQuality = .none
        let o = controller.panelOrigin
        for item in controller.items {
            let r = item.rect.offsetBy(dx: -o.x, dy: -o.y)
            if let text = item.text {
                if item.boxed {
                    let box = NSBezierPath(roundedRect: r, xRadius: 4, yRadius: 4)
                    (item.agentBox ? NSColor(calibratedRed: 0.05, green: 0.10, blue: 0.24, alpha: 0.82 * item.alpha)
                                   : NSColor(white: 0.08, alpha: 0.82 * item.alpha)).setFill()
                    box.fill()
                    (item.agentBox ? NSColor(calibratedRed: 0.45, green: 0.65, blue: 1, alpha: 0.5 * item.alpha)
                                   : NSColor(white: 1, alpha: 0.35 * item.alpha)).setStroke()
                    box.lineWidth = 1
                    box.stroke()
                    let ts = text.size()
                    text.draw(in: NSRect(x: r.midX - ts.width / 2, y: r.midY - ts.height / 2, width: ts.width, height: ts.height))
                    continue
                }
                text.draw(at: r.origin)
                continue
            }
            guard let image = item.image else { continue }
            ctx.saveGState()
            ctx.setAlpha(item.alpha)
            if item.mirrored {
                ctx.translateBy(x: r.maxX, y: r.minY)
                ctx.scaleBy(x: -1, y: 1)
                ctx.draw(image, in: NSRect(origin: .zero, size: r.size))
            } else {
                ctx.draw(image, in: r)
            }
            ctx.restoreGState()
        }
    }

    override func mouseDown(with event: NSEvent) { controller?.beginDrag() }
    override func mouseDragged(with event: NSEvent) { controller?.continueDrag() }
    override func mouseUp(with event: NSEvent) { controller?.endDrag() }

    override func rightMouseDown(with event: NSEvent) {
        guard let controller else { return }
        NSMenu.popUpContextMenu(controller.menu(), with: event, for: self)
    }
}
