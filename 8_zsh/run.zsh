#!/usr/bin/env zsh

set -eo pipefail

contents="$( < "inputs/input" )"
lines=("${(f)contents}")

directions=${lines[1]}

typeset -A data
maps=( "${lines[@]:1}" )
for mapline in "${maps[@]}"; do
  key=${mapline%% = *}

  tuple=${mapline#* = }
  tuple=${tuple#[(]}
  tuple=${tuple%[)]}

  val=("${(@s/, /)tuple}")

  data["$key"]="${val[*]}"
done

steps=0
current="AAA"
step_mod=${#directions}
while [[ "$current" != "ZZZ" ]]; do
  #echo current = $current

  idx=$((steps%step_mod))
  idx=$((idx+1))

  next_step=${directions[$idx]}

  list_as_string="${data["$current"]}"
  curr_list=("${(@s/ /)list_as_string}")

  if [[ "$next_step" = "L" ]]; then
    dir_idx=1
  else
    dir_idx=2
  fi

  current=${curr_list[$dir_idx]}
  #echo going to $current

  steps=$((steps+1))
  #echo step = $steps

  #echo
  #echo

done

echo "First part: $steps"
