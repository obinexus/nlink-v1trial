/**
 * @file config.h (Enhanced with SemVerX Integration)
 * @brief NexusLink Configuration Parser with SemVerX Range State Extensions
 * @author Nnamdi Michael Okpala & Aegis Development Team
 * @version 1.5.0 (SemVerX Integration)
 *
 * Extended configuration system supporting SemVerX range state versioning,
 * hot-swapping capabilities, and compatibility matrix validation.
 */

#ifndef NLINK_CONFIG_H
#define NLINK_CONFIG_H

#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>

// =============================================================================
// SEMVERX RANGE STATE DEFINITIONS
// =============================================================================

#define SEMVERX_MAX_SWAPPABLE_VERSIONS 16
#define SEMVERX_MAX_EXCLUSION_PATTERNS 32
#define SEMVERX_VERSION_STRING_MAX 64
#define SEMVERX_RANGE_STRING_MAX 256

/**
 * @brief SemVerX range state enumeration
 */
typedef enum {
    SEMVERX_RANGE_STATE_UNKNOWN = 0,
    SEMVERX_RANGE_STATE_LEGACY,     // Deprecated, migration required
    SEMVERX_RANGE_STATE_STABLE,     // Production-ready, hot-swappable
    SEMVERX_RANGE_STATE_EXPERIMENTAL // Opt-in, validation required
} semverx_range_state_t;

/**
 * @brief SemVerX validation level enumeration
 */
typedef enum {
    SEMVERX_VALIDATION_DISABLED = 0,
    SEMVERX_VALIDATION_PERMISSIVE,  // Warnings only
    SEMVERX_VALIDATION_STRICT,      // Enforcement with errors
    SEMVERX_VALIDATION_PARANOID     // Maximum validation
} semverx_validation_level_t;

/**
 * @brief SemVerX registry coordination mode
 */
typedef enum {
    SEMVERX_REGISTRY_CENTRALIZED = 0, // Single registry file
    SEMVERX_REGISTRY_DISTRIBUTED,     // Per-component registries
    SEMVERX_REGISTRY_HYBRID          // Mixed approach
} semverx_registry_mode_t;

// =============================================================================
// SEMVERX COMPONENT CONFIGURATION
// =============================================================================

/**
 * @brief SemVerX hot-swap configuration
 */
typedef struct {
    bool hot_swap_enabled;           // Enable runtime component replacement
    bool runtime_validation;         // Validate compatibility at runtime
    bool allow_cross_range_swap;     // Allow swapping across range states
    uint32_t validation_timeout_ms;  // Timeout for validation operations
    bool rollback_on_failure;        // Automatic rollback on swap failure
    bool pre_swap_validation;        // Validate before attempting swap
    bool post_swap_verification;     // Verify after successful swap
} semverx_hotswap_config_t;

/**
 * @brief SemVerX compatibility rules
 */
typedef struct {
    char compatible_range[SEMVERX_RANGE_STRING_MAX];  // Semver range expression
    char **swappable_with;                           // Explicitly compatible versions
    size_t swappable_count;                          // Number of swappable versions
    char **exclusion_patterns;                       // Excluded version patterns
    size_t exclusion_count;                          // Number of exclusions
    bool requires_opt_in;                            // Explicit opt-in required
    bool backward_compatibility;                     // Maintains backward compatibility
} semverx_compatibility_rules_t;

/**
 * @brief SemVerX component metadata
 */
typedef struct {
    char component_name[64];                         // Component identifier
    char version[SEMVERX_VERSION_STRING_MAX];        // Current version
    semverx_range_state_t range_state;               // Current range state
    semverx_compatibility_rules_t compatibility;     // Compatibility rules
    semverx_hotswap_config_t hotswap;               // Hot-swap configuration
    
    // Metadata
    struct timespec last_validated;                  // Last compatibility check
    uint32_t validation_checksum;                    // Rules checksum
    bool is_validated;                              // Validation status
} semverx_component_metadata_t;

// =============================================================================
// EXTENDED NLINK CONFIGURATION STRUCTURES
// =============================================================================

/**
 * @brief Enhanced feature toggle with SemVerX support
 */
typedef struct {
    char feature_name[64];                          // Feature identifier
    bool is_enabled;                                // Enable/disable flag
    char version_constraint[32];                    // Semver constraint
    uint32_t priority_level;                        // Feature priority
    semverx_range_state_t feature_range_state;      // Feature stability level
    bool requires_semverx_validation;               // Needs SemVerX validation
} nlink_feature_toggle_extended_t;

