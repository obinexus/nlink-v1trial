# NexusLink SemVerX - Enhanced Library Architecture
# Systematic .so/.a library builds with proper linking
# Aegis Project Phase 1.5 - Production Implementation

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pthread -I./include -fPIC
LDFLAGS = -lpthread
DEBUG_FLAGS = -g -DDEBUG -O0
RELEASE_FLAGS = -O2 -DNDEBUG

# Directory structure
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
LIB_DIR = lib
INCLUDE_DIR = include

# Source files
CORE_SOURCES = $(SRC_DIR)/core/config.c
CLI_SOURCES = $(SRC_DIR)/cli/parser_interface.c
MAIN_SOURCE = $(SRC_DIR)/main.c

# Object files (PIC for shared library compatibility)
CORE_OBJECTS = $(BUILD_DIR)/core/config.o
CLI_OBJECTS = $(BUILD_DIR)/cli/parser_interface.o
MAIN_OBJECT = $(BUILD_DIR)/main.o

LIB_OBJECTS = $(CORE_OBJECTS) $(CLI_OBJECTS)
ALL_OBJECTS = $(LIB_OBJECTS) $(MAIN_OBJECT)

# Library targets
STATIC_LIB = $(LIB_DIR)/libnlink.a
SHARED_LIB = $(LIB_DIR)/libnlink.so
EXECUTABLE = $(BIN_DIR)/nlink

# Version information for shared library
SONAME = libnlink.so.1
VERSION = 1.5.0

# =============================================================================
# BUILD TARGETS
# =============================================================================

.PHONY: all clean directories debug release shared static

# Default target - build both libraries and executable
all: directories $(STATIC_LIB) $(SHARED_LIB) $(EXECUTABLE)

# Build only static library
static: directories $(STATIC_LIB)

# Build only shared library  
shared: directories $(SHARED_LIB)

# Create directories
directories:
	@mkdir -p $(BUILD_DIR)/core $(BUILD_DIR)/cli
	@mkdir -p $(BIN_DIR) $(LIB_DIR)

# =============================================================================
# OBJECT COMPILATION (PIC for shared library compatibility)
# =============================================================================

# Core objects
$(BUILD_DIR)/core/%.o: $(SRC_DIR)/core/%.c
	@echo "[COMPILE] Core: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(RELEASE_FLAGS) -c $< -o $@

# CLI objects
$(BUILD_DIR)/cli/%.o: $(SRC_DIR)/cli/%.c
	@echo "[COMPILE] CLI: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(RELEASE_FLAGS) -c $< -o $@

# Main object (non-PIC for executable)
$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c
	@echo "[COMPILE] Main: $<"
	$(CC) $(CFLAGS) $(RELEASE_FLAGS) -c $< -o $@

# =============================================================================
# LIBRARY TARGETS
# =============================================================================

# Static library (.a)
$(STATIC_LIB): $(LIB_OBJECTS)
	@echo "[LIBRARY] Creating static library: $@"
	ar rcs $@ $^
	@echo "✅ Static library created: $(STATIC_LIB)"

# Shared library (.so) with proper versioning
$(SHARED_LIB): $(LIB_OBJECTS)
	@echo "[LIBRARY] Creating shared library: $@"
	$(CC) -shared -Wl,-soname,$(SONAME) -o $@ $^ $(LDFLAGS)
	@cd $(LIB_DIR) && ln -sf libnlink.so $(SONAME)
	@echo "✅ Shared library created: $(SHARED_LIB)"
	@echo "✅ Symbolic link created: $(LIB_DIR)/$(SONAME)"

# =============================================================================
# EXECUTABLE TARGETS
# =============================================================================

# Executable linked with static library (default)
$(EXECUTABLE): $(MAIN_OBJECT) $(STATIC_LIB)
	@echo "[LINK] Creating NexusLink executable (static linking): $@"
	$(CC) $(MAIN_OBJECT) -L$(LIB_DIR) -lnlink $(LDFLAGS) -o $@
	@echo "✅ SUCCESS: NexusLink executable created at $@"

# Executable with dynamic linking (alternative)
$(BIN_DIR)/nlink-dynamic: $(MAIN_OBJECT) $(SHARED_LIB)
	@echo "[LINK] Creating NexusLink executable (dynamic linking): $@"
	$(CC) $(MAIN_OBJECT) -L$(LIB_DIR) -lnlink $(LDFLAGS) -o $@
	@echo "✅ Dynamic executable created: $@"

