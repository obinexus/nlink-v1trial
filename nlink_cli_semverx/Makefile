# NexusLink SemVerX - Immediate Compilation Fix
# Resolves current build dependencies with minimal changes

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pthread -I./include -I.
LDFLAGS = -lpthread

# Directory structure
BUILD_DIR = build
BIN_DIR = bin
LIB_DIR = lib

# Source files (current structure)
CORE_SOURCES = core/config.c
CLI_SOURCES = cli/parser_interface.c
MAIN_SOURCE = main.c

# Object files
CORE_OBJECTS = $(BUILD_DIR)/core/config.o
CLI_OBJECTS = $(BUILD_DIR)/cli/parser_interface.o
MAIN_OBJECT = $(BUILD_DIR)/main.o

ALL_OBJECTS = $(CORE_OBJECTS) $(CLI_OBJECTS) $(MAIN_OBJECT)

# Build targets
.PHONY: all clean directories

all: directories $(BIN_DIR)/nlink

directories:
	@mkdir -p $(BUILD_DIR)/core $(BUILD_DIR)/cli
	@mkdir -p $(BIN_DIR) $(LIB_DIR)

# Object compilation rules
$(BUILD_DIR)/core/%.o: core/%.c
	@echo "[COMPILE] Core: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/cli/%.o: cli/%.c
	@echo "[COMPILE] CLI: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/main.o: main.c
	@echo "[COMPILE] Main: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Link executable
$(BIN_DIR)/nlink: $(ALL_OBJECTS)
	@echo "[LINK] Creating NexusLink executable"
	$(CC) $(ALL_OBJECTS) $(LDFLAGS) -o $@
	@echo "✅ SUCCESS: NexusLink executable created at $@"

# Utility targets
test: $(BIN_DIR)/nlink
	@echo "[TEST] Testing executable"
	$(BIN_DIR)/nlink --help

clean:
	@echo "[CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(LIB_DIR)

help:
	@echo "NexusLink SemVerX Build System"
	@echo "Targets: all, test, clean, help"
