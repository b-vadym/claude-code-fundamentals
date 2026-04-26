# Review: add caching layer to fetchUser

## Overall verdict

approve with changes

## Critical issues (must fix before implementation)

- **Plan ignores the missing-codebase finding from research.** The research note flagged that `fetchUser` doesn't exist in this repo. The plan proceeds as if it does. Before implementation, the team must confirm whether this is a hypothetical exercise or the wrong repo.
- **Step 1's done-criterion doesn't cover error handling.** What happens if `runWithRequestContext` is invoked from a path that already has a context? The plan should specify either nesting behavior or an error.

## Suggestions (consider)

- The risk "AsyncLocalStorage perf overhead" cites ≤5% as acceptable but doesn't say how it's measured. Add a concrete benchmark target (e.g., p95 latency on `/users/:id` endpoint).
- Step 3 patches `fetchUser` directly — consider a thin wrapper (`fetchUserCached`) so the un-cached version stays available for tests and admin paths.
- "Cache poisoning" mitigation says "never reuse stale entries across writes" but the plan has no write path. Either drop the risk or add an invalidation mechanism (which would push it out-of-scope, which is also fine).

## Coverage check

- Constraint "must work in Node.js" → addressed (AsyncLocalStorage is stdlib): yes
- Constraint "cleared per request automatically" → addressed at step 1's try/finally pattern: yes
- Constraint "no new deps" → addressed (stdlib only): yes
- Constraint "tests/users.spec.ts must pass" → addressed at step 5: yes
- Open question "should plan be hypothetical?" → not addressed: NO (critical issue 1)
- Open question "existing requestContext middleware?" → not addressed: NO (planner did not re-check as suggested)
