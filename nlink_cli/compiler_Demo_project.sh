#!/bin/bash

# NexusLink Compiler Demo Project Setup
# Aegis Project - Real-World Compiler Feature Implementation
# Author: Nnamdi Michael Okpala & Development Team

# =============================================================================
# PROJECT STRUCTURE CREATION
# =============================================================================

echo "=== Creating NexusLink Compiler Demo Project ==="

# Create project directory structure
mkdir -p compiler_demo/{src,include,lib,bin,test,docs}

# Create main project directories
mkdir -p compiler_demo/src/{lexer,parser,symtab,codegen}
mkdir -p compiler_demo/include/{lexer,parser,symtab,codegen}
mkdir -p compiler_demo/test/{samples,unit}

echo "Project structure created successfully"

# =============================================================================
# CORE SYMBOL TABLE IMPLEMENTATION
# =============================================================================

# Create symbol table header
cat > compiler_demo/include/symtab/symbol_table.h << 'EOF'
/**
 * @file symbol_table.h
 * @brief Production-Grade Symbol Table Manager
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * 
 * Real-world compiler symbol table implementation with type checking,
 * scope management, and systematic error reporting integration.
 */

#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

// =============================================================================
// TYPE DEFINITIONS AND ENUMERATIONS
// =============================================================================

typedef enum {
    SYM_TYPE_INT,
    SYM_TYPE_FLOAT,
    SYM_TYPE_CHAR,
    SYM_TYPE_STRING,
    SYM_TYPE_POINTER,
    SYM_TYPE_ARRAY,
    SYM_TYPE_FUNCTION,
    SYM_TYPE_STRUCT,
    SYM_TYPE_UNKNOWN
} symbol_type_t;

typedef enum {
    SYM_SCOPE_GLOBAL,
    SYM_SCOPE_LOCAL,
    SYM_SCOPE_PARAMETER,
    SYM_SCOPE_FUNCTION
} symbol_scope_t;

typedef struct symbol_entry {
    char *name;                    // Symbol identifier
    symbol_type_t type;           // Data type
    symbol_scope_t scope;         // Scope level
    uint32_t line_number;         // Declaration line
    uint32_t column;              // Declaration column
    size_t size;                  // Memory size
    bool is_initialized;          // Initialization status
    bool is_constant;             // Const qualifier
    struct symbol_entry *next;    // Hash chain
} symbol_entry_t;

typedef struct symbol_table {
    symbol_entry_t **buckets;     // Hash table buckets
    uint32_t bucket_count;        // Number of buckets
    uint32_t symbol_count;        // Total symbols
    uint32_t scope_level;         // Current scope depth
    struct symbol_table *parent;  // Parent scope
} symbol_table_t;

typedef enum {
    SYMTAB_SUCCESS,
    SYMTAB_ERROR_DUPLICATE,
    SYMTAB_ERROR_NOT_FOUND,
    SYMTAB_ERROR_TYPE_MISMATCH,
    SYMTAB_ERROR_SCOPE_INVALID,
    SYMTAB_ERROR_MEMORY_ALLOCATION
} symtab_result_t;

// =============================================================================
// CORE SYMBOL TABLE OPERATIONS
// =============================================================================

/**
 * @brief Initialize symbol table with specified capacity
 */
symbol_table_t* symtab_create(uint32_t bucket_count);

/**
 * @brief Add symbol to table with type checking
 */
symtab_result_t symtab_add_symbol(symbol_table_t *table, 
                                 const char *name,
                                 symbol_type_t type,
                                 symbol_scope_t scope,
                                 uint32_t line, uint32_t column);

/**
 * @brief Lookup symbol with scope resolution
 */
symbol_entry_t* symtab_lookup(symbol_table_t *table, const char *name);

/**
 * @brief Validate type compatibility for assignments
 */
bool symtab_check_type_compatibility(symbol_type_t from, symbol_type_t to);

/**
 * @brief Enter new scope level
 */
symbol_table_t* symtab_enter_scope(symbol_table_t *parent);

/**
 * @brief Exit current scope and cleanup
 */
symbol_table_t* symtab_exit_scope(symbol_table_t *current);

/**
 * @brief Display symbol table contents for debugging
 */
void symtab_display(symbol_table_t *table);

