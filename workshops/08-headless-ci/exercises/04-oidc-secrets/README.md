# Вправа 4 — OIDC + token-vault (mock)

**Мета:** зрозуміти OIDC-flow для cloud-провайдерів і token-vault для subscription auth, без розгортання реального AWS/GCP.

**Час:** 15 хв.

## Контекст

Дві різні задачі, обидві про «прибрати long-lived ключі»:

1. **OIDC для Bedrock/Vertex** — CI exchange-ить свій JWT на короткоживучі AWS/GCP creds.
2. **Token-vault для subscription** — `apiKeyHelper` тягне ключ з Vault при кожному виклику.

Mock-варіант: ми не звертаємось до реального AWS, але повторюємо точну послідовність, щоб ти міг зробити справжню налаштовку самостійно.

## Кроки

### Частина A — OIDC mock (5 хв)

1. **Подивись `mock-aws-oidc.sh`:**

   ```bash
   cat mock-aws-oidc.sh
   ```

   Це симулятор `aws sts assume-role-with-web-identity`. Видає fake creds, але точну структуру.

2. **Запусти end-to-end mock-flow:**

   ```bash
   bash mock-aws-oidc.sh
   ```

   Подивись що видається:
   - JWT (mock-токен від «GitLab»)
   - `aws sts ...` виклик
   - JSON з `AccessKeyId`, `SecretAccessKey`, `SessionToken`
   - `export` cмd

3. **Подивись на `gitlab-bedrock.yml`:**

   Це адаптована версія з docs (`https://code.claude.com/docs/en/gitlab-ci-cd`). Ключове:
   - Без `ANTHROPIC_API_KEY`
   - `aws sts assume-role-with-web-identity` робить exchange
   - `claude` запускається з `CLAUDE_CODE_USE_BEDROCK=1`

### Частина B — token-vault mock (5 хв)

1. **Подивись `apiKeyHelper.sh`:**

   ```bash
   cat apiKeyHelper.sh
   ```

   Симулятор: «дістає» ключ з vault. У продакшні замінюєш на `vault kv get -field=key secret/anthropic`.

2. **Налаштуй у `settings.json`:**

   ```bash
   cat settings.json
   ```

   Полі `apiKeyHelper` вказує на скрипт.

3. **Запусти claude з settings (mock):**

   ```bash
   claude --settings ./settings.json -p "test" --max-turns 1
   ```

   Якщо твій helper повертає валідний ключ — Claude використає його. Mock-ключ не валідний; це для розуміння flow, не реального запуску.

### Частина C — список real-world steps (5 хв)

1. **Прочитай `aws-setup-runbook.md`** — список IAM-кроків для AWS Bedrock OIDC
2. **Прочитай `gcp-setup-runbook.md`** — кроки для GCP Workload Identity Federation
3. Обери одну платформу і поставши собі задачу: зробити в реальному середовищі за 1 годину поза воркшопом.

## Очікуваний результат

- Розумієш `aws sts assume-role-with-web-identity` flow
- Розумієш різницю `apiKeyHelper` vs static `ANTHROPIC_API_KEY`
- Маєш runbook для реального AWS/GCP setup-у

## Якщо не вийшло

- **Mock-script повертає не те:** перевір що в env є `CI_JOB_JWT_V2` (mock встановить сам)
- **`apiKeyHelper` не викликається:** перевір settings.json синтаксис; шлях до скрипта має бути absolute або relative до cwd
- **Plan завеликий:** OIDC setup для AWS — це 30+ хв реальної роботи; mock дає лише розуміння

## Файли в теці

- `mock-aws-oidc.sh` — симулятор `assume-role-with-web-identity`
- `apiKeyHelper.sh` — симулятор vault-fetch
- `settings.json` — приклад settings з apiKeyHelper
- `gitlab-bedrock.yml` — адаптована з docs CI-yaml для Bedrock OIDC
- `aws-setup-runbook.md` — IAM-кроки для реального AWS
- `gcp-setup-runbook.md` — WIF-кроки для реального GCP

## Подальше читання

- <https://code.claude.com/docs/en/gitlab-ci-cd#aws-bedrock-job-example-oidc> — повний приклад
- <https://code.claude.com/docs/en/github-actions#using-with-aws-bedrock--google-vertex-ai> — те саме для GitHub
- <https://code.claude.com/docs/en/authentication#credential-management> — `apiKeyHelper`
- `solutions/04-oidc-secrets/` — повністю заповнені файли
