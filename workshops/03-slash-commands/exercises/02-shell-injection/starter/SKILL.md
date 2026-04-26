---
name: env-info
description: Print environment context (cwd, git branch, last commit, node version)
disable-model-invocation: true
allowed-tools: Bash(pwd) Bash(git *) Bash(node *) Bash(uname *)
---

# env-info

## Context

- Working directory: TODO replace with !`pwd`
- Current branch: TODO replace with !`git branch --show-current`
- Latest commit: TODO replace with !`git log -1 --oneline`
- Node version: TODO

## System

TODO: add a multi-line shell block here using ```! ... ```

## Your task

Summarise the environment in 3 bullet points and flag anything unusual (detached HEAD, missing node, dirty tree).
