---
name: git-bisect-helper
description: Use when the user wants to find which commit introduced
  a regression between two known commits (a good and a bad one).
argument-hint: [good-sha] [bad-sha]
arguments: [good, bad]
allowed-tools: [Bash]
---

# git-bisect-helper

Walk the user through `git bisect` to find the commit that introduced a regression.

## Process

1. Verify clean working tree:
   ```bash
   git status --porcelain
   ```
   If non-empty, ask user to commit or stash before bisecting.

2. Start bisect:
   ```bash
   git bisect start $bad $good
   ```

3. After each checkout, ask user to test the current commit and report `good` or `bad`.

4. Run `git bisect $verdict` based on user's answer.

5. When git reports the first bad commit, run:
   ```bash
   git bisect reset
   git show <first-bad-sha> --stat
   ```

6. Summarize: which commit, when, by whom, what files changed.
