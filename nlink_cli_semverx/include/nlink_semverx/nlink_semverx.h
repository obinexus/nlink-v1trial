/**
 * @file nlink_semverx.h
 * @brief NexusLink SemVerX Master Header
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * @version 1.5.0
 */

#ifndef NLINK_SEMVERX_H
#define NLINK_SEMVERX_H

// Standard includes
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <pthread.h>
#include <time.h>

// Core functionality
#include "nlink_semverx/core/types.h"
#include "nlink_semverx/core/config.h"
#include "nlink_semverx/core/error_codes.h"

// CLI interface
#include "nlink_semverx/cli/parser_interface.h"

// SemVerX extensions
#include "nlink_semverx/semverx/range_state.h"
#include "nlink_semverx/semverx/compatibility.h"

// Version information
#define NLINK_SEMVERX_VERSION_MAJOR 1
#define NLINK_SEMVERX_VERSION_MINOR 5
#define NLINK_SEMVERX_VERSION_PATCH 0
#define NLINK_SEMVERX_VERSION_STRING "1.5.0"

#endif /* NLINK_SEMVERX_H */
