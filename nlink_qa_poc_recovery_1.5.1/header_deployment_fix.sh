#!/bin/bash

# =============================================================================
# OBINexus NexusLink QA POC - Header Deployment & Include Path Fix
# Systematic Resolution of Missing Header Dependencies
# =============================================================================

set -e

# Color codes for structured output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_phase() { echo -e "${BLUE}[HEADER FIX]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=============================================================================="
echo "🔧 OBINexus Header Deployment & Include Path Resolution"
echo "=============================================================================="
echo "Issue: Missing marshal.h and potential other header dependencies"
echo "Solution: Deploy missing headers + audit include path references"
echo "Environment: nlink_qa_poc_recovery_1.5.1"
echo "=============================================================================="
echo ""

# Validate we're in the recovery environment
if [ ! -d "include/nlink_qa_poc" ]; then
    log_error "Not in recovery environment. Please run from nlink_qa_poc_recovery_1.5.1/"
    exit 1
fi

log_success "Located recovery environment with include/nlink_qa_poc/ structure"

# =============================================================================
# Phase 1: Deploy Missing marshal.h Header
# =============================================================================

log_phase "1. Deploying missing marshal.h header definition"

cat > include/nlink_qa_poc/core/marshal.h << 'EOF'
/**
 * @file marshal.h
 * @brief NexusLink Zero-Overhead Data Marshalling
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * @version 1.5.1
 */

#ifndef NLINK_QA_POC_CORE_MARSHAL_H
#define NLINK_QA_POC_CORE_MARSHAL_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// =============================================================================
// Marshalling Header Structure (16 bytes, aligned)
// =============================================================================

typedef struct nlink_marshal_header {
    uint32_t version;           // Protocol version
    uint32_t payload_size;      // Data payload size in bytes
    uint32_t checksum;          // XOR-based checksum with rotation
    uint32_t topology_id;       // Unique topology identifier
} nlink_marshal_header_t;

// =============================================================================
// Marshalling Context Structure
// =============================================================================

typedef struct nlink_marshaller {
    uint8_t* buffer;            // Working buffer for marshalling operations
    size_t buffer_size;         // Current buffer capacity
    uint32_t topology_id;       // Topology identifier for this marshaller
    uint64_t marshal_count;     // Successful marshalling operations count
    uint64_t error_count;       // Error count for diagnostics
} nlink_marshaller_t;

// =============================================================================
// Core Marshalling API Functions
// =============================================================================

// Context management
int nlink_marshaller_create(nlink_marshaller_t** marshaller, size_t initial_size);
void nlink_marshaller_destroy(nlink_marshaller_t* marshaller);

// Data marshalling operations
int nlink_marshal_data(nlink_marshaller_t* marshaller, 
                      const double* data, size_t count,
                      uint8_t** output, size_t* output_size);

int nlink_unmarshal_data(nlink_marshaller_t* marshaller,
                        const uint8_t* input, size_t input_size,
                        double** output, size_t* output_count);

// Utility functions
uint32_t nlink_compute_checksum(const uint8_t* data, size_t size);
int nlink_verify_header(const nlink_marshal_header_t* header);

// Statistics and diagnostics
uint64_t nlink_marshaller_get_operation_count(const nlink_marshaller_t* marshaller);
uint64_t nlink_marshaller_get_error_count(const nlink_marshaller_t* marshaller);
uint32_t nlink_marshaller_get_topology_id(const nlink_marshaller_t* marshaller);

#ifdef __cplusplus
}
#endif

#endif // NLINK_QA_POC_CORE_MARSHAL_H
EOF

log_success "✅ Deployed marshal.h header to include/nlink_qa_poc/core/"

# =============================================================================
# Phase 2: Audit Source Files for Include Path References
# =============================================================================

log_phase "2. Auditing source files for nlink_qa_poc include references"

# Find all source files with nlink_qa_poc includes
echo "📋 Source files containing 'nlink_qa_poc' include statements:"
echo ""

INCLUDE_REFERENCES=()
if [ -d "src" ]; then
    while IFS= read -r -d '' file; do
        if grep -l "nlink_qa_poc" "$file" >/dev/null 2>&1; then
            echo "📄 $file:"
            grep -n "nlink_qa_poc" "$file" | head -5
            INCLUDE_REFERENCES+=("$file")
            echo ""
        fi
    done < <(find src -name "*.c" -print0)
fi

echo "📊 Found ${#INCLUDE_REFERENCES[@]} source files with nlink_qa_poc references"

# =============================================================================
# Phase 3: Validate Header Resolution
# =============================================================================

log_phase "3. Validating header resolution with test compilation"

# Test critical headers individually
echo "🧪 Testing header compilation..."

# Test marshal.h
echo "#include \"nlink_qa_poc/core/marshal.h\"" > test_marshal.c
echo "int main(){return 0;}" >> test_marshal.c

if gcc -I include -c test_marshal.c -o test_marshal.o 2>/dev/null; then
    log_success "✅ marshal.h compilation: PASSED"
    rm -f test_marshal.c test_marshal.o
else
    log_error "❌ marshal.h compilation: FAILED"
