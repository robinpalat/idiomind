#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "Does not need configuration")\n" info "$4"

else
local LINK="http://audio1.spanishdict.com/audio?lang=es&text=${word}"
local ex='mp3'
fi


