# GCP Vertex AI Workload Identity Federation runbook

Покрокове налаштування Vertex + GitLab WIF. Reference на потім.

Адаптовано з <https://code.claude.com/docs/en/gitlab-ci-cd#google-vertex-ai-job-example-workload-identity-federation>.

## Передумови

- GCP project з admin-доступом
- GitLab project
- Доступ до бажаних Claude моделей у Vertex (typically `us-east5` для Sonnet 4.5)

## Кроки

### 1. Увімкни API

- IAM Credentials API
- Security Token Service (STS) API
- Vertex AI API

### 2. Створи Workload Identity Pool + Provider

- IAM → Workload Identity Federation → Create pool
- Pool ID: `gitlab-pool`
- Add provider — type **OIDC**
  - Issuer: `https://gitlab.com`
  - Attribute mapping:
    ```
    google.subject = assertion.sub
    attribute.project_path = assertion.project_path
    attribute.ref = assertion.ref
    ```
  - Attribute condition (security):
    ```
    attribute.project_path == "my-org/my-project" && attribute.ref == "main"
    ```

### 3. Створи Service Account

- IAM → Service Accounts → Create
- Name: `claude-vertex-ci`
- Role: **Vertex AI User** (least privilege)

### 4. Дозволь WIF imperonate Service Account

- IAM → Service Accounts → claude-vertex-ci → Permissions → Grant access
- Principal: `principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/gitlab-pool/attribute.project_path/my-org/my-project`
- Role: **Workload Identity User** (`roles/iam.workloadIdentityUser`)

### 5. Зберегти resource names

- **WIF Provider full name:**
  `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/gitlab-pool/providers/PROVIDER_ID`
- **Service Account email:**
  `claude-vertex-ci@PROJECT_ID.iam.gserviceaccount.com`

### 6. GitLab CI/CD variables

- `GCP_WORKLOAD_IDENTITY_PROVIDER` = full provider name з кроку 5
- `GCP_SERVICE_ACCOUNT` = SA email з кроку 5
- `CLOUD_ML_REGION` = `us-east5`
- `ANTHROPIC_VERTEX_PROJECT_ID` = твій GCP project ID

### 7. `.gitlab-ci.yml` job

Адаптуй з docs (`/en/gitlab-ci-cd` → Google Vertex AI tab):

```yaml
claude-vertex:
  stage: ai
  image: gcr.io/google.com/cloudsdktool/google-cloud-cli:slim
  before_script:
    - apt-get update && apt-get install -y git jq && apt-get clean
    - curl -fsSL https://claude.ai/install.sh | bash
    - export PATH="$HOME/.local/bin:$PATH"
    - >
      gcloud auth login --cred-file=<(cat <<EOF
      {
        "type": "external_account",
        "audience": "${GCP_WORKLOAD_IDENTITY_PROVIDER}",
        "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
        "service_account_impersonation_url": "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${GCP_SERVICE_ACCOUNT}:generateAccessToken",
        "token_url": "https://sts.googleapis.com/v1/token"
      }
      EOF
      )
  script:
    - export CLAUDE_CODE_USE_VERTEX=1
    - claude -p "review this MR" --bare --permission-mode plan --max-turns 3
```

## Troubleshooting

- **`Permission denied` на impersonate** — перевір attribute condition у WIF provider. Має точно матчити твій project + branch.
- **`Model not found`** — Vertex regions для Claude моделей обмежені. Подивись `us-east5` для Sonnet 4.5.
- **`gcloud auth login` падає** — перевір що audience у JSON-creds співпадає з WIF provider name.

## Подальше читання

- <https://cloud.google.com/iam/docs/workload-identity-federation>
- <https://code.claude.com/docs/en/google-vertex-ai>
