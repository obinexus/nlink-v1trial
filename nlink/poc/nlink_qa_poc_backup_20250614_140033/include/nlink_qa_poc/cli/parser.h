/**
 * @file parser.h
 * @brief NexusLink Command-Line Interface Parser
 * @version 1.0.0
 */

#ifndef NLINK_CLI_PARSER_H
#define NLINK_CLI_PARSER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

/* CLI command structure */
typedef struct nlink_cli_args {
    bool config_check;
    bool verbose;
    bool version;
    char* project_root;
    char* config_file;
    char* output_file;
} nlink_cli_args_t;

/* CLI parsing API */
int nlink_cli_parse(int argc, char* argv[], nlink_cli_args_t* args);
void nlink_cli_cleanup(nlink_cli_args_t* args);
void nlink_cli_print_help(const char* program_name);
void nlink_cli_print_version(void);

/* CLI command execution */
int nlink_cli_execute(const nlink_cli_args_t* args);

#ifdef __cplusplus
}
#endif

#endif /* NLINK_CLI_PARSER_H */
