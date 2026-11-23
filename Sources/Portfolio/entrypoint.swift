import Foundation
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        if CommandLine.arguments.contains("export") || CommandLine.arguments.contains("--export") {
            let workingDir = FileManager.default.currentDirectoryPath
            try StaticSiteExporter.export(workingDirectory: workingDir)
            return
        }

        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)
        do {
            try configure(app)
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}

func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let store = ContentStore(workingDirectory: app.directory.workingDirectory)
    try routes(app, store: store)
}
