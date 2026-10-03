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

# ------------------------------------------------------------

# Extract a metadata field (LANGUAGES, TLANGS, ...) from a provider
# script, handling values split across several lines:
#
#     LANGUAGES="Afrikaans, ... Bulgarian,
#      Catalan, ..., English, ..."
#
# A naive `grep -m1 '^LANGUAGES=' | cut -d'"' -f2` only returns the
# first physical line ("...Bulgarian,") and wrongly concludes that
# e.g. English is unsupported, disabling the provider on every boot.
#
# USAGE:
#     val=$(resource_get_field "/path/to/provider.sh" "LANGUAGES")
#
# Only lines starting at column 0 are considered (comments excluded).
# The surrounding quotes are stripped and continuation lines are
# joined with a single space.

resource_get_field()
{
    local _file="$1" _field="$2"
    [ -f "$_file" ] || return 1
    sed -n "/^${_field}=\"/,/\"[[:space:]]*$/p" "$_file" 2>/dev/null \
        | sed "1s/^${_field}=\"//; \$s/\"[[:space:]]*$//" \
        | tr '\n' ' ' | sed 's/  */ /g; s/^ //; s/ $//'
}

# ------------------------------------------------------------

# Check whether a provider script supports a given learning language.
#
# USAGE:
#     resource_supports_language "<script>" "<tlng>" "<lgt>"
#       _tlng: full name, e.g. "English" (matches LANGUAGES)
#       _lgt:  code, e.g. "en" (matches TLANGS when LANGUAGES missing)
#
# Logic:
#   - if LANGUAGES exists: whole-word match of _tlng in the full
#     (possibly multiline) value;
#   - else if TLANGS exists: exact token match of _lgt in the
#     comma-separated list (so "en" does not match inside other
#     tokens and "zh-cn" is safe).
#
# Returns 0 when supported, 1 otherwise.

resource_supports_language()
{
    local _script="$1" _tlng="$2" _lgt="$3"
    local _langs _tcodes _clean
    [ -f "$_script" ] || return 1
    _langs="$(resource_get_field "$_script" "LANGUAGES")"
    if [ -n "$_langs" ]; then
        grep -Fwq -- "$_tlng" <<< "$_langs" 2>/dev/null
        return $?
    fi
    _tcodes="$(resource_get_field "$_script" "TLANGS")"
    if [ -n "$_tcodes" ] && [ -n "$_lgt" ]; then
        _clean="$(tr -d '[:space:]' <<< "$_tcodes")"
        case ",${_clean}," in
            *",${_lgt},"*) return 0 ;;
            *) return 1 ;;
        esac
    fi
    # No language metadata: assume compatible (historic behaviour).
    return 0
}

# ------------------------------------------------------------

# Whether the current process is allowed to open the Resources GUI.
#
# Background/startup tasks (autostart, feeds/podcasts refresh, session
# init) export IDIOMIND_NONINTERACTIVE=1. In that mode missing
# providers must fail silently (empty output, log) instead of popping
# modal yad dialogs that block the boot and multiply (one per caller).
#
# Returns 0 when GUI is allowed, 1 when it must be suppressed.

resource_gui_allowed()
{
    [ "${IDIOMIND_NONINTERACTIVE:-}" = 1 ] && return 1
    [ "${IDIOMIND_BACKGROUND:-}" = 1 ] && return 1
    return 0
}

# ------------------------------------------------------------

# Whether a Resources config dialog is already on screen.
#
# Used by library callers (translate/tts/_definition) to avoid
# stacking N dialogs when N background jobs miss the same provider
# at once. The dialog itself holds an flock (see cnfg.sh dlg()),
# so this is only a fast pre-check to avoid even spawning it.

resource_dlg_is_open()
{
    pgrep -f "Resources/cnfg.sh" >/dev/null 2>&1 && return 0
    return 1
}
