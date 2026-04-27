# Корисні `jq` запити для tool-log.jsonl

Усі запити припускають, що лог у `~/.claude/tool-log.jsonl`.

## Повна стрічка з людським форматом

```bash
jq -r '"\(.ts) [\(.tool)] \(.input.command // .input.file_path // .input.pattern // "")"' \
  < ~/.claude/tool-log.jsonl
```

## Топ-10 найбільш юзаних tools

```bash
jq -r '.tool' < ~/.claude/tool-log.jsonl | sort | uniq -c | sort -rn | head -10
```

## Усі неуспішні tool-calls

```bash
jq 'select(.success == false)' < ~/.claude/tool-log.jsonl
```

## Середня тривалість по tool

```bash
jq -s 'group_by(.tool) | map({
  tool: .[0].tool,
  count: length,
  avg_ms: (map(.duration_ms // 0) | add / length | floor)
})' < ~/.claude/tool-log.jsonl
```

## Усі Bash-команди за останню годину

```bash
jq --arg cutoff "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ)" \
   'select(.tool == "Bash" and .ts > $cutoff) | .input.command' \
   < ~/.claude/tool-log.jsonl
```

## Live tail

```bash
tail -f ~/.claude/tool-log.jsonl | jq -c '{ts, tool, cmd: .input.command, ok: .success}'
```
