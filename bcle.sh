#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
cfg="${DC_tlt}/10.cfg"
rplay="$(grep -o rplay=\"[^\"]* "${cfg}" |grep -o '[^"]*$')"
ritem=0; stnrd=0; f=0
echo 0 > "$DT/playlck"
touch "${DM_tlt}"

[ -z "${tpc}" -a ! -d "${DC_tlt}" ] && exit 1
export tpc DC_tlt cfg f ritem stnrd numer
export word_rep sentence_rep pause_osd
export -f include msg
sleep 1

if [[ "$rplay" = TRUE ]]; then
    while [ 1 ]; do
        "$DS/chng.sh" 0; sleep ${pause_rep}
        if [ "$(< $DT/playlck)" = '0' ]; then
            "$DS"/stop.sh 2 & break
        fi
    done
else
    "$DS/chng.sh" 0
    echo 0 > "$DT/playlck" & exit 0
fi
