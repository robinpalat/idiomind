#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_form_1() {
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${id}"
    [ -z "${trgt}" ] && trgt="${item_id}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" --selectable-labels \
    --window-icon=idiomind \
    --align=right --text-align=center --columns=2 \
    --buttons-layout=end --scroll --center --on-top \
    --width=700 --height=500 --borders=10 \
    --field="$lgtl" "${trgt}" \
    --field="$lgsl" "${srce}" \
    --field="$(gettext "Topic")":CB "${tpc_list}" \
    --field="$(gettext "Tag")":CB "${tags_list}" \
    --field="$(gettext "Example")\t\t\t\t\t\t\t\t\t\t\t":TXT "${exmp}" \
    --field="$(gettext "Definition")":TXT "${defn}" \
    --field="$(gettext "Note")":TXT "${note}" \
    --field="<a href='$link1'>$(gettext "Go to Google Translate")</a>  ":LBL " " \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --field="$(gettext "Definition")!gtk-info":FBTN "${cmd_def}" \
    --button="$(gettext "Image")":"${cmd_image}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Close")":0 |tail -n 1 |tr '\n' ' '
}

function dlg_form_2() {
    if [[ `wc -w <<<"${trgt}"` -lt 4 ]]; then
    t=CHK; lbl_2="$(gettext "It is a compound word")"
    [ -z "${trgt}" ] && trgt="${item_id}"
    else t=LBL; fi
    cmd_play="$DS/play.sh play_sentence ${id}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --separator="|" --selectable-labels \
    --window-icon=idiomind \
    --buttons-layout=end --align=right --center --on-top \
    --width=700 --height=480 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":${t} "$type" \
    --field="$lgtl":TXT "${trgt}" \
    --field="<a href='$link1'>$(gettext "Go to Google Translate")</a>\t":LBL " " \
    --field="$lgsl":TXT "${srce}" \
    --field="\t\t\t$(gettext "Topic")":CB "${tpc_list}" \
    --field="$(gettext "Tag")":CB "${tags_list}" \
    --field="$(gettext "Audio")":FL "${audf}" \
    --button="$(gettext "Words")":"${cmd_words}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Close")":0 |tail -n 1 |tr '\n' ' '
}

function edit_list_list() {
    yad --list --title="$(gettext "Edit list")" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --no-headers --center \
    --width=420 --height=260 --borders=5 \
    --column="" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Reverse List")":2 \
    --button="gtk-apply":0
}

function edit_feeds_list() {
    yad --list --title="${tpc}" \
    --text="$(gettext "Configure feed urls to add content automatically from news headlines.")" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='\n' \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --no-headers --fixed --center \
    --width=550 --height=160 --borders=2 \
    --column="" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Update")":2 \
    --button="$(gettext "Save")":0
}

function progr_3() {
    yad --progress \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}
