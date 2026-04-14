# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Slidev presentation "Claude Code для розробників" — a ~65-slide deck in Ukrainian covering Claude Code installation, configuration, MCP, skills, plugins, IDE integrations, hooks, subagents, and RTK. All slide content is written in Ukrainian; preserve that language when editing or adding slides.

## Commands

```bash
npm run dev      # start Slidev dev server with auto-open (live reload)
npm run build    # build static site into dist/
npm run export   # export to PDF (requires playwright-chromium)
```

For slide authoring, the installed `slidev` plugin provides `/slidev:*` skills (add, edit, delete, move, diagram, visuals, preview, export, etc.). Prefer those over hand-editing slide numbering/ordering — they handle renumbering and cross-slide concerns.

## Structure

- `slides.md` — single-file source of truth for the whole deck. Slides are separated by `---` frontmatter blocks; the first block configures the deck (theme `seriph`, cover background, transitions, `mdc: true`, `lineNumbers: true`).
- `components/DocRef.vue` — custom Vue component rendering a small bottom-right documentation link on a slide. Used as `<DocRef url="..." label="..." />` inside slide bodies to cite the corresponding `code.claude.com/docs` page. When adding a slide that explains a Claude Code feature, include a `DocRef` pointing to the canonical docs page for that feature — this is a deliberate convention throughout the deck.
- `style.css` — global overrides (currently hides `#slidev-goto-dialog`).
- `dist/` — build output, not edited by hand.

## Conventions

- Slide-level frontmatter (`layout: cover`, `layout: section`, `transition: ...`, `hideInToc: true`) controls behavior — match the style of surrounding slides rather than inventing new layouts.
- Speaker notes go in HTML comments (`<!-- ... -->`) at the end of a slide and are written in Ukrainian.
- `<v-clicks>` is used for progressive reveals in bullet lists; keep that pattern when adding list-based content slides.
- Icons come from `@iconify-json/carbon` (available as `<carbon-* />` in Slidev).
