#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function internet() {
    if curl -v www.google.com 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then :
    else zenity --info \
    --text="$(gettext "No network connection\nPlease connect to a network, then try again.")  " & exit 1
    fi
}

function msg() {
    [ -n "${3}" ] && title="${3}" || title=Idiomind
    [ -n "${4}" ] && btn="${4}" || btn="$(gettext "OK")"
    yad --title="${title}" --text="${1}" --image="${2}" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --image-on-top --center --fixed --sticky --on-top \
    --width=450 --height=110 --borders=3 \
    --button="${btn}":0
}

function msg_2() {
    [ -n "${5}" ] && title="${5}" || title=Idiomind
    [ -n "${6}" ] && btn3="--button=${6}:2" || btn3=""
    yad --title="${title}" --text="${1}" --image="${2}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=idiomind \
    --image-on-top --on-top --fixed --sticky --center \
    --width=450 --height=110 --borders=3 \
    "${btn3}" --button="${4}":1 --button="${3}":0
}

function msg_4() {
	[ -n "${5}" ] && title="${5}" || title=Idiomind
	( echo "# "; while true; do
	sleep 1; echo "# "; [ ! -e "${6}" ] && break
	done )  | yad --progress --title="${title}" --text="${1}" \
    --name=Idiomind --class=Idiomind \
    --pulsate --auto-close --always-print-result \
    --window-icon=idiomind \
    --buttons-layout=edge --image-on-top --fixed --on-top --sticky --center \
    --width=380 --height=100 --borders=3 \
    --button="${4}":1 --button="${3}":0
    #--image="$2"
}

function progress() {
    yad --progress \
    --name=Idiomind --class=Idiomind \
    --undecorated --${1} --auto-close \
    --skip-taskbar --center --on-top --no-buttons
}

export numer='^[0-9]+$'

function nmfile() {
    echo -n "${1}" |md5sum |rev |cut -c 4- |rev
}

function set_name_file() {
    cdid="trgt{$2}srce{$3}exmp{$4}defn{$5}note{$6}wrds{$7}grmr{$8}tags{}mark{}link{}cdid{}type{$1}"
    echo -n "${cdid}" |md5sum |rev |cut -c 4- |rev
}

function include() {
    if [[ -d "${1}" ]]; then
        local f; for f in "${1}"/*; do source "${f}"; done
    fi
}

function yad_kill() {
    for X in "${@}"; do kill -9 $(pgrep -f "$X") & done
}

function f_lock() {
    brk=0
    while true; do
        if [ ! -e "${1}" -o ${brk} -gt 20 ]; then touch "${1}" & break
        elif [ -e "${1}" ]; then sleep 1; fi
        let brk++
    done
}

function check_index1() {
    for i in "${@}"; do
        if [ -n "$(sort -n < "${i}" |uniq -dc)" ]; then
            awk '!array_temp[$0]++' < "${i}" > "$DT/tmp"
            sed '/^$/d' "$DT/tmp" > "${i}"; rm -f "$DT/tmp"
        fi
        if grep '^$' "${i}"; then sed -i '/^$/d' "${i}"; fi
    done
}

function check_list() {
    if ls -tNd "$DM_tl"/*/ 1> /dev/null 2>&1; then
        while read -r topic; do
            if ! echo -e "$(ls -1a "$DS/addons/")\n$(cat "$DM_tl/.share/3.cfg")" \
            |grep -Fxo "${topic}" >/dev/null 2>&1; then
                [ ! -L "$DM_tl/${topic}" ] && echo "${topic}"
            fi
        done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
        -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')
    fi
}

function check_dir() {
    dret=0
    for _dir in "$@"; do
        if [ ! -d "${_dir}" ]; then mkdir -p "${_dir}"; dret=1; fi
    done
    return $dret
}

function check_file() {
    fret=0
    for _fil in "$@"; do
        if [ ! -e "${_fil}" ]; then > "${_fil}"; fret=1; fi
    done
    return $fret
}

function cleanups() {
    for _fl in "$@"; do
        if [ -d "${_fl}" ]; then
            rm -fr "${_fl}"
        elif [ -e "${_fl}" ]; then
            rm -f "${_fl}"
        fi
    done
}

function get_item() {
    export item="$(sed 's/}/}\n/g' <<< "${1}")"
    export type="$(grep -oP '(?<=type{).*(?=})' <<<"${item}")"
    export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<<"${item}")"
    export srce="$(grep -oP '(?<=srce{).*(?=})' <<<"${item}")"
    export exmp="$(grep -oP '(?<=exmp{).*(?=})' <<<"${item}")"
    export defn="$(grep -oP '(?<=defn{).*(?=})' <<<"${item}")"
    export note="$(grep -oP '(?<=note{).*(?=})' <<<"${item}")"
    export wrds="$(grep -oP '(?<=wrds{).*(?=})' <<<"${item}")"
    export grmr="$(grep -oP '(?<=grmr{).*(?=})' <<<"${item}")"
    export mark="$(grep -oP '(?<=mark{).*(?=})' <<<"${item}")"
    export link="$(grep -oP '(?<=link{).*(?=})' <<<"${item}")"
    export tags="$(grep -oP '(?<=tags{).*(?=})' <<<"${item}")"
    export cdid="$(grep -oP '(?<=cdid{).*(?=})' <<<"${item}")"
}

function unset_item() {
    srce=""; exmp=""; defn=""; note=""; wrds=""
    grmr=""; tags=""; mark=""; link=""; cdid=""
    export srce exmp defn note wrds
    export grmr tags mark link cdid
}

function calculate_review() {
    [ -z ${notice1} ] && source "$DS/default/sets.cfg"
    DC_tlt="$DM_tl/${1}/.conf"
    dts=$(sed '/^$/d' < "${DC_tlt}/9.cfg" | wc -l)

    if [ ${dts} = 1 ]; then
        dte=$(sed -n 1p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice1} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice1))
        tdays=${notice1}
    elif [ ${dts} = 2 ]; then
        dte=$(sed -n 2p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice2} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice2))
        tdays=${notice2}
    elif [ ${dts} = 3 ]; then
        dte=$(sed -n 3p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice3} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice3))
        tdays=${notice3}
    elif [ ${dts} = 4 ]; then
        dte=$(sed -n 4p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice4} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice4))
        tdays=${notice4}
    elif [ ${dts} = 5 ]; then
        dte=$(sed -n 5p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice5} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice5))
        tdays=${notice5}
    elif [ ${dts} = 6 ]; then
        dte=$(sed -n 6p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice6} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice6))
        tdays=${notice6}
    elif [ ${dts} = 7 ]; then
        dte=$(sed -n 7p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice7} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice7))
        tdays=${notice7}
    elif [ ${dts} = 8 ]; then
        dte=$(sed -n 8p "${DC_tlt}/9.cfg")
        adv="<b>  ${notice8} $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/notice8))
        tdays=${notice8}
    fi
    export tdays adv
    return ${RM}
}