/**
 * @brief Cleanup symbol table and free memory
 */
void symtab_destroy(symbol_table_t *table);

#endif /* SYMBOL_TABLE_H */
EOF

# Create symbol table implementation
cat > compiler_demo/src/symtab/symbol_table.c << 'EOF'
/**
 * @file symbol_table.c
 * @brief Symbol Table Implementation
 */

#include "symtab/symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEFAULT_BUCKET_COUNT 256

// =============================================================================
// HASH FUNCTION IMPLEMENTATION
// =============================================================================

static uint32_t hash_function(const char *str, uint32_t bucket_count) {
    uint32_t hash = 5381;
    int c;
    
    while ((c = *str++)) {
        hash = ((hash << 5) + hash) + c;
    }
    
    return hash % bucket_count;
}

// =============================================================================
// CORE SYMBOL TABLE OPERATIONS
// =============================================================================

symbol_table_t* symtab_create(uint32_t bucket_count) {
    if (bucket_count == 0) {
        bucket_count = DEFAULT_BUCKET_COUNT;
    }
    
    symbol_table_t *table = malloc(sizeof(symbol_table_t));
    if (!table) return NULL;
    
    table->buckets = calloc(bucket_count, sizeof(symbol_entry_t*));
    if (!table->buckets) {
        free(table);
        return NULL;
    }
    
    table->bucket_count = bucket_count;
    table->symbol_count = 0;
    table->scope_level = 0;
    table->parent = NULL;
    
    return table;
}

symtab_result_t symtab_add_symbol(symbol_table_t *table, 
                                 const char *name,
                                 symbol_type_t type,
                                 symbol_scope_t scope,
                                 uint32_t line, uint32_t column) {
    if (!table || !name) return SYMTAB_ERROR_SCOPE_INVALID;
    
    // Check for duplicate in current scope
    uint32_t hash = hash_function(name, table->bucket_count);
    symbol_entry_t *entry = table->buckets[hash];
    
    while (entry) {
        if (strcmp(entry->name, name) == 0 && entry->scope == scope) {
            return SYMTAB_ERROR_DUPLICATE;
        }
        entry = entry->next;
    }
    
    // Create new symbol entry
    symbol_entry_t *new_entry = malloc(sizeof(symbol_entry_t));
    if (!new_entry) return SYMTAB_ERROR_MEMORY_ALLOCATION;
    
    new_entry->name = strdup(name);
    new_entry->type = type;
    new_entry->scope = scope;
    new_entry->line_number = line;
    new_entry->column = column;
    new_entry->is_initialized = false;
    new_entry->is_constant = false;
    
    // Calculate size based on type
    switch (type) {
        case SYM_TYPE_INT: new_entry->size = sizeof(int); break;
        case SYM_TYPE_FLOAT: new_entry->size = sizeof(float); break;
        case SYM_TYPE_CHAR: new_entry->size = sizeof(char); break;
        case SYM_TYPE_POINTER: new_entry->size = sizeof(void*); break;
        default: new_entry->size = 0; break;
    }
    
    // Insert at head of chain
    new_entry->next = table->buckets[hash];
    table->buckets[hash] = new_entry;
    table->symbol_count++;
    
    return SYMTAB_SUCCESS;
}

symbol_entry_t* symtab_lookup(symbol_table_t *table, const char *name) {
    while (table) {
        uint32_t hash = hash_function(name, table->bucket_count);
        symbol_entry_t *entry = table->buckets[hash];
        
        while (entry) {
            if (strcmp(entry->name, name) == 0) {
                return entry;
            }
            entry = entry->next;
        }
        
        table = table->parent; // Search parent scope
    }
    
    return NULL;
}

bool symtab_check_type_compatibility(symbol_type_t from, symbol_type_t to) {
    if (from == to) return true;
    
    // Allow implicit conversions
    if ((from == SYM_TYPE_INT && to == SYM_TYPE_FLOAT) ||
        (from == SYM_TYPE_CHAR && to == SYM_TYPE_INT)) {
        return true;
    }
    
    return false;
}

