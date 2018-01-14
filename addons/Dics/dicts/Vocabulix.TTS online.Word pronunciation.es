#!/bin/bash

if [[ "$1" = _dlg_ ]]; then
    source "$DS/ifs/cmns.sh"
    msg "$(gettext "Languages"): Spanish\n$(gettext "Does not need configuration")\n" dialog-information "$4" "$(gettext "Close")"
else
    export LINK="http://static.vocabulix.com//speech/dict/spanish/${word}.mp3"
    export ex='mp3'
fi
