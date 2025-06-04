# Makefile for NexusLink CLI Library + Executable
# Aegis Project - Phase 1 Implementation
# Author: Nnamdi Michael Okpala & Development Team

# =============================================================================
# BUILD CONFIGURATION
# =============================================================================

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pedantic -O2 -g -fPIC
LDFLAGS = -lpthread
INCLUDES = -I./include

# Target configuration
LIBRARY_NAME = nlink
EXECUTABLE_NAME = nlink
STATIC_LIB = lib/lib$(LIBRARY_NAME).a
SHARED_LIB = lib/lib$(LIBRARY_NAME).so
EXECUTABLE = bin/$(EXECUTABLE_NAME)

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

# Object files
LIB_CORE_OBJECTS = $(LIB_BUILD_DIR)/config.o
LIB_CLI_OBJECTS = $(LIB_BUILD_DIR)/parser_interface_lib.o
LIB_OBJECTS = $(LIB_CORE_OBJECTS) $(LIB_CLI_OBJECTS)

EXE_OBJECTS = $(SRC_BUILD_DIR)/main.o

# Header dependencies
HEADERS = include/nlink/core/config.h include/nlink/cli/parser_interface.h

# =============================================================================
# PRIMARY BUILD TARGETS
# =============================================================================

.PHONY: all
all: $(STATIC_LIB) $(SHARED_LIB) $(EXECUTABLE)

# Static library target
$(STATIC_LIB): $(LIB_OBJECTS) | lib
	@echo "[NLINK BUILD] Creating static library: $(STATIC_LIB)"
	ar rcs $(STATIC_LIB) $(LIB_OBJECTS)
	@echo "[NLINK SUCCESS] Static library created: $(STATIC_LIB)"

# Shared library target
$(SHARED_LIB): $(LIB_OBJECTS) | lib
	@echo "[NLINK BUILD] Creating shared library: $(SHARED_LIB)"
	$(CC) -shared $(LIB_OBJECTS) $(LDFLAGS) -o $(SHARED_LIB)
	@echo "[NLINK SUCCESS] Shared library created: $(SHARED_LIB)"

# Executable target (using static library)
$(EXECUTABLE): $(EXE_OBJECTS) $(STATIC_LIB) | bin
	@echo "[NLINK BUILD] Linking executable: $(EXECUTABLE)"
	$(CC) $(EXE_OBJECTS) -L./lib -l$(LIBRARY_NAME) $(LDFLAGS) -o $(EXECUTABLE)
	@echo "[NLINK SUCCESS] Executable created: $(EXECUTABLE)"

# Alternative executable using shared library
.PHONY: executable-shared
executable-shared: $(EXE_OBJECTS) $(SHARED_LIB) | bin
	@echo "[NLINK BUILD] Linking executable with shared library"
	$(CC) $(EXE_OBJECTS) -L./lib -l$(LIBRARY_NAME) $(LDFLAGS) -o $(EXECUTABLE)

# =============================================================================
# OBJECT FILE COMPILATION
# =============================================================================

# Library object files
$(LIB_BUILD_DIR)/config.o: core/config.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling library core module"
	$(CC) $(CFLAGS) $(INCLUDES) -c core/config.c -o $(LIB_BUILD_DIR)/config.o

$(LIB_BUILD_DIR)/parser_interface_lib.o: cli/parser_interface_lib.c $(HEADERS) | $(LIB_BUILD_DIR)
	@echo "[NLINK BUILD] Compiling library CLI module"
	$(CC) $(CFLAGS) $(INCLUDES) -c cli/parser_interface_lib.c -o $(LIB_BUILD_DIR)/parser_interface_lib.o

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
debug: all

# Release build
.PHONY: release
release: CFLAGS += -DNDEBUG -O3 -march=native
release: all

# =============================================================================
# TESTING TARGETS
# =============================================================================

.PHONY: test
test: $(EXECUTABLE)
	@echo "[NLINK TEST] Running functional tests"
	LD_LIBRARY_PATH=./lib $(EXECUTABLE) --help
	LD_LIBRARY_PATH=./lib $(EXECUTABLE) --version

.PHONY: test-config
test-config: $(EXECUTABLE)
	@echo "[NLINK TEST] Testing configuration parsing"
	LD_LIBRARY_PATH=./lib $(EXECUTABLE) --config-check --verbose || true

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
	install -m 755 $(SHARED_LIB) $(LIBDIR)/
	install -m 755 $(EXECUTABLE) $(BINDIR)/
	cp -r include/nlink $(INCLUDEDIR)/
	ldconfig || true
	@echo "[NLINK SUCCESS] Installation completed"

# =============================================================================
# CLEANUP TARGETS
# =============================================================================

.PHONY: clean
clean:
	@echo "[NLINK CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR)
	rm -rf lib
	rm -rf bin
	@echo "[NLINK SUCCESS] Cleanup completed"

.PHONY: distclean
distclean: clean
	rm -f core/*.o cli/*.o src/*.o
	find . -name "*~" -delete

# =============================================================================
# UTILITY TARGETS
# =============================================================================

.PHONY: help
help:
	@echo "NexusLink CLI Library + Executable Build System"
	@echo "Aegis Project Phase 1 Implementation"
	@echo ""
	@echo "Targets:"
	@echo "  all              - Build static library, shared library, and executable"
	@echo "  $(STATIC_LIB)   - Build static library only"
	@echo "  $(SHARED_LIB)   - Build shared library only"
	@echo "  $(EXECUTABLE)    - Build executable (using static library)"
	@echo "  executable-shared - Build executable using shared library"
	@echo "  debug            - Debug build with symbols"
	@echo "  release          - Optimized release build"
	@echo "  test             - Run basic functionality tests"
	@echo "  test-config      - Test configuration parsing"
	@echo "  install          - Install to system (PREFIX=$(PREFIX))"
	@echo "  clean            - Remove build artifacts"
	@echo "  distclean        - Deep cleanup"
	@echo "  help             - Show this help"

# =============================================================================
# DEPENDENCY MANAGEMENT
# =============================================================================

# Automatic dependency generation
-include $(LIB_OBJECTS:.o=.d) $(EXE_OBJECTS:.o=.d)

$(LIB_BUILD_DIR)/%.d: %.c | $(LIB_BUILD_DIR)
	@$(CC) $(CFLAGS) $(INCLUDES) -MM -MT $(@:.d=.o) $< > $@

$(SRC_BUILD_DIR)/%.d: src/%.c | $(SRC_BUILD_DIR)
	@$(CC) $(CFLAGS) $(INCLUDES) -MM -MT $(@:.d=.o) $< > $@

# Force rebuild on Makefile changes
$(LIB_OBJECTS) $(EXE_OBJECTS): Makefile

# Platform-specific configurations
ifeq ($(OS),Windows_NT)
    EXECUTABLE := $(EXECUTABLE).exe
    SHARED_LIB := $(SHARED_LIB:.so=.dll)
    LDFLAGS += -lws2_32
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        LDFLAGS += -lrt
    endif
endif
