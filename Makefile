.PHONY: run

days=1_elixir 2_nix

define run_day
	@echo "Running $(1)"
	$(MAKE) -C $(1) run
endef

run:
	$(foreach day, $(days), $(call run_day,$(day)) )

define setup_ci_day
	@echo "Setting up $(1)"
	@$(MAKE) -C $(1) setup_ci
endef

setup_ci: setup_ci_pre
	$(foreach day, $(days), $(call setup_ci_day,$(day)) )

setup_ci_pre:
	apt update

ci: setup_ci run
