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

t=0; f=0
[ $(tpc_db 1 config words) = 'TRUE' ] && t=1
[ $(tpc_db 1 config sntcs) = 'TRUE' ] && t=1
[ $(tpc_db 1 config marks) = 'TRUE' ] && t=1
[ $(tpc_db 1 config learn) = 'TRUE' ] && t=1
[ $(tpc_db 1 config diffi) = 'TRUE' ] && t=1

[ -f "${DC_tlt}/stts" ] && export stts=$(sed -n 1p "${DC_tlt}/stts")
if ((stts>=1 && stts<=10)); then 
    if [ ${t} = 0 ]; then f=1; fi
fi

for ad in "$DS/ifs/mods/play"/*; do
    source "${ad}"
    for item in "${!items[@]}"; do
        val="$(grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$')"
        if [ "$val" = 'TRUE' ]; then t=1; fi
        declare t=${t};
    done
    unset items
done

if [ ${f} = 1 -a "$1" != 2 ]; then t=0; fi

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
    "$DS/play.sh" play_list 2
fi
