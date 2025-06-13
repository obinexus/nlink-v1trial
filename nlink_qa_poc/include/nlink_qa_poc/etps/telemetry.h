/**
 * =============================================================================
 * NexusLink Cross-Language Binding Validation System
 * OBINexus Aegis Engineering - Binding Compliance & ETPS Integration
 * =============================================================================
 * 
 * Implements validation for all language bindings (Python, Java, Cython)
 * with comprehensive error telemetry and panic handling.
 * 
 * Author: Nnamdi Michael Okpala (OBINexus Computing)
 * Framework: Program-First Architecture with Zero-Trust Validation
 */

#ifndef NLINK_BINDING_VALIDATION_H
#define NLINK_BINDING_VALIDATION_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "nlink_qa_poc/etps/telemetry.h"

#ifdef __cplusplus
extern "C" {
#endif

// =============================================================================
// Binding Type Definitions
// =============================================================================

// Language binding types
typedef enum {
    NLINK_BINDING_UNKNOWN   = 0,
    NLINK_BINDING_PYTHON    = 1,    // Pure Python binding
    NLINK_BINDING_CYTHON    = 2,    // Cython zero-overhead binding
    NLINK_BINDING_JAVA      = 3,    // Java protocol adapter
    NLINK_BINDING_C         = 4,    // Native C binding
    NLINK_BINDING_GOLANG    = 5,    // Go language binding (future)
    NLINK_BINDING_RUST      = 6     // Rust binding (future)
} nlink_binding_type_t;

// Binding validation status
typedef enum {
    NLINK_BINDING_STATUS_UNKNOWN        = 0,
    NLINK_BINDING_STATUS_INITIALIZING   = 1,
    NLINK_BINDING_STATUS_ACTIVE         = 2,
    NLINK_BINDING_STATUS_ERROR          = 3,
    NLINK_BINDING_STATUS_PANIC          = 4,
    NLINK_BINDING_STATUS_SHUTDOWN       = 5
} nlink_binding_status_t;

// Binding capability flags
typedef enum {
    NLINK_BINDING_CAP_MARSHAL           = 0x0001,   // Data marshalling
    NLINK_BINDING_CAP_TELEMETRY         = 0x0002,   // ETPS telemetry
    NLINK_BINDING_CAP_VALIDATION        = 0x0004,   // Input validation
    NLINK_BINDING_CAP_CRYPTO            = 0x0008,   // Cryptographic functions
    NLINK_BINDING_CAP_THREADING         = 0x0010,   // Thread safety
    NLINK_BINDING_CAP_ZERO_OVERHEAD     = 0x0020,   // Zero-overhead operations
    NLINK_BINDING_CAP_FFI               = 0x0040,   // Foreign Function Interface
    NLINK_BINDING_CAP_PROTOCOL_ADAPTER  = 0x0080    // Protocol adapter pattern
} nlink_binding_capabilities_t;

// Binding information structure
typedef struct {
    nlink_binding_type_t    type;
    char                    name[64];           // Human-readable name
    char                    version[32];        // Binding version
    char                    runtime_version[32]; // Runtime version (Python, Java, etc.)
    uint32_t                capabilities;       // Capability flags
    nlink_binding_status_t  status;
    etps_guid_t             binding_guid;       // Unique binding identifier
    etps_timestamp_t        created_time;
    etps_timestamp_t        last_activity;
    uint64_t                operation_count;    // Total operations performed
    uint64_t                error_count;        // Total errors encountered
    uint64_t                panic_count;        // Total panics encountered
    char                    last_error[256];    // Last error message
} nlink_binding_info_t;

// Binding registry entry
typedef struct {
    nlink_binding_info_t    info;
    bool                    active;
    etps_context_t*         etps_context;
    void*                   binding_data;       // Binding-specific data
    
    // Function pointers for binding operations
    int (*validate_fn)(void* binding_data, const void* input, size_t input_size);
    int (*marshal_fn)(void* binding_data, const void* input, size_t input_size, 
                     void* output, size_t* output_size);
    int (*unmarshal_fn)(void* binding_data, const void* input, size_t input_size,
                       void* output, size_t* output_size);
    void (*cleanup_fn)(void* binding_data);
} nlink_binding_registry_entry_t;

// Validation context for binding operations
typedef struct {
    etps_context_t*         etps_context;
    nlink_binding_type_t    binding_type;
    const char*             operation_name;
    etps_timestamp_t        start_time;
    bool                    panic_on_error;     // Whether to panic on validation failure
    uint32_t                timeout_ms;        // Operation timeout
} nlink_binding_validation_context_t;

// =============================================================================
// Binding Registry Functions
// =============================================================================

/**
 * Initialize the binding validation system
 * Must be called before any other binding functions
 */
int nlink_binding_system_init(void);

/**
 * Shutdown the binding validation system
 * Cleans up all registered bindings and logs final telemetry
 */
void nlink_binding_system_shutdown(void);

/**
 * Register a new language binding
 * @param binding_info Binding information structure
 * @param binding_data Binding-specific data pointer
 * @param callbacks Function pointers for binding operations
 * @return Binding ID (> 0) on success, -1 on error with ETPS logging
 */
int nlink_binding_register(const nlink_binding_info_t* binding_info,
                          void* binding_data);

/**
 * Unregister a language binding
 * @param binding_id Binding ID returned by nlink_binding_register
 * @return 0 on success, -1 on error with ETPS logging
 */
int nlink_binding_unregister(int binding_id);

/**
 * Get binding information by ID
 * @param binding_id Binding ID
 * @param binding_info Output buffer for binding information
 * @return 0 on success, -1 if binding not found
 */
int nlink_binding_get_info(int binding_id, nlink_binding_info_t* binding_info);

/**
 * Update binding status
 * @param binding_id Binding ID
 * @param status New status
 * @param error_message Optional error message (can be NULL)
 * @return 0 on success, -1 on error
 */
int nlink_binding_update_status(int binding_id, nlink_binding_status_t status,
                               const char* error_message);

// =============================================================================
// Binding Validation Functions - Core ETPS Integration
// =============================================================================

/**
 * Create validation context for binding operations
 * @param binding_type Type of binding being validated
 * @param operation_name Name of operation being performed
 * @param panic_on_error Whether to trigger panic on validation failure
 * @return Validation context or NULL on error
 */
nlink_binding_validation_context_t* nlink_binding_create_validation_context(
    nlink_binding_type_t binding_type,
    const char* operation_name,
    bool panic_on_error);

/**
 * Destroy validation context
 * @param ctx Validation context to destroy
 */
void nlink_binding_destroy_validation_context(nlink_binding_validation_context_t* ctx);

/**
 * Validate binding input data
 * Comprehensive validation with ETPS error reporting
 * @param ctx Validation context
 * @param binding_id Binding ID
 * @param input Input data to validate
 * @param input_size Size of input data
 * @return 0 if valid, -1 if invalid (with ETPS event logged)
 */
int nlink_binding_validate_input(nlink_binding_validation_context_t* ctx,
                                int binding_id,
                                const void* input,
                                size_t input_size);

/**
 * Validate binding output data
 * @param ctx Validation context
 * @param binding_id Binding ID
 * @param input Original input data
 * @param input_size Size of input data
 * @param output Output data to validate
 * @param output_size Size of output data
 * @return 0 if valid, -1 if invalid (with ETPS event logged)
 */
int nlink_binding_validate_output(nlink_binding_validation_context_t* ctx,
                                 int binding_id,
                                 const void* input,
                                 size_t input_size,
                                 const void* output,
                                 size_t output_size);

/**
 * Validate binding capabilities
 * Ensures binding supports required operations
 * @param binding_id Binding ID
 * @param required_capabilities Required capability flags
 * @return 0 if all capabilities supported, -1 otherwise
 */
int nlink_binding_validate_capabilities(int binding_id,
                                       uint32_t required_capabilities);

/**
 * Validate cross-language compatibility
 * Tests marshalling/unmarshalling between different bindings
 * @param source_binding_id Source binding ID
 * @param target_binding_id Target binding ID
 * @param test_data Test data for compatibility check
 * @param test_data_size Size of test data
 * @return 0 if compatible, -1 if incompatible (with ETPS events logged)
 */
int nlink_binding_validate_cross_language_compatibility(int source_binding_id,
                                                       int target_binding_id,
                                                       const void* test_data,
                                                       size_t test_data_size);

// =============================================================================
// Binding Error Handling - Panic & Recovery
// =============================================================================

/**
 * Report binding error with ETPS integration
 * @param binding_id Binding ID where error occurred
 * @param error_code Error code
 * @param operation Operation that failed
 * @param error_message Human-readable error message
 * @param file Source file where error occurred
 * @param line Line number where error occurred
 */
void nlink_binding_report_error(int binding_id,
                               int error_code,
                               const char* operation,
                               const char* error_message,
                               const char* file,
                               uint32_t line);

/**
 * Report binding panic condition
 * Triggers immediate ETPS panic logging and system notification
 * @param binding_id Binding ID where panic occurred
 * @param panic_code Panic code
 * @param operation Operation that caused panic
 * @param panic_message Human-readable panic message
 * @param file Source file where panic occurred
 * @param line Line number where panic occurred
 */
void nlink_binding_report_panic(int binding_id,
                               int panic_code,
                               const char* operation,
                               const char* panic_message,
                               const char* file,
                               uint32_t line);

/**
 * Attempt binding recovery after error
 * @param binding_id Binding ID to recover
 * @param recovery_strategy Recovery strategy to attempt
 * @return 0 if recovery successful, -1 if recovery failed
 */
int nlink_binding_attempt_recovery(int binding_id, const char* recovery_strategy);

// =============================================================================
// Binding Performance Monitoring
// =============================================================================

/**
 * Start performance monitoring for binding operation
 * @param binding_id Binding ID
 * @param operation_name Operation being monitored
 * @return Monitoring handle or NULL on error
 */
void* nlink_binding_start_performance_monitoring(int binding_id,
                                                const char* operation_name);

/**
 * Stop performance monitoring and log results
 * @param monitor_handle Handle returned by start_performance_monitoring
 * @param success Whether operation completed successfully
 */
void nlink_binding_stop_performance_monitoring(void* monitor_handle, bool success);

// =============================================================================
// Binding JSON Export for Telemetry
// =============================================================================

/**
 * Export binding information as JSON
 * @param binding_id Binding ID
 * @param json_buffer Output buffer for JSON string
 * @param buffer_size Size of output buffer
 * @return Number of bytes written, or -1 on error
 */
int nlink_binding_to_json(int binding_id, char* json_buffer, size_t buffer_size);

/**
 * Export all bindings registry as JSON
 * @param json_buffer Output buffer for JSON string
 * @param buffer_size Size of output buffer
 * @return Number of bytes written, or -1 on error
 */
int nlink_binding_registry_to_json(char* json_buffer, size_t buffer_size);

/**
 * Export binding validation report as JSON
 * @param ctx Validation context
 * @param json_buffer Output buffer for JSON string
 * @param buffer_size Size of output buffer
 * @return Number of bytes written, or -1 on error
 */
int nlink_binding_validation_report_to_json(nlink_binding_validation_context_t* ctx,
                                           char* json_buffer,
                                           size_t buffer_size);

// =============================================================================
// Convenience Macros for Binding Error Reporting
// =============================================================================

#define NLINK_BINDING_ERROR(binding_id, code, op, msg) \
    nlink_binding_report_error(binding_id, code, op, msg, __FILE__, __LINE__)

#define NLINK_BINDING_PANIC(binding_id, code, op, msg) \
    nlink_binding_report_panic(binding_id, code, op, msg, __FILE__, __LINE__)

#define NLINK_BINDING_VALIDATE_OR_ERROR(condition, binding_id, code, op, msg) \
    do { \
        if (!(condition)) { \
            NLINK_BINDING_ERROR(binding_id, code, op, msg); \
            return -1; \
        } \
    } while(0)

#define NLINK_BINDING_VALIDATE_OR_PANIC(condition, binding_id, code, op, msg) \
    do { \
        if (!(condition)) { \
            NLINK_BINDING_PANIC(binding_id, code, op, msg); \
            return -1; \
        } \
    } while(0)

// =============================================================================
// Binding-Specific Validation Functions
// =============================================================================

/**
 * Validate Python binding
 * @param binding_id Python binding ID
 * @param python_version Python version string (e.g., "3.8.10")
 * @return 0 if valid, -1 if invalid
 */
int nlink_binding_validate_python(int binding_id, const char* python_version);

/**
 * Validate Cython binding
 * @param binding_id Cython binding ID
 * @param cython_version Cython version string
 * @param numpy_available Whether NumPy is available
 * @return 0 if valid, -1 if invalid
 */
int nlink_binding_validate_cython(int binding_id, const char* cython_version,
                                 bool numpy_available);

/**
 * Validate Java binding
 * @param binding_id Java binding ID
 * @param java_version Java version string (e.g., "17.0.1")
 * @param maven_available Whether Maven is available
 * @return 0 if valid, -1 if invalid
 */
int nlink_binding_validate_java(int binding_id, const char* java_version,
                               bool maven_available);

// =============================================================================
// System Integration Functions
// =============================================================================

/**
 * Run comprehensive binding validation suite
 * Tests all registered bindings with cross-language compatibility
 * @param json_report_buffer Buffer for JSON validation report
 * @param buffer_size Size of report buffer
 * @return 0 if all validations pass, -1 if any validation fails
 */
int nlink_binding_run_validation_suite(char* json_report_buffer,
                                      size_t buffer_size);

/**
 * Monitor all bindings for health and performance
 * Continuous monitoring with ETPS telemetry integration
 * @param monitoring_duration_seconds Duration to monitor (0 for continuous)
 * @return 0 on successful monitoring completion
 */
int nlink_binding_start_health_monitoring(uint32_t monitoring_duration_seconds);

/**
 * Stop health monitoring and generate final report
 */
void nlink_binding_stop_health_monitoring(void);

#ifdef __cplusplus
}
#endif

#endif // NLINK_BINDING_VALIDATION_H
