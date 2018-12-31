#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
rplay=$(tpc_db 1 config rplay)
ritem=0; stnrd=0; f=0
echo 0 > "$DT/playlck"
touch "${DM_tlt}"

[ -z "${tpc}" -a ! -d "${DC_tlt}" ] && exit 1
export tpc DC_tlt cfg f ritem stnrd numer
export word_rep sentence_rep pause_osd
export -f include msg tpc_db
sleep 1

t=0
[ $(tpc_db 1 config words) = 'TRUE' ] && t=1
[ $(tpc_db 1 config sntcs) = 'TRUE' ] && t=1
[ $(tpc_db 1 config marks) = 'TRUE' ] && t=1
[ $(tpc_db 1 config learn) = 'TRUE' ] && t=1
[ $(tpc_db 1 config diffi) = 'TRUE' ] && t=1


if [ "$t" = 1 ]; then

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

else
    "$DS/play.sh" play_list
fi
