#!/usr/bin/env fish

function hash
  set -l str $argv[1]
  set -l hash 0
  for i in (seq (string length $str))
    set -l char (string sub -l 1 -s $i -- $str)
    set -l ascii (printf %d\\n \'$char)

    set hash (math "(($hash + $ascii) * 17) % 256")
  end

  echo $hash
end


while read -l line
  set file_content $line
end < inputs/input

set -l fields (string split "," $file_content)

set -l sum 0
for field in $fields
  set -l h (hash $field)
  set sum (math "$sum + $h")
end

echo $sum
