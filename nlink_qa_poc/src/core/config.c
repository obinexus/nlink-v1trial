/**
 * =============================================================================
 * NexusLink QA POC - Core Configuration Module
 * OBINexus Engineering - Configuration Parsing with ETPS Integration
 * =============================================================================
 * 
 * CRITICAL FIX: Includes stddef.h to resolve size_t compilation errors
 * Implements configuration parsing with structured error telemetry
 */

// CRITICAL FIX: Include stddef.h FIRST to resolve size_t compilation errors
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "nlink_qa_poc/core/config.h"
#include "nlink_qa_poc/etps/telemetry.h"

// =============================================================================
// Configuration Parser State
// =============================================================================

// Configuration parsing context
typedef struct {
    etps_context_t* etps_ctx;
    char* buffer;
    size_t buffer_size;
    size_t position;
    int line_number;
    char current_section[64];
} config_parser_t;

// Internal function declarations
static int skip_whitespace(config_parser_t* parser);
static int parse_section_header(config_parser_t* parser, char* section_name, size_t name_size);
static int parse_key_value(config_parser_t* parser, char* key, char* value, size_t key_size, size_t value_size);
static int validate_project_name(etps_context_t* ctx, const char* name);
static int validate_version_string(etps_context_t* ctx, const char* version);

// =============================================================================
// FIXED: Configuration Parsing Functions with size_t Support
// =============================================================================

int nlink_parse_project_name(const char* input, char* output, size_t max_len) {
    // Initialize ETPS context for validation
    etps_context_t* ctx = etps_context_create("config/project_name");
    if (!ctx) {
        return -1;
    }
    
    // Validate input parameters
    if (!etps_validate_input(ctx, "input", input, "string") ||
        !etps_validate_input(ctx, "output", output, "buffer") ||
        max_len == 0) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_INVALID_INPUT,
                      "nlink_parse_project_name", "Invalid input parameters");
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Validate project name format
    if (!validate_project_name(ctx, input)) {
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Copy project name safely
    size_t input_len = strlen(input);
    if (input_len >= max_len) {
        char error_msg[128];
        snprintf(error_msg, sizeof(error_msg), 
                 "Project name too long: %zu chars (max: %zu)", input_len, max_len - 1);
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_INVALID_INPUT,
                      "nlink_parse_project_name", error_msg);
        etps_context_destroy(ctx);
        return -1;
    }
    
    strncpy(output, input, max_len - 1);
    output[max_len - 1] = '\0';
    
    ETPS_LOG_INFO(ctx, ETPS_COMPONENT_CONFIG, "parse_project_name", 
                  "Project name parsed successfully");
    etps_context_destroy(ctx);
    return 0;
}

int nlink_parse_version(const char* input, char* output, size_t max_len) {
    // Initialize ETPS context for validation
    etps_context_t* ctx = etps_context_create("config/version");
    if (!ctx) {
        return -1;
    }
    
    // Validate input parameters
    if (!etps_validate_input(ctx, "input", input, "string") ||
        !etps_validate_input(ctx, "output", output, "buffer") ||
        max_len == 0) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_INVALID_INPUT,
                      "nlink_parse_version", "Invalid input parameters");
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Validate version string format
    if (!validate_version_string(ctx, input)) {
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Copy version string safely
    size_t input_len = strlen(input);
    if (input_len >= max_len) {
        char error_msg[128];
        snprintf(error_msg, sizeof(error_msg), 
                 "Version string too long: %zu chars (max: %zu)", input_len, max_len - 1);
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_INVALID_INPUT,
                      "nlink_parse_version", error_msg);
        etps_context_destroy(ctx);
        return -1;
    }
    
    strncpy(output, input, max_len - 1);
    output[max_len - 1] = '\0';
    
    ETPS_LOG_INFO(ctx, ETPS_COMPONENT_CONFIG, "parse_version", 
                  "Version string parsed successfully");
    etps_context_destroy(ctx);
    return 0;
}

