# =============================================================================
# NexusLink QA POC - Production C Library Build System
# OBINexus Engineering - Aegis Project Implementation
# Technical Lead: Nnamdi Michael Okpala
# =============================================================================

# Compiler and build configuration
CC = gcc
AR = ar
CFLAGS = -Wall -Wextra -std=c99 -fPIC -O2 -DNLINK_VERSION=\"1.0.0\"
DEBUG_FLAGS = -g -DDEBUG -O0
LDFLAGS = -shared
ARFLAGS = rcs

# Project structure
PROJECT_NAME = nlink_qa_poc
LIB_NAME = nlink
VERSION = 1.0.0

# Directory structure (standard C library layout)
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj
BIN_DIR = bin
LIB_DIR = lib

# Header organization
CLI_HEADERS = $(INCLUDE_DIR)/$(PROJECT_NAME)/cli
CORE_HEADERS = $(INCLUDE_DIR)/$(PROJECT_NAME)/core
PUBLIC_HEADERS = $(INCLUDE_DIR)

# Source file organization
CLI_SOURCES = $(wildcard $(SRC_DIR)/cli/*.c)
CORE_SOURCES = $(wildcard $(SRC_DIR)/core/*.c)
MAIN_SOURCE = $(SRC_DIR)/main.c

# Object file generation
CLI_OBJECTS = $(CLI_SOURCES:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
CORE_OBJECTS = $(CORE_SOURCES:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
ALL_OBJECTS = $(CLI_OBJECTS) $(CORE_OBJECTS)

# Library targets
STATIC_LIB = $(LIB_DIR)/lib$(LIB_NAME).a
SHARED_LIB = $(LIB_DIR)/lib$(LIB_NAME).so.$(VERSION)
SHARED_LIB_LINK = $(LIB_DIR)/lib$(LIB_NAME).so

# Executable targets
CLI_EXECUTABLE = $(BIN_DIR)/nlink

# Installation paths (following FHS standards)
PREFIX = /usr/local
INSTALL_BIN = $(PREFIX)/bin
INSTALL_LIB = $(PREFIX)/lib
INSTALL_INCLUDE = $(PREFIX)/include

# Include paths for compilation
INCLUDE_PATHS = -I$(INCLUDE_DIR) -I$(CLI_HEADERS) -I$(CORE_HEADERS)

# =============================================================================
# Main Build Targets
# =============================================================================

.PHONY: all clean install uninstall test debug release directories help

# Default target - production build
all: release

# Production release build
release: CFLAGS += -DNDEBUG -O2
release: directories $(STATIC_LIB) $(SHARED_LIB) $(CLI_EXECUTABLE)
	@echo "✅ Production build completed successfully"
	@echo "   Static library: $(STATIC_LIB)"
	@echo "   Shared library: $(SHARED_LIB)"
	@echo "   CLI executable: $(CLI_EXECUTABLE)"

# Debug build with symbols
debug: CFLAGS += $(DEBUG_FLAGS)
debug: directories $(STATIC_LIB) $(SHARED_LIB) $(CLI_EXECUTABLE)
	@echo "🐛 Debug build completed with symbols"

# Create directory structure
directories:
	@mkdir -p $(OBJ_DIR)/cli $(OBJ_DIR)/core $(BIN_DIR) $(LIB_DIR)

# =============================================================================
# Library Build Targets
# =============================================================================

# Static library (.a) - for static linking
$(STATIC_LIB): $(ALL_OBJECTS)
	@echo "[AR] Creating static library: $@"
	$(AR) $(ARFLAGS) $@ $^

# Shared library (.so) - for dynamic linking
$(SHARED_LIB): $(ALL_OBJECTS)
	@echo "[LD] Creating shared library: $@"
	$(CC) $(LDFLAGS) -Wl,-soname,lib$(LIB_NAME).so.1 -o $@ $^
	@ln -sf lib$(LIB_NAME).so.$(VERSION) $(SHARED_LIB_LINK)

# CLI executable linking against our library
$(CLI_EXECUTABLE): $(STATIC_LIB) $(SRC_DIR)/main.c
	@echo "[CC] Building CLI executable: $@"
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -L$(LIB_DIR) $(SRC_DIR)/main.c -l$(LIB_NAME) -o $@

# =============================================================================
# Object File Compilation Rules
# =============================================================================

# CLI module objects
$(OBJ_DIR)/cli/%.o: $(SRC_DIR)/cli/%.c
	@echo "[CC] Compiling CLI module: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@

# Core module objects  
$(OBJ_DIR)/core/%.o: $(SRC_DIR)/core/%.c
	@echo "[CC] Compiling core module: $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@

# =============================================================================
# Installation Targets
# =============================================================================

install: all
	@echo "[INSTALL] Installing NexusLink library system-wide"
	install -d $(INSTALL_BIN) $(INSTALL_LIB) $(INSTALL_INCLUDE)
	install -m 755 $(CLI_EXECUTABLE) $(INSTALL_BIN)/
	install -m 644 $(STATIC_LIB) $(INSTALL_LIB)/
	install -m 755 $(SHARED_LIB) $(INSTALL_LIB)/
	ln -sf lib$(LIB_NAME).so.$(VERSION) $(INSTALL_LIB)/lib$(LIB_NAME).so
	cp -r $(INCLUDE_DIR)/* $(INSTALL_INCLUDE)/
	@echo "✅ Installation completed"
	@echo "   Usage: gcc -lnlink your_program.c"

uninstall:
	@echo "[UNINSTALL] Removing NexusLink library"
	rm -f $(INSTALL_BIN)/nlink
	rm -f $(INSTALL_LIB)/lib$(LIB_NAME).*
	rm -rf $(INSTALL_INCLUDE)/$(PROJECT_NAME)
	@echo "✅ Uninstallation completed"

# =============================================================================
# Development and Testing Targets
# =============================================================================

# Example usage demonstration
example: $(SHARED_LIB)
	@echo "[EXAMPLE] Demonstrating library usage"
	@echo 'int main() { return 0; }' > /tmp/example.c
	$(CC) $(INCLUDE_PATHS) -L$(LIB_DIR) /tmp/example.c -l$(LIB_NAME) -o /tmp/example
	@echo "✅ Example compilation successful: gcc -I$(INCLUDE_DIR) -L$(LIB_DIR) program.c -l$(LIB_NAME)"

# Library information
info:
	@echo "NexusLink Library Build Information"
	@echo "==================================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Library: lib$(LIB_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Static:  $(STATIC_LIB)"
	@echo "Shared:  $(SHARED_LIB)"
	@echo "CLI:     $(CLI_EXECUTABLE)"
	@echo ""
	@echo "Usage Examples:"
	@echo "  Static linking:  gcc -I$(INCLUDE_DIR) -L$(LIB_DIR) program.c -l$(LIB_NAME)"
	@echo "  Dynamic linking: gcc -I$(INCLUDE_DIR) -L$(LIB_DIR) program.c -l$(LIB_NAME)"
	@echo "  Header include:  #include <$(PROJECT_NAME)/cli/parser.h>"
	@echo "  Header include:  #include <$(PROJECT_NAME)/core/config.h>"

# =============================================================================
# Quality Assurance Integration
# =============================================================================

# Test with proper library linking
test-library: $(SHARED_LIB)
	@echo "[TEST] Testing library functionality"
	@if [ -f test/unit/test_config_parsing.c ]; then \
		$(CC) $(CFLAGS) $(INCLUDE_PATHS) -L$(LIB_DIR) \
			test/unit/test_config_parsing.c -l$(LIB_NAME) \
			-o $(BIN_DIR)/test_with_library && \
		$(BIN_DIR)/test_with_library && \
		echo "✅ Library tests passed"; \
	else \
		echo "⚠️  No unit tests found"; \
	fi

# Validate library symbols
check-symbols: $(SHARED_LIB)
	@echo "[SYMBOLS] Checking exported library symbols"
	@nm -D $(SHARED_LIB) | grep -E '(nlink|marshal|config)' || echo "No matching symbols found"
	@objdump -T $(SHARED_LIB) | head -20

# =============================================================================
# Cleanup Targets
# =============================================================================

clean:
	@echo "[CLEAN] Removing build artifacts"
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(LIB_DIR)

distclean: clean
	@echo "[DISTCLEAN] Deep cleaning"
	find . -name "*.o" -delete
	find . -name "*.a" -delete  
	find . -name "*.so*" -delete
	find . -name "*~" -delete

# =============================================================================
# Help and Documentation
# =============================================================================

help:
	@echo "NexusLink C Library Build System"
	@echo "================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  all              - Production build (default)"
	@echo "  release          - Optimized production build"
	@echo "  debug            - Debug build with symbols"
	@echo "  clean            - Remove build artifacts"
	@echo "  distclean        - Deep clean all generated files"
	@echo ""
	@echo "Library Targets:"
	@echo "  $(STATIC_LIB)   - Static library"
	@echo "  $(SHARED_LIB)   - Shared library"
	@echo "  $(CLI_EXECUTABLE)        - CLI executable"
	@echo ""
	@echo "Installation:"
	@echo "  install          - Install system-wide"
	@echo "  uninstall        - Remove system installation"
	@echo ""
	@echo "Development:"
	@echo "  example          - Demonstrate library usage"
	@echo "  info             - Show build information"
	@echo "  test-library     - Test library functionality"
	@echo "  check-symbols    - Validate exported symbols"
	@echo ""
	@echo "Usage after build:"
	@echo "  gcc -I$(INCLUDE_DIR) -L$(LIB_DIR) program.c -l$(LIB_NAME)"
	@echo "  #include <$(PROJECT_NAME)/cli/parser.h>"
	@echo "  #include <$(PROJECT_NAME)/core/config.h>"

# =============================================================================
# Dependency tracking (automatic header dependencies)
# =============================================================================

-include $(ALL_OBJECTS:.o=.d)

$(OBJ_DIR)/%.d: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) $(INCLUDE_PATHS) -MM -MT $(@:.d=.o) $< > $@
