#!/bin/bash
input=$(cat)
echo "$input" > /tmp/claude-subagent-statusline-last.json
now_ms=$(($(date +%s) * 1000))

echo "$input" | jq -c '.tasks[]?' | while read -r task; do
  id=$(echo "$task" | jq -r '.id')
  label=$(echo "$task" | jq -r '.label // .description // "agent"')
  tok=$(echo "$task" | jq -r '.tokenCount // 0')
  start=$(echo "$task" | jq -r '.startTime // 0')

  model="?"
  f=$(ls /private/tmp/claude-*/*/*/tasks/"$id".output 2>/dev/null | head -1)
  if [ -n "$f" ]; then
    m=$(grep -m1 -o '"model":"[^"]*"' "$f" | cut -d'"' -f4)
    [ -n "$m" ] && model="$m"
  fi

  secs=0
  [ "$start" -gt 0 ] && secs=$(((now_ms - start) / 1000))
  if [ "$secs" -ge 60 ]; then
    elapsed="$((secs / 60))m $((secs % 60))s"
  else
    elapsed="${secs}s"
  fi

  if [ "$tok" -ge 1000 ]; then
    toks=$(awk "BEGIN{printf \"%.1fk\", $tok/1000}")
  else
    toks="$tok"
  fi

  printf '{"id":"%s","content":"%s [%s]  %s · ↓ %s tokens"}\n' "$id" "$label" "$model" "$elapsed" "$toks"
done
