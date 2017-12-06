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
        msg "$(gettext "File is corrupted.") ${1}\n" error & exit 1
    }
    if [ ! -f "${file}" ]; then invalid
    elif [ $(wc -l < "${file}") != 3 ]; then invalid "$(wc -l < "${file}") Lines!"
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
	id_lines=18
    cnfg10_lines=12
    
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    DC_tlt="$DM_tl/${2}/.conf"
    DM_tlt="$DM_tl/${2}"
    tpc="${2}"; mkmn=0; f=0; c=0
    [[ ${3} = 1 ]] && r=1 || r=0

    _check() {
        if [ ! -f "${DC_tlt}/0.cfg" ]; then export f=1; fi
        
        check_dir "${DC_tlt}" "${DC_tlt}" "${DM_tlt}/images" "${DC_tlt}/practice"
        check_file "${DC_tlt}/practice/log1" "${DC_tlt}/practice/log2" "${DC_tlt}/practice/log3" \
        "${DC_tlt}/9.cfg" "${DC_tlt}/10.cfg" "${DC_tlt}/info"
        
        for n in {0..4}; do
            if [ ! -e "${DC_tlt}/${n}.cfg" ]; then 
                touch "${DC_tlt}/${n}.cfg"; export f=1
            fi
            if grep '^$' "${DC_tlt}/${n}.cfg"; then
                sed -i '/^$/d' "${DC_tlt}/${n}.cfg"
            fi
        done
        cfg="${DC_tlt}/10.cfg"
        if [[ $(wc -l < "${cfg}") != ${cnfg10_lines} ]]; then
            source "$DS/default/sets.cfg"; > "${cfg}"
            for n in ${psets[@]}; do
                echo -e "${n}=\"FALSE\"" >> "${cfg}"
            done
            sed -i "s/acheck=.*/acheck=\"TRUE\"/g" "${cfg}"
            sed -i "s/repass=.*/repass=\"0\"/g" "${cfg}"
            sed -i "s/words=.*/words=\"TRUE\"/g" "${cfg}"
            sed -i "s/sntcs=.*/sntcs=\"TRUE\"/g" "${cfg}"
        fi
        id=1
        [ ! -e "${DC_tlt}/id.cfg" ] && touch "${DC_tlt}/id.cfg" && id=0
        [[ $(egrep -cv '#|^$' < "${DC_tlt}/id.cfg") != ${id_lines} ]] && id=0
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
        cnt1=$(wc -l < "${DC_tlt}/1.cfg" |sed '/^$/d')
        cnt2=$(wc -l < "${DC_tlt}/2.cfg" |sed '/^$/d')
        if [ $((cnt1+cnt2)) != ${cnt0} ]; then export f=1; fi
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

    _check

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

create_cfgfile() {
	db="$HOME/.config/idiomind/config"
	echo -n "create table if not exists opts \
	(gramr TEXT, wlist TEXT, trans TEXT, dlaud TEXT, ttrgt TEXT, clipw TEXT, itray TEXT, \
	swind TEXT, stsks TEXT, tlang TEXT, slang TEXT, synth TEXT, txaud TEXT, intrf TEXT);" |sqlite3 "${db}"
	echo -n "create table if not exists lang \
	(tlng TEXT, slng TEXT);" |sqlite3 "${db}"
	echo -n "create table if not exists geom \
	(vals TEXT);" |sqlite3 "${db}"
	echo -n "create table if not exists user \
	(autr TEXT, pass TEXT);" |sqlite3 "${db}"
	echo -n "create table if not exists sess \
	(date TEXT);" |sqlite3 "${db}"
	echo -n "create table if not exists updt \
	(date TEXT);" |sqlite3 "${db}"
	sqlite3 "${db}" "insert into opts (gramr,wlist,trans,dlaud,ttrgt,\
	clipw,itray,swind,stsks,tlang,slang,synth,txaud,intrf) \
	values ('FALSE','FALSE','FALSE','FALSE','FALSE','FALSE','FALSE',\
	'FALSE','FALSE','','','','','default');"
	sqlite3 "${db}" "insert into lang (tlng,slng) values ('','');"
	sqlite3 "${db}" "insert into user (autr,pass) values ('','');"
	sqlite3 "${db}" "insert into geom (vals) values ('');"
	v=$(date +%d)
	sqlite3 "${db}" "insert into sess (date) values ('${v}');"
	sqlite3 "${db}" "insert into updt (date) values ('${v}');"
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
    cleanups "${DM_tl}/${2}/.conf/1.cfg"
    $DS/ifs/tls.sh check_index "${2}" 1
    
    mode="$(< "$DM_tl/${2}/.conf/8.cfg")"
    if ! [[ ${mode} =~ $num ]]; then
        echo 13 > "$DM_tl/${2}/.conf/8.cfg"; mode=13
    fi
    
    "$DS/ifs/tpc.sh" "${2}" ${mode} 0 &
} >/dev/null 2>&1

fback() {
    xdg-open "http://idiomind.sourceforge.net/contact"
} >/dev/null 2>&1


add_file() {
    cd "$HOME"
    FL=$(yad --file --title="$(gettext "Add File")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --name=Idiomind --class=Idiomind \
    --file-filter="*.mp3 *.ogg *.mp4 *.m4v *.jpg *.jpeg *.png *.txt *.gif" \
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
    --window-icon=idiomind \
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
	yad --form --title="$(gettext "Attached Files")" \
	--name=Idiomind --class=Idiomind \
	---window-icon=idiomind --center \
	--width=320 --height=100 --borders=5 \
	--field="$(gettext "Add files")":FBTN "$DS/ifs/tls.sh 'add_file'" \
	--field="$(gettext "YouTube URL")":FBTN "$DS/ifs/tls.sh 'videourl'" \
	--button="$(gettext "Cancel")":1 \
	--button="$(gettext "OK")":0
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
	     yad --html --title="$(gettext "Attached Files")" \
		--name=Idiomind --class=Idiomind \
		--encoding=UTF-8 --uri="${DC_tlt}/att.html" --browser \
		--window-icon=idiomind --center \
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
    local link="https://translate.google.com/#$lgt/$lgs/${2}"
    sz=(800 500); [[ ${swind} = TRUE ]] && sz=(700 400)
    yad --html --title="" \
    --name=Idiomind --class=Idiomind \
    --uri="${link}" --browser \
    --window-icon=idiomind \
    --fixed --on-top --mouse \
    --width=${sz[0]} --height=${sz[1]} --borders=5 \
    --button="$(gettext "Close")":1 &
} >/dev/null 2>&1

_help() {
    sz=(540 500); [[ ${swind} = TRUE ]] && sz=(520 420)
    _url='http://idiomind.sourceforge.net/doc/help.html'
    yad --html --title="$(gettext "Get started")" \
    --name=Idiomind --class=Idiomind \
    --uri="${_url}" \
    --window-icon=idiomind \
    --fixed --on-top --mouse \
    --width=${sz[0]} --height=${sz[1]} --borders=5 \
    --button="$(gettext "Close")":1 &
} >/dev/null 2>&1

check_updates() {
    source "$DS/ifs/cmns.sh"; internet
    link='http://idiomind.sourceforge.net/doc/checkversion'
    nver=$(wget --user-agent "$useragent" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
    pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
    d2=$(date +%Y%m%d); mod_val updt date ${d2}
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
} >/dev/null 2>&1

a_check_updates() {
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    link='http://idiomind.sourceforge.net/doc/checkversion'
    nver=$(wget --user-agent "$useragent" -qO - "$link" |grep \<body\> |sed 's/<[^>]*>//g')
    pkg='https://sourceforge.net/projects/idiomind/files/latest/download'
    d1=$(read_val updt date)
    d2=$(date +%Y%m%d)
    ig=$(read_val updt ignr)
	if [[ $((d1-d2)) -gt 30 ]]; then
		mod_val updt ignr FALSE & return
	fi
	if [[ $ig = TRUE ]]; then return; fi
    if [[ ${d1} != ${d2} ]]; then
        sleep 5; curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        mod_val updt date ${d2}
        if [ ${#nver} -lt 9 ] && [ ${#_version} -lt 9 ] \
        && [ ${#nver} -ge 3 ] && [ ${#_version} -ge 3 ] \
        && [[ ${nver} != ${_version} ]]; then
            msg_2 " <b>$(gettext "A new version of Idiomind available\!")\t\n</b> $(gettext "Do you want to download it now?")\n" \
            dialog-information "$(gettext "Download")" "$(gettext "Cancel")" "$(gettext "New Version")" "$(gettext "Ignore")"
            ret=$?
            if [ $ret -eq 0 ]; then
                xdg-open "$pkg"
            elif [ $ret -eq 2 ]; then
                mod_val updt ignr TRUE
            fi
        fi
    fi
   return 0
} 

promp_topic_info() {
    [ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
    source "$DS/ifs/cmns.sh"
    source "$DS/default/sets.cfg"
    active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
    slng_err_lbl="$(gettext "You may need to translate this topic to your language: click \"Edit\" tab on the main window, click \"Translate\" button, and then in \"Automatic Translation\" select from the list of languages:") \"$slng\""
    slng_err_lbl="$(printf '%s\n' "$slng_err_lbl"| fold -s -w80)"
    
    if [ -e "${DC_tlt}/note_err" ]; then
        include "$DS/ifs/mods/add"
        dlg_text_info_3 "$(cat "${DC_tlt}/note_err")"
        cleanups "${DC_tlt}/note_err"
    fi
    if [ -e "${DC_tlt}/slng_err" ]; then
        msg "$slng_err_lbl" "face-worried" \
        "$(gettext "Languages")" \
        "$(gettext "OK")"
        cleanups "${DC_tlt}/slng_err"
        
    elif [ -n "$active_trans" -a "$active_trans" != "$slng" ]; then
        msg "$slng_err_lbl" "face-worried" \
        "$(gettext "Languages")" \
        "$(gettext "OK")"
    fi
    
} >/dev/null 2>&1

first_run() {
    source /usr/share/idiomind/default/c.conf
    dlg() {
        sleep 3; mv -f "${file}" "${file}".p
        yad --title="$title" --text="${note}" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --image=dialog-information --window-icon=idiomind \
        --image-on-top --on-top --sticky --center \
        --width=500 --height=140 --borders=5 \
        --button="$(gettext "Do not show again")":1 \
        --button="$(gettext "OK")":0
        [ $? = 1 ] && rm -f "${file}" "${file}".p
    }
    NOTE2="$(gettext "Close and reopen the main window to see any changes.")"
    NOTE3="$(gettext "To start adding notes you need to have a Topic.\nCreate one using the "New" button...")"

    if [[ ${2} = edit_list ]]; then
        title="$(gettext "Info")"
        note="${NOTE2}"
        file="$DC_s/elist_first_run"
        dlg
    elif [[ ${2} = topics ]]; then
        "$DS/chng.sh" "$NOTE3"; sleep 1
        source /usr/share/idiomind/default/c.conf
        if [ -n "$tpc" ]; then
            rm -f "$DC_s/topics_first_run"
            "$DS/add.sh" new_items &
        fi
    elif [[ -z "${2}" ]]; then
        echo "-- done"
        touch "$DC_s/elist_first_run" \
        "$DC_s/topics_first_run" \
        "$DC_s/dics_first_run"
    fi
    exit
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
        btn2="--button=!edit-delete!$(gettext "Remove image"):2"
        image="--image=$ifile"
    else
        btn2="--button=!image-x-generic!"$(gettext "Add an image by screen clipping")":0"
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
        /usr/bin/import "$DT/temp.jpg"
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
    if [ -e "$DT/transl_batch_lk" -o -e "$DT/translate_to" ]; then
        msg_4 "$(gettext "Please wait until the current actions are finished")" \
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
    lns=$(cat "${DC_tlt}/0.cfg" |wc -l)
    if [ -z "$active_trans" ]; then active_trans="$slng"; fi

echo -e "yad --form --title=\"$(gettext "$tlng") / $active_trans\" \\
--class=Idiomind --name=Idiomind --window-icon=idiomind \\
--always-print-result --print-all \\
--width=${sz[0]} --height=${sz[1]} --borders=5 \\
--on-top --scroll --center --separator='|\n' \\
--button=\!'gtk-preferences':\"idiomind translate\" \\
--button=$(gettext \"Save\")!document-save:0 \\
--button=$(gettext \"Cancel\"):1 \\" > "$DT/dlg"

    (echo "#"; n=1
    while read -r _item; do
        unset trgt srce; get_item "${_item}"
        trgt="$(tr -s '"' '*' <<< "${trgt}")"
        srce="$(tr -s '"' '*' <<< "${srce}")"
        echo -e "--field=\"  $trgt\":lbl \"\" --field=\"\" \"$srce\" --field=\" \":lbl \"\" \\" >> "$DT/dlg"
        let n++
        echo $((100*n/lns-1))
    done < "${DC_tlt}/0.cfg") |progress "progress"
    sed -i 's/\*/\\\"/g' "$DT/dlg"
    
    dlg="$(cat "$DT/dlg")"; eval "${dlg}" > "$DT/transl_batch_out"; ret="$?"
    
    if [ $ret = 0 ]; then
        cp -f "${DC_tlt}/0.cfg" "$DT/0.cfg"
        while read -r item_; do
            item="$(sed 's/}/}\n/g' <<< "${item_}")"
            trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
            edit_pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${DC_tlt}/0.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
            if ! [[ ${edit_pos} =~ ${numer} ]]; then
                edit_pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${trgt}}" "${DC_tlt}/0.cfg")"
            fi
            if [ -n "${trgt}" ]; then
                srce_pos=$((edit_pos*3-1))
                srce_mod="$(sed -n ${srce_pos}p "$DT/transl_batch_out" |tr -d '|')"
                if [ "${srce}" != "${srce_mod}" ]; then
                    sed -i "${edit_pos}s|srce{$srce}|srce{${srce_mod^}}|g" "$DT/0.cfg"
                fi
            fi
        done < "${DC_tlt}/0.cfg"
    fi
    
    mv -f "$DT/0.cfg" "${DC_tlt}/0.cfg"
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
    active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
    if [ -z "$active_trans" ]; then active_trans="$slng"; fi
    if grep "$active_trans" <<< "${list_transl_saved}"; then chk=TRUE; else chk=FALSE; fi
    
    if [ ${list_transl_saved_WC} -lt 1 ]; then
        ldgl="$(yad --form --title="$(gettext "Native Language Settings")" \
        --class=Idiomind --name=Idiomind \
        --text="$(gettext "The current Native language of this topic is") <b>$active_trans</b>" \
        --text-align=center --always-print-result --window-icon=idiomind \
        --buttons-layout=end --center --on-top \
        --width=390 --height=350 --borders=12 \
        --field="":LBL " " \
        --field="\n<b>$(gettext "Verified translations") </b> ":LBL " " \
        --field="$active_trans — $(gettext "The  accuracy of this translation was verified")":CHK "$chk" \
        --field="<small>$(gettext "This topic has no verified translations.")</small>":LBL " " \
        --field=" ":LBL " " \
        --field=" ":LBL " " \
        --field="<b>$(gettext "Automatic translation")</b> ":LBL " " \
        --field="$(gettext "Select Native language to translate automaticly:")":CB "${list_transl}" \
        --field="<small>$(gettext "Note that translation from google translate service sometimes is inaccurate especially in complex frases.")</small>":LBL " " \
        --button="$(gettext "Apply")"!gtk-apply:0 \
        --button="$(gettext "Cancel")":1)"; ret="$?"
    else
        ldgl="$(yad --form --title="$(gettext "Native Language Settings")" \
        --class=Idiomind --name=Idiomind \
        --text="$(gettext "The current Native language of this topic is") <b>$active_trans</b>" \
        --text-align=center --always-print-result --window-icon=idiomind \
        --buttons-layout=end --center --on-top \
        --width=390 --height=350 --borders=12 \
        --field="":LBL " " \
        --field="\n<b>$(gettext "Verified translations") </b> ":LBL " " \
        --field="$active_trans — $(gettext "The  accuracy of this translation was verified")":CHK "$chk" \
        --field="$(gettext "Change the Native language:")":CB "!${list_transl_saved}" \
        --field=" ":LBL " " \
        --field="<b>$(gettext "Automatic translation")</b> ":LBL " " \
        --field="$(gettext "Select Native language:")":CB "${list_transl}" \
        --field="<small>$(gettext "Note that translation from google translate service sometimes is inaccurate especially in complex frases.")</small>":LBL " " \
        --button="$(gettext "Apply")"!gtk-apply:0 \
        --button="$(gettext "Cancel")":1)"; ret="$?"
    fi
    review_trans="$(cut -f4 -d'|' <<< "$ldgl")"
    review_chek="$(cut -f3 -d'|' <<< "$ldgl")"
    autom_trans="$(cut -f7 -d'|' <<< "$ldgl")"
    
    if [ "$ret" = 0 ]; then
    
        [ -e "${DC_tlt}/slng_err" ] && mv "${DC_tlt}/slng_err" "${DC_tlt}/slng_err.bk"
        if [ "$review_chek" = TRUE ]; then
            cp -f "${DC_tlt}/0.cfg" "${DC_tlt}/translations/$active_trans.tra"
            echo "$active_trans" > "${DC_tlt}/translations/active"
        elif [ "$review_chek" = FALSE ]; then
            cleanups "${DC_tlt}/translations/$active_trans.tra"
        fi
        if [ "$review_trans" != "$active_trans" -a -n "$review_trans" -a "$review_trans" != "(null)" ]; then
            if [ -e "${DC_tlt}/translations/$review_trans.tra" ]; then
                yad_kill "yad --form --title="
                cp -f "${DC_tlt}/translations/$review_trans.tra" "${DC_tlt}/0.cfg"
                echo "$review_trans" > "${DC_tlt}/translations/active"
            fi
        elif [ -n "$autom_trans" -a "$autom_trans" != "(null)" ]; then
            yad_kill "yad --form --title="
            if grep "$autom_trans" <<< "$(cd "$DC_tlt/translations"; ls *.bk)"; then
                msg_2 "$(gettext "Exist a copy of this translation. Do you want to restore the copy instead of translating again?")" dialog-question "$(gettext "Restore")" "$(gettext "Translate Again")" " "
                if [ $? = 0 ]; then
                    mv -f "$DC_tlt/translations/$autom_trans.bk" "${DC_tlt}/0.cfg"
                    cleanups "$DT/translation" "$DT/transl_batch_lk" \
                    "$DT/translate_to" "${DC_tlt}/slng_err.bk"
                    echo "$autom_trans" > "${DC_tlt}/translations/active"
                    exit 1
                else
                    cleanups "$DC_tlt/translations/$autom_trans.bk"
                fi
            fi
            if grep "$autom_trans" <<< "$(cd "$DC_tlt/translations"; ls *.tra)"; then
                msg_2 "$(gettext "Exist a Verified translation for this language. Do you want to use this copy instead of translating again?")" dialog-question "$(gettext "Restore")" "$(gettext "Translate Again")" " "
                if [ $? = 0 ]; then
                    cp -f "$DC_tlt/translations/$autom_trans.tra" "${DC_tlt}/0.cfg"
                    echo "$autom_trans" > "${DC_tlt}/translations/active"
                    cleanups "$DT/translation" "$DT/transl_batch_lk" \
                    "$DT/translate_to" "${DC_tlt}/slng_err.bk"
                    exit 1
                fi
            fi
            > "$DT/words.trad_tmp"; > "$DT/index.trad_tmp"; > "$DT/translation"
            del='~~'
            internet
            if [ ! -e "${DC_tlt}/id.cfg" ]; then return 1; fi
            l="$(grep -o 'tlng="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
            if [ -n "$l" ]; then lgt=${tlangs[$l]}; else lgt=${tlangs[$tlng]}; fi
            tl=${slangs[$autom_trans]}
            include "$DS/ifs/mods/add"
            c1=$(cat "${DC_tlt}/0.cfg" |wc -l)
			
			pretrans() {
				while read -r item_; do
					item="$(sed 's/}/}\n/g' <<< "${item_}")"
					type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
					trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
					if [ -n "${trgt}" ]; then
						echo "${trgt}" \
						|python -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
						|sed 's/ /\n/g' |grep -v '^.$' |grep -v '^..$' \
						|tr -d '*)(,;"“”:' |tr -s '&{}[]' ' ' \
						|sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
						|sed 's/\]//;s/\[//;s/<[^>]*>//g' \
						|sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' \
						|tr -d '.' |sed 's/^ *//; s/ *$//; /^$/d' >> "$DT/words.trad_tmp"
						echo "|" >> "$DT/words.trad_tmp"
						echo "${trgt} ${del}" >> "$DT/index.trad_tmp"
					fi
				done < "${DC_tlt}/0.cfg"
           
				sed -i ':a;N;$!ba;s/\n/\. /g' "$DT/words.trad_tmp"
				sed -i 's/|/|\n/g' "$DT/words.trad_tmp"
				sed -i 's/^..//' "$DT/words.trad_tmp"
				index_to_trad="$(< "$DT/index.trad_tmp")"
				words_to_trad="$(< "$DT/words.trad_tmp")"
				translate "${index_to_trad}" "$lgt" "$tl" > "$DT/index.trad"
				translate "${words_to_trad}" "$lgt" "$tl" > "$DT/words.trad"
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
						msg "$(gettext "There was a problem with the translation.")\n" error
						fi
					fi
				fi
            fi
            if [ -z "$(< "$DT/index.trad")" -o -z "$(< "$DT/words.trad")" ]; then
                msg "$(gettext "A problem has occurred, try again later.")\n" 'error'
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
            done < "${DC_tlt}/0.cfg"
            unset item type trgt srce exmp defn note grmr mark link tag cdid
            if [ -n "$DT" ]; then rm -f "$DT"/*.tmp "$DT"/*.trad "$DT"/*.trad_tmp; fi

            if [ -e "$DT/translation" ]; then
                mv -f "${DC_tlt}/0.cfg" "${DC_tlt}/translations/$active_trans.bk"
                mv -f "$DT/translation" "${DC_tlt}/0.cfg"
                echo "$autom_trans" > "${DC_tlt}/translations/active"
            fi
        fi
        active_trans=$(sed -n 1p "${DC_tlt}/translations/active")
        if [[ "$active_trans" != "$slng" ]]; then
            touch "${DC_tlt}/slng_err"
        fi
    fi
    cleanups "$DT/translate_to" "${DC_tlt}/slng_err.bk"
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
    touch "${DM_tlt}"
    check_file "${DC_tlt}/1.cfg" "${DC_tlt}/6.cfg" "${DC_tlt}/9.cfg"
    if [[ $(egrep -cv '#|^$' < "${DC_tlt}/9.cfg") -ge 4 ]] \
    && [[ $(grep -oP '(?<=acheck=\").*(?=\")' "${DC_tlt}/10.cfg") = TRUE ]] \
    && [[ ${2} = 1 ]]; then chk=TRUE; else chk=FALSE; fi
    img1="$DS/images/1.png"
    img2="$DS/images/2.png"
    img3="$DS/images/3.png"
    img0="$DS/images/0.png"
    cfg0="${DC_tlt}/0.cfg"
    cfg1="${DC_tlt}/1.cfg"
    cfg5="${DC_tlt}/5.cfg"
    cfg6="${DC_tlt}/6.cfg"
    log3="$(cat "${DC_tlt}/practice"/log3)"
    log2="$(cat "${DC_tlt}/practice"/log2)"
    log1="$(cat "${DC_tlt}/practice"/log1)"
    export chk cfg0 cfg1 cfg5 cfg6 log1 \
    log2 log3 img0 img1 img2 img3
    python <<PY
import os, re
chk = os.environ['chk']
cfg0 = os.environ['cfg0']
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
items = [line.strip() for line in open(cfg0)]
cfg1 = [line.strip() for line in open(cfg1)]
marks = [line.strip() for line in open(cfg6)]
f = open(cfg5, "w")
for item in items:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    item = (fields[0].split('trgt{'))[1].split('}')[0]
    if item in cfg1:
        srce = (fields[1].split('srce{'))[1].split('}')[0]
        if item in marks:
            i="<b><big>"+item+"</big></b>"
        else:
            i=item
        if item in log3:
            f.write(img3+"\n"+i+"\nFALSE\n"+srce+"\n")
        elif item in log2:
            f.write(img2+"\n"+i+"\nFALSE\n"+srce+"\n")
        elif item in log1:
            f.write(img1+"\n"+i+"\n"+chk+"\n"+srce+"\n")
        else:
            f.write(img0+"\n"+i+"\nFALSE\n"+srce+"\n")
f.close()
PY
    rm -f "$DT/co_lk"
}

itray() {
	
    [ ! -e "$HOME/.config/idiomind/tpc" ] && \
    touch "$HOME/.config/idiomind/tpc"
    source "$DS/default/sets.cfg"
    lgt=${tlangs[$tlng]}
    ln -sf "$DS/images/flags/${lgt}.png" "$DT/icon"
    export lbl1="$(gettext "Add")"
    export lbl2="$(gettext "Play")"
    export lbl3="$(gettext "Stop playback")"
    export lbl4="$(gettext "Next")"
    export lbl5="$(gettext "Index")"
    export lbl9="$(gettext "Tasks")"
    export lbl8="$(gettext "Quit")"
    export dirt="$DT/"
	export lgt=${tlangs[$tlng]}
    python <<PY
import time, os, os.path, gtk, gio, signal, appindicator
lgt = os.environ['lgt']
HOME = os.getenv('HOME')
add = os.environ['lbl1']
play = os.environ['lbl2']
stop = os.environ['lbl3']
next = os.environ['lbl4']
topics = os.environ['lbl5']
tasks = os.environ['lbl9']
quit = os.environ['lbl8']
quit = os.environ['lbl8']
icon = os.environ['dirt']+'icon'
my_pid = os.getpid()
f_pid = open(os.environ['dirt']+'tray.pid', 'w')
f_pid.write(str(my_pid))
f_pid.close()
class IdiomindIndicator:
    def __init__(self):
        self.indicator = appindicator.Indicator(icon, icon, appindicator.CATEGORY_APPLICATION_STATUS)
        self.indicator.set_status(appindicator.STATUS_ACTIVE)
        self.cfg = os.getenv('HOME') + '/.config/idiomind/tpc'
        self.playlck = os.environ['dirt'] + 'playlck'
        self.tasks = os.environ['dirt'] + 'tasks'
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
    def change_topic(self):
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

        if os.path.exists(self.tasks):
            listMenu=gtk.Menu()
            listItems=gtk.MenuItem(tasks)
            listItems.set_submenu(listMenu)
            try:
                m = open(self.tasks).readlines()
            except:
                m = []
            for bm in m:
                label = bm.rstrip('\n')
                if not label:
                    label = ""
                item = self.create_menu_label(label)
                item.connect("activate", self.on_Task)
                listMenu.append(item)
            
            popup_menu.append(listItems)
            item.show()
            listItems.show()
        
        item = self.create_menu_label(topics)
        item.connect("activate", self.on_Topics_click)
        popup_menu.append(item)
        item = gtk.SeparatorMenuItem()
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
    def on_Quit_click(self, widget):
        os.system("/usr/share/idiomind/stop.sh 1 &")
        gtk.main_quit()
    def on_Topic_Changed(self, filemonitor, file, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self._on_menu_update()
    def on_Play_Changed(self, filemonitor, file2, other_file, event_type):
        if event_type == gio.FILE_MONITOR_EVENT_CHANGES_DONE_HINT:
            self._on_menu_update()
    def on_Tasks_Changed(self, filemonitor, file3, other_file, event_type):
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
    file3 = gio.File(i.tasks)
    monitor3 = file3.monitor_file()
    monitor3.connect("changed", i.on_Tasks_Changed)
    gtk.main()
PY

}

about() {
    export _descrip="$(gettext "Learning foreign vocabulary")"
    python << ABOUT
import gtk, os
app_logo = os.path.join('/usr/share/idiomind/images/logo.png')
app_icon = os.path.join('/usr/share/icons/hicolor/22x22/apps/idiomind.png')
app_name = 'Idiomind'
app_version = os.environ['_version']
app_website = os.environ['_website']
app_comments = os.environ['_descrip']
website_label = os.environ['_website']
app_copyright = 'Copyright (c) 2014-2017 Robin Palatnik'
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
app_authors = ['Robin Palatnik <robinpalat@users.sourceforge.net>\nMade with YAD https://sourceforge.net/projects/yad-dialog']
app_artists = ["chiru2017"]
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

clipw() {
		if [[ ! -e $DT/clipw ]]; then
            "$DS/ifs/clipw.sh" &
            sleep 1
            notify-send -i info "$(gettext "Information")" \
            "$(gettext "The clipboard watcher is enabled for 5 minutes...")" -t 5000
        else 
			"$DS/ifs/clipw.sh" 1
        fi

}>/dev/null 2>&1


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
    create_cfg)
    create_cfgfile ;;
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
    update_menu)
    menu_addons ;;
    _stats)
    stats_dlg ;;
    colorize)
    colorize "$@" ;;
    transl_batch)
    transl_batch ;;
    translate)
    translate_to "$@" ;;
    itray)
    itray ;;
    about)
    about ;;
    clipw)
    clipw "$@" ;;
esac
