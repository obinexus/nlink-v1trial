/**
 * @file parser_interface.h
 * @brief CLI parser interface
 */

#ifndef NLINK_SEMVERX_CLI_PARSER_INTERFACE_H
#define NLINK_SEMVERX_CLI_PARSER_INTERFACE_H

#include "nlink_semverx/core/error_codes.h"

typedef struct nlink_cli_context nlink_cli_context_t;
typedef struct nlink_cli_args nlink_cli_args_t;

// CLI functions
nlink_cli_result_t nlink_cli_init(nlink_cli_context_t *context);
nlink_cli_result_t nlink_cli_parse_args(int argc, char *argv[], nlink_cli_args_t *args);
nlink_cli_result_t nlink_cli_execute(nlink_cli_context_t *context, nlink_cli_args_t *args);
void nlink_cli_cleanup(nlink_cli_context_t *context);
void nlink_cli_display_help(const char *program_name);

#endif /* NLINK_SEMVERX_CLI_PARSER_INTERFACE_H */
