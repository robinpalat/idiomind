#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

DT="/tmp/.idmtp1.$USER"
DS="/usr/share/idiomind"
DC_s="$HOME/.config/idiomind/s"
source "$DS/ifs/mods/cmns.sh"
f=0

if [[ "$1" = chngi ]]; then

    w="$(grep -oP '(?<=words=\").*(?=\")' "$DC_s/1.cfg")"
    s="$(grep -oP '(?<=sntcs=\").*(?=\")' "$DC_s/1.cfg")"
    m="$(grep -oP '(?<=marks=\").*(?=\")' "$DC_s/1.cfg")"
    p="$(grep -oP '(?<=wprct=\").*(?=\")' "$DC_s/1.cfg")"
    export v="$(grep -oP '(?<=video=\").*(?=\")' "$DC_s/1.cfg")"
    export ne="$(grep -oP '(?<=nsepi=\").*(?=\")' "$DC_s/1.cfg")"
    export se="$(grep -oP '(?<=svepi=\").*(?=\")' "$DC_s/1.cfg")"
    
    _play() {
		
		a="$(grep -oP '(?<=audio=\").*(?=\")' "$DC_s/1.cfg")"
		n="$(grep -oP '(?<=ntosd=\").*(?=\")' "$DC_s/1.cfg")"
		l="$(grep -oP '(?<=loop=\").*(?=\")' "$DC_s/1.cfg")"
		if [[ ${n} != TRUE ]] && [[ ${a} != TRUE ]]; then audio=TRUE; fi
		nu='^[0-9]+$'; if ! [[ $l =~ $nu ]]; then l=1; fi
        
        if [ ${n} = TRUE ]; then
        notify-send -i "${icon}" "${trgt}" "${srce}" -t 10000; fi &
        
        if [ ${a} = TRUE ]; then
        "${play}" "${file}" && wait; fi
        
        if [ ${n} = TRUE ] && [[ ${l} -lt 11 ]]; then l=11; fi
        
        sleep ${l}
    }
    export -f _play
    
    getitem() {
        
        if [ ${f} -gt 5 ] || [ ! -d "${DM_tlt}" ]; then
        msg "$(gettext "An error has occurred. Playback stopped")" info &
        "$DS/stop.sh" 2; fi
        
        if [ -n "${item}" ]; then
        unset file
        _item="$(grep -F -m 1 "trgt={${item}}" "$DC_tlt/0.cfg" |sed 's/},/}\n/g')"
        type="$(grep -oP '(?<=type={).*(?=})' <<<"${_item}")"
        trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${_item}")"
        srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${_item}")"
        id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${_item}")"
        img="${DM_tlt}/images/$id.jpg"; [ -f "$img" ] && icon="$img"
        [ -z "$trgt" ] && trgt="$item"
        [[ ${type} = 1 ]] && file="$DM_tls/${trgt,,}.mp3"
        [[ ${type} = 2 ]] && file="$DM_tlt/$id.mp3"
        play=play
        else ((f=f+1)); fi
    }
    
    if [ ${w} = TRUE -a ${s} = TRUE ]; then
    while read item; do getitem; _play
    done < "$DC_tlt/1.cfg"; fi
    
    if [ ${w} = TRUE -a ${s} = FALSE ]; then
    while read item; do getitem; _play
    done < "$DC_tlt/3.cfg"; fi
    
    if [ ${w} = FALSE -a ${s} = TRUE ]; then
    while read item; do getitem; _play
    done < "$DC_tlt/4.cfg"; fi
    
    if [ ${m} = TRUE ]; then
    while read item; do getitem; _play
    done < "$DC_tlt/6.cfg"; fi
    
    if [ ${p} = TRUE ]; then
    while read item; do getitem; _play
    done < <(grep -Fxv "$cfg4" "$DC_tlt/practice/log.3"); fi
    
    include "$DS/ifs/mods/play"

elif [[ "$1" != chngi ]]; then

    source /usr/share/idiomind/ifs/c.conf
    [ ! -f "$DC_s/0.cfg" ] && > "$DC_s/0.cfg"
    lgs=$(lnglss $lgsl)
    
    if [ -n "$1" ]; then
    text="--text=$1\n"; align="left"; img="--image=info"
    else
    text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/${lgtl,,}'>$(gettext "Shared")</a>   </small></small>"; align="right"
    fi
    
    if [ -f "${DC_tlt}/1.cfg" ] && \
    [[ $((`wc -l < "$DC_s/0.cfg"`/3)) = `wc -l < "${DC_tlt}/1.cfg"` ]]; then
    "$DS/mngr.sh" mkmn; fi

    tpc=$(cat "$DC_s/0.cfg" | \
    yad --list --title="$(gettext "Topics")" "$text" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-column=2 --separator="" \
    --window-icon="$DS/images/icon.png" \
    --text-align=$align --center $img --image-on-top \
    --no-headers --ellipsize=END --expand-column=2 --tooltip-column=3 \
    --width=600 --height=560 --borders=8 \
    --column=img:IMG \
    --column=File:TEXT \
    --column=File:HD \
    --button=gtk-new:3 \
    --button="$(gettext "Default")":5 \
    --button="$(gettext "Apply")":2 \
    --button="$(gettext "Close")":1)
    ret=$?
    
    if [[ $ret -eq 3 ]]; then
    
            "$DS/add.sh" new_topic & exit
            
    elif [[ $ret -eq 2 ]]; then
            
            if [ -z "$tpc" ]; then exit 1

            else
                "$DS/default/tpc.sh" "$tpc" 1 & exit
            fi

    elif [[ $ret -eq 0 ]]; then
            
            if [ -z "$tpc" ]; then exit 1

            else
                "$DS/default/tpc.sh" "$tpc" & exit
            fi
            
    elif [[ $ret -eq 5 ]]; then
            
            if [ -z "$tpc" ]; then exit 1

            else
                echo "$tpc" > "$DM_tl"/.5.cfg
                "$DS/default/tpc.sh" "$tpc" &
                "$DS/mngr.sh" mkmn & exit
            fi
    fi
fi

exit
