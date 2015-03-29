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

if [ "$1" = vsd ]; then

    U=$(sed -n 1p $HOME/.config/idiomind/s/4.cfg)
    lng=$(echo "$lgtl" | awk '{print tolower($0)}')
    wth=$(($(sed -n 2p $DC_s/10.cfg)-350))
    eht=$(($(sed -n 3p $DC_s/10.cfg)-0))
    
    cd "$DM_t/saved"; ls -t *.id | sed 's/\.id//g' | yad --list \
    --window-icon=idiomind --center --name=Idiomind --borders=8 \
    --text=" $(gettext "Double clik to download") \t\t\t\t" \
    --title="$(gettext "Topics saved")" --width=$wth --height=$eht \
    --column=Nombre:TEXT --print-column=1 --no-headers --class=Idiomind \
    --expand-column=1 --search-column=1 --button=gtk-close:1 \
    --dclick-action="$DS/ifs/upld.sh 'infsd'" >/dev/null 2>&1
    [ "$?" -eq 1 ] & exit
    exit
    
elif [ "$1" = infsd ]; then

    U=$(sed -n 1p $DC_s/5.cfg)
    user=$(echo "$(whoami)")
    source "$DM_t/saved/$2.id"
    lng=$(lnglss $language_source)
    nme=$(echo "$2" | sed 's/ /_/g')
    lnglbl=$(echo $language_target | awk '{print tolower($0)}')
    
        cd $HOME
        sleep 0.5
        sv=$(yad --save --center --borders=10 \
        --on-top --filename="$2.idmnd" \
        --window-icon=idiomind --skip-taskbar --title="Save" \
        --file --width=600 --height=500 --button="Ok":0 )
        ret=$?
        if [ $ret -eq 0 ]; then
            
            internet; cd "$DT"
            source /dev/stdin <<<"$(curl http://idiomind.sourceforge.net/doc/SITE_TMP)"
            [ -z "$DOWNLOADS" ] && msg "$(gettext "The server is not available at the moment.")" dialog-warning && exit
            
            file="$DOWNLOADS/$lng/$lnglbl/$category/$link"
            WGET() {
            rand="$RANDOM `date`"
            pipe="/tmp/pipe.`echo '$rand' | md5sum | tr -d ' -'`"
            mkfifo $pipe
            wget -c "$1" 2>&1 | while read data;do
            if [ "`echo $data | grep '^Length:'`" ]; then
            total_size=`echo $data | grep "^Length:" | sed 's/.*\((.*)\).*/\1/' | tr -d '()'`
            fi
            if [ "`echo $data | grep '[0-9]*%' `" ];then
            percent=`echo $data | grep -o "[0-9]*%" | tr -d '%'`
            echo $percent
            echo "# $(gettext "Downloading...")  $percent%"
            fi
            done > $pipe &
            wget_info=`ps ax |grep "wget.*$1" |awk '{print $1"|"$2}'`
            wget_pid=`echo $wget_info|cut -d'|' -f1 `
            yad --progress --timeout=100 --auto-close --width=200 --height=20 \
            --geometry=200x20-2-2 --no-buttons --skip-taskbar --undecorated --on-top \
            --title="Downloading"< $pipe
            if [ "`ps -A |grep "$wget_pid"`" ];then
            kill $wget_pid
            fi
            rm -f $pipe
            }
            cd /tmp
            [ -f "/tmp/$link" ] && rm -f "/tmp/$link"
            
            WGET "$file"
            
            if [ -f "/tmp/$link" ] ; then
                [ -f "$sv" ] && rm "$sv"
                mv -f "/tmp/$link" "$sv"
            else
                msg "$(gettext "The file is not yet available.\n")" info && exit
            fi
            exit
        else
            exit
        fi
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
lnglbl=$(echo $lgtl | awk '{print tolower($0)}')
U=$(sed -n 1p $DC_s/5.cfg)
[[ -z "$U" ]] && U=$(echo $(($RANDOM%100)))
mail=$(sed -n 2p $DC_s/5.cfg)
user=$(sed -n 3p $DC_s/5.cfg)
[ -z "$user" ] && user=$(echo "$(whoami)")
nt=$(cat "$DC_tlt/10.cfg")
nme=$(echo "$tpc" | sed 's/ /_/g' \
| sed 's/"//g' | sed 's/’//g')
imgm="$DM_tlt/words/images/img.png"

