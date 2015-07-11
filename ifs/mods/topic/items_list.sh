#!/bin/bash
# -*- ENCODING: UTF-8 -*-

 
function word_view() {

    [ -n "$defn" ] && field_defn="--field=$defn:lbl"
    [ -n "$note" ] && field_note="--field=$note\n:lbl"
    [ -n "$exmp" ] && field_exmp="--field=<i><span color='#737373'>$exmp</span></i>:lbl"

    yad --form --title=" " \
    --selectable-labels --quoted-output \
    --text="$tag<span font_desc='Sans Free 25'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --window-icon="$DS/images/icon.png" \
    --align=left --scroll --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=620 --height=380 --borders=20 \
    --field="":lbl "$field_exmp" "$field_defn" "$field_note" \
    --button=gtk-edit:4 \
    --button="$(gettext "Listen")":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1


function sentence_view() {

    if [ "$(grep -o gramr=\"[^\"]* < "$DC_s/1.cfg" | grep -o '[^"]*$')"  = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    
    echo "$lwrd" | yad --list --title=" " \
    --text="$tag<span font_desc='Sans Free 15'>${trgt_l}</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --print-column=0 \
    --dclick-action="$DS/play.sh 'play_word'" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --image-on-top --center --on-top \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --width=620 --height=380 --borders=20 \
    --column="":TEXT \
    --column="":TEXT \
    --button=gtk-edit:4 \
    --button="$(gettext "Listen")":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1


function m_text() {

    include "$DS/ifs/mods/mngr"
    trgt="${1}"
    cmd_del="$DS/mngr.sh delete_item "\"${tpc}\"" "\"${trgt}\"""
    cmd_add="$DS/add.sh new_items (2) (3) "\"${trgt}\"""
    text="<span font_desc='monospace 10'>$(gettext "Text missing")</span>\n\n\n\n"

    yad --form --title=" " \
    --text="${text}" \
    --window-icon="$DS/images/icon.png" \
    --align=center --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=620 --height=380 --borders=20 \
    --button="$(gettext "Delete")":"$cmd_del" \
    --button=gtk-add:"$cmd_add" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1

export -f word_view sentence_view m_text


function notebook_1() {
    
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"$tpc\"" 1"
    cmd_attchs="'$DS/ifs/tls.sh' 'attachs'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' "\"$tpc\"""
    cmd_adv="'$DS/ifs/tls.sh' adv "\"$tpc\"""
    cmd_share="'$DS/ifs/upld.sh' upld "\"$tpc\"""
    cmd_eind="'$DS/mngr.sh' edit_list "\"$tpc\"""
    cmd_play="$DS/play.sh play_list"
    
    list() { if [[ $((`wc -l < "${DC_tlt}/5.cfg"`/3)) = \
    `wc -l < "${DC_tlt}/1.cfg"` ]]; then
    tac "${DC_tlt}/5.cfg"; else tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0"\nFALSE"}'; fi; }
    
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
    --field="$(gettext "Auto select items that could be marked as learnt")":CHK "$auto_mrk" \
    --field="$label_info2\n":LBL " " \
    --field="$(gettext "Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field="$(gettext "Edit list")":FBTN "$cmd_eind" > "$cnf4" &
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
    --button="gtk-close":1
} >/dev/null 2>&1


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
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t":LBL "_" \
    --field="$label_info2\n":LBL " " \
    --field="$(gettext "Files")":FBTN "$cmd_attchs" \
    --field="$(gettext "Share")":FBTN "$cmd_share" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field="$(gettext "Edit list")":FBTN "$cmd_eind" > "$cnf4" &
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
    --button="gtk-close":1
} >/dev/null 2>&1


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
