#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/upld.conf
source $DS/ifs/mods/cmns.sh

if [[ $1 = vsd ]]; then

	U=$(sed -n 1p $HOME/.config/idiomind/s/cfg.4)
	lng=$(echo "$lgtl" |  awk '{print tolower($0)}')
	wth=$(sed -n 3p $DC_s/cfg.18)
	eht=$(sed -n 4p $DC_s/cfg.18)
	
	cd $DM_t/saved; ls -t *.id | sed 's/\.id//g' | yad --list \
	--window-icon=idiomind --center --skip-taskbar --borders=8 \
	--text=" <small>$double_click_for_download \t\t\t\t</small>" \
	--title="$topics_saved" --width=$wth --height=$eht \
	--column=Nombre:TEXT --print-column=1 --no-headers \
	--expand-column=1 --search-column=1 --button="$close":1 \
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
	--title="idiomind" --button="$download:0" --button="Close:1" \
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
			[[ -z "$DOWNLOADS" ]] && msg "$err_link" dialog-warning && exit
			
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
			[ -f "/tmp/$link" ] && rm -f "/tmp/$link"
			
			WGET "$file"
			
			if [ -f "/tmp/$link" ] ; then
				[[ -f "$sv" ]] && rm "$sv"
				mv -f "/tmp/$link" "$sv"
			else
				msg "$file_err" info && exit
			fi
			exit
		else
			exit
		fi
fi

lnglbl=$(echo $lgtl | awk '{print tolower($0)}')
U=$(sed -n 1p $DC_s/cfg.4)
mail=$(sed -n 2p $DC_s/cfg.4)
user=$(sed -n 3p $DC_s/cfg.4)
[[ -z "$user" ]] && user=$(echo "$(whoami)")
nt=$(cat "$DC_tlt/cfg.10")
nme=$(echo "$tpc" | sed 's/ /_/g' \
| sed 's/"//g' | sed 's/’//g')

# check index
[[ ! -f "$DC_tlt/cfg.0" ]] && touch "$DC_tlt/cfg.0"
chk1="$DC_tlt/cfg.0"
[[ ! -f "$DC_tlt/cfg.1" ]] && touch "$DC_tlt/cfg.1"
chk2="$DC_tlt/cfg.1"
[[ ! -f "$DC_tlt/cfg.2" ]] && touch "$DC_tlt/cfg.2"
chk3="$DC_tlt/cfg.2"
[[ ! -f "$DC_tlt/cfg.3" ]] && touch "$DC_tlt/cfg.3"
chk4="$DC_tlt/cfg.3"
[[ ! -f "$DC_tlt/cfg.4" ]] && touch "$DC_tlt/cfg.4"
chk5="$DC_tlt/cfg.4"
[[ ! -f "$DC_tlt/cfg.10" ]] && touch "$DC_tlt/cfg.10"
chk6="$DC_tlt/cfg.10"

if [ -n "$(cat "$chk1" | sort -n | uniq -dc)" ]; then
	cat "$chk1" | awk '!array_temp[$0]++' > $DT/ls0.x
	sed '/^$/d' $DT/ls0.x > "$chk1"; fi
if [ -n "$(cat "$chk2" | sort -n | uniq -dc)" ]; then
	cat "$chk2" | awk '!array_temp[$0]++' > $DT/ls1.x
	sed '/^$/d' $DT/ls1.x > "$chk2"; fi
if [ -n "$(cat "$chk3" | sort -n | uniq -dc)" ]; then
	cat "$chk3" | awk '!array_temp[$0]++' > $DT/ls2.x
	sed '/^$/d' $DT/ls2.x > "$chk3"; fi
if [ -n "$(cat "$chk4" | sort -n | uniq -dc)" ]; then
	cat "$chk4" | awk '!array_temp[$0]++' > $DT/ls1.x
	sed '/^$/d' $DT/ls1.x > "$chk4"; fi
if [ -n "$(cat "$chk5" | sort -n | uniq -dc)" ]; then
	cat "$chk5" | awk '!array_temp[$0]++' > $DT/ls2.x
	sed '/^$/d' $DT/ls2.x > "$chk5"; fi

chk1=$(cat "$DC_tlt/cfg.0" | wc -l)
chk2=$(cat "$DC_tlt/cfg.1" | wc -l)
chk3=$(cat "$DC_tlt/cfg.2" | wc -l)
chk4=$(cat "$DC_tlt/cfg.3" | wc -l)
chk5=$(cat "$DC_tlt/cfg.4" | wc -l)
stts=$(cat "$DC_tlt/cfg.8")
mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
| sort -k 1n,1 -k 7 | wc -l)"

