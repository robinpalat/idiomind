#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
include "$DS/ifs/mods/add"
wlist="$(cdb "${cfgdb}" 1 opts wlist)"
trans="$(cdb "${cfgdb}" 1 opts trans)"
ttrgt="$(cdb "${cfgdb}" 1 opts ttrgt)"
dlaud="$(cdb "${cfgdb}" 1 opts dlaud)"
[ -z "$trans" ] && trans='FALSE'
export ttrgt trans lgt lgs

new_topic() {
    [ -z "$2" ] && mode=1 || mode=$2
    [ -z "$3" ] && activ=1 || activ=$3
    [ -n "$4" ] && name="${4}"
    listt="$(cd "$DM_tl"; find ./ -maxdepth 1 -type d \
    ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"
    if [[ $(wc -l <<< "${listt}") -ge 120 ]]; then
        msg "$(gettext "Maximum number of topics reached.")" \
        dialog-information "$(gettext "Information")" & exit 1
    fi
	source "$DS/ifs/mods/add/add.sh"

	if [[ -z "$name" ]]; then
		to=0; while [ ${to} -lt 4 ]; do
			if [[ -z "$name" ]]; then add="$(dlg_form_0)"
			else add="$(dlg_form_0 "$name")"; fi
			name="$(clean_3 "$(cut -d "|" -f1 <<< "${add}")")"
			if [[ ${#name} -gt 55 ]]; then
				msg "$(gettext "Sorry, the name is too long.")\n" \
				dialog-information "$(gettext "Information")"
			else 
				export name & break
			fi
			let to++
		done
	fi
    if [[ ${#name} -gt 55 ]]; then name="Untitled"; fi
    if grep -Fxo "${name}" < <(ls "$DS/addons/"); then name="${name} (1)"; fi
    chck=$(grep -Fxo "${name}" <<< "${listt}" |wc -l)
    if [[ ${chck} -ge 1 ]]; then
        for i in {1..50}; do
        chck=$(grep -Fxo "${name} ($i)" <<< "${listt}")
        [ -z "${chck}" ] && break; done
        name="${name} ($i)"
    else
        name="${name}"
    fi
    if [ -z "${name}" ]; then 
        return 1
    else
        mkdir -p "$DM_tl/${name}"
        check_list
        "$DS/ifs/tpc.sh" "${name}" "$mode" "$activ"
        "$DS/mngr.sh" mkmn 0
    fi
}

function new_item() {
    export tpe
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    if [ ! -d "$DT_r" ]; then
		mkdir "$DT_r"; cd "$DT_r"
    fi
    check_s "${tpe}"
    if [ -z "${trgt}" ]; then trgt="${3}"; fi
    
    if [[ ${trans} = FALSE ]] && [ -z "${srce}" -o -z "${trgt}" ]; then
        cleanups "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" \
        dialog-information "$(gettext "Information")" & exit 1
    fi
    if grep -o -E 'ja|zh-cn|ru' <<< "$lgt" >/dev/null 2>&1 ; then
        srce=$(translate "${trgt}" auto $lgs)
        [ -z "${srce}" ] && internet
        if [ $(wc -w <<< "${srce}") = 1 ]; then
            new_word
        elif [ $(wc -w <<< "${srce}") -ge 1 -a ${#srce} -le ${sentence_chars} ]; then
            new_sentence
        fi
    elif ! grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
        if [ $(wc -w <<< "${trgt}") = 1 ]; then
            new_word
        elif [ $(wc -w <<< "${trgt}") -ge 1 -a ${#trgt} -le ${sentence_chars} ]; then
            new_sentence
        fi
    fi
}

function new_sentence() {
    export db="$DS/default/dicts/$lgt"
    export trgt="$(clean_2 "${trgt}")"
    export srce="$(clean_2 "${srce}")"

    if [[ ${trans} = TRUE ]]; then
        if [[ ${ttrgt} = TRUE ]]; then
            _trgt="$(translate "${trgt,,}" auto $lgt)"
            [ -n "${_trgt}" ] && trgt=$(clean_2 "${_trgt}")
        fi
        srce="$(translate "${trgt,,}" $lgt $lgs)"
        [ -z "${srce}" ] && internet
        srce="$(clean_2 "${srce}")"
        export trgt="${trgt^}"
        export srce="${srce^}"
    else 
        if [ -z "${srce}" -o -z "${trgt}" ]; then
        cleanups "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" \
        dialog-information "$(gettext "Information")" & exit; fi
    fi
    sentence_p 1
    export cdid="$(set_name_file 2 "${trgt}" "${srce}" "" "" "" "${wrds}" "${grmr}")"
    mksure "${trgt}" "${srce}" "${grmr}" "${wrds}"

    if [ $? = 1 ]; then
        echo -e "${trgt}" >> "${DC_tlt}/note_err"
        cleanups "$DT_r"; exit 1
    else
        notify-send -i idiomind "${trgt}" "${srce}\\n(${tpe})" -t 10000 &
       if [ -e "$DT_r/__opts__" ]; then
			opts="$(< "$DT_r/__opts__")"
			export note="$(clean_2 "$(cut -d "|" -f1 <<< "${opts}")")"
			export exmp="$(clean_2 "$(cut -d "|" -f2 <<< "${opts}")")"
			export mark="$(clean_2 "$(cut -d "|" -f3 <<< "${opts}")")"
		fi
        index 2
        if [ -e "$DT_r/img.jpg" ]; then
            set_image_2 "$DT_r/img.jpg" "${DM_tlt}/images/${trgt,,}.jpg"
        fi
        if [ ! -e "$DT_r/audtm.mp3" ]; then
            if [[ ${dlaud} = TRUE ]]; then
                tts_sentence "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                if [ ! -e "${DM_tlt}/$cdid.mp3" ]; then
                    voice "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                fi
            else
                voice "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                if [ $? = 1 ]; then
                    [[ ${dlaud} = TRUE ]] && tts_sentence "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                fi
            fi
        else
            mv -f "$DT_r/audtm.mp3" "${DM_tlt}/$cdid.mp3"
        fi

        ( if [[ ${wlist} = TRUE ]] && [ -n "${wrds}" ]; then
            list_words_sentence; fi ) &
        [[ ${dlaud} = TRUE ]] && fetch_audio "$aw" "$bw"
        cleanups "$DT_r"
    fi
}

function new_word() {
    export trgt="$(clean_1 "${trgt}")"
    export srce="$(clean_0 "${srce}")"

    if [[ ${trans} = TRUE ]]; then
        if [[ ${ttrgt} = TRUE ]]; then
            _trgt="$(translate "${trgt}" auto $lgt)"
            [ -n "${_trgt}" ] && export trgt="$(clean_1 "${_trgt}")"
        fi
        srce="$(translate "${trgt}" $lgt $lgs)"
        [ -z "${srce}" ] && internet
        export srce="$(clean_0 "${srce}")"
    else 
        if [ -z "${srce}" -o -z "${trgt}" ]; then
        cleanups "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" \
        dialog-information "$(gettext "Information")" & exit; fi
    fi

    audio="${trgt,,}"
    export cdid="$(set_name_file 1 "${trgt}" "${srce}" "${exmp}" "" "" "" "")"
    export exmp="$(sqlite3 "$tlngdb" "select Example from Words where Word is '${trgt}';")"
    mksure "${trgt}" "${srce}"
    
    if [ $? = 1 ]; then
        echo -e "${trgt}" >> "${DC_tlt}/note_err"
        cleanups "$DT_r"; exit 1
    else
		if [ -e "$DT_r/__opts__" ]; then
			opts="$(< "$DT_r/__opts__")"
			export note="$(clean_2 "$(cut -d "|" -f1 <<< "${opts}")")"
			export exmp="$(clean_2 "$(cut -d "|" -f2 <<< "${opts}")")"
			export mark="$(clean_2 "$(cut -d "|" -f3 <<< "${opts}")")"
		fi
        index 1
        notify-send -i idiomind "${trgt}" "${srce}\\n(${tpe})" -t 10000
        if [ -e "$DT_r/img.jpg" ]; then
            if [ -e "${DM_tls}/images/${trgt,,}-1.jpg" ]; then
                n=$(ls "${DM_tls}/images/${trgt,,}-"*.jpg |wc -l); n=$(($n+1))
                name_img="${DM_tls}/images/${trgt,,}-"${n}.jpg
            else
                name_img="${DM_tls}/images/${trgt,,}-1.jpg"
            fi
            set_image_2 "$DT_r/img.jpg" "$name_img"
        fi
        if [ ! -e "$DT_r/audtm.mp3" ]; then
            if [ ! -e "${DM_tls}/audio/${audio}.mp3" ]; then
                [[ ${dlaud} = TRUE ]] && tts_word "${audio}" "${DM_tls}/audio"
            fi
        else
            if [ -e "${DM_tls}/audio/${audio}.mp3" ]; then
                msg_3 "$(gettext "A file named "${audio}.mp3" already exists, do you want to replace it?")\n" \
                dialog-question "${trgt}"
                if [ $? -eq 0 ]; then
                    cp -f "$DT_r/audtm.mp3" "${DM_tls}/audio/${audio}.mp3"
                fi
            else
                cp -f "$DT_r/audtm.mp3" "${DM_tls}/audio/${audio}.mp3"
            fi
        fi
        word_p
        img_word "${trgt}" "${srce}" &
        cleanups "${DT_r}"
    fi
}

function list_words_edit() {
    include "$DS/ifs/mods/add"
    tpe="${tpc}"
    exmp="${3}"
    [ -z "${exmp}" ] && exmp="${trgt}"
    check_s "${tpe}"
    DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
    words="$(list_words_2 "${2}")"
    slt="$(dlg_checklist_1 "${words}")"
    if [ $? -eq 0 ]; then
        while read -r chkst; do
            if [ -n "$chkst" ]; then
            sed 's/TRUE//;s/<[^>]*>//g;s/|//g' <<< "${chkst}" >> "$DT_r/select_lines"
            fi
        done <<< "${slt}"
    fi
    
    n=1
    while read -r trgt; do
        if [ "$(wc -l < "${DC_tlt}/data")" -ge 200 ]; then
            echo -e "\n\n$n) [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> "${DC_tlt}/note_err"
        elif [ -z "$(< "$DT_r/select_lines")" ]; then
            cleanups "${DT_r}"; exit 0
        else
            export trgt="$(clean_1 "${trgt}")"
            audio="${trgt,,}"
            translate "${trgt}" auto $lgs > "$DT_r/tr"
            srce=$(< "$DT_r/tr"); [ -z "${srce}" ] && internet
            export srce="$(clean_0 "${srce}")"
            export cdid="$(set_name_file 1 "${trgt}" "${srce}" "${exmp}" "" "" "" "")"
            mksure "${trgt}" "${srce}"

            if [ $? = 0 ]; then
                index 1
                if [ ! -e "$DM_tls/audio/$audio.mp3" ]; then
                    ( [[ ${dlaud} = TRUE ]] && tts_word "$audio" "$DM_tls/audio" )
                fi
                ( img_word "${trgt}" "${srce}" ) &
            else
                echo -e "\n$trgt" >> "${DC_tlt}/note_err"
                cleanups "${DM_tlt}/$cdid.mp3"
            fi
        fi
        let n++
    done < <(head -200 < "$DT_r/select_lines")
    cleanups "${DT_r}"; exit 0
    
} >/dev/null 2>&1

function list_words_sentence() {
    exmp="${trgt}"
    c=$((RANDOM%100))
    DT_r=$(mktemp -d "$DT/XXXXXX")
    wrds="$(list_words_2 "${wrds}")"
    if [ -n "${wrds}" ]; then
        slt="$(dlg_checklist_1 "${wrds}")"
    else
        return 1
    fi
        if [ $? -eq 0 ]; then
            while read -r chkst; do
                if [ -n "$chkst" ]; then
                sed 's/TRUE//;s/<[^>]*>//g;s/|//g' <<< "${chkst}" >> "$DT_r/select_lines"
                fi
            done <<< "${slt}"
        elif [ $? -eq 1 ]; then
            rm -f "$DT"/*."$c"
            cleanups "$DT_r"
            exit 1
        fi
    [ ! -e "$DT_r/select_lines" ] && return 1
    n=1
    while read -r trgt; do
        if [ $(wc -l < "${DC_tlt}/data") -ge 200 ]; then
            echo -e "\n$trgt" >> "${DC_tlt}/note_err"
        elif [ -z "$(< "$DT_r/select_lines")" ]; then
            cleanups "${DT_r}"; exit 0
        else
            export trgt="$(clean_1 "${trgt}")"
            audio="${trgt,,}"
            translate "${trgt}" auto $lgs > "$DT_r/tr.$c"
            srce=$(< "$DT_r/tr.$c"); [ -z "${srce}" ] && internet
            export srce="$(clean_0 "${srce}")"
            export cdid="$(set_name_file 1 "${trgt}" "${srce}" "${exmp}" "" "" "" "")"
            mksure "${trgt}" "${srce}"
            
            if [ $? = 0 ]; then
                index 1
                if [ ! -e "$DM_tls/audio/$audio.mp3" ]; then
                    ( [[ ${dlaud} = TRUE ]] && tts_word "${audio}" "${DM_tls}/audio" )
                fi
                ( img_word "${trgt}" "${srce}" ) &
            else
                echo -e "\n$trgt" >> "${DC_tlt}/note_err"
            fi
        fi
        let n++
    done < <(head -200 < "$DT_r/select_lines")
    cleanups "$DT_r"; exit 0
}

function list_words_dclik() {
    source "$DS/ifs/mods/add/add.sh"
    words="$(sed 's/<[^>]*>//g' <<< "${3}")"
    [[ -d "$2"  ]] && DT_r="$2"
    [ ! -d "$DT_r" ] && mkdir "$DT_r"
    export DT_r

	if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
		( echo "#"
		echo "# $(gettext "Processing")..." ;
		export srce="$(translate "${words}" $lgt $lgs)"
		[ -z "${srce}" ] && internet
		sentence_p 1
		echo "$wrds"
		list_words_3 "${words}" "${wrds}"
		) | dlg_progress_1
	else
		list_words_3 "${words}"
	fi
	export wrds="$(< "$DT_r/lst")"
	[ $(wc -l <<< "$wrds") = 1 ] && wrds=""

    if [[ -d "$2"  ]]; then
		if [[ -n "$words" ]]; then
			slts=$(mktemp "$DT/cnf1.XXXXXX")
			opts="$(dlg_checklist_2 "${wrds}")"
			if [ $? -eq 0 ]; then
				echo "$opts" > "$DT_r/__opts__"
				while read -r chkst; do
					if [ -n "$chkst" ]; then
					sed 's/TRUE//;s/<[^>]*>//g;s/|//g' <<< "${chkst}" >> "$DT_r/wrds"
					echo "${words}" >> "$DT_r/wrdsls"
					fi
				done < "${slts}"
				cleanups "${slts}"
			fi
			process '__words__'
		fi
    else
		if [[ -n "$wrds" ]]; then
			slt="$(dlg_checklist_1 "${wrds}")"
			if [ $? -eq 0 ]; then
				while read -r chkst; do
					if [ -n "$chkst" ]; then
					sed 's/TRUE//;s/<[^>]*>//g;s/|//g' <<< "${chkst}" >> "$DT_r/wrds"
					echo "${words}" >> "$DT_r/wrdsls"
					fi
				done <<< "${slt}"
			fi
		fi
    fi
    exit 0
    
} >/dev/null 2>&1

function process() {
	 if [ ! -d "$DT_r" ] ; then
		mkdir "$DT_r"; cd "$DT_r"
    fi
    echo "${tpe}" > "$DT/n_s_pr"
    export ns=$(wc -l < "${DC_tlt}/data")
    export db="$DS/default/dicts/$lgt"

    if [ -n "${trgt}" ]; then
        conten="${trgt}"
    else
        conten="${1}"
    fi
    include "$DS/ifs/mods/add_process"
    
    if [[ "$1" = '__words__' ]]; then 
		ret=0; conten="${1}"
    elif [[ $conten != '__edit__' ]]; then
    
        if [[ $1 = image ]]; then
            pars=`mktemp`
            trap rm "$pars*" EXIT
            /usr/bin/import "$DT_r/img_.png"
            /usr/bin/convert "$DT_r/img_.png" -shave 1x1 "$pars.png"
            ( echo "#"
            mogrify -modulate 100,0 -resize 400% "$pars.png"
            tesseract "$pars.png" "$pars" -l ${tesseract_lngs[$tlng]} &> /dev/null
            if [ $? != 0 ]; then
                info="$(gettext "The package 'tesseract-ocr' is not installed\nPlease install") <b>tesseract-ocr-${tesseract_lngs[$tlng]}</b> $(gettext "and try again.")"
                msg "${info}" error "$(gettext "Error")"; cleanups "$DT/n_s_pr" "$DT_r" & exit 0
            fi
            clean_6 < "$pars.txt" > "$DT_r/xxlines"
            rm -f "$pars".png "$DT_r"/img_.png
            ) | dlg_progress_1
        else
            if [[ ${#conten} = 1 ]]; then
                cleanups "$DT_r" "$DT/n_s_pr"; return 1; 
            fi
            if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
                echo "${conten}" |clean_7 > "$DT_r/xxlines"; epa=0
            else
                echo "${conten}" |clean_8 > "$DT_r/xxlines"; epa=1
            fi
        fi
        [ -e "$DT_r/xlines" ] && rm -f "$DT_r/xlines"
        if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
            lenght() {
                if [ $(wc -c <<< "${1}") -le ${sentence_chars} ]; then
                    echo -e "${1}" >> "$DT_r/xlines"
                else
                    echo -e "${1}" >> "$DT_r/xlines"
                fi
            }
        else
            lenght() {
                if [ $(wc -c <<< "${1}") -le ${sentence_chars} ]; then
                    [ ${#1} -gt 1 ] && echo -e "${1}" >> "$DT_r/xlines"
                else
                    echo -e "${1}" >> "$DT_r/xlines"
                fi
            }
        fi
        if [ ${#@} -lt 4 ]; then
            while read l; do
                if [ $(wc -c <<< "${l}") -gt 140 ]; then
                    if grep -o -E '\,|\;' <<< "${l}" >/dev/null 2>&1; then
						while read -r A; do
							if [ $(wc -c <<< "${A}") -le 140 ]; then
								lenght "${A}"
							else									
								while read -r B; do
									if [ $(wc -c <<< "${B}") -le 140 ]; then
										lenght "${B}"
									else
										while read -r C; do
										  if [ $(wc -c <<< "${C}") -le 140 ]; then
												lenght "${C}"
											else
												while read -r D; do
													lenght "${D}"
												done < <(sed 's/\—/\—\n/g' <<< "${C}")
											fi
										done < <(sed 's/\;/\;\n/g' <<< "${B}")
									fi
								done < <(sed 's/\,/\,\n/g' <<< "${A}")
							fi
                        done < <(sed 's/\,"/\,"\n/g' <<< "${l}")
                    else
                        lenght "${l}"
                    fi
                else
                    lenght "${l}"
                fi
            done < "$DT_r/xxlines"
        else 
            mv "$DT_r/xxlines" "$DT_r/xlines"
            sed -i '/^$/d' "$DT_r/xlines"
        fi
    else 
        echo "${2}" > "$DT_r/xlines"
        sed -i '/^$/d' "$DT_r/xlines"
    fi
    if [ -z "$(< "$DT_r/xlines")" ] && [[ $conten != '__words__' ]]; then
        msg "$(gettext "Failed to get text.")\n" \
        dialog-information "$(gettext "Information")"
        cleanups "$DT_r" "$DT/n_s_pr" "$slt" & exit 1
    elif [[ $conten != '__words__' ]]; then
        xclip -i /dev/null
        export slt=$(mktemp $DT/slt.XXXXXX.x)
        tpcs="$(cdb "${shrdb}" 5 topics)"
        export tpcs="$(grep -vFx "${tpe}" <<< "$tpcs" |tr "\\n" '!' |sed 's/\!*$//g')"
        [ -n "$tpcs" ] && export e='!'
        tpe="$(dlg_checklist_3 "$DT_r/xlines" "${tpe}")"
        ret="$?"
    fi
    if [ $ret -eq 2 ]; then
        cleanups "$slt"
        txt="$(dlg_text_info_1 "$DT_r/xlines")"
            ret=$?
            if [ $ret -eq 0 ]; then
                unset trgt; process __edit__ "${txt}"
            else
                unset trgt; process "$(< "$DT_r/xlines")"
            fi
    elif [ $ret -eq 0 ]; then
        unset link
        touch "$DT_r/select_lines"
        if [ "${tpe}" = "$(gettext "New") *" ]; then
			new_topic
            source $DS/default/c.conf
        else
            echo "${tpe}" > "$DT/tpe"
        fi
        export DM_tlt="$DM_tl/${tpe}"
        export DC_tlt="$DM_tl/${tpe}/.conf"
        if [ ! -d "${DM_tlt}" ]; then
            msg "$(gettext "An error occurred.")\n" "face-worried" "$(gettext "Information")"
            cleanups "$DT_r" "$DT/n_s_pr" "$slt" & exit 1
        fi
        while read -r chkst; do
            [ -n "$chkst" ] && sed 's/TRUE//g;s/|//g' <<< "${chkst}" >> "$DT_r/select_lines"
        done < "${slt}"
        cleanups "$slt"

        touch "$DT_r/wlog" "$DT_r/slog" "$DT_r/adds" \
        "$DT_r/addw" "$DT_r/wrds"
        
        cnta=$(sed '/^$/d' "$DT_r/select_lines" |wc -l)
        cntb=$(sed '/^$/d' "$DT_r/wrds" |wc -l)
        
        if [ -n "$(< "$DT_r/select_lines")" -o -n "$(< "$DT_r/wrds")" ]; then
            number_items=$((cnta+cntb))
            ( sleep 1; notify-send -i idiomind \
            "$(gettext "Adding $number_items notes")" \
            "$(gettext "Please wait till the process is completed")" )
        else
			[[ $conten != '__words__' ]] && cleanups "$DT_r"
            cleanups "$DT/n_s_pr" "$slt" & exit 1
        fi
        
        if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then c=c; else c=w; fi
        lns="$(cat "$DT_r/select_lines" "$DT_r/wrds" |sed '/^$/d' |wc -l)"
        n=1
        while read -r trgt; do
            export trgt="$(clean_2 "${trgt}")"
            if [[ ${ttrgt} = TRUE ]]; then
                trgt="$(translate "${trgt}" auto $lgt)"
                export trgt="$(clean_2 "${trgt}")"
            fi
            srce="$(translate "${trgt}" $lgt $lgs)"
            [ -z "${srce}" ] && internet
            export srce="$(clean_2 "${srce}")"
            export cdid="$(set_name_file 2 "${trgt}" "${srce}" "" "" "" "" "")"
            
            
            if [[ $(wc -l < "${DC_tlt}/data") -ge 200 ]]; then
                echo -e "\n\n$n) [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> "$DT_r/slog"
            else
                if [[ $(wc -$c <<< "${trgt}") = 1 ]]; then
                    export trgt="$(clean_1 "${trgt}")"
                    export srce="$(clean_0 "${srce}")"
                    exmp="$(sqlite3 "$tlngdb" "select Example from Words where Word is '${trgt}';")"
                    export exmp="$(echo "$exmp" |tr '\n' ' ')"
                    export cdid="$(set_name_file 1 "${trgt}" "${srce}" "" "" "" "" "")"
                    audio="${trgt,,}"
                    mksure "${trgt}" "${srce}"
                    
                    if [ $? = 0 ]; then
                        index 1
                        ( [[ ${dlaud} = TRUE ]] && tts_word "${audio}" "${DM_tlt}" ) &&
                        if [ -e "${DM_tlt}/${audio}.mp3" ]; then
                            mv "${DM_tlt}/${audio}.mp3" "${DM_tlt}/$cdid.mp3"
                        else
                            if [ -e "${DM_tls}/audio/${audio}.mp3" ]; then
                            cp "${DM_tls}/audio/${audio}.mp3" "${DM_tlt}/$cdid.mp3"
                            fi
                        fi
                        ( img_word "${trgt}" "${srce}" ) &
                        echo "${trgt}" >> "$DT_r/addw"
                    else
                        echo -e "\n\n$n) ${trgt}" >> "$DT_r/wlog"
                        rm "${DM_tlt}/$cdid.mp3"
                    fi
                elif [[ $(wc -$c <<< "${trgt}") -ge 1 ]]; then
                    
                    if [ ${#trgt} -ge ${sentence_chars} ]; then
                        echo -e "\n\n$n) [$(gettext "Sentence too long")] $trgt" >> "$DT_r/slog"
                    else
                        ( export DT_r; sentence_p 1
                        export cdid="$(set_name_file 1 "${trgt}" "${srce}" "" "" "" "${wrds}" "${grmr}")"
                        mksure "${trgt}" "${srce}" "${wrds}" "${grmr}"
                        
                        if [ $? = 0 ]; then
                            index 2
                            if [[ ${dlaud} = TRUE ]]; then
                                tts_sentence "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                                [ ! -e "${DM_tlt}/$cdid.mp3" ] && voice "${trgt}" "$DT_r" "${DM_tlt}/$cdid.mp3"
                            else 
                                voice "${trgt}" "${DT_r}" "${DM_tlt}/$cdid.mp3"
                            fi #TODO
                            ( [[ ${dlaud} = TRUE ]] && fetch_audio "$aw" "$bw" )
                            echo "${trgt}" >> "$DT_r/adds"
                            ((adds=adds+1))
                        else
                            echo -e "\n\n$n) $trgt" >> "$DT_r/slog"
                            rm "${DM_tlt}/$cdid.mp3"
                        fi
                        rm -f "$aw" "$bw" )
                    fi
                fi
            fi
            let n++
        done < <(head -200 < "$DT_r/select_lines")
        
        if [ -s "$DT_r/wrds" ]; then
            n=1
            while read -r trgt; do
                export exmp=$(sed -n ${n}p "$DT_r/wrdsls" |sed 's/\[ \.\.\. \]//g')
                export trgt=$(echo "${trgt,,}" |sed 's/^\s*./\U&\E/g')
                audio="${trgt,,}"
                
                if [[ $(wc -l < "${DC_tlt}/data") -ge 200 ]]; then
                    echo -e "\n\n$n) [$(gettext "Maximum number of notes has been exceeded")] ${trgt}" >> "$DT_r/wlog"
                else
                    export srce="$(translate "${trgt}" auto $lgs)"
                    [ -z "${srce}" ] && internet
                    export cdid="$(set_name_file 1 "${trgt}" "${srce}" "${exmp}" "" "" "" "")"
                    mksure "${trgt}" "${srce}"
                    if [ $? = 0 ]; then
                        index 1
                        if [ ! -e "${DM_tls}/audio/$audio.mp3" ]; then
                        ( [[ ${dlaud} = TRUE ]] && tts_word "$audio" "${DM_tls}/audio" )
                        ( img_word "${trgt}" "${srce}" ) & fi
                        echo "${trgt}" >> "$DT_r/addw"
                    else
                        echo -e "\n\n$n) $trgt" >> "$DT_r/wlog"
                        cleanups "${DM_tlt}/$cdid.mp3"
                    fi
                fi
                let n++
            done < <(head -200 < "$DT_r/wrds")
        fi

        if  [ $? != 0 ]; then
            "$DS/stop.sh" 5
        fi
        a=$(sed '/^$/d' "$DT_r/addw" |wc -l)
        b=$(sed '/^$/d' "$DT_r/wlog" |wc -l)
        wadds=" $((a-b))"
        W=" $(gettext "words")"
        if [[ ${wadds} = 1 ]]; then
            W=" $(gettext "word")"
        fi
        a=$(sed '/^$/d' "$DT_r/adds" |wc -l)
        b=$(sed '/^$/d' "$DT_r/slog" |wc -l)
        sadds=" $((a-b))"
        S=" $(gettext "sentences")"
        if [[ ${sadds} = 1 ]]; then
            S=" $(gettext "sentence")"
        fi
        log=$(cat "$DT_r/slog" "$DT_r/wlog" |sed '/^$/d')
        adds=$(cat "$DT_r/adds" "$DT_r/addw" |sed '/^$/d' |wc -l)
        
        if [[ ${adds} -ge 1 ]]; then
            notify-send -i idiomind "${tpe}" \
            "$(gettext "Have been added:")\n$sadds$S$wadds$W" -t 2000 &
        fi
        
        [ -n "$log" ] && echo "$log" >> "${DC_tlt}/note_err"
    fi
    [[ ! -f "$DT_r/__opts__" ]] && cleanups "$DT_r"
    cleanups "$DT/n_s_pr" & return 0
}

fetch_content() {
    export tpe="${2}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    if [[ $(wc -l < "${DC_tlt}/data") -ge 200 ]]; then exit 1; fi
    if [ -e "$DT/updating_feeds" ]; then
        exit 1
    else
        > "$DT/updating_feeds"
    fi
    for t in {0..30}; do
        curl -v www.google.com 2>&1 \
        | grep -m1 "HTTP/1.1" >/dev/null 2>&1 && break || sleep 10
        [ ${t} = 30 ] && exit 1
    done
    feeds="${DC_tlt}/feeds"
    source "$DS/ifs/mods/add/add.sh"
    tmplitem="<?xml version='1.0' encoding='UTF-8'?>
    <xsl:stylesheet version='1.0'
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
      xmlns:itunes='http://www.itunes.com/dtds/feed-1.0.dtd'
      xmlns:media='http://search.yahoo.com/mrss/'
      xmlns:atom='http://www.w3.org/2005/Atom'>
      <xsl:output method='text'/>
      <xsl:template match='/'>
        <xsl:for-each select='/rss/channel/item'>
          <xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
          <xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@url'/><xsl:text>-!-</xsl:text>
          <xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
          <xsl:value-of select='link'/><xsl:text>-!-</xsl:text>
          <xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
          <xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
        </xsl:for-each>
      </xsl:template>
    </xsl:stylesheet>"
    while read -r _feed; do
        if [ -n "${_feed}" ]; then
            feed_items="$(xsltproc - "${_feed}" <<< "${tmplitem}" 2> /dev/null)"
            if [ -z "${feed_items}" ]; then internet; fi
            feed_items="$(echo "${feed_items}" |tr '\n' '*' |tr -s '[:space:]' |sed 's/EOL/\n/g' |head -n2)"
            feed_items="$(echo "${feed_items}" |sed '/^$/d')"
            while read -r item; do
                if [[ $(wc -l < "${DC_tlt}/data") -ge 200 ]]; then exit 1; fi
                fields="$(echo "${item}" |sed -r 's|-\!-|\n|g')"
                title=$(echo "${fields}" |sed -n 3p \
                |iconv -c -f utf8 -t ascii |sed 's/\://g' \
                |sed 's/\&/&amp;/g' |sed 's/^\s*./\U&\E/g' \
                |sed 's/<[^>]*>//g' |sed 's/^ *//; s/ *$//; /^$/d')
                export link="$(echo "${fields}" |sed -n 4p \
                |sed 's|/|\\/|g' |sed 's/\&/\&amp\;/g')"

                if [ -n "${title}" ]; then
                    if ! grep -Fo "trgt{${title^}}" "${DC_tlt}/data" >/dev/null 2>&1 && \
                    ! grep -Fxq "${title^}" "${DC_tlt}/exclude" >/dev/null 2>&1; then
                        export wlist='FALSE'; export trans='TRUE'
                        export trgt="${title^}"
                        new_item
                    fi
                fi
            done <<< "${feed_items}"
        fi
    done < "${feeds}"
    cleanups "$DT/updating_feeds"; exit 0
} 

new_items() {
	itemdir=$(cat /dev/urandom |tr -cd 'a-f0-9' |head -c 10)
	export DT_r="$DT/$itemdir"
    if [ -f "$DT/clipw" ]; then 
        "$DS/ifs/clipw.sh" 1 & exit 1
    fi
    if [ ! -e "$DT/tpe" ]; then
        tpc="$(sed -n 1p "$DC_s/tpc")"
        if ! ls -1a "$DS/addons/" |grep -Fxo "${tpc}" >/dev/null 2>&1; then
            [ ! -L "$DM_tl/${tpc}" ] && echo "${tpc}" > "$DT/tpe"
        fi
        tpe="$(sed -n 1p "$DT/tpe")"
    fi
    if [ -e "$DC_s/topics_first_run" ]; then
        "$DS/ifs/tls.sh" first_run topics & exit 1
    fi

    [ -z "${4}" ] && txt="$(xclip -selection primary -o)" || txt="${4}"
    export trgt="$(clean_4 "${txt}")"
    
    [ -d "${2}" ] && DT_r="${2}"
    [ -n "${5}" ] && srce="${5}" || srce=""
    
    if [ ${#trgt} -le ${sentence_chars} ] && \
    [ $(echo -e "${trgt}" |wc -l) -gt ${sentence_lines} ]; then process & return; fi
    if [ ${#trgt} -gt ${sentence_chars} ]; then process & return; fi

    [ -e "$DT_r/ico.jpg" ] && img="$DT_r/ico.jpg" || img="$DS/images/nw.png"
    export img
    tpcs="$(cdb "${shrdb}" 5 topics)"
    tpcs="$(grep -vFx "${tpe}" <<< "$tpcs" |tr "\\n" '!' |sed 's/\!*$//g')"
    [ -n "$tpcs" ] && e='!'

    if [[ ${trans} = TRUE ]]; then
        lzgplr="$(dlg_form_1)"; ret=$?
        trgt=$(cut -d "|" -f1 <<< "${lzgplr}")
        tpe=$(cut -d "|" -f2 <<< "${lzgplr}")
    else 
        lzgplr="$(dlg_form_2)"; ret=$?
        trgt=$(cut -d "|" -f1 <<< "${lzgplr}")
        srce=$(cut -d "|" -f2 <<< "${lzgplr}")
        tpe=$(cut -d "|" -f3 <<< "${lzgplr}")
    fi
    if [ $ret -eq 3 ]; then
        [ -d "$2" ] && DT_r="$2" || mkdir "$DT_r"
        ! grep '*' <<< "${tpe}" >/dev/null 2>&1 && echo "${tpe}" > "$DT/tpe"
        cd "$DT_r"; set_image_1
        "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
    elif [ $ret -eq 2 ]; then
        [ -d "$2" ] && DT_r="$2" || mkdir "$DT_r"
        ! grep '*' <<< "${tpe}" >/dev/null 2>&1 && echo "${tpe}" > "$DT/tpe"
        "$DS/ifs/tls.sh" add_audio "$DT_r"
        "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
    elif [ $ret -eq 0 -o $ret -eq 4 -o  $ret -eq 5 ]; then
        if [ $ret -eq 5 ]; then "$DS/ifs/tls.sh" clipw & return; fi
		[ $ret -eq 4 ] && export wlist='TRUE'
        if [ -z "${tpe}" ]; then
			check_s "${tpe}" && exit 1
        fi
        if [ "${tpe}" = "$(gettext "New") *" ]; then
            "$DS/add.sh" new_topic
            source $DS/default/c.conf
        else
            ! grep '*' <<< "${tpe}" >/dev/null 2>&1 && echo "${tpe}" > "$DT/tpe"
        fi
        if [ "$3" = 2 ]; then
            [ -d "$2" ] && DT_r="$2" || mkdir "$DT_r"
        else 
            mkdir "$DT_r"
        fi
        
        export DT_r; cd "$DT_r"
        xclip -i /dev/null
        if [ -z "${tpe}" ] && [[ ${3} != 3 ]]; then cleanups "$DT_r"
            msg "$(gettext "No topic is active")\n" \
            "face-worried" "$(gettext "Information")" & exit 1; fi
        if [ -z "${trgt}" ]; then
            cleanups "$DT_r"; exit 1; fi
        if [[ ${trgt,,} = ocr ]] || [[ ${trgt^} = I ]]; then
            unset trgt; process image
        elif [[ ${#trgt} = 1 ]]; then
            process ${trgt:0:2}
        elif [[ ${#trgt} -gt ${sentence_chars} ]]; then #TODO
            process
        else
            new_item
        fi
    else
        xclip -i /dev/null; cleanups "$DT_r"
    fi
    exit 0
}

case "$1" in
    new_topic)
    new_topic "$@" ;;
    new_item)
    new_item "$@" ;;
    new_items)
    new_items "$@" ;;
    list_words_edit)
    list_words_edit "$@" ;;
    list_words_dclik)
    list_words_dclik "$@" ;;
    fetch_content)
    fetch_content "$@" ;;
esac
