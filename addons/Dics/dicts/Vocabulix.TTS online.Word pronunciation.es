#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "Does not need configuration")\n" info "$4"


else
name="vocabulix"
lang="es"

wget -T 51 -q -U Mozilla "http://static.vocabulix.com//speech/dict/spanish/$1.mp3"

exit
fi
