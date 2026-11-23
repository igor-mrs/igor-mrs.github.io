# Planejamento do Portfólio — Igor Morais do Amaral (`igor-mrs`)

> **Arquitetura:** Aplicação **Swift + Vapor** alimentada por JSON (`Data/projects.json` e `Data/profile.json`) com comando de exportação estática (`swift run Portfolio export`) para rodar no **GitHub Pages** (`igor-mrs.github.io`) sem depender de servidor sempre ligado.

---

## 1. Visual e Filosofia

- **Design próprio (Swiss Grid Contemporâneo — Slate & Terracotta):**
  - **Tipografia:** `Plus Jakarta Sans` (leitura e títulos) + `JetBrains Mono` (anos, plataformas e stack).
  - **Paleta:** Carvão `#0D0F12` com acento Terracotta `#E06D53` no tema escuro (padrão), e Stone `#F4F5F7` no tema claro.
  - **Sem clichês:** sem janelas falsas de código, sem nuvens de pills coloridas, sem coluna esquerda pontilhada copiada de terceiros.
- **Projetos são projetos:** todos os projetos ficam juntos na mesma estrutura (`Data/projects.json`), diferenciados apenas pelo estágio (`wip`, `live`, `prototype`).
- **Interações e scroll:** barra de progresso de scroll no topo, entrada suave dos blocos via `IntersectionObserver` (`[data-reveal]`) e filtro instantâneo em `/projetos`.

---

## 2. Páginas Separadas

1. **Início (`/` e `/en/`):** apresentação direta em 1ª pessoa, faixa "Agora" em 3 colunas (`Apple Developer Academy | PUC-Rio`, `GameLab UERJ`, `UERJ`), bloco **Construindo agora** (projetos com `status: "wip"`) e lista dos projetos publicados/protótipos.
2. **Projetos (`/projetos/` e `/en/projetos/`):** barra de filtro (`Todos`, `Construindo agora`, `Publicados / No ar`, `Protótipos`) e layout assimétrico de 2 colunas por projeto (ficha técnica + relato em prosa + bloco de foco atual quando em andamento).
3. **Sobre (`/sobre/` e `/en/sobre/`):** história pessoal, trajetória/experiência, ferramentas por categoria e contatos.

---

## 3. Como Atualizar Projetos Sem Mexer no Código Swift

1. Abra [`Data/projects.json`](Data/projects.json).
2. Adicione um novo objeto JSON seguindo o padrão dos demais (`id`, `title`, `year`, `status`, `statusLabel`, `platform`, `tagline`, `description`, `currentFocus`, `stack`, `links`).
3. Ao rodar o Vapor localmente (`swift run`), o servidor lê o arquivo na hora; ao dar push no GitHub, o workflow [`.github/workflows/deploy-pages.yml`](.github/workflows/deploy-pages.yml) compila e publica `dist/` no GitHub Pages.
