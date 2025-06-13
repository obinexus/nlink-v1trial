/**
 * =============================================================================
 * NexusLink QA POC - Core Configuration Header
 * OBINexus Engineering - Configuration Parsing with ETPS Integration
 * =============================================================================
 * 
 * CRITICAL FIX: Includes stddef.h to resolve size_t compilation errors
 * Provides configuration structures and parsing functions with telemetry
 */

#ifndef NLINK_QA_POC_CORE_CONFIG_H
#define NLINK_QA_POC_CORE_CONFIG_H

// CRITICAL FIX: Include stddef.h FIRST to resolve size_t compilation errors
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// =============================================================================
// Configuration Structure Definitions
// =============================================================================

// Main configuration structure for NexusLink projects
typedef struct {
    char project_name[128];         // Project name
    char version[32];               // Project version
    char entry_point[256];          // Entry point file path
    char description[512];          // Project description
    
    // Build configuration
    bool strict_mode;               // Strict validation mode
    bool experimental_mode;         // Experimental features enabled
    bool debug_symbols;             // Include debug symbols
    bool ast_optimization;          // AST optimization enabled
    bool quality_assurance;         // QA mode enabled
    
    // Threading configuration
    int worker_count;               // Number of worker threads
    int queue_depth;                // Queue depth for operations
    int stack_size_kb;              // Stack size in KB
    bool enable_work_stealing;      // Work stealing enabled
    
    // Language support
    char supported_languages[512]; // Comma-separated list
    char primary_language[32];      // Primary language
    bool build_coordination;        // Build coordination enabled
    
    // Resolution configuration
    char search_paths[1024];        // Search paths (semicolon-separated)
    bool fallback_resolution;       // Fallback resolution enabled
    
    // SemVerX configuration
    char compatible_range[64];      // Compatible version range
    bool cross_language_compatibility; // Cross-language compatibility
    
    // Feature flags
    bool unicode_normalization;     // Unicode normalization
    bool isomorphic_reduction;      // Isomorphic reduction
    
    // QA-specific settings
    char unit_test_framework[64];   // Unit test framework name
    char integration_test_framework[64]; // Integration test framework
    int coverage_threshold;         // Coverage threshold percentage
    bool static_analysis;           // Static analysis enabled
    bool memory_leak_detection;     // Memory leak detection enabled
} nlink_config_t;

// Configuration loading options
typedef struct {
    bool validate_syntax;           // Validate configuration syntax
    bool strict_validation;         // Strict validation mode
    bool log_parsing_errors;        // Log parsing errors to ETPS
    char error_log_file[256];       // Error log file path
} nlink_config_options_t;

// =============================================================================
// FIXED: Configuration Parsing Functions with size_t Support
// =============================================================================

/**
 * Parse project name from configuration input
 * FIXED: Uses size_t for buffer length parameters
 * 
 * @param input Input string containing project name
 * @param output Output buffer for parsed project name
 * @param max_len Maximum length of output buffer (including null terminator)
 * @return 0 on success, -1 on error (with ETPS event logged)
 */
int nlink_parse_project_name(const char* input, char* output, size_t max_len);

/**
 * Parse version string from configuration input
 * FIXED: Uses size_t for buffer length parameters
 * 
 * @param input Input string containing version
 * @param output Output buffer for parsed version
 * @param max_len Maximum length of output buffer (including null terminator)
 * @return 0 on success, -1 on error (with ETPS event logged)
 */
int nlink_parse_version(const char* input, char* output, size_t max_len);

/**
 * Load configuration from file
 * Implements comprehensive configuration parsing with ETPS integration
 * 
 * @param filename Path to configuration file
 * @param config Pointer to configuration structure to populate
 * @return 0 on success, -1 on error (with ETPS events logged)
 */
int nlink_load_config(const char* filename, nlink_config_t* config);

/**
 * Load configuration with options
 * Extended configuration loading with parsing options
 * 
 * @param filename Path to configuration file
 * @param config Pointer to configuration structure to populate
 * @param options Configuration loading options
 * @return 0 on success, -1 on error (with ETPS events logged)
 */
int nlink_load_config_with_options(const char* filename, 
                                  nlink_config_t* config,
                                  const nlink_config_options_t* options);

/**
 * Save configuration to file
 * Serialize configuration structure to file format
 * 
 * @param filename Path to output configuration file
 * @param config Pointer to configuration structure to save
 * @return 0 on success, -1 on error (with ETPS events logged)
 */
int nlink_save_config(const char* filename, const nlink_config_t* config);

/**
 * Validate configuration structure
 * Comprehensive validation of configuration values
 * 
 * @param config Pointer to configuration structure to validate
 * @return 0 if valid, -1 if invalid (with ETPS validation events logged)
 */
int nlink_validate_config(const nlink_config_t* config);

/**
 * Initialize configuration structure with defaults
 * Sets up default values for all configuration fields
 * 
 * @param config Pointer to configuration structure to initialize
 * @return 0 on success, -1 on error
 */
int nlink_init_config(nlink_config_t* config);

/**
 * Clone configuration structure
 * FIXED: Uses size_t for internal buffer operations
 * 
 * @param source Source configuration to clone
 * @param destination Destination configuration structure
 * @return 0 on success, -1 on error
 */
