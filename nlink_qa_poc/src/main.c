/**
 * @file main.c
 * @brief NexusLink CLI Main Entry Point
 */

#include "nlink_qa_poc/nlink.h"
#include "nlink_qa_poc/cli/parser.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]) {
    nlink_cli_args_t args;
    
    int parse_result = nlink_cli_parse(argc, argv, &args);
    
    if (parse_result == 1) {
        /* Help requested */
        nlink_cli_print_help(argv[0]);
        nlink_cli_cleanup(&args);
        return 0;
    }
    
    if (parse_result < 0) {
        /* Parse error */
        printf("Error: Invalid command line arguments\n");
        nlink_cli_print_help(argv[0]);
        nlink_cli_cleanup(&args);
        return 1;
    }
    
    int result = nlink_cli_execute(&args);
    
    nlink_cli_cleanup(&args);
    return result;
}
