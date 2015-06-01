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
DSP="$DS/practice"
easys="$2"
learning="$3"
[[ "$4" -lt 0 ]] && hards=0 || hards="$4"
[ ! -d "$DC_tlt/practice" ] \
&& mkdir "$DC_tlt/practice"
cd "$DC_tlt/practice"
[ ! -f .icon1 ] && echo 1 > .icon1
[ ! -f .icon2 ] && echo 1 > .icon2
[ ! -f .icon3 ] && echo 1 > .icon3
[ ! -f .icon4 ] && echo 1 > .icon4
[ ! -f .icon5 ] && echo 1 > .icon5

if [[ -n "$1" ]]; then

    if [ "$1" = 1 ]; then
        info1="* "; info6="<b>$(gettext "Test completed!")</b>"
        echo 21 > .icon1
    elif [ "$1" = 2 ]; then
        info2="* "; info7="<b>$(gettext "Test completed!")</b>"
        echo 21 > .icon2
    elif [ "$1" = 3 ]; then
        info3="* "; info8="<b>$(gettext "Test completed!")</b>"
        echo 21 > .icon3
    elif [ "$1" = 4 ]; then
        info4="* "; info9="<b>$(gettext "Test completed!")</b>"
        echo 21 > .icon4
    elif [ "$1" = 5 ]; then
        info5="* "; info10="<b>$(gettext "Test completed!")</b>"
        echo 21 > .icon5
    elif [ "$1" = 6 ]; then
        learned=$(< ./l_f)
        num=$(< ./.icon1)
        info1="* "
        info="  <b><big>$learned </big></b><small>$(gettext "Learned")</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$(gettext "Easy")</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$(gettext "Learning")</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$(gettext "Difficult")</small>  \\n"
    elif [ $1 = 7 ]; then
        learned=$(< ./l_m)
        num=$(< ./.icon2)
        info2="* "
        info="  <b><big>$learned </big></b><small>$(gettext "Learned")</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$(gettext "Easy")</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$(gettext "Learning")</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$(gettext "Difficult")</small>  \\n"
    elif [ $1 = 8 ]; then
        learned=$(< ./l_w)
        num=$(< ./.icon3)
        info3="* "
        info="  <b><big>$learned </big></b><small>$(gettext "Learned")</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$(gettext "Easy")</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$(gettext "Learning")</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$(gettext "Difficult")</small>  \\n"
    elif [ $1 = 9 ]; then
        learned=$(< ./l_s)
        num=$(< ./.icon4)
        info4="* "
        info="  <b><big>$learned </big></b><small>$(gettext "Learned")</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$(gettext "Easy")</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$(gettext "Learning")</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$(gettext "Difficult")</small>  \\n"
    elif [ $1 = 10 ]; then
        learned=$(< ./l_i)
        num=$(< ./.icon5)
        info5="* "
        info="  <b><big>$learned </big></b><small>$(gettext "Learned")</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$(gettext "Easy")</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$(gettext "Learning")</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$(gettext "Difficult")</small>  \\n"
    fi
fi



writing sentences

img1="$DSP/icons_st/$(< ./.icon1).png"
img2="$DSP/icons_st/$(< ./.icon2).png"
img3="$DSP/icons_st/$(< ./.icon3).png"
img4="$DSP/icons_st/$(< ./.icon4).png"
img5="$DSP/icons_st/$(< ./.icon5).png"

VAR="$(yad --list --title="$(gettext "Practice ")- $tpc" \
$img --text="$info" \
--class=Idiomind --name=Idiomind \
--print-column=1 --separator="" \
--window-icon="$DS/images/icon.png" \
--buttons-layout=edge --image-on-top --center --on-top --text-align=center \
--ellipsize=NONE --no-headers --expand-column=2 --hide-column=1 \
--width=500 --height=450 --borders=10 \
--column="Action" --column="Pick":IMG --column="Label" \
1 $img1 "    $info1 $info6   $(gettext "Flashcards")" \
2 $img2 "    $info2 $info7   $(gettext "Multiple Choice")" \
3 $img3 "    $info3 $info8   $(gettext "Recognizing Words")" \
4 $img4 "    $info4 $info9   $(gettext "Writing Sentences")" \
5 $img5 "    $info5 $info10   $(gettext "Images")" \
--button="$(gettext "Restart")":3 \
--button="$(gettext "Start")":0)"
ret=$?

if [[ $ret -eq 0 ]]; then

    if [ -z "$VAR" ]; then
    source "$DS/ifs/mods/cmns.sh"
    msg " $(gettext "You must choose a practice.")\n" info
    "$DSP/strt.sh" & exit 1
    else
    printf "prct.shc.$tpc.prct.shc\n" >> "$DC_s/8.cfg" &
    "$DSP/prct.sh" "$VAR" & exit 1
    fi

elif [[ $ret -eq 3 ]]; then
    if [ -d "$DC_tlt/practice" ]; then
    cd "$DC_tlt/practice"
    rm .*; rm *; fi
    "$DS/practice/strt.sh" & exit
else
    cd "$DC_tlt/practice"
    [ -f fin1 ] && rm fin1; [ -f fin2 ] && rm fin2;
    [ -f mcin1 ] && rm mcin1; [ -f mcin2 ] && rm mcin2;
    [ -f lwin1 ] && rm lwin1; [ -f lwin2 ] && rm lwin2;
    [ -f lsin1 ] && rm lsin1
    [ -f wiin1 ] && rm wiin1; [ -f wiin2 ] && rm wiin2;
    kill -9 $(pgrep -f "yad --form ")
    exit
fi
