#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# ============================================================
# Resource Provider Template
# ============================================================
#
# PURPOSE:
#   This file is a starting point for creating new Resource
#   providers for Idiomind. It documents the common interface,
#   the provider-specific parts, and the contract that must
#   be respected.
#
# HOW TO USE THIS TEMPLATE:
#   1. Copy this file into the scripts/ directory.
#   2. Rename following the naming convention:
#        ProviderName.Type.Task.Language
#      For example:
#        Azure.TTS online.Convert text to audio.various
#   3. Replace all [PLACEHOLDER] sections with your provider's data.
#   4. Implement the provider-specific functions.
#   5. Test with: test.sh (run from the Resources GUI).
#
# WHAT TO MODIFY:
#   - Provider metadata (TLANGS, LANGUAGES, USEDTO, INFO, etc.)
#   - Provider-specific config (PROVIDER_ENDPOINT, PROVIDER_AUTH)
#   - validate_input() — your input validation
#   - build_request() — your API request construction
#   - execute_request() — your API call
#   - parse_response() — your response handling
#
# WHAT NOT TO MODIFY:
#   - The metadata variable NAMES (TLANGS, LANGUAGES, USEDTO, INFO, etc.)
#   - The script argument contract ($1, $2)
#   - The exit status contract (0=success, non-zero=failure)
#   - The error message format (HTML spans in $msgs/)
#   - The filename convention
#
# ============================================================

# ------------------------------------------------------------
# Common utilities
# ------------------------------------------------------------

_RES_DIR="$(dirname "$(readlink -f "$0")")"
[ -f "$_RES_DIR/common.sh" ] && source "$_RES_DIR/common.sh"
_msgs_dir="$HOME/.config/idiomind/addons/resources/msgs"

# ------------------------------------------------------------
# Provider Metadata
# ------------------------------------------------------------
# These variables are read by cnfg.sh (GUI) and test.sh.
# The NAMES must not change. The VALUES are provider-specific.
#
# TLANGS     — Comma-separated language codes this provider supports.
#              Use "various" if the provider handles any language.
# USEDTO     — Short purpose shown as "Is used for" in the config dialog.
#              Example: "Convert text to audio (online)"
# INFO       — Short bounded documentation shown as "Info" (no URLs here).
# INFOAPI    — API reference URL shown as link (empty if none).
# LANGUAGES  — Human-readable language names for display.
# STATUS     — Initial status. Keep as "Ok".
# VOICES     — Available voices (for display). Empty if not applicable.
# CONF       — "TRUE" if the provider has a config dialog (API key, etc.)
# FILECONF   — Path to .cfg file. Empty if CONF is "FALSE".
# CONFFIELDS — Space-separated field names for the config form.
#              Example: "key model voice"
# CONFOPTS   — Dropdown options. Format: "field|opt1!opt2!opt3"
# CONFKEY_HIDDEN — Fields rendered as password input.
# TESTSTRING — Sample text for TTS testing.
# TESTWORD   — Sample word for image/definition testing.
# EXECUT     — Required system binary. Empty = URL-based (wget).
# EX         — Output file extension (mp3, wav, ogg, etc.)

TLANGS="en, es"
USEDTO="Convert text to audio (online)"
INFO="Short bounded documentation (no URLs here)"
INFOAPI="https://example.com/docs/api"
LANGUAGES="English, Spanish"
STATUS="Ok"
VOICES=""
CONF="TRUE"
FILECONF="$HOME/.config/idiomind/addons/resources/YourProvider.cfg"
CONFFIELDS="key model voice"
CONFOPTS="model|standard!premium
voice|female!male"
CONFKEY_HIDDEN="key"
TESTSTRING="This is a test"
TESTWORD=""
EXECUT="curl"
EX="mp3"

# ------------------------------------------------------------
# Provider-Specific Configuration
# ------------------------------------------------------------
# These variables define your provider's API details.
# Replace them with your actual provider values.

PROVIDER_ENDPOINT="https://api.example.com/v1/tts"
# PROVIDER_AUTH is a comment — authentication is implemented in build_request()

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

# validate_input — Verify that required arguments are present.
#
# Called before any API request. Return 1 to abort with an error.
# $1 = text to process, $2 = output file path (for Convert type)

