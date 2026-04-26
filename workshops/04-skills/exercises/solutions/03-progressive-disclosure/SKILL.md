---
name: cloud-deploy
description: Deploy a project to AWS, GCP, or Azure. Use when user
  asks to deploy, ship, release, or push to production for any cloud
  provider. Detects platform from project markers automatically.
allowed-tools: [Bash, Read, Edit]
---

# cloud-deploy

Deploy any project to AWS, GCP, or Azure. Auto-detect the platform from project files.

## Detect platform

Check in this priority:

1. `terraform/aws/` directory or `*.tf` containing `provider "aws"` → **AWS**
2. `gcloud-config.yaml` or `terraform/gcp/` → **GCP**
3. `bicep/` directory or `.azure/config.json` → **Azure**

If multiple match, ask user to confirm. If none match, ask user explicitly.

## Platform-specific steps

For detailed deploy procedure, read the relevant reference:

- **AWS:** [aws.md](references/aws.md) — credentials, terraform, validation
- **GCP:** [gcp.md](references/gcp.md) — gcloud auth, Cloud Run, build
- **Azure:** [azure.md](references/azure.md) — az login, Bicep, resource groups

Read **only** the file matching the detected platform — do not load all three.

## Common output format

After deploy completes (any platform), report:

- Platform used
- Resource identifiers (instance IDs, service URLs)
- Time taken
- Cost estimate if available
- Suggested next steps (DNS, monitoring, secrets management)

## Failure handling

If deploy fails mid-way:

1. Capture the error message verbatim
2. Read platform-specific reference for rollback commands
3. Confirm with user before destructive cleanup
4. Document the failure in `deploy-log.md` with timestamp + error