/**
 * @brief SemVerX global configuration
 */
typedef struct {
    bool semverx_enabled;                           // Enable SemVerX processing
    semverx_range_state_t project_range_state;      // Overall project stability
    semverx_validation_level_t validation_level;    // Validation strictness
    semverx_registry_mode_t registry_mode;          // Registry coordination mode
    
    // Registry paths
    char shared_registry_path[NLINK_MAX_PATH_LENGTH];
    char compatibility_matrix_path[NLINK_MAX_PATH_LENGTH];
    char range_policies_path[NLINK_MAX_PATH_LENGTH];
    
    // Global policies
    bool allow_legacy_components;                   // Allow legacy range state
    bool enforce_range_boundaries;                  // Strict range enforcement
    bool enable_dependency_graph_analysis;         // Enhanced dependency tracking
    bool monitor_hot_swap_events;                   // Hot-swap event logging
    
    // Performance tuning
    uint32_t max_validation_depth;                  // Maximum dependency depth
    uint32_t compatibility_cache_size;              // Validation result caching
    bool lazy_validation;                           // Defer validation until needed
} nlink_semverx_config_t;

/**
 * @brief Enhanced component metadata with SemVerX
 */
typedef struct {
    char component_name[64];                        // Component identifier
    char component_path[NLINK_MAX_PATH_LENGTH];     // Path to component
    char version[NLINK_VERSION_STRING_MAX];         // Component version
    bool has_nlink_txt;                            // Has component config
    uint32_t dependency_count;                      // Number of dependencies
    char **dependencies;                           // Dependency names
    
    // SemVerX extensions
    semverx_component_metadata_t semverx_metadata;  // SemVerX-specific data
    bool is_semverx_compliant;                      // SemVerX compliance status
    struct timespec last_compatibility_check;       // Last compatibility check
} nlink_component_metadata_extended_t;

/**
 * @brief Enhanced pkg.nlink configuration with SemVerX
 */
typedef struct {
    // Original NexusLink fields (preserved for compatibility)
    char project_name[128];
    char project_version[NLINK_VERSION_STRING_MAX];
    char entry_point[NLINK_MAX_PATH_LENGTH];
    
    // Build mode configuration
    nlink_pass_mode_t pass_mode;
    bool experimental_mode_enabled;
    bool unicode_normalization_enabled;
    bool isomorphic_reduction_enabled;
    
    // Threading configuration (existing)
    nlink_thread_pool_config_t thread_pool;
    
    // Enhanced feature toggles with SemVerX
    uint32_t feature_count;
    nlink_feature_toggle_extended_t features[NLINK_MAX_FEATURES];
    
    // Global constraints (existing)
    uint32_t max_memory_mb;
    uint32_t compilation_timeout_seconds;
    bool strict_mode;
    
    // Enhanced component discovery with SemVerX
    uint32_t component_count;
    nlink_component_metadata_extended_t components[NLINK_MAX_COMPONENTS];
    
    // SemVerX configuration (new)
    nlink_semverx_config_t semverx;
    
    // Parse metadata (existing)
    struct timespec parse_timestamp;
    char config_file_path[NLINK_MAX_PATH_LENGTH];
    uint32_t config_checksum;
    
    // SemVerX metadata (new)
    uint32_t semverx_config_version;               // SemVerX schema version
    bool semverx_validation_passed;                // Overall validation status
    struct timespec last_semverx_validation;       // Last SemVerX validation
} nlink_pkg_config_extended_t;

// =============================================================================
// SEMVERX PARSING AND VALIDATION FUNCTIONS
// =============================================================================

/**
 * @brief Initialize SemVerX subsystem
 */
nlink_config_result_t nlink_semverx_init(void);

/**
 * @brief Parse SemVerX configuration section from pkg.nlink
 */
nlink_config_result_t nlink_parse_semverx_config(const char *config_path,
                                                 nlink_semverx_config_t *semverx_config);

/**
 * @brief Parse SemVerX metadata from component nlink.txt
 */
nlink_config_result_t nlink_parse_component_semverx(const char *config_path,
                                                    semverx_component_metadata_t *metadata);

/**
 * @brief Validate SemVerX compatibility between components
 */