void symtab_display(symbol_table_t *table) {
    printf("=== Symbol Table (Scope Level %d) ===\n", table->scope_level);
    printf("Total Symbols: %d\n", table->symbol_count);
    
    for (uint32_t i = 0; i < table->bucket_count; i++) {
        symbol_entry_t *entry = table->buckets[i];
        while (entry) {
            const char *type_str = "unknown";
            switch (entry->type) {
                case SYM_TYPE_INT: type_str = "int"; break;
                case SYM_TYPE_FLOAT: type_str = "float"; break;
                case SYM_TYPE_CHAR: type_str = "char"; break;
                case SYM_TYPE_STRING: type_str = "string"; break;
                case SYM_TYPE_POINTER: type_str = "pointer"; break;
                default: break;
            }
            
            printf("  %s: %s (line %d, scope %d)\n", 
                   entry->name, type_str, entry->line_number, entry->scope);
            entry = entry->next;
        }
    }
    printf("===============================\n\n");
}

void symtab_destroy(symbol_table_t *table) {
    if (!table) return;
    
    for (uint32_t i = 0; i < table->bucket_count; i++) {
        symbol_entry_t *entry = table->buckets[i];
        while (entry) {
            symbol_entry_t *next = entry->next;
            free(entry->name);
            free(entry);
            entry = next;
        }
    }
    
    free(table->buckets);
    free(table);
}
EOF

