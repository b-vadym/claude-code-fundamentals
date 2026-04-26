# Research: add caching layer to fetchUser

## Goal

Add a request-scoped cache for `fetchUser(id)` calls so repeated calls within a single HTTP request return the same object without redundant DB hits. The cache must not leak across requests.

## Current state (relevant files)

After Glob/Grep across the repo: **no `fetchUser` function and no `tests/users.spec.ts` were found**. This is a synthetic task and the codebase referenced in the task does not actually exist in this repo.

## Constraints / risks

- Must work in Node.js (no service worker)
- Per-request lifecycle — cleared automatically
- No new dependencies if stdlib pattern works
- Tests in `tests/users.spec.ts` must continue to pass

## Open questions for the planner

- Since the target code doesn't exist in the repo, should the plan be written hypothetically (as if the code existed) or should the planner refuse to plan?
- If hypothetical: what request-scoping mechanism should we assume? `AsyncLocalStorage` is the Node stdlib answer — that's likely the right pattern.
- If the team has an existing `requestContext` middleware, the cache should plug into it. We didn't find one but the planner should look once more.
