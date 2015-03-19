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

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

if [ "$1" = chngi ]; then

    function stop_bcl() {
    
    if [ ! -f "$1" ]; then
        echo "___" >> "$DT/.l_bcl"
        if [ $(cat "$DT/.l_bcl" | wc -l) -gt 5 ]; then
            rm -f "$DT/.p_"  "$DT/.l_bcl" &
            "$DS/stop.sh" play & exit 1
        fi
    fi
    }
    
    nta=$(sed -n 9p "$DC_s/1.cfg")
    sna=$(sed -n 10p "$DC_s/1.cfg")
    index="$DT/index"
    bcl=$(sed -n 17p "$DC_s/1.cfg")
    item="$(sed -n "$2"p "$index")"
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
    
    [ -f "$DM_tlt/$fname.mp3" ] && file="$DM_tlt/$fname.mp3" && t=2
    [ -f "$DM_tlt/words/$fname.mp3" ] && file="$DM_tlt/words/$fname.mp3" && t=1

    include "$DS/ifs/mods/play"
    
    stop_bcl "$file"
    
    if [ "$t" = 2 ]; then
        tgs=$(eyeD3 "$file")
        trgt=$(echo "$tgs" | \
        grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
        srce=$(echo "$tgs" | \
        grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
        play=play
    
    elif [ "$t" = 1 ]; then
        if ([ $(echo "$nta" | grep "TRUE") ] \
        && [ "$bcl" -lt 12 ]); then bcl=12; fi
        tgs=$(eyeD3 "$file")
        trgt=$(echo "$tgs" | \
        grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        srce=$(echo "$tgs" | \
        grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
        play=play
    fi

    [ -z "$trgt" ] && trgt="$item"
    imgt="$DM_tlt/words/images/$fname.jpg"
    [ -f "$imgt" ] && osdi="$imgt" || osdi=idiomind
    if echo "$nta" | grep "TRUE"; then
        (notify-send -i "$osdi" "$trgt" "$srce" -t 10000 && sleep 0.5); fi &
    if echo "$sna" | grep "TRUE"; then
        "$play" "$file" && wait; fi
    
    sleep "$bcl"
    [ -f "$DT/.l_bcl" ] && rm -f "$DT/.l_bcl"
        

elif [ "$1" != chngi ]; then
    
    lgs=$(lnglss $lgsl)
    [ ! -f "$DC_s/0.cfg" ] && > "$DC_s/0.cfg"
    wth=$(($(sed -n 2p $DC_s/10.cfg)-350))
    eht=$(($(sed -n 3p $DC_s/10.cfg)-0))
    
    if [ -n "$1" ]; then
        text="--text=<small>$1\n</small>"
        align="left"; h=1
        img="--image=info"
    else
        lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
        text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/$lgtl'>$(gettext "Search other topics")</a>   </small></small>"
        align="right"
    fi
    
    s=$(cat "$DC_s/0.cfg" | yad --name=Idiomind --text-align=$align \
    --center $img --image-on-top --separator="" --class=Idiomind \
    "$text" --width="$wth" --height="$eht" --ellipsize=END \
    --no-headers --list --window-icon=idiomind --borders=5 \
    --button=gtk-new:3 --button=gtk-apply:2 --button=gtk-close:1 \
    --title="$(gettext "Topics")" --column=img:img --column=File:TEXT)
    ret=$?
        
    if [ $ret -eq 3 ]; then
    
            "$DS/add.sh" new_topic & exit
            
    elif [ $ret -eq 2 ]; then
    
            "$DS/stop.sh" play &
            
            [ -z "$s" ] && exit 1
            
            if [ -f "$DM_tl/$s/tpc.sh" ]; then
                if [ "$s" != "Feeds" ]; then
                cp -f "$DS/default/tpc.sh" "$DM_tl/$s/tpc.sh"
                fi
                "$DM_tl/$s/tpc.sh" 1 & exit
            else
                cp -f "$DS/default/tpc.sh" "$DM_tl/$s/tpc.sh"
                "$DM_tl/$s/tpc.sh" 1 & exit
            fi

    elif [ $ret -eq 0 ]; then
    
            "$DS/stop.sh" play &
            
            [ -z "$s" ] && exit 1
            
            if [ -f "$DM_tl/$s/tpc.sh" ]; then
                if [ "$s" != "Feeds" ]; then
                cp -f "$DS/default/tpc.sh" "$DM_tl/$s/tpc.sh"
                fi
                "$DM_tl/$s/tpc.sh" & exit
            else
                cp -f "$DS/default/tpc.sh" "$DM_tl/$s/tpc.sh"
                "$DM_tl/$s/tpc.sh" & exit
            fi
    else
        exit 1
    fi
fi
