#!/usr/bin/env -S nix-instantiate --eval

let
  first_part = (import ./first_part.nix);
in
builtins.trace ''
  First part: ${toString first_part.solution}
'' {
  first_part = first_part.solution;
}
