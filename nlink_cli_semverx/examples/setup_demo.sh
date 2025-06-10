#!/bin/bash

# SemVerX Demo Setup Script - Systematic Implementation
# Creates structured demonstration environment with two focused demo projects
# Aegis Project Phase 1.5 - Waterfall methodology compliance

set -e

# Project structure configuration
PROJECT_ROOT="$(pwd)"
EXAMPLES_DIR="$PROJECT_ROOT/examples"

# Color-coded logging for systematic progress tracking
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[SETUP]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Phase 1: Directory Structure Creation
create_demo_structure() {
    log_info "Creating systematic demo structure with two focused projects"
    
    # Primary Demo: Calculation Pipeline
    mkdir -p "$EXAMPLES_DIR/calculation_pipeline/basic_math/src"
    mkdir -p "$EXAMPLES_DIR/calculation_pipeline/basic_math/build"
    mkdir -p "$EXAMPLES_DIR/calculation_pipeline/advanced_math/src"
    mkdir -p "$EXAMPLES_DIR/calculation_pipeline/advanced_math/build"
    mkdir -p "$EXAMPLES_DIR/calculation_pipeline/shared_orchestration"
    
    # Secondary Demo: Simple Parser (for comparative analysis)
    mkdir -p "$EXAMPLES_DIR/simple_parser/lexer_component/src"
    mkdir -p "$EXAMPLES_DIR/simple_parser/parser_component/src"
    mkdir -p "$EXAMPLES_DIR/simple_parser/shared_coordination"
    
    log_success "Demo directory structure created"
}

# Phase 2: Component Configuration Files
create_component_configs() {
    log_info "Creating component-level SemVerX configuration files"
    
    # Basic Math Component Configuration
    cat > "$EXAMPLES_DIR/calculation_pipeline/basic_math/nlink.txt" << 'EOF'
[component]
name = basic_math_calculator
version = 1.2.0
parent_component = calculation_pipeline

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

[capabilities]
supported_operations = ["add", "subtract", "multiply", "divide"]
precision_level = single
memory_footprint_kb = 64
EOF

    # Advanced Math Component Configuration  
    cat > "$EXAMPLES_DIR/calculation_pipeline/advanced_math/nlink.txt" << 'EOF'
[component]
name = advanced_math_scientific
version = 2.0.0-alpha.1
parent_component = calculation_pipeline

[semverx]
range_state = experimental
compatible_range = 2.0.0-alpha.x
swappable_with = ["2.0.0-alpha.2", "2.0.0-beta.1"]
exclusions = ["stable.*", "legacy.*"]
hot_swap_enabled = false
runtime_validation = paranoid
requires_opt_in = true

[compilation]
optimization_level = 0
max_compile_time = 120
parallel_allowed = false
requires_semverx_validation = true
experimental_features = ["scientific_computing", "extended_precision"]

[capabilities]
supported_operations = ["sin", "cos", "log", "exp", "sqrt", "factorial"]
precision_level = double
memory_footprint_kb = 256
EOF

    # Simple Parser Demo Components
    cat > "$EXAMPLES_DIR/simple_parser/lexer_component/nlink.txt" << 'EOF'
[component]
name = simple_lexer
version = 1.0.0
parent_component = simple_parser

[semverx]
range_state = stable
compatible_range = ^1.0.0
hot_swap_enabled = true
runtime_validation = strict

[compilation]
optimization_level = 2
parallel_allowed = true
EOF

    cat > "$EXAMPLES_DIR/simple_parser/parser_component/nlink.txt" << 'EOF'
[component]
name = simple_parser_engine
version = 1.1.0
parent_component = simple_parser

[semverx]
range_state = stable
compatible_range = ^1.1.0
hot_swap_enabled = true
runtime_validation = strict

[compilation]
optimization_level = 2
parallel_allowed = true
EOF

    log_success "Component configuration files created"
}

# Phase 3: Shared Orchestration Configuration
create_shared_configs() {
    log_info "Creating shared orchestration configuration files"
    
    # Project-level pkg.nlink for calculation pipeline
    cat > "$EXAMPLES_DIR/calculation_pipeline/pkg.nlink" << 'EOF'
[project]
name = mathematical_calculation_pipeline
version = 1.0.0
entry_point = calculation_orchestrator

[build]
pass_mode = multi
experimental_mode = true
semverx_enabled = true

[semverx]
range_state = stable
registry_mode = centralized
validation_level = strict
shared_registry_path = ./shared_orchestration/calculation_registry.nlink
compatibility_matrix_path = ./shared_orchestration/algorithm_compatibility.nlink
range_policies_path = ./shared_orchestration/precision_policies.nlink
hot_swap_enabled = true
runtime_validation = true

[threading]
worker_count = 4
queue_depth = 64
enable_work_stealing = true

[features]
shared_artifact_coordination = true
component_compatibility_validation = true
calculation_result_caching = true
EOF

    # Simple parser project configuration
    cat > "$EXAMPLES_DIR/simple_parser/pkg.nlink" << 'EOF'
[project]
name = simple_parsing_system
version = 1.0.0
entry_point = parser_main

[build]
pass_mode = multi
semverx_enabled = true

[semverx]
range_state = stable
registry_mode = centralized
validation_level = strict
shared_registry_path = ./shared_coordination/parser_registry.nlink

[threading]
worker_count = 2
queue_depth = 32
EOF

    log_success "Project configuration files created"
}