# fix index
if [[ $(($chk4 + $chk5)) != $chk1 || $(($chk2 + $chk3)) != $chk1 \
|| $mp3s != $chk1 || $stts = 13 ]]; then
	sleep 1
	notify-send -i idiomind "$index_err1" "$index_err2" -t 3000 &
	> $DT/ps_lk
	cd "$DM_tlt/words/"
	for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	cd "$DM_tlt/"
	for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
	| sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
	| sed s'|\.\/||'g | sed s'|\.mp3||'g > $DT/index
	
	touch "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.4.tmp"
	
	if ([ -f "$DC_tlt/.cfg.11" ] && \
	[ -n $(cat "$DC_tlt/.cfg.11") ]); then
	index="$DC_tlt/.cfg.11"
	else
	index="$DT/index"
	fi

	n=1
	while [ $n -le $(cat "$index" | wc -l) ]; do
	
		name="$(sed -n "$n"p "$index")"
		sfname="$(nmfile "$name")"
		wfname="$(nmfile "$name")"

		if [ -f "$DM_tlt/$name.mp3" ]; then
			tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
			trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
			xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
			mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
			echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
			echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
		elif [ -f "$DM_tlt/$sfname.mp3" ]; then
			tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
			trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
			xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
			mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
			echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
			echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
		elif [ -f "$DM_tlt/words/$name.mp3" ]; then
			tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
			trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
			xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
			mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
			echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
			echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
		elif [ -f "$DM_tlt/words/$wfname.mp3" ]; then
			tgs="$(eyeD3 "$DM_tlt/words/$wfname.mp3")"
			trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
			xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
			mv -f "$DM_tlt/words/$wfname.mp3" "$DM_tlt/words/$xname.mp3"
			echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
			echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
		fi
		let n++
	done

	cp -f "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.0"
	cp -f "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.3"
	cp -f "$DC_tlt/cfg.4.tmp" "$DC_tlt/cfg.4"
	cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"
	rm "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.4.tmp"
	
	if [ $? -ne 0 ]; then
		[[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
		msg " $files_err\n\n" error & exit 1
	fi
	
	in0="$DC_tlt/cfg.0"
	if [ -n "$(cat "$in0" | sort -n | uniq -dc)" ]; then
		cat "$in0" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in0"; fi
	in1="$DC_tlt/cfg.1"
	if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
		cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in1"; fi
	in2="$DC_tlt/cfg.2"
	if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
		cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in2"; fi
	in3="$DC_tlt/cfg.3"
	if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
		cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in3"; fi
	in4="$DC_tlt/cfg.4"
	if [ -n "$(cat "$in4" | sort -n | uniq -dc)" ]; then
		cat "$in4" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in4"; fi
	if [[ $stts = "13" ]]; then
		if cat "$DC_tl/.cfg.3" | grep -Fxo "$topic"; then
			echo "6" > "$DC_tlt/cfg.8"
		elif cat "$DC_tl/.cfg.2" | grep -Fxo "$topic"; then
			echo "1" > "$DC_tlt/cfg.8"
		else
			echo "1" > "$DC_tlt/cfg.8"
		fi
	fi
	[[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
fi

if [ $(cat "$DC_tlt/cfg.0" | wc -l) -le 20 ]; then
	msg " $min_items\\n " info &
	exit
fi

cd $HOME
upld=$($yad --form --width=420 --height=460 --on-top \
--buttons-layout=end --center --window-icon=idiomind \
--borders=15 --skip-taskbar --align=right \
--button=$cancel:1 --button=$upload:0 \
--title="$upload" --text="   <b>$tpc</b>" \
--field=" :lbl" "#1" \
--field="    <small>$author</small>" "$user" \
--field="    <small>$email</small>" "$mail" \
--field="    <small>$category</small>:CB" \
"!$others!$comics!$culture!$entertainment!$family!$grammar!$history!$movies!$in_the_city!$internet!$music!$nature!$news!$office!$relations!$sport!$shopping!$social!$technology!$travel" \
--field="    <small>$level</small>:CB" "!$beginner!$intermediate!$advanced" \
--field="<small>\\n$notes</small>:TXT" "$nt" \
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
[[ $Ctgry = $movies ]] && Ctgry=movies
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
msg " $categry_err\\n " info
$DS/ifs/upld.sh &
exit 1
fi

internet

cd $DT
wget http://idiomind.sourceforge.net/info/SITE_TMP
source $DT/SITE_TMP && rm -f $DT/SITE_TMP
[[ -z "$FTPHOST" ]] && msg " $site_err\\n " dialog-warning && exit

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

if [[ -f "$img" ]]; then
/usr/bin/convert -scale 120x90! "$img" $DT_u/img1.png
convert $DT_u/img1.png -alpha opaque -channel a \
-evaluate set 15% +channel $DT_u/img.png
bo=/usr/share/idiomind/images/bo.png
convert $bo -edge .5 -blur 0x.5 $DT_u/bo_.png
convert $DT_u/img.png \( $DT_u/bo_.png -negate \) \
-geometry +1+1 -compose multiply -composite \
-crop 120x90+1+1 +repage $DT_u/bo_outline.png
convert $DT_u/img.png -crop 120x90+1+1\! \
-background none -flatten +repage \( $bo +matte \) \
-compose CopyOpacity -composite +repage $DT_u/boim.png
convert $DT_u/boim.png \( +clone -channel A -separate +channel \
-negate -background black -virtual-pixel background \
-blur 0x4 -shade 110x21.78 -contrast-stretch 0% +sigmoidal-contrast 7x50% \
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

n=1
while [ $n -le $(cat "$DC_tlt/cfg.5" | wc -l) ]; do
	cp=$(sed -n "$n"p "$DC_tlt/cfg.5")
	cp "$DM_tl/.share/$cp" "$DT_u/$tpc/.audio/$cp"
	let n++
done

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
notify-send "$uploading" "$wait..." -i idiomind -t 6000

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
	info="  $tpc\n\n<b> $saved</b>\n"
	image=dialog-ok
else
	info=" $upload_err"
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
