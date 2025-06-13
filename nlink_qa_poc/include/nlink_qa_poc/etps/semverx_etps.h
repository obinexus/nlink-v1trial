/**
 * =============================================================================
 * OBINexus NexusLink - SemVerX ETPS Integration
 * Advanced Component Compatibility Validation with Structured Telemetry
 * =============================================================================
 */

#ifndef NLINK_SEMVERX_ETPS_H
#define NLINK_SEMVERX_ETPS_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

// SemVerX Range State Types
typedef enum {
    SEMVERX_RANGE_LEGACY = 1,
    SEMVERX_RANGE_STABLE = 2,
    SEMVERX_RANGE_EXPERIMENTAL = 3
} semverx_range_state_t;

typedef enum {
    COMPAT_ALLOWED = 1,
    COMPAT_REQUIRES_VALIDATION = 2,
    COMPAT_DENIED = 3
} compatibility_result_t;

typedef enum {
    HOTSWAP_SUCCESS = 1,
    HOTSWAP_FAILED = 2,
    HOTSWAP_NOT_APPLICABLE = 3
} hotswap_result_t;

// SemVerX Component Metadata
typedef struct {
    char name[64];
    char version[32];
    semverx_range_state_t range_state;
    char compatible_range[128];
    bool hot_swap_enabled;
    char migration_policy[64];
    uint64_t component_id;
} semverx_component_t;

// ETPS SemVerX Event Structure
typedef struct {
    char event_id[37];
    char timestamp[32];
    char layer[32];
    semverx_component_t source_component;
    semverx_component_t target_component;
    compatibility_result_t compatibility_result;
    bool hot_swap_attempted;
    hotswap_result_t hot_swap_result;
    char resolution_policy_triggered[64];
    int severity;
    char migration_recommendation[256];
    char project_path[256];
    char build_target[64];
} etps_semverx_event_t;

// Enhanced ETPS Context
typedef struct etps_context {
    uint64_t binding_guid;
    uint64_t created_time;
    uint64_t last_activity;
    char context_name[64];
    bool is_active;
    char project_root[256];
    semverx_component_t* registered_components;
    size_t component_count;
    size_t component_capacity;
    bool strict_mode;
    bool allow_experimental_stable;
    bool auto_migration_enabled;
} etps_context_t;

// Function declarations
int etps_init(void);
void etps_shutdown(void);
bool etps_is_initialized(void);
etps_context_t* etps_context_create(const char* context_name);
void etps_context_destroy(etps_context_t* ctx);

// SemVerX functions
int etps_register_component(etps_context_t* ctx, const semverx_component_t* component);
compatibility_result_t etps_validate_component_compatibility(
    etps_context_t* ctx,
    const semverx_component_t* source_component,
    const semverx_component_t* target_component,
    etps_semverx_event_t* event
);
void etps_emit_semverx_event(etps_context_t* ctx, const etps_semverx_event_t* event);
hotswap_result_t etps_attempt_hotswap(
    etps_context_t* ctx,
    const semverx_component_t* source_component,
    const semverx_component_t* target_component
);

// Utility functions
uint64_t etps_get_current_timestamp(void);
const char* etps_range_state_to_string(semverx_range_state_t state);
const char* etps_compatibility_result_to_string(compatibility_result_t result);
const char* etps_hotswap_result_to_string(hotswap_result_t result);
void etps_generate_iso8601_timestamp(char* buffer, size_t max_len);
void etps_generate_guid_string(char* buffer);

// CLI functions
int nlink_cli_validate_compatibility(int argc, char* argv[]);
int nlink_cli_semverx_status(int argc, char* argv[]);
int nlink_cli_migration_plan(int argc, char* argv[]);
int etps_validate_project_compatibility(const char* project_path);
int etps_export_events_json(etps_context_t* ctx, const char* output_path);

#ifdef __cplusplus
}
#endif

#endif // NLINK_SEMVERX_ETPS_H
