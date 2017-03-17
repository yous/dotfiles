#!/usr/bin/env bash
for i in {0..7}; do
  next=$((i + 8))
  printf "\x1b[38;5;%dmcolour%d \x1b[38;5;%dmcolour%d\n" "${i}" "${i}" "${next}" "${next}"
done
for i in {16..255}; do
  printf "\x1b[38;5;%dmcolour%d " "${i}" "${i}"
  if [[ $((i % 6)) == 3 ]]; then
    printf "\n"
  fi
done
