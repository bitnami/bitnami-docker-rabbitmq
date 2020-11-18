#!/bin/bash

# Library to use for scripts expected to be used as Kubernetes lifecycle hooks

# Output is sent to output of process 1 and thus end up in the container log. The hook output in
# general isn't saved.

. /opt/bitnami/scripts/liblog.sh
########################
# Print to STDERR of process 1. Overrides implementation in liblog.
# Arguments:
#   Message to print
# Returns:
#   None
#########################
stderr_print() {
    # 'is_boolean_yes' is defined in libvalidations.sh, but depends on this file so we cannot source it
    local bool="${BITNAMI_QUIET:-false}"
    # comparison is performed without regard to the case of alphabetic characters
    shopt -s nocasematch
    if ! [[ "$bool" = 1 || "$bool" =~ ^(yes|true)$ ]]; then
        printf "%b\\n" "${*}" >/proc/1/fd/2
    fi
}
#########################
# Redirects output to /dev/null if debug mode is disabled and to output of process 1 otherwise.
# Globals:
#   BITNAMI_DEBUG
# Arguments:
#   $@ - Command to execute
# Returns:
#   None
#########################
debug_execute() {
    if ${BITNAMI_DEBUG:-false}; then
        "$@" >/proc/1/fd/1 2>/proc/1/fd/2
    else
        "$@" >/dev/null 2>&1
    fi
}