int nlink_load_config(const char* filename, nlink_config_t* config) {
    // Initialize ETPS context for configuration loading
    etps_context_t* ctx = etps_context_create("config/load");
    if (!ctx) {
        return -1;
    }
    
    // Validate input parameters
    if (!etps_validate_input(ctx, "filename", filename, "string") ||
        !etps_validate_input(ctx, "config", config, "nlink_config_t")) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_INVALID_INPUT,
                      "nlink_load_config", "Invalid input parameters");
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Open configuration file
    FILE* file = fopen(filename, "r");
    if (!file) {
        char error_msg[256];
        snprintf(error_msg, sizeof(error_msg), 
                 "Failed to open config file: %s (errno: %d)", filename, errno);
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                      "nlink_load_config", error_msg);
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Get file size
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    if (file_size <= 0 || file_size > 1024 * 1024) { // 1MB limit
        char error_msg[128];
        snprintf(error_msg, sizeof(error_msg), 
                 "Invalid config file size: %ld bytes", file_size);
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                      "nlink_load_config", error_msg);
        fclose(file);
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Allocate buffer for file contents
    char* buffer = malloc((size_t)file_size + 1);
    if (!buffer) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_MEMORY_FAULT,
                      "nlink_load_config", "Failed to allocate file buffer");
        fclose(file);
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Read file contents
    size_t bytes_read = fread(buffer, 1, (size_t)file_size, file);
    fclose(file);
    
    if (bytes_read != (size_t)file_size) {
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                      "nlink_load_config", "Failed to read complete file");
        free(buffer);
        etps_context_destroy(ctx);
        return -1;
    }
    
    buffer[bytes_read] = '\0';
    
    // Validate configuration data
    if (!etps_validate_config(ctx, buffer, bytes_read)) {
        free(buffer);
        etps_context_destroy(ctx);
        return -1;
    }
    
    // Initialize parser
    config_parser_t parser = {
        .etps_ctx = ctx,
        .buffer = buffer,
        .buffer_size = bytes_read,
        .position = 0,
        .line_number = 1,
        .current_section = {0}
    };
    
    // Initialize config structure
    memset(config, 0, sizeof(nlink_config_t));
    
    // Parse configuration file
    char key[128], value[256];
    int parse_result = 0;
    
    while (parser.position < parser.buffer_size) {
        skip_whitespace(&parser);
        
        if (parser.position >= parser.buffer_size) {
            break;
        }
        
        // Check for section header
        if (parser.buffer[parser.position] == '[') {
            if (parse_section_header(&parser, parser.current_section, 
                                   sizeof(parser.current_section)) != 0) {
                parse_result = -1;
                break;
            }
            continue;
        }
        
        // Parse key-value pair
        if (parse_key_value(&parser, key, value, sizeof(key), sizeof(value)) != 0) {
            parse_result = -1;
            break;
        }
        
        // Store configuration values based on current section
        if (strcmp(parser.current_section, "project") == 0) {
            if (strcmp(key, "name") == 0) {
                strncpy(config->project_name, value, sizeof(config->project_name) - 1);
            } else if (strcmp(key, "version") == 0) {
                strncpy(config->version, value, sizeof(config->version) - 1);
            } else if (strcmp(key, "entry_point") == 0) {
                strncpy(config->entry_point, value, sizeof(config->entry_point) - 1);
            }
        } else if (strcmp(parser.current_section, "build") == 0) {
            if (strcmp(key, "strict_mode") == 0) {
                config->strict_mode = (strcmp(value, "true") == 0);
            } else if (strcmp(key, "experimental_mode") == 0) {
                config->experimental_mode = (strcmp(value, "true") == 0);
            }
        }
    }
    
    free(buffer);
    
    if (parse_result == 0) {
        ETPS_LOG_INFO(ctx, ETPS_COMPONENT_CONFIG, "load_config", 
                      "Configuration loaded successfully");
    }
    
    etps_context_destroy(ctx);
    return parse_result;
}

// =============================================================================
// Internal Helper Functions
// =============================================================================

static int skip_whitespace(config_parser_t* parser) {
    while (parser->position < parser->buffer_size) {
        char c = parser->buffer[parser->position];
        if (c == '\n') {
            parser->line_number++;
            parser->position++;
        } else if (isspace(c)) {
            parser->position++;
        } else if (c == '#') {
            // Skip comment line
            while (parser->position < parser->buffer_size && 
                   parser->buffer[parser->position] != '\n') {
                parser->position++;
            }
        } else {
            break;
        }
    }
    return 0;
}

