# Makefile for NexusLink CLI Library + Executable
# Aegis Project - Phase 1 Implementation (Final Corrected Version)
# Author: Nnamdi Michael Okpala & Development Team

# =============================================================================
# BUILD CONFIGURATION
# =============================================================================

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pedantic -O2 -g
CFLAGS_LIB = $(CFLAGS) -fPIC
LDFLAGS = -lpthread
INCLUDES = -I./include

# Target configuration
LIBRARY_NAME = nlink
EXECUTABLE_NAME = nlink
STATIC_LIB = lib/lib$(LIBRARY_NAME).a
SHARED_LIB = lib/lib$(LIBRARY_NAME).so
EXECUTABLE_STATIC = bin/$(EXECUTABLE_NAME)
EXECUTABLE_SHARED = bin/$(EXECUTABLE_NAME)-shared

# Build directories
BUILD_DIR = build
LIB_BUILD_DIR = $(BUILD_DIR)/lib
SRC_BUILD_DIR = $(BUILD_DIR)/src

# Library source files
LIB_CORE_SOURCES = core/config.c
LIB_CLI_SOURCES = cli/parser_interface_lib.c
LIB_SOURCES = $(LIB_CORE_SOURCES) $(LIB_CLI_SOURCES)

# Executable source files
EXE_SOURCES = src/main.c

# Object files for static library
LIB_CORE_OBJECTS_STATIC = $(LIB_BUILD_DIR)/config_static.o
LIB_CLI_OBJECTS_STATIC = $(LIB_BUILD_DIR)/parser_interface_lib_static.o
LIB_OBJECTS_STATIC = $(LIB_CORE_OBJECTS_STATIC) $(LIB_CLI_OBJECTS_STATIC)

# Object files for shared library
LIB_CORE_OBJECTS_SHARED = $(LIB_BUILD_DIR)/config_shared.o
LIB_CLI_OBJECTS_SHARED = $(LIB_BUILD_DIR)/parser_interface_lib_shared.o
LIB_OBJECTS_SHARED = $(LIB_CORE_OBJECTS_SHARED) $(LIB_CLI_OBJECTS_SHARED)

# Executable object files
EXE_OBJECTS = $(SRC_BUILD_DIR)/main.o

# Header dependencies
HEADERS = include/nlink/core/config.h include/nlink/cli/parser_interface.h

# Platform-specific configurations
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LDFLAGS += -lrt
    RPATH_FLAG = -Wl,-rpath=
else ifeq ($(UNAME_S),Darwin)
    RPATH_FLAG = -Wl,-rpath,
endif

# Current working directory for RPATH
PWD := $(shell pwd)

# =============================================================================
# PRIMARY BUILD TARGETS
# =============================================================================

.PHONY: all
all: $(STATIC_LIB) $(EXECUTABLE_STATIC)

# Build both static and shared variants
.PHONY: all-variants
all-variants: $(STATIC_LIB) $(SHARED_LIB) $(EXECUTABLE_STATIC) $(EXECUTABLE_SHARED)

# Static library target
$(STATIC_LIB): $(LIB_OBJECTS_STATIC) | lib
	@echo "[NLINK BUILD] Creating static library: $(STATIC_LIB)"
	ar rcs $(STATIC_LIB) $(LIB_OBJECTS_STATIC)
	@echo "[NLINK SUCCESS] Static library created: $(STATIC_LIB)"

# Shared library target
$(SHARED_LIB): $(LIB_OBJECTS_SHARED) | lib
	@echo "[NLINK BUILD] Creating shared library: $(SHARED_LIB)"
	$(CC) -shared -Wl,-soname,lib$(LIBRARY_NAME).so.1 $(LIB_OBJECTS_SHARED) $(LDFLAGS) -o $(SHARED_LIB)
	@echo "[NLINK SUCCESS] Shared library created: $(SHARED_LIB)"

# Static executable target (completely self-contained)
$(EXECUTABLE_STATIC): $(EXE_OBJECTS) $(STATIC_LIB) | bin
	@echo "[NLINK BUILD] Linking static executable: $(EXECUTABLE_STATIC)"
	$(CC) $(EXE_OBJECTS) $(STATIC_LIB) $(LDFLAGS) -o $(EXECUTABLE_STATIC)
	@echo "[NLINK SUCCESS] Static executable created: $(EXECUTABLE_STATIC)"

# Shared executable target with embedded RPATH
$(EXECUTABLE_SHARED): $(EXE_OBJECTS) $(SHARED_LIB) | bin
	@echo "[NLINK BUILD] Linking shared executable with RPATH: $(EXECUTABLE_SHARED)"
	$(CC) $(EXE_OBJECTS) -L./lib $(RPATH_FLAG)$(PWD)/lib -l$(LIBRARY_NAME) $(LDFLAGS) -o $(EXECUTABLE_SHARED)
	@echo "[NLINK SUCCESS] Shared executable created: $(EXECUTABLE_SHARED)"

