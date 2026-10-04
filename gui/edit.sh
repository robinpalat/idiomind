#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#

if [ -n "${__GUI_EDIT_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_EDIT_SH=1


if [ -z "${__GUI_COMMON_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/common.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/common.sh"
fi

function gui_edit_word() {
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
    --field=" ":LBL " " \
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

function gui_edit_sentence() {
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

function gui_edit_list() {

    yad --editable --list --title="$(gettext "Edit list")" \
    --text="<small>$(gettext "Try double click, right-click and drag and drop.")</small>" \
    --name=Idiomind --class=Idiomind \
    --separator='' \
    --always-print-result --print-all \
    --window-icon=$DS/images/logo.png \
    --no-headers --center \
    --width=530 --height=560 --borders=5 \
    --column="" \
    --button="$(gettext "Restart")":"$DS/mngr.sh restart-topic" \
    --button="$(gettext "Backups")":"$DS/mngr.sh edit_list_more" \
    --button="$(gettext "Translate")":2 \
    --button="$(gettext "Save")!document-save":0 \
    --button="$(gettext "Close")":1
}

function gui_edit_progress() {
    yad --progress  \
    --name=Idiomind --class=Idiomind \
    --undecorated --${1} --auto-close \
    --skip-taskbar --center --on-top --no-buttons
}

gui_edit_backups() {
    touch "$DT/edit_list_more"
    file="$HOME/.idiomind/backup/${tpc}.bk"

    dt1=$(grep '\----- newest' "${file}" |cut -d' ' -f3)
    dt2=$(grep '\----- oldest' "${file}" |cut -d' ' -f3)
    if [ -n "$dt2" ]; then
        cols2="!$(gettext "Restore backup:") $dt1!$(gettext "Restore backup:") $dt2"
    elif [ -n "$dt1" ]; then
        cols2="!$(gettext "Restore backup:") $dt1"
    else
        cols2=""
    fi

    optns="$(sed '/^$/d' <<< "$cols2")"
    
    more="$(yad --form --title="$(gettext "Backups")" \
    --field=":CB" "${optns}" --separator="" \
    --name=Idiomind --class=Idiomind \
    --expand-column=2 --no-click --no-headers\
    --window-icon=$DS/images/logo.png --on-top --center \
    --width=390 --borders=5 \
    --column="":TXT \
    --button="$(gettext "Apply")"!gtk-apply:0 \
    --button="$(gettext "Cancel")":1)"
    ret="$?"
    if [ $ret = 0 ]; then
        _war(){ msg_2 "${more}\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"; }

        if grep "$(gettext "Reverse items order")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                "$DS/stop.sh" 5
                edit_list_cmds 2 "${tpc}"
                cleanups "$DT/edit_list_more"
            fi
        elif grep "$(gettext "Remove all items")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                cleanups "$DT/list_output" "$DT/list_input"
                cleanups "${DC_tlt}/data" "${DC_tlt}/index"
                tpc_db 6 'sentences'; tpc_db 6 'words'
                tpc_db 6 'learning'; tpc_db 6 'learnt'
                tpc_db 6 'marks'
                touch "${DC_tlt}/data"
                cleanups "$DT/edit_list_more"
                [ -d "${DM_tlt}" ] && [ -n "$tpc" ] && rm "$DM_tlt"/*.mp3
            fi

        elif grep "$(gettext "Show short sentences in word's view")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                edit_list_cmds 4 "${tpc}"
                cleanups "$DT/edit_list_more"
            fi
        elif grep "$(gettext "Restore backup:")" <<< "${more}"; then
             _war; if [ $? = 0 ]; then
                cleanups "$DT/list_output" "$DT/list_input"
                yad_kill "yad --editable --list"
                if grep ${dt1} <<< "${more}"; then
                    export line=1
                elif grep ${dt2} <<< "${more}"; then
                    export line=2
                fi
                "$DS/ifs/tls.sh" restore "${tpc}" ${line}
                cleanups "$DT/edit_list_more"
            fi
        elif [ -f "$DS/ifs/extensions/topic/${more}.sh" ]; then 
            "$DS/ifs/extensions/topic/${more}.sh" "${more}" # ADDON: $DS/ifs/extensions/topic/ADDON.sh ADDON
        else
            cleanups "$DT/edit_list_more"
        fi
    else
        cleanups "$DT/items_to_add"  \
        "$DT/act_restfile" "$DT/edit_list_more"
    fi
    
} >/dev/null 2>&1
