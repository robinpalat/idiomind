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
in5=$(sed '/^$/d' < "$DM_tl/Feeds/.conf/1.cfg")
in6=$(sed '/^$/d' < "$DM_tl/Feeds/.conf/2.cfg")
[ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

function setting_1() {
    n=1
    while [ $n -le 6 ]; do
            arr="in$n"
            [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
            || echo "$DS/images/add.png"
        echo "  <span font_desc='Verdana 10'>$(gettext "${lbls[$n]}")</span><i></i>"
        echo "${!sets[$n]}"
        let n++
    done
}

if [ ! -f "$DT/.p_" ]; then
btn="Play:0"; else btn="gtk-media-stop:2"; fi
#--text="<span background='#505050'>\t\t\t\t\t</span>" \
slct=$(mktemp "$DT"/slct.XXXX)
setting_1 | yad --list --separator="|" --on-top \
--expand-column=2 --print-all --no-headers --center \
--class=Idiomind --name=Idiomind --align=right \
--width=380 --height=310 --title="$(gettext "Playlist")" \
--window-icon=idiomind --borders=5 --always-print-result \
--column=IMG:IMG --column=TXT:TXT --column=CHK:CHK \
--button="Cancel":1 --button="$btn" --skip-taskbar > "$slct"
ret=$?

if [ "$ret" -eq 0 ]; then

    cd "$DT"; > ./index; n=1
    while [ $n -le 6 ]; do
        val=$(sed -n "$n"p < "$slct" | cut -d "|" -f3)
        sed -i "s/${sets[$n]}=.*/${sets[$n]}=$val/g" "$DC_s/1.cfg"
        if [ "$val" = TRUE ]; then
            [ -n "${!in[$n]}" ] && echo "${!in[$n]}" >> ./index
        fi
        ((n=n+1))
    done

    rm -f "$slct"; 
    "$DS/stop.sh" playm
    source "$DC_s/1.cfg"
    
    if [ -z "$(< "$DT/index")" ]; then
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
