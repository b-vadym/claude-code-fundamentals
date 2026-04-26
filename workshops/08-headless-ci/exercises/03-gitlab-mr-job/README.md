# Вправа 3 — `.gitlab-ci.yml` для AI-ревʼю на MR

**Мета:** робочий job, який тригериться на MR і коментує діф у MR як note.

**Час:** 20 хв.

## Передумови

- Тестовий проєкт у GitLab (gitlab.com або self-hosted) з правом на CI/CD variables
- АБО: GitHub проєкт — у `solutions/03-gitlab-mr-job/github-actions.yml` є еквівалент
- `ANTHROPIC_API_KEY` готовий (Console-key) АБО `CLAUDE_CODE_OAUTH_TOKEN` (з `claude setup-token`)

## Кроки

1. **Підготуй GitLab project access:**

   - Створи (або візьми існуючий) тестовий проєкт у GitLab
   - **Settings → CI/CD → Variables → Add Variable:**
     - Key: `ANTHROPIC_API_KEY`
     - Value: твій ключ
     - Прапори: ✅ **Masked**, ✅ **Protected** (якщо main protected)
   - (Опціонально) `GITLAB_ACCESS_TOKEN` — Project Access Token зі scope `api` для постингу коментарів

2. **Додай `.gitlab-ci.yml` у корінь репо:**

   Скопіюй `gitlab-ci-starter.yml` з цієї теки → перейменуй на `.gitlab-ci.yml`.

   Прокоментуй секції — зрозумій як працюють:
   - `rules:` — тригер тільки на MR-event
   - `before_script:` — установка Claude
   - `script:` — fetch diff, run claude, post result
   - `--permission-mode plan` — readonly
   - `--max-turns 3` — стелля ітерацій
   - `--output-format json` — машино-парсимий вивід

3. **Створи feature-гілку та MR:**

   ```bash
   git checkout -b test-claude-review
   echo "// TODO: refactor" >> src/some_file.js
   git add . && git commit -m "test claude review"
   git push -u origin test-claude-review
   # Відкрий MR у GitLab UI
   ```

4. **Дивись Pipeline:**

   - **CI/CD → Pipelines** → клацни на pipeline для свого MR
   - Дивись лог `claude-review` job-а
   - Має закінчитись успіхом, у логах ти побачиш текст ревʼю

5. **Bonus: пости коментар у MR:**

   У `gitlab-ci-starter.yml` є коментована секція `after_script` з `curl` до GitLab API. Розкоментуй, додай `GITLAB_ACCESS_TOKEN` у CI/CD vars, перезапусти pipeline.

   Перевір MR → tab «Comments» → бачиш note від Claude.

6. **Експеримент: cost ceiling:**

   Додай `--max-budget-usd 0.50` у claude command — побач, як job завершується якщо переб'є budget.

## Очікуваний результат

- Job `claude-review` тригериться на кожен MR
- У логах — JSON-вивід Claude з summary
- (Bonus) Коментар з'являється в MR

## Якщо не вийшло

- **Auth fail у CI:** перевір `Settings → CI/CD → Variables` — `ANTHROPIC_API_KEY` має бути masked, не protected якщо тестова гілка не protected.
- **`claude: command not found`:** install скрипт `curl -fsSL https://claude.ai/install.sh | bash` додає у `~/.local/bin`. У `before_script` додай `export PATH=$HOME/.local/bin:$PATH`.
- **`git diff` пустий:** перевір `CI_MERGE_REQUEST_TARGET_BRANCH_NAME` — це pre-defined CI variable у MR-context.
- **Permission denied на curl у `after_script`:** додай `--allowedTools "Bash(curl *)"` у claude (якщо Claude мав робити curl, що рідко) АБО роби curl поза claude (як у solution).
- **Job-timeout:** GitLab default ~1 година. Постав `timeout: 10 minutes` явно.

## Файли в теці

- `gitlab-ci-starter.yml` — шаблон, з нього робимо `.gitlab-ci.yml`
- `prompt.md` — system prompt для review (можна append через `--append-system-prompt-file`)

## Подальше читання

- <https://code.claude.com/docs/en/gitlab-ci-cd> — офіційний template (Claude API + Bedrock + Vertex)
- <https://code.claude.com/docs/en/github-actions> — GitHub Actions з `anthropics/claude-code-action@v1`
- `solutions/03-gitlab-mr-job/` — повний `.gitlab-ci.yml` + GitHub Actions варіант
