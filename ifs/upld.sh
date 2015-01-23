#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/upld.conf

if [[ $1 = vsd ]]; then
	U=$(sed -n 1p $HOME/.config/idiomind/s/cfg.4)
	lng=$(echo "$lgtl" |  awk '{print tolower($0)}')
	wth=$(sed -n 4p $DC_s/cfg.18)
	eht=$(sed -n 3p $DC_s/cfg.18)
	cd $DM_t/saved
	ls -t *.cfg.12 > ls
	(sed -i 's/\.cfg.12//g' ./ls)
	cat ./ls | $yad --list \
	--window-icon=idiomind --center --skip-taskbar --borders=8 \
	--text=" <small>$double_click_for_download \\t\\t\\t\\t</small>" \
	--title="$topics_saved" --width=$wth --height=$eht \
	--column=Nombre:TEXT --print-column=1 \
	--expand-column=1 --search-column=1 \
	--button="$close":1 \
	--dclick-action='/usr/share/idiomind/ifs/upld.sh infsd'
			["$?" -eq 0 ]
				killall topic.sh
				rm $DT/lista
			[ "$?" -eq 1 ] & exit
	exit 1
	
elif [[ $1 = infsd ]]; then
	echo "$2"
	cd $DM_t/saved
	U=$(sed -n 1p $DC_s/cfg.4)
	user=$(echo "$(whoami)")
	tpcd="$2"
	source "./$tpcd.cfg.12"
	[[ $language_target = English ]] && lng=en
	[[ $language_target = French ]] && lng=fr
	[[ $language_target = German ]] && lng=de
	[[ $language_target = Chinese ]] && lng=zn-cn
	[[ $language_target = Italian ]] && lng=it
	[[ $language_target = Japanese ]] && lng=ja
	[[ $language_target = Portuguese ]] && lng=pt
	[[ $language_target = Spanish ]] && lng=es
	[[ $language_target = Vietnamese ]] && lng=vi
	[[ $language_target = Russian ]] && lng=ru
	nme=$(echo "$tpcd" | sed 's/ /_/g')
	lnglbl=$(echo $language_target | awk '{print tolower($0)}')
	icon=$DS/images/img6.png

	yad --borders=10 --width=400 --height=160 \
	--on-top --skip-taskbar --center --image=$icon \
	--title="idiomind" --button="$download:0" --button="Close:1" \
	--text="<b>$name</b>\\n<small>$language_source <b>></b> $language_target </small> \\n" \
	--window-icon=idiomind
		ret=$?

		if [ $ret -eq 2 ]; then
			xdg-open "$LNK"
		exit 1

		elif [ $ret -eq 0 ]; then
			sv=$(yad --save --center --borders=10 \
			--on-top --filename="$tpcd.idmnd" \
			--window-icon=idiomind --skip-taskbar --title="Save" \
			--file --width=600 --height=500 --button="Ok":0 )
			ret=$?
			
			curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
			yad --window-icon=idiomind --on-top \
			--image="info" --name=idiomind \
			--text="  $conn_err  \\n" \
			--image-on-top --center --sticky \
			--width=320 --height=100 --borders=5 \
			--skip-taskbar --title="Idiomind" \
			--button="  Ok  ":0 >&2; exit 1;}
			cd $DT
			wget http://idiomind.sourceforge.net/info/SITE_TMP
			source $DT/SITE_TMP && rm -f $DT/SITE_TMP
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
			echo "# $downloading...  $percent%"
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
			[ -f "/tmp/$U.$tpcd.idmnd" ] && rm -f "/tmp/$U.$tpcd.idmnd"
			
			WGET "$file"
			
			if [ -f "/tmp/$U.$tpcd.idmnd" ] ; then
				[[ -f "$sv" ]] && rm "$sv"
				mv -f "/tmp/$U.$tpcd.idmnd" "$sv"
			else
				yad --fixed --name=idiomind --center \
				--image=dialog-warning --text="$file_err" \
				--fixed --sticky --width=320 --height=140 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--on-top --title="Idiomind" \
				--button="Ok":0 && exit 1
			fi
			exit 1
		else
			exit 1
		fi
fi

