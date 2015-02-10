#!/bin/bash
# -*- ENCODING: UTF-8 -*-



function dlg_form_1() {
	
        yad --form --wrap --center --name=idiomind --class=idmnd \
        --width=$wth --height=$eht --always-print-result \
        --borders=15 --columns=2 --align=center --skip-taskbar \
        --buttons-layout=end --title=" $nme" --separator="\\n" \
        --fontname="Arial" --scroll --window-icon=idiomind \
        --text-align=center --selectable-labels \
        --field="<small>$lgtl</small>":RO "$TGT" \
        --field="<small>$lgsl</small>" "$src" \
        --field="<small>$topic </small>":CB "$tpc!$tpcs" \
        --field="<small>$audio </small>":FL "$AUD" \
        --field="<small>$example </small>":TXT "$exm1" \
        --field="<small>$definition </small>":TXT "$dftn" \
        --field="<small>$notes </small>":TXT "$ntes" \
        --field="$mark "":CHK" "$mrk" \
        --field="$chk"":CHK" "$mrok" \
        --field="<a href='http://glosbe.com/$lgs/$lgt/$TGT'>$search_def</a>":lbl \
        --field=" :LBL" " " \
        --button="$image":"$imge" \
        --button="$delete":"$dlte" \
        --button=gtk-close:0 > $1
}


function dlg_form_2() {
        
        yad --form --wrap --center --name=idiomind --class=idmnd \
        --width=$wth --height=$eht --always-print-result \
        --separator="\\n" --borders=15 --align=center --align=center \
        --buttons-layout=end --title=" $nme" --fontname="Arial" \
        --selectable-labels --window-icon=idiomind --skip-taskbar \
        --field="$chk:CHK" "$ok" \
        --field="$mark "":CHK" "$mrk" \
        --field="<small>$lgtl</small>":TXT "$tgt" \
        --field="<small>$lgsl</small>":TXT "$src" \
        --field="<small>$topic </small>":CB "$tpc!$tpcs" \
        --field="<small>$audio </small>":FL "$DM_tlt/$nme.mp3" \
        --field="$list_words":BTN "$wrds" \
        --button="$image":"$imge" \
        --button="$delete":"$dlte" "$edau" \
        --button=gtk-close:0 > $1
}