validate_input()
{
    [ -n "$1" ] || return 1
    [ -n "$2" ] || return 1
    return 0
}

# build_request — Construct the API request (URL, headers, body).
#
# This is provider-specific. Set variables that execute_request() will use.
# For curl-based providers, you might set:
#   _request_url, _request_headers (array), _request_body

build_request()
{
    local _text="$1" _model="$2" _voice="$3"

    _request_url="$PROVIDER_ENDPOINT"
    _request_headers=(-H "Content-Type: application/json")
    # Authentication header — add your provider's auth mechanism here
    # Example for Bearer token: _request_headers+=(-H "Authorization: Bearer $api_key")

    # Build request body — use jq if available for safe JSON construction
    if command -v jq >/dev/null 2>&1; then
        _request_body=$(jq -cn \
            --arg m "$_model" --arg v "$_voice" --arg s "$_text" \
            '{model:$m,voice:$v,input:$s}')
    else
        # Fallback: escape special characters for JSON
        local _escaped
        _escaped=$(printf '%s' "$_text" | sed 's/\\/\\\\/g; s/"/\\"/g')
        _request_body="{\"model\":\"$_model\",\"voice\":\"$_voice\",\"input\":\"$_escaped\"}"
    fi
}

# execute_request — Make the API call and handle the response.
#
# Write the output to $2 (the output file path).
# Return 0 on success, non-zero on failure.
# Use resource_write_error() to report errors.

execute_request()
{
    local _output="$2"
    local _http_code _response

    _response=$(curl -s -m 51 \
        -w "\n%{http_code}" \
        -X POST "$_request_url" \
        "${_request_headers[@]}" \
        -d "$_request_body" \
        -o "$_output" 2>&1)
    _http_code=$(tail -1 <<< "$_response")

    case "$_http_code" in
        200)
            return 0
            ;;
        401)
            resource_write_error \
                "<span color='#C15F27'>API key invalid or expired</span>" \
                "$_msgs_dir" "${0##*/}"
            return 1
            ;;
        429)
            resource_write_error \
                "<span color='#C15F27'>Request limit exceeded</span>" \
                "$_msgs_dir" "${0##*/}"
            return 1
            ;;
        503)
            resource_write_error \
                "<span color='#C15F27'>Service temporarily unavailable</span>" \
                "$_msgs_dir" "${0##*/}"
            return 1
            ;;
        *)
            resource_write_error \
                "<span color='#C15F27'>Connection error (HTTP $_http_code)</span>" \
                "$_msgs_dir" "${0##*/}"
            return 1
            ;;
    esac
}

# parse_response — Validate the output after a successful API call.
#
# Check that the output file is valid audio. Return 1 if not.
# This is optional — many providers skip this and let test.sh validate.

parse_response()
{
    local _file="$1"
    [ -s "$_file" ] || return 1
    file -b --mime-type "$_file" 2>/dev/null \
        | grep -qE 'audio|mpeg|mp3|ogg|wav' || return 1
    return 0
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
# The script receives arguments differently depending on context:
#
#   When sourced by cnfg.sh/add.sh/test.sh:
#     No arguments. Metadata variables are read from this file.
#
#   When executed by add.sh (TTS Convert):
#     $1 = text to synthesize
#     $2 = output file path
#
#   When executed by test.sh (testing):
#     $1 = test text, $2 = output file path
#
#   When executed with _dclk_ (detail click):
#     $1 = "_dclk_" — no-op, metadata already exported.

if [ "$1" = "_dclk_" ]; then
    :
elif [ -n "$2" ]; then

    # Read API key from config file (safe parsing, not source)
    api_key=$(resource_read_config "$FILECONF" "key")
    model=$(resource_read_config "$FILECONF" "model")
    voice=$(resource_read_config "$FILECONF" "voice")
    [ -z "$model" ] && model="tts-1"
    [ -z "$voice" ] && voice="alloy"

    # Validate credentials
    if [ -z "$api_key" ]; then
        resource_write_error \
            "<span color='#C15F27'>No key configuration</span>" \
            "$_msgs_dir" "${0##*/}"
        exit 1
    fi

    # Validate input
    validate_input "$1" "$2" || exit 1

    # Build and execute the request
    build_request "$1" "$model" "$voice" || exit 1
    execute_request "$@" || exit 1
fi
