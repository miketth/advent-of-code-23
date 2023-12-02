#!/usr/bin/env -S nix-instantiate --eval

let
  first_part = (import ./first_part.nix);
  second_part = (import ./second_part.nix);
in
builtins.trace ''

  First part:  ${toString first_part.solution}
  Second part: ${toString second_part.solution}
'' {
  first_part = first_part.solution;
  second_part = second_part.solution;
}
