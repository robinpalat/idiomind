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

position() {

    item="$(sed -n "$2"p "$3")"
    pos=$(($(wc -l < "$3")-$2))
    source "$DS/ifs/mods/cmns.sh"
    [ ${#item} -gt 80 ] && label="${item:0:80}..." \
    || label="$item"
    mv="$(tac "$DC_tlt/0.cfg" | grep -vxF "$item" \
    | awk '{print ((let++))"\nFALSE\n"$0}' \
    | yad --list --title="$(gettext "Move")" \
    --class=Idiomind --name=Idiomind \
    --text="  [ $pos ]  \"$label\"\n" \
    --always-print-result --print-column=3 --separator="" \
    --window-icon="$DS/images/icon.png" --no-headers --on-top --center \
    --expand-column=3 --ellipsize=END \
    --width=640 --height=560 --borders=8 \
    --column="":NUM \
    --column="":RD \
    --column="":TEXT \
    --button="$(gettext "Cancel")":2 \
    --button="$(gettext "OK")":0)"
    
    ret=$?

    if [[ $ret -eq 0 ]]; then

        [ -z "${mv}" ] && exit
        > "$DC_tlt/0.cfg.mv"
        while read sec; do

            if [ "$sec" = "${mv}" ]; then
                echo -e "$mv" >> "$DC_tlt/0.cfg.mv"
                echo -e "$item" >> "$DC_tlt/0.cfg.mv"
                
            elif [ "$sec" = "${item}" ]; then
                continue

            else echo "$sec" >> "$DC_tlt/0.cfg.mv"; fi
            
        done < "$DC_tlt/0.cfg"

        e=$?
    
        if [ $e != 0 ] ; then
            msg "$(gettext "Some changes were not made.")\n" dialog-warning
        else
            cp -f "$DC_tlt/0.cfg.mv" "$DC_tlt/0.cfg"
            cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
            
            if [ "$(wc -l < "$DC_tlt/2.cfg")" = 0 ]; then
                cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
                msg "$(gettext "Restart the window to see the changes.")\n" info
                
            else
                msg "$(gettext "The changes will be seen after restarting the index.")\n" info; fi
        fi
    fi
    rm "$DC_tlt/0.cfg.mv"
    exit
}


function dlg_form_1() {
    
    yad --form --title="$trgt" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" --selectable-labels \
    --align=center --text-align=center \
    --window-icon="$DS/images/icon.png" --buttons-layout=end --scroll \
    --columns=2 --center \
    --width=680 --height=540 --borders=10 \
    --field="<small>$lgtl</small>" "$trgt" \
    --field="<small>$lgsl</small>" "$srce" \
    --field="<small>$(gettext "Topic")</small>":CB "$tpc!$tpcs" \
    --field="<small>$(gettext "Audio")</small>":FL "$DM_tlt/words/$fname.mp3" \
    --field="<small>$(gettext "Example")</small>":TXT "$exmp" \
    --field="<small>$(gettext "Definition")</small>":TXT "$dftn" \
    --field="<small>$(gettext "Note")</small>":TXT "$note" \
    --field="<small>$(gettext "Listen")</small>":FBTN "play '$DM_tlt/words/$fname.mp3'" \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="<small>$(gettext "Search definition")</small>":FBTN "$cmd_definition" \
    --field=" ":LBL " " \
    --button="$(gettext "Move")":"$cmd_move" \
    --button="$(gettext "Image")":"$cmd_image" \
    --button="$(gettext "Delete")":"$cmd_delete" \
    --button="gtk-go-down":2 \
    --button="gtk-save":0 > "$1"
} >/dev/null 2>&1


function dlg_form_2() {
        
    yad --form --title="$trgt" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" --selectable-labels \
    --window-icon="$DS/images/icon.png" --center --align=center \
    --buttons-layout=end \
    --width=650 --height=540 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":$t "$type" \
    --field="<small>$lgtl</small>":TXT "$trgt" \
    --field="<small>$lgsl</small>":TXT "$srce" \
    --field="$(gettext "Listen")":FBTN "$cmd_play" \
    --field="<small>$(gettext "Topic")</small>":CB "$tpc!$tpcs" \
    --field="<small>$(gettext "Audio")</small>":FL "$DM_tlt/$fname.mp3" \
    --button="$(gettext "Move")":"$cmd_move" \
    --button="$(gettext "Words")":"$cmd_words" \
    --button="$(gettext "Image")":"$cmd_image" \
    --button="$(gettext "Delete")":"$cmd_delete" \
    --button="gtk-go-down":2 \
    --button="gtk-save":0 > "$1"
} >/dev/null 2>&1


function dialog_2() {
    
    yad --title="$tpc" \
    --class=Idiomind --name=Idiomind \
    --text="<b>$(gettext "Reviewing all or only new?")</b>" \
    --window-icon="$DS/images/icon.png" \
    --image=dialog-question --center \
    --on-top --window-icon="$DS/images/icon.png" \
    --width=380 --height=120 --borders=3 \
    --button="$(gettext "New Items")":3 \
    --button="$(gettext "Review All")":2
}

case "$1" in
    position)
    position "$@" ;;
esac
