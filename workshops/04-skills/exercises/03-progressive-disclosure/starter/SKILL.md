---
name: cloud-deploy
description: Deploy a project to AWS, GCP, or Azure with terraform/bicep
allowed-tools: [Bash, Read, Edit]
---

# cloud-deploy

Deploy any project to one of three cloud providers. Detect platform from project files.

## Detect platform

Look for marker files in this priority:

1. `terraform/aws/` directory or `*.tf` with `provider "aws"` → AWS
2. `gcloud-config.yaml` or `terraform/gcp/` → GCP
3. `bicep/` directory or `.azure/` config → Azure

If none found, ask user explicitly which platform.

## AWS deploy steps

1. Verify credentials:
   ```bash
   aws sts get-caller-identity
   ```
   If fails, ask user to run `aws configure` or `aws sso login`.

2. Check region from `AWS_REGION` env or `~/.aws/config`. Default `us-east-1`.

3. Init Terraform:
   ```bash
   cd terraform/aws
   terraform init
   ```

4. Plan and review:
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

7. Validate deployment by hitting the load balancer URL from output.
8. If health check fails — rollback with `terraform destroy -auto-approve`.

## GCP deploy steps

1. Verify auth:
   ```bash
   gcloud auth list
   gcloud config get-value project
   ```
   If no active account, run `gcloud auth login`.

2. Set project from `gcloud-config.yaml`:
   ```bash
   gcloud config set project $(yq '.project' gcloud-config.yaml)
   ```

3. Enable required APIs:
   ```bash
   gcloud services enable run.googleapis.com cloudbuild.googleapis.com
   ```

4. Build container:
   ```bash
   gcloud builds submit --tag gcr.io/$PROJECT/$SERVICE
   ```

5. Deploy to Cloud Run:
   ```bash
   gcloud run deploy $SERVICE --image gcr.io/$PROJECT/$SERVICE --region us-central1
   ```

6. Capture service URL:
   ```bash
   gcloud run services describe $SERVICE --format='value(status.url)'
   ```

7. Validate with curl. On 5xx — `gcloud run services delete $SERVICE`.

## Azure deploy steps

1. Verify login:
   ```bash
   az account show
   ```
   If fails — `az login`.

2. Set subscription:
   ```bash
   az account set --subscription $(jq -r '.subscription' .azure/config.json)
   ```

3. Create resource group if missing:
   ```bash
   az group create --name rg-$SERVICE --location westeurope
   ```

4. Validate Bicep:
   ```bash
   az deployment group validate --resource-group rg-$SERVICE \
     --template-file bicep/main.bicep
   ```

5. Deploy:
   ```bash
   az deployment group create --resource-group rg-$SERVICE \
     --template-file bicep/main.bicep
   ```

6. Capture outputs:
   ```bash
   az deployment group show --resource-group rg-$SERVICE \
     --name main --query properties.outputs
   ```

7. Validate endpoint. On failure — `az group delete --name rg-$SERVICE --yes`.

## Common output format

After any deploy, report:
- Platform used
- Resource identifiers (instance IDs, service URLs)
- Time taken
- Cost estimate (if available)
- Next steps (DNS, monitoring, secrets)