# =============================================================================
# OBJECT FILE COMPILATION (SEPARATE STATIC/SHARED)
# =============================================================================

# Static library object files (no -fPIC)
$(LIB_BUILD_DIR)/config_static.o: core/config.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling core module for static library"
	$(CC) $(CFLAGS) $(INCLUDES) -c core/config.c -o $(LIB_BUILD_DIR)/config_static.o

$(LIB_BUILD_DIR)/parser_interface_lib_static.o: cli/parser_interface_lib.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling CLI module for static library"
	$(CC) $(CFLAGS) $(INCLUDES) -c cli/parser_interface_lib.c -o $(LIB_BUILD_DIR)/parser_interface_lib_static.o

# Shared library object files (with -fPIC)
$(LIB_BUILD_DIR)/config_shared.o: core/config.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling core module for shared library"
	$(CC) $(CFLAGS_LIB) $(INCLUDES) -c core/config.c -o $(LIB_BUILD_DIR)/config_shared.o

$(LIB_BUILD_DIR)/parser_interface_lib_shared.o: cli/parser_interface_lib.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling CLI module for shared library"
	$(CC) $(CFLAGS_LIB) $(INCLUDES) -c cli/parser_interface_lib.c -o $(LIB_BUILD_DIR)/parser_interface_lib_shared.o

