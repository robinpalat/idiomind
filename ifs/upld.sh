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
    sleep 0.5
    msg "$(gettext "When the download completes the files will be added to topic directory.")" \
    dialog-information "$(gettext "Downloading")"
    kill -9 $(pgrep -f "yad --form --columns=1")
    mkdir "$DT/download"
    ilnk=$(grep -o 'ilnk="[^"]*' "$DM_tl/${2}/.conf/id.cfg" |grep -o '[^"]*$')
    tlng=$(grep -o 'tlng="[^"]*' "$DM_tl/${2}/.conf/id.cfg" |grep -o '[^"]*$')
    [ -z "${ilnk}" ] && err

    url1="http://idiomind.sourceforge.net/dl.php/?fl=${tlng,,}/${ilnk}"
    if wget -S --spider "${url1}" 2>&1 |grep 'HTTP/1.1 200 OK'; then 
    URL="${url1}"; else err & exit 1; fi
    
    wget -q -c -T 80 -O "$DT/download/${ilnk}.tar.gz" "${URL}"
    [ $? != 0 ] && err && exit 1
    
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
            done < "${DC_tlt}/3.cfg"
            rm -fr "${tmp}/share" "${tmp}/conf" "${tmp}/images"
            mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
            cleanups "$DM_t/$tlng/.share/audio/.mp3" "$DM_t/$tlng/.share/images/.jpg"
            echo -e "$total_lbl $total\n$audio_lbl $naud\n$image_lbl $nimg\n$trans_lbl $tran" > "${DC_tlt}/download"
            "$DS/ifs/tls.sh" colorize 0
            cleanups "$DT/download"
        else
            err & exit 1
        fi
    else
        err & exit 1
    fi
}