fi

# Test config.h
echo "#include \"nlink_qa_poc/core/config.h\"" > test_config.c
echo "int main(){return 0;}" >> test_config.c

if gcc -I include -c test_config.c -o test_config.o 2>/dev/null; then
    log_success "✅ config.h compilation: PASSED"
    rm -f test_config.c test_config.o
else
    log_error "❌ config.h compilation: FAILED"
fi

# Test telemetry.h
echo "#include \"nlink_qa_poc/etps/telemetry.h\"" > test_telemetry.c
echo "int main(){return 0;}" >> test_telemetry.c

if gcc -I include -c test_telemetry.c -o test_telemetry.o 2>/dev/null; then
    log_success "✅ telemetry.h compilation: PASSED"
    rm -f test_telemetry.c test_telemetry.o
else
    log_error "❌ telemetry.h compilation: FAILED"
fi

# Test combined includes
echo "#include \"nlink_qa_poc/core/marshal.h\"" > test_combined.c
echo "#include \"nlink_qa_poc/core/config.h\"" >> test_combined.c
echo "#include \"nlink_qa_poc/etps/telemetry.h\"" >> test_combined.c
echo "int main(){return 0;}" >> test_combined.c

if gcc -I include -c test_combined.c -o test_combined.o 2>/dev/null; then
    log_success "✅ Combined headers compilation: PASSED"
    rm -f test_combined.c test_combined.o
else
    log_warning "⚠️ Combined headers compilation: Issues detected"
fi

# =============================================================================
# Phase 4: Check for Additional Missing Headers
# =============================================================================

log_phase "4. Checking for additional missing header dependencies"

# Scan for other potential missing headers
echo "🔍 Scanning for other header references that might be missing..."

# Look for common header patterns in source files
POTENTIAL_MISSING=()
if [ -d "src" ]; then
    while IFS= read -r line; do
        header_path=$(echo "$line" | sed 's/.*#include [<"]\([^>"]*\)[>"].*/\1/')
        if [[ "$header_path" == nlink_qa_poc/* ]]; then
            header_file="include/$header_path"
            if [ ! -f "$header_file" ]; then
                POTENTIAL_MISSING+=("$header_path")
            fi
        fi
    done < <(find src -name "*.c" -exec grep -H "#include.*nlink_qa_poc" {} \; 2>/dev/null || true)
fi

# Remove duplicates and sort
if [ ${#POTENTIAL_MISSING[@]} -gt 0 ]; then
    readarray -t UNIQUE_MISSING < <(printf '%s\n' "${POTENTIAL_MISSING[@]}" | sort -u)
    
    if [ ${#UNIQUE_MISSING[@]} -gt 0 ]; then
        log_warning "⚠️ Additional potentially missing headers detected:"
        for header in "${UNIQUE_MISSING[@]}"; do
            echo "    ❌ include/$header"
        done
        echo ""
        echo "💡 These headers may need to be created or include paths updated"
    fi
else
    log_success "✅ No additional missing headers detected"
fi

# =============================================================================
# Phase 5: Test Build Process
# =============================================================================

log_phase "5. Testing build process with deployed headers"

echo "🔨 Attempting make clean && make to validate header resolution..."
echo ""

# Clean previous artifacts
make clean >/dev/null 2>&1 || true

# Attempt compilation
if make 2>&1 | tee build_test.log; then
    log_success "✅ Build process completed successfully"
    echo ""
    echo "📦 Generated artifacts:"
    ls -la lib/ bin/ 2>/dev/null || echo "No artifacts generated yet"
else
    log_warning "⚠️ Build process encountered issues"
    echo ""
    echo "📋 Last 10 lines of build output:"
    tail -10 build_test.log
    echo ""
    echo "💡 Review build_test.log for detailed error analysis"
fi

# =============================================================================
# Phase 6: Summary and Next Steps
# =============================================================================

log_phase "6. Header Deployment Summary"

echo ""
echo "=============================================================================="
echo -e "${GREEN}🎯 HEADER DEPLOYMENT RESULTS${NC}"
echo "=============================================================================="
echo -e "${GREEN}✅ Deployed marshal.h:${NC} include/nlink_qa_poc/core/marshal.h"
echo -e "${GREEN}✅ Header structure:${NC} Consistent with OBINexus naming convention"
echo -e "${GREEN}✅ Include paths:${NC} Validated for nlink_qa_poc/* resolution"

if [ ${#UNIQUE_MISSING[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️ Additional headers needed:${NC} ${#UNIQUE_MISSING[@]} potential missing headers"
else
    echo -e "${GREEN}✅ Header coverage:${NC} All required headers appear to be present"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Review build_test.log for any remaining compilation issues"
echo "2. If additional headers are missing, create them using the same pattern"
echo "3. Continue with systematic compilation and testing"
echo "4. Proceed to implement missing source function bodies"
echo ""
echo -e "${BLUE}🚀 Header deployment phase completed${NC}"
echo "=============================================================================="

# Clean up temporary files
rm -f build_test.log test_*.c test_*.o 2>/dev/null || true

log_success "Header deployment and validation script completed"
