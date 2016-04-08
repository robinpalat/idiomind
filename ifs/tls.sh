#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function check_format_1() {
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/default/sets.cfg"
    lgt=${tlangs[$tlng]}
    lgs=${slangs[$slng]}
    source "$DS/ifs/cmns.sh"
    file="${1}"
    invalid() {
        echo "Error! Value: ${1}"
        msg "$(gettext "File is corrupted.")\n ${n}" error & exit 1
    }
    if [ ! -f "${file}" ]; then invalid
    elif [ $(wc -l < "${file}") != 3 ]; then invalid 'lines'
    elif [ $(sed -n 1p "$file" |tr -d '"{' |cut -d':' -f1) != 'items' ]; then
        invalid
    fi
    shopt -s extglob; n=0
    while read -r line; do
        if [ -z "$line" ]; then continue; fi
        val="$(cut -d ':' -f2 <<< "${line}")"
        if [[ ${n} = 0 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 60 ] || \
            [ "$(grep -o -E '\*|\/|\@|$|=|' <<< "${val}")" ]; then invalid $n; fi
        elif [[ ${n} = 1 || ${n} = 2 ]]; then
            if ! grep -Fo "${val}" <<< "${!tlangs[@]}" >/dev/null 2>&1; then invalid $n; fi
        elif [[ ${n} = 3 || ${n} = 4 ]]; then
            if [ ${#val} -gt 30 ] || \
            [ "$(grep -o -E '\*|\/|$|\)|\(|=' <<< "${val}")" ]; then invalid $n; fi
        elif [[ ${n} = 5 ]]; then
            if ! grep -Fo "${val//_/ }" <<< "${Categories[@],}" >/dev/null 2>&1; then invalid $n; fi
        elif [[ ${n} = 6 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 36 ]; then invalid $n; fi
        elif [[ ${n} = 7 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 60 ] || \
            [ "$(grep -o -E '\*|\/|\@|$|=|' <<< "${val}")" ]; then invalid $n; fi
        elif [[ ${n} = 8 || ${n} = 9 || ${n} = 10 ]]; then
            if [ -n "${val}" ]; then
            if ! [[ ${val} =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
            || [ ${#val} -gt 12 ]; then invalid $n; fi; fi
        elif [[ ${n} = 11 || ${n} = 12 || ${n} = 13 ]]; then
            if ! [[ $val =~ $numer ]] || [ ${val} -gt 200 ]; then invalid $n; fi
        elif [[ ${n} = 14 ]]; then
             if ! [[ $val =~ $numer ]] || [ ${val} -gt 1000 ]; then invalid $n; fi
        elif [[ ${n} = 15 ]]; then
            if [ ${#val} -gt 6 ]; then invalid $n; fi
        elif [[ ${n} = 16 ]]; then
            if ! [[ $val =~ $numer ]] || [ ${#val} -gt 2 ]; then invalid $n; fi
        elif [[ ${n} = 17 ]]; then
            if [ -z "${val##+([[:space:]])}" ] || [ ${#val} -gt 40 ] || \
            [ "$(grep -o -E '\*|\/|\@|$|=|-' <<< "${val}")" ]; then invalid $n; fi
        fi
        export ${tsets[$n]}="${val}"
        let n++
    done < <(sed -n 3p "$file"|sed 's/\",\"/\"\n\"/g'|tr -d '"}')
    return ${n}
}

check_index() {
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    DC_tlt="$DM_tl/${2}/.conf"; DM_tlt="$DM_tl/${2}"
    tpc="${2}"; mkmn=0; f=0
    [[ ${3} = 1 ]] && r=1 || r=0
    
    _check() {
        if [ ! -f "${DC_tlt}/0.cfg" ]; then export f=1; fi
        
        check_dir "${DC_tlt}" "${DC_tlt}" "${DM_tlt}/images" "${DC_tlt}/practice"
        check_file "${DC_tlt}/practice/log1" "${DC_tlt}/practice/log2" "${DC_tlt}/practice/log3"
        
        for n in {0..4}; do
            if [ ! -e "${DC_tlt}/${n}.cfg" ]; then 
                touch "${DC_tlt}/${n}.cfg"; export f=1
            fi
            if grep '^$' "${DC_tlt}/${n}.cfg"; then
                sed -i '/^$/d' "${DC_tlt}/${n}.cfg"
            fi
        done
        
        if [ ! -e "${DC_tlt}/10.cfg" -o ! -s "${DC_tlt}/10.cfg" ]; then
            source "$DS/default/sets.cfg"; > "${DC_tlt}/10.cfg"
            for n in ${psets[@]}; do
                echo -e "${n}=\"\"" >> "${DC_tlt}/10.cfg"
            done
            sed -i "s/acheck=.*/acheck=\"TRUE\"/g" "${DC_tlt}/10.cfg"
            sed -i "s/repass=.*/repass=\"0\"/g" "${DC_tlt}/10.cfg"
        fi
        
        check_file "${DC_tlt}/9.cfg" "${DC_tlt}/info"
        
        id=1
        [ ! -e "${DC_tlt}/id.cfg" ] && touch "${DC_tlt}/id.cfg" && id=0
        [[ $(egrep -cv '#|^$' < "${DC_tlt}/id.cfg") != 18 ]] && id=0
        if [ ${id} != 1 ]; then
            dtec=$(date +%F)
            eval vls="$(sed -n 4p $DS/default/vars)"
            echo -e "${vls}" > "${DC_tlt}/id.cfg"
        fi
        if ls "${DM_tlt}"/*.mp3 1> /dev/null 2>&1; then
            for au in "${DM_tlt}"/*.mp3 ; do 
                [ ! -s "${au}" ] && rm "${au}"
            done
        fi
        if [ ! -e "${DC_tlt}/8.cfg" ]; then
            echo 1 > "${DC_tlt}/8.cfg"
            export f=1
        fi
        
        stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        ! [[ ${stts} =~ $numer ]] && stts=13

        if [ $stts = 13 ]; then
            echo 1 > "${DC_tlt}/8.cfg"; export mkmn=1; export f=1
        fi
        
        export stts

        cnt0=$(wc -l < "${DC_tlt}/0.cfg" |sed '/^$/d')
        cnt1=$(egrep -cv '#|^$' < "${DC_tlt}/1.cfg")
        cnt2=$(egrep -cv '#|^$' < "${DC_tlt}/2.cfg")
        if [ $((cnt1+cnt2)) != ${cnt0} ]; then export f=1; fi
        
        if grep '},' "${DC_tlt}/0.cfg"; then export c=1; fi
    }
    
    _restore() {
        if [ ! -e "${DC_tlt}/0.cfg" ]; then
            if [ -e "$DM/backup/${tpc}.bk" ]; then
                cp -f "$DM/backup/${tpc}.bk" "${DC_tlt}/0.cfg"
            else
                msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
            fi
        fi
        rm "${DC_tlt}/1.cfg" "${DC_tlt}/3.cfg" "${DC_tlt}/4.cfg"
        while read -r item_; do
            item="$(sed 's/}/}\n/g' <<< "${item_}")"
            type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
            trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
            if [ -n "${trgt}" -a -n ${type} ]; then
                if ! grep -Fxq "${trgt}" "${DC_tlt}/1.cfg"; then
                    if [ ${type} = 1 ]; then
                        echo "${trgt}" >> "${DC_tlt}/3.cfg"
                        echo "${trgt}" >> "${DC_tlt}/1.cfg"
                        echo "${item_}" >> "$DT/0.cfg"
                    elif [ ${type} = 2 ]; then
                        echo "${trgt}" >> "${DC_tlt}/4.cfg"
                        echo "${trgt}" >> "${DC_tlt}/1.cfg"
                        echo "${item_}" >> "$DT/0.cfg"
                    fi
                fi
            fi
        done < "${DC_tlt}/0.cfg"
        > "${DC_tlt}/2.cfg"; mv -f "$DT/0.cfg" "${DC_tlt}/0.cfg"
        sed -i '/^$/d' "${DC_tlt}/0.cfg"
    }
    
    _newformat() {
        get_item() {
            export item="$(sed 's/},/}\n/g' <<< "${1}")"
            export type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
            export trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            export srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
            export exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
            export defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
            export note="$(grep -oP '(?<=note={).*(?=})' <<<"${item}")"
            export wrds="$(grep -oP '(?<=wrds={).*(?=})' <<<"${item}")"
            export grmr="$(grep -oP '(?<=grmr={).*(?=})' <<<"${item}")"
            export mark="$(grep -oP '(?<=mark={).*(?=})' <<<"${item}")"
            export link="$(grep -oP '(?<=link={).*(?=})' <<<"${item}")"
            export tags="$(grep -oP '(?<=tag={).*(?=})' <<<"${item}")"
            export cdid="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
        }
        rm -f "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg"
        while read -r _item; do
            get_item "${_item}"
            eval line="$(sed -n 2p $DS/default/vars)"
            echo -e "${line}" >> "${DC_tlt}/cfg"
            echo "${trgt}" >> "${DC_tlt}/1.cfg"
        done < <(tac "${DC_tlt}/0.cfg")
        mv -f "${DC_tlt}/cfg" "${DC_tlt}/0.cfg"
        touch "${DC_tlt}/2.cfg"
        "$DS/ifs/tls.sh" colorize 1
    }
    
    _check
    
    if [[ ${c} = 1 ]]; then
        > "$DT/ps_lk"; 
        (sleep 1; notify-send -i idiomind "$(gettext "Index Error")" \
        "$(gettext "Convert to new format...")" -t 3000) &
        _newformat
    fi
    if [[ ${f} = 1 ]]; then
        > "$DT/ps_lk"; mkmn=1
        if [[ ${r} = 0 ]]; then
            (sleep 1; notify-send -i idiomind "$(gettext "Index Error")" \
            "$(gettext "Fixing...")" -t 3000) &
        fi
        _restore
    fi
    if [[ ${mkmn} = 1 ]] ;then
        "$DS/ifs/tls.sh" colorize 1; "$DS/mngr.sh" mkmn 0
    fi
    
    cleanups "$DT/ps_lk"
}

add_audio() {
    cd "$HOME"
    aud="$(yad --file --title="$(gettext "Add Audio")" \
    --text=" $(gettext "Browse to and select the audio file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --file-filter="*.mp3" \
    --window-icon=idiomind --center --on-top \
    --width=620 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0 |cut -d "|" -f1)"
    ret=$?
    if [ $ret -eq 0 ]; then
        if [ -f "${aud}" ]; then 
            cp -f "${aud}" "${2}/audtm.mp3"
        fi
    fi
} >/dev/null 2>&1

_backup() {
    source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    dt=$(date +%F)
    check_dir "$HOME/.idiomind/backup"
    file="$HOME/.idiomind/backup/${2}.bk"
    
    if ! grep "${2}.bk" < <(cd "$HOME/.idiomind/backup"/; \
    find . -maxdepth 1 -name '*.bk' -mtime -2); then
        if [ -s "$DM_tl/${2}/.conf/0.cfg" ]; then
            if [ -e "${file}" ]; then
                dt2=$(grep '\----- newest' "${file}" |cut -d' ' -f3)
                old="$(sed -n '/----- newest/,/----- oldest/p' "${file}" \
                |grep -v '\----- newest' |grep -v '\----- oldest')"
            fi
            new="$(cat "$DM_tl/${2}/.conf/0.cfg")"
            echo "----- newest $dt" > "${file}"
            echo "${new}" >> "${file}"
            echo "----- oldest $dt2" >> "${file}"
            echo "${old}" >> "${file}"
            echo "----- end" >> "${file}"
        fi
    fi 
} >/dev/null 2>&1


_restore_backup() {
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    file="$HOME/.idiomind/backup/${2}.bk"

    touch "$DT/act_restfile"; check_dir "${DM_tl}/${2}/.conf"
    if [[ ${3} = 1 ]]; then
        sed -n '/----- newest/,/----- oldest/p' "${file}" \
        |grep -v '\----- newest' |grep -v '\----- oldest' > \
        "${DM_tl}/${2}/.conf/0.cfg"
        
    elif [[ ${3} = 2 ]]; then
        sed -n '/----- oldest/,/----- end/p' "${file}" \
        |grep -v '\----- oldest' |grep -v '\----- end' > \
        "${DM_tl}/${2}/.conf/0.cfg"
    fi
    
    "$DS/ifs/tls.sh" check_index "${2}" 1
    mode="$(< "$DM_tl/${2}/.conf/8.cfg")"
    if ! [[ ${mode} =~ $num ]]; then
        echo 13 > "$DM_tl/${2}/.conf/8.cfg"; mode=13
    fi
    "$DS/default/tpc.sh" "${2}" ${mode} 1 &
} >/dev/null 2>&1

fback() {
    xdg-open "http://idiomind.sourceforge.net/contact"
} >/dev/null 2>&1

_definition() {
    source "$DS/ifs/cmns.sh"
    export query="$(sed 's/<[^>]*>//g' <<<"${2}")"
    f="$(ls "$DC_d"/*."Link.Search definition".* |head -n1)"
    if [ -z "$f" ]; then "$DS_a/Dics/cnfg.sh" 3
        f="$(ls "$DC_d"/*."Link.Search definition".* |head -n1)"
    fi
    eval _url="$(< "$DS_a/Dics/dicts/$(basename "$f")")"
    yad --html --title="$(gettext "Definition")" \
    --name=Idiomind --class=Idiomind \
    --browser --uri="${_url}" \
    --window-icon=idiomind \
    --fixed --on-top --mouse \
    --width=680 --height=520 --borders=0 \
    --button="$(gettext "Close")":1 &
} >/dev/null 2>&1

_translation() {
    source "$DS/ifs/cmns.sh"
    source /usr/share/idiomind/default/c.conf
    xdg-open "https://translate.google.com/#$lgt/$lgs/${2}"
} >/dev/null 2>&1

_quick_help() {
    _url='http://idiomind.sourceforge.net/doc/help.html'
    yad --html --title="$(gettext "Reference")" \
    --name=Idiomind --class=Idiomind \
    --uri="${_url}" \
    --window-icon=idiomind \
    --fixed --on-top --mouse \
    --width=620 --height=520 --borders=5 \
    --button="$(gettext "Close")":1 &
} >/dev/null 2>&1

check_updates() {
    source "$DS/ifs/cmns.sh"
    internet
    link='http://idiomind.sourceforge.net/doc/checkversion'
    nver=$(wget --user-agent "$ua" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
    pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
    date "+%d" > "$DC_s/9.cfg"
    if [ ${#nver} -lt 9 ] && [ ${#_version} -lt 9 ] \
    && [ ${#nver} -ge 3 ] && [ ${#_version} -ge 3 ] \
    && [[ ${nver} != ${_version} ]]; then
        msg_2 " <b>$(gettext "A new version of Idiomind available\!")</b>\t\n" \
        dialog-information "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "Information")"
        ret=$?
        if [ $ret -eq 0 ]; then xdg-open "$pkg"; fi
    else
        msg " $(gettext "No updates available.")\n" \
        dialog-information "$(gettext "Information")"
    fi
    exit 0
} >/dev/null 2>&1

a_check_updates() {
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    if [ ! -e "$DC_s/9.cfg" ]; then
        date "+%d" > "$DC_s/9.cfg"; exit 1
    fi
    d1=$(< "$DC_s/9.cfg"); d2=$(date +%d)
    if [ $(sed -n 1p "$DC_s/9.cfg") = 1 ] \
    && [ $(wc -l < "$DC_s/9.cfg") -gt 1 ]; then
        rm -f "$DC_s/9.cfg"; exit 1
    fi
    [[ $(wc -l < "$DC_s/9.cfg") -gt 1 ]] && exit 1
    if [ ${d1} != ${d2} ]; then
        sleep 5; curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        echo ${d2} > "$DC_s/9.cfg"
        link='http://idiomind.sourceforge.net/doc/checkversion'
        nver=$(wget --user-agent "$ua" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
        pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
        if [ ${#nver} -lt 9 ] && [ ${#_version} -lt 9 ] \
        && [ ${#nver} -ge 3 ] && [ ${#_version} -ge 3 ] \
        && [[ ${nver} != ${_version} ]]; then
            msg_2 " <b>$(gettext "A new version of Idiomind available\!")\t\n</b> $(gettext "Do you want to download it now?")\n" \
            dialog-information "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "New Version")" "$(gettext "Ignore")"
            ret=$?
            if [ $ret -eq 0 ]; then
                xdg-open "$pkg"
            elif [ $ret -eq 2 ]; then
                echo ${d2} >> "$DC_s/9.cfg"
            fi
        fi
    fi
    exit 0
} >/dev/null 2>&1

first_run() {
    source /usr/share/idiomind/default/c.conf
    dlg() {
        sleep 3; mv -f "${file}" "${file}".p
        yad --title=" " --text="${note}" \
        --name=Idiomind --class=Idiomind \
        --always-print-result --selectable-labels \
        --image=dialog-information --window-icon=idiomind \
        --image-on-top --on-top --sticky --center \
        --width=500 --height=140 --borders=5 \
        --button="$(gettext "Do not show again")":1 \
        --button="$(gettext "OK")":0
        [ $? = 1 ] && rm -f "${file}" "${file}".p
    }
    NOTE2="$(gettext "You can move any item by dragging and dropping or double click to edit it.\nIf you change the text of an item, its audio file can be overwritten by another new file, to avoid this you can edit it individually through its edit dialog.\nClose and reopen the main window to see any changes.")\n"
    NOTE3="$(gettext "To start adding notes you need to have a Topic.\nTo create one you can click on the New button...")"

    if [[ ${2} = edit_list ]]; then
        title="$(gettext "Information")"
        note="${NOTE2}"
        file="$DC_s/elist_first_run"
        dlg
    elif [[ ${2} = topics ]]; then
        "$DS/chng.sh" "$NOTE3"; sleep 1
        source /usr/share/idiomind/default/c.conf
        if [ -n "$tpc" ]; then
        rm -f "$DC_s/topics_first_run"
        "$DS/add.sh" new_items & fi
        exit
    elif [[ -z "${2}" ]]; then
        echo "-- done"
        touch "$DC_s/elist_first_run" \
        "$DC_s/topics_first_run"
        exit
    else 
        exit
    fi
    exit
}

set_image() {
    source "$DS/ifs/cmns.sh"
    cd "$DT"; r=0
    source "$DS/ifs/mods/add/add.sh"
    if [ -e "${DM_tlt}/images/${trgt,,}.jpg" ]; then
        ifile="${DM_tlt}/images/${trgt,,}.jpg"; im=1
    else
        ifile="${DM_tls}/images/${trgt,,}-0.jpg"; im=0
    fi

    if [ -e "$DT/$trgt.img" ]; then
        msg_4 "$(gettext "Attempting download image")...\n" \
        dialog-warning OK "$(gettext "Stop")" "$(gettext "Information")" "$DT/$trgt.img"
        if [ $? -eq 1 ]; then rm -f "$DT/$trgt".img; else exit 1 ; fi
    fi

    if [ -e "$ifile" ]; then
        export btn2="--button=$(gettext "Remove")!edit-delete:2"
        export image="--image=$ifile"
    else
        export btn2="--button="$(gettext "Screen clipping")":0"
        export image="--image=$DS/images/bar.png"
    fi
    
    dlg_form_3; ret=$?
    
    if [ $ret -eq 2 ]; then
        rm -f "$ifile"
        if [ ${im} = 0 ]; then
            mv -f "$img" "${DM_tlt}/images/${trgt,,}.jpg"
        else
            ls "${DM_tls}/images/${trgt,,}"-*.jpg | while read -r img; do
            mv -f "$img" "${DM_tls}/images/${trgt,,}"-${r}.jpg
            let r++
            done
        fi
    elif [ $ret -eq 0 ]; then
        scrot -s --quality 90 "$DT/temp.jpg"
        /usr/bin/convert "$DT/temp.jpg" -interlace Plane -thumbnail 405x275^ \
        -gravity center -extent 400x270 -quality 90% "$ifile"
        "$DS/ifs/tls.sh" set_image "${2}" "${trgt}" & exit
    fi
    cleanups "$DT/temp.jpg"
    exit
} >/dev/null 2>&1

translate_to() {
    source /usr/share/idiomind/default/c.conf
    source $DS/default/sets.cfg
    source $DS/default/source_langs.cfg
    source "$DS/ifs/cmns.sh"
    internet
    [ ! -e "${DC_tlt}/id.cfg" ] && echo -e "  -- error" && exit 1
    l="$(grep -o 'tlng="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    if [ -n "$l" ]; then lgt=${tlangs[$l]}; else lgt=${tlangs[$tlng]}; fi

    if [ "$2" = "$(gettext "Restore original")" -o "$2" = restore ]; then
        if [ -e "${DC_tlt}/0.data" ]; then
            mv -f "${DC_tlt}/0.data" "${DC_tlt}/0.cfg"
            echo -e "  done!"
        else 
            echo -e "  -- error"
        fi
    else
        tl=${tranlangs[$2]}
        [ -e "${DC_tlt}/$tl.data" ] && "${DC_tlt}/$tl.data"
        include "$DS/ifs/mods/add"
        echo -e "\n\n  translating \"$tpc\"...\n"
        cnt=$(wc -l "${DC_tlt}/0.cfg")
        > "$DT/words.trad_tmp"
        > "$DT/index.trad_tmp"
        while read -r item_; do
            item="$(sed 's/}/}\n/g' <<<"${item_}")"
            type="$(grep -oP '(?<=type{).*(?=})' <<<"${item}")"
            trgt="$(grep -oP '(?<=trgt{).*(?=})' <<<"${item}")"
            if [ -n "${trgt}" ]; then
                echo "${trgt}" \
                | python -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
                | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
                | tr -d '*)(,;"“”:' | tr -s '&{}[]' ' ' \
                | sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
                | sed 's/\]//;s/\[//;s/<[^>]*>//g' \
                | sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' \
                | tr -d '.' | sed 's/^ *//; s/ *$//; /^$/d' >> "$DT/words.trad_tmp"
                echo "|" >> "$DT/words.trad_tmp"
                echo "${trgt} |" >> "$DT/index.trad_tmp"; fi
        done < "${DC_tlt}/0.cfg"
        sed -i ':a;N;$!ba;s/\n/\. /g' "$DT/words.trad_tmp"
        sed -i 's/|/|\n/g' "$DT/words.trad_tmp"
        sed -i 's/^..//' "$DT/words.trad_tmp"
        index_to_trad="$(< "$DT/index.trad_tmp")"
        words_to_trad="$(< "$DT/words.trad_tmp")"
        translate "${index_to_trad}" $lgt $tl > "$DT/index.trad"
        translate "${words_to_trad}" $lgt $tl > "$DT/words.trad"
        sed -i ':a;N;$!ba;s/\n/ /g' "$DT/index.trad"
        sed -i 's/|/\n/g' "$DT/index.trad"
        sed -i 's/^ *//; s/ *$//g' "$DT/index.trad"
        sed -i ':a;N;$!ba;s/\n/ /g' "$DT/words.trad"
        sed -i 's/|/\n/g' "$DT/words.trad"
        sed -i 's/^ *//; s/ *$//;s/\。/\. /g' "$DT/words.trad"
        paste -d '&' "$DT/words.trad_tmp" "$DT/words.trad" > "$DT/mix_words.trad_tmp"
        echo "${srce}"
        n=1
        while read -r item_; do
            get_item "${item_}"
            srce="$(sed -n ${n}p "$DT/index.trad")"
            tt="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f1 \
            |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' |tr -d '|.')"
            st="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f2 \
            |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' |tr -d '|.')"

            ( bcle=1
            > "$DT/w.tmp"
            while [[ ${bcle} -le $(wc -l <<<"${tt}") ]]; do
                t="$(sed -n ${bcle}p <<<"${tt}" |sed 's/^\s*./\U&\E/g')"
                s="$(sed -n ${bcle}p <<<"${st}" |sed 's/^\s*./\U&\E/g')"
                echo "${t}_${s}" >> "$DT/w.tmp"
                let bcle++
            done )
            wrds="$(tr '\n' '_' < "$DT/w.tmp" |sed '/^$/d')"; cdid="$id"
            eval line="$(sed -n 2p $DS/default/vars)"
            echo -e "${line}" >> "${DC_tlt}/$tl.data"
            echo "${srce}"
            
        let n++
        done < "${DC_tlt}/0.cfg"
        unset item type trgt srce exmp defn note grmr mark link tag id
        rm -f "$DT"/*.tmp "$DT"/*.trad "$DT"/*.trad_tmp
        if [ ! -e "${DC_tlt}/0.data" ]; then
            mv "${DC_tlt}/0.cfg" "${DC_tlt}/0.data"
        fi
        cp -f "${DC_tlt}/$tl.data" "${DC_tlt}/0.cfg"
        echo -e "\n\tdone!"
    fi
}

menu_addons() {
    > /usr/share/idiomind/addons/menu_list
    while read -r _set; do
        if [ -e "/usr/share/idiomind/addons/${_set}/icon.png" ]; then
            echo -e "/usr/share/idiomind/addons/${_set}/icon.png\n${_set}" >> \
            /usr/share/idiomind/addons/menu_list
        else echo -e "/usr/share/idiomind/images/thumb.png\n${_set}" >> \
            /usr/share/idiomind/addons/menu_list; fi
    done < <(cd "/usr/share/idiomind/addons/"; set -- */; printf "%s\n" "${@%/}")
}

stats_dlg() {
    source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/stats.sh"
    stats &
}

colorize() {
    source "$DS/ifs/cmns.sh"
    f_lock "$DT/co_lk"
    rm "${DC_tlt}/5.cfg"
    check_file "${DC_tlt}/1.cfg" "${DC_tlt}/6.cfg" "${DC_tlt}/9.cfg"
    if [[ $(egrep -cv '#|^$' < "${DC_tlt}/9.cfg") -ge 4 ]] \
    && [[ $(grep -oP '(?<=acheck=\").*(?=\")' "${DC_tlt}/10.cfg") = TRUE ]] \
    && [[ ${2} = 1 ]]; then chk=TRUE; else chk=FALSE; fi
    img1="$DS/images/1.png"
    img2="$DS/images/2.png"
    img3="$DS/images/3.png"
    img0="$DS/images/0.png"
    cfg1="${DC_tlt}/1.cfg"
    cfg5="${DC_tlt}/5.cfg"
    cfg6="${DC_tlt}/6.cfg"
    log3="$(cat "${DC_tlt}/practice"/log3)"
    log2="$(cat "${DC_tlt}/practice"/log2)"
    log1="$(cat "${DC_tlt}/practice"/log1)"
    export chk cfg1 cfg5 cfg6 log1 \
    log2 log3 img0 img1 img2 img3
    python <<PY
import os
chk = os.environ['chk']
cfg1 = os.environ['cfg1']
cfg5 = os.environ['cfg5']
cfg6 = os.environ['cfg6']
log1 = os.environ['log1']
log2 = os.environ['log2']
log3 = os.environ['log3']
img0 = os.environ['img0']
img1 = os.environ['img1']
img2 = os.environ['img2']
img3 = os.environ['img3']
items = [line.strip() for line in open(cfg1)]
marks = [line.strip() for line in open(cfg6)]
f = open(cfg5, "w")
n = 0
while n < len(items):
    item = items[n]
    if item in marks:
        i="<b><big>"+item+"</big></b>"
    else:
        i=item
    if item in log3:
        f.write(img3+"\n"+i+"\nFALSE\n")
    elif item in log2:
        f.write(img2+"\n"+i+"\nFALSE\n")
    elif item in log1:
        f.write(img1+"\n"+i+"\n"+chk+"\n")
    else:
        f.write(img0+"\n"+i+"\nFALSE\n")
    n += 1
f.close()
PY
    rm -f "$DT/co_lk"
}

itray() {
    [ ! -e "$HOME/.config/idiomind/4.cfg" ] && \
    touch "$HOME/.config/idiomind/4.cfg"
    export lbl1="$(gettext "Add")"
    export lbl2="$(gettext "Play")"
    export lbl3="$(gettext "Stop playback")"
    export lbl4="$(gettext "Next")"
    export lbl5="$(gettext "Index")"
    export lbl6="$(gettext "Options")"
    export lbl7="$(gettext "Show panel")"
    export lbl8="$(gettext "Quit")"
    export dirt="$DT/"
    python <<PY
import time, os, os.path, gtk, gio, signal, appindicator
icon = 'gtk-edit'
HOME = os.getenv('HOME')
add = os.environ['lbl1']
play = os.environ['lbl2']
stop = os.environ['lbl3']
next = os.environ['lbl4']
topics = os.environ['lbl5']
options = os.environ['lbl6']
panel = os.environ['lbl7']
quit = os.environ['lbl8']
class IdiomindIndicator:
    def __init__(self):
        self.indicator = appindicator.Indicator(icon, icon, appindicator.CATEGORY_APPLICATION_STATUS)
        self.indicator.set_status(appindicator.STATUS_ACTIVE)
        self.cfg = os.getenv('HOME') + '/.config/idiomind/4.cfg'
        self.playlck = os.environ['dirt'] + 'playlck'
        self.menu_items = []
        self.stts = 1
        self.change_label()
        self._on_menu_update()
    def _on_menu_update(self):
        time.sleep(0.5)
        if os.path.exists(self.playlck):
            m = open(self.playlck).readlines()
            for bm in m:
                label = bm.rstrip('\n')
                if label == "0":
                    self.stts = 1
                else:
                    self.stts = 0
        else:
            self.stts = 1
        self.change_label()
    def create_menu_label(self, label):
        item = gtk.ImageMenuItem()
        item.set_label(label)
        return item
    def create_menu_icon(self, label, icon_name):
        image = gtk.Image()
        image.set_from_icon_name(icon_name, 24)
        item = gtk.ImageMenuItem()
        item.set_label(label)
        item.set_image(image)
        item.set_always_show_image(True)
        return item
    def make_menu_items(self):
        menu_items = []
        menu_items.append((add, self.on_Add_click))
        if self.stts == 0:
            menu_items.append((stop, self.on_stop))
        else:
            menu_items.append((play, self.on_play))
        return menu_items
    def change_label(self):
        menu_items = self.make_menu_items()
        popup_menu = gtk.Menu()
        for label, callback in menu_items:
            if not label and not callback:
                item = gtk.SeparatorMenuItem()
            else:
                item = gtk.ImageMenuItem(label)
                item.connect('activate', callback)
            popup_menu.append(item)
        try:
            m = open(self.cfg).readlines()
        except:
            m = []
        for bm in m:
            label = bm.rstrip('\n')
            if not label:
                label = ""
            item = self.create_menu_icon(label, "go-home")
            item.connect("activate", self.on_Home)
            popup_menu.append(item)
        item = gtk.SeparatorMenuItem()
        popup_menu.append(item)
        item = self.create_menu_label(topics)
        item.connect("activate", self.on_Topics_click)
        popup_menu.append(item)
        item = self.create_menu_label(options)
        item.connect("activate", self.on_Options_click)
        popup_menu.append(item)
        item = self.create_menu_label(panel)
        item.connect("activate", self.on_Panel_click)
        popup_menu.append(item)
        item = gtk.SeparatorMenuItem()
        popup_menu.append(item)
        item = self.create_menu_label(quit)
        item.connect("activate", self.on_Quit_click)
        popup_menu.append(item)
        popup_menu.show_all()
        self.indicator.set_menu(popup_menu)
        self.menu_items = menu_items
    def on_Home(self, widget):
        os.system("idiomind topic &")
    def on_Add_click(self, widget):
        os.system("/usr/share/idiomind/add.sh new_items &")
    def on_Topics_click(self, widget):
        os.system("/usr/share/idiomind/chng.sh &")
    def on_Options_click(self, widget):
        os.system("/usr/share/idiomind/cnfg.sh &")
    def on_Panel_click(self, widget):
        os.system("/usr/share/idiomind/main.sh panel &")
    def on_play(self, widget):
        self.stts = 0
        os.system("/usr/share/idiomind/bcle.sh &")
        self._on_menu_update()
    def on_stop(self, widget):
        self.stts = 1
        os.system("/usr/share/idiomind/stop.sh 2 &")
        self._on_menu_update()
    def on_Quit_click(self, widget):
        os.system("/usr/share/idiomind/stop.sh 1 &")
        gtk.main_quit()
    def on_Topic_Changed(self, filemonitor, file, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self._on_menu_update()
    def on_Play_Changed(self, filemonitor, file2, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self._on_menu_update()
if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda signal, frame: gtk.main_quit())
    i = IdiomindIndicator()
    file = gio.File(i.cfg)
    monitor = file.monitor_file()
    monitor.connect("changed", i.on_Topic_Changed)
    file2 = gio.File(i.playlck)
    monitor2 = file2.monitor_file()
    monitor2.connect("changed", i.on_Play_Changed)
    gtk.main()
PY
return 0
}

about() {
    export _descrip="$(gettext "Utility for learning foreign vocabulary")"
    python << ABOUT
import gtk, os
app_logo = os.path.join('/usr/share/idiomind/images/logo.png')
app_icon = os.path.join('/usr/share/icons/hicolor/22x22/apps/idiomind.png')
app_name = 'Idiomind'
app_version = os.environ['_version']
app_website = os.environ['_website']
app_comments = os.environ['_descrip']
website_label = os.environ['_website']
app_copyright = 'Copyright (c) 2016 Robin Palatnik'
app_license = (('Idiomind is free software: you can redistribute it and/or modify\n'+
'it under the terms of the GNU General Public License as published by\n'+
'the Free Software Foundation, either version 3 of the License, or\n'+
'(at your option) any later version.\n'+
'\n'+
'This program is distributed in the hope that it will be useful,\n'+
'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'+
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n'+
'GNU General Public License for more details.\n'+
'\n'+
'You should have received a copy of the GNU General Public License\n'+
'along with this program.  If not, see http://www.gnu.org/licenses'))
app_authors = ['Robin Palatnik <robinpalat@users.sourceforge.net>']
app_artists = ["Logo based on rg1024's openclipart Ufo Cartoon."]
class AboutDialog:
    def __init__(self):
        about = gtk.AboutDialog()
        about.set_logo(gtk.gdk.pixbuf_new_from_file(app_logo))
        about.set_icon_from_file(app_icon)
        about.set_wmclass('Idiomind', 'Idiomind')
        about.set_name(app_name)
        about.set_program_name(app_name)
        about.set_version(app_version)
        about.set_comments(app_comments)
        about.set_copyright(app_copyright)
        about.set_license(app_license)
        about.set_authors(app_authors)
        about.set_artists(app_artists)
        about.set_website(app_website)
        about.set_website_label(website_label)
        about.run()
        about.destroy()
if __name__ == "__main__":
    AboutDialog = AboutDialog()
    main()
ABOUT
} >/dev/null 2>&1

gtext() {
$(gettext "Marked items")
$(gettext "Difficult words")
$(gettext "Does not need configuration")
}>/dev/null 2>&1

case "$1" in
    backup)
    _backup "$@" ;;
    restore)
    _restore_backup "$@" ;;
    check_index)
    check_index "$@" ;;
    add_audio)
    add_audio "$@" ;;
    help)
    _quick_help ;;
    check_updates)
    check_updates ;;
    a_check_updates)
    a_check_updates ;;
    edit_tag)
    edit_tag "$@" ;;
    set_image)
    set_image "$@" ;;
    first_run)
    first_run "$@" ;;
    fback)
    fback ;;
    find_def)
    _definition "$@" ;;
    find_trad)
    _translation "$@" ;;
    update_menu)
    menu_addons ;;
    _stats)
    stats_dlg ;;
    colorize)
    colorize "$@" ;;
    translate)
    translate_to "$@" ;;
    itray)
    itray ;;
    about)
    about ;;
esac