lnglbl=$(echo $lgtl | awk '{print tolower($0)}')
user=$(echo "$(whoami)")
U=$(sed -n 1p $DC_s/cfg.4)
mail=$(sed -n 2p $DC_s/cfg.4)
skp=$(sed -n 3p $DC_s/cfg.4)
nt=$(cat "$DC_tlt/cfg.10")
nme=$(echo "$tpc" | sed 's/ /_/g' \
| sed 's/"//g' | sed 's/’//g')
#[[ $(echo "$tpc" | wc -c) -gt 40 ]] \
#&& ttpc="${tpc:0:40}..." || ttpc="$tpc"


chk1="$DC_tlt/cfg.0"
chk2="$DC_tlt/cfg.1"
chk3="$DC_tlt/cfg.2"
chk4="$DC_tlt/cfg.3"
chk5="$DC_tlt/cfg.4"
chk6="$DC_tlt/cfg.10"

if [[ -z "$cat chk1" ]]; then
	cp -f "$DC_tlt/cfg.0~" "$DC_tlt/cfg.0"
fi
if [[ -z "$cat chk2" ]]; then
	cp -f "$DC_tlt/cfg.1~" "$DC_tlt/cfg.1"
fi
if [[ -z "$cat chk3" ]]; then
	cp -f "$DC_tlt/cfg.2~" "$DC_tlt/cfg.2"
fi
if [[ -z "$cat chk6" ]]; then
	cp -f "$DC_tlt/.cfg.10~" "$DC_tlt/cfg.10"
fi

if [ -n "$(cat "$chk1" | sort -n | uniq -dc)" ]; then
	cat "$chk1" | awk '!array_temp[$0]++' > $DT/ls0.x
	sed '/^$/d' $DT/ls0.x > "$chk1"
fi
if [ -n "$(cat "$chk2" | sort -n | uniq -dc)" ]; then
	cat "$chk2" | awk '!array_temp[$0]++' > $DT/ls1.x
	sed '/^$/d' $DT/ls1.x > "$chk2"
fi
if [ -n "$(cat "$chk3" | sort -n | uniq -dc)" ]; then
	cat "$chk3" | awk '!array_temp[$0]++' > $DT/ls2.x
	sed '/^$/d' $DT/ls2.x > "$chk3"
fi
if [ -n "$(cat "$chk4" | sort -n | uniq -dc)" ]; then
	cat "$chk4" | awk '!array_temp[$0]++' > $DT/ls1.x
	sed '/^$/d' $DT/ls1.x > "$chk4"
fi
if [ -n "$(cat "$chk5" | sort -n | uniq -dc)" ]; then
	cat "$chk5" | awk '!array_temp[$0]++' > $DT/ls2.x
	sed '/^$/d' $DT/ls2.x > "$chk5"
fi

chk1=$(cat "$DC_tlt/cfg.0" | wc -l)
chk2=$(cat "$DC_tlt/cfg.1" | wc -l)
chk3=$(cat "$DC_tlt/cfg.2" | wc -l)
chk4=$(cat "$DC_tlt/cfg.3" | wc -l)
chk5=$(cat "$DC_tlt/cfg.4" | wc -l)
stts=$(cat "$DC_tlt/cfg.8")

