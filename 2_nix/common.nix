let
  lib = import <nixpkgs/lib>;
in
{
  inherit (lib) lists strings;

  filterEmpty = lines:
    let
      lines_nonempty = builtins.filter (line: line != "") lines;
      lines_nonlist = builtins.filter (line: line != []) lines_nonempty;
    in lines_nonlist;
}