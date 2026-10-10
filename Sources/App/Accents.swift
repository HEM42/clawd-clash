import AppKit

/// One accent colour per project, shared by a Claude and its agents so you can see who belongs to whom
/// even mid-fight. Handed out first-come-first-served without collisions among the projects on screen,
/// and remembered, so a project keeps its colour between launches.
enum Accents {
    static let palette: [NSColor] = [0xFF8A3D, 0x3DD6FF, 0xFF4FD8, 0x9BE84A, 0xFFD23D, 0xA57BFF, 0x2EE6B0, 0xFF6B6B]
        .map { NSColor(srgbRed: CGFloat(($0 >> 16) & 0xFF) / 255, green: CGFloat(($0 >> 8) & 0xFF) / 255,
                       blue: CGFloat($0 & 0xFF) / 255, alpha: 1) }

    private static var assigned: [String: Int] {
        get { UserDefaults.standard.dictionary(forKey: "accents") as? [String: Int] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: "accents") }
    }

    /// Assign colours for the projects currently on screen (call once per refresh), then look them up.
    static func update(visible projects: [String]) {
        var map = assigned
        var used = Set(projects.compactMap { map[$0] })
        for p in projects where !p.isEmpty {
            // Keep a remembered colour unless another visible project already holds it.
            if let i = map[p], projects.filter({ map[$0] == i }).count == 1 { continue }
            let free = (0..<palette.count).first { !used.contains($0) } ?? (abs(p.hashValue) % palette.count)
            map[p] = free
            used.insert(free)
        }
        if map != assigned { assigned = map }
    }

    static func color(for project: String) -> NSColor? {
        guard !project.isEmpty, let i = assigned[project] else { return nil }
        return palette[i % palette.count]
    }
}