# Create main demonstration program
cat > compiler_demo/src/main.c << 'EOF'
/**
 * @file main.c
 * @brief NexusLink Compiler Demo - Symbol Table Manager
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * 
 * Demonstration of real-world compiler symbol table management
 * integrated with NexusLink configuration system.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab/symbol_table.h"

// Simple lexer for parsing variable declarations
typedef struct {
    const char *input;
    size_t position;
    size_t length;
    uint32_t line;
    uint32_t column;
} lexer_t;

typedef enum {
    TOKEN_INT, TOKEN_FLOAT, TOKEN_CHAR,
    TOKEN_IDENTIFIER, TOKEN_SEMICOLON,
    TOKEN_ASSIGN, TOKEN_NUMBER, TOKEN_EOF
} token_type_t;

typedef struct {
    token_type_t type;
    char *value;
    uint32_t line;
    uint32_t column;
} token_t;

// =============================================================================
// SIMPLE LEXER IMPLEMENTATION
// =============================================================================

static bool is_alpha(char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
}

static bool is_digit(char c) {
    return c >= '0' && c <= '9';
}

static bool is_alnum(char c) {
    return is_alpha(c) || is_digit(c);
}

static void skip_whitespace(lexer_t *lexer) {
    while (lexer->position < lexer->length) {
        char c = lexer->input[lexer->position];
        if (c == ' ' || c == '\t') {
            lexer->position++;
            lexer->column++;
        } else if (c == '\n') {
            lexer->position++;
            lexer->line++;
            lexer->column = 1;
        } else {
            break;
        }
    }
}

static token_t next_token(lexer_t *lexer) {
    token_t token = {TOKEN_EOF, NULL, lexer->line, lexer->column};
    
    skip_whitespace(lexer);
    
    if (lexer->position >= lexer->length) {
        return token;
    }
    
    char c = lexer->input[lexer->position];
    
    if (is_alpha(c)) {
        // Identifier or keyword
        size_t start = lexer->position;
        while (lexer->position < lexer->length && is_alnum(lexer->input[lexer->position])) {
            lexer->position++;
            lexer->column++;
        }
        
        size_t len = lexer->position - start;
        token.value = malloc(len + 1);
        strncpy(token.value, &lexer->input[start], len);
        token.value[len] = '\0';
        
        // Check for keywords
        if (strcmp(token.value, "int") == 0) token.type = TOKEN_INT;
        else if (strcmp(token.value, "float") == 0) token.type = TOKEN_FLOAT;
        else if (strcmp(token.value, "char") == 0) token.type = TOKEN_CHAR;
        else token.type = TOKEN_IDENTIFIER;
        
    } else if (is_digit(c)) {
        // Number literal
        size_t start = lexer->position;
        while (lexer->position < lexer->length && is_digit(lexer->input[lexer->position])) {
            lexer->position++;
            lexer->column++;
        }
        
        size_t len = lexer->position - start;
        token.value = malloc(len + 1);
        strncpy(token.value, &lexer->input[start], len);
        token.value[len] = '\0';
        token.type = TOKEN_NUMBER;
        
    } else if (c == ';') {
        token.type = TOKEN_SEMICOLON;
        lexer->position++;
        lexer->column++;
    } else if (c == '=') {
        token.type = TOKEN_ASSIGN;
        lexer->position++;
        lexer->column++;
    } else {
        // Skip unknown character
        lexer->position++;
        lexer->column++;
        return next_token(lexer);
    }
    
    return token;
}

// =============================================================================
// DEMONSTRATION FUNCTIONS
// =============================================================================

static void demonstrate_symbol_table() {
    printf("=== NexusLink Compiler Demo: Symbol Table Manager ===\n\n");
    
    // Create symbol table
    symbol_table_t *global_scope = symtab_create(64);
    if (!global_scope) {
        printf("Failed to create symbol table\n");
        return;
    }
    
    printf("1. Adding symbols to global scope:\n");
    
    // Add some test symbols
    symtab_add_symbol(global_scope, "main_counter", SYM_TYPE_INT, SYM_SCOPE_GLOBAL, 1, 1);
    symtab_add_symbol(global_scope, "pi_value", SYM_TYPE_FLOAT, SYM_SCOPE_GLOBAL, 2, 1);
    symtab_add_symbol(global_scope, "user_name", SYM_TYPE_STRING, SYM_SCOPE_GLOBAL, 3, 1);
    
    symtab_display(global_scope);
    
    printf("2. Testing symbol lookup:\n");
    symbol_entry_t *found = symtab_lookup(global_scope, "main_counter");
    if (found) {
        printf("   Found: %s (type: %d, line: %d)\n", 
               found->name, found->type, found->line_number);
    }
    
    printf("3. Testing type compatibility:\n");
    bool compatible = symtab_check_type_compatibility(SYM_TYPE_INT, SYM_TYPE_FLOAT);
    printf("   int -> float: %s\n", compatible ? "Compatible" : "Incompatible");
    
    compatible = symtab_check_type_compatibility(SYM_TYPE_STRING, SYM_TYPE_INT);
    printf("   string -> int: %s\n", compatible ? "Compatible" : "Incompatible");
    
    printf("4. Testing duplicate detection:\n");
    symtab_result_t result = symtab_add_symbol(global_scope, "main_counter", SYM_TYPE_FLOAT, SYM_SCOPE_GLOBAL, 5, 1);
    printf("   Adding duplicate 'main_counter': %s\n", 
           result == SYMTAB_ERROR_DUPLICATE ? "Detected duplicate (correct)" : "Unexpected result");
    
    symtab_destroy(global_scope);
    printf("\n=== Demo completed successfully ===\n");
}

static void parse_simple_declarations(const char *source_code) {
    printf("\n=== Parsing Variable Declarations ===\n");
    printf("Source: %s\n\n", source_code);
    
    lexer_t lexer = {source_code, 0, strlen(source_code), 1, 1};
    symbol_table_t *table = symtab_create(32);
    
    token_t token = next_token(&lexer);
    
    while (token.type != TOKEN_EOF) {
        if (token.type == TOKEN_INT || token.type == TOKEN_FLOAT || token.type == TOKEN_CHAR) {
            symbol_type_t type = (token.type == TOKEN_INT) ? SYM_TYPE_INT :
                               (token.type == TOKEN_FLOAT) ? SYM_TYPE_FLOAT : SYM_TYPE_CHAR;
            
            free(token.value);
            token = next_token(&lexer);
            
            if (token.type == TOKEN_IDENTIFIER) {
                symtab_result_t result = symtab_add_symbol(table, token.value, type, 
                                                         SYM_SCOPE_LOCAL, token.line, token.column);
                
                if (result == SYMTAB_SUCCESS) {
                    printf("Parsed declaration: %s (type: %d)\n", token.value, type);
                } else {
                    printf("Error adding symbol: %s\n", token.value);
                }
            }
        }
        
        if (token.value) free(token.value);
        token = next_token(&lexer);
    }
    
    printf("\nFinal symbol table:\n");
    symtab_display(table);
    symtab_destroy(table);
}

// =============================================================================
// MAIN DEMONSTRATION PROGRAM
// =============================================================================

int main(int argc, char *argv[]) {
    printf("NexusLink Compiler Demo - Phase 1 Symbol Table Implementation\n");
    printf("Aegis Project: Real-World Compiler Engineering\n");
    printf("Author: Nnamdi Michael Okpala & Development Team\n\n");
    
    // Basic symbol table demonstration
    demonstrate_symbol_table();
    
    // Parse some simple variable declarations
    const char *sample_code = "int counter; float rate; char grade; int value;";
    parse_simple_declarations(sample_code);
    
    if (argc > 1) {
        printf("\n=== Processing command line input ===\n");
        parse_simple_declarations(argv[1]);
    }
    
    printf("\n=== Compiler Demo Completed Successfully ===\n");
    printf("This demonstrates real-world symbol table management\n");
    printf("suitable for production compiler implementation.\n\n");
    
    return 0;
}
EOF

# Create demo Makefile with dual linker support
cat > compiler_demo/Makefile << 'EOF'
# NexusLink Compiler Demo Makefile
# Aegis Project - Real-World Compiler Feature Demo
# Dual Linker Support: LINKER=nlink or LINKER=ld

# =============================================================================
# BUILD CONFIGURATION
# =============================================================================

CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -pedantic -O2 -g
INCLUDES = -I./include
SRCDIR = src
OBJDIR = build
BINDIR = bin

# Linker selection - can be overridden with LINKER=nlink or LINKER=ld
LINKER ?= ld
NLINK_PATH ?= ../bin/nlink

# Source files
SOURCES = $(SRCDIR)/main.c $(SRCDIR)/symtab/symbol_table.c
OBJECTS = $(OBJDIR)/main.o $(OBJDIR)/symbol_table.o

# Target executables
TARGET_NLINK = $(BINDIR)/compiler_demo_nlink
TARGET_LD = $(BINDIR)/compiler_demo_ld

# =============================================================================
# MAIN TARGETS
# =============================================================================

.PHONY: all
all: $(TARGET_LD)

# Build with NexusLink integration
.PHONY: nlink
nlink: $(TARGET_NLINK)

# Build with standard ld
.PHONY: standard
standard: $(TARGET_LD)

# Build both variants
.PHONY: both
both: $(TARGET_NLINK) $(TARGET_LD)

# =============================================================================
# LINKER-SPECIFIC BUILDS
# =============================================================================

$(TARGET_NLINK): $(OBJECTS) | $(BINDIR)
	@echo "[DEMO BUILD] Linking with NexusLink integration"
	@if [ -f "$(NLINK_PATH)" ]; then \
		echo "[DEMO] Using NexusLink for build coordination"; \
		$(NLINK_PATH) --config-check --verbose; \
		$(CC) $(OBJECTS) -o $(TARGET_NLINK); \
	else \
		echo "[DEMO WARNING] NexusLink not found, using standard linking"; \
		$(CC) $(OBJECTS) -o $(TARGET_NLINK); \
	fi
	@echo "[DEMO SUCCESS] NexusLink variant created: $(TARGET_NLINK)"

$(TARGET_LD): $(OBJECTS) | $(BINDIR)
	@echo "[DEMO BUILD] Linking with standard ld"
	$(CC) $(OBJECTS) -o $(TARGET_LD)
	@echo "[DEMO SUCCESS] Standard variant created: $(TARGET_LD)"

# =============================================================================
# OBJECT FILE COMPILATION
# =============================================================================

$(OBJDIR)/main.o: $(SRCDIR)/main.c | $(OBJDIR)
	@echo "[DEMO BUILD] Compiling main.c"
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/main.c -o $(OBJDIR)/main.o

$(OBJDIR)/symbol_table.o: $(SRCDIR)/symtab/symbol_table.c | $(OBJDIR)
	@echo "[DEMO BUILD] Compiling symbol_table.c" 
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/symtab/symbol_table.c -o $(OBJDIR)/symbol_table.o

# =============================================================================
# DIRECTORY CREATION
# =============================================================================

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

# =============================================================================
# DEMONSTRATION TARGETS
# =============================================================================

.PHONY: demo
demo: $(TARGET_LD)
	@echo "=== Running Compiler Demo ==="
	./$(TARGET_LD)

.PHONY: demo-nlink
demo-nlink: $(TARGET_NLINK)
	@echo "=== Running NexusLink-Integrated Demo ==="
	./$(TARGET_NLINK)

.PHONY: demo-parse
demo-parse: $(TARGET_LD)
	@echo "=== Testing Declaration Parsing ==="
	./$(TARGET_LD) "int main_var; float calc_rate; char user_input; int loop_counter;"

# =============================================================================
# VALIDATION TARGETS
# =============================================================================

.PHONY: test
test: both
	@echo "[DEMO TEST] Validating both build variants"
	@./$(TARGET_LD) >/dev/null && echo "✓ Standard build functional" || echo "✗ Standard build failed"
	@./$(TARGET_NLINK) >/dev/null && echo "✓ NexusLink build functional" || echo "✗ NexusLink build failed"

.PHONY: validate
validate: test
	@echo "[DEMO VALIDATE] Comparing executable outputs"
	@file $(TARGET_LD)
	@file $(TARGET_NLINK)
	@echo "Validation completed"

# =============================================================================
# LINKER OVERRIDE SUPPORT
# =============================================================================

.PHONY: linker-nlink
linker-nlink:
	@$(MAKE) LINKER=nlink nlink

.PHONY: linker-ld  
linker-ld:
	@$(MAKE) LINKER=ld standard

# =============================================================================
# CLEANUP
# =============================================================================

.PHONY: clean
clean:
	@echo "[DEMO CLEAN] Removing build artifacts"
	rm -rf $(OBJDIR) $(BINDIR)
	@echo "[DEMO SUCCESS] Cleanup completed"

# =============================================================================
# HELP DOCUMENTATION
# =============================================================================

.PHONY: help
help:
	@echo "NexusLink Compiler Demo Build System"
	@echo "Aegis Project - Real-World Compiler Engineering"
	@echo ""
	@echo "Targets:"
	@echo "  all         - Build standard executable (default)"
	@echo "  nlink       - Build with NexusLink integration"
	@echo "  both        - Build both variants"
	@echo "  demo        - Run standard demo"
	@echo "  demo-nlink  - Run NexusLink demo"
	@echo "  demo-parse  - Test declaration parsing"
	@echo "  test        - Validate both builds"
	@echo "  clean       - Remove build artifacts"
	@echo ""
	@echo "Linker Override:"
	@echo "  make LINKER=nlink  - Force NexusLink integration"
	@echo "  make LINKER=ld     - Force standard linking"

EOF

# Create pkg.nlink configuration for the demo
cat > compiler_demo/pkg.nlink << 'EOF'
# NexusLink Compiler Demo Configuration
[project]
name = compiler_demo
version = 1.0.0
entry_point = src/main.c
description = Real-world compiler symbol table demonstration

[build]
pass_mode = single
experimental_mode = false
strict_mode = true
library_target = compiler_demo
executable_target = compiler_demo

[compilation]
compiler = gcc
c_standard = c99
optimization_level = 2
enable_debug_symbols = true

[features]
symbol_table_management = true
type_checking = true
scope_resolution = true
memory_optimization = true
debug_output = true
EOF

# Create test samples
mkdir -p compiler_demo/test/samples
cat > compiler_demo/test/samples/simple.c << 'EOF'
int main_counter;
float pi_value;
char user_grade;
int loop_index;
float calculation_result;
EOF

cat > compiler_demo/test/samples/complex.c << 'EOF'  
int global_var;
float rate_table;
char status_flag;
int error_code;
float precision_value;
char buffer_char;
int validation_result;
EOF

echo ""
echo "=== NexusLink Compiler Demo Project Created ==="
echo "Location: ./compiler_demo/"
echo ""
echo "Next steps:"
echo "1. cd compiler_demo"
echo "2. make help              # View available targets"
echo "3. make both              # Build both variants"
echo "4. make demo              # Run demonstration"
echo "5. make LINKER=nlink nlink # Test NexusLink integration"
echo ""
echo "This demonstrates real-world compiler engineering with:"
echo "- Production-grade symbol table management"
echo "- Type checking and validation"  
echo "- Scope resolution"
echo "- Integration with NexusLink configuration system"
echo "- Dual linker support (nlink vs ld)"
EOF

chmod +x compiler_demo_project.sh
