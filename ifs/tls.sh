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
        echo "Error! Value: ${val}"
        msg "$(gettext "File is corrupted")\n[${1}]\n" error & exit 1
    }
    if [ ! -f "${file}" ]; then invalid
    elif ! python3 -m json.tool < "${file}" >> /dev/null; then
        invalid "Format"
    elif [ $(wc -l < "${file}") != 3 ]; then 
        invalid "$(wc -l < "${file}") Lines!"
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
        elif [[ ${n} = 1 ]]; then
            if grep ',' <<< "$val" >/dev/null 2>&1; then
                opre="$val"; val="$(cut -f1  -d ',' <<< "$val" |sed 's/ \+//g')"
                export otranslations=", $(sed "s/${val}, //g" <<< "$opre")"
            fi
            if ! grep -Fo "${val}" <<< "${!slangs[@]}" >/dev/null 2>&1; then invalid $n; fi
        elif [[ ${n} = 2 ]]; then
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
            if [ ${#val} -gt 10240 ]; then invalid $n; fi
        elif [[ ${n} = 18 ]]; then
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
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} \
    >/dev/null 2>&1; then c=c; else c=w; fi
    source "$DS/ifs/cmns.sh"
    DC_tlt="$DM_tl/${2}/.conf"
    DM_tlt="$DM_tl/${2}"
    tpc="${2}"; mkmn=0; fix=0
    c=0; s=0
    db_config=0
    db_reviews=0
    db_id=0
    [[ ${3} = 1 ]] && r=1 || r=0

    _check() {
        check_dir "${DM_tlt}" "${DC_tlt}" \
        "${DM_tlt}/images" "${DC_tlt}/practice"
        check_file "${DC_tlt}/practice/log1" "${DC_tlt}/practice/log2" \
        "${DC_tlt}/practice/log3" "${DC_tlt}/note"
        
        if ls "${DM_tlt}"/*.mp3 1> /dev/null 2>&1; then
            for mp3 in "${DM_tlt}"/*.mp3 ; do 
                [ ! -s "${mp3}" ] && rm "${mp3}"
            done
        fi
        if [ ! -e "${DC_tlt}/stts" ]; then
            echo 1 > "${DC_tlt}/stts"; export fix=1
        fi
        if [ ! -e "${DC_tlt}/data" ]; then
            export fix=1
        fi
        stts=$(sed -n 1p "${DC_tlt}/stts")
        ! [[ ${stts} =~ $numer ]] && stts=13

        if [ ${stts} = 13 ]; then
            if [ -e "${DC_tlt}/stts.bk" ]; then
                stts="$(< "${DC_tlt}/stts.bk")"
                cleanups "${DC_tlt}/stts.bk"
            else
                stts=1
            fi
            ! [[ ${stts} =~ $numer ]] && stts=1
            echo ${stts} > "${DC_tlt}/stts"
            export mkmn=1; export fix=1
        fi
        # DB check
        if [ -z "$(file "${tpcdb}" |grep -o 'SQLite')" ]; then
			"$DS/ifs/mkdb.sh" tpc "${tpc}"; fix=1
		else
            cnt="$(sqlite3 "${tpcdb}" "SELECT Count(*) FROM reviews")"
            if [ ${cnt} != '1' ]; then
                db_reviews=1; echo -e "\n-- error: db_table_reviews"
            fi
            cnt="$(sqlite3 "${tpcdb}" "SELECT Count(*) FROM id")"
            if [ ${cnt} != '1' ]; then
                db_id=1; echo -e "\n-- error: db_table_id"
            fi
            cnt="$(sqlite3 "${tpcdb}" "SELECT Count(*) FROM config")"
            if [[ ${cnt} != '1' ]]; then
                db_config=1; echo -e "\n-- error: db_table_config"
            fi
        fi
        if [ ${stts} -gt 1 ]; then
            dater=$(tpc_db 1 reviews date1)
            if [ -z "$dater" ]; then
                d="$(date +%m/%d/%Y)"
                tpc_db 9 reviews date1 "${d}"
            fi
        fi
        if [ -f "${DC_tlt}/0.cfg" ] || [ -f "${DC_tlt}/id.cfg" ]; then
            newform=1
        fi
        if grep -o 'trgt{}srce{}' "${DC_tlt}/data"; then fix=1; fi

        learn="$(tpc_db 5 learning)"
        leart="$(tpc_db 5 learnt)"
        words="$(tpc_db 5 words)"
        sentences="$(tpc_db 5 sentences)"
        cnt0=$(grep -c '[^[:space:]]' < "${DC_tlt}/data")
        if [ -f "${DC_tlt}/index" ]; then
            index0=$(grep -c '[^[:space:]]' < "${DC_tlt}/index")
            index0=$((index0/3))
        else
            index0=0
        fi
        cnt1="$(grep -c '[^[:space:]]' <<< "$learn")"
        cnt2="$(grep -c '[^[:space:]]' <<< "$leart")"
        cnt3="$(grep -c '[^[:space:]]' <<< "$words")"
        cnt4="$(grep -c '[^[:space:]]' <<< "$sentences")"
        
        if [ $((cnt3+cnt4)) != ${cnt0} ]; then export fix=1; fi
        if [ $((cnt1+cnt2)) != ${cnt0} ]; then export fix=1; fi
        if [ $? != 0 ]; then export fix=1; fi
        if [ ${index0} != ${cnt1} ]; then fix=1; fi
        if grep -E '3|4|7|8|9|10' <<< "$stts"; then
             [ ${cnt0} = 0 ] && echo 1 > "${DC_tlt}/stts"
             mkmn=1
        fi
        export stts
    }
    
    _restore() {
        if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} \
        >/dev/null 2>&1; then c=c; else c=w; fi
        if echo "$stts" |grep -E '3|4|7|8|9|10' >/dev/null 2>&1; then s=1; fi
        if [ ! -f "${DC_tlt}/data" ]; then
            if [ -f "$DM/backup/${tpc}.bk" ]; then
                sed -n '/----- newest/,/----- oldest/p' \
                "$DM/backup/${tpc}.bk" \
                |grep -Pv '\----- newest' \
                |grep -Pv '\----- oldest' |head -n200 > "${DC_tlt}/data"
            else
                msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
            fi
        fi
        sed -i "/trgt{}srce{}/d" "${DC_tlt}/data"
        tpc_db 6 'sentences'; tpc_db 6 'words'
        tpc_db 6 'learning'; tpc_db 6 'learnt'
        tpc_db 6 'marks'
        echo -n "pragma foreign_keys=ON" |sqlite3 "${tpcdb}"
        datafile="${DC_tlt}/data"; datatmp="$DT/data"
        export s tpcdb datafile datatmp

        python3 <<PY
import os, re, sqlite3, sys
count = 1
s = os.environ['s']
datafile = os.environ['datafile']
datatmp = os.environ['datatmp']
datatmp = open(datatmp, "w")
tpcdb = os.environ['tpcdb']
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
datalist = [line.strip() for line in open(datafile)]
for mitem in datalist:
    mitem = str(mitem)
    if count > 200:
        break
    item = mitem.replace('}', '}\n')
    fields = re.split('\n',item)
    trgt = (fields[0].split('trgt{'))[1].split('}')[0]
    try:
        typee = (fields[13].split('type{'))[1].split('}')[0]
        mark = (fields[8].split('mark{'))[1].split('}')[0]
    except:
        typee = (fields[24].split('type{'))[1].split('}')[0]
        mark = (fields[18].split('mark{'))[1].split('}')[0]
    
    if typee == '1':
        cur.execute("insert into words (list) values (?)", (trgt,))
    else:
        cur.execute("insert into sentences (list) values (?)", (trgt,))
    if mark == 'TRUE':
        cur.execute("insert into marks (list) values (?)", (trgt,))
    if s == '1':
        cur.execute("insert into learnt (list) values (?)", (trgt,))
    else:
        cur.execute("insert into learning (list) values (?)", (trgt,))
    datatmp.write(mitem+"\n")
    count += 1
db.commit()
db.close()
datatmp.close()
PY

        mv -f "$DT/data" "${DC_tlt}/data"
        sed -i '/^$/d' "${DC_tlt}/data"
        export mkmn=1
    }

    _check

    if [ ${fix} = 1 ]; then
        > "$DT/ps_lk"
        if [[ ${r} = 0 ]]; then
            (sleep 1; notify-send -i idiomind "$(gettext "Index error")" \
            "$(gettext "Fixing...")" -t 3000) &
        fi
        _restore
    fi
    # db fixing
    if [ ${db_config} = 1 ]; then
        sqlite3 "$tpcdb" "delete from config;"
        sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
        insert into config (words,sntcs,marks,learn,\
        diffi,rplay,audio,ntosd,loop,rword,acheck,repass) \
        values ('TRUE','TRUE','FALSE','FALSE','FALSE','FALSE',\
        'FALSE','FALSE','FALSE','FALSE','TRUE','0');"
    fi
    if [ ${db_reviews} = 1 ]; then
        firstrec="$(sqlite3 "${tpcdb}" "select * FROM reviews;" |sed -n 1p| tr '|' '\n')"
        tpc_db 6 reviews
        for i in {1..8}; do
            val="$(sed -n ${i}p <<< "${firstrec}")"
            if [ ${i} = '1' ]; then
                sqlite3 "${tpcdb}" "insert into reviews ("date$i") values ('"$val"');"
            else
                sqlite3 "${tpcdb}" "update reviews set "date$i"='"${val}"';"
            fi
        done
    fi
    if [ ${db_id} = 1 ]; then
        source /usr/share/idiomind/default/sets.cfg
        firstrec="$(sqlite3 "${tpcdb}" "select * FROM id;" |sed -n 1p| tr '|' '\n')"
        tpc_db 6 id
        for i in {1..18}; do
            val="$(sed -n ${i}p <<< "${firstrec}")"
            col=${tsets[$((i-1))]}
            if [ ${col} = 'name' ]; then
                sqlite3 "${tpcdb}" "insert into id ("$col") values ('"$val"');"
            else
                sqlite3 "${tpcdb}" "update id set "$col"='"${val}"';"
            fi
        done
    fi
    # create topics index
    if [ ${mkmn} = 1 ] ;then
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
    --window-icon=$DS/images/logo.png --center --on-top \
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
    
    if ! grep "${2}.bk" < <(cd ~ && cd "$HOME/.idiomind/backup"/; \
    find . -maxdepth 1 -name '*.bk' -mtime -2); then
        if [ -s "$DM_tl/${2}/.conf/data" ]; then
            if [ -e "${file}" ]; then
                dt2=$(grep '\----- newest' "${file}" |cut -d' ' -f3)
                old="$(sed -n '/----- newest/,/----- oldest/p' "${file}" \
                |grep -Pv '\----- newest' |grep -Pv '\----- oldest')"
            fi
            new="$(cat "$DM_tl/${2}/.conf/data")"
            echo "----- newest $dt" > "${file}"
            echo "${new}" >> "${file}"
            echo "----- oldest $dt2" >> "${file}"
            echo "${old}" >> "${file}"
            echo "----- end" >> "${file}"
        fi
    fi 
} >/dev/null 2>&1

_restore_backup() {
    local tpc; tpc="$2"
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    file="$HOME/.idiomind/backup/${tpc}.bk"
    touch "$DT/act_restfile"; check_dir "${DM_tl}/${tpc}/.conf"
    if [[ ${3} = 1 ]]; then
        sed -n '/----- newest/,/----- oldest/p' "${file}" \
        |grep -Pv '\----- newest' |grep -Pv '\----- oldest' |head -n200 > \
        "${DM_tl}/${tpc}/.conf/data"
    elif [[ ${3} = 2 ]]; then
        sed -n '/----- oldest/,/----- end/p' "${file}" \
        |grep -Pv '\----- oldest' |grep -Pv '\----- end' |head -n200 > \
        "${DM_tl}/${tpc}/.conf/data"
    fi
    tpc_db 6 'learning'
    $DS/ifs/tls.sh check_index "${tpc}" 1
    
    stts="$(< "$DM_tl/${tpc}/.conf/stts")"
    if ! [[ ${stts} =~ $num ]]; then
        echo 13 > "$DM_tl/${tpc}/.conf/stts"; stts=13
    fi
    "$DS/ifs/tpc.sh" "${tpc}" ${stts} 0 &
    
} >/dev/null 2>&1

fback() {
    xdg-open "https://idiomind.sourceforge.io/contact.html"
} >/dev/null 2>&1


add_file() {
    cd "$HOME"
    FL=$(yad --file --title="$(gettext "Add File")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --name=Idiomind --class=Idiomind \
    --file-filter="$(gettext "Supported files") \
    | *.mp3 *.ogg *.mp4 *.m4v *.jpg *.jpeg *.png *.txt *.gif" \
    --add-preview --multiple \
    --window-icon="$DS/images/icon.png" --on-top --center \
    --width=680 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)
    ret=$?
    if [ $ret -eq 0 ]; then
        while read -r file; do
        [ -f "${file}" ] && cp -f "${file}" \
        "${DM_tlt}/files/$(basename "$file" |iconv -c -f utf8 -t ascii)"
        done <<<"$(tr '|' '\n' <<<"$FL")"
    fi
    
} >/dev/null

videourl() {
    source "$DS/ifs/mods/cmns.sh"
    n=$(ls *.url "${DM_tlt}/files/" |wc -l)
    url=$(yad --form --title=" " \
    --name=Idiomind --class=Idiomind \
    --separator="" \
    --window-icon=$DS/images/logo.png \
    --skip-taskbar --center --on-top \
    --width=420 --height=100 --borders=5 \
    --field="$(gettext "URL")" \
    --button="$(gettext "Cancel")":1 \
    --button=gtk-ok:0)
    ret=$?
    [ $ret = 1 -o -z "$url" ] && exit
    if [ ${#url} -gt 40 ] && \
        ([ ${url:0:29} = 'https://www.youtube.com/watch' ] \
        || [ ${url:0:28} = 'http://www.youtube.com/watch' ]); then \
        echo "$url" > "${DM_tlt}/files/video$n.url"
    else 
        msg "$(gettext "You have entered an invalid URL").\n" error \
        "$(gettext "You have entered an invalid URL")"
    fi
}

addFiles() {
    yad --form --title="$(gettext "Resources")" \
    --name=Idiomind --class=Idiomind \
    ---window-icon=$DS/images/logo.png --center \
    --width=320 --height=100 --borders=5 \
    --field="$(gettext "Add files")":FBTN "$DS/ifs/tls.sh 'add_file'" \
    --field="$(gettext "YouTube URL")":FBTN "$DS/ifs/tls.sh 'videourl'" \
    --button="$(gettext "Save")!gtk-apply":0 \
    --button="$(gettext "Cancel")":1
    ret=$?
    if [[ "$ch1" != "$(ls -A "${DM_tlt}/files")" ]] && [ $ret = 0 ]; then
        mkindex
    fi
}

attatchments() {
    sz=(580 450); [[ ${swind} = TRUE ]] && sz=(480 440)
    source "$DS/ifs/mods/cmns.sh"
    mkindex() {
rename 's/_/ /g' "${DM_tlt}/files"/*
echo "<html><meta http-equiv=\"Content-Type\" \
content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" \
href=\"/usr/share/idiomind/default/attch.css\">\
<body>" > "${DC_tlt}/att.html"
while read -r file; do
if grep ".mp3" <<<"${file: -4}"; then
echo "${file::-4}<br><br><audio controls>
<source src=\"../files/$file\" type=\"audio/mpeg\">
</audio><br><br>" >> "${DC_tlt}/att.html"
elif grep ".ogg" <<<"${file: -4}"; then
echo "${file::-4}<audio controls>
<source src=\"../files/$file\" type=\"audio/mpeg\">
</audio><br><br>" >> "${DC_tlt}/att.html"; fi
done <<<"$(ls "${DM_tlt}/files")"
while read -r file; do
if grep ".txt" <<<"${file: -4}"; then
txto=$(sed ':a;N;$!ba;s/\n/<br>/g' \
< "${DM_tlt}/files/$file" \
| sed 's/\"/\&quot;/;s/\&/&amp;/g')
echo "<div class=\"summary\">
<h2>${file::-4}</h2><br>$txto \
<br><br><br></div>" >> "${DC_tlt}/att.html"; fi
done <<<"$(ls "${DM_tlt}/files")"
while read -r file; do
if grep ".mp4" <<<"${file: -4}"; then
echo "${file::-4}<br><br>
<video width=450 height=280 controls>
<source src=\"../files/$file\" type=\"video/mp4\">
</video><br><br><br>" >> "${DC_tlt}/att.html"
elif grep ".m4v" <<<"${file: -4}"; then
echo "${file::-4}<br><br>
<video width=450 height=280 controls>
<source src=\"../files/$file\" type=\"video/mp4\">
</video><br><br><br>" >> "${DC_tlt}/att.html"
elif grep ".jpg" <<<"${file: -4}"; then
echo "${file::-4}<br><br>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br><br>" \
>> "${DC_tlt}/att.html"
elif grep ".jpeg" <<<"${file: -5}"; then
echo "${file::-5}<br><br>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br><br>" \
>> "${DC_tlt}/att.html"
elif grep ".png" <<<"${file: -4}"; then
echo "${file::-4}<br><br>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br><br>" \
>> "${DC_tlt}/att.html"
elif grep ".url" <<<"${file: -4}"; then
url=$(tr -d '=' < "${DM_tlt}/files/$file" \
| sed 's|watch?v|embed\/|;s|https|http|g')
echo "<iframe width=\"100%\" height=\"85%\" src=\"$url\" \
frameborder=\"0\" allowfullscreen></iframe>
<br><br>" >> "${DC_tlt}/att.html"
elif grep ".gif" <<<"${file: -4}"; then
echo "${file::-4}<br><br>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br><br>" \
>> "${DC_tlt}/att.html"; fi
done <<<"$(ls "${DM_tlt}/files")"
echo "</body></html>" >> "${DC_tlt}/att.html"

} >/dev/null 2>&1
    [ ! -d "${DM_tlt}/files" ] && mkdir "${DM_tlt}/files"
    ch1="$(ls -A "${DM_tlt}/files")"
    if [[ "$(ls -A "${DM_tlt}/files")" ]]; then
        [ ! -e "${DC_tlt}/att.html" ] && mkindex
         yad --html --title="$(gettext "Resources")" \
        --name=Idiomind --class=Idiomind \
        --encoding=UTF-8 --uri="${DC_tlt}/att.html" --browser \
        --window-icon=$DS/images/logo.png --center \
        --width=${sz[0]} --height=${sz[1]} --borders=10 \
        --button="$(gettext "Folder")":"xdg-open \"${DM_tlt}\"/files" \
        --button="$(gettext "Add")":0 \
        --button="gtk-close":1
        ret=$?
        if [ $ret = 0 ]; then "$DS/ifs/tls.sh" addFiles
        elif [ $ret = 2 ]; then "$DS/ifs/tls.sh" videourl; fi
        
        if [[ "$ch1" != "$(ls -A "${DM_tlt}/files")" ]]; then
        mkindex; fi
    else
        addFiles
    fi
} >/dev/null 2>&1


_definition() {
    source "$DS/ifs/cmns.sh"
    export query="$(sed 's/<[^>]*>//g' <<<"${2}")"
    f="$(ls "$DC_d"/*."Link.Search definition".* |head -n1)"
    if [ -z "$f" ]; then 
        "$DS_a/Resources/cnfg.sh" 3
        f="$(ls "$DC_d"/*."Link.Search definition".* |head -n1)"
    fi
    eval _url="$(< "$DS_a/Resources/scripts/$(basename "$f")")"
	export _url

python3 <<PY
import gi, os
gi.require_version("Gtk", "3.0")
gi.require_version('WebKit2', '4.0')
from gi.repository import Gtk, WebKit2 as WebKit
_url = os.environ['_url']
class Window():
	def __init__(self, *args, **kwargs):
		self._window = Gtk.Window(title = "Idiomind", 
		skip_pager_hint=True, skip_taskbar_hint=True)
		# self._window.set_icon_from_file('idiomind')
		self._window.connect('destroy', Gtk.main_quit)
		self._window.set_default_size(750, 470)
		self._view = Gtk.ScrolledWindow()
		self._webview = WebKit.WebView()
		self._webview.load_uri(_url)
		self._view.add(self._webview)
		self.vbox_container = Gtk.VBox()
		self.vbox_container.pack_start(self._view, True, True, 0)
		self._window.add(self.vbox_container)
		self._window.show_all()
		Gtk.main()
main = Window()
PY
    
} >/dev/null 2>&1

_translation() {
    source "$DS/ifs/cmns.sh"
    source /usr/share/idiomind/default/c.conf
	url="https://translate.google.com/?sl=$lgt&tl=$lgs&text=${2}&op=translate"
	export url

python3 <<PY
import gi, os
gi.require_version("Gtk", "3.0")
gi.require_version('WebKit2', '4.0')
from gi.repository import Gtk, WebKit2 as WebKit
url = os.environ['url']
class Window():
	def __init__(self, *args, **kwargs):
		self._window = Gtk.Window(title = "Idiomind", 
		skip_pager_hint=True, skip_taskbar_hint=True)
		# self._window.set_icon_from_file('idiomind')
		self._window.connect('destroy', Gtk.main_quit)
		self._window.set_default_size(750, 470)
		self._view = Gtk.ScrolledWindow()
		self._webview = WebKit.WebView()
		self._webview.load_uri(url)
		self._view.add(self._webview)
		self.vbox_container = Gtk.VBox()
		self.vbox_container.pack_start(self._view, True, True, 0)
		self._window.add(self.vbox_container)
		self._window.show_all()
		Gtk.main()
main = Window()
PY

} >/dev/null 2>&1

_help() {
    xdg-open 'https://idiomind.sourceforge.io/help.html'
    
} >/dev/null 2>&1

check_updates() {
    source "$DS/ifs/cmns.sh"; internet
    link='https://idiomind.sourceforge.io/doc/checkversion'
    nver=$(wget --user-agent "$useragent" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
    pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
    d2=$(date +%Y%m%d); cdb ${cfgdb} 3 updt date ${d2}
    if [ ${#nver} -lt 9 ] && [ ${#_version} -lt 9 ] \
    && [ ${#nver} -ge 3 ] && [ ${#_version} -ge 3 ] \
    && [[ ${nver} != ${_version} ]]; then
        msg_2 " <b>$(gettext "A new version of Idiomind available\!")</b>\t\n" \
        dialog-information "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "Information")"
        ret=$?
        if [ $ret -eq 0 ]; then xdg-open "$pkg"; fi
    else
        msg " $(gettext "No updates available.")\n" \
        dialog-information "Idiomind $nver"
    fi
} >/dev/null 2>&1

a_check_updates() {
    echo -e "\n--- Checking for updates..."
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    link='https://idiomind.sourceforge.io/doc/checkversion'
    nver=$(wget --user-agent "$useragent" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
    pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
    d1=$(cdb ${cfgdb} 1 updt date)
    d2=$(date +%Y%m%d)
    ig=$(cdb ${cfgdb} 1 updt ignr) 
    if [[ $((d1-d2)) -gt 30 ]]; then
        cdb ${cfgdb} 3 updt ignr FALSE & return
    fi
    if [[ $ig = TRUE ]]; then return; fi
    if [[ ${d1} != ${d2} ]]; then
        sleep 5; curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        cdb ${cfgdb} 3 updt date ${d2}
        if [ ${#nver} -lt 9 ] && [ ${#_version} -lt 9 ] \
        && [ ${#nver} -ge 3 ] && [ ${#_version} -ge 3 ] \
        && [[ ${nver} != ${_version} ]]; then
            msg_2 " <b>$(gettext "A new version of Idiomind available\!")\t\n</b> $(gettext "Do you want to download it now?")\n" \
            dialog-information "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "New Version")" "$(gettext "Ignore")"
            ret=$?
            if [ $ret -eq 0 ]; then
                xdg-open "$pkg"
            elif [ $ret -eq 2 ]; then
                cdb ${cfgdb} 3 updt ignr TRUE
            fi
        fi
    fi
    return 0
} 

promp_topic_info() {
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    if [ -f "${DC_tlt}/translations/active" ]; then
        active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
    fi
    if [ -n "$active_trans" -a "$active_trans" != "$slng" ]; then
        slng_err_lbl="\n$(gettext "Native languages do not match.\nYou may have to translate this topic to your own language: click \"Manage\" tab on the main window, click \"Edit\" -> \"Translate\" -> \"Automatic Translation\" ->") \"$slng\"."
        echo -e "$slng_err_lbl" >> "${DC_tlt}/slng.inf"
    elif [ -z "$active_trans" -a "$(tpc_db 1 id slng)" != "$slng" ]; then
        slng_err_lbl="\n$(gettext "Native languages do not match.\nYou may have to translate this topic to your own language: click \"Manage\" tab on the main window, click \"Edit\" -> \"Translate\" -> \"Automatic Translation\" ->") \"$slng\"."
        echo -e "$slng_err_lbl" >> "${DC_tlt}/slng.inf"
    fi
    check_err "${DC_tlt}/slng.inf" "${DC_tlt}/note.inf"
    
} >/dev/null 2>&1

first_run() {
    source /usr/share/idiomind/default/c.conf
    NOTE3="$(gettext "To start adding notes you need to have a Topic.\nCreate one using the "New" button...")"

    if [[ ${2} = topics ]]; then
        "$DS/chng.sh" "$NOTE3"; sleep 1
        source /usr/share/idiomind/default/c.conf
        if [ -n "$tpc" ]; then
            rm -f "$DC_s/topics_first_run"
            "$DS/add.sh" new_items &
        fi
    elif [[ "${2}" = 'TRUE' ]]; then
        echo "-- done"
        touch "$DC_s/topics_first_run" "$DC_s/recommended_scripts_first_run"
    elif [[ "${2}" = 'FALSE' ]]; then
        echo "-- done"
        touch "$DC_s/topics_first_run" "$DC_s/Resources_first_run"
    fi
    return
}

set_image() {
    source "$DS/ifs/cmns.sh"
    cd "$DT"; r=0
    source "$DS/ifs/mods/add/add.sh"
    if [ -e "${DM_tlt}/images/${trgt,,}.jpg" ]; then
        ifile="${DM_tlt}/images/${trgt,,}.jpg"; im=0
    else
        ifile="${DM_tls}/images/${trgt,,}-1.jpg"; im=1
    fi
    if [ -e "$DT/$trgt.img" ]; then
        msg_4 "$(gettext "Attempting download image")..." \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Wait")" "$DT/$trgt.img"
        if [ $? -eq 1 ]; then rm -f "$DT/$trgt".img; else return 1 ; fi
    fi
    if [ -e "$ifile" ]; then
        btn2="--button=!gtk-delete!$(gettext "Remove image"):2"
        image="--image=$ifile"
    else
        btn2="--button=!$DS/images/add_image.png!"$(gettext "Add an image by screen clipping")":0"
        image="--image=$DS/images/bar.png"
    fi
    export btn2 image
    dlg_form_3; ret=$?
    if [ $ret -eq 2 ]; then
        rm -f "$ifile"
        if [ ${im} = 1 ]; then
            mv -f "$img" "${DM_tlt}/images/${trgt,,}.jpg"
        else
            n=$(ls "${DM_tls}/images/${trgt,,}-"*.jpg |wc -l); n=$(($n+1))
            mv -f "$img" "${DM_tls}/images/${trgt,,}"-${n}.jpg
        fi
    elif [ $ret -eq 0 ]; then
        #GDK_BACKEND=x11 /usr/bin/import "$DT/temp.jpg"
        gnome-screenshot -a --file="$DT/temp.jpg"
        /usr/bin/convert "$DT/temp.jpg" -interlace Plane -thumbnail 405x275^ \
        -gravity center -extent 400x270 -quality 90% "$ifile"
        "$DS/ifs/tls.sh" set_image "${2}" "${trgt}" & exit
    fi
    cleanups "$DT/temp.jpg"
    exit
} >/dev/null 2>&1

function transl_batch() {
    source /usr/share/idiomind/default/c.conf
    sz=(580 450); [[ ${swind} = TRUE ]] && sz=(480 440)
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    if [ -e "$DT/transl_batch_lk" ]; then
        msg_4 "$(gettext "Please wait until the current process is finished.")" \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Wait")" "$DT/translation"
        ret=$?
        if [ $ret -eq 1 ]; then 
            cleanups "$DT/translation" \
            "$DT/transl_batch_lk" \
            "$DT/translate_to" "$DT/translation"
        else
            exit 1
        fi
    else
        > "$DT/transl_batch_lk"
    fi
    touch "${DC_tlt}/translations/active"
    active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
    lns=$(cat "${DC_tlt}/data" |wc -l)
    if [ -z "$active_trans" ]; then active_trans="$slng"; fi

echo -e "yad --form --title=\"$(gettext "$tlng") / $active_trans\" \\
--class=Idiomind --name=Idiomind --window-icon=$DS/images/logo.png \\
--always-print-result --print-all \\
--width=${sz[0]} --height=${sz[1]} --borders=5 \\
--on-top --scroll --center --separator='|\n' \\
--button=$(gettext \"Save\")!gtk-apply:0 \\
--button=$(gettext \"Cancel\"):1 \\" > "$DT/dlg"

    (echo "#"; n=1
    while read -r _item; do
        unset trgt srce; get_item "${_item}"
        trgt="$(tr -s '"' '*' <<< "${trgt}")"
        srce="$(tr -s '"' '*' <<< "${srce}")"
        echo -e "--field=\"  $trgt\":lbl \"\" --field=\"\" \"$srce\" --field=\" \":lbl \"\" \\" >> "$DT/dlg"
        let n++
        echo $((100*n/lns-1))
    done < "${DC_tlt}/data") |progress "progress"
    sed -i 's/\*/\\\"/g' "$DT/dlg"
    
    dlg="$(cat "$DT/dlg")"; eval "${dlg}" > "$DT/transl_batch_out"; ret="$?"
    
    if [ $ret = 0 ]; then
        cp -f "${DC_tlt}/data" "$DT/data"
        while read -r item_; do
            item="$(sed 's/}/}\n/g' <<< "${item_}")"
            trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
            edit_pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${DC_tlt}/data" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
            if ! [[ ${edit_pos} =~ ${numer} ]]; then
                edit_pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${trgt}}" "${DC_tlt}/data")"
            fi
            if [ -n "${trgt}" ]; then
                srce_pos=$((edit_pos*3-1))
                srce_mod="$(sed -n ${srce_pos}p "$DT/transl_batch_out" |tr -d '|')"
                if [ "${srce}" != "${srce_mod}" ]; then
                    sed -i "${edit_pos}s|srce{$srce}|srce{${srce_mod^}}|g" "$DT/data"
                fi
            fi
        done < "${DC_tlt}/data"
    fi
    
    mv -f "$DT/data" "${DC_tlt}/data"
    cleanups "$DT/dlg" "$DT/transl_batch_out" \
    "$DT/transl_batch_lk"
} >/dev/null 2>&1

