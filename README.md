# Portfólio — Igor Morais do Amaral

Aplicação **Swift + Vapor** alimentada por arquivos JSON (`Data/projects.json` e `Data/profile.json`), com exportação estática integrada para **GitHub Pages** (`igor-mrs.github.io`).

## Como rodar o servidor Vapor localmente

```bash
swift run
```

Acesse `http://localhost:8080`.

Rotas disponíveis:
- `/` — Início (PT)
- `/projetos` — Todos os projetos com filtro por estado (PT)
- `/sobre` — Trajetória, ferramentas e contato (PT)
- `/en`, `/en/projetos`, `/en/sobre` — Versão em inglês
- `/api/projects` — Lista dos projetos em JSON

## Como adicionar ou editar projetos

Edite [`Data/projects.json`](Data/projects.json). Cada item suporta:
- `status`: `"wip"` (aparece em **Construindo agora**), `"live"` (publicado / no ar) ou `"prototype"`.
- `currentFocus`: texto opcional destacando o que está sendo feito no momento.
- `stack`, `platform`, `description` (`pt` e `en`) e `links`.

Como o Vapor lê `Data/projects.json` do disco a cada requisição, basta salvar o JSON e recarregar o navegador.

## Exportar estático para GitHub Pages

```bash
swift run Portfolio export
```

Gera a pasta `dist/` pronta para deploy estático. O workflow [deploy-pages.yml](.github/workflows/deploy-pages.yml) automatiza esse processo no GitHub Actions.
