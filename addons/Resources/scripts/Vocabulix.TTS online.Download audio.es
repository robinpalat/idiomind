#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# ============================================================
# Resource Provider: Vocabulix Spanish Audio
# Resource Type: TTS online — Download audio for words
# ============================================================
#
# Downloads pre-recorded Spanish pronunciation audio.
# No API key required. Spanish only.
#
# Execution pattern: Source + URL export (Pattern B)

TLANGS="es"
INFO="Search audio for words"
LANGUAGES="Spanish"
STATUS="Ok"
VOICES=""
CONF="FALSE"
FILECONF=""
TESTWORD=""
EXECUT=""

export TESTURL="http://static.vocabulix.com//speech/dict/spanish/prueba.mp3"
export URL="http://static.vocabulix.com//speech/dict/spanish/${word}.mp3"
export EX='mp3'
