#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source $DS/default/sets.cfg
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
sz=(450 450); [[ ${swind} = TRUE ]] && sz=(410 410)

function dwld() {
    err() {
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" \
        dialog-information
        cleanups "$DT/download"
    }
    (sleep 0.5 && notify-send -i 'dialog-information' "$(gettext "Downloading")" \
    "$(gettext "When the download completes, the files will be added to topic directory...")" -t 8000) &
    
    kill -9 $(pgrep -f "yad --form --columns=2")
    
    mkdir "$DT/download"
    ilnk=$(tpc_db 1 id ilnk)
    tlng=$(tpc_db 1 id tlng)
    [ -z "${ilnk}" ] && err
    url1="http://idiomind.sourceforge.io/download.php/?fl=${tlng,,}/${ilnk}"
    if wget -S --spider "${url1}" 2>&1 |grep 'HTTP/1.1 200 OK'; then 
    URL="${url1}"; else err & exit 1; fi
    
    wget -q -c -T 80 -O "$DT/download/${ilnk}.tar.gz" "${URL}"
    if [ $? != 0 ]; then err & exit 1; fi
    
    if [ -f "$DT/download/${ilnk}.tar.gz" ]; then
        cd "$DT/download"/
        tar xvf "$DT/download/${ilnk}.tar.gz"

        if [ -d "$DT/download/files" ]; then
            total_lbl="$(gettext "Total")"
            audio_lbl="$(gettext "Audio files")"
            image_lbl="$(gettext "Images")"
            trans_lbl="$(gettext "Translations")"
            tmp="$DT/download/files"
            total=$(find "${tmp}" -maxdepth 5 -type f |wc -l)
            naud=$(find "${tmp}" -maxdepth 5 -name '*.mp3' |wc -l)
            nimg=$(find "${tmp}" -maxdepth 5 -name '*.jpg' |wc -l)
            tran=$(find "${tmp}" -maxdepth 5 -name '*.tra' |wc -l)

            check_dir "$DM_t/$tlng/.share/images" "$DM_t/$tlng/.share/audio"
            mv -n "${tmp}/share"/*.mp3 "$DM_t/$tlng/.share/audio"/
            while read -r img; do
                if [ -e "${tmp}/images/${img,,}.jpg" ]; then
                    if [ -e "$DM_t/$tlng/.share/images/${img,,}-0.jpg" \
                    -o $(wc -w <<< "${img}") -gt 1 ]; then
                        img_path="${DM_tlt}/images/${img,,}.jpg"
                    else 
                        img_path="${DM_tls}/images/${img,,}-0.jpg"
                    fi
                    mv -f "${tmp}/images/${img,,}.jpg" "${img_path}"
                fi
            done < <(tpc_db 5 words)
            
            [ -f "${tmp}/note" ] && cat "${tmp}/note" >> "${DC_tlt}/note"
            [ -f "${tmp}/conf/info" ] && cat "${tmp}/conf/info" >> "${DC_tlt}/note"
            rm -fr "${tmp}/share" "${tmp}/images" "${tmp}/note"
            mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
            cleanups "$DM_t/$tlng/.share/audio/.mp3" \
            "$DM_t/$tlng/.share/images/.jpg" \
            "$DT/download" "${DC_tlt}/download" 

            "$DS/ifs/tls.sh" colorize 0
        else
            err & exit 1
        fi
    else
        err & exit 1
    fi
}

function upld() {
    if [ -d "$DT/upload" ]; then
        msg_4 "$(gettext "Please wait until the current process is finished.")" \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Uploading")" "$DT/upload"
        ret=$?
        if [ $ret -eq 1 ]; then
            cleanups "$DT/upload"; "$DS/stop.sh" 5
        else
            exit 1
        fi
    fi
    if [ -d "$DT/download" ]; then
        msg_4 "$(gettext "Please wait until the current process is finished.")" \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Downloading")" "$DT/download"
        ret=$?
        if [ $ret -eq 1 ]; then
            cleanups "$DT/download"; "$DS/stop.sh" 5
        else
            exit 1
        fi
    fi
    
    conds_upload() {
        if [ $((cfg3+cfg4)) -lt 8 ]; then
            msg "$(gettext "Insufficient number of items")." \
            dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${autr_mod}" -o -z "${pass_mod}" ]; then
            msg "$(gettext "Sorry, Authentication failed.")\n" \
            dialog-information "$(gettext "Information")" & exit 1
        fi
        if [ -z "${ctgy}" ]; then
            msg "$(gettext "Please select a category.")\n " \
            dialog-information
            "$DS/ifs/upld.sh" upld "${tpc}" & exit 1
        fi
        if [ -d "$DT" ]; then cd "$DT"; else exit 1; fi
        [ -d "$DT/upload" ] && rm -fr "$DT/upload"
        
        if [ "${tpc}" != "${1}" ]; then
            msg "$(gettext "Sorry, this topic is currently not active.")" \
            dialog-information & exit 1
        fi
        internet
    }

    dlg_getuser() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=right --center \
        --width=${sz[0]} --height=${sz[1]} --borders=18 \
        --field=" :LBL" "" \
        --field="$(gettext "Category"):CB" "" \
        --field="$(gettext "Skill Level"):CB" "" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t\t\t\t\t$(gettext "Password")" "$pass" \
        --field="<a href='$linkac'>$(gettext "Get account")</a> \n":LBL \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    }
    
    dlg_upload() {
        yad --form --title="$(gettext "Share")" \
        --text="$text_upld" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind  \
        --align=right --center \
        --width=${sz[0]} --height=${sz[1]} --borders=18 --field=" :LBL" "" \
        --field="$(gettext "Category"):CBE" "$_Categories" \
        --field="$(gettext "Skill Level"):CB" "$_levels" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t\t\t\t\t$(gettext "Password")" "$pass" \
        --field=" ":LBL "" \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Upload")":0 \
        --button="$(gettext "Close")":4
    }

    dlg_dwld_content() {
        naud="$(tpc_db 1 id naud)"
        nimg="$(tpc_db 1 id nimg)"
        trad="$(tpc_db 1 id slng)"
        fsize="$(tpc_db 1 id nsze)"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Downloadable content available")</b>"
        info2="\n<small>$(gettext "Audio files:") $naud\n$(gettext "Images:") $nimg\n$(gettext "Translations:") $trad\n$(gettext "Size:") $fsize</small>"
        yad --form --columns=2 --title="$(gettext "Share")" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind  \
        --align=left --center \
        --width=350 --height=240 --borders=10 \
        --text="$info" \
        --field="$info2:lbl" " " \
        --field="$(gettext "Download"):fbtn" "${cmd_dwl}" \
        --field="\t\t\t\t\t:lbl" " " \
        --field="\t\t\t\t\t:lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    } 
    
    dlg_export() {
        fsize="$(tpc_db 1 id nsze)"
        yad --form --title="$(gettext "Share")" \
        --separator="|" \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind \
        --align=left --center \
        --width=350 --height=240 --borders=10 \
        --field="<b>$(gettext "Downloaded files")</b>:lbl" " " \
        --field="\n$(gettext "Size:") ${fsize}":lbl " " \
        --field="\t\t\t\t\t\t\t:lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Close")":4
    }
    
    sv_data() {
        if [ $sv = TRUE ]; then
            if [ "${autr}" != "${autr_mod}" -o "${pass}" != "${pass_mod}" ]; then
                cdb ${cfgdb} 3 user autr "${autr_mod}"
                cdb ${cfgdb} 3 user pass "${pass_mod}"
            fi
            if [ "${note}" != "${note_mod}"  ]; then
                if ! grep '^$' <<< "${note_mod}"; then 
                    echo -e "\n${note_mod}" > "${DC_tlt}/note.tmp"
                else 
                    echo "${note_mod}" > "${DC_tlt}/note.tmp"
                fi
            fi
        fi
    }
    
    em='!'; unset list
    for val in "${Categories[@]}"; do
        declare clocal="$(gettext "${val}")"
        list="${list}${em}${clocal}"
    done
    LANGUAGE_TO_LEARN="${tlng^}"
    linkc="https://idiomind.sourceforge.io/links/${tlng,,}"
    linkac='https://idiomind.sourceforge.io/community/?q=user/register'
    ctgy=$(tpc_db 1 id ctgy)
    levl=$(tpc_db 1 id levl)
    text_upld="<span font_desc='Arial 12'><b>$(gettext "Share what you learn with others!")</b></span>\n$(gettext "Visit the ") <a href='$linkc'>$(gettext "Topics library")</a>"
    _Categories="${ctgy}${list}"
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    _levels="!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")"
    if [ -n "$levl" ]; then 
        level="${lv[${levl}]}"
        _levels="$level"$(sed "s/\!$level//g" <<< "$_levels")""
    fi
    note=$(< "${DC_tlt}/note")
    autr=$(cdb ${cfgdb} 1 user autr) 
    pass=$(cdb ${cfgdb} 1 user pass)

    # dialogs
    if [[ -n "$(tpc_db 1 id naud)" ]]; then
        if [[ -e "${DC_tlt}/download" ]]; then
            dlg="$(dlg_dwld_content)"
            ret=$?
        else
            dlg="$(dlg_export)"
            ret=$?
        fi
        export sv=FALSE
    else
        shopt -s extglob
        if [ -z "${autr##+([[:space:]])}" -o -z "${pass##+([[:space:]])}" ]; then
            dlg="$(dlg_getuser)"
            ret=$?
        elif [ -n "${autr}" -o -n "${pass}" ]; then
            dlg="$(dlg_upload)"
            ret=$?
        fi
        dlg="$(grep -oP '(?<=|).*(?=\|)' <<< "$dlg")"
        ctgy=$(echo "${dlg}" |cut -d "|" -f2)
        levl=$(echo "${dlg}" |cut -d "|" -f3)
        note_mod=$(echo "${dlg}" |cut -d "|" -f4)
        autr_mod=$(echo "${dlg}" |cut -d "|" -f5)
        pass_mod=$(echo "${dlg}" |cut -d "|" -f6)
        # get data
        for val in "${Categories[@],}"; do
            [ "${ctgy^}" = "$(gettext "${val^}")" ] && export ctgy="${val// /_}"
        done
        [ "$levl" = $(gettext "Beginner") ] && levl=0
        [ "$levl" = $(gettext "Intermediate") ] && levl=1
        [ "$levl" = $(gettext "Advanced") ] && levl=2
        export sv=TRUE
    fi
    
    if [ $ret = 1 -o $ret = 4 ]; then
        sv_data
        
    elif [ $ret = 2 ]; then
        sv_data
        if [ -d "$DT/export" ]; then
            msg_4 "$(gettext "Please wait until the current process is finished.")\n" \
            "face-worried" "$(gettext "Cancel")" "$(gettext "Stop")" \
            "$(gettext "Wait")" "$DT/export"
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
        ( sleep 1; notify-send -i 'dialog-information' "$(gettext "Uploading")" \
        "$(gettext "Please wait, it may take a while")" -t 6000 ) &
        mkdir -p "$DT/upload/files"
        DT_u="$DT/upload/"
        orig="${tpc}"
        pre=$(sed "s/ /_/g;s/'//g" <<< "${orig:0:15}" |iconv -c -f utf8 -t ascii)
        export autr="${autr_mod}"
        export pass="${pass_mod}"
        export rand=$(md5sum "${DC_tlt}/data" |cut -d' ' -f1)
        ilnk=$(tpc_db 1 id ilnk)
        if [ -z "$ilnk" ]; then ilnk="${pre,,}${rand:0:20}"; fi
        export ilnk
        export dtec=$(tpc_db 1 id dtec)
        export dtei=$(tpc_db 1 id dtei)
        export dteu=$(date +%F)
        export nwrd=${cfg3}
        export nsnt=${cfg4}
        export orig levl
        export stts=0
        ### copying files
        cd "${DM_tlt}"/
        cp -r ./* "$DT_u/files/"
        cleanups "$DT_u/files/.mp3"
        mkdir "$DT_u/files/share"
        [ ! -d "$DT_u/files/images" ] && mkdir "$DT_u/files/images"
        ###  copying audio words
        sents="$(tpc_db 5 sentences)"
        uniq <<< "${sents}" \
        |sed 's/\n/ /; s/ /\n/g' \
        |grep -v '^.$' |grep -v '^..$' \
        |sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//g' \
        |sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /g' \
        |tr -d ')' |tr -d '(' |tr '[:upper:]' '[:lower:]' |while read -r audio; do
            if [ -f "$DM_tl/.share/audio/$audio.mp3" -a -n "$audio" ]; then
                cp -f "$DM_tl/.share/audio/$audio.mp3" \
                "$DT_u/files/share/$audio.mp3"
            fi
        done
        while read -r _item; do
            unset trgt cdid
            get_item "${_item}"
            if [ $type = 1 -a -n "$trgt" -a -n "$cdid" ]; then
                if [ -f "$DT_u/files/$cdid.mp3" ]; then :
                elif [ -f "$DM_tl/.share/audio/${trgt,,}.mp3" ]; then
                    cp -f "$DM_tl/.share/audio/${trgt,,}.mp3" \
                    "$DT_u/files/share/${trgt,,}.mp3"
                fi
            fi
        done < "${DC_tlt}/data"
        cleanups "$DT_u/files/share/.mp3"
        ### translations
        if [ -d "$DC_tlt/translations" ]; then
            act="$(< "$DC_tlt/translations/active")"
            if [ -z "$act" ] && grep -Fo "${act}" <<< "${!slangs[@]}" >/dev/null 2>&1; then
                a="$act"
            else
                a="$slng"
            fi
            if [ $(cd "$DC_tlt/translations"; ls *.tra |wc -l) -gt 1 ]; then
                slng="$(for t in "$(cd "$DC_tlt/translations"
                ls *.tra |sed 's/\.tra//g' |grep -v "$a")"; do
                [ -n "$t" ] && echo "$t"; done |sed ':a;N;$!ba;s/\n/, /g')"
                slng="${a}, ${slng}"
            else
                slng="${a}"
            fi
            cp -r "$DC_tlt/translations" "$DT_u/files/translations"
        fi
        export slng
        export naud=$(find "$DT_u/files" -maxdepth 5 -name '*.mp3' |wc -l)
        ###
        if [ -e "${DC_tlt}/note.tmp" ]; then
            mv "${DC_tlt}/note.tmp" "${DC_tlt}/note"
        fi
        cp "${DC_tlt}/note" "$DT_u/files/note"
        export info="$(cat "$DT_u/files/note" |sed '/^$/d' \
        |sed ':a;N;$!ba;s/\n/<br><br>/g;s/\&/&amp;/g' \
        |sed 's|\"|\\"|g;s|\/|\\/|g')"
        tpc_db 9 id autr "$autr"
        tpc_db 9 id ctgy "$ctgy"
        tpc_db 9 id ilnk "$ilnk"
        tpc_db 9 id orig "$orig"
        tpc_db 9 id dteu "$(date +%F)"
        tpc_db 9 id levl "$levl"
        
        ### get data for html
        htmlnote="$(sed '/^$/d' "$DT_u/files/note" \
        |sed ':a;N;$!ba;s/\n/<br><br>/g;s/\&/&amp;/g')"
        eval body="$(sed -n 5p "$DS/default/vars")"
        body="${body}<blockquote>$htmlnote</blockquote>"
        export tpc DT_u body
        
        ###  convert to json format and copy images
        idmnd="$DT_u/${orig}.idmnd"
        echo -e "{\"items\":{" > "${idmnd}"
        while read -r _item; do
            get_item "${_item}"
             if [ -n "$trgt" ] && [ "$type" = 1 ]; then
                if [ -e "$DM_tlt/images/${trgt,,}.jpg" ]; then
                    ipath="$DM_tlt/images/${trgt,,}.jpg"; export imag=2
                elif [ -e "$DM_tls/images/${trgt,,}-1.jpg" ]; then
                    ipath="$DM_tls/images/${trgt,,}-1.jpg"; export imag=1
                fi
                if [ -e "${ipath}" ]; then
                    cp -f "${ipath}" "$DT_u/files/images/${trgt,,}-${imag}.jpg"
                fi
             else
                export imag=0
            fi
            eval item="$(sed -n 1p "$DS/default/vars")"
            [ -n "${trgt}" ] && echo -en "${item}" >> "${idmnd}"
        done < <(sed 's|"|\\"|g' < "${DC_tlt}/data")
        export nimg=$(cd "$DT_u/files/images"/; ls *.jpg |wc -l)
        
        ### set head info
        sed -i 's/,$//' "${idmnd}"
        echo "}," >> "${idmnd}"
        cd "$DT_u"; export nsze=$(du -sh ./* |sort -hr |head -n1 |cut -f1)
        eval head="$(sed -n 3p "$DS/default/vars")"
        echo -e "${head}}" >> "${idmnd}"
        
        ### split tar.gz
        find "$DT_u"/ -type f -exec chmod 644 {} \;
        tar czpvf - ./"files" |split -d -b 2500k - ./"${ilnk}.tar.gz"
        rm -fr ./"files"

        python << END
import os, sys, requests, time, xmlrpclib
reload(sys)
sys.setdefaultencoding("utf-8")
autr = os.environ['autr']
pssw = os.environ['pass']
tpc = os.environ['tpc']
body = os.environ['body']
try:
    # http://idiomind.net/community/xmlrpc.php
    server = xmlrpclib.Server('http://idiomind.sourceforge.io/community/xmlrpc.php')
    nid = server.metaWeblog.newPost('blog', autr, pssw, 
    {'title': tpc, 'description': body}, True)
except:
    sys.exit(3)
url = requests.get('http://idiomind.sourceforge.net/upload.php').url
DT_u = os.environ['DT_u']
volumes = [i for i in os.listdir(DT_u)]
for f in volumes:
    fl = {'file': open(DT_u + f, 'rb')}
    print f
    r = requests.post(url, files=fl)
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
            sleep 2
            info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
            image='error'
        fi
        msg "${info}" $image

        cleanups "${DT_u}"
        return 0
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
    --width=650 --height=480 --borders=8 --splitter=370 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}

_export() {
    dlg="$(fdlg)"; ret=$?
    if [ $ret -eq 0 ]; then
        "$DS/ifs/mods/export/$(head -n 1 <<< "$dlg").sh" \
        "$(tail -n 1 <<< "$dlg")" "${tpc}" & return 0
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
