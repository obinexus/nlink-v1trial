/**
 * @file config.c
 * @brief NexusLink Configuration Implementation
 */

#include "nlink_qa_poc/core/config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int nlink_config_init(nlink_config_t* config) {
    if (!config) return -1;
    
    memset(config, 0, sizeof(nlink_config_t));
    
    /* Set defaults */
    strncpy(config->project_name, "nlink_qa_poc", sizeof(config->project_name) - 1);
    strncpy(config->version, "1.0.0", sizeof(config->version) - 1);
    strncpy(config->build_system, "make", sizeof(config->build_system) - 1);
    config->worker_count = 4;
    config->queue_depth = 64;
    config->debug_enabled = false;
    
    return 0;
}

int nlink_config_load(nlink_config_t* config, const char* filename) {
    if (!config || !filename) return -1;
    
    FILE* file = fopen(filename, "r");
    if (!file) {
        printf("Warning: Could not open config file %s, using defaults\n", filename);
        return nlink_config_init(config);
    }
    
    /* Simple line-by-line parsing */
    char line[256];
    while (fgets(line, sizeof(line), file)) {
        /* Skip comments and empty lines */
        if (line[0] == '#' || line[0] == '\n') continue;
        
        /* Parse key-value pairs */
        char* equals = strchr(line, '=');
        if (equals) {
            *equals = '\0';
            char* key = line;
            char* value = equals + 1;
            
            /* Remove trailing newline */
            char* newline = strchr(value, '\n');
            if (newline) *newline = '\0';
            
            /* Parse known keys */
            if (strcmp(key, "project_name") == 0) {
                strncpy(config->project_name, value, sizeof(config->project_name) - 1);
            } else if (strcmp(key, "version") == 0) {
                strncpy(config->version, value, sizeof(config->version) - 1);
            } else if (strcmp(key, "worker_count") == 0) {
                config->worker_count = (uint32_t)atoi(value);
            }
        }
    }
    
    fclose(file);
    return 0;
}

int nlink_config_validate(const nlink_config_t* config) {
    if (!config) return -1;
    
    if (strlen(config->project_name) == 0) return -1;
    if (strlen(config->version) == 0) return -1;
    if (config->worker_count == 0 || config->worker_count > 256) return -1;
    
    return 0;
}

void nlink_config_cleanup(nlink_config_t* config) {
    if (config) {
        memset(config, 0, sizeof(nlink_config_t));
    }
}

int nlink_parse_project_name(const char* input, char* output, size_t max_len) {
    if (!input || !output || max_len == 0) return -1;
    
    strncpy(output, input, max_len - 1);
    output[max_len - 1] = '\0';
    return 0;
}

int nlink_parse_version(const char* input, char* output, size_t max_len) {
    if (!input || !output || max_len == 0) return -1;
    
    strncpy(output, input, max_len - 1);
    output[max_len - 1] = '\0';
    return 0;
}

int nlink_parse_worker_count(const char* input, uint32_t* output) {
    if (!input || !output) return -1;
    
    int value = atoi(input);
    if (value <= 0 || value > 256) return -1;
    
    *output = (uint32_t)value;
    return 0;
}
