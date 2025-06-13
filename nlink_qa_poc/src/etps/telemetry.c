/**
 * NexusLink ETPS Implementation
 * Basic implementation of GUID + Timestamp telemetry system
 */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#include "nlink_qa_poc/etps/telemetry.h"

static bool etps_initialized = false;
static FILE* etps_log_file = NULL;

int etps_init(void) {
    if (etps_initialized) return 0;
    
    etps_log_file = fopen("nlink_etps.log", "a");
    if (!etps_log_file) {
        etps_log_file = stderr;
    }
    
    etps_initialized = true;
    fprintf(etps_log_file, "{\"event\":\"etps_init\",\"timestamp\":%lu}\n", 
            (unsigned long)time(NULL));
    fflush(etps_log_file);
    
    return 0;
}

void etps_shutdown(void) {
    if (!etps_initialized) return;
    
    if (etps_log_file && etps_log_file != stderr) {
        fclose(etps_log_file);
    }
    etps_initialized = false;
}

etps_guid_t etps_generate_guid(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return ((uint64_t)ts.tv_sec << 32) | (uint32_t)ts.tv_nsec;
}

etps_timestamp_t etps_get_timestamp(void) {
    struct timespec ts;
    clock_gettime(CLOCK_REALTIME, &ts);
    return ((uint64_t)ts.tv_sec * 1000000000UL) + (uint64_t)ts.tv_nsec;
}

etps_context_t* etps_context_create(const char* command_path) {
    if (!etps_initialized) etps_init();
    
    etps_context_t* ctx = malloc(sizeof(etps_context_t));
    if (!ctx) return NULL;
    
    ctx->session_guid = etps_generate_guid();
    ctx->session_start = etps_get_timestamp();
    ctx->event_count = 0;
    ctx->panic_mode = false;
    ctx->max_severity = ETPS_SEVERITY_DEBUG;
    
    if (command_path) {
        strncpy(ctx->command_path, command_path, sizeof(ctx->command_path) - 1);
        ctx->command_path[sizeof(ctx->command_path) - 1] = '\0';
    } else {
        strcpy(ctx->command_path, "unknown");
    }
    
    return ctx;
}

void etps_context_destroy(etps_context_t* ctx) {
    if (!ctx) return;
    free(ctx);
}

void etps_log_error(etps_context_t* ctx, etps_component_t component,
                   int error_code, const char* operation, const char* message,
                   const char* file, uint32_t line) {
    if (!ctx || !etps_log_file) return;
    
    fprintf(etps_log_file,
            "{\"etps_event\":\"error\",\"guid\":%lu,\"timestamp\":%lu,"
            "\"component\":%d,\"error_code\":%d,\"operation\":\"%s\","
            "\"message\":\"%s\",\"file\":\"%s\",\"line\":%u}\n",
            ctx->session_guid, etps_get_timestamp(), component, error_code,
            operation ? operation : "unknown",
            message ? message : "unknown error",
            file ? file : "unknown", line);
    fflush(etps_log_file);
    
    ctx->event_count++;
    if (ETPS_SEVERITY_ERROR > ctx->max_severity) {
        ctx->max_severity = ETPS_SEVERITY_ERROR;
    }
}

void etps_log_panic(etps_context_t* ctx, etps_component_t component,
                   int error_code, const char* operation, const char* message,
                   const char* file, uint32_t line) {
    if (!ctx) return;
    
    ctx->panic_mode = true;
    ctx->max_severity = ETPS_SEVERITY_PANIC;
    
    fprintf(stderr, "ETPS PANIC [GUID:%lu]: %s in %s:%u\n",
            ctx->session_guid, message ? message : "Unknown panic", 
            file ? file : "unknown", line);
    
    if (etps_log_file) {
        fprintf(etps_log_file,
                "{\"etps_event\":\"panic\",\"guid\":%lu,\"timestamp\":%lu,"
                "\"component\":%d,\"error_code\":%d,\"operation\":\"%s\","
                "\"message\":\"%s\",\"file\":\"%s\",\"line\":%u}\n",
                ctx->session_guid, etps_get_timestamp(), component, error_code,
                operation ? operation : "unknown",
                message ? message : "unknown panic",
                file ? file : "unknown", line);
        fflush(etps_log_file);
    }
}

bool etps_validate_config(etps_context_t* ctx, const void* config_data, size_t config_size) {
    if (!ctx || !config_data || config_size == 0) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_VALIDATION, 1001, 
                      "config_validation", "Invalid configuration parameters");
        return false;
    }
    return true;
}

bool etps_validate_input(etps_context_t* ctx, const char* param_name,
                        const void* value, const char* expected_type) {
    if (!ctx || !value) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_VALIDATION, 1002,
                      "input_validation", "Invalid input parameters");
        return false;
    }
    return true;
}
