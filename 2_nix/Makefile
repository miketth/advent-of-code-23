.PHONY: run

run:
	nix-instantiate --eval main.nix

setup_ci:
	curl -L https://nixos.org/nix/install | sh /dev/stdin --daemon --yes
	nohup /nix/store/*-nix-*/bin/nix-daemon &

