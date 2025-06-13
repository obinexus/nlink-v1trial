/**
 * NexusLink ETPS (Error Telemetry Point System) - Core Header
 * GUID + Timestamp Integration for Structured Error Reporting
 */

#ifndef NLINK_ETPS_TELEMETRY_H
#define NLINK_ETPS_TELEMETRY_H

#include <stddef.h>
#include <stdint.h>
#include <time.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ETPS Core Types
typedef uint64_t etps_guid_t;
typedef uint64_t etps_timestamp_t;

// ETPS Context Structure
typedef struct etps_context {
    etps_guid_t binding_guid;
    etps_timestamp_t created_time;
    etps_timestamp_t last_activity;
    char context_name[64];
    bool is_active;
} etps_context_t;

// ETPS Component Types
typedef enum {
    ETPS_COMPONENT_CONFIG = 1,
    ETPS_COMPONENT_CLI = 2,
    ETPS_COMPONENT_CORE = 3,
    ETPS_COMPONENT_PARSER = 4
} etps_component_t;

// ETPS Error Codes
typedef enum {
    ETPS_ERROR_NONE = 0,
    ETPS_ERROR_INVALID_INPUT = 1001,
    ETPS_ERROR_MEMORY_FAULT = 1002,
    ETPS_ERROR_CONFIG_PARSE = 1003,
    ETPS_ERROR_FILE_IO = 1004
} etps_error_code_t;

// Function declarations
etps_context_t* etps_context_create(const char* context_name);
void etps_context_destroy(etps_context_t* ctx);
bool etps_validate_input(etps_context_t* ctx, const char* param_name, const void* value, const char* type);
bool etps_validate_config(etps_context_t* ctx, const char* buffer, size_t size);

// Logging macros
#define ETPS_LOG_ERROR(ctx, component, error_code, function, message) \
    etps_log_error(ctx, component, error_code, function, message)

#define ETPS_LOG_INFO(ctx, component, function, message) \
    etps_log_info(ctx, component, function, message)

// Logging functions
void etps_log_error(etps_context_t* ctx, etps_component_t component, 
                   etps_error_code_t error_code, const char* function, const char* message);
void etps_log_info(etps_context_t* ctx, etps_component_t component, 
                  const char* function, const char* message);

#ifdef __cplusplus
}
#endif

#endif // NLINK_ETPS_TELEMETRY_H
