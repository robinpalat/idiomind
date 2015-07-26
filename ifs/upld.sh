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

    # downloading from http://server_temp/c/xxx.md5sum.tar.gz
    sleep 0.5
    msg "$(gettext "When the download completes the files will be added to topic directory.")" info "$(gettext "Downloading")..."
    kill -9 $(pgrep -f "yad --form --columns=2")
    mkdir "$DT/download"
    idcfg="$DM_tl/${2}/.conf/id.cfg"
    ilink=$(grep -o 'ilink="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    md5id=$(grep -o 'md5id="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    oname=$(grep -o 'oname="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    langt=$(grep -o 'langt="[^"]*' "${idcfg}" |grep -o '[^"]*$')
    url="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
    | grep -o 'DOWNLOADS="[^"]*' | grep -o '[^"]*$')"
    URL="$url/c/$ilink.${md5id}.tar.gz"

    if ! wget -S --spider "${URL}" 2>&1 |grep 'HTTP/1.1 200 OK'; then
        cleanups "$DT/download"
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" info & exit; fi
    
    wget -q -c -T 80 -O "$DT/download/${oname}.tar.gz" "${URL}"

    if [ -f "$DT/download/${oname}.tar.gz" ]; then
        cd "$DT/download"/
        tar -xzvf "$DT/download/${oname}.tar.gz"
        
        if [ -d "$DT/download/${oname}" ]; then
        
        ltotal="$(gettext "Total:")"
        laudio="$(gettext "Audio files:")"
        limage="$(gettext "Images:")"
        lfiles="$(gettext "Additional files:")"
        lothers="$(gettext "Others:")"
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
        n=`ls "$DM_t/$langt/.share/images/${img,,}-"*.jpg |wc -l`
        name_img="${DM_tls}/images/${trgt,,}-"${n}.jpg
        else name_img="${DM_tls}/images/${trgt,,}-0.jpg"; fi
        mv -f "${tmp}/images/${img,,}-0.jpg" "$name_img"; fi
        done < "${DC_tlt}/3.cfg"
        rm -fr "${tmp}/share" "${tmp}/conf" "${tmp}/images"
        mv -f "${tmp}"/*.mp3 "${DM_tlt}"/
        [ ! -f "${DM_tlt}/files" ] && mkdir "${DM_tlt}/files"
        mv -f "${tmp}"/files/* "${DM_tlt}"/files/
        echo "${oname}" >> "$DM_tl/.3.cfg"
        echo -e "$ltotal $total\n$laudio $c_audio\n$limage $c_images\n$lfiles $atfiles\n$lothers $others" > "${DC_tlt}/11.cfg"
        "$DS/ifs/tls.sh" colorize
        rm -fr "$DT/download"
        
        else
            cleanups "$DT/download"
            msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" info & exit
        fi
    else
        cleanups "$DT/download"
        msg "$(gettext "A problem has occurred while fetching data, try again later.")\n" info & exit
    fi
    exit
}


function upld() {

if [ $((inx3+inx4)) -lt 2 ]; then
msg "$(gettext "Unavailable")\n" info "$(gettext "Unavailable")" & exit 1; fi

if [ "${tpc}" != "${2}" ]; then
msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit 1; fi

if [ -d "$DT/upload" -o -d "$DT/download" ]; then
msg_2 "$(gettext "Wait until it finishes a previous process")\n" info OK gtk-stop "$(gettext "Warning")"
ret="$?"
if [ $ret -eq 1 ]; then
cleanups "$DT/upload" "$DT/download"
"$DS/stop.sh" 5
fi
exit 1
fi

others="$(gettext "Others")"
comics="$(gettext "Comics")"
culture="$(gettext "Culture")"
family="$(gettext "Family")"
entertainment="$(gettext "Entertainment")"
grammar="$(gettext "Grammar")"
history="$(gettext "History")"
documentary="$(gettext "Documentary")"
in_the_city="$(gettext "In the city")"
movies="$(gettext "Movies")"
internet="$(gettext "Internet")"
music="$(gettext "Music")"
nature="$(gettext "Nature")"
news="$(gettext "News")"
office="$(gettext "Office")"
relations="$(gettext "Relations")"
sport="$(gettext "Sport")"
social_networks="$(gettext "Social networks")"
shopping="$(gettext "Shopping")"
technology="$(gettext "Technology")"
travel="$(gettext "Travel")"
article="$(gettext "Article")"
science="$(gettext "Science")"
interview="$(gettext "Interview")"
funny="$(gettext "Funny")"
lnglbl="${lgtl,,}"
usrid="$(grep -o 'usrid="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
iuser="$(grep -o 'iuser="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
cntct="$(grep -o 'cntct="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
if [ -z "$usrid" -o ${#id} -gt 3 ]; then
b=$(tr -dc a-z < /dev/urandom |head -c 1)
usrid="$b$((RANDOM%1000))"
usrid=${usrid:0:3}; fi
[ -z "$iuser" ] && iuser=$USER
note=$(< "${DC_tlt}/info")
imgm="${DM_tlt}/images/img.jpg"

"$DS/ifs/tls.sh" check_index "${tpc}"
if [ $((inx3+inx4)) -ge 15 ]; then
btn="--button="$(gettext "Upload")":0"; else
btn="--center"; fi
cd "$HOME"

if [ -f "${DC_tlt}/11.cfg" ]; then

        if [ -z "$(< "${DC_tlt}/11.cfg")" ]; then
        c_audio="$(grep -o 'naudi="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        c_images="$(grep -o 'nimag="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        fsize="$(grep -o 'nsize="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        cmd_dwl="$DS/ifs/upld.sh 'dwld' "\"${tpc}\"""
        info="<b>$(gettext "Additional content available")</b>"
        info2="$(gettext "Audio files:") $c_audio\n$(gettext "Images:") $c_images\n$(gettext "Size:") $fsize"
        dlg=$(yad --form --columns=2 --title="$(gettext "Share")" \
        --text="<span font_desc='Free Sans 15'> ${tpc}</span>" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --buttons-layout=end \
        --align=left --center --on-top \
        --width=380 --height=260 --borders=12 \
        --field="\n\n$info:lbl" " " \
        --field="$(gettext "Download"):BTN" "${cmd_dwl}" \
        --field="$info2:lbl" " " \
        --field="\t\t\t\t\t:lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "PDF")":2 \
        --button="$(gettext "Close")":4)
        ret=$?
        
        elif [ -n "$(< "${DC_tlt}/11.cfg")" ]; then
        dlg=$(yad --form --title="$(gettext "Share")" \
        --columns=2 --separator="|" \
        --text="<span font_desc='Free Sans 15'> ${tpc}</span>" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --buttons-layout=end \
        --align=left --center --on-top \
        --width=380 --height=260 --borders=12 \
        --field="$(gettext "Latest Download:"):lbl" " " \
        --field="$(< "${DC_tlt}/11.cfg"):lbl" " " \
        --field=" :lbl" " " \
        --button="$(gettext "PDF")":2 \
        --button="$(gettext "Close")":4)
        ret=$?
        
        fi
else
    dlg=$(yad --form --title="$(gettext "Share")" \
    --text="<span font_desc='Free Sans 14'>${tpc}</span>" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" --buttons-layout=end \
    --align=right --center --on-top \
    --width=480 --height=460 --borders=12 \
    --field=" :lbl" " " \
    --field="$(gettext "Author")" "$iuser" \
    --field="\t$(gettext "Contact (Optional)")" "$cntct" \
    --field="$(gettext "Category"):CBE" \
    "!$others!$article!$comics!$culture!$documentary!$entertainment!$funny!$family!$grammar!$history!$movies!$in_the_city!$interview!$internet!$music!$nature!$news!$office!$relations!$sport!$science!$shopping!$social_networks!$technology!$travel" \
    --field="$(gettext "Skill Level"):CB" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
    --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
    --field="$(gettext "Image 600x150px"):FL" "${imgm}" \
    --button="$(gettext "PDF")":2 "$btn" \
    --button="$(gettext "Close")":4)
    ret=$?

    img=$(echo "${dlg}" | cut -d "|" -f7)
    if [ -f "${img}" -a "${img}" != "${imgm}" ]; then
    wsize="$(identify "${img}" | cut -d ' ' -f 3 | cut -d 'x' -f 1)"
    esize="$(identify "${img}" | cut -d ' ' -f 3 | cut -d 'x' -f 2)"
    if [ ${wsize} -gt 1000 ] || [ ${wsize} -lt 400 ] \
    || [ ${esize} -lt 100 ] || [ ${esize} -gt 600 ]; then
    msg "$(gettext "Sorry, the image size is not suitable.")\n " info "$(gettext "Error")"
    "$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi
    /usr/bin/convert "${img}" -interlace Plane -thumbnail 600x150^ \
    -gravity center -extent 600x150 \
    -quality 100% "${DM_tlt}/images/img.jpg"
    fi
fi

if [ $ret = 2 ]; then
    "$DS/ifs/tls.sh" pdf & exit 1
    
elif [ $ret = 0 ]; then

Ctgry=$(echo "${dlg}" | cut -d "|" -f4)
level=$(echo "${dlg}" | cut -d "|" -f5)
iuser_m=$(echo "${dlg}" | cut -d "|" -f2)
cntct_m=$(echo "${dlg}" | cut -d "|" -f3)
notes_m=$(echo "${dlg}" | cut -d "|" -f6)
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

if [ -z "${iuser_m##+([[:space:]])}" ] || [ ${#iuser_m} -gt 60 ] || \
[ "$(grep -o -E '\*|\/|\@|$|\)|\(|=|-' <<<"${iuser_m}")" ]; then
msg "$(gettext "Name author not válid.")\n " info
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ ${#cntct_m} -gt 30 ] || \
[ "$(grep -o -E '\*|\/|$|\)|\(|=' <<<"${cntct_m}")" ]; then
msg "$(gettext "Invalid contact format.")\n " info
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ -z "${Ctgry}" ]; then
msg "$(gettext "Please select a category.")\n " info
"$DS/ifs/upld.sh" upld "${tpc}" & exit 1; fi

if [ -d "${DM_tlt}/files" ]; then
du=$(du -sb "${DM_tlt}/files" | cut -f1)
if [[ "$du" -gt 50000000 ]]; then
msg "$(gettext "Sorry, the size of the attachments is too large.")\n " info & exit 1; fi; fi

internet
[ -d "$DT" ] && cd "$DT" || exit 1
[ -d "$DT/upload" ] && rm -fr "$DT/upload"

notify-send "$(gettext "Upload in progress")" \
"$(gettext "This can take some time, please wait")" -t 6000

mkdir "$DT/upload"
DT_u="$DT/upload/"
mkdir -p "$DT/upload/${tpc}/conf"

"$DS/ifs/tls.sh" check_index "${tpc}" 1

c_words=${inx3}
c_sntncs=${inx4}

if [ -f "${DC_tlt}/id.cfg" ]; then
datec="$(grep -o 'datec="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
datei="$(grep -o 'datei="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"; fi
dateu=$(date +%F)
sum=`md5sum "${DC_tlt}/0.cfg" | cut -d' ' -f1`

if [ "${iuser}" != "${iuser_m}" ] \
|| [ "${cntct}" != "${cntct_m}" ]; then
echo -e "usrid=\"$usrid\"
iuser=\"$iuser_m\"
cntct=\"$cntct_m\"" > "$DC_s/3.cfg"
fi

cd "${DM_tlt}"
cp -r ./* "$DT_u/${tpc}/"
mkdir "$DT_u/${tpc}/files"
mkdir "$DT_u/${tpc}/share"
[ ! -d "$DT_u/${tpc}/images" ] && mkdir "$DT_u/${tpc}/images"

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
c_audio=$(find "$DT_u/${tpc}" -maxdepth 5 -name '*.mp3' |wc -l)

while read -r img; do
if [ -f "$DM_tl/.share/images/${img,,}-0.jpg" ]; then
cp -f "$DM_tl/.share/images/${img,,}-0.jpg" "$DT_u/${tpc}/images/${img,,}-0.jpg"; fi
done < "${DC_tlt}/3.cfg"
c_images=$(cd "$DT_u/${tpc}/images"/; ls *.jpg |wc -l)

echo -e "${notes_m}" > "$DT_u/${tpc}/conf/info"

cd "$DT/upload"
find "$DT_u" -type f -exec chmod 644 {} \;
tar czpvf - ./"${tpc}" |split -d -b 2500k - ./"$usrid.${sum}"
rm -fr ./"${tpc}"
f_size=$(du -h . | cut -f1)

echo -e "v=1
tname=\"${tpc}\"
langs=\"$lgsl\"
langt=\"$lgtl\"
authr=\"$iuser_m\"
cntct=\"$cntct_m\"
ctgry=\"$Ctgry\"
ilink=\"$usrid\"
oname=\"${tpc}\"
datec=\"$datec\"
dateu=\"$dateu\"
datei=\"$datei\"
nword=\"$c_words\"
nsent=\"$c_sntncs\"
nimag=\"$c_images\"
naudi=\"$c_audio\"
nsize=\"$f_size\"
level=\"$level\"
set_1=\"$set_1\"
set_2=\"$set_2\"
set_3=\"$set_3\"
set_4=\"$set_4\"
md5id=\"$sum\"" > "${DC_tlt}/id.cfg"
cp -f "${DC_tlt}/0.cfg" "$DT_u/$usrid.${tpc}.$lgt"
tr '\n' '&' < "${DC_tlt}/id.cfg" >> "$DT_u/$usrid.${tpc}.$lgt"

# uploading files to http://server_temp/lang/xxx.name.idmnd
url="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP \
| grep -o 'UPLOADS="[^"]*' | grep -o '[^"]*$')"
direc="$DT_u"
log="$DT_u/log"
export direc url log

python << END
import os, sys, requests, time
reload(sys)
sys.setdefaultencoding("utf-8")
url = os.environ['url']
direc = os.environ['direc']
log = os.environ['log']
volumes = [i for i in os.listdir(direc)]
for f in volumes:
    file = {'file': open(f, 'rb')}
    r = requests.post(url, files=file)
    p = open(log, "w")
    p.write("xxx")
    p.close()
    time.sleep(5)
END
u=$?

if [ $u = 0 ]; then
    [ ! -d "${DM}/backup" ] && mkdir "${DM}/backup"
    mv -f "$DT_u/${usrid}.${tpc}.$lgt" "${DM}/backup/${tpc}.idmnd"
    info=" <b>$(gettext "Uploaded correctly")</b>\n $tpc\n"
    image=dialog-ok
else
    sleep 10
    info="$(gettext "A problem has occurred with the file upload, try again later.")\n"
    image=dialog-warning
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
