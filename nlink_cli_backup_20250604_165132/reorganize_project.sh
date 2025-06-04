#!/bin/bash

# NexusLink CLI Project Reorganization Script
# Aegis Project - Phase 1 Implementation
# Author: Nnamdi Michael Okpala & Development Team
# Purpose: Reorganize project structure for library + executable architecture

set -e

# =============================================================================
# PROJECT REORGANIZATION CONFIGURATION
# =============================================================================

PROJECT_NAME="NexusLink CLI Configuration Parser"
PROJECT_ROOT="$(pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"
}

log_info() {
    echo -e "${BLUE}[REORGANIZE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# BACKUP AND VALIDATION FUNCTIONS
# =============================================================================

create_backup() {
    log_header "Creating Project Backup"
    
    local backup_dir="${PROJECT_ROOT}_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$backup_dir" ]; then
        log_warning "Backup directory already exists: $backup_dir"
        return 1
    fi
    
    cp -r "$PROJECT_ROOT" "$backup_dir"
    log_success "Project backed up to: $backup_dir"
}

validate_current_structure() {
    log_header "Validating Current Project Structure"
    
    local required_files=(
        "core/config.c"
        "cli/parser_interface.c"
        "include/core/config.h"
        "include/cli/parser_interface.h"
        "Makefile"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            log_error "Required file missing: $file"
            exit 1
        fi
    done
    
    log_success "Current structure validation complete"
}

# =============================================================================
# DIRECTORY STRUCTURE CREATION
# =============================================================================

create_new_structure() {
    log_header "Creating New Directory Structure"
    
    # Create primary directories
    mkdir -p {lib,src,bin}
    
    # Ensure include directories exist
    mkdir -p include/{nlink/core,nlink/cli}
    
    # Create build directories for new structure
    mkdir -p build/{lib,src}
    
    log_success "New directory structure created"
}

# =============================================================================
# SOURCE CODE REORGANIZATION
# =============================================================================

extract_main_function() {
    log_header "Extracting Main Function from CLI Interface"
    
    # Create new main.c file
    cat > src/main.c << 'EOF'
/**
 * @file main.c
 * @brief NexusLink CLI Main Entry Point
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * @version 1.0.0
 *
 * Main entry point for NexusLink CLI executable.
 * Separated from library code for proper library architecture.
 */

#include "nlink/cli/parser_interface.h"
#include <stdio.h>
#include <stdlib.h>

/**
 * @brief Convert CLI result to appropriate exit code
 */
static int cli_result_to_exit_code(nlink_cli_result_t result) {
  switch (result) {
  case NLINK_CLI_SUCCESS:
    return 0;
  case NLINK_CLI_ERROR_INVALID_ARGUMENTS:
    return 1;
  case NLINK_CLI_ERROR_CONFIG_NOT_FOUND:
    return 2;
  case NLINK_CLI_ERROR_PARSE_FAILED:
    return 3;
  case NLINK_CLI_ERROR_VALIDATION_FAILED:
    return 4;
  case NLINK_CLI_ERROR_THREADING_INVALID:
    return 5;
  case NLINK_CLI_ERROR_COMPONENT_DISCOVERY_FAILED:
    return 6;
  case NLINK_CLI_ERROR_INTERNAL_ERROR:
    return 7;
  default:
    return 99;
  }
}

/**
 * @brief Main entry point for nlink CLI executable
 * @param argc Argument count
 * @param argv Argument vector
 * @return Exit code following systematic error propagation
 */
int main(int argc, char *argv[]) {
  nlink_cli_context_t context;
  nlink_cli_args_t args;

  // Initialize CLI context with systematic error handling
  nlink_cli_result_t init_result = nlink_cli_init(&context);
  if (init_result != NLINK_CLI_SUCCESS) {
    fprintf(stderr, "[NLINK FATAL] Failed to initialize CLI context: %d\n",
            init_result);
    return cli_result_to_exit_code(init_result);
  }

  // Parse command line arguments with comprehensive validation
  nlink_cli_result_t parse_result = nlink_cli_parse_args(argc, argv, &args);
  if (parse_result != NLINK_CLI_SUCCESS) {
    fprintf(stderr, "[NLINK ERROR] Invalid command line arguments\n");
    nlink_cli_display_help(argv[0]);
    return cli_result_to_exit_code(parse_result);
  }

  // Execute CLI command with systematic error propagation
  nlink_cli_result_t exec_result = nlink_cli_execute(&context, &args);

  // Clean up resources with systematic resource management
  nlink_cli_cleanup(&context);
  nlink_config_destroy();

  return cli_result_to_exit_code(exec_result);
}
EOF
    
    log_success "Main function extracted to src/main.c"
}

update_parser_interface() {
    log_header "Updating Parser Interface for Library Architecture"
    
    # Remove main function from parser_interface.c
    sed '/^\/\*\*$/,/^int main(int argc, char \*argv\[\]) {$/d' cli/parser_interface.c > cli/parser_interface_lib.c
    sed '/^int main/,$d' cli/parser_interface_lib.c > cli/parser_interface_temp.c
    
    # Add proper library footer
    cat >> cli/parser_interface_temp.c << 'EOF'

// =============================================================================
// LIBRARY INTERFACE COMPLETION
// =============================================================================

// Main function removed - now implemented in src/main.c for executable
// This maintains clean separation between library and executable code
EOF
    
    mv cli/parser_interface_temp.c cli/parser_interface_lib.c
    rm -f cli/parser_interface_temp.c
    
    log_success "Parser interface updated for library use"
}

reorganize_headers() {
    log_header "Reorganizing Header Files"
    
    # Update include paths in headers to use nlink/ prefix
    cp include/core/config.h include/nlink/core/config.h
    cp include/cli/parser_interface.h include/nlink/cli/parser_interface.h
    
    # Update include statements in header files
    sed -i 's|#include "core/config.h"|#include "nlink/core/config.h"|g' include/nlink/cli/parser_interface.h
    
    log_success "Header files reorganized with proper include structure"
}

# =============================================================================
# BUILD SYSTEM UPDATES
# =============================================================================

create_library_makefile() {
    log_header "Creating Library-Oriented Makefile"
    
    cat > Makefile << 'EOF'
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
EOF
    
    log_success "Library-oriented Makefile created"
}

create_pkg_nlink() {
    log_header "Creating Single Project pkg.nlink Configuration"
    
    cat > pkg.nlink << 'EOF'
# NexusLink CLI Single-Pass Project Configuration
# Aegis Project - Phase 1 Implementation

[project]
name = nlink_library_project
version = 1.0.0
entry_point = src/main.c
description = NexusLink CLI Configuration Parser Library and Executable

[build]
pass_mode = single
experimental_mode = false
strict_mode = true
library_target = libnlink
executable_target = nlink

[compilation]
compiler = gcc
c_standard = c99
optimization_level = 2
enable_debug_symbols = true
enable_static_library = true
enable_shared_library = true

[threading]
worker_count = 4
queue_depth = 64
stack_size_kb = 512
enable_work_stealing = true

[features]
unicode_normalization = true
isomorphic_reduction = true
debug_symbols = true
ast_optimization = false
config_validation = true
component_discovery = true
threading_validation = true

[paths]
source_directories = src,core,cli
include_directories = include,include/nlink
library_output = lib
executable_output = bin
build_directory = build

[dependencies]
system_libraries = pthread,rt
link_flags = -lpthread,-lrt

[validation]
enable_static_analysis = true
enable_format_checking = true
enable_comprehensive_testing = true
strict_validation = true
EOF
    
    log_success "Single project pkg.nlink configuration created"
}

# =============================================================================
# MAIN REORGANIZATION EXECUTION
# =============================================================================

main() {
    log_header "NexusLink CLI Project Reorganization"
    echo -e "${BOLD}${CYAN}Aegis Project Phase 1 Implementation${NC}"
    echo -e "${BOLD}Transitioning to Library + Executable Architecture${NC}\n"
    
    # Validation and backup
    validate_current_structure
    create_backup
    
    # Structure reorganization
    create_new_structure
    extract_main_function
    update_parser_interface
    reorganize_headers
    
    # Build system updates
    create_library_makefile
    create_pkg_nlink
    
    # Final validation
    log_header "Reorganization Validation"
    
    if [ -f "src/main.c" ] && [ -f "lib/.gitkeep" ] && [ -f "Makefile" ]; then
        # Create placeholder files to ensure directories exist
        touch lib/.gitkeep bin/.gitkeep
        
        log_success "Project reorganization completed successfully"
        
        echo -e "\n${GREEN}${BOLD}Next Steps:${NC}"
        echo "  make all                    # Build library and executable"
        echo "  make test                   # Run functionality tests"
        echo "  ./bin/nlink --help         # Test executable"
        echo "  make install                # Install system-wide"
        
        echo -e "\n${YELLOW}${BOLD}Library Usage:${NC}"
        echo "  Static:  gcc -I./include main.c -L./lib -lnlink -lpthread"
        echo "  Shared:  gcc -I./include main.c -L./lib -lnlink -lpthread"
        echo "           LD_LIBRARY_PATH=./lib ./program"
        
    else
        log_error "Reorganization validation failed"
        exit 1
    fi
}

# Execute main reorganization process
main "$@"