"$DS/ifs/tls.sh" check_index "$tpc"

if [ $(cat "$DC_tlt/0.cfg" | wc -l) -le 20 ]; then
    msg "$(gettext "To upload must be at least 20 items.")\n " info &
    exit
fi

cd $HOME
upld=$(yad --form --width=480 --height=460 --on-top \
--buttons-layout=end --center --window-icon=idiomind \
--borders=15 --name=Idiomind --align=right --class=Idiomind \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "To PDF")":2 \
--button="$(gettext "Upload")":0 \
--title="$(gettext "Upload")" --text="   <b>$tpc</b>" \
--field=" :lbl" "#1" \
--field="    $(gettext "Author")" "$user" \
--field="    $(gettext "Contact (Optional)")" "$mail" \
--field="    $(gettext "Category"):CBE" \
"!$others!$article!$comics!$culture!$documentary!$entertainment!$funny!$family!$grammar!$history!$movies!$in_the_city!$interview!$internet!$music!$nature!$news!$office!$relations!$sport!$science!$shopping!$social_networks!$technology!$travel" \
--field="    $(gettext "Skill Level"):CBE" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
--field="\n$(gettext "Description/Notes"):TXT" "$nt" \
--field="$(gettext "Add image"):FL" "$imgm")
ret=$?

if [ "$ret" = 2 ]; then
    "$DS/ifs/tls.sh" pdfdoc & exit 1
    
elif [ "$ret" = 0 ]; then

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

if [ -z "$Ctgry" ]; then
msg " $(gettext "Please indicates a category.")\n " info
$DS/ifs/upld.sh &
exit 1
fi

internet; cd "$DT"
source /dev/stdin <<<"$(curl http://idiomind.sourceforge.net/doc/SITE_TMP)"
[ -z "$FTPHOST" ] && msg " $(gettext "An error occurred, please try later.")\n " dialog-warning && exit

Author=$(echo "$upld" | cut -d "|" -f2)
Mail=$(echo "$upld" | cut -d "|" -f3)
notes=$(echo "$upld" | cut -d "|" -f6)
img=$(echo "$upld" | cut -d "|" -f7)
link="$U.$tpc.idmnd"

mkdir "$DT/upload"
DT_u="$DT/upload"
mkdir "$DT/upload/$tpc"

cd "$DM_tlt/words/images"
if [ $(ls -1 *.jpg 2>/dev/null | wc -l) != 0 ]; then
images=$(ls *.jpg | wc -l); else
images=0; fi
[ -f "$DC_tlt"/3.cfg ] && words=$(cat "$DC_tlt"/3.cfg | wc -l)
[ -f "$DC_tlt"/4.cfg ] && sentences=$(cat "$DC_tlt"/4.cfg | wc -l)
[ -f "$DC_tlt"/12.cfg ] && date_c=$(cat "$DC_tlt"/12.cfg)
date_u=$(date +%F)

echo -e "name=\"$tpc\"
language_source=\"$lgsl\"
language_target=\"$lgtl\"
author=\"$Author\"
contact=\"$Mail\"
category=\"$Ctgry\"
link=\"$link\"
date_c=\"$date_c\"
date_u=\"$date_u\"
nwords=\"$words\"
nsentences=\"$sentences\"
nimages=\"$images\"
level=\"$level\"" > "$DT_u/$tpc/12.cfg"
cp -f "$DT_u/$tpc/12.cfg" "$DT/12.cfg"
echo -e "$U
$Mail
$Author" > "$DC_s/5.cfg"

