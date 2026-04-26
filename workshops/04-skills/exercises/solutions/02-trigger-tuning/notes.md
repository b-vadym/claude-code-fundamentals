# Trigger-tuning: ожидані результати

Це не «правильна» відповідь — кожен запуск може триматися інакше залежно від контексту сесії й моделі. Але типовий patern:

| Запит | A (vague) | B (specific) | C (pushy) |
|---|---|---|---|
| який розмір bundle-у? | ❌ | ✅ | ✅ |
| чи багато залежностей? | ❌ | ⚠️ | ✅ |
| check the dist size | ❌ | ✅ | ✅ |
| is bundle bloated? | ❌ | ⚠️ | ✅ |
| show package weight | ❌ | ⚠️ | ✅ |

## Чому A провалюється

Description "Check bundle size" — без action context. Claude бачить «check size» — застосовно до тисячі речей. Безпечніше не тригерити.

## Чому B працює середньо

Specific — згадує "JavaScript bundle", "weight", "bloat", "before/after". На прямі запити з цими словами тригерить впевнено. На дотичні («чи багато залежностей?») — Claude вагається, бо немає прямого ключа «dependency size».

## Чому C тригерить агресивно

Pushy — переліковує синоніми (bundle, weight, dependency size, dist size, build output, payload), додає «MANDATORY», згадує «even subtle hints». Claude отримує сигнал «не пропусти».

## Який вибрати у production

**Залежить:**

- Skill з side-effects (deploy, drop tables) → НЕ pushy. Краще явний `/skill-name`. Навіть `disable-model-invocation: true`
- Skill-довідник, чисто read-only → можна pushy. Гірше від зайвого тригеру не буде
- Skill що змінює код (refactor, format) → specific з обмеженням `paths` (e.g., `paths: ["**/*.ts"]`)

## Висновок

Pushy ≠ безвідповідально. Pushy + scoping (paths, allowed-tools) = надійно. Vague + ніщо = марна метадата в усіх сесіях.
