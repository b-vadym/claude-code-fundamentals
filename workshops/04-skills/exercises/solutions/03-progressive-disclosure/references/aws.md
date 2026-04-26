# AWS deploy reference

## Prerequisites

- `aws` CLI installed
- `terraform` >= 1.5
- Active AWS credentials

## Steps

1. Verify credentials:
   ```bash
   aws sts get-caller-identity
   ```
   If fails, ask user to run `aws configure` or `aws sso login`.

2. Determine region:
   - `AWS_REGION` env var
   - `~/.aws/config` default profile
   - Fallback: `us-east-1`

3. Init Terraform:
   ```bash
   cd terraform/aws
   terraform init
   ```

4. Plan and review (always show user the plan output):
   ```bash
   terraform plan -out=tfplan
   ```

5. Apply only after explicit user approval:
   ```bash
   terraform apply tfplan
   ```

6. Capture outputs:
   ```bash
   terraform output -json > deploy-output.json
   ```

7. Health check: hit the load balancer URL from `deploy-output.json`. Expect HTTP 200.

## Rollback

If health check fails or user requests rollback:

```bash
terraform destroy -auto-approve
```

⚠️ Confirm with user explicitly before destroy — irreversible.
