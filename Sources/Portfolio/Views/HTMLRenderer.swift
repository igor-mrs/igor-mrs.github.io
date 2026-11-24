import Foundation

struct HTMLRenderer: Sendable {
    private static func esc(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func routePath(page: PageKind, lang: Language) -> String {
        switch (lang, page) {
        case (.pt, .home): return "/"
        case (.pt, .projects): return "/projetos/"
        case (.pt, .about): return "/sobre/"
        case (.en, .home): return "/en/"
        case (.en, .projects): return "/en/projetos/"
        case (.en, .about): return "/en/sobre/"
        }
    }

    static func render(
        page: PageKind,
        lang: Language,
        profile: Profile,
        projects: [Project]
    ) -> String {
        let htmlLang = lang == .pt ? "pt-BR" : "en"
        let pageTitle = titleFor(page: page, lang: lang, profile: profile)
        let metaDesc = esc(profile.hero.lead.value(for: lang))

        let navHTML = renderHeader(page: page, lang: lang, profile: profile)
        let bodyHTML: String
        switch page {
        case .home:
            bodyHTML = renderHome(lang: lang, profile: profile, projects: projects)
        case .projects:
            bodyHTML = renderProjects(lang: lang, projects: projects)
        case .about:
            bodyHTML = renderAbout(lang: lang, profile: profile)
        }
        let footerHTML = renderFooter(lang: lang, profile: profile)

        return """
        <!doctype html>
        <html lang="\(htmlLang)" class="dark">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>\(esc(pageTitle))</title>
          <meta name="description" content="\(metaDesc)" />
          <script>
            (function () {
              var saved = localStorage.getItem('portfolio-theme');
              if (saved === 'light') document.documentElement.classList.remove('dark');
              else document.documentElement.classList.add('dark');
            })();
          </script>
          <link rel="preconnect" href="https://fonts.googleapis.com" />
          <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
          <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=Schibsted+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet" />
          <link rel="stylesheet" href="/styles/main.css" />
        </head>
        <body>
          <div class="scroll-progress" id="scroll-progress" aria-hidden="true"></div>
          \(navHTML)
          <main id="main-content" class="site-main">
            \(bodyHTML)
          </main>
          \(footerHTML)
          <script src="/scripts/main.js" defer></script>
        </body>
        </html>
        """
    }

    private static func titleFor(page: PageKind, lang: Language, profile: Profile) -> String {
        switch (lang, page) {
        case (.pt, .home): return "\(profile.name) — Engenharia de Computação & iOS"
        case (.pt, .projects): return "Projetos — \(profile.name)"
        case (.pt, .about): return "Sobre — \(profile.name)"
        case (.en, .home): return "\(profile.name) — Computer Engineering & iOS"
        case (.en, .projects): return "Projects — \(profile.name)"
        case (.en, .about): return "About — \(profile.name)"
        }
    }

    private static func renderHeader(page: PageKind, lang: Language, profile: Profile) -> String {
        let homeHref = routePath(page: .home, lang: lang)
        let projectsHref = routePath(page: .projects, lang: lang)
        let aboutHref = routePath(page: .about, lang: lang)

        let otherLang: Language = lang == .pt ? .en : .pt
        let langSwitchHref = routePath(page: page, lang: otherLang)
        let langSwitchLabel = lang == .pt ? "EN" : "PT"

        let homeLabel = lang == .pt ? "Início" : "Home"
        let projectsLabel = lang == .pt ? "Projetos" : "Projects"
        let aboutLabel = lang == .pt ? "Sobre" : "About"

        return """
        <header class="site-header">
          <div class="container header-inner">
            <a class="brand" href="\(homeHref)">
              <span class="brand-mark" aria-hidden="true"></span>
              <span class="brand-name">\(esc(profile.name))</span>
              <span class="brand-handle">@\(esc(profile.handle))</span>
            </a>

            <nav class="site-nav" aria-label="Principal">
              <a class="nav-link \(page == .home ? "is-active" : "")" href="\(homeHref)">\(homeLabel)</a>
              <a class="nav-link \(page == .projects ? "is-active" : "")" href="\(projectsHref)">\(projectsLabel)</a>
              <a class="nav-link \(page == .about ? "is-active" : "")" href="\(aboutHref)">\(aboutLabel)</a>
            </nav>

            <div class="header-controls">
              <a class="control-btn" href="\(langSwitchHref)" aria-label="Switch language">\(langSwitchLabel)</a>
              <button type="button" class="control-btn" id="theme-toggle" aria-label="Alternar tema">
                <span data-theme-label>Light</span>
              </button>
            </div>
          </div>
        </header>
        """
    }

    private static func renderHome(lang: Language, profile: Profile, projects: [Project]) -> String {
        let projectsHref = routePath(page: .projects, lang: lang)
        let aboutHref = routePath(page: .about, lang: lang)

        let wipProjects = projects.filter { $0.status == .wip }
        let archiveProjects = projects.filter { $0.status != .wip }

        let seeProjectsText = lang == .pt ? "Ver todos os projetos" : "View all projects"
        let aboutMeText = lang == .pt ? "Sobre mim & trajetória" : "About me & journey"
        let buildingTitle = lang == .pt ? "Construindo agora" : "Building now"
        let buildingSub = lang == .pt
            ? "O que estou desenvolvendo e estudando ativamente no momento."
            : "What I am actively building and studying right now."
        let allTitle = lang == .pt ? "Publicados & Concluídos" : "Shipped & Finished"
        let allSub = lang == .pt
            ? "Apps, sistemas web, oficinas e jogos já lançados ou concluídos."
            : "Apps, web tools, teaching workshops, and completed games."
        let openAllText = lang == .pt ? "Abrir página completa de projetos" : "Open full projects page"
        let focusPrefix = lang == .pt ? "Agora:" : "Focus:"

        let nowItemsHTML = profile.nowStrip.enumerated().map { index, item in
            let delay = index * 60
            return """
            <div class="now-cell" data-reveal="up" data-delay="\(delay)">
              <div class="now-place">\(esc(item.place))</div>
              <div class="now-role">\(esc(item.role.value(for: lang)))</div>
              <p class="now-summary">\(esc(item.summary.value(for: lang)))</p>
            </div>
            """
        }.joined(separator: "\n")

        let wipCardsHTML = wipProjects.enumerated().map { index, project in
            let delay = index * 70
            let stackPreview = project.stack.prefix(4).map { esc($0.value(for: lang)) }.joined(separator: " · ")
            let iconHTML = project.iconUrl.map { url in
                "<img class=\"wip-icon\" src=\"\(esc(url))\" alt=\"\" width=\"32\" height=\"32\" loading=\"lazy\" />"
            } ?? ""
            let focusBlock = project.currentFocus.map { focus in
                """
                <p class="wip-focus"><span>\(focusPrefix)</span> \(esc(focus.value(for: lang)))</p>
                """
            } ?? ""

            return """
            <a class="wip-card" href="\(projectsHref)#\(esc(project.id))" data-reveal="up" data-delay="\(delay)">
              <div class="wip-top">
                <span class="status-pill"><span class="status-dot is-wip"></span>\(esc(project.statusLabel.value(for: lang)))</span>
                <span class="mono-meta">\(esc(project.platform))</span>
              </div>
              <div class="wip-title-row">
                \(iconHTML)
                <h3 class="wip-title">\(esc(project.title)) <span class="arrow-shift">→</span></h3>
              </div>
              <p class="wip-tagline">\(esc(project.tagline.value(for: lang)))</p>
              \(focusBlock)
              <div class="wip-stack mono-meta">\(stackPreview)</div>
            </a>
            """
        }.joined(separator: "\n")

        let archiveRowsHTML = archiveProjects.enumerated().map { index, project in
            let delay = index * 45
            let stackText = project.stack.prefix(3).map { esc($0.value(for: lang)) }.joined(separator: ", ")
            let iconHTML = project.iconUrl.map { url in
                "<img class=\"row-icon\" src=\"\(esc(url))\" alt=\"\" width=\"24\" height=\"24\" loading=\"lazy\" />"
            } ?? ""

            return """
            <a class="project-row" href="\(projectsHref)#\(esc(project.id))" data-reveal="up" data-delay="\(delay)">
              <div class="row-year mono-meta">\(esc(project.year))</div>
              <div class="row-main">
                <div class="row-title-wrap">
                  \(iconHTML)
                  <span class="row-title">\(esc(project.title))</span>
                </div>
                <p class="row-tagline">\(esc(project.tagline.value(for: lang)))</p>
              </div>
              <div class="row-stack mono-meta">\(stackText)</div>
              <div class="row-status">
                <span class="mono-meta">\(esc(project.statusLabel.value(for: lang)))</span>
                <span class="arrow-shift" aria-hidden="true">→</span>
              </div>
            </a>
            """
        }.joined(separator: "\n")

        return """
        <section class="hero-section">
          <div class="container">
            <div class="hero-grid">
              <div class="hero-copy">
                <h1 class="hero-title" data-reveal="up" data-delay="0">\(esc(profile.hero.greeting.value(for: lang)))</h1>
                <p class="hero-role" data-reveal="up" data-delay="30">\(esc(profile.hero.eyebrow.value(for: lang)))</p>
                <p class="hero-lead" data-reveal="up" data-delay="60">\(esc(profile.hero.lead.value(for: lang)))</p>
                <p class="hero-secondary" data-reveal="up" data-delay="90">\(esc(profile.hero.secondary.value(for: lang)))</p>
                <div class="hero-actions" data-reveal="up" data-delay="120">
                  <a class="btn-primary" href="\(projectsHref)">\(seeProjectsText) <span class="arrow-shift">→</span></a>
                  <a class="btn-secondary" href="\(aboutHref)">\(aboutMeText)</a>
                </div>
              </div>

              <div class="hero-photo-wrap" data-reveal="up" data-delay="60">
                <img class="hero-photo" src="\(esc(profile.avatarUrl))" alt="\(esc(profile.fullName))" width="220" height="220" loading="eager" />
                <div class="hero-photo-caption mono-meta">
                  <span>\(esc(profile.fullName))</span>
                  <span>\(esc(profile.location))</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="now-strip-section" aria-label="Atuação atual">
          <div class="container">
            <div class="now-grid">
              \(nowItemsHTML)
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(buildingTitle)</h2>
                <p class="section-subtitle">\(buildingSub)</p>
              </div>
            </div>
            <div class="wip-grid">
              \(wipCardsHTML)
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(allTitle)</h2>
                <p class="section-subtitle">\(allSub)</p>
              </div>
              <a class="section-link" href="\(projectsHref)">\(openAllText) <span class="arrow-shift">→</span></a>
            </div>

            <div class="project-table">
              \(archiveRowsHTML)
            </div>
          </div>
        </section>
        """
    }

    private static func renderProjects(lang: Language, projects: [Project]) -> String {
        let title = lang == .pt ? "Projetos" : "Projects"
        let intro = lang == .pt
            ? "Tudo o que venho construindo, estudando ou já coloquei no ar — sem separar por caixinhas. Os dados vêm direto de Data/projects.json."
            : "Everything I have been building, studying, or already shipped — kept together in one place. Backed directly by Data/projects.json."

        let filterAll = lang == .pt ? "Todos" : "All"
        let filterWip = lang == .pt ? "Construindo agora" : "In progress"
        let filterLive = lang == .pt ? "Publicados & Concluídos" : "Shipped & Finished"
        let filterProto = lang == .pt ? "Protótipos" : "Prototypes"
        let protoCount = projects.filter { $0.status == .prototype }.count
        let protoButtonHTML = protoCount > 0
            ? "<button type=\"button\" class=\"filter-btn\" data-filter=\"prototype\">\(filterProto) <span>\(protoCount)</span></button>"
            : ""

        let currentFocusHeading = lang == .pt ? "Em andamento" : "Current focus"
        let stackHeading = "Stack"
        let platformHeading = lang == .pt ? "Onde roda" : "Platform"

        let entriesHTML = projects.enumerated().map { index, project in
            let delay = (index % 3) * 50
            let dotClass = project.status == .wip ? "is-wip" : "is-live"

            let iconHTML = project.iconUrl.map { url in
                "<img class=\"entry-icon\" src=\"\(esc(url))\" alt=\"\" width=\"36\" height=\"36\" loading=\"lazy\" />"
            } ?? ""

            let paragraphsHTML = project.description.value(for: lang).map { p in
                "<p>\(esc(p))</p>"
            }.joined(separator: "\n")

            let focusHTML = project.currentFocus.map { focus in
                """
                <div class="entry-focus">
                  <span class="focus-label">\(currentFocusHeading)</span>
                  <p>\(esc(focus.value(for: lang)))</p>
                </div>
                """
            } ?? ""

            let stackTagsHTML = project.stack.map { tech in
                "<span class=\"stack-item\">\(esc(tech.value(for: lang)))</span>"
            }.joined(separator: "\n")

            let linksHTML = project.links.map { link in
                """
                <a class="entry-link" href="\(esc(link.url))" target="_blank" rel="noopener noreferrer">
                  \(esc(link.label.value(for: lang))) <span class="arrow-shift">↗</span>
                </a>
                """
            }.joined(separator: "\n")

            return """
            <article class="project-entry" id="\(esc(project.id))" data-status="\(project.status.rawValue)" data-reveal="up" data-delay="\(delay)">
              <div class="entry-aside">
                <div class="entry-meta-line">
                  <span class="mono-meta">\(esc(project.year))</span>
                  <span class="status-pill"><span class="status-dot \(dotClass)"></span>\(esc(project.statusLabel.value(for: lang)))</span>
                </div>

                <div class="entry-title-row">
                  \(iconHTML)
                  <h2 class="entry-title">\(esc(project.title))</h2>
                </div>

                <div class="entry-facts">
                  <div class="fact-row">
                    <span class="fact-key">\(platformHeading)</span>
                    <span class="fact-val">\(esc(project.platform))</span>
                  </div>
                  <div class="fact-row">
                    <span class="fact-key">\(stackHeading)</span>
                    <div class="stack-list">
                      \(stackTagsHTML)
                    </div>
                  </div>
                </div>

                \(linksHTML.isEmpty ? "" : "<div class=\"entry-links\">\(linksHTML)</div>")
              </div>

              <div class="entry-content">
                <p class="entry-tagline">\(esc(project.tagline.value(for: lang)))</p>
                <div class="entry-prose">
                  \(paragraphsHTML)
                </div>
                \(focusHTML)
              </div>
            </article>
            """
        }.joined(separator: "\n")

        return """
        <section class="page-head">
          <div class="container">
            <h1 class="page-heading" data-reveal="up">\(title)</h1>
            <p class="page-intro" data-reveal="up" data-delay="60">\(intro)</p>

            <div class="filter-bar" role="tablist" aria-label="Filtrar projetos" data-reveal="up" data-delay="110">
              <button type="button" class="filter-btn is-active" data-filter="all">\(filterAll) <span>\(projects.count)</span></button>
              <button type="button" class="filter-btn" data-filter="wip">\(filterWip) <span>\(projects.filter { $0.status == .wip }.count)</span></button>
              <button type="button" class="filter-btn" data-filter="live">\(filterLive) <span>\(projects.filter { $0.status == .live }.count)</span></button>
              \(protoButtonHTML)
            </div>
          </div>
        </section>

        <section class="projects-list-section">
          <div class="container">
            <div class="projects-stack" id="projects-stack">
              \(entriesHTML)
            </div>
          </div>
        </section>
        """
    }

    private static func renderAbout(lang: Language, profile: Profile) -> String {
        let title = lang == .pt ? "Sobre" : "About"
        let readmeTitle = lang == .pt ? "// sobre mim" : "// about me"
        let expTitle = lang == .pt ? "Experiência & Projetos" : "Work & Projects"
        let expSub = lang == .pt
            ? "Estágios, bolsas de pesquisa/extensão e atuação prática."
            : "Internships, fellowships, and hands-on engineering."
        let eduTitle = lang == .pt ? "Formação Acadêmica" : "Academic Education"
        let eduSub = lang == .pt
            ? "Graduação e formação técnica."
            : "University degree and technical high school."
        let toolsTitle = lang == .pt ? "Ferramentas & Stack" : "Tools & Stack"
        let contactTitle = lang == .pt ? "Contato" : "Get in touch"

        let readmeBulletsHTML = profile.about.readmeBullets.value(for: lang).map { bullet in
            "<li>\(esc(bullet))</li>"
        }.joined(separator: "\n")

        let storyHTML = profile.about.story.value(for: lang).map { p in
            "<p>\(esc(p))</p>"
        }.joined(separator: "\n")

        let expHTML = profile.experience.enumerated().map { index, item in
            let delay = index * 50
            return """
            <div class="exp-item" data-reveal="up" data-delay="\(delay)">
              <div class="exp-period mono-meta">\(esc(item.period.value(for: lang)))</div>
              <div class="exp-body">
                <h3 class="exp-role">\(esc(item.role.value(for: lang)))</h3>
                <div class="exp-org">\(esc(item.organization))</div>
                <p class="exp-summary">\(esc(item.summary.value(for: lang)))</p>
              </div>
            </div>
            """
        }.joined(separator: "\n")

        let eduHTML = profile.education.enumerated().map { index, item in
            let delay = index * 60
            return """
            <article class="edu-card" data-reveal="up" data-delay="\(delay)">
              <div class="edu-period mono-meta">\(esc(item.period.value(for: lang)))</div>
              <h3 class="edu-role">\(esc(item.role.value(for: lang)))</h3>
              <div class="edu-org">\(esc(item.organization))</div>
              <p class="edu-summary">\(esc(item.summary.value(for: lang)))</p>
            </article>
            """
        }.joined(separator: "\n")

        let toolsHTML = profile.tools.enumerated().map { index, group in
            let delay = index * 50
            let itemsHTML = group.items.map { item in
                "<li>\(esc(item.value(for: lang)))</li>"
            }.joined(separator: "\n")

            return """
            <div class="tool-group" data-reveal="up" data-delay="\(delay)">
              <h3 class="tool-category">\(esc(group.category.value(for: lang)))</h3>
              <ul class="tool-items">
                \(itemsHTML)
              </ul>
            </div>
            """
        }.joined(separator: "\n")

        return """
        <section class="page-head">
          <div class="container">
            <div class="about-top" data-reveal="up">
              <img class="about-avatar" src="\(esc(profile.avatarUrl))" alt="\(esc(profile.fullName))" width="76" height="76" />
              <div>
                <h1 class="page-heading">\(title)</h1>
                <p class="about-subline">\(esc(profile.fullName)) · \(esc(profile.location))</p>
              </div>
            </div>
            <p class="page-intro mono-intro" data-reveal="up" data-delay="60">\(esc(profile.about.intro.value(for: lang)))</p>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="about-overview-grid">
              <div class="readme-block" data-reveal="up">
                <h2 class="readme-heading">\(readmeTitle)</h2>
                <ul class="readme-list">
                  \(readmeBulletsHTML)
                </ul>
              </div>
              <div class="about-story" data-reveal="up" data-delay="70">
                \(storyHTML)
              </div>
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(expTitle)</h2>
                <p class="section-subtitle">\(expSub)</p>
              </div>
            </div>
            <div class="exp-list">
              \(expHTML)
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(eduTitle)</h2>
                <p class="section-subtitle">\(eduSub)</p>
              </div>
            </div>
            <div class="edu-grid">
              \(eduHTML)
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(toolsTitle)</h2>
              </div>
            </div>
            <div class="tools-grid">
              \(toolsHTML)
            </div>
          </div>
        </section>

        <section class="section-block">
          <div class="container section-divider">
            <div class="section-head" data-reveal="up">
              <div>
                <h2 class="section-title">\(contactTitle)</h2>
              </div>
            </div>
            <div class="contact-links" data-reveal="up" data-delay="60">
              <a class="contact-card" href="\(esc(profile.githubUrl))" target="_blank" rel="noopener noreferrer">
                <span class="contact-label">GitHub</span>
                <span class="contact-val">@\(esc(profile.handle)) <span class="arrow-shift">↗</span></span>
              </a>
              <a class="contact-card" href="\(esc(profile.linkedinUrl))" target="_blank" rel="noopener noreferrer">
                <span class="contact-label">LinkedIn</span>
                <span class="contact-val">igor-morais-do-amaral <span class="arrow-shift">↗</span></span>
              </a>
              <a class="contact-card" href="mailto:\(esc(profile.email))">
                <span class="contact-label">E-mail</span>
                <span class="contact-val">\(esc(profile.email))</span>
              </a>
            </div>
          </div>
        </section>
        """
    }

    private static func renderFooter(lang: Language, profile: Profile) -> String {
        let builtWith = lang == .pt
            ? "Feito em Swift + Vapor · \(profile.location)"
            : "Built with Swift + Vapor · \(profile.location)"

        return """
        <footer class="site-footer">
          <div class="container footer-inner">
            <div class="footer-note">\(esc(builtWith))</div>
            <div class="footer-links">
              <a href="\(esc(profile.githubUrl))" target="_blank" rel="noopener noreferrer">GitHub</a>
              <a href="\(esc(profile.linkedinUrl))" target="_blank" rel="noopener noreferrer">LinkedIn</a>
              <a href="mailto:\(esc(profile.email))">\(esc(profile.email))</a>
            </div>
          </div>
        </footer>
        """
    }
}
