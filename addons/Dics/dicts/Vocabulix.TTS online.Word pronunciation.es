#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "Does not need configuration")\n" info "$4"

else
export LINK="http://static.vocabulix.com//speech/dict/spanish/${word}.mp3"
export ex='mp3'
fi
