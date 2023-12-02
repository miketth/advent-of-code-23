.PHONY: run

days=1_elixir

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

setup_ci:
	$(foreach day, $(days), $(call setup_ci_day,$(day)) )

ci: setup_ci run
