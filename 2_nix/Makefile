.PHONY: run

run:
	nix-instantiate --eval main.nix

setup_ci:
	sh <(curl -L https://nixos.org/nix/install) --daemon --yes
	source /etc/profile
	nohup /nix/store/*-nix-*/bin/nix-daemon &

