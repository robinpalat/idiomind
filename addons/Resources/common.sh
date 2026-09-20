#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# ============================================================
# Resource Addon — Common Utilities
# ============================================================
#
# Minimal shared functions used across multiple resource providers.
#
# RULE: A function belongs here ONLY if it is used by two or more
# different providers (or by both providers AND test.sh/add.sh)
# without requiring knowledge of any specific provider.
#
# Providers should source this file when they need these utilities:
#
#     source "$(dirname "$(readlink -f "$0")")/common.sh" 2>/dev/null
#
# This path resolution works both when the script is executed
# directly and when it is sourced from another context.
#
# ============================================================

# ------------------------------------------------------------

# Write an error message for a resource provider.
#
# The message is stored as HTML in the msgs directory so that
# cnfg.sh and test.sh can display it in the GUI.
#
# USAGE:
#     resource_write_error "Error message" "/path/to/msgs" "filename"
#
# The message should NOT contain API keys or secrets.
# Use generic descriptions like "API key invalid" instead.
#
# For permanent errors (key invalid, quota exhausted), the message
# should contain one of these patterns so test.sh can auto-disable:
#     "key", "credential", "quota", "credit", "expired", "inactive"

resource_write_error()
{
    local _msg="$1" _dir="$2" _file="$3"
    [ -d "$_dir" ] || mkdir -p "$_dir"
    printf '%s\n' "$_msg" > "$_dir/$_file"
}

# ------------------------------------------------------------

# Clear a previous error message for a resource provider.
#
# USAGE:
#     resource_clear_error "/path/to/msgs" "filename"
#
# Called by test.sh when a provider passes validation,
# or by providers themselves when they recover from an error.

resource_clear_error()
{
    local _dir="$1" _file="$2"
    [ -f "$_dir/$_file" ] && rm -f "$_dir/$_file"
}

# ------------------------------------------------------------

# Read a value from a provider .cfg configuration file.
#
# The .cfg format is:  field="value"
# This function safely parses the value without executing the file.
#
# USAGE:
#     val=$(resource_read_config "/path/to/provider.cfg" "key")
#
# Returns the value string, or empty if not found.
# Returns empty if the value is literally "(null)".

resource_read_config()
{
    local _file="$1" _field="$2"
    [ -f "$_file" ] || { echo ""; return; }
    local _val
    _val=$(grep -o "${_field}=\"[^\"]*" "$_file" 2>/dev/null \
        | grep -o '[^"]*$' \
        | sed 's/(null)//')
    printf '%s' "$_val"
}
