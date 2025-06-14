#!/bin/bash

# =============================================================================
# OBINexus NexusLink QA POC - Include Path Systematic Audit & Replace
# Comprehensive Search and Replace for nlink_qa_poc References
# =============================================================================

set -e

# Color codes for structured output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_phase() { echo -e "${BLUE}[AUDIT PHASE]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }

echo "=============================================================================="
echo "🔍 OBINexus Include Path Systematic Audit & Replace"
echo "=============================================================================="
echo "Objective: Find and resolve ALL nlink_qa_poc include path references"
echo "Methodology: Waterfall-compliant systematic search and replace"
echo "Environment: nlink_qa_poc_recovery_1.5.1"
echo "=============================================================================="
echo ""

# Validate recovery environment
if [ ! -d "include/nlink_qa_poc" ]; then
    log_error "Recovery environment not detected. Expected: include/nlink_qa_poc/"
    exit 1
fi

log_success "Recovery environment validated: $(pwd)"

# =============================================================================
# Phase 1: Comprehensive Search for nlink_qa_poc References
# =============================================================================

log_phase "1. Comprehensive search for all nlink_qa_poc references"

# Create audit report
AUDIT_REPORT="nlink_qa_poc_audit_$(date +%Y%m%d_%H%M%S).txt"
echo "OBINexus Include Path Audit Report" > "$AUDIT_REPORT"
echo "Generated: $(date)" >> "$AUDIT_REPORT"
echo "Environment: $(pwd)" >> "$AUDIT_REPORT"
echo "===========================================" >> "$AUDIT_REPORT"
echo "" >> "$AUDIT_REPORT"

# Search all source files for nlink_qa_poc references
echo "🔍 Scanning for nlink_qa_poc references in source files..."
echo ""

declare -A INCLUDE_REFS
declare -a ALL_FILES
FILE_COUNT=0

