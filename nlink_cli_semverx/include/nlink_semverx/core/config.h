/**
 * @file config.h
 * @brief Configuration system for NexusLink SemVerX
 */

#ifndef NLINK_SEMVERX_CORE_CONFIG_H
#define NLINK_SEMVERX_CORE_CONFIG_H

#include "nlink_semverx/core/types.h"
#include "nlink_semverx/core/error_codes.h"

// Forward declarations
typedef struct nlink_pkg_config nlink_pkg_config_t;

// Core functions
nlink_config_result_t nlink_config_init(void);
nlink_config_result_t nlink_parse_pkg_config(const char *path, nlink_pkg_config_t *config);
void nlink_config_destroy(void);

#endif /* NLINK_SEMVERX_CORE_CONFIG_H */
