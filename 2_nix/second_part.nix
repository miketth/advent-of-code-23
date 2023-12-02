let
  common = (import ./common.nix);
  input = builtins.readFile ./inputs/input;
  lines = builtins.split "\n" input;
  processedLines = common.processLines lines;

  max = left: right:
    if left > right then left else right;

  maxOfOutcomes = acc: outcome:
  {
    red =   max (outcome.red or 0)   (acc.red or 0);
    green = max (outcome.green or 0) (acc.green or 0);
    blue =  max (outcome.blue or 0)  (acc.blue or 0);
  };

  minNeeded = line: builtins.foldl' maxOfOutcomes {} line.outcomes;
  powerOfLine = line: let
    minNeededLine = minNeeded line;
  in minNeededLine.red * minNeededLine.green * minNeededLine.blue;

  powerOfLines = builtins.map powerOfLine processedLines;
  sumOfPower = builtins.foldl' builtins.add 0 powerOfLines;
in
{
  solution = sumOfPower;
}