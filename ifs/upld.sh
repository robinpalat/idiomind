#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

if [[ $1 = vsd ]]; then

    U=$(sed -n 1p $HOME/.config/idiomind/s/cfg.4)
    lng=$(echo "$lgtl" | awk '{print tolower($0)}')
    wth=$(sed -n 3p $DC_s/cfg.18)
    eht=$(sed -n 4p $DC_s/cfg.18)
    
    cd $DM_t/saved; ls -t *.id | sed 's/\.id//g' | yad --list \
    --window-icon=idiomind --center --skip-taskbar --borders=8 \
    --text=" <small>$(gettext "Double clik to download") \t\t\t\t</small>" \
    --title="$(gettext "Topics saved")" --width=$wth --height=$eht \
    --column=Nombre:TEXT --print-column=1 --no-headers \
    --expand-column=1 --search-column=1 --button="$(gettext "Close")":1 \
    --dclick-action='/usr/share/idiomind/ifs/upld.sh infsd' >/dev/null 2>&1
    [ "$?" -eq 1 ] & exit
    exit
    
elif [[ $1 = infsd ]]; then

    U=$(sed -n 1p $DC_s/cfg.4)
    user=$(echo "$(whoami)")
    source "$DM_t/saved/$2.id"
    [[ $language_source = english ]] && lng=en
    [[ $language_source = french ]] && lng=fr
    [[ $language_source = german ]] && lng=de
    [[ $language_source = chinese ]] && lng=zh-cn
    [[ $language_source = italian ]] && lng=it
    [[ $language_source = japanese ]] && lng=ja
    [[ $language_source = portuguese ]] && lng=pt
    [[ $language_source = spanish ]] && lng=es
    [[ $language_source = vietnamese ]] && lng=vi
    [[ $language_source = russian ]] && lng=ru
    nme=$(echo "$2" | sed 's/ /_/g')
    lnglbl=$(echo $language_target | awk '{print tolower($0)}')
    icon=$DS/images/img.6.png

    yad --borders=10 --width=420 --height=150 \
    --on-top --skip-taskbar --center --image=$icon \
    --title="idiomind" --button="$(gettext "Download")":0 \
    --button="$(gettext "Close")":1 \
    --text="$name\n<small>${language_source^} $language_target </small> \n" \
    --window-icon=idiomind
    ret=$?

        if [ $ret -eq 0 ]; then
            cd $HOME
            sv=$(yad --save --center --borders=10 \
            --on-top --filename="$2.idmnd" \
            --window-icon=idiomind --skip-taskbar --title="Save" \
            --file --width=600 --height=500 --button="Ok":0 )
            ret=$?
            
            internet
            cd $DT
            wget http://idiomind.sourceforge.net/info/SITE_TMP
            source $DT/SITE_TMP && rm -f $DT/SITE_TMP
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
            $yad --progress --timeout=100 --auto-close --width=200 --height=20 \
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
                [[ -f "$sv" ]] && rm "$sv"
                mv -f "/tmp/$link" "$sv"
            else
                msg "$(gettext "The request is not yet available")" info && exit
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
events="$(gettext "Events")"
nature="$(gettext "Nature")"
news="$(gettext "News")"
office"$(gettext "Office")"
relations="$(gettext "Relations")"
sport="$(gettext "Sport")"
social="$(gettext "Social")"
shopping="$(gettext "Shopping")"
technology="$(gettext "Technology")"
travel="$(gettext "Travel")"
lnglbl=$(echo $lgtl | awk '{print tolower($0)}')
U=$(sed -n 1p $DC_s/cfg.4)
mail=$(sed -n 2p $DC_s/cfg.4)
user=$(sed -n 3p $DC_s/cfg.4)
[[ -z "$user" ]] && user=$(echo "$(whoami)")
nt=$(cat "$DC_tlt/cfg.10")
nme=$(echo "$tpc" | sed 's/ /_/g' \
| sed 's/"//g' | sed 's/’//g')

