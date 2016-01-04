#!/usr/bin/env bash
for i in {0..7}; do
  next=$((${i} + 8))
  printf "\x1b[38;5;${i}mcolour${i} \x1b[38;5;${next}mcolour${next}\n"
done
for i in {16..255}; do
  printf "\x1b[38;5;${i}mcolour${i} "
  if [[ $((${i} % 6)) == 3 ]]; then
    printf "\n"
  fi
done
