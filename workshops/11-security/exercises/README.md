# Workshop 11 — Security: вправи

Чотири вправи по 15 хвилин. Defensive-only. Слайди ведуть — ти кодиш паралельно.

## Передумови

- Claude Code v1.x встановлений (`claude --version`)
- Docker або VS Code Dev Containers extension (для вправи 1)
- `git filter-repo` встановлений (для вправи 3) — `pip install git-filter-repo`
- `jq` (для вправи 4)
- `gitleaks` (опційно) — `brew install gitleaks`

## Маршрут

| № | Тека | Що робиш | Час |
|---|---|---|---|
| 1 | `01-devcontainer/` | Свій devcontainer з firewall (default-deny outbound + allowlist) | 15 хв |
| 2 | `02-deny-list/` | Багатошаровий deny: permissions + sandbox + hooks (12 test cases) | 15 хв |
| 3 | `03-secret-leak/` | Знайти і прибрати leaked API key з git історії (rotate + filter-repo) | 15 хв |
| 4 | `04-audit-logs/` | Audit transcripts через jq queries, налаштувати ConfigChange hook | 15 хв |

## Як запускати

Кожна тека має свій `README.md` зі специфічними кроками:

```bash
cd 0N-name/
cat README.md          # інструкція
ls starter/            # стартовий стан
# роби кроки з README
ls ../solutions/0N-*/  # підглянь якщо застрягнеш
```

## solutions/

Готові розв'язки. Не дивись поки не спробував — мета зрозуміти різницю між твоїм підходом і еталоном.

## Що зберіг після воркшопу

- Робочий devcontainer template для будь-якого проєкту
- `.claude/settings.json` deny-list для copy-paste
- Runbook на secret leak (rotate → clean → postmortem)
- jq queries для audit transcripts
- Чек-ліст defense-in-depth з 5 шарів

## Disclaimer

**Defensive only.** Жодних offensive технік, ні bypass-ів. Якщо щось працює "не так" — повідом, не використовуй.

## Коли застрягнеш

- Спочатку — `solutions/`
- Потім — `handout.pdf` у батьківській теці
- Питання — Discord або підніми руку на воркшопі
