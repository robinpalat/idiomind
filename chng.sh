#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ ${1} = 0 ]]; then

    w="$(grep -oP '(?<=words=\").*(?=\")' "${cfg}")"
    s="$(grep -oP '(?<=sntcs=\").*(?=\")' "${cfg}")"
    m="$(grep -oP '(?<=marks=\").*(?=\")' "${cfg}")"
    p="$(grep -oP '(?<=wprct=\").*(?=\")' "${cfg}")"
    export v="$(grep -oP '(?<=video=\").*(?=\")' "${cfgp}")"
    export ne="$(grep -oP '(?<=nsepi=\").*(?=\")' "${cfgp}")"
    export se="$(grep -oP '(?<=svepi=\").*(?=\")' "${cfgp}")"
    
    _play() {
        
        a="$(grep -oP '(?<=audio=\").*(?=\")' "${cfg}")"
        n="$(grep -oP '(?<=ntosd=\").*(?=\")' "${cfg}")"
        l="$(grep -oP '(?<=loop=\").*(?=\")' "${cfg}")"
        rw="$(grep -oP '(?<=rword=\").*(?=\")' "${cfg}")"
        [ ! -f "$DT"/.p_ ] && > "$DT"/.p_

        if [ ${n} != TRUE -a ${a} != TRUE -a ${stnrd} = 1 ]; then "$DS"/stop.sh 2 & exit 1; fi
        if ! grep TRUE <<<"$n$w$s$m$p$ne$se">/dev/null 2>&1; then "$DS"/stop.sh 2 & exit 1; fi
        if ! [[ ${l} =~ $nu ]]; then l=1; fi
        if ! [[ ${rw} =~ $nu ]]; then rw=0; fi
        
        if [ ${stnrd} = 1 ]; then
        
            if [ ${n} = TRUE ]; then
            notify-send -i "${icon}" "${trgt}" "${srce}" -t 10000; fi &
            if [ ${a} = TRUE ]; then sleep 0.5
            if [ ${type} = 1 -a ${rw} = 0 ]; then spn=3; else spn=1; fi
            ( while [ ${ritem} -lt ${spn} ]; do
            "$DS"/play.sh play_file "${file}" "${trgt}"
            [ ${ritem} = 0 ] && sleep 0.5
            [ ${ritem} = 1 ] && sleep 2.5
            [ ${ritem} = 2 ] && sleep 2
            let ritem++
            done )
            fi
            
        else
            notify-send -i "${icon}" "${trgt}" "${srce}" -t 10000 &
            sleep 1 && "$DS"/play.sh play_file "${file}" "${trgt}"
        fi
        
        if [ ${n} = TRUE -a ${l} -lt 11 -a ${type} -lt 3 ]; then l=11; fi
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
        trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${_item}")"
        srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${_item}")"
        id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${_item}")"
        img="${DM_tls}/images/${trgt,,}-0.jpg"; [ -f "$img" ] && icon="$img"
        [ -z "$trgt" ] && trgt="$item"
        
        if [ -f "${DM_tlt}/$id.mp3" ]; then
        file="${DM_tlt}/$id.mp3"; else
        file="${DM_tls}/${trgt,,}.mp3"; fi
        
        stnrd=1
        else ((f=f+1)); fi
    }
    
    if [ ${w} = TRUE -a ${s} = TRUE ]; then
    while read item; do getitem; _play
    done < <(tac "${DC_tlt}/1.cfg"); fi
    
    if [ ${w} = TRUE -a ${s} = FALSE ]; then
    while read item; do getitem; _play
    done < <(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/1.cfg" |tac); fi

    if [ ${w} = FALSE -a ${s} = TRUE ]; then
    while read item; do getitem; _play
    done < <(grep -Fxvf "${DC_tlt}/3.cfg" "${DC_tlt}/1.cfg" |tac); fi
    
    if [ ${m} = TRUE ]; then
    while read item; do getitem; _play
    done < "${DC_tlt}/6.cfg"; fi
    
    if [ ${p} = TRUE ]; then
    while read item; do getitem; _play
    done < <(grep -Fxv "${DC_tlt}/4.cfg" "${DC_tlt}/practice/log.3"); fi
    
    include "$DS/ifs/mods/play"

elif [[ ${1} != 0 ]]; then

    source /usr/share/idiomind/ifs/c.conf
    source "$DS/ifs/mods/cmns.sh"
    [ ! -f "$DM_tl/.0.cfg" ] && > "$DM_tl/.0.cfg"
    [ ! -f "$DM_tl/.1.cfg" ] && > "$DM_tl/.1.cfg"
    lgs=$(lnglss $lgsl)
    
    if [ -n "$1" ]; then
    text="--text=$1\n"
    align="left"
    img="--image=info"
    else
    text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/${lgtl,,}'>$(gettext "Shared")</a>   </small></small>"
    align="right"
    fi
    
    if [[ $((`wc -l < "$DM_tl/.0.cfg"`/2)) != `wc -l < "$DM_tl/.1.cfg"` ]]; then
    "$DS/mngr.sh" mkmn; fi

    tpc=$(cat "$DM_tl/.0.cfg" | \
    yad --list --title="$(gettext "Topics")" "$text" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-column=2 --separator="" \
    --window-icon="$DS/images/icon.png" \
    --text-align=$align --center $img --image-on-top \
    --no-headers --ellipsize=END --expand-column=2 \
    --width=620 --height=580 --borders=8 \
    --column=img:IMG \
    --column=File:TEXT \
    --button=gtk-new:3 \
    --button="$(gettext "Default")":5 \
    --button="$(gettext "Apply")":2 \
    --button="gtk-close":1)
    ret=$?

    if [ $ret -eq 3 ]; then "$DS/add.sh" new_topic &
            
    elif [ $ret -eq 2 ]; then "$DS/default/tpc.sh" "$tpc" 1 &

    elif [ $ret -eq 0 ]; then "$DS/default/tpc.sh" "$tpc" &

    elif [ $ret -eq 5 ]; then "$DS/default/tpc.sh" "$tpc" &
    [ -n "${tpc}" ] && echo "${tpc}" > "$DM_tl"/.5.cfg
    
    fi
    exit
fi