function upld() {
    if [ -d "$DT/upload" ]; then
        msg_4 "$(gettext "Please wait until the current actions are finished")" \
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
        msg_4 "$(gettext "Please wait until the current actions are finished")" \
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
        [ -d "$DT" ] && cd "$DT" || exit 1
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
        --align=right --center --on-top \
        --width=${sz[0]} --height=${sz[1]} --borders=15 \
        --field=" :LBL" "" \
        --field="$(gettext "Category"):CB" "" \
        --field="$(gettext "Skill Level"):CB" "" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t$(gettext "Password")" "$pass" \
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
        --width=${sz[0]} --height=${sz[1]} --borders=15 --field=" :LBL" "" \
        --field="$(gettext "Category"):CBE" "$_Categories" \
        --field="$(gettext "Skill Level"):CB" "$_levels" \
        --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
        --field="$(gettext "Author")" "$autr" \
        --field="\t\t$(gettext "Password")" "$pass" \
        --field=" ":LBL "" \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Upload")":0 \
        --button="$(gettext "Cancel")":4
    }

    dlg_dwld_content() {
        naud="$(grep -o 'naud="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        nimg="$(grep -o 'nimg="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        trad="$(grep -o 'slng="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        fsize="$(grep -o 'nsze="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Downloadable content available")</b>"
        info2="$(gettext "Audio files:") $naud\n$(gettext "Images:") $nimg\n$(gettext "Translations:") $trad\n$(gettext "Size:") $fsize"
        yad --form --columns=1 --title="$(gettext "Share")" \
        --name=Idiomind --class=Idiomind \
        --always-print-result \
        --window-icon=idiomind --buttons-layout=end \
        --align=left --center --on-top \
        --width=${sz[0]} --height=170 --borders=10 \
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
        --width=${sz[0]} --height=140 --borders=10 \
        --field="<b>$(gettext "Downloaded files"):</b>:lbl" " " \
        --field="$(< "${DC_tlt}/download"):lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "Export")":2 \
        --button="$(gettext "Cancel")":4
    }
    
    sv_data() {
        if [ $sv = TRUE ]; then
            if [ "${autr}" != "${autr_mod}" -o "${pass}" != "${pass_mod}" ]; then
                echo -e "autr=\"$autr_mod\"\npass=\"$pass_mod\"" > "$DC_s/3.cfg"
            fi
            if [ "${note}" != "${note_mod}"  ]; then
                if ! grep '^$' <<< "${note_mod}"; then 
                    echo -e "\n${note_mod}" > "${DC_tlt}/info.tmp"
                else 
                    echo "${note_mod}" > "${DC_tlt}/info.tmp"
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
    linkc="http://idiomind.net/${tlng,,}"
    linkac='http://idiomind.net/community/?q=user/register'
    ctgy="$(grep -o 'ctgy="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    text_upld="<span font_desc='Arial 12'>$(gettext "Share online with other $LANGUAGE_TO_LEARN learners!")</span>\n<a href='$linkc'>$(gettext "Topics shared")</a> Beta"
    _Categories="${ctgy}${list}"
    _levels="!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")"
    note=$(< "${DC_tlt}/info")
    autr="$(grep -o 'autr="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
    pass="$(grep -o 'pass="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"

    # dialogs
    if [[ -e "${DC_tlt}/download" ]]; then
        if [[ ! -s "${DC_tlt}/download" ]]; then
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
            msg_4 "$(gettext "Please wait until the current actions are finished").\n" \
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
        ( sleep 1; notify-send -i dialog-information "$(gettext "Upload in progress")" \
        "$(gettext "This can take a while...")" -t 6000 ) &
        mkdir -p "$DT/upload/files/conf"
        DT_u="$DT/upload/"
        orig="${tpc}"
        pre=$(sed "s/ /_/g;s/'//g" <<< "${orig:0:15}" |iconv -c -f utf8 -t ascii)
        export autr="${autr_mod}"
        export pass="${pass_mod}"
        export rand=$(md5sum "${DC_tlt}/0.cfg" |cut -d' ' -f1)
        ilnk="$(grep -o 'ilnk="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        if [ -z "$ilnk" ]; then ilnk="${pre,,}${rand:0:20}"; fi
        export ilnk
        export dtec="$(grep -o 'dtec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        export dtei="$(grep -o 'dtei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
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
        uniq < "${DC_tlt}/4.cfg" \
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
        done < "${DC_tlt}/0.cfg"

        cleanups "$DT_u/files/share/.mp3"
        
        ### copying translations
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
        
        cp "${DC_tlt}/6.cfg" "$DT_u/files/conf/6.cfg"
        
        ### Get text for info variable
        if [ -e "${DC_tlt}/info.tmp" ]; then
            mv "${DC_tlt}/info.tmp" "${DC_tlt}/info"
        fi
        cp "${DC_tlt}/info" "$DT_u/files/conf/info"
		sed -i 's|\"|\\"|g' "$DT_u/files/conf/info"
		sed -i ':a;N;$!ba;s/\n/<br><br>/g;s/\&/&amp;/g' "$DT_u/files/conf/info"
        export info="$(sed '/^$/d' "$DT_u/files/conf/info")"
		cleanups "$DT_u/files/conf/info"
		
        ### get data for html
        body="$(echo -e "$note_mod" |sed 's/\&/&amp;/g')"
        eval c="$(sed -n 4p "$DS/default/vars")"
        echo -e "${c}" > "${DC_tlt}/id.cfg"
        eval body="$(sed -n 5p "$DS/default/vars")"
        body="${body}<blockquote>$body</blockquote>"
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
        done < <(sed 's|"|\\"|g' < "${DC_tlt}/0.cfg")
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
    server = xmlrpclib.Server('http://idiomind.net/community/xmlrpc.php')
    nid = server.metaWeblog.newPost('blog', autr, pssw, 
    {'title': tpc, 'description': body}, True)
except:
    sys.exit(3)
url = requests.get('http://idiomind.sourceforge.net/uploads.php').url
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
