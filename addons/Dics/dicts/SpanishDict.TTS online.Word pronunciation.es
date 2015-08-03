#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "Does not need configuration.")\n" info "$4"


else
name="spanishdict"
lang="es"

wget -T 51 -O ./"${1}.mp3" -q -U Mozilla "http://audio1.spanishdict.com/audio?lang=es&text=${1}"

exit
fi


