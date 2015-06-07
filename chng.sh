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
loop=$(sed -n 10p "$DC_s/1.cfg" |grep -o loop=\"[^\"]* | grep -o '[^"]*$')
text=$(sed -n 6p "$DC_s/1.cfg" |grep -o text=\"[^\"]* | grep -o '[^"]*$')
audio=$(sed -n 7p "$DC_s/1.cfg" |grep -o audio=\"[^\"]* | grep -o '[^"]*$')
if [[ "$text" != TRUE ]] && [[ "$audio" != TRUE ]]; then audio=TRUE; fi
nu='^[0-9]+$'; if ! [[ $loop =~ $nu ]]; then loop=1; fi

if [[ "$1" = chngi ]]; then
    
    stop_loop() {
    if [[ ! -f "$1" ]]; then
    echo "___" >> "$DT/.l_loop"
    if [[ `wc -l < "$DT/.l_loop"` -gt 5 ]]; then
    rm -f "$DT/.p_"  "$DT/.l_loop" &
    msg "$(gettext "An error has occurred. Playback stopped")" error &
    "$DS/stop.sh" 2 & exit 1; fi
    fi
    }
    DM_tlt="$(sed -n 1p "$DT/.p_")"
    index="$DT/index.m3u"
    _item="$(sed -n "$2"p "$index")"
    if [[ -f "$DT/.p" ]]; then
    echo $(($2+2)) > "$DT/.p"
    "$DS/stop.sh" 8 & exit 1; fi
    
    fname="$(echo -n "{$_item}" | md5sum | rev | cut -c 4- | rev)"
    [[ -f "${DM_tlt}/$fname.mp3" ]] && file="${DM_tlt}/$fname.mp3" && t=2
    [[ -f "${DM_tlt}/words/$fname.mp3" ]] && file="${DM_tlt}/words/$fname.mp3" && t=1
    include "$DS/ifs/mods/play"
    stop_loop "$file"
    
    if [[ "$t" = 2 ]]; then
    tags=$(eyeD3 "$file") 
    trgt=$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")
    srce=$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")
    play=play
    
    elif [[ "$t" = 1 ]]; then
    tags=$(eyeD3 "$file")
    trgt=$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"$tags")
    srce=$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tags")
    play=play
    fi

    [[ -z "$trgt" ]] && trgt="$_item"
    img="${DM_tlt}/words/images/$fname.jpg"
    [ -f "$img" ] && icon="$img"
            
    if [[ "$text" = "TRUE" ]]; then
    notify-send -i "$icon" "$trgt" "$srce" -t 10000; fi &
    
    if [[ "$audio" = "TRUE" ]]; then
    "$play" "$file" && wait; fi
    
    if [[ "$text" = "TRUE" ]] && [[ $loop -lt 11 ]]; then loop=11; fi
    sleep "$loop"
    
    [[ -f "$DT/.l_loop" ]] && rm -f "$DT/.l_loop"
        

elif [[ "$1" != chngi ]]; then

    source /usr/share/idiomind/ifs/c.conf
    [ ! -f "$DC_s/0.cfg" ] && > "$DC_s/0.cfg"
    lgs=$(lnglss $lgsl)
    
    if [ -n "$1" ]; then
    text="--text=$1\n"
    align="left"
    img="--image=info"
    else
    text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/${lgtl,,}'>$(gettext "Shared")</a>   </small></small>"
    align="right"; fi
    
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
    fi
fi

exit
