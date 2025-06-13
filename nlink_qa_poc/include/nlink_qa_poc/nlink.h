/**
 * @file nlink.h
 * @brief NexusLink Core Library - Main Public Header
 * @version 1.0.0
 * 
 * OBINexus Engineering - Aegis Project
 * Mathematical Framework for Zero-Overhead Data Marshalling
 */

#ifndef NLINK_H
#define NLINK_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stddef.h>

/* Library version information */
#define NLINK_VERSION_MAJOR 1
#define NLINK_VERSION_MINOR 0
#define NLINK_VERSION_PATCH 0
#define NLINK_VERSION "1.0.0"

/* Core library includes */
#include "core/config.h"
#include "core/marshal.h"
#include "cli/parser.h"

/* Main library initialization */
int nlink_init(void);
void nlink_cleanup(void);
const char* nlink_version(void);

#ifdef __cplusplus
}
#endif

#endif /* NLINK_H */
