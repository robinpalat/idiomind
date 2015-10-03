#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)
_cfg() {  b=$(tr -dc a-z < /dev/urandom |head -c 1)
c=$((RANDOM%100))
id="$b$c"
id=${id:0:3}
echo -e "usrid=\"$id\"
iuser=\"\"
cntct=\"\"" > "$DC_s/3.cfg"; }
[ ! $(grep -oP '(?<=usrid=\").*(?=\")' "$DC_s/3.cfg") ] && _cfg

function dwld() {
    err() {
        cleanups "$DT/download" &
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" info
    }
    # downloading from http://server_temp/c/xxx.md5sum.tar.gz
    sleep 0.5
    msg "$(gettext "When the download completes the files will be added to topic directory.")" info "$(gettext "Downloading")"
    kill -9 $(pgrep -f "yad --form --columns=2")
    mkdir "$DT/download"; idcfg="$DM_tl/${2}/.conf/id.cfg"
    ilink=$(grep -o 'ilink="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    md5id=$(grep -o 'md5id="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    oname=$(grep -o 'oname="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    langt=$(grep -o 'langt="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    [ -z "${oname}" ] && oname="${tpc}"
    pre="$(sed 's/ /_/g' <<< "${oname:0:10}")"
    url1="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
    |grep -o 'DOWNLOADS="[^"]*' |grep -o '[^"]*$')"
    url2="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
    |grep -o 'DOWNLOADS2="[^"]*' |grep -o '[^"]*$')"
    url1="$url1/c/${langt,,}/${pre}${md5id}.tar.gz"
    url2="$url2/c/${langt,,}/${pre}${md5id}.tar.gz"
    if wget -S --spider "${url1}" 2>&1 |grep 'HTTP/1.1 200 OK'; then
        URL="${url1}"
    elif wget -S --spider "${url2}" 2>&1 |grep 'HTTP/1.1 200 OK'; then
        URL="${url2}"
    else err & exit
    fi
    wget -q -c -T 80 -O "$DT/download/${md5id}.tar.gz" "${URL}"
    [ $? != 0 ] && err && exit 1
    
    if [ -f "$DT/download/${md5id}.tar.gz" ]; then
        cd "$DT/download"/
        tar -xzvf "$DT/download/${md5id}.tar.gz"
        
        if [ -d "$DT/download/${oname}" ]; then
            ltotal="$(gettext "Total")"
            laudio="$(gettext "Audio files")"
            limage="$(gettext "Images")"
            lfiles="$(gettext "Additional files")"
            lothers="$(gettext "Others")"
            tmp="$DT/download/${oname}"
            total=$(find "${tmp}" -maxdepth 5 -type f | wc -l)
            c_audio=$(find "${tmp}" -maxdepth 5 -name '*.mp3' | wc -l)
            c_images=$(find "${tmp}" -maxdepth 5 -name '*.jpg' | wc -l)
            hfiles="$(cd "${tmp}"; ls -d ./.[^.]* | less | wc -l)"
            exfiles="$(find "${tmp}" -maxdepth 5 -perm -111 -type f | wc -l)"
            atfiles=$(find "${tmp}/files" -maxdepth 5 -name | wc -l)
            others=$((wchfiles+wcexfiles))
            
            mv -f "${tmp}/conf/info" "${DC_tlt}/info"
            [ ! -d "$DM_t/$langt/.share" ] && mkdir -p "$DM_t/$langt/.share/images"
            mv -n "${tmp}/share"/*.mp3 "$DM_t/$langt/.share"/
            [ ! -f "${DM_tlt}/images" ] && mkdir "${DM_tlt}/images"
            [ -f "${tmp}"/images/img.jpg  ] && \
            mv "${tmp}"/images/img.jpg "${DM_tlt}"/images/img.jpg
            while read -r img; do
                if [ -f "${tmp}/images/${img,,}-0.jpg" ]; then
                if [ -f "$DM_t/$langt/.share/images/${img,,}-0.jpg" ]; then
                    n=`ls "${DM_tls}/images/${img,,}"-*.jpg |wc -l`
                    name_img="${DM_tls}/images/${img,,}"-${n}.jpg
                else name_img="${DM_tls}/images/${img,,}-0.jpg"; fi
                    mv -f "${tmp}/images/${img,,}-0.jpg" "${name_img}"; fi
            done < "${DC_tlt}/3.cfg"
            rm -fr "${tmp}/share" "${tmp}/conf" "${tmp}/images"
            mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
            [ ! -f "${DM_tlt}/files" ] && mkdir "${DM_tlt}/files"
            mv -f "${tmp}"/files/* "${DM_tlt}"/files/
            echo "${oname}" >> "$DM_tl/.3.cfg"
            echo -e "$ltotal $total\n$laudio $c_audio\n$limage $c_images\n$lfiles $atfiles\n$lothers $others" > "${DC_tlt}/download"
            "$DS/ifs/tls.sh" colorize
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
if [ $((inx3+inx4)) -lt 5 ]; then exit 1; fi

if [ "${tpc}" != "${2}" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit 1
fi
if [ -d "$DT/upload" -o -d "$DT/download" ]; then
    [ -e "$DT/download" ] && t="$(gettext "Downloading")..." || t="$(gettext "Uploading")..."
    msg_2 "$(gettext "Wait until it finishes a previous process")\n" dialog-warning OK gtk-stop "$t"
    ret="$?"
    if [ $ret -eq 1 ]; then
        cleanups "$DT/upload" "$DT/download"
        "$DS/stop.sh" 5
    fi
    exit 1
fi

others="$(gettext "Others")"
article="$(gettext "Article")"
city="$(gettext "City")"
comics="$(gettext "Comics")"
culture="$(gettext "Culture")"
education="$(gettext "Education")"
entertainment="$(gettext "Entertainment")"
funny="$(gettext "Funny")"
grammar="$(gettext "Grammar")"
history="$(gettext "History")"
home="$(gettext "Home")"
internet="$(gettext "Internet")"
interview="$(gettext "Interview")"
movies="$(gettext "Movies")"
music="$(gettext "Music")"
nature="$(gettext "Nature")"
news="$(gettext "News")"
office="$(gettext "Office")"
places="$(gettext "Places")"
quotes="$(gettext "Quotes")"
relations="$(gettext "Relations")"
science="$(gettext "Science")"
social_media="$(gettext "Social media")"
sport="$(gettext "Sport")"
tech="$(gettext "Tech")"
lnglbl="${lgtl,,}"
usrid="$(grep -o 'usrid="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
iuser="$(grep -o 'iuser="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
cntct="$(grep -o 'cntct="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
ctgry="$(grep -o 'ctgry="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"

if [ -z "$usrid" -o ${#id} -gt 3 ]; then
b=$(tr -dc a-z < /dev/urandom |head -c 1) # uranium?
usrid="$b$((RANDOM%1000))"
usrid=${usrid:0:3}; fi
[ -z "$iuser" ] && iuser=$USER
note=$(< "${DC_tlt}/info")
imgm="${DM_tlt}/images/Cover.jpg"

if [ $((inx3+inx4)) -ge 15 ]; then
btn="--button="$(gettext "Upload")":0"; else
btn="--center"; fi
cd "$HOME"

if [ -e "${DC_tlt}/download" ]; then
    if [ ! -s "${DC_tlt}/download" ]; then
        c_audio="$(grep -o 'naudi="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        c_images="$(grep -o 'nimag="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        fsize="$(grep -o 'nsize="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Downloadable content available")</b>"
        info2="$(gettext "Audio files:") $c_audio\n$(gettext "Images:") $c_images\n$(gettext "Size:") $fsize"
        dlg=$(yad --form --columns=2 --title="$(gettext "Share")" \
        --name=Idiomind --class=Idiomind \
        --image="$DS/images/download.png" --image-on-top \
        --window-icon="$DS/images/icon.png" --buttons-layout=end \
        --align=left --center --on-top \
        --width=400 --height=220 --borders=12 \
        --text="$info" \
        --field="$info2:lbl" " " \
        --field="$(gettext "Download"):FBTN" "${cmd_dwl}" \
        --field="\t\t\t\t\t:lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "PDF")":2 \
        --button="$(gettext "Close")":4)
        ret=$?
    elif [ -s "${DC_tlt}/download" ]; then
        dlg=$(yad --form --title="$(gettext "Share")" \
        --columns=2 --separator="|" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --buttons-layout=end \
        --align=left --center --on-top \
        --width=400 --height=200 --borders=12 \
        --field="$(gettext "Latest downloads:"):lbl" " " \
        --field="$(< "${DC_tlt}/download"):lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "PDF")":2 \
        --button="$(gettext "Close")":4)
        ret=$?
    fi
else
    linkc="http://idiomind.sourceforge.net/community/${lgtl,,}"
    LANGUAGE_TO_LEARN=${lgtl}
    dlg=$(yad --form --title="$(gettext "Share")" \
    --text="$(gettext "Share your notes with other ${LANGUAGE_TO_LEARN} learners!")\n<a href='$linkc'>$(gettext "Topics shared")</a> (Beta)\n" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" --buttons-layout=end \
    --align=right --center --on-top \
    --width=460 --height=450 --borders=12 \
    --field="$(gettext "Author")" "$iuser" \
    --field="\t$(gettext "Contact (optional)")" "$cntct" \
    --field="$(gettext "Category"):CBE" \
    "$ctgry!$others!$article!$city!$comics!$culture!$education!$entertainment!$funny!$grammar!$history!$home!$internet!$interview!$movies!$music!$nature!$news!$office!$places!$quotes!$relations!$science!$social_media!$sport!$tech" \
    --field="$(gettext "Skill Level"):CB" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
    --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
    --button="$(gettext "PDF")":2 "$btn" --button="$(gettext "Close")":4)
    ret=$?
fi

if [ $ret = 2 ]; then
    "$DS/ifs/mods/export/PDF.sh" & exit 1
 
elif [ $ret = 0 ]; then
Ctgry=$(echo "${dlg}" | cut -d "|" -f3)
level=$(echo "${dlg}" | cut -d "|" -f4)
iuser_m=$(echo "${dlg}" | cut -d "|" -f1)
cntct_m=$(echo "${dlg}" | cut -d "|" -f2)
notes_m=$(echo "${dlg}" | cut -d "|" -f5)
[ "$Ctgry" = "$others" ] && Ctgry=others
[ "$Ctgry" = "$comics" ] && Ctgry=comics
[ "$Ctgry" = "$culture" ] && Ctgry=culture
[ "$Ctgry" = "$family" ] && Ctgry=family
[ "$Ctgry" = "$entertainment" ] && Ctgry=entertainment
[ "$Ctgry" = "$grammar" ] && Ctgry=grammar
[ "$Ctgry" = "$history" ] && Ctgry=history
[ "$Ctgry" = "$documentary" ] && Ctgry=documentary
[ "$Ctgry" = "$in_the_city" ] && Ctgry=in_the_city
[ "$Ctgry" = "$movies" ] && Ctgry=movies
[ "$Ctgry" = "$internet" ] && Ctgry=internet
[ "$Ctgry" = "$music" ] && Ctgry=music
[ "$Ctgry" = "$nature" ] && Ctgry=nature
[ "$Ctgry" = "$news" ] && Ctgry=news
[ "$Ctgry" = "$office" ] && Ctgry=office
[ "$Ctgry" = "$relations" ] && Ctgry=relations
[ "$Ctgry" = "$sport" ] && Ctgry=sport
[ "$Ctgry" = "$social_networks" ] && Ctgry=social_networks
[ "$Ctgry" = "$shopping" ] && Ctgry=shopping
[ "$Ctgry" = "$technology" ] && Ctgry=technology
[ "$Ctgry" = "$article" ] && Ctgry=article
[ "$Ctgry" = "$travel" ] && Ctgry=travel
[ "$Ctgry" = "$interview" ] && Ctgry=interview
[ "$Ctgry" = "$science" ] && Ctgry=science
[ "$Ctgry" = "$funny" ] && Ctgry=funny
[ "$Ctgry" = "$others" ] && Ctgry=others
[ "$level" = $(gettext "Beginner") ] && level=0
[ "$level" = $(gettext "Intermediate") ] && level=1
[ "$level" = $(gettext "Advanced") ] && level=2

if [ -z "${iuser_m##+([[:space:]])}" -o ${#iuser_m} -gt 60 ] || \
[ "$(grep -o -E '\*|\/|\@|$|\)|\(|=|-' <<<"${iuser_m}")" ]; then
msg "$(gettext "You have entered an invalid author name.")\n " info
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ ${#cntct_m} -gt 30 ] || \
[ "$(grep -o -E '\*|\/|$|\)|\(|=' <<<"${cntct_m}")" ]; then
    msg "$(gettext "You have entered an invalid contact format.")\n " info
    "$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ -z "${Ctgry}" ]; then
    msg "$(gettext "Please select a category.")\n " info
    "$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ -d "${DM_tlt}/files" ]; then
    du=$(du -sb "${DM_tlt}/files" | cut -f1)
    if [[ "$du" -gt 50000000 ]]; then
    msg "$(gettext "Sorry, the size of the attachments is too large.")\n " info & exit 1; fi
fi

internet
[ -d "$DT" ] && cd "$DT" || exit 1
[ -d "$DT/upload" ] && rm -fr "$DT/upload"

notify-send -i info "$(gettext "Upload in progress")" \
"$(gettext "This can take some time, please wait")" -t 6000

"$DS/ifs/tls.sh" check_index "${tpc}" 1
mkdir "$DT/upload"
DT_u="$DT/upload/"
mkdir -p "$DT/upload/${tpc}/conf"
c_words=${inx3}
c_sntncs=${inx4}

if [ -e "${DC_tlt}/id.cfg" ]; then
    oname="$(grep -o 'oname="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    datec="$(grep -o 'datec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
    datei="$(grep -o 'datei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
fi
dateu=$(date +%F)
sum=`md5sum "${DC_tlt}/0.cfg" | cut -d' ' -f1`
[ -z "${oname}" ] && oname="${tpc}"

if [ "${iuser}" != "${iuser_m}" ] \
|| [ "${cntct}" != "${cntct_m}" ]; then
echo -e "usrid=\"$usrid\"
iuser=\"$iuser_m\"
cntct=\"$cntct_m\"" > "$DC_s/3.cfg"
fi

cd "${DM_tlt}"/
cp -r ./* "$DT_u/${tpc}/"
cp "${DC_tlt}/6.cfg" "$DT_u/${tpc}/conf/6.cfg"
mkdir "$DT_u/${tpc}/share"
[ ! -d "$DT_u/${tpc}/images" ] && mkdir "$DT_u/${tpc}/images"
[ ! -d "$DT_u/${tpc}/files" ] && mkdir "$DT_u/${tpc}/files"

auds="$(uniq < "${DC_tlt}/4.cfg" \
| sed 's/\n/ /g' | sed 's/ /\n/g' \
| grep -v '^.$' | grep -v '^..$' \
| sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//'g \
|  sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /'g \
| tr -d ')' | tr -d '(' | tr '[:upper:]' '[:lower:]')"
while read -r audio; do
    if [ -f "$DM_tl/.share/$audio.mp3" ]; then
    cp -f "$DM_tl/.share/$audio.mp3" "$DT_u/${tpc}/share/$audio.mp3"; fi
done <<<"$auds"
while read -r audio; do
    if [ -f "$DM_tl/.share/${audio,,}.mp3" ]; then
    cp -f "$DM_tl/.share/${audio,,}.mp3" "$DT_u/${tpc}/share/${audio,,}.mp3"; fi
done < "${DC_tlt}/3.cfg"

c_audio=$(find "$DT_u/${tpc}" -maxdepth 5 -name '*.mp3' |wc -l)
while read -r img; do
    if [ -f "$DM_tl/.share/images/${img,,}-0.jpg" ]; then
    cp -f "$DM_tl/.share/images/${img,,}-0.jpg" "$DT_u/${tpc}/images/${img,,}-0.jpg"; fi
done < "${DC_tlt}/3.cfg"
c_images=$(cd "$DT_u/${tpc}/images"/; ls *.jpg |wc -l)

echo -e "${notes_m}" > "$DT_u/${tpc}/conf/info"

cd "$DT/upload"/
pre="$(sed 's/ /_/g' <<< "${oname:0:10}")"
find "$DT_u"/ -type f -exec chmod 644 {} \;
tar czpvf - ./"${tpc}" |split -d -b 2500k - ./"${pre}${sum}"
rm -fr ./"${tpc}"; rename 's/(.*)/$1.tar.gz/' *
f_size=$(du -h . |cut -f1)

eval c="$(< "$DS/default/topicid")"
echo -n "${c}" > "${DC_tlt}/id.cfg"
cp -f "${DC_tlt}/0.cfg" "$DT_u/$usrid.${tpc}.$lgt"
tr '\n' '&' < "${DC_tlt}/id.cfg" >> "$DT_u/$usrid.${tpc}.$lgt"
echo -n "&idiomind-`idiomind -v`" >> "$DT_u/$usrid.${tpc}.$lgt"
echo -en "\nidiomind-`idiomind -v`" >> "${DC_tlt}/id.cfg"

# uploading files to http://server_temp/lang/xxx.name.idmnd
url="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
| grep -o 'UPLOADS="[^"]*' | grep -o '[^"]*$')"
direc="$DT_u"
log="$DT_u/log"
user='robin'
pwd='333333'
title="$tpc"
body="$(tac "${DC_tlt}/1.cfg")"
export direc url log user pwd title body

python << END
import os, sys, requests, time, xmlrpclib
reload(sys)
sys.setdefaultencoding("utf-8")
site_url  = 'http://test.com/'
post_type = 'blog'
publish  = True
user = os.environ['user']
pwd = os.environ['pwd']
title = os.environ['title']
body = os.environ['body']
try:
	server = xmlrpclib.Server(site_url + 'xmlrpc.php')
	nid = server.metaWeblog.newPost(post_type, user, pwd, {'title': title, 'description': body}, publish)
except:
    pass
url = os.environ['url']
direc = os.environ['direc']
log = os.environ['log']
volumes = [i for i in os.listdir(direc)]
for f in volumes:
    file = {'file': open(f, 'rb')}
    r = requests.post(url, files=file)
    p = open(log, "w")
    p.write("x")
    p.close()
    time.sleep(5)
END
u=$?
if [ $u = 0 ]; then
    info="\"$tpc\"\n<b>$(gettext "Uploaded correctly")</b>\n"
    image=gtk-ok
else
    sleep 10
    info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
    image=gtk-warning
fi
msg "$info" $image

cleanups "${DT_u}"
exit 0
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
    share)
    download "$@" ;;
esac
