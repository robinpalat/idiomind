#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#

if [ -n "${__GUI_ADD_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_ADD_SH=1

# Primitivas comunes (documental; check_s/mksure usan msg vía cmns.sh
# del llamador, igual que antes — no se redefine nada aquí).
if [ -z "${__GUI_COMMON_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/common.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/common.sh"
fi

function gui_add_select_topic() {
    if [ -z "${1}" ]; then
        tpcs="$(cdb "${shrdb}" 5 topics |tr "\\n" '!' |sed 's/\!*$//g')"
        tpe="$(yad --form --title="$(gettext "No topic selected")" \
        --name=Idiomind --class=Idiomind \
        --text="$(gettext "Select the topic in which the notes should be added")" \
        --always-print-result --separator="" \
        --skip-taskbar --fixed --center --on-top --align=right \
        --window-icon=idiomind \
        --width=470 --borders=5 \
        --field=":CB" " !$tpcs" \
        --button="$(gettext "OK")":0 |sed -e 's/^ *//' -e 's/ *$//')"
        
        if [ -z "${tpe}" ]; then
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            msg "$(gettext "No topic selected")\n" \
            dialog-information "$(gettext "Information")" & exit 1
        else
            echo "${tpe}" > "$DT/tpe"
            export tpe
        fi
    fi
    DC_tlt="$DM_tl/${tpe}/.conf"
    if [[ $(wc -l < "${DC_tlt}/data") -ge 200 ]]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You've reached the maximum number of notes for this topic. Max allowed (200)")" \
        dialog-information "$(gettext "Information")" & exit
    fi
}

function gui_add_new_topic() {
    yad --form --title="$(gettext "New Topic")" \
    --name=Idiomind --class=Idiomind \
    --separator='|' \
    --window-icon=$DS/images/logo.png \
    --skip-taskbar --fixed --center --on-top \
    --width=450 --height=80 --borders=5 \
    --field="$(gettext "Name")" "$1" \
    --button="$(gettext "OK")":0
}

function gui_add_note_simple() {
    cmd_words="$DS/add.sh list_words_dclik $DT_r "\"${trgt}\"""
    yad --form --title="$(gettext "Add note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="|" \
    --skip-taskbar --fixed --center \
    --buttons-layout=spread --align=right --image="${img}" \
    --window-icon=$DS/images/logo.png \
    --width=470 --borders=1 \
    --field="" "$trgt" \
    --field=":CB" "$tpe!$(gettext "New topic") *$e$tpcs" \
    --button="!$DS/images/add_clipboard.png!$(gettext "Clipboard watcher")":5 \
    --button="!$DS/images/add_image.png!$(gettext "Screen clipping")":3 \
    --button="!$DS/images/add_audio.png!$(gettext "Add an audio file")":2 \
    --button="!$DS/images/add_more.png!$(gettext "Add notes, example and words of a sentence")":4 \
    --button="!document-save!$(gettext "Add")":0
}

function gui_add_note_with_srce() {
    cmd_words="$DS/add.sh list_words_dclik $DT_r "\"${trgt}\"""
    # cmd_words is unused: the words button returns 4 and new_items
    # runs list_words_dclik with the current field values.
    yad --form --title="$(gettext "Add note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="|" \
    --skip-taskbar --fixed --center \
    --buttons-layout=spread --align=right --image="${img}" \
    --window-icon=$DS/images/logo.png \
    --width=470 --borders=1 \
    --field="" "$trgt" \
    --field="" "$srce" \
    --field=":CB" "$tpe!$(gettext "New topic") *$e$tpcs" \
    --button="!$DS/images/add_clipboard.png!$(gettext "Clipboard watcher")":5 \
    --button="!$DS/images/add_image.png!$(gettext "Screen clipping")":3 \
    --button="!$DS/images/add_audio.png!$(gettext "Add an audio file")":2 \
    --button="!$DS/images/add_more.png!$(gettext "Add notes, example and words of a sentence")":4 \
    --button="!document-save!$(gettext "Add")":0
}

function gui_add_checklist_batch() {
    sz=(700 400 300 350)
    fkey=$((RANDOM%80000+10000))
    function _list_2() {
        while read -r aitem; do
            if [ -n "$aitem" ]; then
                if [ "$(echo "$aitem" |wc -c)" -gt ${sentence_chars} ]; then
                    echo -e "FALSE\n<span color='#995B50'>$aitem</span>"
                else
                    echo -e "FALSE\n$aitem"
                fi
            fi
        done < "${1}"
    }
    if [ $Level = 0 ]; then
        inf="$(gettext "Sentence too complex for your learning level, please edit it to simplify or shorten it.")\n"
        img="--image=$DS/images/info.png"
    fi
    _list_2 "${1}" | yad --list --checklist --tabnum=1 --plug="$fkey" \
    --dclick-action="$DS/add.sh 'list_words_dclik'" --multiple \
    --ellipsize=end --wrap-width=${sz[3]} --ellipsize-cols=1 \
    $img --text="<small>$inf</small>" --no-headers --text-align=left \
    --image-on-top --column=" " --column=" " |sed '/^$/d' > "$slt" &
    yad --form --tabnum=2 --plug="$fkey" --columns=2 \
    --separator="" \
    --field=" ":lbl null \
    --field="$(gettext "Add to"):CB" "$2!$(gettext "New topic") *$e$tpcs" &
    yad --paned --key="$fkey" \
    --title="$(wc -l < "${1}") $(gettext "notes found")" \
    --name=Idiomind --class=Idiomind \
    --skip-taskbar --orient=vert --window-icon=$DS/images/logo.png --center \
    --width=${sz[0]} --height=${sz[1]} --borders=5 --splitter=${sz[2]} \
    --button=!'document-edit'!"$(gettext "Edit")":2 \
    --button="$(gettext "Save")!document-save!$(gettext "Save")":0
}

function gui_add_checklist_words() {
    list() {
        echo "${1}" | while read -r word; do
        if [ -n "$word" ]; then
            echo; echo "<span font_desc='Droid Sans 12'>$word</span>"
        fi
        done
    }
    list "${1}" | yad --list --checklist --title="$(gettext "Add words")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png \
    --mouse --on-top --no-headers \
    --text-align=right --buttons-layout=end \
    --width=380 --height=260 --borders=5  \
    --column=" " --column="Select" \
    --button="  $(gettext "Close")  ":0
}

function gui_add_checklist_opts() {
    fkey=$((RANDOM%80000+10000))
    list() {
        echo "${1}" | while read -r word; do
        if [ -n "$word" ]; then
            echo; echo "<span font_desc='Droid Sans 12'>$word</span>"
        fi
        done
    }
    pre_exmp="$trgt"
    if [ $(wc -w <<< "${1}") -le 5 ] && [ $(wc -w <<< "${1}") -gt 1 ]; then
    fl="--field="$(gettext "Show in word viewer")":CHK"; fi
    list "${1}" | yad --list --checklist --tabnum=1 --plug="$fkey" \
    --no-headers --text-align=left --text="$(gettext "Sentence's words")" \
    --column=" " --column=" " |sed '/^$/d' > "$slts" &
    yad --form --tabnum=2 --plug="$fkey" \
    --separator="|" \
    --field="$(gettext "Note")":TXT "${note}" \
    --field="$(gettext "Example (applicable for words only)")":TXT "${pre_exmp}" \
    --field="$(gettext "Mark")":CHK "$fl" & \
    yad --paned --orient=hor --key="$fkey" \
    --title="$(gettext "Options")" \
    --name=Idiomind --class=Idiomind \
    --skip-taskbar --orient=vert \
    --window-icon=$DS/images/logo.png --center --on-top \
    --width=500 --height=260 --borders=5 --splitter=180 \
    --button="  $(gettext "Cancel")  ":1 \
    --button="$(gettext "Save")!document-save!$(gettext "Save")":0

}

function gui_add_edit_text() {
    cat "${1}" |awk '{print "\n"$0}' | \
    yad --text-info --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --editable \
    --window-icon=$DS/images/logo.png \
    --wrap --margins=20 --fontname='vendana 11' \
    --skip-taskbar --center --on-top \
    --width=700 --height=450 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")!document-save!$(gettext "Save")":0 
}

function gui_add_confirm_play() {
    cmd_listen="$DS/play.sh play_word "\"${3}\"""
    [ -n "$5" ] && title="$5" || title=Idiomind
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=$DS/images/logo.png \
    --image-on-top --on-top --sticky --center \
    --width=400 --height=120 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Play")":"$cmd_listen" \
    --button="$(gettext "Yes")":0
}

function gui_add_unadded_notes() {
    echo -e "${1}" | yad --text-info \
    --title="$(gettext "Some notes could not be added to your list")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png \
    --image="face-worried" \
    --wrap --margins=5 \
    --fixed --center --on-top \
    --width=450 --height=150 --borders=5 \
    "${3}" --button="$(gettext "Close")":1
}

function gui_add_image() {
    yad --form --title=$(gettext "Image") "$image" "$label" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=spread --skip-taskbar --image-on-top \
    --align=center --text-align=center --center --on-top \
    --width=420 --height=320 --borders=5 \
    "${btn2}" --button="$(gettext "Close")!window-close!$(gettext "Close") ":1
}

function gui_add_progress() {
    yad --progress \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png \
    --progress-text="$1" \
    --pulsate --auto-close \
    --undecorated --skip-taskbar --no-buttons \
    --on-top --mouse --fixed
}