translate_to() {
    source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    > "$DT/translate_to"
    source "$DS/default/sets.cfg"
    [ ! -d "$DC_tlt/translations" ] && mkdir "$DC_tlt/translations"
    list_transl_saved="$(cd "$DC_tlt/translations"; ls *.tra \
    |sed 's/\.tra//g' |tr "\\n" '!' |sed 's/\!*$//g')"
    list_transl=$(for i in "${!slangs[@]}"; do echo -n "!$i"; done)
    list_transl_saved_WC="$(cd "$DC_tlt/translations"; ls *.tra |wc -l)"
    if [ -f "${DC_tlt}/translations/active" ]; then 
        active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
    fi
    if [ -z "$active_trans" ]; then active_trans="$(tpc_db 1 id slng)"; fi
    if [ -z "$active_trans" ]; then active_trans="Undefined"; fi

    if grep "$active_trans" <<< "${list_transl_saved}"; then 
    chk=TRUE; else chk=FALSE; fi
    
    if [ ${list_transl_saved_WC} -lt 1 ]; then
        ldgl="$(yad --form --title="$(gettext "Native Language Settings")" \
        --class=Idiomind --name=Idiomind \
        --text="$(gettext "The current Native language of this topic is":)  <b>$active_trans</b>"\\n \
        --always-print-result --window-icon=$DS/images/logo.png \
        --buttons-layout=end --center --on-top --align=left \
        --width=400 --height=400 --borders=15 \
        --field="":LBL " " \
        --field="\n<b>$(gettext "Verified Translations") </b> ":LBL " " \
        --field="$(gettext "The quality of this translation was verified") ( $active_trans )":CHK "$chk" \
        --field="<small>$(gettext "This topic has no verified translations.")</small>":LBL " " \
        --field=" ":LBL " " \
        --field="\\n<b>$(gettext "Automatic Translation")</b> ":LBL " " \
        --field="$(gettext "Select native language:")":CB "${list_transl}" \
        --field="<small>$(gettext "Note: translations from google translate service sometimes is inaccurate especially in complex frases.")</small>":LBL " " \
        --field=" ":LBL " " \
        --field="\\n<b>$(gettext "Manually Translation")</b> ":LBL " " \
        --field="$(gettext "Open")":fbtn "$DS/ifs/tls.sh transl_batch" \
        --button="$(gettext "Apply")"!gtk-apply:0 \
        --button="$(gettext "Cancel")":1)"; ret="$?"
    else
        ldgl="$(yad --form --title="$(gettext "Native Language Settings")" \
        --class=Idiomind --name=Idiomind \
        --text="$(gettext "The current Native language of this topic is")  <b>$active_trans</b>" \
        --always-print-result --window-icon=$DS/images/logo.png \
        --buttons-layout=end --center --on-top --align=left \
        --width=400 --height=400 --borders=15 \
        --field="":LBL " " \
        --field="\n<b>$(gettext "Verified Translations") </b> ":LBL " " \
        --field="$active_trans — $(gettext "The quality of this translation was verified")":CHK "$chk" \
        --field="$(gettext "Change native language:")":CB "!${list_transl_saved}" \
        --field=" ":LBL " " \
        --field="<b>$(gettext "Automatic Translation")</b> ":LBL " " \
        --field="$(gettext "Select native language:")":CB "${list_transl}" \
        --field="<small>$(gettext "Note: translations from google translate service sometimes is inaccurate especially in complex frases.")</small>":LBL " " \
        --field=" ":LBL " " \
        --field="<b>$(gettext "Manually Translation")</b> ":LBL " " \
        --field="$(gettext "Open")":fbtn "$DS/ifs/tls.sh transl_batch" \
        --button="$(gettext "Apply")"!gtk-apply:0 \
        --button="$(gettext "Cancel")":1)"; ret="$?"
    fi
    review_trans="$(cut -f4 -d'|' <<< "$ldgl")"
    review_chek="$(cut -f3 -d'|' <<< "$ldgl")"
    autom_trans="$(cut -f7 -d'|' <<< "$ldgl")"

    if [ "$ret" = 0 ]; then
        [ -e "${DC_tlt}/slng_err" ] && mv "${DC_tlt}/slng_err" "${DC_tlt}/slng_err.bk"
        if [ "$review_chek" = TRUE ]; then
            cp -f "${DC_tlt}/data" "${DC_tlt}/translations/$active_trans.tra"
            echo "$active_trans" > "${DC_tlt}/translations/active"
        elif [ "$review_chek" = FALSE ]; then
            cleanups "${DC_tlt}/translations/$active_trans.tra"
        fi
        if [ "$review_trans" != "$active_trans" -a -n "$review_trans" -a "$review_trans" != "(null)" ]; then
            if [ -e "${DC_tlt}/translations/$review_trans.tra" ]; then
                yad_kill "yad --form --title="
                cp -f "${DC_tlt}/translations/$review_trans.tra" "${DC_tlt}/data"
                echo "$review_trans" > "${DC_tlt}/translations/active"
            fi
        elif [ -n "$autom_trans" -a "$autom_trans" != "(null)" ]; then
            yad_kill "yad --form --title="
            if grep "$autom_trans" <<< "$(cd "$DC_tlt/translations"; ls *.bk)"; then
                msg_2 "$(gettext "There is a copy of this translation. Do you want to restore the copy instead of translating again?")" dialog-question "$(gettext "Restore")" "$(gettext "Translate Again")" " "
                if [ $? = 0 ]; then
                    mv -f "$DC_tlt/translations/$autom_trans.bk" "${DC_tlt}/data"
                    cleanups "$DT/translation" "$DT/transl_batch_lk" \
                    "$DT/translate_to" "${DC_tlt}/slng_err.bk"
                    echo "$autom_trans" > "${DC_tlt}/translations/active"
                    exit 1
                else
                    cleanups "$DC_tlt/translations/$autom_trans.bk"
                fi
            fi
            if grep "$autom_trans" <<< "$(cd "$DC_tlt/translations"; ls *.tra)"; then
                msg_2 "$(gettext "There is a verified translation for this language. Do you want to use this copy instead of translating again?")" dialog-question "$(gettext "Restore")" "$(gettext "Translate Again")" " "
                if [ $? = 0 ]; then
                    cp -f "$DC_tlt/translations/$autom_trans.tra" "${DC_tlt}/data"
                    echo "$autom_trans" > "${DC_tlt}/translations/active"
                    cleanups "$DT/translation" "$DT/transl_batch_lk" \
                    "$DT/translate_to" "${DC_tlt}/slng_err.bk"
                    exit 1
                fi
                fi
            > "$DT/words.trad_tmp"; > "$DT/index.trad_tmp"; > "$DT/translation"
            del='~~'
            internet
            l=$(tpc_db 1 lang tlng)
            if [ -n "$l" ]; then lgt=${tlangs[$l]}; else lgt=${tlangs[$tlng]}; fi
            tl=${slangs[$autom_trans]}
            include "$DS/ifs/mods/add"
            c1=$(cat "${DC_tlt}/data" |wc -l)

            pretrans() {
                while read -r item_; do
                    item="$(sed 's/}/}\n/g' <<< "${item_}")"
                    type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
                    trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
                    if [ -n "${trgt}" ]; then
                        echo "${trgt}" \
                        |python3 -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
                        |sed 's/ /\n/g' |grep -Pv '^.$' |grep -Pv '^..$' \
                        |tr -d '*)(,;"“”:' |tr -s '&{}[]' ' ' \
                        |sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
                        |sed 's/\]//;s/\[//;s/<[^>]*>//g' \
                        |sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' \
                        |tr -d '.' |sed 's/^ *//; s/ *$//; /^$/d' >> "$DT/words.trad_tmp"
                        echo "|" >> "$DT/words.trad_tmp"
                        echo "${trgt} ${del}" >> "$DT/index.trad_tmp"
                    fi
                done < "${DC_tlt}/data"
           
                sed -i ':a;N;$!ba;s/\n/\. /g' "$DT/words.trad_tmp"
                sed -i 's/|/|\n/g' "$DT/words.trad_tmp"
                sed -i 's/^..//' "$DT/words.trad_tmp"
                index_to_trad="$(< "$DT/index.trad_tmp")"
                words_to_trad="$(< "$DT/words.trad_tmp")"
                translate "${index_to_trad}" "$lgt" "$tl" > "$DT/index.trad"
                sleep 1 && translate "${words_to_trad}" "$lgt" "$tl" > "$DT/words.trad"
                sed -i ':a;N;$!ba;s/\n/ /g' "$DT/index.trad"
                sed -i "s/${del}n/\n/g" "$DT/index.trad"
                sed -i "s/${del}/\n/g" "$DT/index.trad"
                sed -i 's/^ *//; s/ *$//g' "$DT/index.trad"
                sed -i ':a;N;$!ba;s/\n/ /g' "$DT/words.trad"
                sed -i 's/|n/\n/g' "$DT/words.trad"
                sed -i 's/|/\n/g' "$DT/words.trad"
                sed -i 's/^ *//; s/ *$//;s/\。/\. /g' "$DT/words.trad"
                paste -d '&' "$DT/words.trad_tmp" "$DT/words.trad" > "$DT/mix_words.trad_tmp"
             }
             
            ( notify-send -i info "$(gettext "Translating")" \
            "$(gettext "Please wait ...")" -t 8000 ) &
            
            pretrans 

            c2=$(cat "$DT/index.trad" | wc -l)
            if [[ ${c1} != ${c2} ]]; then
                > "$DT/words.trad_tmp"; > "$DT/index.trad_tmp"
                del='||'; pretrans
                c2=$(cat "$DT/index.trad" | wc -l)
                if [[ ${c1} != ${c2} ]]; then
                    > "$DT/words.trad_tmp"; > "$DT/index.trad_tmp"
                    del=":"; pretrans
                    c2=$(cat "$DT/index.trad" | wc -l)
                    if [[ ${c1} != ${c2} ]]; then
                        > "$DT/words.trad_tmp"; > "$DT/index.trad_tmp"
                        del="_"; pretrans
                        c2=$(cat "$DT/index.trad" | wc -l)
                        if [[ ${c1} != ${c2} ]]; then
                        msg "$(gettext "There was a problem with the translation;\nSome items were not translated correctly.")\n" 'dialog-warning'
                        fi
                    fi
                fi
            fi
            if [ -z "$(< "$DT/index.trad")" -o -z "$(< "$DT/words.trad")" ]; then
                msg "$(gettext "A problem has occurred, try again later.")\n" 'dialog-warning'
                cleanups "$DT/words.trad_tmp" "$DT/index.trad_tmp" \
                "$DT/mix_words.trad_tmp" "$DT/translate_to" "$DT/translation"
                [ -e "${DC_tlt}/slng_err.bk" ] && mv "${DC_tlt}/slng_err.bk" "${DC_tlt}/slng_err"
                exit 1
            fi
            n=1
            while read -r item_; do
                [ ! -f "$DT/translation" ] && break
                get_item "${item_}"
                srce="$(sed -n ${n}p "$DT/index.trad")"; srce="${srce^}"
                tt="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f1 \
                |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' |tr -d '|.')"
                st="$(sed -n ${n}p "$DT/mix_words.trad_tmp" |cut -d '&' -f2 \
                |sed 's/\. /\n/g' |sed 's/^ *//; s/ *$//g' |tr -d '|.')"
                (bcle=1; > "$DT/w.tmp"
                while [[ ${bcle} -le $(wc -l <<< "${tt}") ]]; do
                    t="$(sed -n ${bcle}p <<< "${tt}" |sed 's/^\s*./\U&\E/g')"
                    s="$(sed -n ${bcle}p <<< "${st}" |sed 's/^\s*./\U&\E/g')"
                    echo "${t}_${s}" >> "$DT/w.tmp"
                    let bcle++
                done)
                wrds="$(tr '\n' '_' < "$DT/w.tmp" |sed '/^$/d')"
                eval line="$(sed -n 2p $DS/default/vars)"
                echo -e "${line}" >> "$DT/translation"
            let n++
            done < "${DC_tlt}/data"
            unset item type trgt srce exmp defn note grmr mark link tag cdid
            if [ -n "$DT" ]; then rm -f "$DT"/*.tmp "$DT"/*.trad "$DT"/*.trad_tmp; fi

            if [ -e "$DT/translation" ]; then
                mv -f "${DC_tlt}/data" "${DC_tlt}/translations/$active_trans.bk"
                mv -f "$DT/translation" "${DC_tlt}/data"
                echo "$autom_trans" > "${DC_tlt}/translations/active"
            fi
        fi
        active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
        if [[ "$active_trans" != "$slng" ]]; then
            touch "${DC_tlt}/slng_err"
        fi
    fi
    cleanups "$DT/translate_to" "${DC_tlt}/slng_err.bk"
} >/dev/null 2>&1

update_addons() {
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
    f_lock 1 "$DT/co_lk"
    cleanups "${DC_tlt}/index"
    touch "${DM_tlt}"
    reviews="$(tpc_db 5 reviews |wc -l)"
    acheck="$(tpc_db 1 config acheck)"
    marks="$(tpc_db 5 marks)"
    learning="$(tpc_db 5 learning)"
    if [[ "$reviews" -ge 2 ]] && \
    [[ "$acheck" = TRUE ]] && [[ ${2} = 1 ]]; 
    then chk=TRUE; else chk=FALSE; fi
    data="${DC_tlt}/data"
    index="${DC_tlt}/index"
    log3="$(cat "${DC_tlt}/practice"/log3)"
    log2="$(cat "${DC_tlt}/practice"/log2)"
    log1="$(cat "${DC_tlt}/practice"/log1)"
    export chk data learning index marks log1 log2 log3
python3 <<PY
import os, re, sys
chk = os.environ['chk']
data = os.environ['data']
learning = os.environ['learning']
index = os.environ['index']
marks = os.environ['marks']
log1 = os.environ['log1']
log2 = os.environ['log2']
log3 = os.environ['log3']
learning = learning.split('\n')
marks = marks.split('\n')
data = [line.strip() for line in open(data)]
f = open(index, "w")
for item in data:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    item = (fields[0].split('trgt{'))[1].split('}')[0]
    if item in learning:
        srce = (fields[1].split('srce{'))[1].split('}')[0]
        if item in marks:
            i="<b><big>"+item+"</big></b>"
        else:
            i=item
        if item in log3:
            f.write("<span color='#AE3259'>"+i+"</span>\nFALSE\n"+srce+"\n")
        elif item in log2:
            f.write("<span color='#C15F27'>"+i+"</span>\nFALSE\n"+srce+"\n")
        elif item in log1:
            f.write("<span color='#4C8C12'>"+i+"</span>\n"+chk+"\n"+srce+"\n")
        else:
            f.write(i+"\nFALSE\n"+srce+"\n")
f.close()
PY
    f_lock 3 "$DT/co_lk"
} >/dev/null 2>&1

itray() {
    source /usr/share/idiomind/default/c.conf
    [ ! -e "$HOME/.config/idiomind/tpc" ] && \
    touch "$HOME/.config/idiomind/tpc"
    source "$DS/default/sets.cfg"
    export lbl1="$(gettext "Add")"
    export lbl2="$(gettext "Play")"
    export lbl3="$(gettext "Stop playback")"
    export lbl4="$(gettext "Next")"
    export lbl5="$(gettext "Index")"
    export lbl9="$(gettext "Tasks")"
    export lbl10="$(gettext "Settings")"
    export lbl8="$(gettext "Quit")"
    export dirt="$DT/"
    export lgt=${tlangs[$tlng]}
    python3 <<PY
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
gi.require_version('AyatanaAppIndicator3', '0.1')
gi.require_version('Notify', '0.7')
import time, os, os.path, sys
try:
    from gi.repository import AyatanaAppIndicator3 as AppIndicator
except ImportError:
    try:
        from gi.repository import AppIndicator3 as AppIndicator
    except ImportError:
        from gi.repository import AppIndicator
from gi.repository import Gtk, Gio, Notify
HOME = os.getenv('HOME')
add = os.environ['lbl1']
play = os.environ['lbl2']
stop = os.environ['lbl3']
next = os.environ['lbl4']
topics = os.environ['lbl5']
tasks = os.environ['lbl9']
settings = os.environ['lbl10']
quit = os.environ['lbl8']
my_pid = os.getpid()
f_pid = open(os.environ['dirt']+'tray.pid', 'w')
f_pid.write(str(my_pid))
f_pid.close()
class IdiomindIndicator:
    def __init__(self):
        self.indicator = AppIndicator.Indicator.new("idiomind", "idiomind", AppIndicator.IndicatorCategory.OTHER)
        self.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE)
        self.DIRT = os.environ['dirt']
        self.tpc = os.getenv('HOME') + '/.config/idiomind/tpc'
        self.playlck = self.DIRT + 'playlck'
        self.tasks = self.DIRT + 'tasks'
        Notify.init("Idiomind")
        self.indicator.set_title("Idiomind")
        self.menu_items = []
        self.stts = 1
        self.change_topic()
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
        self.change_topic()
    def create_menu_label(self, label):
        item = Gtk.ImageMenuItem()
        item.set_label(label)
        return item
    def create_menu_icon(self, label, icon_name):
        image = Gtk.Image()
        image.set_from_icon_name(icon_name, 24)
        item = Gtk.ImageMenuItem()
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
    def change_topic(self):
        menu_items = self.make_menu_items()
        popup_menu = Gtk.Menu()
        for Label, callback in menu_items:
            if not Label and not callback:
                item = Gtk.SeparatorMenuItem()
            else:
                item = Gtk.ImageMenuItem(label=Label)
                item.connect('activate', callback)
            popup_menu.append(item)
        try:
            m = open(self.tpc).readlines()
        except:
            m = []
        for bm in m:
            label = bm.rstrip('\n')
            if not label:
                label = ""
            item = self.create_menu_icon(label, "go-home")
            item.connect("activate", self.on_Home)
            popup_menu.append(item)
        item = Gtk.SeparatorMenuItem()
        popup_menu.append(item)
        if os.path.exists(self.tasks):
            listMenu=Gtk.Menu()
            listItems=Gtk.MenuItem(label=tasks)
            listItems.set_submenu(listMenu)
            try:
                m = open(self.tasks).readlines()
            except:
                m = []
            for bm in m:
                Label = bm.rstrip('\n')
                if not Label:
                    Label = ""
                item = self.create_menu_label(label=Label)
                item.connect("activate", self.on_Task)
                listMenu.append(item)
            popup_menu.append(listItems)
            item.show()
            listItems.show()
        item = self.create_menu_label(topics)
        item.connect("activate", self.on_Topics_click)
        popup_menu.append(item)
        item = Gtk.SeparatorMenuItem()
        popup_menu.append(item)
        item = self.create_menu_label(settings)
        item.connect("activate", self.on_settings_click)
        popup_menu.append(item)
        item = self.create_menu_label(quit)
        item.connect("activate", self.on_Quit_click)
        popup_menu.append(item)
        popup_menu.show_all()
        self.indicator.set_menu(popup_menu)
        self.menu_items = menu_items
    def on_Task(self, widget):
        t = widget.get_child()
        t = t.get_label()
        os.system("/usr/share/idiomind/ifs/tasks.sh \"%s\"" % (str(t)))
    def on_Home(self, widget):
        os.system("idiomind topic &")
    def on_Add_click(self, widget):
        os.system("/usr/share/idiomind/add.sh new_items &")
    def on_Topics_click(self, widget):
        os.system("/usr/share/idiomind/chng.sh &")
    def on_play(self, widget):
        self.stts = 0
        os.system("/usr/share/idiomind/bcle.sh &")
        self._on_menu_update()
    def on_stop(self, widget):
        self.stts = 1
        os.system("/usr/share/idiomind/stop.sh 2 &")
        self._on_menu_update()
    def on_settings_click(self, widget):
        os.system("/usr/share/idiomind/cnfg.sh &")
    def on_Quit_click(self, widget):
        os.system("/usr/share/idiomind/stop.sh 1 &")
        Gtk.main_quit()
    def callback(self, m, f, o, event):
        if event == Gio.FileMonitorEvent.CHANGES_DONE_HINT:
            self._on_menu_update()
if __name__ == "__main__":
    i = IdiomindIndicator()
    gdir = Gio.File.new_for_path(i.DIRT)
    monitor = gdir.monitor_directory(Gio.FileMonitorFlags.NONE, None)
    monitor.connect("changed", i.callback)
    Gtk.main()
PY
}

about() {
    export _descrip="$(gettext "Language learning tool")"
    python3 << ABOUT
from gi.repository import Gtk as gtk
import os
app_logo = os.path.join('/usr/share/idiomind/images/logo.png')
app_icon = os.path.join('/usr/share/icons/hicolor/22x22/apps/idiomind.png')
app_name = 'Idiomind'
app_version = os.environ['_version']
app_website = os.environ['_website']
app_comments = os.environ['_descrip']
app_copyright = os.environ['_copyright']
app_license = (('This program is free software: you can redistribute it and/or modify\n'+
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
app_authors = ['Robin Palatnik <robinpalat@users.sourceforge.io>']
class AboutDialog:
    def __init__(self):
        about = gtk.AboutDialog()
        about.set_logo_icon_name("idiomind")
        about.set_icon_from_file(app_icon)
        about.set_wmclass('Idiomind', 'Idiomind')
        about.set_name(app_name)
        about.set_program_name(app_name)
        about.set_version(app_version)
        about.set_comments(app_comments)
        about.set_copyright(app_copyright)
        about.set_license(app_license)
        about.set_authors(app_authors)
        about.set_website(app_website)
        about.run()
        about.destroy()
if __name__ == "__main__":
    AboutDialog = AboutDialog()
    main()
ABOUT
} >/dev/null 2>&1


clipw() {
    if [ -f $DT/tpe ]; then 
        tpe="$(sed -n 1p $DT/tpe |sed -e 's/^ *//' -e 's/ *$//')"
    fi
    if [ -n "${tpe}" ]; then
        info="$(gettext "Notes will be added to:") \"$tpe\""
    else
        info="$(gettext "No topic selected or active")"
    fi
    if [[ ! -e $DT/clipw  ]]; then
        "$DS/ifs/clipw.sh" &
        sleep 1
        notify-send -i info "$(gettext "Information")" \
"$(gettext "The clipboard watcher is enabled for 5 minutes...")
 $info" -t 8000
    else 
        "$DS/ifs/clipw.sh" 1
    fi
    
} >/dev/null 2>&1


case "$1" in
    backup)
    _backup "$@" ;;
    restore)
    _restore_backup "$@" ;;
    check_index)
    check_index "$@" ;;
    addFiles)
    addFiles "$@" ;;
    videourl)
    videourl "$@" ;;
    add_file)
    add_file "$@" ;;
    attatchs)
    attatchments "$@" ;;
    add_audio)
    add_audio "$@" ;;
    help)
    _help ;;
    check_updates)
    check_updates ;;
    a_check_updates)
    a_check_updates ;;
    promp_topic_info)
    promp_topic_info "$@" ;;
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
    update_addons)
    update_addons ;;
    _stats)
    stats_dlg ;;
    colorize)
    colorize "$@" ;;
    transl_batch)
    transl_batch ;;
    translate)
    translate_to ;;
    itray)
    itray ;;
    about)
    about ;;
    clipw)
    clipw "$@" ;;
esac
