let
  common = (import ./common.nix);
  input = builtins.readFile ./inputs/input;
  lines = builtins.split "\n" input;

  lines_nonempty = common.filterEmpty lines;

  processItem = item: let
    parts = builtins.split " " item;
    num_str = builtins.head parts;
    num = common.strings.toInt num_str;
    name = common.lists.last parts;
  in { inherit num name; };

  mergeItems = accumulator: elem:
    accumulator // { ${elem.name} = elem.num; };

  processOutcome = outcome: let
    parts = common.filterEmpty (builtins.split ", " outcome);
    parts_processed = builtins.map processItem parts;
    items = builtins.foldl' mergeItems {} parts_processed;
  in items;

  processLine = line: let
    parts = builtins.split ": " line;

    game = builtins.head parts;
    gameparts = builtins.split " " game;
    id_str = common.lists.last gameparts;
    id = common.strings.toInt id_str;

    outcomes_str = common.lists.last parts;
    outcomes = common.filterEmpty (builtins.split "; " outcomes_str);
    outcomes_processed = builtins.map processOutcome outcomes;
  in { inherit id; outcomes = outcomes_processed; };

  processedLines = builtins.map processLine lines_nonempty;

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