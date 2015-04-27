#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)

vsd() {

    cd "$DM_t/saved"; ls -t *.id | sed 's/\.id//g' | \
    yad --list --title="$(gettext "Saved Topics")" \
    --text="$(gettext "Double clik to download")" \
    --name=Idiomind --class=Idiomind \
    --dclick-action="$DS/ifs/upld.sh 'infsd'" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=520 --height=380 --borders=10 \
    --print-column=1 --no-headers \
    --column=Nombre:TEXT \
    --button=gtk-close:1
    exit
} >/dev/null 2>&1

infsd() {

    file="$DM_t/saved/$2.id"
    idlink=$(sed -n 1p "$DC_s/3.cfg")
    language_source=$(sed -n 2p "$file" | grep -o 'language_source="[^"]*' | grep -o '[^"]*$')
    language_target=$(sed -n 3p "$file" | grep -o 'language_target="[^"]*' | grep -o '[^"]*$')
    category=$(sed -n 6p "$file" | grep -o 'category="[^"]*' | grep -o '[^"]*$')
    link=$(sed -n 7p "$file" | grep -o 'link="[^"]*' | grep -o '[^"]*$')
    name=$(sed -n 1p "$file" | grep -o 'name="[^"]*' | grep -o '[^"]*$')
    lng=$(lnglss "$language_source")
    lnglbl="${language_target,,}"
    
    cd "$HOME"
    sleep 0.5
    sv=$(yad --file --save --title="$(gettext "Save")" \
    --filename="$2.idmnd" \
    --window-icon="$DS/images/icon.png" --skip-taskbar --center --on-top \
    --width=600 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 --button="Ok":0)
    ret=$?
    
    if [[ $ret -eq 0 ]]; then
        
        internet; cd "$DT"
        DOWNLOADS="$(curl http://idiomind.sourceforge.net/doc/SITE_TMP | \
        grep -o 'DOWNLOADS="[^"]*' | grep -o '[^"]*$')"
        file="$DOWNLOADS/$lng/$lnglbl/$category/$link.$name.idmnd"
        [ -z "$DOWNLOADS" ] && msg "$(gettext "The server is not available at the moment.")" dialog-warning && exit
        
        WGET() {
        rand="$RANDOM `date`"
        pipe="/tmp/pipe.$(echo '$rand' | md5sum | tr -d ' -')"
        mkfifo "$pipe"
        wget -c "$1" 2>&1 | while read data;do
        if [ "`echo $data | grep '^Length:'`" ]; then
        total_size=$(echo $data | grep "^Length:" | sed 's/.*\((.*)\).*/\1/' | tr -d '()')
        fi
        if [ "$(echo $data | grep '[0-9]*%' )" ];then
        percent=$(echo $data | grep -o "[0-9]*%" | tr -d '%')
        echo "$percent"
        echo "# $(gettext "Downloading...")  $percent%"
        fi
        done > "$pipe" &
        wget_info=$(ps ax |grep "wget.*$1" |awk '{print $1"|"$2}')
        wget_pid=$(echo $wget_info | cut -d'|' -f1)
        yad --progress --title="$(gettext "Downloading")" \
        --progress-text=" " --auto-close \
        --skip-taskbar --no-buttons --on-top --fixed \
        --width=200 --height=50 --borders=4 --geometry=240x20-4-4 < "$pipe"

        if [ "$(ps -A |grep "$wget_pid")" ];then
        kill "$wget_pid"
        fi
        rm -f "$pipe"
        }
        WGET "$file"
        
        if [ -f "$DT/$link.$name.idmnd" ] ; then
        [ -f "$sv" ] && rm "$sv"
        mv -f "$DT/$link.$name.idmnd" "$sv"
        else
        msg "$(gettext "The file is not yet available for download from the server.")\n" info && exit
        fi
    fi
    exit
}

