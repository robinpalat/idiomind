#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source $DS/default/sets.cfg
lgt=${lang[$lgtl]}
lgs=${slang[$lgsl]}

function dwld() {
    err() {
        cleanups "$DT/download" &
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" dialog-information
    }
    sleep 0.5
    msg "$(gettext "When the download completes the files will be added to topic directory.")" dialog-information "$(gettext "Downloading")"
    kill -9 $(pgrep -f "yad --form --columns=1")
    mkdir "$DT/download"; idcfg="$DM_tl/${2}/.conf/id.cfg"
    ilink=$(grep -o 'ilink="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    langt=$(grep -o 'langt="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    [ -z "${ilink}" ] &&  err

    url1="http://idiomind.sourceforge.net/dl.php/?lg=${langt,,}&fl=${ilink}"
    if wget -S --spider "${url1}" 2>&1 |grep 'HTTP/1.1 200 OK'; then
        URL="${url1}"
    else err & exit
    fi
    wget -q -c -T 80 -O "$DT/download/${ilink}.tar.gz" "${URL}"
    [ $? != 0 ] && err && exit 1
    
    if [ -f "$DT/download/${ilink}.tar.gz" ]; then
        cd "$DT/download"/
        tar -xzvf "$DT/download/${ilink}.tar.gz"
        
        if [ -d "$DT/download/files" ]; then
            ltotal="$(gettext "Total")"
            laudio="$(gettext "Audio files")"
            limage="$(gettext "Images")"
            lothers="$(gettext "Others")"
            tmp="$DT/download/files"
            total=$(find "${tmp}" -maxdepth 5 -type f |wc -l)
            c_audio=$(find "${tmp}" -maxdepth 5 -name '*.mp3' |wc -l)
            c_images=$(find "${tmp}" -maxdepth 5 -name '*.jpg' |wc -l)
            hfiles="$(cd "${tmp}"; ls -d ./.[^.]* |less |wc -l)"
            exfiles="$(find "${tmp}" -maxdepth 5 -perm -111 -type f |wc -l)"
            others=$((hfiles+exfiles))
            mv -f "${tmp}/conf/info" "${DC_tlt}/info"
            check_dir "$DM_t/$langt/.share/images" "$DM_t/$langt/.share/audio"
            mv -n "${tmp}/share"/*.mp3 "$DM_t/$langt/.share/audio"/
            while read -r img; do
                if [ -e "${tmp}/images/${img,,}.jpg" ]; then
                    if [ -e "$DM_t/$langt/.share/images/${img,,}-0.jpg" -o `wc -w <<<"${img}"` -gt 1 ]; then
                        img_path="${DM_tlt}/images/${img,,}.jpg"
                    else 
                        img_path="${DM_tls}/images/${img,,}-0.jpg"
                    fi
                    mv -f "${tmp}/images/${img,,}.jpg" "${img_path}"
                fi
            done < "${DC_tlt}/3.cfg"
            rm -fr "${tmp}/share" "${tmp}/conf" "${tmp}/images"
            mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
            echo "${tpc}" >> "$DM_tl/.share/3.cfg"
            echo -e "$ltotal $total\n$laudio $c_audio\n$limage $c_images\n$lothers $others" > "${DC_tlt}/download"
            "$DS/ifs/tls.sh" colorize 0
            rm -fr "$DT/download"
        else
            err & exit
        fi
    else
        err & exit
    fi
    exit
}

function upld() {
    if [ -d "$DT/upload" -o -d "$DT/download" ]; then
        [ -e "$DT/download" ] && t="$(gettext "Downloading")..." || t="$(gettext "Uploading")..."
        msg_2 "$(gettext "Wait until it finishes a previous process")\n" dialog-warning OK "$(gettext "Stop")" "$t"
        ret="$?"
        if [ $ret -eq 1 ]; then
            cleanups "$DT/upload" "$DT/download"
            "$DS/stop.sh" 5
        fi
        exit 1
    fi
    
    conds_upload() {
        if [ $((inx3+inx4)) -lt 8 ]; then
            msg "$(gettext "Insufficient number of items to perform the action").\t\n " \
            dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${usrid}" -o -z "${passw}" ]; then
            msg "$(gettext "Sorry, Authentication failed.")\n" dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${ctgry}" ]; then
            msg "$(gettext "Please select a category.")\n " dialog-information
            "$DS/ifs/upld.sh" upld "${tpc}" & exit 1
        fi
        [ -d "$DT" ] && cd "$DT" || exit 1
        [ -d "$DT/upload" ] && rm -fr "$DT/upload"
        
        if [ "${tpc}" != "${1}" ]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n " dialog-information & exit 1
        fi
        internet
    }

    dlg_getuser() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=right --center --on-top \
        --width=490 --height=470 --borders=12 \
        --field=" :LBL" "" \
        --field="$(gettext "Category"):CB" "" \
        --field="$(gettext "Skill Level"):CB" "" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$usrid" \
        --field="\t\t$(gettext "Password")" "$passw" \
        --field="<a href='$linkac'>$(gettext "Get account to share")</a> \n":LBL \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    }
    
    dlg_upload() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=right --center --on-top \
        --width=490 --height=470 --borders=12 --field=" :LBL" "" \
        --field="$(gettext "Category"):CBE" "$_Categories" \
        --field="$(gettext "Skill Level"):CB" "$_levels" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$usrid" \
        --field="\t\t$(gettext "Password")" "$passw" \
        --field=" ":LBL "" \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Upload")":0 \
        --button="$(gettext "Cancel")":4
    }

    dlg_dwld_content() {
        c_audio="$(grep -o 'naudi="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        c_images="$(grep -o 'nimag="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        fsize="$(grep -o 'nsize="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Downloadable content available")</b>"
        info2="$(gettext "Audio files:") $c_audio\n$(gettext "Images:") $c_images\n$(gettext "Size:") $fsize"
        yad --form --columns=1 --title="$(gettext "Share")" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --image="dialog-information" \
        --window-icon=idiomind --buttons-layout=end \
        --align=left --center --on-top \
        --width=480 --height=180 --borders=10 \
        --text="$info" \
        --field="$info2:lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Download")":"${cmd_dwl}" \
        --button="$(gettext "Cancel")":4
    } 
    
    dlg_export() {
        yad --form --title="$(gettext "Share")" \
        --separator="|" \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind --buttons-layout=end \
        --align=left --center --on-top \
        --width=480 --height=180 --borders=10 \
        --field="<b>$(gettext "Downloaded files")</b>:lbl" " " \
        --field="$(< "${DC_tlt}/download"):lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Cancel")":4
    }
    
    sv_data() {
        if [ "${usrid}" != "${usrid_m}" -o "${passw}" != "${passw_m}" ]; then
            echo -e "usrid=\"$usrid_m\"\npassw=\"$passw_m\"" > "$DC_s/3.cfg"
        fi
        if [ "${note}" != "${notes_m}"  ]; then
            echo -e "\n${notes_m}" > "${DC_tlt}/info"
        fi
    }
    
    emrk='!'
    for val in "${Categories[@]}"; do
        declare clocal="$(gettext "${val}")"
        list="${list}${emrk}${clocal}"
    done
    
    LANGUAGE_TO_LEARN="${lgtl}"
    linkc="http://idiomind.net/${lgtl,,}"
    linkac='http://idiomind.net/community/?q=user/register'
    ctgry="$(grep -o 'ctgry="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    text_upld="<span font_desc='Arial 12'>$(gettext "Share online with other ${LANGUAGE_TO_LEARN} learners!")</span>\n<a href='$linkc'>$(gettext "Topics shared")</a> Beta\n"
    _Categories="${ctgry}${list}"
    _levels="!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")"
    note=$(< "${DC_tlt}/info")
    usrid="$(grep -o 'usrid="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
    passw="$(grep -o 'passw="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"

    # dialogs
    if [[ -e "${DC_tlt}/download" ]]; then
        if [[ ! -s "${DC_tlt}/download" ]]; then
            dlg="$(dlg_dwld_content)"
            ret=$?
        else
            dlg="$(dlg_export)"
            ret=$?
        fi
    else
        shopt -s extglob
        if [ -z "${usrid##+([[:space:]])}" -o -z "${passw##+([[:space:]])}" ]; then
            dlg="$(dlg_getuser)"
            ret=$?
        elif [ -n "${usrid}" -o -n "${passw}" ]; then
            dlg="$(dlg_upload)"
            ret=$?
            
        fi
        dlg="$(grep -oP '(?<=|).*(?=\|)' <<<"$dlg")"
        ctgry=$(echo "${dlg}" |cut -d "|" -f2)
        level=$(echo "${dlg}" |cut -d "|" -f3)
        notes_m=$(echo "${dlg}" |cut -d "|" -f4)
        usrid_m=$(echo "${dlg}" |cut -d "|" -f5)
        passw_m=$(echo "${dlg}" |cut -d "|" -f6)
        # get data
        for val in "${Categories[@],}"; do
            [ "${ctgry^}" = "$(gettext "${val^}")" ] && export ctgry="${val// /_}"
        done
        [ "$level" = $(gettext "Beginner") ] && level=0
        [ "$level" = $(gettext "Intermediate") ] && level=1
        [ "$level" = $(gettext "Advanced") ] && level=2
    fi
    
    if [ $ret = 1 -o $ret = 4 ]; then
        sv_data
    elif [ $ret = 2 ]; then
        sv_data
        if [ -d "$DT/export" ]; then
            msg_2 "$(gettext "Wait until it finishes a previous process").\n" dialog-information OK "$(gettext "Stop")" "$(gettext "Information")"
            ret=$?
            if [ $ret -eq 1 ]; then
                [ -d "$DT/export" ] && rm -fr "$DT/export"
            fi
            exit 1
        else
            "$DS/ifs/upld.sh" _export "${tpc}" & exit 1
        fi
    elif [ $ret = 0 ]; then
        sv_data
        conds_upload "${2}"
        "$DS/ifs/tls.sh" check_index "${tpc}" 1
        ( sleep 1; notify-send -i dialog-information "$(gettext "Upload in progress")" \
        "$(gettext "This can take a while...")" -t 6000 ) &
        mkdir -p "$DT/upload/files/conf"
        DT_u="$DT/upload/"
        oname="$(grep -o 'oname="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        [ -z "${oname}" ] && oname="${tpc}"
        pre=$(sed "s/ /_/g;s/'//g" <<< "${oname:0:15}" |iconv -c -f utf8 -t ascii)
        export sum=$(md5sum "${DC_tlt}/0.cfg" |cut -d' ' -f1)
        export ilink="${pre,,}${sum:0:20}"
        export datec="$(grep -o 'datec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        export datei="$(grep -o 'datei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        export dateu=$(date +%F)
        tpcid=$(strings /dev/urandom |tr -cd '[:alnum:]' |fold -w 3 |head -n 1)
        export c_words=${inx3}
        export c_sntncs=${inx4}
        export oname level
        
        # copying files
        cd "${DM_tlt}"/
        cp -r ./* "$DT_u/files/"
        mkdir "$DT_u/files/share"
        [ ! -d "$DT_u/files/images" ] && mkdir "$DT_u/files/images"

        auds="$(uniq < "${DC_tlt}/4.cfg" \
        | sed 's/\n/ /g' | sed 's/ /\n/g' \
        | grep -v '^.$' | grep -v '^..$' \
        | sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//'g \
        |  sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /'g \
        | tr -d ')' | tr -d '(' | tr '[:upper:]' '[:lower:]')"
        while read -r audio; do
            if [ -f "$DM_tl/.share/audio/$audio.mp3" ]; then
                cp -f "$DM_tl/.share/audio/$audio.mp3" \
                "$DT_u/files/share/$audio.mp3"
            fi
        done <<<"$auds"
        while read -r audio; do
            if [ -f "$DM_tl/.share/audio/${audio,,}.mp3" ]; then
                cp -f "$DM_tl/.share/audio/${audio,,}.mp3" \
                "$DT_u/files/share/${audio,,}.mp3"
            fi
        done < "${DC_tlt}/3.cfg"
        while read -r img; do
            if [ -e "$DM_tlt/images/${img,,}.jpg" ]; then
                img_path="$DM_tlt/images/${img,,}.jpg"
            elif [ -e "$DM_tls/images/${img,,}-0.jpg" ]; then
                img_path="$DM_tls/images/${img,,}-0.jpg"
            fi
            if [ -e "${img_path}" ]; then
                cp -f "${img_path}" "$DT_u/files/images/${img,,}.jpg"
            fi
        done < "${DC_tlt}/3.cfg"
        export c_audio=$(find "$DT_u/files" -maxdepth 5 -name '*.mp3' |wc -l)
        export c_images=$(cd "$DT_u/files/images"/; ls *.jpg |wc -l)
        cp "${DC_tlt}/6.cfg" "$DT_u/files/conf/6.cfg"
        cp "${DC_tlt}/info" "$DT_u/files/conf/info"

        # create tar
        cd "$DT/upload"/
        find "$DT_u"/ -type f -exec chmod 644 {} \;
        tar czpvf - ./"files" |split -d -b 2500k - ./"${ilink}"
        rm -fr ./"files"; rename 's/(.*)/$1.tar.gz/' *
        
        # create id
        export f_size=$(du -h . |cut -f1)
        eval c="$(< "$DS/default/topic.cfg")"
        echo -n "${c}" > "${DC_tlt}/id.cfg"
        cp -f "${DC_tlt}/0.cfg" "$DT_u/$tpcid.${tpc}.$lgt"
        tr '\n' '&' < "${DC_tlt}/id.cfg" >> "$DT_u/$tpcid.${tpc}.$lgt"
        echo -n "&idiomind-`idiomind -v`" >> "$DT_u/$tpcid.${tpc}.$lgt"
        echo -en "\nidiomind-`idiomind -v`" >> "${DC_tlt}/id.cfg"
        direc="$DT_u"
        body="<hr><br><a href='/${lgtl,}/${ctgry,}/$tpcid.$oname.idmnd'>Download</a>"
        export tpc direc usrid_m passw_m body

        python << END
import os, sys, requests, time, xmlrpclib
reload(sys)
sys.setdefaultencoding("utf-8")
usrid = os.environ['usrid_m']
passw = os.environ['passw_m']
tpc = os.environ['tpc']
body = os.environ['body']
try:
    server = xmlrpclib.Server('http://idiomind.net/community/xmlrpc.php')
    nid = server.metaWeblog.newPost('blog', usrid, passw, 
    {'title': tpc, 'description': body}, True)
except:
    sys.exit(3)
url = requests.get('http://idiomind.sourceforge.net/uploads.php').url
direc = os.environ['direc']
volumes = [i for i in os.listdir(direc)]
for f in volumes:
    file = {'file': open(f, 'rb')}
    r = requests.post(url, files=file)
    time.sleep(5)
END
        u=$?
        if [ $u = 0 ]; then
            info="\"$tpc\"\n<b>$(gettext "Uploaded correctly")</b>\n"
            image='dialog-ok-apply'
        elif [ $u = 3 ]; then
            info="$(gettext "Authentication error.")\n"
            image='error'
        else
            sleep 5
            info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
            image='error'
        fi
        msg "$info" $image

        cleanups "${DT_u}"
        exit 0
    fi
    
} >/dev/null 2>&1

fdlg() {
    tpcs="$(cd "$DS/ifs/mods/export"; ls \
    |sed 's/\.sh//g'|tr "\\n" '!' |sed 's/\!*$//g')"
    key=$((RANDOM%100000)); cd "$HOME"
    yad --file --save --filename="$HOME/$tpc" --tabnum=1 --plug="$key" &
    yad --form --tabnum=2 --plug="$key" \
    --separator="" --align=right \
    --field="\t\t\t\t$(gettext "Export to"):CB" "$tpcs" &
    yad --paned --key="$key" --title="$(gettext "Export")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind --center --on-top \
    --width=600 --height=500 --borders=8 --splitter=370 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}

_export() {
    dlg="$(fdlg)"
    ret=$?
    if [ $ret -eq 0 ]; then
        "$DS/ifs/mods/export/$(head -n 1 <<<"$dlg").sh" \
        "$(tail -n 1 <<<"$dlg")" "${tpc}" & exit 0
    fi
} >/dev/null 2>&1

case "$1" in
    vsd)
    vsd "$@" ;;
    infsd)
    infsd "$@" ;;
    dwld)
    dwld "$@" ;;
    upld)
    upld "$@" ;;
    _export)
    _export "$@" ;;
    share)
    download "$@" ;;
esac
