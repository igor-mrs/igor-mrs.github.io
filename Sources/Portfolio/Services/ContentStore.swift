import Foundation
import Vapor

struct ContentStore: Sendable {
    let dataDirectory: String

    init(workingDirectory: String) {
        let base = workingDirectory.hasSuffix("/") ? String(workingDirectory.dropLast()) : workingDirectory
        self.dataDirectory = "\(base)/Data"
    }

    func loadProjects() throws -> [Project] {
        let url = URL(fileURLWithPath: "\(dataDirectory)/projects.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Project].self, from: data)
    }

    func loadProfile() throws -> Profile {
        let url = URL(fileURLWithPath: "\(dataDirectory)/profile.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Profile.self, from: data)
    }
}
