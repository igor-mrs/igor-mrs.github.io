#if !STATIC_EXPORT_ONLY
import Vapor
typealias PortfolioContent = Content
#else
import Foundation
typealias PortfolioContent = Codable
#endif

enum Language: String, Sendable {
    case pt
    case en
}

enum PageKind: Sendable {
    case home
    case projects
    case about
}

enum ProjectStatus: String, Codable, Sendable {
    case wip
    case live
    case prototype
}

struct LocalizedString: Codable, Sendable {
    let pt: String
    let en: String

    init(pt: String, en: String) {
        self.pt = pt
        self.en = en
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(),
           let plain = try? single.decode(String.self) {
            self.pt = plain
            self.en = plain
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pt = try container.decode(String.self, forKey: .pt)
        self.en = try container.decode(String.self, forKey: .en)
    }

    private enum CodingKeys: String, CodingKey {
        case pt, en
    }

    func value(for lang: Language) -> String {
        switch lang {
        case .pt: return pt
        case .en: return en
        }
    }
}

struct LocalizedParagraphs: Codable, Sendable {
    let pt: [String]
    let en: [String]

    func value(for lang: Language) -> [String] {
        switch lang {
        case .pt: return pt
        case .en: return en
        }
    }
}

struct ProjectLink: Codable, Sendable {
    let label: LocalizedString
    let url: String
}

struct Project: PortfolioContent, Sendable {
    let id: String
    let title: String
    let year: String
    let status: ProjectStatus
    let statusLabel: LocalizedString
    let platform: String
    let featured: Bool
    let iconUrl: String?
    let tagline: LocalizedString
    let description: LocalizedParagraphs
    let currentFocus: LocalizedString?
    let stack: [LocalizedString]
    let links: [ProjectLink]
}

struct HeroContent: Codable, Sendable {
    let eyebrow: LocalizedString
    let greeting: LocalizedString
    let lead: LocalizedString
    let secondary: LocalizedString
}

struct NowStripItem: Codable, Sendable {
    let place: String
    let role: LocalizedString
    let summary: LocalizedString
}

struct AboutContent: Codable, Sendable {
    let intro: LocalizedString
    let readmeBullets: LocalizedParagraphs
    let story: LocalizedParagraphs
}

struct ExperienceItem: Codable, Sendable {
    let period: LocalizedString
    let organization: String
    let role: LocalizedString
    let summary: LocalizedString
}

struct ToolGroup: Codable, Sendable {
    let category: LocalizedString
    let items: [LocalizedString]
}

struct Profile: PortfolioContent, Sendable {
    let name: String
    let fullName: String
    let handle: String
    let location: String
    let avatarUrl: String
    let email: String
    let githubUrl: String
    let linkedinUrl: String
    let hero: HeroContent
    let nowStrip: [NowStripItem]
    let about: AboutContent
    let experience: [ExperienceItem]
    let education: [ExperienceItem]
    let tools: [ToolGroup]
}
