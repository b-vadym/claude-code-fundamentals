# Claude Code: воркшопи

Серія презентацій Slidev українською про Claude Code — від основ до продакшну.

Всі деки задеплоєні на GitHub Pages: <https://b-vadym.github.io/claude-code-fundamentals/>

## Legacy-деки (вже презентовані)

| #  | Тема                          | Посилання |
|----|-------------------------------|-----------|
| 01 | Claude Code: Fundamentals     | <https://b-vadym.github.io/claude-code-fundamentals/> |
| 02 | Claude Code: Економіка токенів | <https://b-vadym.github.io/claude-code-fundamentals/token-economy/> |

## Серія воркшопів

### Extending Claude Code

| #  | Тема                                          | Посилання |
|----|-----------------------------------------------|-----------|
| 03 | Slash Commands: глибше                        | <https://b-vadym.github.io/claude-code-fundamentals/03-slash-commands/> |
| 04 | Skills: від ідеї до продакшну                 | <https://b-vadym.github.io/claude-code-fundamentals/04-skills/> |
| 05 | Hooks: lifecycle deep dive                    | <https://b-vadym.github.io/claude-code-fundamentals/05-hooks/> |
| 06 | Plugins: глибоке занурення в авторство        | <https://b-vadym.github.io/claude-code-fundamentals/06-plugins/> |
| 07 | MCP-сервери: будуємо свій на Python           | <https://b-vadym.github.io/claude-code-fundamentals/07-mcp-servers/> |

### Claude Code in Production

| #  | Тема                                          | Посилання |
|----|-----------------------------------------------|-----------|
| 08 | Headless / CI/CD                              | <https://b-vadym.github.io/claude-code-fundamentals/08-headless-ci/> |
| 09 | Agent SDK: будуємо власного асистента         | <https://b-vadym.github.io/claude-code-fundamentals/09-agent-sdk/> |
| 10 | Subagents та команди агентів                  | <https://b-vadym.github.io/claude-code-fundamentals/10-subagents-and-teams/> |
| 11 | Security & Sandboxing: захист по шарах        | <https://b-vadym.github.io/claude-code-fundamentals/11-security/> |
| 12 | Debugging Claude Code: коли ламається         | <https://b-vadym.github.io/claude-code-fundamentals/12-debugging/> |

## Локальна розробка

```bash
npm install
npm run dev                 # 01-fundamentals (порт 3030)
npm run dev:economy         # 02-token-economy (порт 3031)

# Будь-який воркшоп:
npx slidev workshops/NN-slug/slides.md --open
```

Деталі архітектури — у [CLAUDE.md](./CLAUDE.md).
