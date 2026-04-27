# Task: add caching layer to fetchUser

We have a `fetchUser(id)` function that hits the database every call. Some pages call it 20+ times per request for the same id, which is wasteful.

Goal: add a request-scoped cache so repeated calls within one HTTP request return the same object without a DB hit. Across requests the cache should not leak.

Constraints:
- Must work in our Node.js API (no service worker tricks)
- Cache must be cleared per request automatically
- Tests in `tests/users.spec.ts` must still pass
- No new dependencies if a stdlib pattern works

Open questions for research:
- Where is fetchUser defined?
- How is "request scope" expressed elsewhere in the code?
- Are there existing caches we should align with?

(This is a synthetic task for the workshop chain exercise — the research subagent will find that the repo doesn't actually have these files, which is fine: it should report that as the main finding.)
