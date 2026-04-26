# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Slidev workshop series in Ukrainian. All decks share infrastructure (theme, components, styles, Slidev version) in a single repo and live under `workshops/NN-slug/`.

**Two legacy decks** (already presented — content frozen):

1. **"Claude Code: Fundamentals"** (`workshops/01-fundamentals/slides.md`) — ~159-slide overview deck covering installation, configuration, MCP, skills, plugins, IDE integrations, hooks, subagents, RTK. Published at GitHub Pages root: `/claude-code-fundamentals/`.
2. **"Claude Code: Економіка токенів"** (`workshops/02-token-economy/slides.md`) — ~102-slide deck on token saving for the $20 Pro budget. Published at `/claude-code-fundamentals/token-economy/`.

**Workshop series** (in progress, hands-on bias) — split into two branches of 5:

- *Extending Claude Code* — `03-slash-commands`, `04-skills`, `05-hooks`, `06-plugins`, `07-mcp-servers`
- *Claude Code in Production* — `08-headless-ci`, `09-agent-sdk`, `10-subagents-and-teams`, `11-security`, `12-debugging`

Each new workshop ships a triad: `slides.md` (~30–40 slides) + `exercises/` sub-repo + `handout.tex`/`handout.pdf`. Plan: `~/.claude/plans/2-lazy-unicorn.md`.

All slide content is in Ukrainian; preserve that language.

## Which deck am I editing?

Identify the deck by its full path. **Do not edit content of `01-fundamentals` or `02-token-economy`** — both are frozen (already presented). Only path-level changes (move, rename) are allowed for legacy decks; their slide content is canonical record.

If the user asks to "add a slide about X" without specifying, ask which workshop.

## Commands

```bash
npm run dev                 # 01-fundamentals dev server (port 3030)
npm run dev:economy         # 02-token-economy dev server (port 3031)
npm run build               # build all decks per workshops.config.json → dist/
npm run export              # PDF export of fundamentals
npm run export:economy      # PDF export of token-economy
```

Dev for any workshop: `npx slidev workshops/NN-slug/slides.md --open` (default port 3030 + auto-increments if busy).

**Build mechanics:** `scripts/build-all.mjs` reads `workshops.config.json` and runs `slidev build` per entry. Order in the manifest matters — first entry has `out: "dist"` (wipes it), rest write into subdirs.

## Slidev skill usage

The installed `slidev` plugin provides `/slidev:*` skills. **Always pass the full entry path** when invoking them — the repo has many `slides.md` files:

- `/slidev:add workshops/04-skills/slides.md 5`
- `/slidev:edit workshops/03-slash-commands/slides.md`

Do **not** invoke `/slidev:init` — infrastructure already in place.

## Deployment

`.github/workflows/deploy.yml` auto-deploys on push to `main`: runs `npm run build`, uploads full `dist/` tree to GitHub Pages. Summary step prints all deployed URLs from the manifest. No manual publish step.

## Structure

```
claude-code-developers/
├── components/                # shared by all decks (DocRef.vue + future)
├── style.css                  # shared global CSS
├── workshops/
│   ├── 01-fundamentals/       # slides.md (frozen) + symlinks
│   ├── 02-token-economy/      # slides.md (frozen) + symlinks
│   └── 03-… 12-…              # new workshops: slides.md + exercises/ + handout.tex + meta.json
├── workshops.config.json      # manifest: dir → {title, branch, base, out}
├── scripts/build-all.mjs      # reads manifest, runs slidev build
├── package.json
└── .github/workflows/deploy.yml
```

**Workshop dirs contain symlinks** `components → ../../components` and `style.css → ../../style.css` so Slidev (which resolves these relative to `dirname(entry)`) finds the shared infra. To add a new shared component: drop into root `components/`, every deck sees it. Symlinks committed to git work on Linux/Mac (target audience).

`components/DocRef.vue` — `<DocRef url="..." label="..." :offset="N" />`. Points to `code.claude.com/docs` pages — convention across decks. **Every slide explaining a Claude Code feature carries a `DocRef`.**

`dist/` — build output (gitignored). Layout after full build:
- `dist/index.html`, `dist/assets/*` → 01-fundamentals (root)
- `dist/token-economy/index.html` → 02-token-economy
- `dist/03-slash-commands/index.html` → workshop 03
- … etc per manifest

## Conventions

- Slide-level frontmatter (`layout: cover`, `layout: section`, `transition: ...`, `hideInToc: true`) — match surrounding slides rather than inventing new layouts.
- Speaker notes go in HTML comments (`<!-- ... -->`) at slide end, in Ukrainian.
- `<v-clicks>` for progressive reveals.
- Icons from `@iconify-json/carbon` (`<carbon-* />`).
- Per-workshop `handout.tex` is fine; the legacy fundamentals handout (uncommitted, at repo root) lives in `handout.tex` until moved.

## Base-path gotcha

`--base` per deck is set in `workshops.config.json`. When writing cross-deck links, use absolute URLs to the full deployed path or Slidev URL helpers. Avoid hard-coded `/assets/...` paths in slide content.

## Adding a new workshop (03–12)

1. `mkdir workshops/NN-slug`, add symlinks: `ln -s ../../components components`, `ln -s ../../style.css style.css`.
2. Add an entry to `workshops.config.json`: `{"dir":"NN-slug","title":"…","branch":"extending|production","base":"/claude-code-fundamentals/NN-slug/","out":"dist/NN-slug"}`.
3. Author `slides.md`, `exercises/`, `handout.tex`, `meta.json`.
4. `npm run build` to verify.
