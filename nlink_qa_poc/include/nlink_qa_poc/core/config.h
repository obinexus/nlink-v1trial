/**
 * @file config.h
 * @brief NexusLink Configuration Management
 * @version 1.0.0
 */

#ifndef NLINK_CORE_CONFIG_H
#define NLINK_CORE_CONFIG_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/* Configuration structure */
typedef struct nlink_config {
    char project_name[128];
    char version[32];
    char build_system[32];
    uint32_t worker_count;
    uint32_t queue_depth;
    bool debug_enabled;
} nlink_config_t;

/* Configuration API */
int nlink_config_init(nlink_config_t* config);
int nlink_config_load(nlink_config_t* config, const char* filename);
int nlink_config_validate(const nlink_config_t* config);
void nlink_config_cleanup(nlink_config_t* config);

/* Configuration parsing functions */
int nlink_parse_project_name(const char* input, char* output, size_t max_len);
int nlink_parse_version(const char* input, char* output, size_t max_len);
int nlink_parse_worker_count(const char* input, uint32_t* output);

#ifdef __cplusplus
}
#endif

#endif /* NLINK_CORE_CONFIG_H */