# check index
#------------------------------------------
[[ ! -f "$DC_tlt/cfg.0" ]] && touch "$DC_tlt/cfg.0"
[[ ! -f "$DC_tlt/cfg.1" ]] && touch "$DC_tlt/cfg.1"
[[ ! -f "$DC_tlt/cfg.2" ]] && touch "$DC_tlt/cfg.2"
[[ ! -f "$DC_tlt/cfg.3" ]] && touch "$DC_tlt/cfg.3"
[[ ! -f "$DC_tlt/cfg.4" ]] && touch "$DC_tlt/cfg.4"
[[ ! -f "$DC_tlt/cfg.10" ]] && touch "$DC_tlt/cfg.10"

check_index1 "$DC_tlt/cfg.0" "$DC_tlt/cfg.1" \
"$DC_tlt/cfg.2" "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"

chk0=$(cat "$DC_tlt/cfg.0" | wc -l)
chk1=$(cat "$DC_tlt/cfg.1" | wc -l)
chk2=$(cat "$DC_tlt/cfg.2" | wc -l)
chk3=$(cat "$DC_tlt/cfg.3" | wc -l)
chk4=$(cat "$DC_tlt/cfg.4" | wc -l)
stts=$(cat "$DC_tlt/cfg.8")
mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
| sort -k 1n,1 -k 7 | wc -l)"

