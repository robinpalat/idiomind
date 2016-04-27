#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_form_1() {
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
    [ -z "${trgt}" ] && trgt="${item_id}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" --selectable-labels \
    --window-icon=idiomind \
    --align=right --text-align=center --columns=2 \
    --buttons-layout=end --center \
    --width=650 --height=480 --borders=10 \
    --field="$tlng" "${trgt}" \
    --field="$slng" "${srce}" \
    --field="$(gettext "Topic")":CB "${tpc_list}" \
    --field=" ":LBL " " \
    --field="$(gettext "Example")\t\t\t\t\t\t\t\t\t\t\t":TXT "${exmp}" \
    --field="$(gettext "Definition")":TXT "${defn}" \
    --field="$(gettext "Note")":TXT "${note}" \
    --field="$(gettext "Go to Google Translate")":FBTN "${cmd_trad}" \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --field="$(gettext "Definition")":FBTN "${cmd_def}" \
    --button="$(gettext "Image")":"${cmd_image}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Next")":2 \
    --button="$(gettext "Close")":0
}

function dlg_form_2() {
    if [[ $(wc -w <<<"${trgt}") -lt 8 ]]; then
    t=CHK; lbl_2="$(gettext "Change viewer")"
    [ -z "${trgt}" ] && trgt="${item_id}"
    else t=LBL; fi
    cmd_play="$DS/play.sh play_sentence ${cdid}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" --selectable-labels \
    --window-icon=idiomind \
    --buttons-layout=end --align=right --center \
    --width=650 --height=420 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":${t} "$type" \
    --field="$tlng":TXT "${trgt}" \
    --field="$slng":TXT "${srce}" \
    --field="$(gettext "Go to Google Translate")":FBTN "${cmd_trad}" \
    --field="\t\t\t$(gettext "Topic")":CB "${tpc_list}" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --button="$(gettext "Words")":"${cmd_words}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Next")":2 \
    --button="$(gettext "Close")":0
}

function edit_list_list() {
    yad --list --title="$(gettext "Edit list")" \
    --text="$(gettext "Double click to edit, drag and drop to move, right click to show menu.")" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --no-headers --center \
    --width=560 --height=350 --borders=3 \
    --column="" \
    --button="$(gettext "More")":5 \
    --button="$(gettext "Save")!gtk-save":0 \
    --button="$(gettext "Cancel")":1
}

function edit_feeds_list() {
    yad --list --title="${tpc}" \
    --text="$(gettext "Configure feed urls to add content automatically from news headlines.")\n" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='\n' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --no-headers --center \
    --width=550 --height=160 --borders=3 \
    --column="" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Update")":2 \
    --button="$(gettext "Save")":0
}

function progr_3() {
    yad --progress \
    --name=Idiomind --class=Idiomind \
    --undecorated --pulsate --auto-close \
    --skip-taskbar --center --on-top --no-buttons
}
