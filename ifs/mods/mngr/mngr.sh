#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_form_1() {
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${id}"
    [ -z "${trgt}" ] && trgt="${item_id}"
    yad --form --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --align=left --text-align=center --columns=2 \
    --buttons-layout=end --scroll --center --on-top \
    --width=680 --height=520 --borders=10 \
    --field="<small>$lgtl</small>" "${trgt}" \
    --field="<small>$lgsl</small>" "${srce}" \
    --field="<small>$(gettext "Topic")</small>":CB "${tpc_list}" \
    --field="<small>$(gettext "Audio")</small>":FL "${audf}" \
    --field="<small>$(gettext "Example")</small>\t\t\t\t\t\t\t\t\t\t\t":TXT "${exmp}" \
    --field="<small>$(gettext "Definition")</small>":TXT "${defn}" \
    --field="<small>$(gettext "Note")</small>":TXT "${note}" \
    --field="<small>$(gettext "Search")  <a href='$link1'>$(gettext "Translation")</a>  </small>":LBL " " \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field="<small>$(gettext "Tag")</small>":CB "${tags_list}" \
    --field="$(gettext "Definition")!info":FBTN "${cmd_def}" \
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
    --always-print-result --print-all --separator="|" --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --buttons-layout=end --align=right --center --on-top \
    --width=600 --height=420 --borders=10 \
    --field="$(gettext "Mark")":CHK "$mark" \
    --field=" $lbl_2":${t} "$type" \
    --field="<small>$lgtl</small>":TXT "${trgt}" \
    --field="<small><a href='$link1'>$(gettext "Translation")</a></small>\t":LBL " " \
    --field="<small>$lgsl</small>":TXT "${srce}" \
    --field="<small>$(gettext "Topic")</small>":CB "${tpc_list}" \
    --field="<small>$(gettext "Tag")</small>":CB "${tags_list}" \
    --field="<small>$(gettext "Audio")</small>":FL "${audf}" \
    --button="$(gettext "Words")":"${cmd_words}" \
    --button="$(gettext "Delete")":"${cmd_delete}" \
    --button="!$DS/images/listen.png!$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Close")":0 |tail -n 1 |tr '\n' ' '
}

function edit_list_list() {
    yad --list --title="$(gettext "Edit list")" \
    --text="$(gettext "You can move any item by dragging and dropping or double click to edit it further. Close and reopen the main window to see any changes.")" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='' \
    --always-print-result --print-all \
    --window-icon="$DS/images/icon.png" \
    --no-headers --center \
    --width=420 --height=280 --borders=5 \
    --column="" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Reverse List")":2 \
    --button="gtk-apply":0
}

function edit_feeds_list() {
    yad --list --title="$(gettext "Feeds")" \
    --text="$(gettext "Configure feed urls to add content automatically from news headlines.")" \
    --name=Idiomind --class=Idiomind \
    --editable --separator='\n' \
    --always-print-result --print-all \
    --window-icon="$DS/images/icon.png" \
    --no-headers --center \
    --width=500 --height=190 --borders=2 \
    --column="" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0
}

function progr_3() {
    yad --progress \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}
