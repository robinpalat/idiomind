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
    
        yad --form --wrap --center --name=Idiomind \
        --width=$wth --height=$eht --always-print-result \
        --borders=5 --columns=2 --align=center --class=Idiomind \
        --buttons-layout=end --title=" $TGT" --separator="\\n" \
        --fontname="Arial" --scroll --window-icon="$DS/images/logo.png" \
        --text-align=center --selectable-labels \
        --field="<small>$lgtl</small>":RO "$TGT" \
        --field="<small>$lgsl</small>" "$src" \
        --field="<small>$(gettext "Topic") </small>":CB "$tpc!$tpcs" \
        --field="<small>$(gettext "Audio") </small>":FL "$DM_tlt/words/$fname.mp3" \
        --field="<small>$(gettext "Example") </small>":TXT "$exm1" \
        --field="<small>$(gettext "Definition") </small>":TXT "$dftn" \
        --field="<small>$(gettext "Notes") </small>":TXT "$ntes" \
        --field="$(gettext "Mark") "":CHK" "$mrk" \
        --field="$chk"":CHK" "$mrok" \
        --field="<small>$(gettext "Search definition") </small>":FBTN "$sdefn" \
        --field=" :LBL" " " \
        --button="$(gettext "Image")":"$imge" \
        --button="$(gettext "Delete")":"$dlte" \
        --button=gtk-close:0 > $1
}


function dlg_form_2() {
        
        yad --form --wrap --center --name=Idiomind  \
        --width=$wth --height=$eht --always-print-result \
        --separator="\\n" --borders=5 --align=center --align=center \
        --buttons-layout=end --title=" $tgt" --fontname="Arial" \
        --selectable-labels --window-icon="$DS/images/logo.png" --class=Idiomind \
        --field="$chk:CHK" "$ok" \
        --field="$(gettext "Mark") "":CHK" "$mrk" \
        --field="<small>$lgtl</small>":TXT "$tgt" \
        --field="<small>$lgsl</small>":TXT "$src" \
        --field="<small>$(gettext "Topic") </small>":CB "$tpc!$tpcs" \
        --field="<small>$(gettext "Audio") </small>":FL "$DM_tlt/$fname.mp3" \
        --field="$(gettext "List Words")":FBTN "$wrds" \
        --button="$(gettext "Image")":"$imge" \
        --button="$(gettext "Edit Audio")":"$edau" \
        --button="$(gettext "Delete")":"$dlte" \
        --button=gtk-close:0 > $1
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
