#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ ${1} = 0 ]]; then
    w="$(grep -oP '(?<=words=\").*(?=\")' "${cfg}")"
    s="$(grep -oP '(?<=sntcs=\").*(?=\")' "${cfg}")"
    m="$(grep -oP '(?<=marks=\").*(?=\")' "${cfg}")"
    p="$(grep -oP '(?<=wprct=\").*(?=\")' "${cfg}")"
    _play() {
        if [ ${stnrd} = 1 ]; then
            a="$(grep -oP '(?<=audio=\").*(?=\")' "${cfg}")"
            n="$(grep -oP '(?<=ntosd=\").*(?=\")' "${cfg}")"
            l="$(grep -oP '(?<=loop=\").*(?=\")' "${cfg}")"
            rw="$(grep -oP '(?<=rword=\").*(?=\")' "${cfg}")"
            [ ! -f "$DT"/.p_ ] && > "$DT"/.p_

            if [ ${n} != TRUE -a ${a} != TRUE -a ${stnrd} = 1 ]; then a=TRUE; fi
            if ! grep TRUE <<<"$n$w$s$m$p$ne$se">/dev/null 2>&1; then
            "$DS"/stop.sh 2 & exit 1; fi
            if ! [[ ${l} =~ $numer ]]; then l=1; fi
            if ! [[ ${rw} =~ $numer ]]; then rw=0; fi

            if [ ${n} = TRUE ]; then
                ! [ ps -A |pgrep -f "notify-osd" ] && \
                notify-send -i "${icon}" "${trgt}" "${srce}"; fi &
            if [ ${a} = TRUE ]; then sleep 0.5; sle=0.5; spn=1
                [ ${type} = 1 -a ${rw} = 1 ] && spn=3
                [ ${type} = 2 -a ${rw} = 2 ] && spn=2 && sle=2.5
                ( while [ ${ritem} -lt ${spn} ]; do
                    "$DS"/play.sh play_file "${file}" "${trgt}"
                    [ ${ritem} = 0 ] && sleep ${sle}
                    [ ${ritem} = 1 ] && sleep 2.5
                    [ ${ritem} = 2 ] && sleep 2
                    let ritem++
                done )
            fi
        else
            notify-send -i "${icon}" "${trgt}" "${srce}" -t 10000 &
            "$DS"/play.sh play_file "${file}" "${trgt}"
        fi
        [ ${n} = TRUE -a ${l} -lt 3 -a ${type} = 1 ] && l=3
        [ ${n} = TRUE -a ${l} -lt 10 -a ${type} = 2 ] && l=10
        [ ${stnrd} = 1 ] && sleep ${l}
    }
    export -f _play
    
    getitem() {
        if [ ${f} -gt 5 -o ! -d "${DM_tlt}" ]; then
            msg "$(gettext "An error has occurred. Playback stopped")" info &
            "$DS"/stop.sh 2; fi
        [ -f "$DT/list.m3u" ] && rm -f "$DT/list.m3u"
            
        if [ -n "${item}" ]; then
            unset file icon
            _item="$(grep -F -m 1 "trgt={${item}}" "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
            type="$(grep -oP '(?<=type={).*(?=})' <<<"${_item}")"
            export trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${_item}")"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${_item}")"
            id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${_item}")"
            img="${DM_tls}/images/${trgt,,}-0.jpg"; [ -f "$img" ] && icon="$img"
            [ -z "$trgt" ] && trgt="$item"
            
            if [ -f "${DM_tlt}/$id.mp3" ]; then
                file="${DM_tlt}/$id.mp3"
            else
                file="${DM_tls}/audio/${trgt,,}.mp3"; fi
            stnrd=1
        else
            ((f=f+1))
        fi
    }
    if [ ${w} = TRUE -a ${s} = TRUE ]; then
        echo "${tpc}" > "$DT/.p_"
        while read item; do getitem; _play
        done < <(tac "${DC_tlt}/1.cfg"); fi
    if [ ${w} = TRUE -a ${s} = FALSE ]; then
        echo "${tpc}" > "$DT/.p_"
        while read item; do getitem; _play
        done < <(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/1.cfg" |tac); fi
    if [ ${w} = FALSE -a ${s} = TRUE ]; then
        echo "${tpc}" > "$DT/.p_"
        while read item; do getitem; _play
        done < <(grep -Fxvf "${DC_tlt}/3.cfg" "${DC_tlt}/1.cfg" |tac); fi
    if [ ${m} = TRUE ]; then
        echo "${tpc}" > "$DT/.p_"
        while read item; do getitem; _play
        done < "${DC_tlt}/6.cfg"; fi
    if [ ${p} = TRUE ]; then
        echo "${tpc}" > "$DT/.p_"
        while read item; do getitem; _play
        done < <(grep -Fxv "${DC_tlt}/4.cfg" "${DC_tlt}/practice/log3"); fi
    include "$DS/ifs/mods/chng"

elif [[ ${1} != 0 ]]; then
    source /usr/share/idiomind/default/c.conf
    if [ ! -d "$DT" ]; then
        ( "$DS/ifs/tls.sh" a_check_updates ) &
        idiomind -s; sleep 1
    fi
    linkc="http://community.idiomind.net/${lgtl,,}"
    remove_d() {
        ins="$(cd "/usr/share/idiomind/addons/"
        set -- */; printf "%s\n" "${@%/}")"
        old="$(cat "$DC_a/list")"
        set -e
        while read -r _rm; do
            if [ -n "${_rm}" ]; then
                if [ -d "$DM_tl/${_rm}" ]; then
                ( echo "5"; sleep 1; rm -fr "$DM_tl/${_rm}"; "$DS/mngr.sh" mkmn ) \
                | progress "$(gettext "Removing") ${_rm}"
                fi
            fi
        done < <(grep -Fvx "${ins}" <<<"${old}")
        echo "$ins" > "$DC_a/list"
    }
    if [ ! -e "$DM_tl/.0.cfg" ]; then > "$DM_tl/.0.cfg"; fi
    if [ ! -e "$DM_tl/.1.cfg" ]; then > "$DM_tl/.1.cfg"; fi
    if [ ! -e "$DC_a/list" ]; then
        echo "$(cd "/usr/share/idiomind/addons/"
        set -- */; printf "%s\n" "${@%/}")" > "$DC_a/list"
    fi
    if [[ -n "$1" ]]; then
    var1="--text=$1\n"
    var2="--image=info"; else
    #var1="--text=<small><a href='$linkc'>$(gettext "Shared")</a> </small>"
    var1="--center"
    var2="--text-align=right"; fi
    chk_list_addons1=$(wc -l < "$DS_a/menu_list")
    chk_list_addons2=$((`wc -l < "$DC_a/list"`*2))
    chk_list_topics1=$((`wc -l < "$DM_tl/.0.cfg"`/2))
    chk_list_topics2=$(wc -l < "$DM_tl/.1.cfg")
    if [[ ${chk_list_addons1} != ${chk_list_addons2} ]]; then remove_d; fi
    if [[ ${chk_list_topics1} != ${chk_list_topics2} ]]; then "$DS/mngr.sh" mkmn; fi
    if [ -e "$DC_s/topics_first_run" -a -z "${1}" ]; then exit 1; fi

    tpc=$(cat "$DM_tl/.0.cfg" | \
    yad --list --title="$(gettext "Topics")" "$var1" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-column=2 --separator="" \
    --window-icon=idiomind \
    --text-align=left --center $var2 --image-on-top \
    --no-headers --ellipsize=END --expand-column=2 \
    --search-column=2 --regex-search \
    --width=620 --height=580 --borders=8 \
    --column=img:IMG \
    --column=File:TEXT \
    --button="<small>$(gettext "New Words")</small>":"$DS/ifs/mods/topic/Dictionary.sh" \
    --button="$(gettext "New")"!gtk-new:3 \
    --button="$(gettext "Apply")":2 \
    --button="$(gettext "Close")"!gtk-close:1)
    ret=$?
    if [ $ret -eq 3 ]; then
            "$DS/add.sh" new_topic
    elif [ -n "${tpc}" ]; then
        mode="$(< "$DM_tl/${tpc}/.conf/8.cfg")"
        if ((mode>=0 && mode<=20)); then
            if [ $ret -eq 2 ]; then
                "$DS/default/tpc.sh" "$tpc" ${mode} 1 &
            elif [ $ret -eq 0 ]; then
                "$DS/default/tpc.sh" "$tpc" ${mode} &
            fi
        fi
    fi
    exit
fi