# =============================================================================
# BUILD VARIANTS
# =============================================================================

debug: CFLAGS += $(DEBUG_FLAGS)
debug: RELEASE_FLAGS = $(DEBUG_FLAGS)
debug: all

release: CFLAGS += $(RELEASE_FLAGS)
release: all

# =============================================================================
# TESTING AND VALIDATION
# =============================================================================

test: $(EXECUTABLE)
	@echo "[TEST] Running comprehensive functionality test"
	@echo "=== Testing Static Executable ==="
	$(EXECUTABLE) --help
	@echo ""
	$(EXECUTABLE) --version
	@echo ""
	$(EXECUTABLE) --config-check
	@echo "✅ All tests passed"

test-dynamic: $(BIN_DIR)/nlink-dynamic
	@echo "[TEST] Testing dynamic executable"
	@echo "Setting library path..."
	@LD_LIBRARY_PATH=$(LIB_DIR) $(BIN_DIR)/nlink-dynamic --version

validate: $(EXECUTABLE) $(SHARED_LIB)
	@echo "[VALIDATE] Comprehensive library validation"
	@echo "--- Static Library ---"
	@file $(STATIC_LIB)
	@ar t $(STATIC_LIB)
	@echo ""
	@echo "--- Shared Library ---"
	@file $(SHARED_LIB)
	@ldd $(SHARED_LIB) || echo "No dynamic dependencies (expected)"
	@echo ""
	@echo "--- Executable ---"
	@file $(EXECUTABLE)
	@ldd $(EXECUTABLE)
	@echo ""
	@echo "--- Symbol Validation ---"
	@nm $(STATIC_LIB) | grep -E "nlink_" | head -10
	@echo "✅ Library architecture validation completed"

# =============================================================================
# INSTALLATION TARGETS
# =============================================================================

PREFIX ?= /usr/local
INSTALL_BIN_DIR = $(PREFIX)/bin
INSTALL_LIB_DIR = $(PREFIX)/lib
INSTALL_INCLUDE_DIR = $(PREFIX)/include

install: all
	@echo "[INSTALL] Installing NexusLink system-wide"
	@mkdir -p $(INSTALL_BIN_DIR) $(INSTALL_LIB_DIR) $(INSTALL_INCLUDE_DIR)
	@cp $(EXECUTABLE) $(INSTALL_BIN_DIR)/
	@cp $(STATIC_LIB) $(SHARED_LIB) $(INSTALL_LIB_DIR)/
	@cp -r $(INCLUDE_DIR)/nlink_semverx $(INSTALL_INCLUDE_DIR)/
	@ldconfig || echo "Note: Run 'sudo ldconfig' to update shared library cache"
	@echo "✅ Installation completed to $(PREFIX)"

# =============================================================================
# CLEANUP
# =============================================================================

clean:
	@echo "[CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(LIB_DIR)

distclean: clean
	@echo "[DISTCLEAN] Deep cleaning"
	@find . -name "*.o" -delete
	@find . -name "*.so" -delete
	@find . -name "*.a" -delete

# =============================================================================
# HELP
# =============================================================================

help:
	@echo "NexusLink SemVerX Enhanced Build System"
	@echo "======================================"
	@echo "Targets:"
	@echo "  all          - Build libraries and executable (default)"
	@echo "  static       - Build only static library (.a)"
	@echo "  shared       - Build only shared library (.so)"
	@echo "  debug        - Debug build with symbols"
	@echo "  release      - Optimized release build"
	@echo "  test         - Test static executable"
	@echo "  test-dynamic - Test dynamic executable"
	@echo "  validate     - Comprehensive validation"
	@echo "  install      - System-wide installation"
	@echo "  clean        - Remove build artifacts"
	@echo "  help         - Show this help"
	@echo ""
	@echo "Library Architecture:"
	@echo "  Static Library:  $(STATIC_LIB)"
	@echo "  Shared Library:  $(SHARED_LIB)"
	@echo "  Executable:      $(EXECUTABLE)"

# =============================================================================
# DEPENDENCY TRACKING
# =============================================================================

-include $(ALL_OBJECTS:.o=.d)

$(BUILD_DIR)/%.d: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -MM -MT $(@:.d=.o) $< > $@
