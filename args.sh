#!/bin/bash

declare -g RUFUS_PROMPT_MODULES=(
  a,colour:green
  b,colour:default,position:right
  c
)

for module in "${RUFUS_PROMPT_MODULES[@]}"; do
  echo "All arguments (${module}):"
  IFS=',' read -ra argv <<< $module
  for arg in "${argv[@]}"; do
    if ! [[ $arg == *":"* ]]; then
      echo "Primary arg: $arg"
    else
      IFS=':' read -ra argp <<< $arg
      echo -e "${argp[0]}: ${argp[1]}"
    fi
  done
done

#IFS=';' read -ra ADDR <<< "$RUFUS_PROMPT_MODULES"
#for i in "${ADDR[@]}"; do
#  echo "$i"
#done
