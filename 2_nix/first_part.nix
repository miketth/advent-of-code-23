let
  common = (import ./common.nix);
  input = builtins.readFile ./inputs/input;
  lines = builtins.split "\n" input;
  processedLines = common.processLines lines;

  maxItems = {
    red = 12;
    green = 13;
    blue = 14;
  };

  isPossible = outcome:
    (!(outcome ? blue)  || outcome.blue  <= maxItems.blue) &&
    (!(outcome ? red)   || outcome.red   <= maxItems.red)  &&
    (!(outcome ? green) || outcome.green <= maxItems.green);

  allOutcomesPossible = processedLine:
    builtins.all isPossible processedLine.outcomes;

  possibleLines = builtins.filter allOutcomesPossible processedLines;
  sumLines = accumulator: processedLine:
    accumulator + processedLine.id;

  sumOfIds = builtins.foldl' sumLines 0 possibleLines;
in
{
  solution = sumOfIds;
}