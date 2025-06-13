/**
 * @file nlink.c
 * @brief NexusLink Core Library Implementation
 */

#include "nlink_qa_poc/nlink.h"
#include <stdio.h>
#include <stdlib.h>

static bool g_nlink_initialized = false;

int nlink_init(void) {
    if (g_nlink_initialized) {
        return 0; /* Already initialized */
    }
    
    printf("NexusLink v%s initializing...\n", NLINK_VERSION);
    g_nlink_initialized = true;
    return 0;
}

void nlink_cleanup(void) {
    if (!g_nlink_initialized) {
        return;
    }
    
    printf("NexusLink cleanup complete\n");
    g_nlink_initialized = false;
}

const char* nlink_version(void) {
    return NLINK_VERSION;
}
