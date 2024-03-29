#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_form_1() {
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
    [ -z "${trgt}" ] && trgt="${item_id}"
    yad --form --title="$(gettext "Edit") - $(gettext "Note") ${edit_pos}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" \
    --window-icon=$DS/images/logo.png \
    --align=right --text-align=center --columns=2 \
    --buttons-layout=end --center \
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
    --button="!audio-volume-high!$(gettext "Listen")":"${cmd_play}" \
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
    --window-icon=$DS/images/logo.png \
    --buttons-layout=end --align=right --center \
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
    --button="!audio-volume-high!$(gettext "Listen")":"${cmd_play}" \
    --button="!media-seek-forward":2 \
    --button="$(gettext "Close")":0
}

function edit_list_list() {
    sz=(580 450); [[ ${swind} = TRUE ]] && sz=(480 440)
    yad --editable --list --title="$(gettext "Edit list")" \
    --text="<small>$(gettext "Try double click, right-click and drag and drop.")</small>" \
    --name=Idiomind --class=Idiomind \
    --separator='' \
    --always-print-result --print-all \
    --window-icon=$DS/images/logo.png \
    --no-headers --center \
    --width=${sz[0]} --height=${sz[1]} --borders=5 \
    --column="" \
    --button="$(gettext "Restart")":"$DS/mngr.sh restartTopic" \
    --button="$(gettext "Backups")":"$DS/mngr.sh edit_list_more" \
    --button="$(gettext "Translate")":2 \
    --button="$(gettext "Save")!gtk-save":0 \
    --button="$(gettext "Close")":1
}

function progr_3() {
    yad --progress  \
    --name=Idiomind --class=Idiomind \
    --undecorated --${1} --auto-close \
    --skip-taskbar --center --on-top --no-buttons
}
