# SemVerX Shared Artifact Coordination Demo

## Strategic Demonstration Objective

**Problem**: Mathematical calculation pipeline requiring version-aware component coordination
**Solution**: SemVerX-orchestrated calculation engine with hot-swappable algorithms

## Directory Structure (Systematic Reorganization)

```
nlink_cli_semverx/
├── bin/                           # Executable outputs
├── examples/                      # Demonstration scenarios
│   ├── calculation_pipeline/      # Primary demo: Mathematical calculation
│   │   ├── pkg.nlink             # Project coordination manifest
│   │   ├── basic_math/           # Component 1: Stable range state
│   │   │   ├── nlink.txt         # Component metadata
│   │   │   └── src/calculator.c   # Basic arithmetic implementation
│   │   ├── advanced_math/        # Component 2: Experimental range state
│   │   │   ├── nlink.txt         # Enhanced algorithms metadata
│   │   │   └── src/scientific.c   # Scientific calculation implementation
│   │   └── shared_orchestration/ # Shared artifact coordination
│   │       ├── calculation_registry.nlink
│   │       ├── algorithm_compatibility.nlink
│   │       └── precision_policies.nlink
│   └── simple_parser/            # Secondary demo: Simplified validation
│       ├── pkg.nlink
│       ├── lexer_component/
│       └── parser_component/
├── nlink/                        # Global shared artifacts
│   ├── shared_artifacts/
│   │   └── global_registry.nlink
│   ├── compatibility_matrix.nlink
│   └── range_policies.nlink
└── [existing structure...]
```

## Calculation Pipeline Demonstration

### Problem Scenario
A mathematical calculation engine requiring:
- **Basic arithmetic** (stable, production-ready)
- **Scientific calculations** (experimental, opt-in required)
- **Version compatibility** between algorithm implementations
- **Hot-swap capability** for algorithm upgrades

### SemVerX Coordination Flow

1. **Component Registration**: Each math component registers in shared artifact registry
2. **Compatibility Validation**: Matrix ensures basic ↔ scientific compatibility
3. **Calculation Orchestration**: Pipeline selects components based on range states
4. **Result Validation**: Cross-component verification ensures accuracy

## Implementation Plan

### Phase 1: Build System Fix
```makefile
# Enhanced Makefile targets
bin/nlink: $(OBJECTS) $(SEMVERX_OBJECTS)
	@mkdir -p bin
	$(CC) $(OBJECTS) $(SEMVERX_OBJECTS) $(LDFLAGS) -o bin/nlink

examples-build:
	@mkdir -p examples/calculation_pipeline/basic_math/build
	@mkdir -p examples/calculation_pipeline/advanced_math/build
	$(CC) examples/calculation_pipeline/basic_math/src/calculator.c -o examples/calculation_pipeline/basic_math/build/calculator
	$(CC) examples/calculation_pipeline/advanced_math/src/scientific.c -o examples/calculation_pipeline/advanced_math/build/scientific

demo-calculation: bin/nlink examples-build
	./bin/nlink --semverx-orchestrate examples/calculation_pipeline
```

### Phase 2: Shared Artifact Configuration

#### `examples/calculation_pipeline/pkg.nlink`
```ini
[project]
name = mathematical_calculation_pipeline
version = 1.0.0
entry_point = calculation_orchestrator

[semverx]
range_state = stable
registry_mode = centralized
shared_registry_path = ./shared_orchestration/calculation_registry.nlink
compatibility_matrix_path = ./shared_orchestration/algorithm_compatibility.nlink

[calculation_pipeline]
precision_requirements = double
algorithm_fallback = basic_math
experimental_algorithms_allowed = true
```

#### `examples/calculation_pipeline/shared_orchestration/calculation_registry.nlink`
```ini
[shared_calculation_registry]
registry_version = 1.0.0
total_algorithms = 2

[algorithm_basic_math]
component_name = basic_math
range_state = stable
version = 1.2.0
capabilities = ["add", "subtract", "multiply", "divide"]
precision = single
hot_swap_enabled = true

[algorithm_advanced_math]
component_name = advanced_math  
range_state = experimental
version = 2.0.0-alpha.1
capabilities = ["sin", "cos", "log", "exp", "sqrt"]
precision = double
requires_opt_in = true
fallback_component = basic_math
```

