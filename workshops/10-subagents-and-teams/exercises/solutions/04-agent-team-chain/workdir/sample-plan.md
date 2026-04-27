# Plan: add caching layer to fetchUser (hypothetical)

## Approach

Use Node's `AsyncLocalStorage` to maintain a per-request `Map<userId, User>`. Store created when the request enters the API handler, destroyed when it leaves. `fetchUser(id)` checks the map first, falls back to the DB, populates on miss.

This is the stdlib pattern; no new dependencies.

## Steps

1. **Add request-context module** — files: `src/lib/request-context.ts`. Done when: exports `runWithRequestContext(req, handler)` and `getRequestStore()` returning the per-request Map.
2. **Wire into HTTP entry** — files: `src/app.ts` (middleware). Done when: every incoming request runs inside `runWithRequestContext`.
3. **Patch `fetchUser`** — files: `src/users/fetchUser.ts`. Done when: function consults `getRequestStore()` first, populates on DB-miss.
4. **Add tests** — files: `tests/users.spec.ts`. Done when: spec covers (a) repeated calls in one request hit DB once, (b) different requests do not share cache.
5. **Verify existing tests pass** — Done when: `npm test` is green.

## Risks

- `AsyncLocalStorage` perf overhead in hot paths → mitigation: benchmark before/after, accept ≤5% overhead.
- Memory leak if request handler throws and store isn't cleaned → mitigation: use `runWithRequestContext`'s try/finally.
- Cache poisoning if a write to user lands while request is in flight → mitigation: cache by request ID + user ID, never reuse stale entries across writes.

## Out of scope

- Cross-request caching (would need Redis or similar)
- Cache invalidation on user updates
- Background-job context (no HTTP request)
