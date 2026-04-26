# Стартові prompt-и для вправи 1

Скопіюй один з цих рядків у Claude Code prompt і дивись transcript.

## Базовий

```
Use the Explore subagent to find all places where DocRef is used in this repo.
```

## З явним thoroughness

```
Use Explore very thoroughly to map every component import in workshops/.
```

## Контр-приклад (Claude НЕ має делегувати)

```
Read the file components/DocRef.vue and tell me what props it takes.
```

## Bonus: змусити паралель з простими subagent-ами

(увага — це pre-vue для вправи 3)

```
Use 2 Explore subagents in parallel: one to find all DocRef usage,
one to count slides per workshop file. Synthesize findings.
```
