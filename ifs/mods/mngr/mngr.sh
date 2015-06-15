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
    
    source "$DS/ifs/mods/cmns.sh"
    cnt=$(wc -l < "${3}")
    [ $cnt -lt 3 ] && msg "$(gettext "Unavailable")\n" \
    info "$(gettext "Unavailable")" && exit 1
    item="$(sed -n "$2"p "${3}")"
    pos=$((cnt-$2))
    
    mv="$(tac "$DC_tlt/0.cfg" | grep -vxF "$item" \
    | awk '{print ((let++))"\nFALSE\n"$0"\nFALSE"}' \
    | yad --list --title="$(gettext "More")" \
    --class=Idiomind --name=Idiomind \
    --text="  [ $pos ] $(gettext "Current position")\n" \
    --always-print-result --print-all --separator="|" \
    --no-click --dclick-action="" \
    --window-icon="$DS/images/icon.png" --on-top --center \
    --expand-column=3 --ellipsize=END \
    --width=640 --height=560 --borders=8 \
    --column="":NUM \
    --column="$(gettext "Move")":RD \
    --column="$(gettext "Item")":TEXT \
    --column="$(gettext "Delete")":CHK \
    --button="$(gettext "Inverse")":3 \
    --button="$(gettext "Save")":0 \
    --button="$(gettext "Cancel")":1)"
    ret=$?

    if [[ $ret -eq 0 ]]; then
    
        [ -z "${mv}" ] && exit
        > "$DC_tlt/0.cfg.mv"

        while read -r sec; do
        
            f1=`cut -d "|" -f1 <<<"${sec}"`
            f2=`cut -d "|" -f2 <<<"${sec}"`
            f3=`cut -d "|" -f3 <<<"${sec}"`
            f4=`cut -d "|" -f4 <<<"${sec}"`
            if [[ "$f2" = 'TRUE' ]] && [[ "${itr}" != "${item}" ]]; then
            echo -e "${item}" >> "$DC_tlt/0.cfg.mv"
            echo -e "${f3}" >> "$DC_tlt/0.cfg.mv"
            elif [[ "$f4" = 'TRUE' ]] && [[ "${f3}" != "${item}" ]]; then
            delete_item_ok "${f3}"
            else echo "${f3}" >> "$DC_tlt/0.cfg.mv"; fi
        done <<<"{$mv}"

        e=$?
        if [ $e != 0 ] ; then
            msg "$(gettext "Some changes were not made.")\n" dialog-warning
        else
            tac "$DC_tlt/0.cfg.mv" > "$DC_tlt/0.cfg"
            cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
            
            if [ "$(wc -l < "$DC_tlt/2.cfg")" = 0 ]; then
            cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
            msg "$(gettext "The changes will be seen only after restarting the main window.")\n" info
            else msg "$(gettext "The changes will be seen only after restarting the lists.")\n" info; fi
        fi
        
    elif [[ $ret -eq 3 ]]; then
    
        tac "$DC_tlt/0.cfg"  > "$DC_tlt/0.cfg.mv"; mv -f "$DC_tlt/0.cfg.mv" "$DC_tlt/0.cfg"
        tac "$DC_tlt/.11.cfg"  > "$DC_tlt/.11.cfg.mv"; mv -f "$DC_tlt/.11.cfg.mv" "$DC_tlt/.11.cfg"
        
        if [ "$(wc -l < "$DC_tlt/2.cfg")" = 0 ]; then
        tac "$DC_tlt/1.cfg" > "$DC_tlt/1.cfg.mv"; mv -f "$DC_tlt/1.cfg.mv" "$DC_tlt/1.cfg"
        msg "$(gettext "The changes will be seen only after restarting the main window.")\n" info   
        else msg "$(gettext "The changes will be seen only after restarting the lists.")\n" info; fi
        
    fi
    "$DS/ifs/tls.sh" colorize &
    [ -f "$DC_tlt/0.cfg.mv" ] && rm "$DC_tlt/0.cfg.mv"
    exit
}

function dlg_form_1() {
    
    cmd_play="play "\"${audio}\"""
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --align=left --text-align=center --columns=2 \
    --buttons-layout=end --scroll --center --on-top \
    --width=680 --height=540 --borders=10 \
    --field="<small>$lgtl</small>" "$trgt" \
    --field="<small>$lgsl</small>" "$srce" \
    --field="<small>$(gettext "Topic")</small>":CB "$tpc!$tpcs" \
    --field="<small>$(gettext "Audio")</small>":FL "${audio}" \
    --field="<small>$(gettext "Example")</small>":TXT "$exmp" \
    --field="<small><a href='$link2'>$(gettext "Definition")</a></small>":TXT "$defn" \
    --field="<small>$(gettext "Note")</small>":TXT "$note" \
    --field="<small><a href='$link1'>$(gettext "Translation")</a>\t<a href='$link3'>$(gettext "Images")</a></small>":LBL " " \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="<small>$(gettext "Listen")</small>":FBTN "$cmd_play" \
    --field=" ":LBL " " \
    --button="$(gettext "More")":"$cmd_move" \
    --button="$(gettext "Image")":"$cmd_image" \
    --button="$(gettext "Delete")":"$cmd_delete" \
    --button="gtk-go-down":2 \
    --button="$(gettext "Close")":0
}


function dlg_form_2() {
    
    if [ `wc -w <<<"$item"` -lt 4 ]; then
    t=CHK; lbl_2="$(gettext "It is a compound word")"
    else t=LBL; fi
    cmd_play="play "\"${audio}\"""
    #--button="$(gettext "Image")":"$cmd_image"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --buttons-layout=end --align=right --center --on-top \
    --width=650 --height=540 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":$t "$type" \
    --field="<small>$lgtl</small>":TXT "$trgt" \
    --field="<small><a href='$link1'>$(gettext "Translation")</a></small>\t":LBL " " \
    --field="<small>$lgsl</small>":TXT "$srce" \
    --field="$(gettext "Listen")":FBTN "$cmd_play" \
    --field="<small>$(gettext "Topic")</small>":CB "$tpc!$tpcs" \
    --field="<small>$(gettext "Audio")</small>":FL "${audio}" \
    --button="$(gettext "More")":"$cmd_move" \
    --button="$(gettext "Words")":"$cmd_words" \
    --button="$(gettext "Delete")":"$cmd_delete" \
    --button="gtk-go-down":2 \
    --button="$(gettext "Close")":0
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

case "$1" in
    position)
    position "$@" ;;
esac