# Phase 4: Implementation Files
create_implementation_files() {
    log_info "Creating demonstration implementation files"
    
    # Copy calculator implementation from artifact
    # (This would be created from the previous artifact)
    cat > "$EXAMPLES_DIR/calculation_pipeline/basic_math/src/calculator.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    printf("[BASIC_MATH] Calculator v1.2.0 (Stable Range)\n");
    
    if (argc >= 4) {
        double a = atof(argv[2]);
        double b = atof(argv[3]);
        double result = 0;
        
        if (strcmp(argv[1], "add") == 0) result = a + b;
        else if (strcmp(argv[1], "subtract") == 0) result = a - b;
        else if (strcmp(argv[1], "multiply") == 0) result = a * b;
        else if (strcmp(argv[1], "divide") == 0) result = (b != 0) ? a / b : 0;
        
        printf("[RESULT] %.6f\n", result);
        return 0;
    }
    
    if (argc >= 2 && strcmp(argv[1], "--metadata") == 0) {
        printf("[METADATA] Component: basic_math_calculator\n");
        printf("[METADATA] Range State: stable\n");
        printf("[METADATA] Hot-Swap: enabled\n");
        return 0;
    }
    
    printf("Usage: %s <operation> <num1> <num2>\n", argv[0]);
    printf("       %s --metadata\n", argv[0]);
    return 1;
}
EOF

    # Advanced math component stub
    cat > "$EXAMPLES_DIR/calculation_pipeline/advanced_math/src/scientific.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char *argv[]) {
    printf("[ADVANCED_MATH] Scientific Calculator v2.0.0-alpha.1 (Experimental Range)\n");
    
    if (argc >= 3) {
        double a = atof(argv[2]);
        double result = 0;
        
        if (strcmp(argv[1], "sin") == 0) result = sin(a);
        else if (strcmp(argv[1], "cos") == 0) result = cos(a);
        else if (strcmp(argv[1], "log") == 0) result = log(a);
        else if (strcmp(argv[1], "sqrt") == 0) result = sqrt(a);
        
        printf("[RESULT] %.10f\n", result);
        return 0;
    }
    
    printf("Usage: %s <function> <value>\n", argv[0]);
    return 1;
}
EOF

    log_success "Implementation files created"
}

# Phase 5: Build Integration
update_makefile() {
    log_info "Updating Makefile for demo integration"
    
    # Add demo targets to existing Makefile
    cat >> "$PROJECT_ROOT/Makefile" << 'EOF'

# =============================================================================
# DEMO PROJECT TARGETS
# =============================================================================

demo-setup:
	@echo "[DEMO] Setting up demonstration environment"
	./setup_demo.sh

examples-build:
	@echo "[BUILD] Compiling demonstration components"
	@mkdir -p examples/calculation_pipeline/basic_math/build
	@mkdir -p examples/calculation_pipeline/advanced_math/build
	@if [ -f examples/calculation_pipeline/basic_math/src/calculator.c ]; then \
		gcc -Wall -Wextra -std=c99 examples/calculation_pipeline/basic_math/src/calculator.c \
		-o examples/calculation_pipeline/basic_math/build/calculator -lm; \
	fi
	@if [ -f examples/calculation_pipeline/advanced_math/src/scientific.c ]; then \
		gcc -Wall -Wextra -std=c99 examples/calculation_pipeline/advanced_math/src/scientific.c \
		-o examples/calculation_pipeline/advanced_math/build/scientific -lm; \
	fi

demo-calculation: all-semverx examples-build
	@echo "[DEMO] Running calculation pipeline demonstration"
	@chmod +x scripts/orchestration_demo.sh
	./scripts/orchestration_demo.sh

demo-validation: all-semverx
	@echo "[DEMO] Running systematic validation"
	@if [ -f bin/nlink ]; then \
		bin/nlink --config-check --project-root examples/calculation_pipeline || true; \
		bin/nlink --discover-components --project-root examples/calculation_pipeline || true; \
	fi

.PHONY: demo-setup examples-build demo-calculation demo-validation
EOF

    log_success "Makefile updated with demo targets"
}

# Main execution function
main() {
    echo "=== SemVerX Demo Setup - Systematic Implementation ==="
    echo "Creating focused demonstration with two strategic projects"
    echo ""
    
    create_demo_structure
    create_component_configs
    create_shared_configs
    create_implementation_files
    update_makefile
    
    echo ""
    echo "=== Setup Completed Successfully ==="
    echo "Demonstration structure created with:"
    echo "✅ examples/calculation_pipeline/ - Mathematical coordination demo"
    echo "✅ examples/simple_parser/ - Parser component coordination demo"
    echo "✅ Shared orchestration configuration via nlink/*.nlink files"
    echo "✅ Component-level SemVerX metadata and range state coordination"
    echo ""
    echo "Next Steps:"
    echo "1. make clean && make all-semverx"
    echo "2. make examples-build"
    echo "3. make demo-calculation"
    echo "4. ./scripts/orchestration_demo.sh"
    echo ""
}

main "$@"
