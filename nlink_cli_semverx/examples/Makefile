
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
