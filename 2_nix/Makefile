.PHONY: run

run:
	docker run --rm -it -v $(PWD):/aoc --workdir /aoc nixos/nix nix-instantiate --eval main.nix

setup_ci:
	docker pull nixos/nix

