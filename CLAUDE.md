# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Two Slidev presentations in Ukrainian, sharing infrastructure (theme, components, styles, Slidev version) in a single repo:

1. **"Claude Code: Fundamentals"** (`slides.md`) — ~65-slide deck covering Claude Code installation, configuration, MCP, skills, plugins, IDE integrations, hooks, subagents, RTK. Published at GitHub Pages root: `/claude-code-fundamentals/`.
2. **"Claude Code: Економіка токенів"** (`token-economy.md`) — deck on saving Claude Code tokens to fit a $20 Pro budget. Published at `/claude-code-fundamentals/token-economy/`.

All slide content is in Ukrainian; preserve that language when editing or adding slides.

## Which deck am I editing?

Before making changes, identify the deck by its entry file:
- `slides.md` → Fundamentals. URL: `https://b-vadym.github.io/claude-code-fundamentals/`.
- `token-economy.md` → Token Economy. URL: `https://b-vadym.github.io/claude-code-fundamentals/token-economy/`.

If the user asks to "add a slide about X" without specifying, ask which deck.

## Commands

```bash
npm run dev                 # fundamentals dev server (port 3030, auto-open)
npm run dev:economy         # token-economy dev server (port 3031, auto-open)
npm run build               # build both decks into dist/ (fundamentals FIRST, then economy)
npm run build:fundamentals  # fundamentals only → dist/
npm run build:economy       # economy only → dist/token-economy/
npm run export              # PDF export of fundamentals
npm run export:economy      # PDF export of token-economy
```

Both dev servers can run simultaneously on their respective ports.

**Build order matters**: `build:fundamentals` must run before `build:economy`. Fundamentals writes to bare `dist/` (wiping it); economy then writes into `dist/token-economy/`. Reversing order destroys the economy output.

## Slidev skill usage

For slide authoring, the installed `slidev` plugin provides `/slidev:*` skills (add, edit, delete, move, diagram, visuals, preview, export, etc.). **Always pass the explicit entry filename** when invoking them, because this repo has two `*.md` entry files at root:

- `/slidev:add token-economy.md 5` (not just `/slidev:add 5`)
- `/slidev:edit slides.md` (not just `/slidev:edit`)

Do **not** invoke `/slidev:init` — it scaffolds a fresh project. Infrastructure is already in place.

## Deployment

`.github/workflows/deploy.yml` auto-deploys on push to `main`: runs `build:fundamentals` then `build:economy`, uploads full `dist/` tree to GitHub Pages. No manual publish step. Fundamentals lands at repo Pages root; economy at `/token-economy/` subpath.

## Structure

- `slides.md` — Fundamentals deck (single-file). First `---`-delimited block sets theme, background, transitions, `mdc: true`, `lineNumbers: true`.
- `token-economy.md` — Token Economy deck. Same frontmatter conventions.
- `components/DocRef.vue` — **shared by both decks**. Renders a small bottom-right doc link: `<DocRef url="..." label="..." :offset="N" />`. Points to `code.claude.com/docs` pages — a deliberate convention throughout both decks. **Every slide that explains a Claude Code feature should carry a `DocRef`.**
- `style.css` — global CSS overrides shared by both decks.
- `dist/` — build output (gitignored). Layout after full build:
  - `dist/index.html`, `dist/assets/*` → fundamentals
  - `dist/token-economy/index.html`, `dist/token-economy/assets/*` → economy
- `handout.tex`, `handout.pdf` — fundamentals handout. If economy gets its own, name it `handout-token-economy.*` to avoid collision.

## Component & asset sharing

Slidev resolves `components/`, `style.css`, `public/` relative to `dirname(entry)`. Both entry files live at repo root → both decks share `components/` automatically. To add a new shared component, drop it into `components/` at root — both decks see it immediately.

## Conventions

- Slide-level frontmatter (`layout: cover`, `layout: section`, `transition: ...`, `hideInToc: true`) controls behavior — match surrounding slides rather than inventing new layouts.
- Speaker notes go in HTML comments (`<!-- ... -->`) at the end of a slide, in Ukrainian.
- `<v-clicks>` for progressive reveals in bullet lists.
- Icons from `@iconify-json/carbon` (available as `<carbon-* />`).

## Base-path gotcha

`--base /claude-code-fundamentals/` for fundamentals, `--base /claude-code-fundamentals/token-economy/` for economy. When writing cross-deck links, use absolute URLs to the full deployed path or rely on Slidev URL helpers. Avoid hard-coded `/assets/...` paths in slide content.
