#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ "$1" = '_DLG_' ]]; then
    fname="$(basename "$0")"
    name="<b>$(cut -f 1 -d '.' <<< "$fname")</b>"
    icon="gtk-apply"
    
    if [ -f "$DC_a/dict/msgs/$fname" ]; then
        info="\n<small>$(gettext "<b>Status:</b>") $(< "$DC_a/dict/msgs/$fname")</small>"
        icon="dialog-warning"
        
    elif grep -Fxq "$fname" "$DC_a/dict/ok_nolang.list" >/dev/null 2>&1; then
        info="\n<small>$(gettext "<b>Status:</b> Not enabled for the language you are learning.")</small>\n"
        icon="dialog-information"
    fi
    
    source "$DS/ifs/cmns.sh"
    msg "$name\n<small>$(gettext "Languages"): English, Spanish\n$(gettext "Does not need configuration")</small>\n$info" $icon "$4" "$(gettext "Close")"
else

     _test="prueba"
     
    TLANGS="es"
    export TESTURL="http://audio1.spanishdict.com/audio?lang=es&text=${_test}"
    export URL="http://audio1.spanishdict.com/audio?lang=es&text=${word}"
    export EX='mp3'
fi