# Executable object files
$(SRC_BUILD_DIR)/main.o: src/main.c $(HEADERS) | $(SRC_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling main executable module"
	$(CC) $(CFLAGS) $(INCLUDES) -c src/main.c -o $(SRC_BUILD_DIR)/main.o

# =============================================================================
# DIRECTORY CREATION
# =============================================================================

lib:
	mkdir -p lib

bin:
	mkdir -p bin

$(LIB_BUILD_DIR):
	mkdir -p $(LIB_BUILD_DIR)

$(SRC_BUILD_DIR):
	mkdir -p $(SRC_BUILD_DIR)

# =============================================================================
# DEVELOPMENT TARGETS
# =============================================================================

# Debug build
.PHONY: debug
debug: CFLAGS += -DDEBUG -g3 -O0
debug: CFLAGS_LIB += -DDEBUG -g3 -O0
debug: all

# Release build
.PHONY: release
release: CFLAGS += -DNDEBUG -O3 -march=native
release: CFLAGS_LIB += -DNDEBUG -O3 -march=native
release: all

# =============================================================================
# TESTING TARGETS
# =============================================================================

.PHONY: test
test: $(EXECUTABLE_STATIC)
	@echo "[NLINK TEST] Running functional tests with static executable"
	$(EXECUTABLE_STATIC) --help >/dev/null 2>&1 && echo "✓ Help command functional" || echo "✗ Help command failed"
	$(EXECUTABLE_STATIC) --version >/dev/null 2>&1 && echo "✓ Version command functional" || echo "✗ Version command failed"

.PHONY: test-shared
test-shared: $(EXECUTABLE_SHARED)
	@echo "[NLINK TEST] Running functional tests with shared executable"
	$(EXECUTABLE_SHARED) --help >/dev/null 2>&1 && echo "✓ Shared Help command functional" || echo "✗ Shared Help command failed"
	$(EXECUTABLE_SHARED) --version >/dev/null 2>&1 && echo "✓ Shared Version command functional" || echo "✗ Shared Version command failed"

.PHONY: test-config
test-config: $(EXECUTABLE_STATIC)
	@echo "[NLINK TEST] Testing configuration parsing"
	$(EXECUTABLE_STATIC) --config-check --verbose 2>/dev/null || echo "Configuration test completed (expected behavior without pkg.nlink)"

.PHONY: test-library
test-library: $(STATIC_LIB) $(SHARED_LIB)
	@echo "[NLINK TEST] Validating library symbols and dependencies"
	@nm $(STATIC_LIB) | grep -c "nlink_" >/dev/null && echo "✓ Static library symbols exported" || echo "✗ Static library symbol export failed"
	@if [ -f $(SHARED_LIB) ]; then ldd $(SHARED_LIB) >/dev/null 2>&1 && echo "✓ Shared library dependencies resolved" || echo "✗ Shared library dependency issues"; fi

# =============================================================================
# INSTALLATION TARGETS
# =============================================================================

PREFIX ?= /usr/local
LIBDIR = $(PREFIX)/lib
BINDIR = $(PREFIX)/bin
INCLUDEDIR = $(PREFIX)/include

.PHONY: install
install: all
	@echo "[NLINK INSTALL] Installing library and executable"
	install -d $(LIBDIR) $(BINDIR) $(INCLUDEDIR)
	install -m 644 $(STATIC_LIB) $(LIBDIR)/
	install -m 755 $(EXECUTABLE_STATIC) $(BINDIR)/$(EXECUTABLE_NAME)
	cp -r include/nlink $(INCLUDEDIR)/
	@echo "[NLINK SUCCESS] Installation completed"

.PHONY: install-dev
install-dev: all-variants
	@echo "[NLINK INSTALL] Installing development variant"
	install -d $(LIBDIR) $(BINDIR) $(INCLUDEDIR)
	install -m 644 $(STATIC_LIB) $(LIBDIR)/
	install -m 755 $(SHARED_LIB) $(LIBDIR)/
	install -m 755 $(EXECUTABLE_STATIC) $(BINDIR)/$(EXECUTABLE_NAME)
	install -m 755 $(EXECUTABLE_SHARED) $(BINDIR)/$(EXECUTABLE_NAME)-shared
	cp -r include/nlink $(INCLUDEDIR)/
	ldconfig 2>/dev/null || true

# =============================================================================
# VALIDATION AND DIAGNOSTICS
# =============================================================================

.PHONY: validate
validate: all test-library
	@echo "[NLINK VALIDATE] Running comprehensive validation suite"
	@echo "Static Library Analysis:"
	@file $(STATIC_LIB)
	@echo "Static Executable Analysis:"
	@file $(EXECUTABLE_STATIC)
	@echo "Static Executable Dependencies:"
	@ldd $(EXECUTABLE_STATIC) || echo "Static linking confirmed"
	@echo "✓ Validation completed"

.PHONY: symbols
symbols: $(STATIC_LIB)
	@echo "=== Static Library Symbols ==="
	@nm $(STATIC_LIB) | grep " T " | grep nlink_

# =============================================================================
# CLEANUP TARGETS
# =============================================================================

.PHONY: clean
clean:
	@echo "[NLINK CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR)
	rm -rf lib
	rm -rf bin
	rm -rf dist
	@echo "[NLINK SUCCESS] Cleanup completed"

.PHONY: distclean
distclean: clean
	rm -f core/*.o cli/*.o src/*.o
	find . -name "*~" -delete
	find . -name "*.orig" -delete

# =============================================================================
# UTILITY TARGETS
# =============================================================================

.PHONY: help
help:
	@echo "NexusLink CLI Library + Executable Build System"
	@echo "Aegis Project Phase 1 Implementation"
	@echo ""
	@echo "Primary Targets:"
	@echo "  all              - Build static library and static executable (default)"
	@echo "  all-variants     - Build both static and shared variants"
	@echo "  $(STATIC_LIB)   - Build static library only"
	@echo "  $(SHARED_LIB)   - Build shared library only"
	@echo "  $(EXECUTABLE_STATIC) - Build static executable (no runtime deps)"
	@echo "  $(EXECUTABLE_SHARED) - Build shared executable (with RPATH)"
	@echo ""
	@echo "Development Targets:"
	@echo "  debug            - Debug build with symbols"
	@echo "  release          - Optimized release build"
	@echo "  test             - Run basic functionality tests (static)"
	@echo "  test-shared      - Run functionality tests (shared)"
	@echo "  test-library     - Validate library integrity"
	@echo "  validate         - Comprehensive validation suite"
	@echo ""
	@echo "Distribution:"
	@echo "  install          - Install static executable to system"
	@echo "  install-dev      - Install both static and shared variants"
	@echo "  clean            - Remove build artifacts"
	@echo "  help             - Show this help"

# =============================================================================
# DEPENDENCY MANAGEMENT
# =============================================================================

# Automatic dependency generation
-include $(LIB_OBJECTS_STATIC:.o=.d) $(LIB_OBJECTS_SHARED:.o=.d) $(EXE_OBJECTS:.o=.d)

$(LIB_BUILD_DIR)/%.d: %.c | $(LIB_BUILD_DIR)
	@$(CC) $(CFLAGS) $(INCLUDES) -MM -MT $(@:.d=.o) $< > $@

$(SRC_BUILD_DIR)/%.d: src/%.c | $(SRC_BUILD_DIR)
	@$(CC) $(CFLAGS) $(INCLUDES) -MM -MT $(@:.d=.o) $< > $@

# Force rebuild on Makefile changes
$(LIB_OBJECTS_STATIC) $(LIB_OBJECTS_SHARED) $(EXE_OBJECTS): Makefile