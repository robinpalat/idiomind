#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source $DS/ifs/cmns.sh
source $DS/default/sets.cfg
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
sz=(450 450)

export_topic() {
    export_tpc="${1}"

    dlg_export() {
        yad --form --title="$(gettext "Export topic")" \
        --text="$text_export" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=$DS/images/logo.png --buttons-layout=end \
        --align=right --center \
        --width=${sz[0]} --height=${sz[1]} --borders=18 \
        --field="$(gettext "Author")" "$autr" \
        --field="$(gettext "Category"):CBE" "$_Categories" \
        --field="$(gettext "Skill Level"):CB" "$_levels" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Format"):CB" "$_formats" \
        --field="$(gettext "Include images and audio"):CHK" "$include_media" \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    }

    sv_data() {
        tpc_db 9 id autr "${autr_mod}"
        tpc_db 9 id ctgy "${ctgy}"
        tpc_db 9 id levl "${levl}"
        if [ "${note}" != "${note_mod}" ]; then
            if ! grep '^$' <<< "${note_mod}"; then
                echo -e "\n${note_mod}" > "${DC_tlt}/note"
            else
                echo "${note_mod}" > "${DC_tlt}/note"
            fi
        fi
    }

    ctgy=$(tpc_db 1 id ctgy)
    levl=$(tpc_db 1 id levl)
    text_export="<span font_desc='Arial 12'><b>$(gettext "Export this topic")</b></span>\n<small>$(gettext "The topic will be saved locally so you can share it with other Idiomind users.")</small>"

    em='!'; unset list
    for val in "${Categories[@]}"; do
        declare clocal="$(gettext "${val}")"
        list="${list}${em}${clocal}"
    done
    _Categories="${ctgy}${list}"
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    _levels="!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")"
    if [ -n "$levl" ]; then
        level="${lv[${levl}]}"
        _levels="$level"$(sed "s/\!$level//g" <<< "$_levels")
    fi
    
	export_dir="$DS/ifs/mods/export"
	_formats=""
	declare -A export_modules

	while IFS= read -r -d '' file; do
		module="${file##*/}"
		module="${module%.sh}"

		case "$module" in
			"Idiomind Topic (idmnd)")
				format="$(gettext "Idiomind Topic (.idmnd)")"
				;;
			"Comma-separated values (csv)")
				format="CSV"
				;;
			"Tab-separated values (tsv)")
				format="TSV"
				;;
			*)
				format="$module"
				;;
		esac

		export_modules["$format"]="$module"

		if [[ -z "$_formats" ]]; then
			_formats="$format"
		else
			_formats="${_formats}!${format}"
		fi

	done < <(
		find "$export_dir" -maxdepth 1 -type f -name '*.sh' -print0 |
		sort -z
	)

    note=$(< "${DC_tlt}/note" 2>/dev/null)
    autr=$(tpc_db 1 id autr)
    include_media="FALSE"
    [ -n "$(tpc_db 1 id naud)" ] && include_media="TRUE"

    shopt -s extglob
    dlg="$(dlg_export)"
    ret=$?

    if [ $ret = 4 ]; then
        exit 1
    elif [ $ret = 2 ]; then
        autr_mod=$(echo "${dlg}" |cut -d "|" -f1)
        ctgy=$(echo "${dlg}" |cut -d "|" -f2)
        levl=$(echo "${dlg}" |cut -d "|" -f3)
        note_mod=$(echo "${dlg}" |cut -d "|" -f4)
        format=$(echo "${dlg}" |cut -d "|" -f5)
        media_opt=$(echo "${dlg}" |cut -d "|" -f6)

        for val in "${Categories[@],}"; do
            [ "${ctgy^}" = "$(gettext "${val^}")" ] && ctgy="${val// /_}"
        done
        [ "$levl" = "$(gettext "Beginner")" ] && levl=0
        [ "$levl" = "$(gettext "Intermediate")" ] && levl=1
        [ "$levl" = "$(gettext "Advanced")" ] && levl=2
        [ "$media_opt" = TRUE ] && include_media=1 || include_media=0

        sv_data

		format=$(echo "${dlg}" | cut -d "|" -f5)
		module="${export_modules[$format]}"

		_export "${module}" "${include_media}"
    fi
} >/dev/null 2>&1

fdlg() {
    module="$1"
    key=$((RANDOM%100000)); cd "$HOME"
    yad --file --save --filename="$HOME/$tpc" --tabnum=1 --plug="$key" &
    yad --form --tabnum=2 --plug="$key" \
    --separator="" --align=right \
    --field="\t\t\t\t$(gettext "Export to"):CB" "$module" &
    yad --paned --key="$key" --title="$(gettext "Export")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png --center --on-top \
    --width=650 --height=480 --borders=8 --splitter=370 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}

_export() {
    module="$1"; media="$2"
    dlg="$(fdlg "$module")"; ret=$?
    if [ $ret -eq 0 ]; then
        "$DS/ifs/mods/export/${module}.sh" \
        "$(tail -n 1 <<< "$dlg")" "${tpc}" "$media" & return 0
    fi
} >/dev/null 2>&1

case "$1" in
    export|upld)
    export_topic "$@" ;;
    _export)
    _export "$@" ;;
esac