#### `examples/calculation_pipeline/shared_orchestration/algorithm_compatibility.nlink`
```ini
[compatibility_matrix]
matrix_version = 1.0.0

[stable_algorithms]
basic_math.compatible_with = ["basic_math.1.x.x"]
basic_math.hot_swap_policy = version_upgrade_allowed

[experimental_algorithms]
advanced_math.compatible_with = ["advanced_math.2.0.x-alpha"]
advanced_math.hot_swap_policy = explicit_validation_required
advanced_math.fallback_required = true

[cross_range_compatibility]
stable_to_experimental = calculation_chaining_allowed
experimental_to_stable = result_validation_required
```

### Phase 3: Calculation Implementation

#### `examples/calculation_pipeline/basic_math/src/calculator.c`
```c
#include <stdio.h>
#include <stdlib.h>

// Basic arithmetic component (stable range state)
typedef struct {
    double (*add)(double a, double b);
    double (*subtract)(double a, double b);
    double (*multiply)(double a, double b);
    double (*divide)(double a, double b);
} basic_math_api_t;

double basic_add(double a, double b) { return a + b; }
double basic_subtract(double a, double b) { return a - b; }
double basic_multiply(double a, double b) { return a * b; }
double basic_divide(double a, double b) { return (b != 0) ? a / b : 0; }

basic_math_api_t basic_math = {
    .add = basic_add,
    .subtract = basic_subtract,
    .multiply = basic_multiply,
    .divide = basic_divide
};

int main(int argc, char *argv[]) {
    printf("[BASIC_MATH] Stable calculation component v1.2.0\n");
    
    if (argc != 4) {
        printf("Usage: %s <operation> <num1> <num2>\n", argv[0]);
        return 1;
    }
    
    double a = atof(argv[2]);
    double b = atof(argv[3]);
    double result = 0;
    
    if (strcmp(argv[1], "add") == 0) result = basic_math.add(a, b);
    else if (strcmp(argv[1], "subtract") == 0) result = basic_math.subtract(a, b);
    else if (strcmp(argv[1], "multiply") == 0) result = basic_math.multiply(a, b);
    else if (strcmp(argv[1], "divide") == 0) result = basic_math.divide(a, b);
    
    printf("[RESULT] %.6f\n", result);
    return 0;
}
```

### Phase 4: Terminal Orchestration Demo

```bash
# Demonstrate SemVerX coordination
cd examples/calculation_pipeline

# Step 1: Validate shared artifact configuration
../../bin/nlink --semverx-validate --registry-check

# Step 2: Execute coordinated calculation pipeline
../../bin/nlink --semverx-orchestrate --operation "complex_calculation"

# Step 3: Test hot-swap capability
../../bin/nlink --hot-swap-test basic_math advanced_math

# Expected Output:
# [SEMVERX] Loading shared registry: calculation_registry.nlink
# [SEMVERX] Compatibility matrix loaded: 2 algorithms validated
# [SEMVERX] Range state enforcement: stable ↔ experimental validation
# [CALCULATION] Pipeline orchestrated: basic_math.1.2.0 → advanced_math.2.0.0-alpha.1
# [RESULT] Calculation completed with cross-component validation
```

## Strategic Value Demonstration

This architecture demonstrates:

1. **Shared Artifact Coordination**: Registry-driven component discovery and validation
2. **Range State Enforcement**: Systematic compatibility between stable/experimental components  
3. **Hot-Swap Capability**: Runtime algorithm replacement with validation
4. **Systematic Problem Solving**: Mathematical calculation pipeline with version-aware orchestration

## Implementation Priority

1. **Fix build system** - Ensure `bin/nlink` executable creation
2. **Create examples/ directory structure**
3. **Implement calculation pipeline demo**
4. **Validate shared artifact coordination**
5. **Test terminal orchestration workflow**

This approach provides a concrete, compilable demonstration that showcases SemVerX value through systematic mathematical problem-solving with shared artifact coordination.