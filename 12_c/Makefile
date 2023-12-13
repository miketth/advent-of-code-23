.PHONY: run

run: build
	$(BUILD_DIR)/aoc

BUILD_DIR := .build

$(BUILD_DIR)/Makefile:
	mkdir -p $(BUILD_DIR)
	@(cd $(BUILD_DIR) && cmake ..)

build: $(BUILD_DIR)/Makefile
	$(MAKE) -C $(BUILD_DIR)


