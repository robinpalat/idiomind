#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_form_1() {
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
    [ -z "${trgt}" ] && trgt="${item_id}"
    yad --form --title="$(gettext "Edit") - $(gettext "Note") ${edit_pos}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" \
    --window-icon=idiomind \
    --align=right --text-align=center --columns=2 \
    --buttons-layout=end --on-top --center \
    --width=650 --height=400 --borders=10 \
    --field="$(gettext "$tlng")" "${trgt}" \
    --field="$(gettext "$slng")" "${srce}" \
    --field="$(gettext "Topic")":CB "${tpc_list}" \
    --field=" ":LBL " " \
    --field="$(gettext "Example")\t\t\t\t\t\t\t\t\t\t\t":TXT "${exmp}" \
    --field="$(gettext "Definition")":TXT "${defn}" \
    --field="$(gettext "Definition")":FBTN "${cmd_def}" \
    --field="$(gettext "Translation")":FBTN "${cmd_trad}" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="$(gettext "Note")":TXT "${note}" \
    --button="$(gettext "Image")":"${cmd_image}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"${cmd_play}" \
    --button="!media-seek-forward":2 \
    --button="$(gettext "Close")":0
}

function dlg_form_2() {
    if [[ $(wc -w <<<"${trgt}") -lt 8 ]]; then
    t=CHK; lbl_2="$(gettext "Change viewer")"
    [ -z "${trgt}" ] && trgt="${item_id}"
    else t=LBL; fi
    cmd_play="$DS/play.sh play_sentence ${cdid}"
    yad --form --title="$(gettext "Edit") - $(gettext "Note") ${edit_pos}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" \
    --window-icon=idiomind \
    --buttons-layout=end --align=right --on-top --center \
    --width=650 --height=400 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":${t} "$type" \
    --field="$(gettext "$tlng")":TXT "${trgt}" \
    --field="$(gettext "$slng")":TXT "${srce}" \
    --field="$(gettext "Note")":TXT "${note}" \
    --field="$(gettext "Translation")":FBTN "${cmd_trad}" \
    --field="\t\t\t$(gettext "Topic")":CB "${tpc_list}" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"${cmd_play}" \
    --button="!media-seek-forward":2 \
    --button="$(gettext "Close")":0
}

function edit_list_list() {
    sz=(580 450); [[ ${swind} = TRUE ]] && sz=(480 440)
    yad --list --title="$(gettext "Edit list")" \
    --text="<small>$(gettext "Try double click, right-click and drag and drop.")</small>" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --no-headers --center \
    --width=${sz[0]} --height=${sz[1]} --borders=5 \
    --column="" \
    --button="$(gettext "More")":"$DS/mngr.sh edit_list_more" \
    --button="$(gettext "Translate")":2 \
    --button="$(gettext "Save")!document-save":0 \
    --button="$(gettext "Cancel")":1
}

function edit_feeds_list() {
    kill -9 $(pgrep -f "yad --list --title") &
    yad --list --title="$(gettext "Add content automatically")" \
    --text="<small>$(gettext "Configure feed urls")</small>" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='\n' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --limit=3 --no-headers --center \
    --width=520 --height=140 --borders=5 \
    --column="" \
    "$btnf" --button="$(gettext "Save")":0 \
    --button="$(gettext "Cancel")":1
    
}

function progr_3() {
    yad --progress  \
    --name=Idiomind --class=Idiomind \
    --undecorated --${1} --auto-close \
    --skip-taskbar --center --on-top --no-buttons
}
