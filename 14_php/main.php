<?php

$filePath = 'inputs/input';

function transpose($array): array
{
    $transposed = [];
    foreach ($array as $rowKey => $row) {
        foreach ($row as $colKey => $value) {
            $transposed[$colKey][$rowKey] = $value;
        }
    }
    return $transposed;
}

function find_first_dot_before($line, $end): ?int
{
    $first_dot = null;
    for ($i = $end; $i >= 0; $i--) {
        if ($line[$i] === '.') {
            $first_dot = $i;
        }
        if ($line[$i] === '#') {
            break;
        }
    }

    return $first_dot;
}

function tilt($line): array
{
    foreach ($line as $key => $value) {
        if ($value === 'O') {
            $first_dot = find_first_dot_before($line, $key - 1);
            if ($first_dot !== null) {
                $line[$first_dot] = 'O';
                $line[$key] = '.';
            }
        }
    }
    return $line;
}

function score($line): int
{
    $length = count($line);
    $score = 0;
    foreach ($line as $i => $value) {
        if ($value === 'O') {
            $score += $length - $i;
        }
    }
    return $score;
}

$lines = file($filePath);
$lines = array_filter($lines, function ($line) {
    return !empty(trim($line));
});
$lines = array_map(function ($line) {
    return trim($line);
}, $lines);
$lines = array_map(function ($line) {
    return str_split($line);
}, $lines);


$lines = transpose($lines);
foreach ($lines as $i => $line) {
    $lines[$i] = tilt($line);
}

$scores = array_map(function ($line) {
    return score($line);
}, $lines);

$sum = array_sum($scores);

echo "First part: " . $sum . PHP_EOL;


