import Foundation
#if !STATIC_EXPORT_ONLY
import Vapor
#endif

@main
enum Entrypoint {
    static func main() async throws {
        #if STATIC_EXPORT_ONLY
        let workingDir = FileManager.default.currentDirectoryPath
        try StaticSiteExporter.export(workingDirectory: workingDir)
        #else
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
        #endif
    }
}

#if !STATIC_EXPORT_ONLY
func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    let store = ContentStore(workingDirectory: app.directory.workingDirectory)
    try routes(app, store: store)
}
#endif
