#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
source "$DS/ifs/cmns.sh"
msg "$(gettext "Does not need configuration")\n" dialog-information "$4"
else
export LINK="http://audio1.spanishdict.com/audio?lang=es&text=${word}"
export ex='mp3'
fi