# fix index
#------------------------------------------
if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
|| $mp3s != $chk0 || $stts = 13 ]]; then
    sleep 1
    notify-send -i idiomind "$(gettext "Index error")" "$(gettext "fixing...")" -t 3000 &
    > $DT/ps_lk
    [ -d "$DM_tlt/.conf" ] && mkdir "$DM_tlt/.conf"
    DC_tlt="$DM_tlt/.conf"
    cd "$DM_tlt/words/"
    for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
    if [ -f ".mp3" ]; then rm ".mp3"; fi
    cd "$DM_tlt/"
    for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
    if [ -f ".mp3" ]; then rm ".mp3"; fi
    cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
    | sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
    | sed s'|\.\/||'g | sed s'|\.mp3||'g > $DT/index


    if ([ -f "$DC_tlt/.cfg.11" ] && \
    [ -n "$(cat "$DC_tlt/.cfg.11")" ]); then
    index="$DC_tlt/.cfg.11"
    echo ok
    else
    index="$DT/index"
    fi

    while read name; do

        sfname="$(nmfile "$name")"
        wfname="$(nmfile "$name")"

        if [ -f "$DM_tlt/$name.mp3" ]; then
            tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
            trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
            xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
            [ "$name" != "$xname" ] && \
            mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
            echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
            echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
        elif [ -f "$DM_tlt/$sfname.mp3" ]; then
            tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
            trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
            xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
            [ "$sfname" != "$xname" ] && \
            mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
            echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
            echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
        elif [ -f "$DM_tlt/words/$name.mp3" ]; then
            tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
            trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
            xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
            [ "$name" != "$xname" ] && \
            mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
            echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
            echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
        elif [ -f "$DM_tlt/words/$wfname.mp3" ]; then
            tgs="$(eyeD3 "$DM_tlt/words/$wfname.mp3")"
            trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
            xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
            [ "$wfname" != "$xname" ] \
            && mv -f "$DM_tlt/words/$wfname.mp3" "$DM_tlt/words/$xname.mp3"
            echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
            echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
        fi
        
    done < "$index"

    mv -f "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.0"
    mv -f "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.3"
    mv -f "$DC_tlt/cfg.4.tmp" "$DC_tlt/cfg.4"
    cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"
    cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
    check_index1 "$DC_tlt/cfg.0" "$DC_tlt/cfg.1" \
    "$DC_tlt/cfg.2" "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"
    [[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
fi

if [ $? -ne 0 ]; then
    msg " $files_err\n\n" error & exit 1
fi

if [ $(cat "$DC_tlt/cfg.0" | wc -l) -le 20 ]; then
    msg "$(gettext "To upload must be at least 20 items.")\n " info &
    exit
fi

cd $HOME
upld=$($yad --form --width=420 --height=460 --on-top \
--buttons-layout=end --center --window-icon=idiomind \
--borders=15 --skip-taskbar --align=right \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "Upload")":0 \
--title="$(gettext "Upload")" --text="   <b>$tpc</b>" \
--field=" :lbl" "#1" \
--field="    <small>$(gettext "Author")</small>" "$user" \
--field="    <small>$(gettext "Contact (Optional)")</small>" "$mail" \
--field="    <small>$(gettext "Category")</small>:CB" \
"!$others!$comics!$culture!$entertainment!$family!$grammar!$history!$movies!$in_the_city!$internet!$music!$nature!$news!$office!$relations!$sport!$shopping!$social!$technology!$travel" \
--field="    <small>$(gettext "Skill Level")</small>:CB" "!$(gettext "Beginner")!$(gettext "Intermediate")!$(gettext "Advanced")" \
--field="<small>\n$(gettext "Description/Notes")</small>:TXT" "$nt" \
--field="<small>$(gettext "Add image")</small>:FL")
ret=$?

if [[ "$ret" != 0 ]]; then
    exit 1
fi

Ctgry=$(echo "$upld" | cut -d "|" -f4)
[[ $Ctgry = $others ]] && Ctgry=others
[[ $Ctgry = $comics ]] && Ctgry=comics
[[ $Ctgry = $culture ]] && Ctgry=culture
[[ $Ctgry = $family ]] && Ctgry=family
[[ $Ctgry = $entertainment ]] && Ctgry=entertainment
[[ $Ctgry = $grammar ]] && Ctgry=grammar
[[ $Ctgry = $history ]] && Ctgry=history
[[ $Ctgry = $documentary ]] && Ctgry=documentary
[[ $Ctgry = $in_the_city ]] && Ctgry=in_the_city
[[ $Ctgry = $movies ]] && Ctgry=movies
[[ $Ctgry = $internet ]] && Ctgry=internet
[[ $Ctgry = $music ]] && Ctgry=music
[[ $Ctgry = $events ]] && Ctgry=events
[[ $Ctgry = $nature ]] && Ctgry=nature
[[ $Ctgry = $news ]] && Ctgry=news
[[ $Ctgry = $office ]] && Ctgry=office
[[ $Ctgry = $relations ]] && Ctgry=relations
[[ $Ctgry = $sport ]] && Ctgry=sport
[[ $Ctgry = $social ]] && Ctgry=social
[[ $Ctgry = $shopping ]] && Ctgry=shopping
[[ $Ctgry = $technology ]] && Ctgry=technology
[[ $Ctgry = $travel ]] && Ctgry=travel

level=$(echo "$upld" | cut -d "|" -f5)
[[ $level = $beginner ]] && level=1
[[ $level = $intermediate ]] && level=2
[[ $level = $advanced ]] && level=3

if [ -z $Ctgry ]; then
msg " $(gettext "Please indicates a category.")\n " info
$DS/ifs/upld.sh &
exit 1
fi

internet

cd $DT
wget http://idiomind.sourceforge.net/info/SITE_TMP
source $DT/SITE_TMP && rm -f $DT/SITE_TMP
[[ -z "$FTPHOST" ]] && msg " $(gettext "An error occurred, please try later.")\n " dialog-warning && exit

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
    images=$(ls *.jpg | wc -l)
else
    images=0
fi
[[ -f "$DC_tlt"/cfg.3 ]] && words=$(cat "$DC_tlt"/cfg.3 | wc -l)
[[ -f "$DC_tlt"/cfg.4 ]] && sentences=$(cat "$DC_tlt"/cfg.4 | wc -l)
[[ -f "$DC_tlt"/cfg.12 ]] && date_c=$(cat "$DC_tlt"/cfg.12)
date_u=$(date +%F)

echo '
name="01"
language_source="02"
language_target="03"
author="04"
contact="05"
category="06"
link="07"
date_c="08"
date_u="09"
nwords="10"
nsentences="11"
nimages="12"
level=13
' > "$DT_u/$tpc/cfg.12"

sed -i "s/01/$tpc/g" "$DT_u/$tpc/cfg.12"
sed -i "s/02/$lgsl/g" "$DT_u/$tpc/cfg.12"
sed -i "s/03/$lgtl/g" "$DT_u/$tpc/cfg.12"
sed -i "s/04/$Author/g" "$DT_u/$tpc/cfg.12"
sed -i "s/05/$Mail/g" "$DT_u/$tpc/cfg.12"
sed -i "s/06/$Ctgry/g" "$DT_u/$tpc/cfg.12"
sed -i "s/07/$link/g" "$DT_u/$tpc/cfg.12"
sed -i "s/08/$date_c/g" "$DT_u/$tpc/cfg.12"
sed -i "s/09/$date_u/g" "$DT_u/$tpc/cfg.12"
sed -i "s/10/$words/g" "$DT_u/$tpc/cfg.12"
sed -i "s/11/$sentences/g" "$DT_u/$tpc/cfg.12"
sed -i "s/12/$images/g" "$DT_u/$tpc/cfg.12"
sed -i "s/13/$level/g" "$DT_u/$tpc/cfg.12"
cp -f "$DT_u/$tpc/cfg.12" "$DT/cfg.12"

echo "$U" > $DC_s/cfg.4
echo "$Mail" >> $DC_s/cfg.4
echo "$Author" >> $DC_s/cfg.4

if [ -f "$img" ]; then
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
    cp -f "$DM_tl/.share/$audio" "$DT_u/$tpc/.audio/$audio"
done < "$DC_tlt/cfg.5"
cp -f "$DC_tlt/cfg.0" "$DT_u/$tpc/cfg.0"
cp -f "$DC_tlt/cfg.3" "$DT_u/$tpc/cfg.3"
cp -f "$DC_tlt/cfg.4" "$DT_u/$tpc/cfg.4"
cp -f "$DC_tlt/cfg.5" "$DT_u/$tpc/cfg.5"
printf "$notes" > "$DC_tlt/cfg.10"
printf "$notes" > "$DT_u/$tpc/cfg.10"

cd $DT_u
tar -cvf "$tpc.tar" "$tpc"
gzip -9 "$tpc.tar"
mv "$tpc.tar.gz" "$U.$tpc.idmnd"
[[ -d "$DT_u/$tpc" ]] && rm -fr "$DT_u/$tpc"
dte=$(date "+%d %B %Y")
notify-send "$(gettext "Uploading")" "$(gettext "Wait...")" -i idiomind -t 6000

#-----------------------
cd $DT_u
chmod 775 -R $DT_u
lftp -u $USER,$KEY $FTPHOST << END_SCRIPT
mirror --reverse ./ public_html/$lgs/$lnglbl/$Ctgry/
quit
END_SCRIPT

exit=$?
if [[ $exit = 0 ]] ; then
    mv -f "$DT/cfg.12" "$DM_t/saved/$tpc.id"
    info="  $tpc\n\n<b> $(gettext "Was uploaded properly.")</b>\n"
    image=dialog-ok
else
    info=" $(gettext "There was a problem uploading your file.") "
    image=dialog-warning
fi

msg "$info" $image

[[ -d "$DT_u/$tpc" ]] && rm -fr "$DT_u/$tpc"
[[ -f "$DT_u/SITE_TMP" ]] && rm -f "$DT_u/SITE_TMP"
[[ -f "$DT_u/.aud" ]] && rm -f "$DT_u/.aud"
[[ -f "$DT_u/$U.$tpc.idmnd" ]] && rm -f "$DT_u/$U.$tpc.idmnd"
[[ -f "$DT_u/$tpc.tar" ]] && rm -f "$DT_u/$tpc.tar"
[[ -f "$DT_u/$tpc.tar.gz" ]] && rm -f "$DT_u/$tpc.tar.gz"
[[ -d "$DT_u" ]] && rm -fr "$DT_u"

exit
