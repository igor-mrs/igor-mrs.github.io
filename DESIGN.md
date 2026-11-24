# Design System & Tokens — Portfólio Igor Amaral (`igor-mrs`)

Este documento define os tokens visuais estritos do portfólio. Toda estilização em [`Public/styles/main.css`](Public/styles/main.css) utiliza exclusivamente estas variáveis.

---

## 1. Tipografia

Sem `Inter`, `Roboto`, `Arial` ou `Plus Jakarta Sans` como fonte principal.

| Papel | Família | Pesos Carregados | Variável CSS | Uso |
| :--- | :--- | :--- | :--- | :--- |
| **Sans (Prosa & Títulos)** | `Schibsted Grotesk` | `400`, `500`, `600`, `700` | `--font-sans` | Títulos, narrativa, descrições de projetos e navegação |
| **Mono (Metadados & Código)** | `IBM Plex Mono` | `400`, `500`, `600` | `--font-mono` | Anos, assinatura `{em construção}`, stack, plataformas e `// sobre mim` |

### Escala Tipográfica (6 Degraus Fixos)

| Token | Valor | Line-Height | Uso |
| :--- | :--- | :--- | :--- |
| `--text-xs` | `0.75rem` (`12px`) | `1.4` | Metadados compactos, tags de stack, anos e rótulos técnicos |
| `--text-sm` | `0.875rem` (`14px`) | `1.5` | Links de navegação, botões, resumos curtos de tabela e legendas |
| `--text-base` | `1rem` (`16px`) | `1.65` | Corpo de texto padrão, parágrafos de projetos e itens do `// sobre mim` |
| `--text-lg` | `1.1875rem` (`19px`) | `1.55` | Lead do Hero, taglines de projetos em destaque e títulos de card |
| `--text-xl` | `1.5rem` (`24px`) | `1.25` | Títulos de seção (`h2`) e títulos de projeto na página `/projetos/` |
| `--text-display` | `clamp(2.25rem, 3.8vw, 3.125rem)` | `1.08` | Título principal da página (`h1`) |

- **Medida de leitura (`--measure-prose`):** `64ch`
- **Quebra de linha:** `text-wrap: balance` em títulos (`h1`, `h2`, `h3`) e `text-wrap: pretty` em parágrafos.

---

## 2. Paleta Estrita (Máximo de 4 Cores Base)

A paleta inteira é composta por **4 cores base** (2 superfícies + 2 tintas), com contraste verificado acima do piso WCAG AA (`>= 4.5:1` para texto normal e `>= 3:1` para elementos gráficos/texto grande). Bordas e textos secundários são derivados por composição (`color-mix`) dessas 4 cores.

| Token | Papel | Dark Mode (Padrão) | Light Mode | Contraste com Fundo |
| :--- | :--- | :--- | :--- | :--- |
| `--color-bg` | Fundo principal da página (Papel/Carvão) | `#0E1013` | `#F6F5F2` | — |
| `--color-surface` | Superfície elevada de cards e faixas | `#171B21` | `#EAE7E0` | — |
| `--color-ink` | Tinta principal (títulos e leitura) | `#F2F0EC` | `#141619` | `15.4:1` (Dark) / `16.4:1` (Light) |
| `--color-accent` | Acento técnico (terracota queimado) | `#E88464` | `#9E331B` | `7.1:1` (Dark) / `6.6:1` (Light) |

### Derivações Semânticas (a partir das 4 cores)
- `--color-ink-muted`: `color-mix(in srgb, var(--color-ink) 74%, var(--color-bg))` (`>= 7.5:1` sobre `--color-bg` e `>= 6.5:1` sobre `--color-surface`).
- `--color-border`: `color-mix(in srgb, var(--color-ink) 14%, var(--color-bg))`
- `--color-border-strong`: `color-mix(in srgb, var(--color-ink) 28%, var(--color-bg))`
- `--color-accent-tint`: `color-mix(in srgb, var(--color-accent) 12%, var(--color-surface))`

---

## 3. Escala de Espaçamento e Layout

Baseada em progressão modular (`4px` / `8px`):

| Token | Valor | Equivalente (`px`) | Uso Típico |
| :--- | :--- | :--- | :--- |
| `--space-1` | `0.25rem` | `4px` | Micro-ajustes e gaps entre badges |
| `--space-2` | `0.5rem` | `8px` | Padding interno de tags e botões compactos |
| `--space-3` | `0.75rem` | `12px` | Espaçamento entre linhas de metadados e células internas |
| `--space-4` | `1rem` | `16px` | Padding interno mínimo de linhas e itens com borda |
| `--space-5` | `1.5rem` | `24px` | Padding interno padrão de cards e células da faixa *Agora* |
| `--space-6` | `2rem` | `32px` | Gap entre colunas de cards e separação entre cabeçalho de seção e conteúdo |
| `--space-7` | `3rem` | `48px` | Padding vertical de entradas de projeto e separação interna de blocos |
| `--space-8` | `4.5rem` | `72px` | Ritmo vertical entre seções principais |
| `--space-9` | `6rem` | `96px` | Respiro superior do Hero |

- **Largura máxima do container (`--container-max`):** `1060px`
- **Raio de borda (`--radius-sm`, `--radius-md`):** `6px` e `10px`