int nlink_clone_config(const nlink_config_t* source, nlink_config_t* destination);

/**
 * Merge configuration structures
 * Merge settings from source into destination
 * 
 * @param destination Configuration to merge into
 * @param source Configuration to merge from
 * @param overwrite_existing Whether to overwrite existing values
 * @return 0 on success, -1 on error
 */
int nlink_merge_config(nlink_config_t* destination, 
                      const nlink_config_t* source,
                      bool overwrite_existing);

// =============================================================================
// Configuration Utility Functions
// =============================================================================

/**
 * Get configuration value as string
 * FIXED: Uses size_t for buffer operations
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value Output buffer for value
 * @param value_size Size of output buffer
 * @return 0 on success, -1 if key not found
 */
int nlink_config_get_string(const nlink_config_t* config, 
                           const char* key, 
                           char* value, 
                           size_t value_size);

/**
 * Get configuration value as integer
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value Pointer to output integer value
 * @return 0 on success, -1 if key not found or not integer
 */
int nlink_config_get_int(const nlink_config_t* config, 
                        const char* key, 
                        int* value);

/**
 * Get configuration value as boolean
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value Pointer to output boolean value
 * @return 0 on success, -1 if key not found or not boolean
 */
int nlink_config_get_bool(const nlink_config_t* config, 
                         const char* key, 
                         bool* value);

/**
 * Set configuration value from string
 * FIXED: Uses size_t for string length validation
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value String value to set
 * @return 0 on success, -1 on error
 */
int nlink_config_set_string(nlink_config_t* config, 
                           const char* key, 
                           const char* value);

/**
 * Set configuration value from integer
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value Integer value to set
 * @return 0 on success, -1 on error
 */
int nlink_config_set_int(nlink_config_t* config, 
                        const char* key, 
                        int value);

/**
 * Set configuration value from boolean
 * 
 * @param config Configuration structure
 * @param key Configuration key name
 * @param value Boolean value to set
 * @return 0 on success, -1 on error
 */
int nlink_config_set_bool(nlink_config_t* config, 
                         const char* key, 
                         bool value);

// =============================================================================
// Configuration Export Functions
// =============================================================================

/**
 * Export configuration as JSON string
 * FIXED: Uses size_t for buffer operations
 * 
 * @param config Configuration structure to export
 * @param json_buffer Output buffer for JSON string
 * @param buffer_size Size of output buffer
 * @return Number of bytes written, or -1 on error
 */
int nlink_config_to_json(const nlink_config_t* config, 
                        char* json_buffer, 
                        size_t buffer_size);

/**
 * Import configuration from JSON string
 * 
 * @param json_string JSON string containing configuration
 * @param config Configuration structure to populate
 * @return 0 on success, -1 on error (with ETPS events logged)
 */
int nlink_config_from_json(const char* json_string, nlink_config_t* config);

/**
 * Export configuration as command-line arguments
 * FIXED: Uses size_t for buffer operations
 * 
 * @param config Configuration structure to export
 * @param args_buffer Output buffer for command-line arguments
 * @param buffer_size Size of output buffer
 * @return Number of bytes written, or -1 on error
 */
int nlink_config_to_args(const nlink_config_t* config, 
                        char* args_buffer, 
                        size_t buffer_size);

// =============================================================================
// Configuration Validation Constants
// =============================================================================

// Maximum allowed values for validation
#define NLINK_CONFIG_MAX_PROJECT_NAME_LEN   127
#define NLINK_CONFIG_MAX_VERSION_LEN        31
#define NLINK_CONFIG_MAX_ENTRY_POINT_LEN    255
#define NLINK_CONFIG_MAX_DESCRIPTION_LEN    511
#define NLINK_CONFIG_MAX_LANGUAGES_LEN      511
#define NLINK_CONFIG_MAX_SEARCH_PATHS_LEN   1023
#define NLINK_CONFIG_MAX_RANGE_LEN          63
#define NLINK_CONFIG_MAX_FRAMEWORK_LEN      63
#define NLINK_CONFIG_MAX_ERROR_LOG_LEN      255

// Validation limits
#define NLINK_CONFIG_MIN_WORKER_COUNT       1
#define NLINK_CONFIG_MAX_WORKER_COUNT       64
#define NLINK_CONFIG_MIN_QUEUE_DEPTH        1
#define NLINK_CONFIG_MAX_QUEUE_DEPTH        1024
#define NLINK_CONFIG_MIN_STACK_SIZE_KB      64
#define NLINK_CONFIG_MAX_STACK_SIZE_KB      8192
#define NLINK_CONFIG_MIN_COVERAGE_THRESHOLD 0
#define NLINK_CONFIG_MAX_COVERAGE_THRESHOLD 100

// Default configuration values
#define NLINK_CONFIG_DEFAULT_WORKER_COUNT   4
#define NLINK_CONFIG_DEFAULT_QUEUE_DEPTH    64
#define NLINK_CONFIG_DEFAULT_STACK_SIZE_KB  512
#define NLINK_CONFIG_DEFAULT_COVERAGE_THRESHOLD 85

#ifdef __cplusplus
}
#endif

#endif // NLINK_QA_POC_CORE_CONFIG_H
