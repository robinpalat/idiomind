#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# ============================================================
# Resource Provider: SpanishDict Word Audio
# Resource Type: TTS online — Download audio for words
# ============================================================
#
# Downloads Spanish pronunciation audio from SpanishDict.
# No API key required. Spanish only.
#
# Execution pattern: Source + URL export (Pattern B)

TLANGS="es"
USEDTO="Download audio (online)"
INFO="Search audio for words"
LANGUAGES="Spanish"
STATUS="Ok"
VOICES=""
CONF="FALSE"
FILECONF=""
TESTWORD=""
EXECUT=""

# URL-encode text for safe embedding in query parameters.
_sd_urlencode()
{
    local _str="$1"
    python3 -c "import urllib.parse; print(urllib.parse.quote('$_str', safe=''))" 2>/dev/null \
    || printf '%s' "$_str" | curl -Gso /dev/stdout -w '%{url_effective}' --data-urlencode @- "" 2>/dev/null \
    || printf '%s' "$_str"
}

export TESTURL="https://audio1.spanishdict.com/audio?lang=es&text=$(_sd_urlencode "prueba")"
export URL="https://audio1.spanishdict.com/audio?lang=es&text=$(_sd_urlencode "${word}")"
export EX='mp3'
