#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function word_view() {

    trgt="$item"
    tags="$(eyeD3 "$DM_tlt/words/$fname.mp3")"
    srce="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tags")"
    fields="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tags" | tr '_' '\n')"
    mark="$(grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)' <<<"$tags")"
    exmp="$(sed -n 1p <<<"$fields")"
    dftn="$(sed -n 2p <<<"$fields")"
    note="$(sed -n 3p <<<"$fields")"
    exmp="$(sed "s/"${trgt,,}"/<span background='#FDFBCF'>"${trgt,,}"<\/\span>/g" <<<"$exmp")"
    [ -n "$dftn" ] && field_dftn="--field=$dftn:lbl"
    [ -n "$note" ] && field_note="--field=$note\n:lbl"
    [ -n "$exmp" ] && field_exmp="--field=<i><span color='#737373'>$exmp</span></i>:lbl"
    [ -z "$trgt" ] && tm="<span color='#3F78A0'><tt>$(gettext "Text missing")</tt></span>"
    [ "$mark" = TRUE ] && im="--image=$DS/images/mark.png"
    
    yad --form --title=" " $im \
    --selectable-labels --quoted-output \
    --text="<span font_desc='Sans Free Bold $fs'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --window-icon="$DS/images/icon.png" \
    --align=left --scroll --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=620 --height=380 --borders=$bs \
    --field="":lbl "$field_exmp" "$field_dftn" "$field_note" \
    --button=gtk-edit:4 \
    --button="$listen":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1


function sentence_view() {

    if [ -f "$DM_tlt/$fname.mp3" ]; then
    tags="$(eyeD3 "$DM_tlt/$fname.mp3")"
    [ "$(sed -n 1p "$DC_s/1.cfg" | grep -o grammar=\"[^\"]* | grep -o '[^"]*$')"  = TRUE ] \
    && trgt="$(grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)' <<<"$tags")" \
    || trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")"
    srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")"
    lwrd="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags" | tr '_' '\n')"
    mark="$(grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)' <<<"$tags")"
    [  "$mark" = TRUE ] && im="--image=$DS/images/mark.png"
    [ -z "$trgt" ] && tm="<span color='#3F78A0'><tt>$(gettext "Text missing")</tt></span>"
    else tm="<span color='#3F78A0'><tt>$(gettext "File not found")</tt></span>"; fi
    
    echo "$lwrd" | yad --list --title=" " $im \
    --text="$tm<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --print-column=0 \
    --dclick-action="$DS/ifs/tls.sh 'dclik'" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --image-on-top --center --on-top \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --width=620 --height=380 --borders=20 \
    --column="":TEXT \
    --column="":TEXT \
    --button=gtk-edit:4 \
    --button="$listen":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1

export -f word_view sentence_view


function notebook_1() {
    
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"$tpc\"" 1"
    cmd_attchs="'$DS/ifs/tls.sh' 'attachs'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' "\"$tpc\"""
    cmd_share="'$DS/ifs/upld.sh' upld "\"$tpc\"""
    cmd_play="$DS/play.sh"
    list() {
    if [ -f "${DC_tlt}/5.cfg" ]; then
    tac "${DC_tlt}/5.cfg"; else
    tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0"\nFALSE"}'; fi
    }

    list | yad --list --tabnum=1 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '1'" \
    --expand-column=2 --no-headers --ellipsize=END --tooltip-column=2 \
    --column=Name:IMG --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
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
    --field="$(gettext "Mark as learnt")":FBTN "$cmd_mark" \
    --field=" ":LBL "$set1" \
    --field="$label_info2\n\t\t\t\t\n\t\t\t\t\t\t\t\t\t\t\t\t":LBL " " \
    --field="$(gettext "Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right "$img" --fixed --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --tab="  $(gettext "Learning") ($inx1) " \
    --tab="  $(gettext "Learnt") ($inx2) " \
    --tab=" $(gettext "Notes") " \
    --tab=" $(gettext "Edit") " \
    --width=$sx --height=$sy --borders=0 --tab-borders=3 \
    --button="$(gettext "Lists")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="$(gettext "Close")":1
}


function notebook_2() {
    
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' "\"$tpc\"" 1"
    cmd_attchs="'$DS/ifs/tls.sh' 'attachs'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' "\"$tpc\"""
    cmd_share="'$DS/ifs/upld.sh' 'upld' "\"$tpc\"""
    
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
    --field="$(gettext "Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right "$img" --fixed --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --tab="  $(gettext "Review")  " \
    --tab="  $(gettext "Learnt") ($inx2) " \
    --tab=" $(gettext "Notes") " \
    --tab=" $(gettext "Edit") " \
    --width=$sx --height=$sy --borders=0 --tab-borders=3 \
    --button="$(gettext "Close")":1
}


function dialog_1() {
    
    yad --title="$tpc" \
    --class=idiomind --name=Idiomind \
    --text=" $(gettext "<b>Would you like to go over it?</b>\n The specified period already has been completed")" \
    --image=gtk-refresh \
    --window-icon="$DS/images/icon.png" \
    --buttons-layout=edge --center --on-top \
    --width=420 --height=140 --borders=10 \
    --button=" $(gettext "Not Yet") ":1 \
    --button=" $(gettext "Yes") ":2
}
