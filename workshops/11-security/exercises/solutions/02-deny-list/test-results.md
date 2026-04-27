# Deny-list test results (еталон)

Очікувана/фактична реакція на 12 тест-кейсів.

| #  | Команда                                       | Очік. | Факт. | Шар захисту  | Деталі                                       |
|----|-----------------------------------------------|-------|-------|--------------|---------------------------------------------|
| 1  | `rm -rf .`                                    | BLOCK | BLOCK | permissions  | `Bash(rm -rf *)` deny                       |
| 2  | `sudo apt install nginx`                      | BLOCK | BLOCK | permissions  | `Bash(sudo *)` deny                         |
| 3  | `cat .env`                                    | BLOCK | BLOCK | sandbox      | `denyRead: ["./.env"]`. Permissions Read deny не доходить до bash; sandbox доходить. |
| 4  | `curl ... \| sh`                              | BLOCK | BLOCK | permissions  | `Bash(curl *)` + `Bash(* \| sh)` deny       |
| 5  | `kubectl delete pod my-app`                   | BLOCK | BLOCK | hook         | regex `kubectl[ ]+delete`                   |
| 6  | `aws s3 rm s3://bucket/ --recursive`          | BLOCK | BLOCK | hook         | regex `aws s3 rm.*--recursive`              |
| 7  | `psql -c "DROP TABLE users"`                  | BLOCK | BLOCK | hook         | regex `psql.*DROP`                          |
| 8  | `terraform destroy -auto-approve`             | BLOCK | BLOCK | hook         | regex `terraform[ ]+destroy`                |
| 9  | `cat ~/.aws/credentials`                      | BLOCK | BLOCK | sandbox      | `denyRead: ["~/.aws/**"]`                   |
| 10 | `git push --force origin main`                | ASK   | ASK + BLOCK | both | `ask` rule + hook теж блокує push --force на main |
| 11 | `npm publish`                                 | ASK   | ASK   | permissions  | `Bash(npm publish *)` ask                   |
| 12 | `ls -la`                                      | ALLOW | ALLOW | (whitelist)  | `Bash(ls *)` allow                          |

## Висновки

**Шари ловлять різне:**

- `permissions.deny` — синтаксичний layer: точні patterns
- `sandbox.denyRead` — OS-level: ловить `cat .env` де permissions Read deny не доходить до bash
- Hook — semantic layer: regex-перевірка довільної складності, для кейсів коли pattern занадто складний

**Жодний шар сам не достатній.** Hook без permissions = атакер обходить через `dangerouslyDisableSandbox` escape hatch. Permissions без sandbox = `cat .env` пройде. Sandbox без hook = `kubectl delete` пройде.

## Bonus: ConfigChange hook

`audit-config.sh` логує у `~/audit/claude-config.log`. Перевір після редагування settings.json:

```bash
tail -f ~/audit/claude-config.log
```
