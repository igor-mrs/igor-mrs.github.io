import Vapor

private func htmlResponse(_ page: PageKind, lang: Language, store: ContentStore) throws -> Response {
    let profile = try store.loadProfile()
    let projects = try store.loadProjects()
    let html = HTMLRenderer.render(page: page, lang: lang, profile: profile, projects: projects)
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/html; charset=utf-8")
    return Response(status: .ok, headers: headers, body: .init(string: html))
}

func routes(_ app: Application, store: ContentStore) throws {
    // Portuguese routes
    app.get { _ async throws -> Response in
        try htmlResponse(.home, lang: .pt, store: store)
    }

    app.get("projetos") { _ async throws -> Response in
        try htmlResponse(.projects, lang: .pt, store: store)
    }

    app.get("sobre") { _ async throws -> Response in
        try htmlResponse(.about, lang: .pt, store: store)
    }

    // English routes
    app.get("en") { _ async throws -> Response in
        try htmlResponse(.home, lang: .en, store: store)
    }

    app.get("en", "projetos") { _ async throws -> Response in
        try htmlResponse(.projects, lang: .en, store: store)
    }

    app.get("en", "sobre") { _ async throws -> Response in
        try htmlResponse(.about, lang: .en, store: store)
    }

    // JSON API endpoint backed by Data/projects.json
    app.get("api", "projects") { _ async throws -> [Project] in
        try store.loadProjects()
    }
}
