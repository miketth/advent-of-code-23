let
  lib = import <nixpkgs/lib>;

  filterEmpty = lines:
    let
      lines_nonempty = builtins.filter (line: line != "") lines;
      lines_nonlist = builtins.filter (line: line != []) lines_nonempty;
    in lines_nonlist;

  processItem = item: let
    parts = builtins.split " " item;
    num_str = builtins.head parts;
    num = lib.strings.toInt num_str;
    name = lib.lists.last parts;
  in { inherit num name; };

  mergeItems = accumulator: elem:
    accumulator // { ${elem.name} = elem.num; };

  processOutcome = outcome: let
    parts = filterEmpty (builtins.split ", " outcome);
    parts_processed = builtins.map processItem parts;
    items = builtins.foldl' mergeItems {} parts_processed;
  in items;

  processLine = line: let
    parts = builtins.split ": " line;

    game = builtins.head parts;
    gameparts = builtins.split " " game;
    id_str = lib.lists.last gameparts;
    id = lib.strings.toInt id_str;

    outcomes_str = lib.lists.last parts;
    outcomes = filterEmpty (builtins.split "; " outcomes_str);
    outcomes_processed = builtins.map processOutcome outcomes;
  in { inherit id; outcomes = outcomes_processed; };

  processLines = lines: builtins.map processLine (filterEmpty lines);

in
{
  inherit (lib) lists strings;
  inherit processLines filterEmpty;

}