static int parse_section_header(config_parser_t* parser, char* section_name, size_t name_size) {
    if (parser->buffer[parser->position] != '[') {
        ETPS_LOG_ERROR(parser->etps_ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                      "parse_section_header", "Expected '[' for section header");
        return -1;
    }
    
    parser->position++; // Skip '['
    size_t name_pos = 0;
    
    while (parser->position < parser->buffer_size && name_pos < name_size - 1) {
        char c = parser->buffer[parser->position];
        if (c == ']') {
            break;
        } else if (c == '\n') {
            ETPS_LOG_ERROR(parser->etps_ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                          "parse_section_header", "Unterminated section header");
            return -1;
        }
        
        section_name[name_pos++] = c;
        parser->position++;
    }
    
    if (parser->position >= parser->buffer_size || parser->buffer[parser->position] != ']') {
        ETPS_LOG_ERROR(parser->etps_ctx, ETPS_COMPONENT_CONFIG, ETPS_ERROR_CONFIG_PARSE,
                      "parse_section_header", "Expected ']' to close section header");
        return -1;
    }
    
    section_name[name_pos] = '\0';
    parser->position++; // Skip ']'
    
    return 0;
}

static int parse_key_value(config_parser_t* parser, char* key, char* value, 
                          size_t key_size, size_t value_size) {
    // Parse key
    size_t key_pos = 0;
    while (parser->position < parser->buffer_size && key_pos < key_size - 1) {
        char c = parser->buffer[parser->position];
        if (c == '=' || isspace(c)) {
            break;
        } else if (c == '\n') {
            // Empty line
            return 0;
        }
        
        key[key_pos++] = c;
        parser->position++;
    }
    
    if (key_pos == 0) {
        return 0; // Empty line
    }
    
    key[key_pos] = '\0';
    
    // Skip whitespace and '='
    skip_whitespace(parser);
    if (parser->position < parser->buffer_size && parser->buffer[parser->position] == '=') {
        parser->position++;
        skip_whitespace(parser);
    }
    
    // Parse value
    size_t value_pos = 0;
    bool in_quotes = false;
    
    while (parser->position < parser->buffer_size && value_pos < value_size - 1) {
        char c = parser->buffer[parser->position];
        
        if (c == '"' && (value_pos == 0 || parser->buffer[parser->position - 1] != '\\')) {
            in_quotes = !in_quotes;
            parser->position++;
            continue;
        }
        
        if (!in_quotes && (c == '\n' || c == '#')) {
            break;
        }
        
        value[value_pos++] = c;
        parser->position++;
    }
    
    value[value_pos] = '\0';
    
    // Trim trailing whitespace from value
    while (value_pos > 0 && isspace(value[value_pos - 1])) {
        value[--value_pos] = '\0';
    }
    
    return 0;
}

static int validate_project_name(etps_context_t* ctx, const char* name) {
    if (!name || strlen(name) == 0) {
        ETPS_LOG_VALIDATION_FAILURE(ctx, "project_name_empty", "non-empty", "empty");
        return 0;
    }
    
    size_t len = strlen(name);
    if (len > 64) {
        ETPS_LOG_VALIDATION_FAILURE(ctx, "project_name_length", "≤ 64 chars", "too long");
        return 0;
    }
    
    // Check for valid characters (alphanumeric, underscore, hyphen)
    for (size_t i = 0; i < len; i++) {
        char c = name[i];
        if (!isalnum(c) && c != '_' && c != '-') {
            ETPS_LOG_VALIDATION_FAILURE(ctx, "project_name_chars", "alphanumeric_-", "invalid chars");
            return 0;
        }
    }
    
    return 1;
}

static int validate_version_string(etps_context_t* ctx, const char* version) {
    if (!version || strlen(version) == 0) {
        ETPS_LOG_VALIDATION_FAILURE(ctx, "version_empty", "non-empty", "empty");
        return 0;
    }
    
    // Simple version format validation (major.minor.patch)
    int dots = 0;
    size_t len = strlen(version);
    
    for (size_t i = 0; i < len; i++) {
        char c = version[i];
        if (c == '.') {
            dots++;
        } else if (!isdigit(c)) {
            ETPS_LOG_VALIDATION_FAILURE(ctx, "version_format", "digits and dots", "invalid chars");
            return 0;
        }
    }
    
    if (dots < 1 || dots > 2) {
        ETPS_LOG_VALIDATION_FAILURE(ctx, "version_dots", "1-2 dots", "invalid dot count");
        return 0;
    }
    
    return 1;
}
