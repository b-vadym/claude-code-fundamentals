---
name: bundle-size-check
description: Check bundle size
allowed-tools: [Bash, Read]
---

# Bundle Size Check

Run a build and analyze the JavaScript bundle size:

1. Run `npm run build` (or `pnpm build` / `yarn build` depending on the lockfile)
2. Locate the output dir (usually `dist/`, `build/`, or `out/`)
3. Report:
   - Total bundle size (gzipped if available)
   - Largest 5 chunks/files with size
   - Files >250 KB flagged as potential issues
4. Compare against previous build if `bundle-size.prev.txt` exists in the repo root

## Edge cases

- No build script → report and stop
- Empty output dir → likely build failed; surface the build error
- TypeScript errors → still try to compile; report partial output
