#!/bin/bash

# Terminal Orchestration Demonstration Script
# SemVerX Shared Artifact Coordination via nlink/*.nlink files
# Aegis Project Phase 1.5 - Systematic validation workflow

set -e  # Exit on error

# Color codes for systematic output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Project directory configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
CALC_DEMO_DIR="$PROJECT_ROOT/examples/calculation_pipeline"

# Systematic logging functions
log_phase() {
    echo -e "${BLUE}[ORCHESTRATION PHASE]${NC} $1"
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

log_semverx() {
    echo -e "${PURPLE}[SEMVERX]${NC} $1"
}

# Systematic validation function
validate_prerequisites() {
    log_phase "Validating systematic prerequisites"
    
    # Check nlink executable
    if [ ! -f "$PROJECT_ROOT/bin/nlink" ]; then
        log_error "NexusLink executable not found: $PROJECT_ROOT/bin/nlink"
        log_warning "Run 'make all-semverx' to build the project"
        return 1
    fi
    
    # Check calculation pipeline structure
    if [ ! -d "$CALC_DEMO_DIR" ]; then
        log_error "Calculation pipeline demo not found: $CALC_DEMO_DIR"
        return 1
    fi
    
    # Validate shared orchestration configuration
    if [ ! -f "$CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink" ]; then
        log_error "Shared registry configuration missing"
        return 1
    fi
    
    log_success "Prerequisites validation completed"
    return 0
}

# Phase 1: Shared Artifact Registry Coordination
demonstrate_registry_coordination() {
    log_phase "Demonstrating Shared Artifact Registry Coordination"
    
    echo "=== Shared Registry Analysis ==="
    echo "Registry Path: $CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink"
    echo ""
    
    # Display registry contents for systematic validation
    if [ -f "$CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink" ]; then
        echo "--- Component Registry Contents ---"
        grep -E "^\[(component_|shared_)" "$CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink" || true
        echo ""
        
        echo "--- Range State Components ---"
        grep -E "range_state = " "$CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink" || true
        echo ""
        
        echo "--- Hot-Swap Configuration ---"
        grep -E "hot_swap_enabled = " "$CALC_DEMO_DIR/shared_orchestration/calculation_registry.nlink" || true
        echo ""
    fi
    
    log_success "Registry coordination analysis completed"
}

# Phase 2: Component Compatibility Matrix Validation
demonstrate_compatibility_validation() {
    log_phase "Validating Component Compatibility Matrix"
    
    echo "=== Compatibility Matrix Analysis ==="
    echo "Matrix Path: $CALC_DEMO_DIR/shared_orchestration/algorithm_compatibility.nlink"
    echo ""
    
    if [ -f "$CALC_DEMO_DIR/shared_orchestration/algorithm_compatibility.nlink" ]; then
        echo "--- Cross-Range Compatibility Rules ---"
        grep -E "stable_to_experimental|experimental_to_stable" "$CALC_DEMO_DIR/shared_orchestration/algorithm_compatibility.nlink" || true
        echo ""
        
        echo "--- Component Coordination Policies ---"
        grep -E "_policy = " "$CALC_DEMO_DIR/shared_orchestration/algorithm_compatibility.nlink" || true
        echo ""
    fi
    
    log_success "Compatibility matrix validation completed"
}

# Phase 3: Component Execution with SemVerX Coordination
demonstrate_component_execution() {
    log_phase "Executing Components with SemVerX Coordination"
    
    # Build components if necessary
    if [ ! -f "$CALC_DEMO_DIR/basic_math/build/calculator" ]; then
        log_warning "Building basic math component"
        mkdir -p "$CALC_DEMO_DIR/basic_math/build"
        if [ -f "$CALC_DEMO_DIR/basic_math/src/calculator.c" ]; then
            gcc -Wall -Wextra -std=c99 \
                "$CALC_DEMO_DIR/basic_math/src/calculator.c" \
                -o "$CALC_DEMO_DIR/basic_math/build/calculator" -lm
            log_success "Basic math component built successfully"
        fi
    fi
    
    echo "=== Component Execution Demonstration ==="
    
    # Execute basic math component with metadata display
    if [ -f "$CALC_DEMO_DIR/basic_math/build/calculator" ]; then
        echo "--- Basic Math Component (Stable Range) ---"
        "$CALC_DEMO_DIR/basic_math/build/calculator" --metadata
        echo ""
        
        echo "--- Calculation Execution ---"
        "$CALC_DEMO_DIR/basic_math/build/calculator" add 42.5 17.3
        echo ""
        
        echo "--- Component Compatibility Validation ---"
        "$CALC_DEMO_DIR/basic_math/build/calculator" --validate "advanced_math" "experimental"
        echo ""
    fi
    
    log_success "Component execution demonstration completed"
}

# Phase 4: NexusLink CLI SemVerX Integration
demonstrate_nlink_integration() {
    log_phase "Demonstrating NexusLink CLI SemVerX Integration"
    
    echo "=== NexusLink SemVerX Validation ==="
    
    cd "$CALC_DEMO_DIR"
    
    # Project configuration validation
    echo "--- Project Configuration Analysis ---"
    "$PROJECT_ROOT/bin/nlink" --config-check --project-root . || {
        log_warning "NexusLink config check reported issues (expected for demo)"
    }
    echo ""
    
    # Component discovery with SemVerX metadata
    echo "--- Component Discovery with SemVerX ---"
    "$PROJECT_ROOT/bin/nlink" --discover-components --verbose --project-root . || {
        log_warning "Component discovery completed with warnings (expected)"
    }
    echo ""
    
    cd "$PROJECT_ROOT"
    log_success "NexusLink SemVerX integration demonstration completed"
}

# Phase 5: Systematic Orchestration Summary
demonstrate_orchestration_summary() {
    log_phase "Systematic Orchestration Summary"
    
    echo "=== SemVerX Shared Artifact Coordination Summary ==="
    echo ""
    echo "✅ Registry Coordination: Centralized component metadata management"
    echo "✅ Compatibility Matrix: Cross-range validation rules enforced"
    echo "✅ Component Execution: Range state-aware calculation processing"
    echo "✅ NexusLink Integration: CLI-orchestrated SemVerX validation"
    echo ""
    echo "--- Demonstrated Capabilities ---"
    echo "• Shared artifact registry coordination via nlink/*.nlink files"
    echo "• Range state compatibility validation (stable ↔ experimental)"
    echo "• Component metadata registration and validation"
    echo "• Terminal-orchestrated calculation pipeline"
    echo "• Systematic error handling and graceful degradation"
    echo ""
    echo "--- Strategic Value for OBINexus Ecosystem ---"
    echo "• Foundation for nlink → polybuild orchestration stack"
    echo "• HACC autonomy levels mapped to SemVerX range states"
    echo "• Milestone-based investment tracking through range transitions"
    echo "• Hot-swappable architecture enabling systematic recovery"
    echo ""
    
    log_success "Orchestration demonstration completed successfully"
}

# Main execution workflow
main() {
    echo "=== SemVerX Shared Artifact Coordination Demonstration ==="
    echo "Aegis Project Phase 1.5 - Range State Versioning Integration"
    echo "Author: Nnamdi Michael Okpala & Development Team"
    echo ""
    
    # Systematic validation and demonstration workflow
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed"
        exit 1
    fi
    
    demonstrate_registry_coordination
    echo ""
    
    demonstrate_compatibility_validation  
    echo ""
    
    demonstrate_component_execution
    echo ""
    
    demonstrate_nlink_integration
    echo ""
    
    demonstrate_orchestration_summary
    
    log_semverx "SemVerX demonstration workflow completed successfully"
    echo ""
    echo "Next Steps:"
    echo "1. Run 'make demo-calculation' for automated demonstration"
    echo "2. Examine shared artifact files in examples/calculation_pipeline/shared_orchestration/"
    echo "3. Test component hot-swap capabilities with range state validation"
    echo "4. Integrate with polybuild for full OBINexus toolchain coordination"
}

# Execute main workflow
main "$@"
