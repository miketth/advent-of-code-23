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

  steps=$((steps+1))
done

echo "First part: $steps"


typeset -A pos
for key in ${(@k)data}; do
  key=${key//\"/}
  last_char=${key[-1]}
  if [[ $last_char = "A" ]]; then
    pos["$key"]=$key
  fi
done

gcd() {
    local a=$1
    local b=$2
    while [[ $b -ne 0 ]]; do
        local temp=$b
        b=$(( a % b ))
        a=$temp
    done
    echo $a
}

lcm() {
    local a=$1
    local b=$2
    local gcd_value=$(gcd $a $b)
    echo $(( a * b / gcd_value ))
}

typeset -A cycles
for key in ${(@k)pos}; do
  key=${key//\"/}
  current="${pos["$key"]}"

  cycle=0
  do_stuff=true
  while [[ ! "$current" = *Z ]]; do
    idx=$((cycle%step_mod))
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

    cycle=$((cycle+1))
  done
  cycles["$key"]=$cycle
done

least_common_mult=1
for key in ${(@k)cycles}; do
  key=${key//\"/}
  value=${cycles["$key"]}
  least_common_mult=$(lcm $least_common_mult $value)
done

echo "Second part: $least_common_mult"
