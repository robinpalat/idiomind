#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function dlg_form_1() {
    
        yad --form --wrap --center --name=idiomind --class=idmnd \
        --width=$wth --height=$eht --always-print-result \
        --borders=15 --columns=2 --align=center --skip-taskbar \
        --buttons-layout=end --title=" $TGT" --separator="\\n" \
        --fontname="Arial" --scroll --window-icon=idiomind \
        --text-align=center --selectable-labels \
        --field="<small>$lgtl</small>":RO "$TGT" \
        --field="<small>$lgsl</small>" "$src" \
        --field="<small>$topic </small>":CB "$tpc!$tpcs" \
        --field="<small>$audio </small>":FL "$DM_tlt/words/$fname.mp3" \
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
        --buttons-layout=end --title=" $tgt" --fontname="Arial" \
        --selectable-labels --window-icon=idiomind --skip-taskbar \
        --field="$chk:CHK" "$ok" \
        --field="$mark "":CHK" "$mrk" \
        --field="<small>$lgtl</small>":TXT "$tgt" \
        --field="<small>$lgsl</small>":TXT "$src" \
        --field="<small>$topic </small>":CB "$tpc!$tpcs" \
        --field="<small>$audio </small>":FL "$DM_tlt/$fname.mp3" \
        --field="$list_words":BTN "$wrds" \
        --button="$image":"$imge" \
        --button="$delete":"$dlte" "$edau" \
        --button=gtk-close:0 > $1
}


function calculate_review() {

    dts=$(cat "$DC_tlt/cfg.9" | wc -l)
    if [ $dts = 1 ]; then
        dte=$(sed -n 1p "$DC_tlt/cfg.9")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/10))
    elif [ $dts = 2 ]; then
        dte=$(sed -n 2p "$DC_tlt/cfg.9")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/15))
    elif [ $dts = 3 ]; then
        dte=$(sed -n 3p "$DC_tlt/cfg.9")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/30))
    elif [ $dts = 4 ]; then
        dte=$(sed -n 4p "$DC_tlt/cfg.9")
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/60))
    fi
}


function _del_() {

    for f in "${@}"; do
        [ -f "${f}" ] && \
        grep -vxF "${trgt}" "${f}" "${f}.tmp" && \
        sed '/^$/d' "${f}.tmp" > "${f}"
        rm "${f}.tmp"
    done
}

