# Enhanced Makefile with SemVerX Support - Build Fix Patch
# Addresses: Missing bin/ directory, unused parameter warnings, linking failures

# Compiler configuration with enhanced warning suppression
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pthread -I./include -Wno-unused-parameter
LDFLAGS = -lpthread

# Directory structure
BUILD_DIR = build
BIN_DIR = bin
LIB_DIR = lib

# Source organization
CORE_SOURCES = core/config.c
CLI_SOURCES = cli/parser_interface.c  
SEMVERX_SOURCES = semverx/semverx_parser.c
MAIN_SOURCE = main.c

# Object file mapping
CORE_OBJECTS = $(CORE_SOURCES:core/%.c=$(BUILD_DIR)/core/%.o)
CLI_OBJECTS = $(CLI_SOURCES:cli/%.c=$(BUILD_DIR)/cli/%.o)
SEMVERX_OBJECTS = $(SEMVERX_SOURCES:semverx/%.c=$(BUILD_DIR)/semverx/%.o)
MAIN_OBJECT = $(BUILD_DIR)/main.o

ALL_OBJECTS = $(CORE_OBJECTS) $(CLI_OBJECTS) $(SEMVERX_OBJECTS) $(MAIN_OBJECT)

# Build targets
.PHONY: all clean all-semverx examples-build demo-calculation directories

# Primary build target with directory creation
all: directories $(BIN_DIR)/nlink

# SemVerX-enhanced build target  
all-semverx: directories $(BIN_DIR)/nlink examples-build

# Create necessary directories
directories:
	@mkdir -p $(BUILD_DIR)/core $(BUILD_DIR)/cli $(BUILD_DIR)/semverx
	@mkdir -p $(BIN_DIR) $(LIB_DIR)
	@mkdir -p examples/calculation_pipeline/basic_math/build
	@mkdir -p examples/calculation_pipeline/advanced_math/build
	@mkdir -p examples/calculation_pipeline/shared_orchestration

# Main executable with systematic dependency management
$(BIN_DIR)/nlink: $(ALL_OBJECTS)
	@echo "[BUILD] Linking NexusLink CLI with SemVerX support"
	$(CC) $(ALL_OBJECTS) $(LDFLAGS) -o $@
	@echo "[SUCCESS] NexusLink executable created: $@"

# Core object compilation
$(BUILD_DIR)/core/%.o: core/%.c
	@mkdir -p $(dir $@)
	@echo "[COMPILE] Core: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# CLI object compilation  
$(BUILD_DIR)/cli/%.o: cli/%.c
	@mkdir -p $(dir $@)
	@echo "[COMPILE] CLI: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# SemVerX object compilation (with warning suppression)
$(BUILD_DIR)/semverx/%.o: semverx/%.c
	@mkdir -p $(dir $@)
	@echo "[COMPILE] SemVerX: $<"
	$(CC) $(CFLAGS) -Wno-unused-parameter -c $< -o $@

# Main object compilation
$(BUILD_DIR)/main.o: main.c
	@echo "[COMPILE] Main: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Example components compilation
examples-build: directories
	@echo "[BUILD] Compiling calculation pipeline examples"
	@if [ -f examples/calculation_pipeline/basic_math/src/calculator.c ]; then \
		$(CC) $(CFLAGS) examples/calculation_pipeline/basic_math/src/calculator.c \
		-o examples/calculation_pipeline/basic_math/build/calculator; \
	fi
	@if [ -f examples/calculation_pipeline/advanced_math/src/scientific.c ]; then \
		$(CC) $(CFLAGS) examples/calculation_pipeline/advanced_math/src/scientific.c \
		-o examples/calculation_pipeline/advanced_math/build/scientific; \
	fi

# Demonstration workflow
demo-calculation: all-semverx
	@echo "[DEMO] Starting SemVerX calculation pipeline demonstration"
	@echo "[DEMO] Validating shared artifact coordination"
	@if [ -f $(BIN_DIR)/nlink ]; then \
		$(BIN_DIR)/nlink --semverx-validate --project-root examples/calculation_pipeline; \
	else \
		echo "[ERROR] nlink executable not found"; \
	fi

# Clean build artifacts
clean:
	@echo "[CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(LIB_DIR)
	rm -rf examples/*/build

# Validation targets
validate-build: all-semverx
	@echo "[VALIDATE] Build system verification"
	@ls -la $(BIN_DIR)/nlink
	@$(BIN_DIR)/nlink --version || echo "[INFO] Version command not implemented"

# Development targets
debug: CFLAGS += -g -DDEBUG
debug: all-semverx

release: CFLAGS += -O2 -DNDEBUG
release: all-semverx