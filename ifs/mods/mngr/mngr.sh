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


function dlg_form_1() {
    
    cmd_play="$DS/play.sh play_word ${trgt}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --align=left --text-align=center --columns=2 \
    --buttons-layout=end --scroll --center --on-top \
    --width=680 --height=540 --borders=10 \
    --field="<small>$lgtl</small>" "${trgt}" \
    --field="<small>$lgsl</small>" "${srce}" \
    --field="<small>$(gettext "Topic")</small>":CB "${tpc}!${tpcs}" \
    --field="<small>$(gettext "Audio")</small>":FL "${audf}" \
    --field="<small>$(gettext "Example")</small>\t\t\t\t\t\t\t\t\t":TXT "${exmp}" \
    --field="<small>$(gettext "Definition")\
    <a href='$link2'>$(gettext "Search Definition")</a></small>":TXT "${defn}" \
    --field="<small>$(gettext "Note")</small>":TXT "${note}" \
    --field="<small>\t<a href='$link3'>$(gettext "Images")</a>\t<a href='$link1'>$(gettext "Translation")</a></small>":LBL " " \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="<small>$(gettext "Listen")</small>":FBTN "${cmd_play}" \
    --field=" ":LBL " " \
    --button="$(gettext "Image")":"${cmd_image}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="gtk-go-down":2 \
    --button="$(gettext "Close")":0 |tail -n 1 |tr '\n' ' '
}


function dlg_form_2() {
    
    if [[ `wc -w <<<"${trgt}"` -lt 4 ]]; then
    t=CHK; lbl_2="$(gettext "It is a compound word")"
    else t=LBL; fi
    cmd_play="$DS/play.sh play_sentence ${id} "\"${trgt}\"""
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --buttons-layout=end --align=right --center --on-top \
    --width=650 --height=540 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":$t "$type" \
    --field="<small>$lgtl</small>":TXT "${trgt}" \
    --field="<small><a href='$link1'>$(gettext "Translation")</a></small>\t":LBL " " \
    --field="<small>$lgsl</small>":TXT "${srce}" \
    --field="$(gettext "Listen")":FBTN "${cmd_play}" \
    --field="<small>$(gettext "Topic")</small>":CB "${tpc}!${tpcs}" \
    --field="<small>$(gettext "Audio")</small>":FL "${audf}" \
    --button="$(gettext "Words")":"${cmd_words}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="gtk-go-down":2 \
    --button="$(gettext "Close")":0 |tail -n 1 |tr '\n' ' '
}


function dialog_2() {
    
    yad --title="$tpc" \
    --class=Idiomind --name=Idiomind \
    --text=" $(gettext "Review all or only new items?") " \
    --window-icon="$DS/images/icon.png" \
    --image=dialog-question --center \
    --on-top --window-icon="$DS/images/icon.png" \
    --width=380 --height=120 --borders=3 \
    --button="$(gettext "Only New")":3 \
    --button="$(gettext "Review All")":2
}


function progr_3() {

    yad --progress \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}
