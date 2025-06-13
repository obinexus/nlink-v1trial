#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "nlink_qa_poc/core/config.h"
#include "nlink_qa_poc/etps/telemetry.h"

const char* nlink_version(void) {
    return "1.0.0";
}

int main(int argc, char* argv[]) {
    etps_context_t* ctx = etps_context_create("main");
    
    printf("NexusLink QA POC v%s\n", nlink_version());
    printf("ETPS Session GUID: %lu\n", ctx->session_guid);
    
    if (argc > 1 && strcmp(argv[1], "--etps-test") == 0) {
        printf("ETPS Test Mode Enabled\n");
        ETPS_LOG_ERROR(ctx, ETPS_COMPONENT_CLI, 0, "test", "ETPS test message");
        
        if (argc > 2 && strcmp(argv[2], "--json") == 0) {
            printf("{\n");
            printf("  \"command\": \"etps-test\",\n");
            printf("  \"guid\": %lu,\n", ctx->session_guid);
            printf("  \"timestamp\": %lu,\n", etps_get_timestamp());
            printf("  \"status\": \"completed\"\n");
            printf("}\n");
        }
    }
    
    etps_context_destroy(ctx);
    return 0;
}