# Search in src directory
if [ -d "src" ]; then
    while IFS= read -r -d '' file; do
        if grep -n "nlink_qa_poc" "$file" >/dev/null 2>&1; then
            ALL_FILES+=("$file")
            ((FILE_COUNT++))
            
            echo "📄 $file:" | tee -a "$AUDIT_REPORT"
            grep -n "nlink_qa_poc" "$file" | while read -r line; do
                echo "    $line" | tee -a "$AUDIT_REPORT"
                # Extract include path
                if [[ "$line" =~ \#include[[:space:]]*[\"<]([^\"<>]*nlink_qa_poc[^\"<>]*)[\"<] ]]; then
                    include_path="${BASH_REMATCH[1]}"
                    INCLUDE_REFS["$include_path"]=1
                fi
            done
            echo "" | tee -a "$AUDIT_REPORT"
        fi
    done < <(find src -type f \( -name "*.c" -o -name "*.h" \) -print0 2>/dev/null)
fi

# Search in include directory
if [ -d "include" ]; then
    while IFS= read -r -d '' file; do
        if grep -n "nlink_qa_poc" "$file" >/dev/null 2>&1; then
            ALL_FILES+=("$file")
            ((FILE_COUNT++))
            
            echo "📄 $file:" | tee -a "$AUDIT_REPORT"
            grep -n "nlink_qa_poc" "$file" | while read -r line; do
                echo "    $line" | tee -a "$AUDIT_REPORT"
            done
            echo "" | tee -a "$AUDIT_REPORT"
        fi
    done < <(find include -type f \( -name "*.c" -o -name "*.h" \) -print0 2>/dev/null)
fi

# Search in examples directory
if [ -d "examples" ]; then
    while IFS= read -r -d '' file; do
        if grep -n "nlink_qa_poc" "$file" >/dev/null 2>&1; then
            ALL_FILES+=("$file")
            ((FILE_COUNT++))
            
            echo "📄 $file:" | tee -a "$AUDIT_REPORT"
            grep -n "nlink_qa_poc" "$file" | while read -r line; do
                echo "    $line" | tee -a "$AUDIT_REPORT"
            done
            echo "" | tee -a "$AUDIT_REPORT"
        fi
    done < <(find examples -type f \( -name "*.c" -o -name "*.h" \) -print0 2>/dev/null)
fi

echo "📊 AUDIT SUMMARY:" | tee -a "$AUDIT_REPORT"
echo "Files containing nlink_qa_poc references: $FILE_COUNT" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

# =============================================================================
# Phase 2: Include Path Analysis
# =============================================================================

log_phase "2. Include path pattern analysis"

echo "🔍 Analyzing include path patterns..." | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

# Find all unique include patterns
declare -a UNIQUE_INCLUDES
while IFS= read -r -d '' file; do
    while IFS= read -r line; do
        if [[ "$line" =~ \#include[[:space:]]*[\"<]([^\"<>]*nlink_qa_poc[^\"<>]*)[\"<] ]]; then
            include_path="${BASH_REMATCH[1]}"
            # Check if already in array
            found=0
            for existing in "${UNIQUE_INCLUDES[@]}"; do
                if [ "$existing" = "$include_path" ]; then
                    found=1
                    break
                fi
            done
            if [ $found -eq 0 ]; then
                UNIQUE_INCLUDES+=("$include_path")
            fi
        fi
    done < <(grep "#include.*nlink_qa_poc" "$file" 2>/dev/null || true)
done < <(find . -type f \( -name "*.c" -o -name "*.h" \) -print0 2>/dev/null)

echo "UNIQUE INCLUDE PATTERNS FOUND:" | tee -a "$AUDIT_REPORT"
for include in "${UNIQUE_INCLUDES[@]}"; do
    echo "  📎 #include \"$include\"" | tee -a "$AUDIT_REPORT"
    
    # Check if corresponding header exists
    if [ -f "include/$include" ]; then
        echo "    ✅ Header exists: include/$include" | tee -a "$AUDIT_REPORT"
    else
        echo "    ❌ Header missing: include/$include" | tee -a "$AUDIT_REPORT"
    fi
done
echo "" | tee -a "$AUDIT_REPORT"

# =============================================================================
# Phase 3: Missing Header Detection
# =============================================================================

log_phase "3. Missing header detection and cataloging"

echo "🔍 Detecting missing headers..." | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

declare -a MISSING_HEADERS
for include in "${UNIQUE_INCLUDES[@]}"; do
    if [ ! -f "include/$include" ]; then
        MISSING_HEADERS+=("$include")
    fi
done

if [ ${#MISSING_HEADERS[@]} -gt 0 ]; then
    echo "❌ MISSING HEADERS DETECTED:" | tee -a "$AUDIT_REPORT"
    for header in "${MISSING_HEADERS[@]}"; do
        echo "  📄 include/$header" | tee -a "$AUDIT_REPORT"
    done
    echo "" | tee -a "$AUDIT_REPORT"
else
    echo "✅ All referenced headers are present" | tee -a "$AUDIT_REPORT"
    echo "" | tee -a "$AUDIT_REPORT"
fi

# =============================================================================
# Phase 4: Replace Strategy Options
# =============================================================================

log_phase "4. Include path replacement strategy options"

echo "🔧 REPLACEMENT STRATEGY OPTIONS:" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

echo "Option 1: Remove nlink_qa_poc prefix (Direct header names)" | tee -a "$AUDIT_REPORT"
echo "  Example: #include \"nlink_qa_poc/core/config.h\" → #include \"core/config.h\"" | tee -a "$AUDIT_REPORT"
echo "  Requires: Adjusting -I include path to include/nlink_qa_poc" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

echo "Option 2: Keep nlink_qa_poc prefix (Current approach)" | tee -a "$AUDIT_REPORT"
echo "  Example: #include \"nlink_qa_poc/core/config.h\" (no change)" | tee -a "$AUDIT_REPORT"
echo "  Requires: Ensuring all headers exist in include/nlink_qa_poc/" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

echo "Option 3: Use absolute project paths" | tee -a "$AUDIT_REPORT"
echo "  Example: #include \"nlink_qa_poc/core/config.h\" → #include \"nlink/core/config.h\"" | tee -a "$AUDIT_REPORT"
echo "  Requires: Restructuring include directory to match OBINexus naming" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

# =============================================================================
# Phase 5: Interactive Replacement Options
# =============================================================================

log_phase "5. Executing systematic replacement"

echo "🔧 Select replacement strategy:"
echo "1) Remove 'nlink_qa_poc/' prefix (Recommended for OBINexus)"
echo "2) Keep 'nlink_qa_poc/' prefix and create missing headers"
echo "3) Replace 'nlink_qa_poc' with 'nlink' (OBINexus standard)"
echo "4) Generate replacement script only (no changes)"
echo ""

# For automation, default to option 2 (safest approach)
STRATEGY=2
echo "🔧 Selected Strategy: $STRATEGY (Keep nlink_qa_poc prefix, create missing headers)"

case $STRATEGY in
    1)
        log_info "Executing Strategy 1: Remove nlink_qa_poc prefix"
        for file in "${ALL_FILES[@]}"; do
            if [ -f "$file" ]; then
                log_info "Processing: $file"
                sed -i.bak 's/#include[[:space:]]*"\([^"]*\)nlink_qa_poc\/\([^"]*\)"/#include "\2"/g' "$file"
                # Also handle angle brackets
                sed -i 's/#include[[:space:]]*<\([^>]*\)nlink_qa_poc\/\([^>]*\)>/#include <\2>/g' "$file"
            fi
        done
        ;;
    2)
        log_info "Executing Strategy 2: Keep prefix, create missing headers"
        # This strategy requires creating the missing headers
        for header in "${MISSING_HEADERS[@]}"; do
            header_dir="include/$(dirname "$header")"
            header_file="include/$header"
            
            log_info "Creating directory: $header_dir"
            mkdir -p "$header_dir"
            
            log_info "Creating placeholder header: $header_file"
            cat > "$header_file" << EOF
/**
 * @file $(basename "$header")
 * @brief Auto-generated header placeholder
 * @version 1.5.1
 * TODO: Implement proper header content
 */

#ifndef $(echo "$header" | tr '[:lower:]/' '[:upper:]_' | sed 's/\.H$/_H/')
#define $(echo "$header" | tr '[:lower:]/' '[:upper:]_' | sed 's/\.H$/_H/')

#ifdef __cplusplus
extern "C" {
#endif

// TODO: Add proper header content here

#ifdef __cplusplus
}
#endif

#endif // $(echo "$header" | tr '[:lower:]/' '[:upper:]_' | sed 's/\.H$/_H/')
EOF
        done
        ;;
    3)
        log_info "Executing Strategy 3: Replace nlink_qa_poc with nlink"
        for file in "${ALL_FILES[@]}"; do
            if [ -f "$file" ]; then
                log_info "Processing: $file"
                sed -i.bak 's/nlink_qa_poc/nlink/g' "$file"
            fi
        done
        ;;
    4)
        log_info "Generating replacement script only"
        cat > replace_includes.sh << 'EOF'
#!/bin/bash
# Generated include path replacement script
# Run this script to apply systematic replacements

# Strategy 1: Remove nlink_qa_poc prefix
# find . -name "*.c" -o -name "*.h" | xargs sed -i.bak 's/#include[[:space:]]*"\([^"]*\)nlink_qa_poc\/\([^"]*\)"/#include "\2"/g'

# Strategy 2: Already implemented (create missing headers)

# Strategy 3: Replace nlink_qa_poc with nlink
# find . -name "*.c" -o -name "*.h" | xargs sed -i.bak 's/nlink_qa_poc/nlink/g'
EOF
        chmod +x replace_includes.sh
        log_success "Generated replace_includes.sh script"
        ;;
esac

# =============================================================================
# Phase 6: Validation and Testing
# =============================================================================

log_phase "6. Post-replacement validation"

echo "🧪 Testing header resolution after changes..."

# Test compilation of a sample file
cat > test_includes.c << 'EOF'
// Test file for include path validation
#include "nlink_qa_poc/core/config.h"
#include "nlink_qa_poc/core/marshal.h"
#include "nlink_qa_poc/etps/telemetry.h"

int main() {
    return 0;
}
EOF

if gcc -I include -c test_includes.c -o test_includes.o 2>/dev/null; then
    log_success "✅ Include path resolution: PASSED"
    rm -f test_includes.c test_includes.o
else
    log_warning "⚠️ Include path resolution: Still has issues"
    echo "Testing individual headers..."
    
    # Test each header individually
    for header in "${UNIQUE_INCLUDES[@]}"; do
        echo "#include \"$header\"" > "test_$(basename "$header" .h).c"
        echo "int main(){return 0;}" >> "test_$(basename "$header" .h).c"
        
        if gcc -I include -c "test_$(basename "$header" .h).c" -o "test_$(basename "$header" .h).o" 2>/dev/null; then
            echo "  ✅ $header: OK"
        else
            echo "  ❌ $header: FAILED"
        fi
        
        rm -f "test_$(basename "$header" .h).c" "test_$(basename "$header" .h).o"
    done
fi

# =============================================================================
# Phase 7: Summary Report
# =============================================================================

log_phase "7. Systematic audit completion summary"

echo "" | tee -a "$AUDIT_REPORT"
echo "=============================================================================="
echo "🎯 INCLUDE PATH AUDIT COMPLETION SUMMARY"
echo "=============================================================================="
echo "Files processed: $FILE_COUNT" | tee -a "$AUDIT_REPORT"
echo "Unique include patterns: ${#UNIQUE_INCLUDES[@]}" | tee -a "$AUDIT_REPORT"
echo "Missing headers detected: ${#MISSING_HEADERS[@]}" | tee -a "$AUDIT_REPORT"
echo "Strategy applied: $STRATEGY" | tee -a "$AUDIT_REPORT"
echo "Audit report: $AUDIT_REPORT" | tee -a "$AUDIT_REPORT"
echo "" | tee -a "$AUDIT_REPORT"

if [ ${#MISSING_HEADERS[@]} -eq 0 ]; then
    echo "✅ All include paths should now resolve correctly" | tee -a "$AUDIT_REPORT"
else
    echo "⚠️ Manual review required for complex header dependencies" | tee -a "$AUDIT_REPORT"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Review audit report: $AUDIT_REPORT"
echo "2. Test compilation: make clean && make"
echo "3. Implement missing function bodies in created headers"
echo "4. Continue with systematic development"
echo ""
echo "🚀 Include path audit and replacement completed"
echo "=============================================================================="

log_success "Systematic include path audit completed successfully"
