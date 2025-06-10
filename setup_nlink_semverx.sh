#!/bin/bash

# NexusLink SemVerX Integration Setup Script
# Aegis Project Phase 1.5 - SemVerX Range State Versioning POC
# Author: Nnamdi Michael Okpala & Development Team

set -e  # Exit on error

# =============================================================================
# PROJECT CONFIGURATION AND PATHS
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Detect source CLI directory with multiple possible locations
detect_source_cli_dir() {
    local possible_paths=(
        "$BASE_DIR/nlink_cli"
        "$SCRIPT_DIR/nlink_cli"
        "$BASE_DIR/../nlink_cli"
        "$SCRIPT_DIR/../nlink_cli"
        "$BASE_DIR/nlink-cli"
        "$SCRIPT_DIR/nlink-cli"
        "$BASE_DIR/../nlink-cli"
        "$SCRIPT_DIR/../nlink-cli"
    )
    
    for path in "${possible_paths[@]}"; do
        if [ -d "$path" ] && [ -f "$path/core/config.c" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

SOURCE_CLI_DIR=$(detect_source_cli_dir)
TARGET_CLI_DIR="$BASE_DIR/nlink_cli_semverx"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[SEMVERX SETUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SEMVERX SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[SEMVERX WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[SEMVERX ERROR]${NC} $1"
}

# =============================================================================
# DIRECTORY STRUCTURE CREATION
# =============================================================================

create_semverx_structure() {
    log_info "Creating SemVerX project structure"
    
    # Create main project directory
    mkdir -p "$TARGET_CLI_DIR"
    
    # Create core directories (copying from source)
    mkdir -p "$TARGET_CLI_DIR"/{bin,build,lib,scripts,test}
    mkdir -p "$TARGET_CLI_DIR"/build/{cli,core,semverx,test}
    mkdir -p "$TARGET_CLI_DIR"/{cli,core,semverx}
    mkdir -p "$TARGET_CLI_DIR"/include/{cli,core,semverx,nlink}
    mkdir -p "$TARGET_CLI_DIR"/include/nlink/{cli,core,semverx,test}
    
    # Create SemVerX-specific directories
    mkdir -p "$TARGET_CLI_DIR"/semverx/{registry,validation,hotswap}
    mkdir -p "$TARGET_CLI_DIR"/nlink/{shared_artifacts,compatibility_matrix,range_policies}
    
    # Create demo projects with SemVerX components
    mkdir -p "$TARGET_CLI_DIR"/demo_semverx_project/{component1,component2,shared_registry}
    mkdir -p "$TARGET_CLI_DIR"/demo_semverx_project/component1/{src,tests}
    mkdir -p "$TARGET_CLI_DIR"/demo_semverx_project/component2/{src,tests}
    mkdir -p "$TARGET_CLI_DIR"/demo_semverx_project/shared_registry/{metadata,policies}
    
    log_success "Project structure created"
}

# =============================================================================
# COPY STABLE LOGIC FROM SOURCE
# =============================================================================

copy_stable_components() {
    log_info "Copying stable logic from $SOURCE_CLI_DIR"
    
    if [ -z "$SOURCE_CLI_DIR" ]; then
        log_error "Source CLI directory could not be detected automatically"
        log_error "Please ensure one of the following directories exists with core/config.c:"
        log_error "  - ../nlink_cli"
        log_error "  - ./nlink_cli" 
        log_error "  - ../nlink-cli"
        log_error "  - ./nlink-cli"
        log_info "Or specify source directory manually:"
        log_info "  SOURCE_CLI_DIR=/path/to/source ./setup_nlink_semverx.sh"
        exit 1
    fi
    
    if [ ! -d "$SOURCE_CLI_DIR" ]; then
        log_error "Source directory not found: $SOURCE_CLI_DIR"
        log_error "Available directories in current location:"
        ls -la ../ | grep nlink || echo "  No nlink-related directories found"
        exit 1
    fi
    
    log_success "Found source directory: $SOURCE_CLI_DIR"
    
    # Copy core configuration parsing logic (stable)
    if [ -f "$SOURCE_CLI_DIR/core/config.c" ]; then
        cp "$SOURCE_CLI_DIR/core/config.c" "$TARGET_CLI_DIR/core/"
        log_success "Copied core configuration parser"
    else
        log_warning "core/config.c not found, looking for alternative locations"
        # Try alternative locations
        find "$SOURCE_CLI_DIR" -name "config.c" -type f | head -1 | while read config_file; do
            if [ -n "$config_file" ]; then
                cp "$config_file" "$TARGET_CLI_DIR/core/"
                log_success "Copied configuration parser from: $config_file"
            fi
        done
    fi
    
    # Copy headers with flexible path detection
    find "$SOURCE_CLI_DIR" -name "config.h" -type f | head -1 | while read config_header; do
        if [ -n "$config_header" ]; then
            cp "$config_header" "$TARGET_CLI_DIR/include/core/"
            log_success "Copied core configuration headers from: $config_header"
        fi
    done
    
    # Copy CLI interface logic (stable) 
    find "$SOURCE_CLI_DIR" -name "parser_interface.c" -type f | head -1 | while read parser_file; do
        if [ -n "$parser_file" ]; then
            cp "$parser_file" "$TARGET_CLI_DIR/cli/"
            log_success "Copied CLI interface implementation from: $parser_file"
        fi
    done
    
    # Copy build system
    if [ -f "$SOURCE_CLI_DIR/Makefile" ]; then
        cp "$SOURCE_CLI_DIR/Makefile" "$TARGET_CLI_DIR/"
        log_success "Copied Makefile"
    else
        log_warning "Makefile not found in source directory"
    fi
    
    # Copy test framework
    find "$SOURCE_CLI_DIR" -name "*test_assert.h" -o -name "*assert.h" | head -1 | while read test_header; do
        if [ -n "$test_header" ]; then
            cp "$test_header" "$TARGET_CLI_DIR/include/nlink/"
            log_success "Copied test assertion framework from: $test_header"
        fi
    done
    
    # Copy main entry point
    if [ -f "$SOURCE_CLI_DIR/main.c" ]; then
        cp "$SOURCE_CLI_DIR/main.c" "$TARGET_CLI_DIR/"
        log_success "Copied main entry point"
    else
        log_warning "main.c not found, creating minimal entry point"
        cat > "$TARGET_CLI_DIR/main.c" << 'EOF'
/**
 * @file main.c
 * @brief NexusLink CLI with SemVerX Integration
 */
#include <stdio.h>
int main(int argc, char *argv[]) {
    printf("NexusLink CLI with SemVerX Integration v1.0.0\n");
    printf("Systematic configuration parsing with range state versioning\n");
    return 0;
}
EOF
        log_success "Created minimal main entry point"
    fi
    
    # Copy scripts directory
    if [ -d "$SOURCE_CLI_DIR/scripts" ]; then
        cp -r "$SOURCE_CLI_DIR/scripts"/* "$TARGET_CLI_DIR/scripts/" 2>/dev/null || true
        log_success "Copied utility scripts"
    else
        log_warning "Scripts directory not found, creating minimal scripts"
        mkdir -p "$TARGET_CLI_DIR/scripts"
    fi
}

# =============================================================================
# CREATE SEMVERX CONFIGURATION FILES
# =============================================================================

create_semverx_configs() {
    log_info "Creating SemVerX configuration files"
    
    # Create enhanced pkg.nlink with SemVerX integration
    cat > "$TARGET_CLI_DIR/pkg.nlink" << 'EOF'
[project]
name = nlink_cli_semverx
version = 1.0.0
entry_point = main.c
description = NexusLink CLI with SemVerX Range State Versioning

[build]
pass_mode = multi                    # SemVerX requires multi-pass for validation
experimental_mode = true             # Enable SemVerX experimental features
strict_mode = true
semverx_enabled = true               # Enable SemVerX processing

[semverx]
# Core SemVerX Configuration
range_state = stable                 # legacy | stable | experimental
compatible_range = ^1.0.0
registry_mode = centralized          # centralized | distributed
validation_level = strict            # strict | permissive | disabled

# Hot-swapping configuration
hot_swap_enabled = true
runtime_validation = true
allow_cross_range_swap = false       # Prevent legacy ↔ stable swapping

# Shared artifacts configuration
shared_registry_path = ./nlink/shared_artifacts/
compatibility_matrix_path = ./nlink/compatibility_matrix.nlink
range_policies_path = ./nlink/range_policies.nlink

[threading]
worker_count = 8                     # Increased for SemVerX validation
queue_depth = 128
stack_size_kb = 1024
enable_work_stealing = true

[features]
unicode_normalization = true
isomorphic_reduction = true
debug_symbols = true
config_validation = true
component_discovery = true
semverx_validation = true            # Enable SemVerX-specific validation
hot_swap_monitoring = true           # Monitor hot-swap events
dependency_graph_analysis = true     # Enhanced dependency tracking
EOF

    # Create shared artifacts registry
    cat > "$TARGET_CLI_DIR/nlink/shared_artifacts/registry.nlink" << 'EOF'
[shared_artifacts]
registry_version = 1.0.0
coordination_mode = centralized
last_updated = 2025-06-10T17:52:00Z

[metadata]
total_components = 3
stable_components = 2
experimental_components = 1
legacy_components = 0

[component_registry]
# Stable components
core_parser.range_state = stable
core_parser.version = 1.0.0
core_parser.compatible_with = ["1.0.x"]

cli_interface.range_state = stable  
cli_interface.version = 1.0.0
cli_interface.compatible_with = ["1.0.x"]

# Experimental components
semverx_engine.range_state = experimental
semverx_engine.version = 2.0.0-alpha.1
semverx_engine.compatible_with = ["2.0.x-alpha", "2.0.x-beta"]
semverx_engine.requires_opt_in = true
EOF

    # Create compatibility matrix
    cat > "$TARGET_CLI_DIR/nlink/compatibility_matrix.nlink" << 'EOF'
[compatibility_matrix]
matrix_version = 1.0.0
validation_rules = strict

[stable_ranges]
allowed = ["1.0.x", "1.1.x", "1.2.x"]
swap_policy = allow_minor_upgrades
backward_compatibility = true

[experimental_ranges]  
allowed = ["2.0.x-alpha", "2.0.x-beta", "2.0.x-rc"]
swap_policy = explicit_opt_in
backward_compatibility = false
requires_validation = true

[legacy_ranges]
allowed = ["0.x.x"]
swap_policy = deprecated_access_only
backward_compatibility = legacy_mode
migration_required = true

[cross_range_policies]
stable_to_experimental = forbidden
experimental_to_stable = validation_required
legacy_to_stable = migration_required
stable_to_legacy = forbidden
EOF

    # Create range policies
    cat > "$TARGET_CLI_DIR/nlink/range_policies.nlink" << 'EOF'
[global_policies]
policy_version = 1.0.0
enforcement_mode = strict

[hot_swap_policies]
enable_runtime_swap = true
validation_timeout_ms = 5000
rollback_on_failure = true
pre_swap_validation = true
post_swap_verification = true

[compatibility_enforcement]
block_incompatible_swaps = true
warn_on_experimental_usage = true
require_explicit_experimental_opt_in = true
enforce_semantic_version_constraints = true

[dependency_policies]
allow_transitive_experimental = false
max_dependency_depth = 10
circular_dependency_detection = true
diamond_dependency_resolution = merge_compatible
EOF

    log_success "SemVerX configuration files created"
}

# =============================================================================
# CREATE SEMVERX DEMO COMPONENTS
# =============================================================================

create_demo_components() {
    log_info "Creating SemVerX demo components"
    
    # Component 1 - Stable range state
    cat > "$TARGET_CLI_DIR/demo_semverx_project/component1/nlink.txt" << 'EOF'
[component]
name = stable_parser_component
version = 1.2.0
parent_component = core_system

[semverx]
range_state = stable
compatible_range = ^1.2.0
swappable_with = ["1.1.x", "1.3.x"]
exclusions = ["experimental.*", "legacy.*"]
hot_swap_enabled = true
runtime_validation = strict

[compilation]
optimization_level = 2
max_compile_time = 60
parallel_allowed = true
requires_semverx_validation = true
EOF

    # Component 2 - Experimental range state
    cat > "$TARGET_CLI_DIR/demo_semverx_project/component2/nlink.txt" << 'EOF'
[component]
name = experimental_ai_component
version = 2.0.0-alpha.3
parent_component = enhanced_system

[semverx]
range_state = experimental
compatible_range = 2.0.0-alpha.x
swappable_with = ["2.0.0-alpha.1", "2.0.0-alpha.2", "2.0.0-alpha.4"]
exclusions = ["stable.*", "legacy.*"]
hot_swap_enabled = false
runtime_validation = permissive
requires_opt_in = true

[compilation]
optimization_level = 0
max_compile_time = 120
parallel_allowed = false
requires_semverx_validation = true
experimental_features = ["ai_acceleration", "neural_optimization"]
EOF

    # Create pkg.nlink for demo project
    cat > "$TARGET_CLI_DIR/demo_semverx_project/pkg.nlink" << 'EOF'
[project]
name = semverx_demo_project
version = 1.0.0
entry_point = src/main.c

[build]
pass_mode = multi
semverx_enabled = true

[semverx]
range_state = stable
registry_mode = centralized
validation_level = strict
EOF

    log_success "Demo components created"
}

# =============================================================================
# CREATE SEMVERX IMPLEMENTATION FILES
# =============================================================================

create_semverx_implementation() {
    log_info "Creating SemVerX implementation files"
    
    # Create SemVerX header file
    cat > "$TARGET_CLI_DIR/include/semverx/semverx_parser.h" << 'EOF'
/**
 * @file semverx_parser.h
 * @brief SemVerX Range State Versioning Parser
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * @version 1.0.0
 */

#ifndef SEMVERX_PARSER_H
#define SEMVERX_PARSER_H

#include <stdbool.h>
#include <stdint.h>

typedef enum {
    SEMVERX_STATE_LEGACY,
    SEMVERX_STATE_STABLE,
    SEMVERX_STATE_EXPERIMENTAL,
    SEMVERX_STATE_INVALID
} semverx_range_state_t;

typedef struct {
    char version[64];
    semverx_range_state_t state;
    char compatible_range[256];
    char **swappable_with;
    size_t swappable_count;
    bool hot_swap_enabled;
    bool runtime_validation;
    bool requires_opt_in;
} semverx_component_t;

typedef struct {
    bool allow_stable_swap;
    bool allow_experimental_swap;
    bool allow_legacy_use;
    char exclusion_patterns[512];
} semverx_policy_t;

// Core SemVerX functions
semverx_range_state_t semverx_parse_range_state(const char *state_str);
bool semverx_validate_compatibility(const semverx_component_t *comp1, 
                                   const semverx_component_t *comp2,
                                   const semverx_policy_t *policy);
int semverx_parse_component_config(const char *config_path, 
                                  semverx_component_t *component);
int semverx_validate_project_compatibility(const char *project_root);

#endif /* SEMVERX_PARSER_H */
EOF

    # Create SemVerX implementation stub
    cat > "$TARGET_CLI_DIR/semverx/semverx_parser.c" << 'EOF'
/**
 * @file semverx_parser.c
 * @brief SemVerX Implementation for NexusLink Integration
 */

#define _GNU_SOURCE
#define _POSIX_C_SOURCE 200809L

#include "semverx/semverx_parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

semverx_range_state_t semverx_parse_range_state(const char *state_str) {
    if (!state_str) return SEMVERX_STATE_INVALID;
    
    if (strcmp(state_str, "legacy") == 0) return SEMVERX_STATE_LEGACY;
    if (strcmp(state_str, "stable") == 0) return SEMVERX_STATE_STABLE;
    if (strcmp(state_str, "experimental") == 0) return SEMVERX_STATE_EXPERIMENTAL;
    
    return SEMVERX_STATE_INVALID;
}

bool semverx_validate_compatibility(const semverx_component_t *comp1, 
                                   const semverx_component_t *comp2,
                                   const semverx_policy_t *policy) {
    // Legacy components cannot be used with Stable/Experimental
    if (comp1->state == SEMVERX_STATE_LEGACY || comp2->state == SEMVERX_STATE_LEGACY) {
        return policy->allow_legacy_use;
    }
    
    // Stable ↔ Stable compatibility
    if (comp1->state == SEMVERX_STATE_STABLE && comp2->state == SEMVERX_STATE_STABLE) {
        return policy->allow_stable_swap;
    }
    
    // Stable ↔ Experimental compatibility
    if ((comp1->state == SEMVERX_STATE_STABLE && comp2->state == SEMVERX_STATE_EXPERIMENTAL) ||
        (comp1->state == SEMVERX_STATE_EXPERIMENTAL && comp2->state == SEMVERX_STATE_STABLE)) {
        return policy->allow_experimental_swap;
    }
    
    return true; // Experimental ↔ Experimental allowed by default
}

int semverx_parse_component_config(const char *config_path, 
                                  semverx_component_t *component) {
    printf("[SEMVERX] Parsing component config: %s\n", config_path);
    // Implementation will extend existing nlink parser
    return 0;
}

int semverx_validate_project_compatibility(const char *project_root) {
    printf("[SEMVERX] Validating project compatibility: %s\n", project_root);
    // Implementation will validate all components in project
    return 0;
}
EOF

    log_success "SemVerX implementation files created"
}

# =============================================================================
# UPDATE MAKEFILE FOR SEMVERX
# =============================================================================

update_makefile() {
    log_info "Updating Makefile for SemVerX support"
    
    # Append SemVerX-specific targets to Makefile
    cat >> "$TARGET_CLI_DIR/Makefile" << 'EOF'

# =============================================================================
# SEMVERX-SPECIFIC TARGETS
# =============================================================================

SEMVERX_SOURCES := semverx/semverx_parser.c
SEMVERX_HEADERS := include/semverx/semverx_parser.h
SEMVERX_OBJECTS := $(SEMVERX_SOURCES:semverx/%.c=build/semverx/%.o)

# Build SemVerX library
build/semverx/%.o: semverx/%.c $(SEMVERX_HEADERS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# SemVerX validation target
semverx-validate:
	@echo "[SEMVERX] Running SemVerX validation"
	./bin/nlink --semverx-validate --project-root demo_semverx_project

# SemVerX compatibility check
semverx-compat:
	@echo "[SEMVERX] Checking component compatibility"
	./bin/nlink --semverx-compat-check --verbose

# Build with SemVerX support
all-semverx: $(OBJECTS) $(SEMVERX_OBJECTS)
	@echo "[BUILD] Building NexusLink CLI with SemVerX support"
	$(CC) $(OBJECTS) $(SEMVERX_OBJECTS) $(LDFLAGS) -o bin/nlink

# SemVerX demo
demo-semverx: all-semverx
	@echo "[DEMO] Running SemVerX demonstration"
	./bin/nlink --config-check --project-root demo_semverx_project
	./bin/nlink --semverx-validate --project-root demo_semverx_project

.PHONY: semverx-validate semverx-compat all-semverx demo-semverx
EOF

    log_success "Makefile updated for SemVerX"
}

# =============================================================================
# CREATE VALIDATION SCRIPT
# =============================================================================

create_validation_script() {
    log_info "Creating SemVerX validation script"
    
    cat > "$TARGET_CLI_DIR/scripts/validate_semverx.sh" << 'EOF'
#!/bin/bash

# SemVerX Validation Script
echo "[SEMVERX VALIDATION] Starting comprehensive validation"

# Build the project
make clean
make all-semverx

# Run basic functionality tests
echo "[SEMVERX] Testing basic functionality"
./bin/nlink --help
./bin/nlink --version

# Run SemVerX-specific validation
echo "[SEMVERX] Running SemVerX compatibility validation"
./bin/nlink --config-check --project-root demo_semverx_project

echo "[SEMVERX] Validation completed"
EOF

    chmod +x "$TARGET_CLI_DIR/scripts/validate_semverx.sh"
    log_success "Validation script created"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    log_info "NexusLink SemVerX Integration Setup"
    log_info "Aegis Project Phase 1.5 - Range State Versioning POC"
    
    # Check if source directory exists
    if [ ! -d "$SOURCE_CLI_DIR" ]; then
        log_error "Source nlink_cli directory not found at: $SOURCE_CLI_DIR"
        log_error "Please ensure the source project exists before running setup"
        exit 1
    fi
    
    # Execute setup phases
    create_semverx_structure
    copy_stable_components
    create_semverx_configs
    create_demo_components
    create_semverx_implementation
    update_makefile
    create_validation_script
    
    log_success "SemVerX integration setup completed successfully"
    
    echo ""
    echo "=== Next Steps ==="
    echo "1. cd $TARGET_CLI_DIR"
    echo "2. make clean && make all-semverx"
    echo "3. ./scripts/validate_semverx.sh"
    echo "4. make demo-semverx"
    echo ""
    echo "Project structure created at: $TARGET_CLI_DIR"
    echo "SemVerX configuration: pkg.nlink"
    echo "Demo project: demo_semverx_project/"
    echo "Validation script: scripts/validate_semverx.sh"
}

# Execute main function
main "$@"
