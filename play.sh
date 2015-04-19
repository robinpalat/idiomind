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
#  2015/02/27
source /usr/share/idiomind/ifs/c.conf

if [ -z "$tpc" ]; then source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "No topic is active")\n" info & exit 1; fi
#x=$(($(sed -n 2p "$DC_s/10.cfg")/2))
#y=$(($(sed -n 3p "$DC_s/10.cfg")/2))
lbls=('Words' 'Sentences' 'Marks' 'Practice' 'New episodes' 'Saved epidodes')
sets=('grammar' 'list' 'tasks' 'trans' 'text' 'audio' \
'repeat' 'videos' 'loop' 't_lang' 's_lang' 'synth' \
'words' 'sentences' 'marks' 'practice' 'news' 'saved')
in=('in1' 'in2' 'in3' 'in4' 'in5' 'in6')
[ -n "$(< "$DC_s/1.cfg")" ] && cfg=1 || > "$DC_s/1.cfg"

tlng="$DC_tlt/1.cfg"
winx="$DC_tlt/3.cfg"
sinx="$DC_tlt/4.cfg"
if [ "$(wc -l < "$sinx")" -gt 0 ]; then
in1="$(grep -Fxvf "$sinx" "$tlng")"; else
in1="$(< "$tlng")"; fi
if [ "$(wc -l < "$winx")" -gt 0 ]; then
in2="$(grep -Fxvf "$winx" "$tlng")"; else
in2="$(< "$tlng")"; fi
in3="$(< "$DC_tlt/6.cfg")"
cd "$DC_tlt/practice"
in4="$(sed '/^$/d' < w6 | sort | uniq)"
in5="$(tac "$DM_tl/Podcasts/.conf/1.cfg" | sed '/^$/d')"
in6="$(tac "$DM_tl/Podcasts/.conf/2.cfg" | sed '/^$/d')"
[ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

if [ "$cfg" = 1 ]; then

    n=12
    while [[ $n -lt 18 ]]; do
        get="${sets[$n]}"
        val=$(sed -n $((n+1))p < "$DC_s/1.cfg" \
        | grep -o "$get"=\"[^\"]* | grep -o '[^"]*$')
        declare ${sets[$n]}="$val"
        ((n=n+1))
    done
    
else
    n=0
    while [ $n -lt 19 ]; do
        if [ $n -lt 8 ] || [ $n -gt 12 ]; then
        val="FALSE"; else val=" "; fi
        echo -e "${sets[$n]}=\"$val\"" >> "$DC_s/1.cfg"
        ((n=n+1))
    done
fi

function setting_1() {
    n=0; 
    while [ $n -le 5 ]; do
            arr="in$((n+1))"
            [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
            || echo "$DS/images/add.png"
        echo "  <span font_desc='Arial 11'>$(gettext "${lbls[$n]}")</span>"
        echo "${!sets[$((n+12))]}"
        let n++
    done
}

if [ ! -f "$DT/.p_" ]; then
    l="--center"
    btn="Play:0"
    
else
    tpp="$(sed -n 2p "$DT/.p_")"
    l="--center"
    if grep TRUE <<<"$words$sentences$marks$practice"; then
    
        if [ "$tpp" != "$tpc" ]; then
        l="--text=<sup><b>Playing:  $tpp</b></sup>"; fi
    fi
    btn="gtk-media-stop:2"
fi
#--geometry=0x0-$x-$y
slct=$(mktemp "$DT"/slct.XXXX)
setting_1 | yad --list --title="$tpc" "$l" \
--print-all --always-print-result --separator="|" \
--class=Idiomind --name=Idiomind \
--window-icon="$DS/images/icon.png" \
--skip-taskbar --align=right --center --on-top \
--expand-column=2 --no-headers \
--width=340 --height=280 --borders=5 \
--column=IMG:IMG --column=TXT:TXT --column=CHK:CHK \
--button="$btn" \
--button="$(gettext "Close")":1  > "$slct"
ret=$?

if [ "$ret" -eq 0 ]; then

    cd "$DT"; > ./index.m3u; n=12
    
    while [ $n -lt 19 ]; do

        val=$(sed -n $((n-11))p < "$slct" | cut -d "|" -f3) # -f3
        [ -n "$val" ] && sed -i "s/${sets[$n]}=.*/${sets[$n]}=\"$val\"/g" \
        "$DC_s/1.cfg"

        if [ "$val" = TRUE ]; then
            [ -n "${!in[$((n-12))]}" ] && \
            echo "${!in[$((n-12))]}" >> ./index.m3u
        fi
        ((n=n+1))
    done

    rm -f "$slct";
    "$DS/stop.sh" playm
    if [ -d "$DM_tlt" ] && [ -n "$tpc" ]; then
    echo "$DM_tlt" > "$DT/.p_"
    echo "$tpc" >> "$DT/.p_"
    else "$DS/stop.sh" play && exit 1; fi
    
    if [ -z "$(< "$DT/index.m3u")" ]; then
    notify-send "$(gettext "Exiting")" \
    "$(gettext "Nothing specified to play")" -i idiomind -t 3000 &&
    sleep 4
    "$DS/stop.sh" play & exit 1; fi
    
    printf "plyrt.$tpc.plyrt\n" >> "$DC_s/8.cfg" &
    sleep 1
    "$DS/bcle.sh" & exit 0

elif [ "$ret" -eq 2 ]; then

    [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
    "$DS/stop.sh" play
fi

rm -f "$slct" & exit