nlink_config_result_t nlink_validate_semverx_compatibility(
    const semverx_component_metadata_t *comp1,
    const semverx_component_metadata_t *comp2,
    const nlink_semverx_config_t *global_config);

/**
 * @brief Build compatibility matrix for project
 */
nlink_config_result_t nlink_build_compatibility_matrix(const char *project_root,
                                                       nlink_pkg_config_extended_t *config);

/**
 * @brief Validate hot-swap feasibility
 */
bool nlink_can_hot_swap(const semverx_component_metadata_t *current,
                       const semverx_component_metadata_t *target,
                       const nlink_semverx_config_t *global_config);

/**
 * @brief Load shared artifacts registry
 */
nlink_config_result_t nlink_load_shared_registry(const char *registry_path,
                                                 nlink_semverx_config_t *config);

/**
 * @brief Validate project-wide SemVerX compliance
 */
nlink_config_result_t nlink_validate_project_semverx(const char *project_root,
                                                     nlink_pkg_config_extended_t *config);

/**
 * @brief Generate SemVerX compatibility report
 */
void nlink_generate_semverx_report(const nlink_pkg_config_extended_t *config,
                                  const char *output_path);

/**
 * @brief Parse range state from string
 */
semverx_range_state_t nlink_parse_range_state(const char *state_str);

/**
 * @brief Convert range state to string
 */
const char* nlink_range_state_to_string(semverx_range_state_t state);

/**
 * @brief Enhanced configuration parsing with SemVerX support
 */
nlink_config_result_t nlink_parse_pkg_config_extended(const char *config_path,
                                                     nlink_pkg_config_extended_t *config);

/**
 * @brief Enhanced component discovery with SemVerX metadata
 */
int nlink_discover_components_extended(const char *project_root_path,
                                      nlink_pkg_config_extended_t *config);

/**
 * @brief Enhanced configuration validation with SemVerX
 */
nlink_config_result_t nlink_validate_config_extended(const nlink_pkg_config_extended_t *config);

/**
 * @brief Enhanced decision matrix with SemVerX information
 */
void nlink_print_decision_matrix_extended(const nlink_pkg_config_extended_t *config);

/**
 * @brief Calculate extended configuration checksum including SemVerX
 */
uint32_t nlink_calculate_config_checksum_extended(const nlink_pkg_config_extended_t *config);

// =============================================================================
// SEMVERX UTILITY MACROS
// =============================================================================

/**
 * @brief Check if component is in stable range
 */
#define NLINK_IS_STABLE_RANGE(comp) \
    ((comp)->semverx_metadata.range_state == SEMVERX_RANGE_STATE_STABLE)

/**
 * @brief Check if component is experimental
 */
#define NLINK_IS_EXPERIMENTAL_RANGE(comp) \
    ((comp)->semverx_metadata.range_state == SEMVERX_RANGE_STATE_EXPERIMENTAL)

/**
 * @brief Check if component is legacy
 */
#define NLINK_IS_LEGACY_RANGE(comp) \
    ((comp)->semverx_metadata.range_state == SEMVERX_RANGE_STATE_LEGACY)

/**
 * @brief Check if hot-swap is enabled for component
 */
#define NLINK_CAN_HOT_SWAP_COMPONENT(comp) \
    ((comp)->semverx_metadata.hotswap.hot_swap_enabled && \
     (comp)->semverx_metadata.range_state != SEMVERX_RANGE_STATE_LEGACY)

/**
 * @brief Validate SemVerX compatibility macro
 */
#define NLINK_VALIDATE_SEMVERX_COMPAT(comp1, comp2, config) \
    (nlink_validate_semverx_compatibility(&(comp1)->semverx_metadata, \
                                         &(comp2)->semverx_metadata, \
                                         &(config)->semverx) == NLINK_CONFIG_SUCCESS)

// =============================================================================
// BACKWARD COMPATIBILITY LAYER
// =============================================================================

/**
 * @brief Legacy type alias for backward compatibility
 */
typedef nlink_pkg_config_extended_t nlink_pkg_config_t;

/**
 * @brief Legacy function wrapper for backward compatibility
 */
static inline nlink_config_result_t nlink_parse_pkg_config(const char *config_path,
                                                          nlink_pkg_config_t *config) {
    return nlink_parse_pkg_config_extended(config_path, config);
}

#endif /* NLINK_CONFIG_H */
