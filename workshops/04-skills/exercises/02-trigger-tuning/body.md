---
name: bundle-size-check
description: PLACEHOLDER — replace with one of A/B/C frontmatter
allowed-tools: [Bash]
---

# bundle-size-check

Run `du -sh dist/` and report total size. Then break down top 5 files:

```bash
du -ah dist/ | sort -rh | head -5
```

If a `dist-prev/` exists (previous build), compare totals:

```bash
prev=$(du -sb dist-prev | cut -f1)
curr=$(du -sb dist | cut -f1)
echo "Δ: $((curr - prev)) bytes"
```

Highlight files >500 KB.