function upld() {

if [ "$tpc" != "$2" ]; then
msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi

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
idlink=$(sed -n 1p $DC_s/3.cfg)
[ -z "$idlink" ] && idlink=$(($RANDOM%100))
mail=$(sed -n 2p $DC_s/3.cfg)
user=$(sed -n 3p $DC_s/3.cfg)
[ -z "$user" ] && user=$(echo "$(whoami)")
nt=$(< "$DC_tlt/10.cfg")
nme=$(echo "$tpc" | sed 's/ /_/g' | tr -s '"' ' ' | sed 's/’//g')
imgm="$DM_tlt/words/images/img.jpg"

"$DS/ifs/tls.sh" check_index "$tpc"

if [ $(cat "$DC_tlt/0.cfg" | wc -l) -ge 20 ]; then
btn="--button="$(gettext "Upload")":0"; else
btn="--center"; fi

cd "$HOME"
upld=$(yad --form --title="$(gettext "Share")" \
--text="   <b>$tpc</b>" \
--name=Idiomind --class=Idiomind \
--window-icon="$DS/images/icon.png" --buttons-layout=end \
--align=right --center --on-top \
--width=480 --height=460 --borders=10 \
--field=" :lbl" "#1" \
--field="    $(gettext "Author")" "$user" \
--field="    $(gettext "Contact (Optional)")" "$mail" \
--field="    $(gettext "Category"):CBE" \
"!$others!$article!$comics!$culture!$documentary!$entertainment!$funny!$family!$grammar!$history!$movies!$in_the_city!$interview!$internet!$music!$nature!$news!$office!$relations!$sport!$science!$shopping!$social_networks!$technology!$travel" \
--field="    $(gettext "Skill Level"):CBE" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
--field="\n$(gettext "Description/Notes"):TXT" "$nt" \
--field="$(gettext "Image 600x150px"):FL" "$imgm" \
--button="$(gettext "Cancel")":4 \
--button="$(gettext "PDF")":2 "$btn")
ret=$?

img=$(echo "$upld" | cut -d "|" -f7)
if [ -f "$img" ] && [ "$img" != "$imgm" ]; then
wsize="$(identify "$img" | cut -d ' ' -f 3 | cut -d 'x' -f 1)"
esize="$(identify "$img" | cut -d ' ' -f 3 | cut -d 'x' -f 2)"
if [ "$wsize" -gt 1000 ] || [ "$wsize" -lt 600 ] \
|| [ "$esize" -lt 100 ] || [ "$esize" -gt 400 ]; then
msg "$(gettext "Sorry, the image size is not suitable.")\n " info "$(gettext "Error")"
"$DS/ifs/upld.sh" upld "$tpc" & exit 1; fi
/usr/bin/convert "$img" -interlace Plane -thumbnail 600x150^ \
-gravity center -extent 600x150 \
-quality 100% "$DM_tlt/words/images/img.jpg"
fi

if [[ $ret = 2 ]]; then
    "$DS/ifs/tls.sh" pdf & exit 1
    
elif [[ $ret = 0 ]]; then

Ctgry=$(echo "$upld" | cut -d "|" -f4)
level=$(echo "$upld" | cut -d "|" -f5)
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
[ "$level" = $(gettext "Beginner") ] && level=1
[ "$level" = $(gettext "Intermediate") ] && level=2
[ "$level" = $(gettext "Advanced") ] && level=3

Author=$(echo "$upld" | cut -d "|" -f2)
Mail=$(echo "$upld" | cut -d "|" -f3)
notes=$(echo "$upld" | cut -d "|" -f6)
data=$(curl http://idiomind.sourceforge.net/doc/SITE_TMP)

if [ -z "$Ctgry" ]; then
msg "$(gettext "Please select a category.")\n " info
"$DS/ifs/upld.sh" upld "$tpc" & exit 1; fi

if [ -d "$DM_tlt/files" ]; then
du=$(du -sb "$DM_tlt/files" | cut -f1)
if [ "$du" -gt 50000000 ]; then
msg "$(gettext "Sorry, the size of the attachments is too large.")\n " info & exit 1; fi
fi

internet; cd "$DT"

mkdir "$DT/upload"
DT_u="$DT/upload"
mkdir "$DT/upload/$tpc"

cd "$DM_tlt/words/images"
if [ $(ls -1 *.jpg 2>/dev/null | wc -l) != 0 ]; then
images=$(ls *.jpg | wc -l); else
images=0; fi
[ -f "$DC_tlt/3.cfg" ] && words=$(wc -l < "$DC_tlt/3.cfg")
[ -f "$DC_tlt/4.cfg" ] && sentences=$(wc -l < "$DC_tlt/4.cfg")
[ -f "$DC_tlt/12.cfg" ] && date_c="$(sed -n 8p < "$DC_tlt/12.cfg" | grep -o 'date_c="[^"]*' | grep -o '[^"]*$')"
date_u=$(date +%F)

echo -e "name=\"$tpc\"
language_source=\"$lgsl\"
language_target=\"$lgtl\"
author=\"$Author\"
contact=\"$Mail\"
category=\"$Ctgry\"
link=\"$idlink\"
date_c=\"$date_c\"
date_u=\"$date_u\"
nwords=\"$words\"
nsentences=\"$sentences\"
nimages=\"$images\"
level=\"$level\"" > "$DT_u/$tpc/12.cfg"
cp -f "$DT_u/$tpc/12.cfg" "$DT/12.cfg"
echo -e "$idlink
$Mail
$Author" > "$DC_s/3.cfg"

cd "$DM_tlt"
cp -r ./* "$DT_u/$tpc/"
cp -r "./words" "$DT_u/$tpc/"
cp -r "./words/images" "$DT_u/$tpc/words"
mkdir "$DT_u/$tpc/files"
mkdir "$DT_u/$tpc/audio"

auds="$(uniq < "$DC_tlt/4.cfg" \
| sed 's/\n/ /g' | sed 's/ /\n/g' \
| grep -v '^.$' | grep -v '^..$' \
| sed 's/&//; s/,//; s/\?//; s/\¿//; s/;//'g \
|  sed 's/\!//; s/\¡//; s/\]//; s/\[//; s/\.//; s/  / /'g \
| tr -d ')' | tr -d '(' | tr '[:upper:]' '[:lower:]')"

while read -r audio; do
if [ -f "$DM_tl/.share/$audio.mp3" ]; then
cp -f "$DM_tl/.share/$audio.mp3" "$DT_u/$tpc/audio/$audio.mp3"; fi
done <<<"$auds"

cp -f "$DC_tlt/0.cfg" "$DT_u/$tpc/0.cfg"
cp -f "$DC_tlt/3.cfg" "$DT_u/$tpc/3.cfg"
cp -f "$DC_tlt/4.cfg" "$DT_u/$tpc/4.cfg"
printf "${notes}" > "$DC_tlt/10.cfg"
printf "${notes}" > "$DT_u/$tpc/10.cfg"

find "$DT_u" -type f -exec chmod 644 {} \;
cd "$DT_u"
tar -cvf "$tpc.tar" "$tpc"
gzip -9 "$tpc.tar"
mv "$tpc.tar.gz" "$idlink.$tpc.idmnd"
[ -d "$DT_u/$tpc" ] && rm -fr "$DT_u/$tpc"
dte=$(date "+%d %B %Y")
notify-send "$(gettext "Uploading")" "$(gettext "Please wait while file is uploaded")" -i idiomind -t 6000

lftp -u "`sed -n 4p <<<"$data" | grep -o 'USER="[^"]*' | grep -o '[^"]*$'`",\
"`sed -n 5p <<<"$data" | grep -o 'KEY="[^"]*' | grep -o '[^"]*$'`" \
"`sed -n 3p <<<"$data" | grep -o 'FTPHOST="[^"]*' | grep -o '[^"]*$'`" << END_SCRIPT
mirror --reverse ./ public_html/$lgs/$lnglbl/$Ctgry/
quit
END_SCRIPT

exit=$?
if [[ $exit = 0 ]]; then
    mv -f "$DT/12.cfg" "$DM_t/saved/$tpc.id"
    info=" <b>$(gettext "Successfully published.")</b>\n $tpc\n"
    image=dialog-ok
else
    sleep 10
    info="$(gettext "Occurred a problem with the file upload, try again later.")"
    image=dialog-warning
fi

msg "$info" $image

[ -d "$DT_u/$tpc" ] && rm -fr "$DT_u/$tpc"
[ "$DT/12.cfg" ] && rm -f "$DT/12.cfg"
[ "$DT_u/$idlink.$tpc.idmnd" ] && rm -f "$DT_u/$idlink.$tpc.idmnd"
[ "$DT_u/$tpc.tar" ] && rm -f "$DT_u/$tpc.tar"
[ "$DT_u/$tpc.tar.gz" ] && rm -f "$DT_u/$tpc.tar.gz"
[ -d "$DT_u" ] && rm -fr "$DT_u"
exit 0
fi
    
} >/dev/null 2>&1

case "$1" in
    vsd)
    vsd "$@" ;;
    infsd)
    infsd "$@" ;;
    upld)
    upld "$@" ;;
esac
