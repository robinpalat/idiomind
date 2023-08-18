#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
rplay=$(tpc_db 1 config rplay)
ritem=0; stnrd=0
echo 0 > "$DT/playlck"
touch "${DM_tlt}"
[ -z "${tpc}" ] && [ ! -d "${DC_tlt}" ] && exit 1
export tpc DC_tlt cfg f ritem stnrd numer
export word_rep sentence_rep pause_osd
export -f include msg tpc_db
true=0; f=0

sleep 0.5

[ -f "${DC_tlt}/stts" ] && export stts=$(sed -n 1p "${DC_tlt}/stts")

if [ $stts = 1 ] || [ $stts = 2 ] || [ $stts = 5 ] || [ $stts = 6 ]; then
    [ $(tpc_db 1 config words) = 'TRUE' ] && true=1
    [ $(tpc_db 1 config sntcs) = 'TRUE' ] && true=1
    [ $(tpc_db 1 config marks) = 'TRUE' ] && true=1
    [ $(tpc_db 1 config learn) = 'TRUE' ] && true=1
    [ $(tpc_db 1 config diffi) = 'TRUE' ] && true=1
    [ ${true} = 0 ] && f=1
fi

if [ ${stts}  -gt 10 ]; then
	for addon in "$DS/ifs/mods/play"/*; do
		source "${addon}"
		for item in "${!items[@]}"; do
			val="$(grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$')"
			if [ "$val" = 'TRUE' ]; then true=1; fi
			declare true=${true};
		done
		unset items
	done
fi

if [ ${f} = 1 ] && [ "$1" != 2 ]; then true=0; fi

if [ $true = 1 ]; then
	echo -e "${tpc}" > "$DT/playlck"
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
	if [ $stts = 1 ] || [ $stts = 2 ] || [ $stts = 5 ] || [ $stts = 6 ]; then
		"$DS/play.sh" play_list 2
    else
		notify-send "$(gettext "Nothing to play")" "$(gettext "Exiting...")" -t 3000 &
	fi
fi
