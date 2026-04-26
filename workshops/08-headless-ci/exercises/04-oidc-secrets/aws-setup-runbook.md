# AWS Bedrock OIDC setup runbook

Покрокове налаштування Bedrock + GitLab OIDC. Не виконуй на воркшопі — це reference на потім (~30 хв реальної роботи в AWS Console + GitLab).

Адаптовано з <https://code.claude.com/docs/en/gitlab-ci-cd#using-with-aws-bedrock--google-vertex-ai>.

## Передумови

- AWS account з адмін-доступом
- GitLab project (gitlab.com or self-hosted)
- Регіон AWS, де доступний бажаний Claude-модель (наприклад `us-west-2`)

## Кроки

### 1. Запитай доступ до Bedrock

- AWS Console → Amazon Bedrock → Model access
- Запит на `anthropic.claude-sonnet-4-6` або потрібний model ID

### 2. Створи IAM OIDC provider для GitLab

- IAM → Identity providers → Add provider
- Provider type: **OpenID Connect**
- Provider URL: `https://gitlab.com` (або URL твого self-hosted)
- Audience: `https://gitlab.com` (чи що твоя конфігурація вимагає)
- Get thumbprint → Add provider

### 3. Створи IAM role для GitLab CI

- IAM → Roles → Create role
- Trusted entity type: **Web identity**
- Identity provider: вибери OIDC-провайдер з кроку 2
- Audience: той же
- Edit Trust policy — обмеж на конкретний project + branch:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Federated": "arn:aws:iam::ACCOUNT:oidc-provider/gitlab.com"},
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.com:sub": "project_path:my-org/my-project:ref_type:branch:ref:main"
        }
      }
    }]
  }
  ```
- Attach permissions: `AmazonBedrockFullAccess` (або кастомну least-privilege policy на `bedrock:InvokeModel`)
- Збережи **Role ARN** — він піде в GitLab variable `AWS_ROLE_TO_ASSUME`

### 4. Додай GitLab CI/CD variables

GitLab → Settings → CI/CD → Variables:

- `AWS_ROLE_TO_ASSUME` = ARN з кроку 3 (НЕ masked, бо не secret — просто config)
- `AWS_REGION` = `us-west-2` (чи де Bedrock)

### 5. Додай `.gitlab-ci.yml` job

Скопіюй `gitlab-bedrock.yml` з цієї теки.

### 6. Перевір

- Створи MR
- Pipeline → claude-bedrock job
- Має пройти `aws sts assume-role-with-web-identity` без помилок
- Логи мають містити `Cost: $...` від Bedrock

## Troubleshooting

- **`Access denied`** на assume-role — перевір умову `gitlab.com:sub` у trust policy. Точний формат залежить від твоїх ref-pattern-ів.
- **`Model not available`** — у твоєму регіоні може не бути потрібного Claude-моделі. Перевір AWS docs щодо доступних регіонів.
- **`InvokeModel` denied** — IAM role не має permissions. Додай `bedrock:InvokeModel` у policy.

## Подальше читання

- <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html>
- <https://docs.aws.amazon.com/bedrock/>
- <https://code.claude.com/docs/en/amazon-bedrock>
