# Solution: 03-secret-leak — повний runbook

## Крок 1 — детектити

```bash
cd starter/repo

# Метод 1: gitleaks (найкраще)
gitleaks detect --source . --verbose

# Метод 2: trufflehog
trufflehog filesystem .

# Метод 3: без tools
git log -p | grep -E 'sk-ant-[a-zA-Z0-9_-]{20,}'
git log -p --all | grep -nE 'sk-ant-' | head
```

Очікуємо знайти 2 ключі: `sk-ant-FAKEFAKEFAKE_FAKE_FAKE_FAKE_KEY_001` і `sk-ant-FAKEFAKEFAKE_FAKE_FAKE_FAKE_KEY_002`.

## Крок 2 — симуляція ротації

```bash
cat > ROTATED.md <<EOF
# Rotation log

$(date -u +"%Y-%m-%dT%H:%M:%SZ"): Both keys revoked in Console.
Old key IDs: KEY_001, KEY_002 (FAKE for workshop)
New key stored in: vault://secrets/anthropic/api-key
EOF
```

## Крок 3 — backup перед filter-repo

```bash
cd ..
cp -r repo repo.backup-$(date +%s)
cd repo
```

## Крок 4 — filter-repo

**Варіант A: replace-text (зберігає файли, замінює patterns):**

```bash
cat > /tmp/replacements.txt <<'EOF'
literal:sk-ant-FAKEFAKEFAKE_FAKE_FAKE_FAKE_KEY_001==>***REDACTED***
literal:sk-ant-FAKEFAKEFAKE_FAKE_FAKE_FAKE_KEY_002==>***REDACTED***
EOF

git filter-repo --replace-text /tmp/replacements.txt --force
```

**Варіант B: викинути цілий файл з усієї історії:**

```bash
git filter-repo --invert-paths --path CLAUDE.md --force
```

**Коли який:**
- replace-text — якщо у файлі легітимний контент крім ключа (наш випадок)
- invert-paths --path — якщо файл взагалі не має бути у репо

## Крок 5 — перевірка

```bash
# Має нічого не повернути:
git log -p --all | grep -E 'sk-ant-[A-Z]' && echo "STILL LEAKED" || echo "CLEAN"

# Перевір що commits перепаковані:
git log --oneline
# SHA-и інші ніж до filter-repo

# Перевір reflog (теж може містити!):
git reflog | grep -i sk-ant
git gc --prune=now --aggressive
```

## Крок 6 — push (СИМУЛЯЦІЯ — НЕ виконуй на реальному repo)

```bash
# git push --force-with-lease origin main
# git push --force-with-lease origin --tags

# Усі collaborators роблять:
# git fetch
# git reset --hard origin/main   # ← обов'язково hard, не rebase
# Або краще: re-clone repo з нуля
```

## Крок 7 — INCIDENT.md

Заповнити timeline, blast radius, containment actions, prevention. Template у `starter/INCIDENT.template.md`.

## Bonus: pre-commit hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.0
    hooks:
      - id: gitleaks
```

```bash
pip install pre-commit
pre-commit install
# Тест:
echo "sk-ant-FAKE_TEST_KEY_999" >> CLAUDE.md
git add CLAUDE.md && git commit -m "test"
# pre-commit має падати на gitleaks
```

## Чого НЕ робити (anti-patterns)

1. **`git rebase -i` + edit commit** — не прибирає з blob storage. Reflog зберігає.
2. **`git reset --hard <pre-leak> + rewrite`** — те ж.
3. **GitHub UI "delete commit"** — не існує (тільки revert, який лишає в історії).
4. **Просто `git rm` + commit** — НАЙГІРШЕ. Файл і ключ лишаються у історії.
5. **Push без `--force-with-lease`** — race з teammate-ом може відкотити твій cleanup.
6. **Cleanup БЕЗ ротації** — ключ уже в архівах GitHub, копії у scrapers, mirrors. Cleanup без revoke = security theatre.

## Реальні часові ризики

GitHub секрет, push-нутий у public repo → сканери (наприклад, AWS abuse) фіксують за **2-5 хвилин**. Тому:

1. **ALWAYS rotate first.** Cleanup — другорядний.
2. Очікуй що ключ уже стибровано до твого filter-repo.
3. Перевір usage logs у Console — чи були виклики не від тебе.
