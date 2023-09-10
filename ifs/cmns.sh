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
    --window-icon=$DS/images/logo.png \
    --image-on-top --sticky --center --fixed --on-top \
    --width=450 --height=100 --borders=5 \
    --button="${btn}":0
}

function msg_2() {
    [ -n "${5}" ] && title="${5}" || title=Idiomind
    [ -n "${6}" ] && btn3="--button=${6}:2" || btn3=""
    yad --title="${title}" --text="${1}" --image="${2}" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=$DS/images/logo.png \
    --image-on-top --sticky --center --fixed --on-top \
    --width=450 --height=100 --borders=5 \
    "${btn3}" --button="${4}":1 --button="${3}":0
}

function msg_4() {
    [ -n "${5}" ] && title="${5}" || title=Idiomind
    ( echo "# "; while true; do
    sleep 1; echo "# "; [ ! -e "${6}" ] && break
    done )  | yad --progress --title="${title}" --text="${1}" \
    --name=Idiomind --class=Idiomind \
    --pulsate --auto-close --always-print-result \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=edge --image-on-top \
    --fixed --on-top --sticky --center \
    --width=380 --height=110 --borders=3 \
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

function cdb () {
    db="${1}"
    ta="${3}"
    co="$(sed "s|'|''|g" <<< "${4}")"
    va="$(sed "s|'|''|g" <<< "${5}")"
    if [ $2 = 1 ]; then # read
        sqlite3 "$db" "select ${co} from ${ta};"
    elif [ $2 = 2 ]; then # insert
        sqlite3 "$db" "insert into ${ta} (${co}) values ('${va}');"
    elif [ $2 = 3 ]; then # mod
        sqlite3 "$db" "update $ta set ${co}='${va}';"
    elif [ $2 = 4 ]; then # delete
        sqlite3 "$db" "delete from ${ta} where ${co}='${va}';"
    elif [ $2 = 5 ]; then # select all
        sqlite3 "$db" "select * FROM ${ta};" |sed 's/|/\n/g'
    elif [ $2 = 6 ]; then # delet all
        sqlite3 "$db" "delete from '${ta}';"
    elif [ $2 = 7 ]; then # mod especific
        sqlite3 "$db" "pragma busy_timeout=200;\
        update '${ta}' set list='${co}' where list='${va}';"
    elif [ $2 = 8 ]; then # read especific
        sqlite3 "$db" "select list from '${ta}' where list is '${va}';"
    fi
}

function tpc_db() {
    ta="${2}"
    co="$(sed "s|'|''|g" <<< "${3}")"
    va="$(sed "s|'|''|g" <<< "${4}")"
    
    if [ $1 = 1 ]; then # read
        sqlite3 "$DC_tlt/tpc" "select ${co} from '${ta}';"
    elif [ $1 = 2 ]; then # insert
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=500; \
        insert into ${ta} (${co}) values ('${va}');"
    elif [ $1 = 3 ]; then # mod
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=300;\
        update ${ta} set ${co}='${va}';"
    elif [ $1 = 4 ]; then # delete specific
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=500; \
        delete from ${ta} where ${co}='${va}';"
    elif [ $1 = 5 ]; then # select all
        sqlite3 "$DC_tlt/tpc" "select * FROM '${ta}';" |tr -s '|' '\n'
    elif [ $1 = 6 ]; then # delet all
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=2000;\
        delete from '${ta}';"
    elif [ $1 = 7 ]; then # mod specific
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=500;\
        update '${ta}' set list='${co}' where list='${va}';"
    elif [ $1 = 8 ]; then # insert fast
        sqlite3 "$DC_tlt/tpc" \
        "insert into ${ta} (${co}) values ('${va}');"
    elif [ $1 = 9 ]; then # mod fast
        sqlite3 "$DC_tlt/tpc" "update ${ta} set ${co}='${va}';"
    elif [ $1 = 10 ]; then # select specific, first record
        sqlite3 "$DC_tlt/tpc" "select ${co} from '${ta}' asc limit 1;" |tr -s '|' '\n'
        
    elif [ $1 = 21 ]; then # mod Data col
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=500; \
        insert into ${ta} (${co}) values ('${va}');"
        
    elif [ $1 = 22 ]; then # delete Data col
        sqlite3 "$DC_tlt/tpc" "pragma busy_timeout=500; \
        insert into ${ta} (${co}) values ('${va}');"
    fi
}

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


#TODO
function f_lock() {
    brk=0
    if [ $1 = 0 -o $1 = 1 ]; then
        while [ ${brk} -le 20 ]; do
            if [ ! -f "${2}" ]; then 
                [ $1 = 1 ] && touch "${2}"
                break
            elif [ -f "${2}" -a ${brk} = 1 ]; then
                msg "$(gettext "Please wait until the current process is finished")...\n" \
                dialog-information 
            elif [ -f "${2}" ]; then
                sleep 1; fi
            let brk++
        done
    elif [ $1 = 3 ]; then
        if [ -f "$2" ]; then rm -f "$2"; fi
    fi
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
    export topics="$(cd ~ && cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')" \
    addons="$(ls -1a "$DS/addons/")" db="$DM_tls/data/config"
    
    if [ -e ${db} ]; then
        if ls -tNd "$DM_tl"/*/ 1> /dev/null 2>&1; then
python3 <<PY
import os, sqlite3
shrdb = os.environ['shrdb']
db = sqlite3.connect(shrdb)
db.text_factory = str
cur = db.cursor()
addons = os.environ['addons']
addons = addons.split('\n')
topics = os.environ['topics']
topics = topics.split('\n')
cur.execute("delete from topics")
for tpc in topics:
    if not tpc in addons:
        cur.execute("insert into topics (list) values (?)", (tpc,))
db.commit()
db.close()
PY
        fi
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
    export type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")" \
    trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")" \
    srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")" \
    exmp="$(grep -oP '(?<=exmp{).*(?=})' <<< "${item}")" \
    defn="$(grep -oP '(?<=defn{).*(?=})' <<< "${item}")" \
    note="$(grep -oP '(?<=note{).*(?=})' <<< "${item}")" \
    wrds="$(grep -oP '(?<=wrds{).*(?=})' <<< "${item}")" \
    grmr="$(grep -oP '(?<=grmr{).*(?=})' <<< "${item}")" \
    mark="$(grep -oP '(?<=mark{).*(?=})' <<< "${item}")" \
    link="$(grep -oP '(?<=link{).*(?=})' <<< "${item}")" \
    tags="$(grep -oP '(?<=tags{).*(?=})' <<< "${item}")" \
    refr="$(grep -oP '(?<=refr{).*(?=})' <<< "${item}")" \
    cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
}

function unset_item() {
    srce=""; exmp=""; defn=""; note=""; wrds=""
    grmr=""; tags=""; mark=""; link=""; cdid=""
    export srce exmp defn note wrds
    export grmr tags mark link cdid
}

function check_err() {
    for filerr in "$@"; do
        if [ -f "$filerr" ]; then
            if [ ${filerr: -4} == ".err" ]; then
                mtitle="$(gettext "Errors found")"
                mimage="dialog-warning"
            elif [ ${filerr: -4} == ".inf" ]; then
                mtitle="$(gettext "Information")"
                mimage="info"
            fi
            sleep 2; echo "$(< "$filerr")" |yad --text-info \
            --title="Idiomind - $mtitle" \
            --name=Idiomind --class=Idiomind \
            --window-icon=$DS/images/logo.png \
            --wrap --margins=5 \
            --show-uri --uri-color="#6591AA" \
            --fontname='monospace 9' \
            --fixed --scroll --center --on-top \
            --width=500 --height=200 --borders=5 \
            --button="$(gettext "Close")":1
            cleanups "$filerr"
        fi
    done &
}

function calculate_review() { #TODO check count rows
    [ -z ${notice} ] && source "$DS/default/sets.cfg"
    export DC_tlt="$DM_tl/${1}/.conf"
    count_date_reviews="$(tpc_db 5 reviews |grep -c '[^[:space:]]')"
    if [ ${count_date_reviews} -ge 1 ]; then
        date_review=""; date_review=$(tpc_db 1 reviews date${count_date_reviews})
        
        if ! [[ ${date_review} =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
            echo "--error: $1"
            tpc_db 6 reviews
            tpc_db 8 reviews date1 "$(date +%m/%d/%Y)"
            date_review=$(tpc_db 1 reviews date1)
            count_date_reviews=0
        fi

        TM=$((($(date +%s)-$(date -d ${date_review} +%s))/(24*60*60)))
        days_to_review=${notice[${count_date_reviews}]}
        days_to_review_porcent=$((100*TM/days_to_review))

        export days_to_review 
        return ${days_to_review_porcent}
    fi
}