if [[ $(($chk4 + $chk5)) != $chk1 \
|| $(($chk2 + $chk3)) != $chk1 || $stts = 13 ]]; then
	sleep 1
	notify-send -i idiomind "$index_err1" "$index_err2" -t 3000 &
	
	rm -f $DT/ind $DT/ind_ok
	
	cd "$DM_tl/$topic"
	for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	ls *.mp3 | sed 's/.mp3//g' > $DT/ind
		
	cd "$DM_tl/$topic/words/"
	for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	ls *.mp3 | sed 's/.mp3//g' >> $DT/ind
	
	rm "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"
	
	if [[ -f "$DC_tlt/.cfg.11" ]]; then
	
		cp -f "$DC_tlt/.cfg.11" "$DC_tlt/cfg.0"
		n=1
		while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
		
			chk1=$(sed -n "$n"p "$DC_tlt/cfg.0")
			if cat "$DT/ind" | grep -Fxo "$chk1"; then
					if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
						echo "$chk1" >> "$DC_tlt/cfg.3"
					elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
						echo "$chk1" >> "$DC_tlt/cfg.4"
					fi
				echo "$chk1" >> $DT/ind_ok
				grep -v -x -v "$chk1" $DT/ind > $DT/ind_
				sed '/^$/d' $DT/ind_ > $DT/ind
			fi
			let n++
		done
	else
		n=1
		while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
		
			chk1=$(sed -n "$n"p "$DT/ind")
				if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
					echo "$chk1" >> "$DC_tlt/cfg.3"
				elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
					echo "$chk1" >> "$DC_tlt/cfg.4"
				fi
				echo "$chk1" >> $DT/ind_ok
			let n++
		done
	fi
	
	if [ $? -ne 0 ]; then
		yad --name=idiomind --image=error --button=gtk-ok:1\
		--text=" $files_err\n\n" --image-on-top --sticky  \
		--width=380 --height=120 --borders=5 --title=Idiomind \
		--skip-taskbar --center --window-icon=idiomind
		$DS/mngr.sh dlt & exit
	fi
	
	n=1
	while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
		chk2=$(sed -n "$n"p "$DT/ind")
		if [[ "$(echo "$chk2" | wc -w)" -eq 1 ]]; then
			echo "$chk2" >> "$DC_tlt/cfg.3"
		elif [[ "$(echo "$chk2" | wc -w)" -gt 1 ]]; then
			echo "$chk2" >> "$DC_tlt/cfg.4"
		fi
		let n++
	done

	cat $DT/ind >> $DT/ind_ok
	cp -f $DT/ind_ok "$DC_tlt/cfg.0"
	rm "$DC_tlt/cfg.2"
	in1="$DC_tlt/cfg.0"
	if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
		cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in1"
	fi
	in2="$DC_tlt/cfg.4"
	if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
		cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in2"
	fi
	in3="$DC_tlt/cfg.4"
	if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
		cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in3"
	fi
	cp -f "$in1" "$DC_tlt/cfg.1"
	
	if [[ $stts = "13" ]]; then
		if cat "$DC_tl/.cfg.3" | grep -Fxo "$topic"; then
			echo "6" > "$DC_tlt/cfg.8"
		elif cat "$DC_tl/.cfg.2" | grep -Fxo "$topic"; then
			echo "1" > "$DC_tlt/cfg.8"
		fi
	fi
fi

