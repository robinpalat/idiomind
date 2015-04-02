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

[ -z "$tpc" ] && exit 1
source "$DC_s/1.cfg"
lbls=(' ' 'Words' 'Sentences' 'Marks' 'Practice' 'News episodes' 'Saved epidodes')
sets=(' ' 'words' 'sentences' 'marks' 'practice' 'news' 'saved')
in=(' ' 'in1' 'in2' 'in3' 'in4' 'in5' 'in6')
tlng="$DC_tlt/1.cfg"
winx="$DC_tlt/3.cfg"
sinx="$DC_tlt/4.cfg"
if [ "$(wc -l < "$sinx")" -gt 0 ]; then
in1=$(grep -Fxvf "$sinx" "$tlng"); else
in1=$(< "$tlng"); fi
if [ "$(wc -l < "$winx")" -gt 0 ]; then
in2=$(grep -Fxvf "$winx" "$tlng"); else
in2=$(< "$tlng"); fi
in3=$(< "$DC_tlt/6.cfg")
cd "$DC_tlt/practice"
in4=$(sed '/^$/d' < w6 | sort | uniq)
in5=$(tac "$DM_tl/Feeds/.conf/1.cfg" | sed '/^$/d')
in6=$(tac "$DM_tl/Feeds/.conf/2.cfg" | sed '/^$/d')
[ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

function setting_1() {
    n=1
    while [ $n -le 6 ]; do
            arr="in$n"
            [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
            || echo "$DS/images/add.png"
        echo "  <span color='#646D72' font_desc='Verdana 11'>$(gettext "${lbls[$n]}")</span><i></i>"
        echo "${!sets[$n]}"
        let n++
    done
}

if [ ! -f "$DT/.p_" ]; then
l="--center"
btn="Play:0"; else
tpp="$(sed -n 2p "$DT/.p_")"
if grep TRUE <<<"$words$sentences$marks$practice"; then
[ "$tpp" != "$tpc" ] && \
l="--text=<sup><b>Playing:  \"$tpp\"</b></sup>" || \
l="--center"; fi
btn="gtk-media-stop:2"; fi
slct=$(mktemp "$DT"/slct.XXXX)

setting_1 | yad --list --separator="|" --on-top \
--expand-column=2 --print-all --no-headers --center \
--class=Idiomind --name=Idiomind --align=right \
--width=380 --height=310 --title="$tpc" "$l" \
--window-icon="$DS/images/logo.png" --borders=5 --always-print-result \
--column=IMG:IMG --column=TXT:TXT --column=CHK:CHK \
--button="$btn" --button="$(gettext "Close")":1 --skip-taskbar > "$slct"
ret=$?

if [ "$ret" -eq 0 ]; then

    cd "$DT"; > ./index.m3u; n=1
    while [ $n -le 6 ]; do
        val=$(sed -n "$n"p < "$slct" | cut -d "|" -f3)
        sed -i "s/${sets[$n]}=.*/${sets[$n]}=$val/g" "$DC_s/1.cfg"
        if [ "$val" = TRUE ]; then
            [ -n "${!in[$n]}" ] && echo "${!in[$n]}" >> ./index.m3u
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
        "$DS/stop.sh" play & exit 1
    fi
    
    printf "plyrt.$tpc.plyrt\n" >> "$DC_s/8.cfg" &
    sleep 1
    "$DS/bcle.sh" & exit 0

elif [ "$ret" -eq 2 ]; then

    rm -f "$slct"
    [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
    "$DS/stop.sh" play & exit
    
else
    rm -f "$slct"
    exit 1
fi