if [ "$img" != "$imgm" ]; then
/usr/bin/convert -scale 110x80! "$img" $DT_u/img1.png
convert $DT_u/img1.png -alpha opaque -channel a \
-evaluate set 15% +channel $DT_u/img.png
bo=/usr/share/idiomind/images/bo.png
convert $bo -edge .5 -blur 0x.5 $DT_u/bo_.png
convert $DT_u/img.png \( $DT_u/bo_.png -negate \) \
-geometry +1+1 -compose multiply -composite \
-crop 115x80+1+1 +repage $DT_u/bo_outline.png
convert $DT_u/img.png -crop 115x80+1+1\! \
-background none -flatten +repage \( $bo +matte \) \
-compose CopyOpacity -composite +repage $DT_u/boim.png
convert $DT_u/boim.png \( +clone -channel A -separate +channel \
-negate -background black -virtual-pixel background \
-blur 0x4 -shade 115x21.78 -contrast-stretch 0% +sigmoidal-contrast 7x50% \
-fill grey50 -colorize 10% +clone +swap -compose overlay -composite \) \
-compose In -composite $DT_u/boim1.png
convert $DT_u/boim1.png \( +clone -background Black \
-shadow 30x3+4+4 \) -background none \
-compose DstOver -flatten "$DM_tlt/words/images/img.png" 
cd $DT_u; rm -f *.png
fi

cd "$DM_tlt"
cp -r ./* "$DT_u/$tpc/"
cp -r "./words" "$DT_u/$tpc/"
cp -r "./words/images" "$DT_u/$tpc/words"
mkdir "$DT_u/$tpc/.audio"
while read audio; do
    if [ -f "$DT_u/$tpc/.audio/$audio" ]; then
    cp -f "$DM_tl/.share/$audio" "$DT_u/$tpc/.audio/$audio"; fi
done < "$DC_tlt/5.cfg"
cp -f "$DC_tlt/0.cfg" "$DT_u/$tpc/0.cfg"
cp -f "$DC_tlt/3.cfg" "$DT_u/$tpc/3.cfg"
cp -f "$DC_tlt/4.cfg" "$DT_u/$tpc/4.cfg"
cp -f "$DC_tlt/5.cfg" "$DT_u/$tpc/5.cfg"
printf "$notes" > "$DC_tlt/10.cfg"
printf "$notes" > "$DT_u/$tpc/10.cfg"

cd $DT_u
tar -cvf "$tpc.tar" "$tpc"
gzip -9 "$tpc.tar"
mv "$tpc.tar.gz" "$U.$tpc.idmnd"
[ -d "$DT_u/$tpc" ] && rm -fr "$DT_u/$tpc"
dte=$(date "+%d %B %Y")
notify-send "$(gettext "Please wait while file is uploaded")" "$(gettext "$tpc")" -i idiomind -t 6000

#-----------------------
cd $DT_u
lftp -u $USER,$KEY $FTPHOST << END_SCRIPT
mirror --reverse ./ public_html/$lgs/$lnglbl/$Ctgry/
quit
END_SCRIPT

exit=$?
if [ $exit = 0 ] ; then
    mv -f "$DT/12.cfg" "$DM_t/saved/$tpc.id"
    info="  $tpc\n<b> $(gettext "Was uploaded properly.")</b>\n"
    image=dialog-ok
else
    info=" $(gettext "There was a problem uploading your file.") "
    image=dialog-warning
fi

msg "$info" $image

[ -d "$DT_u/$tpc" ] && rm -fr "$DT_u/$tpc"
[ -f "$DT_u/.aud" ] && rm -f "$DT_u/.aud"
[ -f "$DT_u/$U.$tpc.idmnd" ] && rm -f "$DT_u/$U.$tpc.idmnd"
[ -f "$DT_u/$tpc.tar" ] && rm -f "$DT_u/$tpc.tar"
[ -f "$DT_u/$tpc.tar.gz" ] && rm -f "$DT_u/$tpc.tar.gz"
[ -d "$DT_u" ] && rm -fr "$DT_u"
exit 0
else
exit 1
fi
