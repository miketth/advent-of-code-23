.PHONY: run

days=1_elixir 2_nix 3_haskell 4_rust 5_prolog 6_go 7_python 8_zsh 9_erlang 10_kotlin 11_java 12_c 13_typescript 14_php 15_fish

define run_day
	echo "Running $(1)"
	$(MAKE) -C $(1) run
endef

run:
	$(foreach day, $(days), $(call run_day,$(day)) &&) true

define setup_ci_day
	echo "Setting up $(1)"
	$(MAKE) -C $(1) setup_ci
endef

setup_ci: setup_ci_pre
	$(foreach day, $(days), $(call setup_ci_day,$(day)) &&) true

setup_ci_pre:
	apt update

ci: setup_ci run
