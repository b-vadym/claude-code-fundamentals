---
description: Show commit count by author for the last 30 days
allowed-tools: [Bash]
---

Run `git shortlog -sn --since="30 days ago"` and format the output as a markdown table with columns: Author, Commits.

If the repository has no commits in that range, return "(no commits in last 30 days)".
