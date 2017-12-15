#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ ${1} = 0 ]]; then
    W=$(tpc_db 1 config words)
    S=$(tpc_db 1 config sntcs)
    M=$(tpc_db 1 config marks)
    L=$(tpc_db 1 config learn)
    D=$(tpc_db 1 config diffi)
    _stop=0

    _play() {
        if [[ ${stnrd} = 1 ]]; then
            a=$(tpc_db 1 config audio)
            n=$(tpc_db 1 config ntosd)
            l=$(tpc_db 1 config loop); ! [[ ${l} =~ $numer ]] && l=0
            rw=$(tpc_db 1 config rword); ! [[ ${rw} =~ $numer ]] && rw=0
            [ ! -e "$DT"/playlck ] && echo 0 > "$DT"/playlck

            if [ ${n} != TRUE -a ${a} != TRUE -a ${stnrd} = 1 ]; then a=TRUE; fi
            if ! grep 'TRUE' <<< "$W$S$M$L$D">/dev/null 2>&1; then "$DS"/stop.sh 2 & exit 1; fi
            
            if [ ${n} = TRUE ]; then
                notify-send -i "${icon}" "${trgt}" "${srce}" &
            fi
            if [ ${a} = TRUE ]; then sleep 0.2; sle=0.1; spn=1
                [ ${type} = 1 -a ${rw} = 1 ] && spn=${word_rep}
                [ ${type} = 2 -a ${rw} = 2 ] && spn=${sentence_rep} && sle=1
                ( while [ ${ritem} -lt ${spn} ]; do
                    "$DS"/play.sh play_file "${file}" "${trgt}"
                    [ ${ritem} = 0 ] && sleep ${sle}
                    [ ${ritem} = 1 ] && sleep 2
                    [ ${ritem} = 2 ] && sleep 2
                    let ritem++
                done )
            fi
        else
            echo -e "${trgt}" > "$DT/playlck"
            [ ${mime} = 1 ] && notify-send -i "${icon}" "${trgt}" "${srce}" -t 5000 &
            "$DS/play.sh" play_file "${file}" "${trgt}"
        fi
        [[ ${n} = TRUE ]] && [[ ${l} -lt ${pause_osd} ]] && l=${pause_osd}
        [[ ${stnrd} = 1 ]] && sleep ${l}
    }
    export -f _play

    getitem() {
        if [ ${f} -gt 5 -o ! -d "${DC_tlt}" ]; then
            msg "$(gettext "An error has occurred. Playback stopped")" dialog-information &
            "$DS"/stop.sh 2
        fi
        if [ -n "${item}" ]; then
            unset file icon
            _item="$(grep -F -m 1 "trgt{${item}}" "${DC_tlt}/data" |sed 's/}/}\n/g')"
            type="$(grep -oP '(?<=type{).*(?=})' <<<"${_item}")"
            export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<<"${_item}")"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<<"${_item}")"
            id="$(grep -oP '(?<=cdid{).*(?=})' <<<"${_item}")"
            [ -e "${DM_tlt}/images/${trgt,,}.jpg" ] && icon="${DM_tlt}/images/${trgt,,}.jpg"
            [ -e "${DM_tls}/images/${trgt,,}-0.jpg" ] && icon="${DM_tls}/images/${trgt,,}-0.jpg"
            [ -e "${DM_tlt}/$id.mp3" ] && file="${DM_tlt}/$id.mp3" || file="${DM_tls}/audio/${trgt,,}.mp3"
            stnrd=1
        else
            let f++
        fi
    }
    
	sents="$(tpc_db 5 sentences)"
	words="$(tpc_db 5 words)"
	marks="$(tpc_db 5 marks)"
	learn="$(tpc_db 5 learning)"
	leart="$(tpc_db 5 learnt)"

	if [ ! -e "$DT/play2lck" ]; then
		if [[ ${W} = TRUE ]] && [[ ${S} = TRUE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done <<< "$learn"
		fi
		if [[ ${W} = TRUE ]] && [[ ${S} = FALSE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done < <(grep -Fxv "${sents}" <<< "${learn}")
		fi
		if [[ ${W} = FALSE ]] && [[ ${S} = TRUE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done < <(grep -Fxv "${words}" <<< "${learn}")
		fi
		if [[ ${M} = TRUE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done <<< "${marks}"
		fi
		if [[ ${L} = TRUE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done < <(grep -Fxvf "${DC_tlt}/practice/log3" \
			"${DC_tlt}/practice/log2" |sort |uniq)
		fi
		if [[ ${D} = TRUE ]]; then
			echo -e "${tpc}" > "$DT/playlck"
			while read item; do _stop=1; getitem; _play
			done < <(sort |uniq "${DC_tlt}/practice/log3")
		fi
    fi
    include "$DS/ifs/mods/chng"
    echo ${_stop} > $DT/playlck

elif [[ ${1} != 0 ]]; then
    source /usr/share/idiomind/default/c.conf
    sz=(560 560); [[ ${swind} = TRUE ]] && sz=(450 420)
    if [ -e "$DT/mn_lk" ]; then
        source "$DS/ifs/cmns.sh"
        msg "$(gettext "Please wait until the current actions are finished")...\n" dialog-information
        exit 1
    fi
    remove_d() {
        source "$DS/ifs/cmns.sh"
        ins="$(cd "/usr/share/idiomind/addons/"; set -- */; printf "%s\n" "${@%/}")"
        old="$(cat "$DC_a/menu_list")"
        while read -r _rm; do
            if [ -n "${_rm}" ]; then
                if [ -d "$DM_tl/${_rm}"/ ]; then
                    ( echo "# $(gettext "Removing") ${_rm}"; sleep 1
                    rm -fr "$DM_tl/${_rm}"/
                    "$DS/mngr.sh" mkmn 0 ) | \
                    progress 'progress'
                fi
            fi
        done < <(grep -Fvx "${ins}" <<< "${old}")
        echo "${ins}" > "$DC_a/menu_list"
    }
    
    if [ ! -e "$DC_a/menu_list" ]; then
        ins="$(cd "/usr/share/idiomind/addons/"; set -- */; printf "%s\n" "${@%/}")"
        echo "${ins}" > "$DC_a/menu_list"
    fi
    
    [ ! -e "$DM_tl/.share/index" ] && > "$DM_tl/.share/index"

    if [[ -n "$1" ]]; then
    var1="--text=$1\n"
    var2="--image=dialog-information"; else
    var1="--center"
    var2="--text-align=right"; fi
    
    chk_list_addons1=$(wc -l < "$DS_a/menu_list")
    chk_list_addons2=$(($(wc -l < "$DC_a/menu_list")*2))
    if [[ ${chk_list_addons1} != ${chk_list_addons2} ]]; then remove_d; fi
    
    chk_list_topics1=$(wc -l < "$DM_tl/.share/index" |sed '/^$/d')
    if [[ $((chk_list_topics1%2)) != 0 ]]; then "$DS/mngr.sh" mkmn 0; fi
    
    if [ -e "$DC_s/topics_first_run" -a -z "${1}" ]; then exit 1; fi

    tpc=$(cat "$DM_tl/.share/index" | \
    yad --list --title="$(gettext "My topics")" "${var1}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-column=2 --separator="" \
    --window-icon=idiomind \
    --text-align=left $var2 --image-on-top \
    --no-headers --ellipsize=END --expand-column=2 \
    --search-column=2 --regex-search --center \
    --width=${sz[0]} --height=${sz[1]} --borders=5 \
    --column=img:IMG \
    --column=File:TEXT \
    --button="!gtk-preferences":"$DS/cnfg.sh" \
    --button="$(gettext "Stats")":"'$DS/ifs/tls.sh' _stats" \
    --button="$(gettext "New")"!document-new:3 \
    --button="$(gettext "Apply")":2 \
    --button="$(gettext "Close")"!window-close:1)
    ret=$?
    if [ $ret -eq 3 ]; then
            "$DS/add.sh" new_topic
    elif [ -n "${tpc}" ]; then
        mode="$(< "$DM_tl/${tpc}/.conf/stts")"
        numer='^[0-9]+$'
        ! [[ ${mode} =~ $num ]] && echo 13 > \
        "$DM_tl/${tpc}/.conf/stts" && mode=13
        if ((mode>=0 && mode<=20)); then
            if [ $ret -eq 2 ]; then
                "$DS/ifs/tpc.sh" "${tpc}" ${mode} 1 &
            elif [ $ret -eq 0 ]; then
                "$DS/ifs/tpc.sh" "${tpc}" ${mode} &
            fi
        fi
    fi
    exit
fi
