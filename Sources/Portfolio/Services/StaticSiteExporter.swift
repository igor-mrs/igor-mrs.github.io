import Foundation

struct StaticSiteExporter: Sendable {
    static func export(workingDirectory: String) throws {
        let fm = FileManager.default
        let base = workingDirectory.hasSuffix("/") ? String(workingDirectory.dropLast()) : workingDirectory
        let distDir = URL(fileURLWithPath: "\(base)/dist", isDirectory: true)
        let publicDir = URL(fileURLWithPath: "\(base)/Public", isDirectory: true)

        if fm.fileExists(atPath: distDir.path) {
            try fm.removeItem(at: distDir)
        }
        try fm.createDirectory(at: distDir, withIntermediateDirectories: true)

        let store = ContentStore(workingDirectory: base)
        let profile = try store.loadProfile()
        let projects = try store.loadProjects()

        let pages: [(String, PageKind, Language)] = [
            ("index.html", .home, .pt),
            ("projetos/index.html", .projects, .pt),
            ("sobre/index.html", .about, .pt),
            ("en/index.html", .home, .en),
            ("en/projetos/index.html", .projects, .en),
            ("en/sobre/index.html", .about, .en),
        ]

        for (relativePath, page, lang) in pages {
            let target = distDir.appendingPathComponent(relativePath)
            try fm.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            let html = HTMLRenderer.render(page: page, lang: lang, profile: profile, projects: projects)
            try html.write(to: target, atomically: true, encoding: .utf8)
        }

        // Write static /api/projects.json
        let apiDir = distDir.appendingPathComponent("api", isDirectory: true)
        try fm.createDirectory(at: apiDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(projects)
        try jsonData.write(to: apiDir.appendingPathComponent("projects.json"))

        // Write .nojekyll for GitHub Pages
        try Data().write(to: distDir.appendingPathComponent(".nojekyll"))

        // Copy Public/ files to dist/
        if fm.fileExists(atPath: publicDir.path) {
            let contents = try fm.contentsOfDirectory(at: publicDir, includingPropertiesForKeys: nil)
            for item in contents {
                let dest = distDir.appendingPathComponent(item.lastPathComponent)
                try fm.copyItem(at: item, to: dest)
            }
        }

        print("Exported static portfolio to \(distDir.path)")
    }
}
