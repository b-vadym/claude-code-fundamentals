# Вправа 3 — plug a leak

**Мета:** змодельований сценарій — хтось paste-нув API key у `CLAUDE.md`, закомітив, push-нув, а потім ще 4 коміти зверху. Прибери slot з історії і нікого не зашкодь.

**Час:** 15 хв.

## Disclaimer

Це навчальний сценарій. Усі ключі у `starter/repo/` — фейкові (формат правильний, але не активні). Жодних справжніх credentials не використовуй на реальних репозиторіях без попередньої ротації.

## Сценарій

Ти junior developer. Senior пише: «у нас leaked Anthropic API key у `CLAUDE.md`, я бачу його у `git log`. Вичисти зараз, я ротую сам.»

```bash
cd starter/repo
git log --oneline
# 5 commits, найдавніший — додавання CLAUDE.md з ключем
```

## Кроки

1. **Знайди secret** автоматично:

   ```bash
   gitleaks detect --source starter/repo --verbose
   # Або:
   trufflehog filesystem starter/repo
   # Або без tools:
   git log -p | grep -E 'sk-ant-[a-zA-Z0-9_-]{32,}'
   ```

2. **Симуляція rotate:** створи `starter/repo/ROTATED.md` з timestamp і "ROTATED OK" — це твій artifact для incident report. **(У реальному житті — заходиш у Console, revoke ключ, генеруєш новий, оновлюєш через apiKeyHelper / vault).**

3. **Backup repo:**

   ```bash
   cp -r starter/repo starter/repo.backup
   ```

4. **Видали з history через `git filter-repo`:**

   ```bash
   cd starter/repo
   # Замінити рядок в усіх коммітах:
   git filter-repo --replace-text <(echo 'literal:sk-ant-FAKEFAKEFAKE_FAKE_FAKE_FAKE_KEY_001==>***REDACTED***')

   # Або, якщо ключ варіюється — викинути цілий файл:
   # git filter-repo --invert-paths --path CLAUDE.md
   ```

5. **Перевір що чисто:**

   ```bash
   git log -p | grep -i 'sk-ant' && echo "STILL LEAKED" || echo "CLEAN"
   git log --all --oneline
   ```

6. **Force-push (НЕ роби на реальному репо без координації):**

   ```bash
   # У реальному житті:
   # git push --force-with-lease origin main
   # І написати команді: re-clone repo (rebase не врятує)
   ```

7. **Напиши incident report:**

   ```bash
   cp ../INCIDENT.template.md ../INCIDENT.md
   # Заповни:
   # - Timeline (коли leaked, коли виявлено, коли cleaned)
   # - Blast radius (хто міг побачити: public/private repo, скільки collaborators)
   # - Containment actions (rotate, filter, force-push, notify)
   # - Prevention (pre-commit hook gitleaks, training)
   ```

## Очікуваний результат

- `git log -p | grep sk-ant` нічого не повертає
- `ROTATED.md` створено
- `INCIDENT.md` заповнено з 4 секціями
- Розумієш які кроки **не робив** і чому (наприклад, не запускав на реальному repo, не поширював fake key)

## Якщо не вийшло

- `git filter-repo: command not found` → `pip install git-filter-repo`
- "refusing to overwrite repo without --force" → ти не на свіжому clone. Зроби fresh clone або додай `--force`
- `solutions/03-secret-leak/` — повний runbook з replace-text patterns і template incident report

## Bonus

Налаштуй pre-commit hook у `starter/repo/.pre-commit-config.yaml` що запускає `gitleaks` перед кожним коммітом. Тестуй: спробуй закомітити файл з fake key — має падати.
