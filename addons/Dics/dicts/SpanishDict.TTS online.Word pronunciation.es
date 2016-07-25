#!/bin/bash

if [[ "$1" = _dlg_ ]]; then
    source "$DS/ifs/cmns.sh"
    msg "$(gettext "Languages"): English, Spanish\n$(gettext "Does not need configuration")\n" dialog-information "$4"
else
    export LINK="http://audio1.spanishdict.com/audio?lang=es&text=${word}"
    export ex='mp3'
fi