cd "$DM_tlt"
MP3=$(ls *.mp3 | wc -l)
WORDS=$(ls ./words/*.mp3 | wc -l)
function suma(){
 let ALL=$MP3+$WORDS
}
suma
if [ $ALL -le 15 ]; then
	cstn=$($yad --image=info --on-top \
	--text=" $min_items\\n " --window-icon=idiomind \
	--image-on-top --center --sticky --name=idiomind \
	--width=320 --height=100 --borders=5 \
	--skip-taskbar --title="Idiomind" \
	--button="Ok:0")
	exit 1
fi
cd $HOME
upld=$($yad --form --width=400 --height=420 --on-top \
--buttons-layout=end --center --window-icon=idiomind \
--borders=15 --skip-taskbar --align=right \
--button=$cancel:1 --button=$upload:0 \
--title="Upload" --text="   <b>$tpc</b>" \
--field=" :lbl" "#1" \
--field="    <small>$author</small>:: " "$user" \
--field="    <small>$email</small>:: " "$mail" \
--field="    <small>$category</small>::CB" \
"!$others!$comics!$culture!$entertainment!$family!$grammar!$history!$films!$in_the_city!$internet!$music!$nature!$news!$office!$relations!$sport!$shopping!$social!$technology!$travel" \
--field="    <small>$level</small>::CB" "!$beginner!$intermediate!$advanced" \
--field="<small>\\n$notes:</small>:TXT" "$nt" \
--field="<small>$add_image</small>:FL")
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
[[ $Ctgry = $family ]] && Ctgry=family
[[ $Ctgry = $grammar ]] && Ctgry=grammar
[[ $Ctgry = $history ]] && Ctgry=history
[[ $Ctgry = $documentary ]] && Ctgry=documentary
[[ $Ctgry = $in_the_city ]] && Ctgry=in_the_city
[[ $Ctgry = $films ]] && Ctgry=films
[[ $Ctgry = $internet ]] && Ctgry=internet
[[ $Ctgry = $music ]] && Ctgry=music
[[ $Ctgry = $events ]] && Ctgry=events
[[ $Ctgry = $nature ]] && Ctgry=nature
[[ $Ctgry = $news ]] && Ctgry=news
[[ $Ctgry = $relations ]] && Ctgry=relations
[[ $Ctgry = $sport ]] && Ctgry=sport
[[ $Ctgry = $shopping ]] && Ctgry=shopping
[[ $Ctgry = $technology ]] && Ctgry=technology
[[ $Ctgry = $travel ]] && Ctgry=travel

level=$(echo "$upld" | cut -d "|" -f5)
[[ $level = $beginner ]] && level=1
[[ $level = $intermediate ]] && level=2
[[ $level = $advanced ]] && level=3

if [ -z $Ctgry ]; then
yad --window-icon=idiomind \
--image=info --on-top --name=idiomind \
--text="  $categry_err\\n  " \
--image-on-top --center --sticky \
--width=320 --height=100 --borders=5 \
--skip-taskbar --title="Idiomind" \
--button="  Ok  ":0
$DS/ifs/upld.sh &
exit 1
fi

curl -v www.google.com 2>&1 | \
grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
yad --window-icon=idiomind --on-top \
--image="info" --name=idiomind \
--text="  $conn_err  \\n" \
--image-on-top --center --sticky \
--width=320 --height=100 --borders=5 \
--skip-taskbar --title=Idiomind \
--button="  Ok  ":0
 >&2; exit 1;}

cd $DT
wget http://idiomind.sourceforge.net/info/SITE_TMP
source $DT/SITE_TMP && rm -f $DT/SITE_TMP

if [ -z "$FTPHOST" ]; then
yad --window-icon=idiomind --name=idiomind \
--image=dialog-warning --on-top \
--text=" $site_err\\n " \
--image-on-top --center --sticky \
--width=320 --height=100 --borders=5 \
--skip-taskbar --title="Idiomind" \
--button="  Ok  ":0 &
exit 1
fi

Author=$(echo "$upld" | cut -d "|" -f2)
Mail=$(echo "$upld" | cut -d "|" -f3)
notes=$(echo "$upld" | cut -d "|" -f6)
img=$(echo "$upld" | cut -d "|" -f7)
link="$U.$tpc.idmnd"

mkdir "$DT/$nme"
mkdir "$DT/$tpc"

cd "$DM_tlt/words/images"
if [ $(ls -1 *.jpg 2>/dev/null | wc -l) != 0 ]; then
	images=$(ls *.jpg | wc -l)
else
	images=0
fi
[[ -f "$DC_tlt"/cfg.3 ]] && words=$(cat "$DC_tlt"/cfg.3 | wc -l)
[[ -f "$DC_tlt"/cfg.4 ]] && sentences=$(cat "$DC_tlt"/cfg.4 | wc -l)
[[ -f "$DM_tlt"/cfg.12 ]] && date_c=$(cat "$DM_tlt"/cfg.12)
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
' > "$DT/cfg.12"

sed -i "s/01/$tpc/g" "$DT/cfg.12"
sed -i "s/02/$lgsl/g" "$DT/cfg.12"
sed -i "s/03/$lgtl/g" "$DT/cfg.12"
sed -i "s/04/$Author/g" "$DT/cfg.12"
sed -i "s/05/$Mail/g" "$DT/cfg.12"
sed -i "s/06/$Ctgry/g" "$DT/cfg.12"
sed -i "s/07/$link/g" "$DT/cfg.12"
sed -i "s/08/$date_c/g" "$DT/cfg.12"
sed -i "s/09/$date_u/g" "$DT/cfg.12"
sed -i "s/10/$words/g" "$DT/cfg.12"
sed -i "s/11/$sentences/g" "$DT/cfg.12"
sed -i "s/12/$images/g" "$DT/cfg.12"
sed -i "s/13/$level/g" "$DT/cfg.12"

echo "$U" > $DC_s/cfg.4
echo "$Mail" >> $DC_s/cfg.4

if [[ -f "$img" ]]; then
/usr/bin/convert -scale 120x90! "$img" $DT/img1.png
convert $DT/img1.png -alpha opaque -channel a \
-evaluate set 15% +channel $DT/img.png
bo=/usr/share/idiomind/images/bo.png
convert $bo -edge .5 -blur 0x.5 $DT/bo_.png
convert $DT/img.png \( $DT/bo_.png -negate \) \
-geometry +1+1 -compose multiply -composite \
-crop 120x90+1+1 +repage $DT/bo_outline.png
convert $DT/img.png -crop 120x90+1+1\! \
-background none -flatten +repage \( $bo +matte \) \
-compose CopyOpacity -composite +repage $DT/boim.png
convert $DT/boim.png \( +clone -channel A -separate +channel \
-negate -background black -virtual-pixel background \
-blur 0x4 -shade 110x21.78 -contrast-stretch 0% +sigmoidal-contrast 7x50% \
-fill grey50 -colorize 10% +clone +swap -compose overlay -composite \) \
-compose In -composite $DT/boim1.png
convert $DT/boim1.png \( +clone -background Black \
-shadow 30x3+4+4 \) -background none \
-compose DstOver -flatten "$DM_tlt/words/images/img.png" 
fi

cd "$DM_tlt"
cp -r ./* "$DT/$tpc/"
cp -r "./words" "$DT/$tpc/"
cp -r "./words/images" "$DT/$tpc/words"
mkdir "$DT/$tpc/.audio"

n=1
while [ $n -le $(cat "$DC_tlt/cfg.5" | wc -l) ]; do
	cp=$(sed -n "$n"p "$DC_tlt/cfg.5")
	cp "$DM_tl/.share/$cp" "$DT/$tpc/.audio/$cp"
	let n++
done

cp -f "$DT/cfg.12" "$DT/$tpc/cfg.12"
cp -f "$DC_tlt/cfg.0" "$DT/$tpc/cfg.0"
cp -f "$DC_tlt/cfg.3" "$DT/$tpc/cfg.3"
cp -f "$DC_tlt/cfg.4" "$DT/$tpc/cfg.4"
cp -f "$DC_tlt/cfg.5" "$DT/$tpc/cfg.5"
#cp -f "$DC_tlt/cfg.10" "$DT/$tpc/cfg.10"
printf "$notes" > "$DC_tlt/cfg.10"
printf "$notes" > "$DT/$tpc/cfg.10"

cd $DT
tar -cvf "$tpc.tar" "$tpc"
gzip -9 "$tpc.tar"
mv "$tpc.tar.gz" "$U.$tpc.idmnd"
[[ -d "$DT/$tpc" ]] && rm -fr "$DT/$tpc"/.*
dte=$(date "+%d %B %Y")
mv -f "$DT/$U.$tpc.idmnd" "$DT/$nme/"

notify-send "$uploading..." "$wait" -i idiomind -t 6000

#-----------------------
#ftp
rm -f $DT/SITE_TMP
cd $DT/$nme
cp -f $DS/default/index.php ./.index.php
chmod 775 -R $DT/$nme
lftp -u $USER,$KEY $FTPHOST << END_SCRIPT
mirror --reverse ./ public_html/$lgs/$lnglbl/$Ctgry/
quit
END_SCRIPT


exit=$?

if [ $exit = 0 ] ; then
[[ $(echo "$tpc" | wc -c) -gt 40 ]] && tpc="${tpc:0:40}..."
cp -f "$DT/cfg.12" "$DM_t/saved/$tpc.cfg.12"
info="  $tpc\n\n<b> $saved</b>\n"
image=dialog-ok
else
info=" $upload_err"
image=dialog-warning
fi

yad --window-icon=idiomind --name=idiomind \
--image=$image --on-top --text="$info" \
--image-on-top --center --sticky \
--width=380 --height=150 --borders=5 \
--skip-taskbar --title=idiomind \
--button="  Ok  ":0

[[ -d "$DT/$nme" ]] && rm -fr "$DT/$nme"
[[ -d "$DT/$tpc" ]] && rm -fr "$DT/$tpc"
[[ -f "$DT/SITE_TMP" ]] && rm -f "$DT/SITE_TMP"
[[ -f "$DT/.aud" ]] && rm -f "$DT/.aud"
[[ -f "$DT/$U.$tpc.idmnd" ]] && rm -f "$DT/$U.$tpc.idmnd"
[[ -f "$DT/$tpc.tar" ]] && rm -f "$DT/$tpc.tar"
[[ -f "$DT/$tpc.tar.gz" ]] && rm -f "$DT/$tpc.tar.gz"
[[ -d "$DT/$nme" ]] && rm -fr "$DT/$nme"
[[ -d "$DT" ]] && rm -f "$DT/*.png"

exit
