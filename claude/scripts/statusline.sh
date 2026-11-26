#!/bin/bash
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  # Round to integer
  pct=$(printf '%.0f' "$used")

  # Build a 20-char progress bar
  filled=$(( pct * 20 / 100 ))
  empty=$(( 20 - filled ))
  bar=""
  i=0
  while [ $i -lt $filled ]; do
    bar="${bar}█"
    i=$(( i + 1 ))
  done
  i=0
  while [ $i -lt $empty ]; do
    bar="${bar}░"
    i=$(( i + 1 ))
  done

  printf '\033[0;36m%s\033[0m  \033[0;33m[%s]\033[0m \033[0;37m%s%%\033[0m' \
    "$model" "$bar" "$pct"
else
  printf '\033[0;36m%s\033[0m' "$model"
fi
