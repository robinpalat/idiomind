#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function word_view(){

    tags="$(eyeD3 "$DM_tlt/words/$fname.mp3")"
    trgt="$item"
    srce="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tags")"
    fields="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tags" | tr '_' '\n')"
    mark="$(grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)' <<<"$tags")"
    exmp="$(sed -n 1p <<<"$fields")"
    dftn="$(sed -n 2p <<<"$fields")"
    note="$(sed -n 3p <<<"$fields")"
    [ -n "$dftn" ] && field_dftn="--field=\n$dftn:lbl"
    [ -n "$note" ] && field_note="--field=$note\n:lbl"
    hlgt="$(awk '{print tolower($0)}' <<<"$trgt")"
    exmp="$(sed "s/"${trgt,,}"/<span background='#FDFBCF'>"${trgt,,}"<\/\span>/g" <<<"$exmp")"
    [ "$mark" = TRUE ] && trgt="<sup>*</sup>$trgt"
    
    yad --form --scroll --title="$item" \
    --selectable-labels --quoted-output \
    --text="<span font_desc='Sans Free Bold $fs'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --window-icon="$DS/images/icon.png" \
    --scroll --center --on-top --skip-taskbar --text-align=center --image-on-top --center \
    --width=620 --height=380 --borders=$bs \
    --field="":lbl \
    --field="<i><span color='#737373'>$exmp</span></i>:lbl" "$field_dftn" "$field_note" \
    --button=gtk-edit:4 \
    --button="$listen":"$cmd_listen" \
    --button=gtk-go-up:3 \
    --button=gtk-go-down:2
} >/dev/null 2>&1


function sentence_view(){

    tags="$(eyeD3 "$DM_tlt/$fname.mp3")"
    [ "$(sed -n 1p < "$DC_s/1.cfg" | grep -o grammar=\"[^\"]* | grep -o '[^"]*$')"  = TRUE ] \
    && trgt="$(grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)' <<<"$tags")" \
    || trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")"
    srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")"
    lwrd="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags" | tr '_' '\n')"
    [ "$(grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)' <<<"$tags")" = TRUE ] && trgt="<b>*</b> $trgt"
    [ ! -f "$DM_tlt/$fname.mp3" ] && exit 1
    
    echo "$lwrd" | yad --list --title=" " \
    --selectable-labels --print-column=0 \
    --dclick-action="$DS/ifs/tls.sh 'dclik'" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --image-on-top --center --on-top \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --text="<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --width=620 --height=380 --borders=20 \
    --column="":TEXT \
    --column="":TEXT \
    --button=gtk-edit:4 \
    --button="$listen":"$cmd_listen" \
    --button=gtk-go-up:3 \
    --button=gtk-go-down:2
} >/dev/null 2>&1

export -f word_view sentence_view


function notebook_1() {
    
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' '$tpc' 1"
    cmd_attchs="'$DS/ifs/tls.sh' 'attachs'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' '$tpc'"
    cmd_share="'$DS/ifs/upld.sh' 'upld' '$tpc'"
    cmd_play="$DS/play.sh"
    
    tac "$ls1" | awk '{print $0"\n"}' | yad --list --tabnum=1 \
    --plug=$KEY --print-all \
    --dclick-action="$DS/vwr.sh '1'" \
    --expand-column=1 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
    tac "$ls2" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '2'" \
    --expand-column=0 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --filename="$nt" --editable --wrap --fore='gray30' \
    --show-uri --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$label_info1\n" \
    --scroll --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "$tpc" \
    --field="$(gettext "Mark as learned")":FBTN "$cmd_mark" \
    --field=" ":LBL "$set1" \
    --field="$label_info2\n\t\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t":LBL " " \
    --field="$(gettext "Attached Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="$tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right "$img" --fixed --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --tab="  $(gettext "Learning") ($inx1) " \
    --tab="  $(gettext "Learned") ($inx2) " \
    --tab=" $(gettext "Notes") " \
    --tab=" $(gettext "Edit") " \
    --width=$sx --height=$sy --borders=0 --tab-borders=3 \
    --button="$(gettext "Lists")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="$(gettext "Close")":1
}


function notebook_2() {
    
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' '$tpc' 1"
    cmd_attchs="'$DS/ifs/tls.sh' 'attachs'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' '$tpc'"
    cmd_share="'$DS/ifs/upld.sh' 'upld' '$tpc'"
    
    yad --multi-progress --tabnum=1 \
    --text="$pres" \
    --plug=$KEY \
    --align=center --borders=80 --bar="":NORM $RM &
    tac "$ls2" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '2'" \
    --expand-column=0 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --filename="$nt" --editable --wrap --fore='gray30' \
    --show-uri --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$label_info1\n" \
    --scroll --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "$tpc" \
    --field="   $(gettext "Review")   ":FBTN "$cmd_mark" \
    --field=" ":LBL "$set1" \
    --field="$label_info2\n\t\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t":LBL " " \
    --field="$(gettext "Attached Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="$tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right "$img" --fixed --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --tab="  $(gettext "Review")  " \
    --tab="  $(gettext "Learned") ($inx2) " \
    --tab=" $(gettext "Notes") " \
    --tab=" $(gettext "Edit") " \
    --width=$sx --height=$sy --borders=0 --tab-borders=3 \
    --button="$(gettext "Close")":1
}


function dialog_1() {
    
    yad --title="$tpc" \
    --class=idiomind --name=Idiomind \
    --text="$(gettext "More than") $tdays $(gettext "days have passed since you mark this topic as learned.  You'd like to review?")" \
    --image=dialog-question --on-top --center \
    --window-icon="$DS/images/icon.png" \
    --width=450 --height=150 --borders=10 \
    --button=" $(gettext "Not Yet") ":1 \
    --button=" $(gettext "Yes") ":2
}
