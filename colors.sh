#!/usr/bin/env bash
for i in {0..7}; do
  next=$((i + 8))
  printf "\x1b[38;5;%dmcolour%d \x1b[38;5;%dmcolour%d\\n" "${i}" "${i}" "${next}" "${next}"
done
for i in {16..255}; do
  printf "\x1b[38;5;%dmcolour%d " "${i}" "${i}"
  if [[ $((i % 6)) == 3 ]]; then
    printf "\n"
  fi
done

# https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x329.html
T='gYw'
printf "\n                 40m     41m     42m     43m     44m     45m     46m     47m\n"
for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
           '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
           '  36m' '1;36m' '  37m' '1;37m'; do
  FG=${FGs// /}
  printf " %s \033[%s  %s  " "$FGs" "$FG" "$T"
  for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
    printf "%s \033[%s\033[%s  %s  \033[0m" "$EINS" "$FG" "$BG" "$T"
  done
  echo
done
echo

printf "\e[1mbold\e[0m\n"
printf "\e[3mitalic\e[0m\n"
printf "\e[3m\e[1mbold italic\e[0m\n"
printf "\e[4munderline\e[0m\n"
printf "\e[9mstrikethrough\e[0m\n"
