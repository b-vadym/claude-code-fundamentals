# Workshop 08 — Headless / CI/CD: вправи

Чотири вправи по 10–20 хвилин кожна. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Claude Code v1.x встановлений (`claude --version`)
- `jq` для парсингу JSON-виводу (`brew install jq` / `apt install jq`)
- `ANTHROPIC_API_KEY` у env, або `CLAUDE_CODE_OAUTH_TOKEN` (з `claude setup-token`)
- Git-репо для тестових команд (можна цей)
- Для вправ 3–4: тестовий проєкт у GitLab або GitHub з правом на CI/CD variables

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-print-basic/` | `claude -p` локально, JSON parsing, `--bare` | 10 хв |
| 2 | `02-pr-diff-review/` | Dry-run readonly review діфа з JSON Schema | 15 хв |
| 3 | `03-gitlab-mr-job/` | `.gitlab-ci.yml` для AI-ревʼю на MR (real or mock) | 20 хв |
| 4 | `04-oidc-secrets/` | Mock OIDC + token-vault flow для cloud-провайдерів | 15 хв |

## Як запускати

Кожна тека має свій `README.md` зі специфічними кроками. Загалом:

```bash
cd 0N-name/
cat README.md          # інструкція
ls                     # стартовий стан
# роби кроки з README
ls ../solutions/0N-*/  # підглянь якщо застрягнеш
```

## solutions/

Готові розвʼязки для кожної вправи. Не дивись поки не спробував сам.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці (Section «Дебаг»)
- Питання — Discord або підніми руку на воркшопі

## Що зберіг після воркшопу

- Робочий headless-скрипт як шаблон
- `.gitlab-ci.yml` для AI-ревʼю MR — копіюєш у свій проєкт
- Розуміння auth precedence (6 джерел) і коли яке використовувати
- Чек-ліст безпечних дефолтів `--permission-mode dontAsk` + `--max-turns` + `--max-budget-usd`
- Mock OIDC-flow як reference для реального налаштування пізніше
