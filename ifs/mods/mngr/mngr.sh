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

function position() {

        item="$(sed -n "$2"p "$3")"
        pos=$(($(wc -l < "$3")-$2))
        source "$DS/ifs/mods/cmns.sh"
        [ $(wc -c <<<"$item") -gt 80 ] && label="${item:0:80}..." \
        || label="$item"
        mv="$(tac "$DC_tlt/0.cfg" | grep -vxF "$item" \
        | awk '{print ((let++))"\nFALSE\n"$0}' \
        | yad --list --title=" " \
        --class=Idiomind --name=Idiomind \
        --text="<sup>$(gettext "Moving the item through the list.")</sup>\n  [ $pos ]  <i>\"$label\"</i>" \
        --always-print-result --print-column=3 --separator="" \
        --window-icon="idiomind" --no-headers --on-top --center \
        --expand-column=3 --ellipsize=END \
        --width=600 --height=500 --borders=5 \
        --column="":NUM \
        --column="":RD \
        --column="":TEXT \
        --button="$(gettext "Cancel")":2 \
        --button="$(gettext "Save")":0)"

        ret=$?

        if [ $ret -eq 0 ]; then
        
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
                
                if [ `wc -l < "$DC_tlt/2.cfg"` = 0 ]; then
                    cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
                    msg "$(gettext "Restart the window to see the changes.")\n" info
                    
                else
                    msg "$(gettext "The changes will be after restarting the topic indexes.")\n" info; fi
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
        --window-icon="idiomind" --buttons-layout=end --scroll \
        --columns=2 --center --on-top \
        --width=$wth --height=$eht --borders=10 \
        --field="<small>$lgtl</small>":RO "$trgt" \
        --field="<small>$lgsl</small>" "$srce" \
        --field="<small>$(gettext "Topic") </small>":CB "$tpc!$tpcs" \
        --field="<small>$(gettext "Audio") </small>":FL "$DM_tlt/words/$fname.mp3" \
        --field="<small>$(gettext "Example") </small>":TXT "$exm1" \
        --field="<small>$(gettext "Definition") </small>":TXT "$dftn" \
        --field="<small>$(gettext "Notes") </small>":TXT "$ntes" \
        --field="$(gettext "Mark") "":CHK" "$mark" \
        --field="<small>$(gettext "Search definition") </small>":FBTN "$sdefn" \
        --field=" ":LBL "" \
        --field="<small>$(gettext "Listen")</small>":FBTN "play '$DM_tlt/words/$fname.mp3'" \
        --button="$(gettext "Position")":"$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' '$index_1'" \
        --button="$(gettext "Image")":"$imge" \
        --button="$(gettext "Delete")":"$dlte" \
        --button="gtk-go-down":2 \
        --button="$(gettext "Close")":0 > "$1"
}


function dlg_form_2() {
        
        yad --form --title="$trgt" \
        --name=Idiomind --class=Idiomind \
        --always-print-result --separator="\n" --selectable-labels \
        --window-icon="idiomind" --center --on-top --align=center \
        --buttons-layout=end \
        --width=$wth --height=$eht --borders=10 \
        --field="$(gettext "Mark") "":CHK" "$mark" \
        --field="<small>$lgtl</small>":TXT "$trgt" \
        --field="<small>$lgsl</small>":TXT "$srce" \
        --field="$(gettext "Listen")":FBTN "$lstau" \
        --field="<small>$(gettext "Topic") </small>":CB "$tpc!$tpcs" \
        --field="<small>$(gettext "Audio") </small>":FL "$DM_tlt/$fname.mp3" \
        --button="$(gettext "Position")":"$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' '$index_1'" \
        --button="$(gettext "List Words")":"$word_list" \
        --button="$(gettext "Image")":"$imge" \
        --button="$(gettext "Delete")":"$dlte" \
        --button="gtk-go-down":2 \
        --button="$(gettext "Close")":0 > "$1"
}


function calculate_review() {

    dts=$(cat "$DC_tlt/9.cfg" | wc -l)
    if [ $dts = 1 ]; then
        dte=$(sed -n 1p "$DC_tlt/9.cfg")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/10))
    elif [ $dts = 2 ]; then
        dte=$(sed -n 2p "$DC_tlt/9.cfg")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/15))
    elif [ $dts = 3 ]; then
        dte=$(sed -n 3p "$DC_tlt/9.cfg")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/30))
    elif [ $dts = 4 ]; then
        dte=$(sed -n 4p "$DC_tlt/9.cfg")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/60))
    fi
}

case "$1" in
    position)
    position "$@" ;;
esac
