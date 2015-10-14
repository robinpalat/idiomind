#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "Does not need configuration")\n" info "$4"

else
local LINK="http://static.vocabulix.com//speech/dict/spanish/${word}.mp3"
local ex='mp3'
fi
