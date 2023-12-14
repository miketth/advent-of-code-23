<?php

$filePath = 'inputs/input';

function find_first_dot_in_col_before($lines, $col, $end): ?int
{
    $first_dot = null;
    for ($i = $end; $i >= 0; $i--) {
        if ($lines[$i][$col] === '.') {
            $first_dot = $i;
        }
        if ($lines[$i][$col] === '#') {
            break;
        }
    }

    return $first_dot;
}

function tilt_all_north(&$lines): void
{
    $col_length = count($lines);
    $row_length = count($lines[0]);
    for ($x = 0; $x < $row_length; $x++) {
        for($y = 0; $y < $col_length; $y++) {
            $value = $lines[$y][$x];
            if ($value === 'O') {
                $first_dot = find_first_dot_in_col_before($lines, $x, $y - 1);
                if ($first_dot !== null) {
                    $lines[$first_dot][$x] = 'O';
                    $lines[$y][$x] = '.';
                }
            }
        }
    }
}

function score($lines): int
{
    $col_count = count($lines[0]);
    $length = count($lines);
    $score = 0;

    for ($x = 0; $x < $col_count; $x++) {
        for ($y = 0; $y < $length; $y++) {
            if ($lines[$y][$x] === 'O') {
                $score += $length - $y;
            }
        }
    }

    return $score;
}

function rotate_clockwise($lines): array
{
    $row_length = count($lines[0]);
    $col_length = count($lines);
    $empty_row = array_fill(0, $col_length, null);
    $rotated = array_fill(0, $row_length, $empty_row);

    foreach ($lines as $rowKey => $row) {
        foreach ($row as $colKey => $value) {
            $rotated[$colKey][$row_length - $rowKey - 1] = $value;
        }
    }
    return $rotated;
}

function print_lines($lines)
{
    echo PHP_EOL . PHP_EOL . PHP_EOL;
    foreach ($lines as $line) {
        echo implode('', $line) . PHP_EOL;
    }
}

$memoize_cache = [];

function lines_to_string($lines): string
{
    return implode('', array_map(function ($line) {
        return implode('', $line);
    }, $lines));
}

function do_round(&$lines): ?string {
    global $memoize_cache;

    $lines_string = lines_to_string($lines);
    if (isset($memoize_cache[$lines_string])) {
        $lines = $memoize_cache[$lines_string];
        return lines_to_string($lines);
    }

    for ($i = 0; $i < 4; $i++) {
        tilt_all_north($lines);
        $lines = rotate_clockwise($lines);
    }

    $memoize_cache[$lines_string] = $lines;
    return null;
}

$orig_lines = file($filePath);
$orig_lines = array_filter($orig_lines, function ($line) {
    return !empty(trim($line));
});
$orig_lines = array_map(function ($line) {
    return trim($line);
}, $orig_lines);
$orig_lines = array_map(function ($line) {
    return str_split($line);
}, $orig_lines);

$first_part_lines = $orig_lines;
tilt_all_north($first_part_lines);

$scores = score($first_part_lines);

echo "First part: " . $scores . PHP_EOL;

$second_part_lines = $orig_lines;

$wanted = 1_000_000_000;
$loops_to = null;
while (true) {
    $loops_to = do_round($second_part_lines);
    if ($loops_to != null) {
        break;
    }

    $wanted--;
}


$loop_len = 1;
$next = lines_to_string($memoize_cache[$loops_to]);
while($next != $loops_to) {
    $next = lines_to_string($memoize_cache[$next]);
    $loop_len++;
}

$wanted = $wanted % $loop_len;

for ($i = 1; $i < $wanted; $i++) {
    do_round($second_part_lines);
}

$scores = score($second_part_lines);

echo "Second part: " . $scores . PHP_EOL;