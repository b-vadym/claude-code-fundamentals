# Incident: leaked API key in CLAUDE.md

**Severity:** [ S1 / S2 / S3 ]
**Detected by:** [name]
**Owner:** [name]
**Status:** [Open / Mitigated / Closed]

---

## Timeline (UTC)

| Time | Event |
|---|---|
| 2026-MM-DD HH:MM | Key originally committed to `CLAUDE.md` (commit `<sha>`) |
| 2026-MM-DD HH:MM | Push to origin/main |
| 2026-MM-DD HH:MM | Detection (how?) |
| 2026-MM-DD HH:MM | Rotation initiated in Console |
| 2026-MM-DD HH:MM | Rotation confirmed; old key revoked |
| 2026-MM-DD HH:MM | History rewrite via `git filter-repo` |
| 2026-MM-DD HH:MM | Force-push to origin/main |
| 2026-MM-DD HH:MM | Team notified, re-clone instructed |

## Blast radius

- **Repo visibility:** [public / private / internal]
- **Collaborators with read access:** [N people / known list]
- **Was repo cloned externally?** [unknown / yes / no]
- **Time exposed:** [duration]
- **Detected anomalies in API usage logs?** [yes/no, details]
- **Bot/scanner exposure window:** [if public, count from push to revoke]

## Containment actions

- [ ] Key revoked in Console (`<key-id>`)
- [ ] New key generated and stored in vault (`vault path`)
- [ ] `apiKeyHelper` updated to point to new key
- [ ] `git filter-repo --replace-text` executed
- [ ] `git log -p | grep -i sk-ant` returns nothing
- [ ] Force-push completed
- [ ] All collaborators notified to re-clone
- [ ] CI re-deployed with new credentials

## Prevention

- [ ] Pre-commit hook with `gitleaks` added to `.pre-commit-config.yaml`
- [ ] `permissions.deny` rule added: `Read(./.env)`, `Read(./CLAUDE.md.local)`
- [ ] Team training: secrets go in vault / `apiKeyHelper`, never in markdown
- [ ] GitHub push protection enabled (if applicable)
- [ ] Quarterly rotation policy review

## Lessons learned

- What worked:
- What didn't:
- Process changes:
