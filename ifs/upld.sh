#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/upld.conf

if [ $1 = vsd ]; then
	userid=$(sed -n 1p $HOME/.config/idiomind/s/cnfg4)
	lng=$(echo "$lgtl" |  awk '{print tolower($0)}')
	wth=$(sed -n 4p $DC_s/cnfg18)
	eht=$(sed -n 3p $DC_s/cnfg18)
	cd $DM_t/saved
	ls -t *cnfg13 > ls
	(sed -i 's/cnfg13//g' ./ls)

	cat ./ls | $yad --list --on-top \
	--window-icon=idiomind --center --skip-taskbar \
	--buttons-layout=edge --borders=8 \
	--text=" <small>$double_click_for_download \\t\\t\\t\\t</small>" \
	--title="topics_saved" --width=$wth --height=$eht \
	--column=Nombre:TEXT --print-column=1 \
	--expand-column=1 --search-column=1 \
	--button="$search_topics":"/usr/share/idiomind/ifs/tls.sh web" \
	--button="$close":1 \
	--dclick-action='/usr/share/idiomind/ifs/upld.sh infsd'
	
			["$?" -eq 0 ]
				killall topic.sh
				rm $DT/lista
			[ "$?" -eq 1 ] & exit
	exit 1
	
elif [ $1 = infsd ]; then
	cd $DM_t/saved
	userid=$(sed -n 1p $DC_s/cnfg4)
	user=$(echo "$(whoami)")
	tpcd="$2"
	NM=$(sed -n 1p ./"$tpcd"cnfg13)
	LNGT=$(sed -n 2p ./"$tpcd"cnfg13)
	lngs=$(sed -n 5p ./"$tpcd"cnfg13)
	ATR=$(sed -n 6p ./"$tpcd"cnfg13)
	SKP=$(sed -n 7p ./"$tpcd"cnfg13)
	ML=$(sed -n 8p ./"$tpcd"cnfg13)
	CTGY=$(sed -n 9p ./"$tpcd"cnfg13)
	LNK=$(sed -n 10p ./"$tpcd"cnfg13)
	nme=$(echo "$tpcd" | sed 's/ /_/g')
	icon=$DS/images/idmnd.png
	file="http://currently.url.ph/$lgs/$lgtl/$Ctgry/$nme/$userid.$tpcd.idmnd"

	$yad --borders=15 --width=450 --height=180 --fixed \
	--on-top --skip-taskbar --center --image=$icon --geometry=0-0-0-0 \
	--title="idiomind" --button="   $download   :0" \
	--button="  Close  :1" --text="<b>$NM</b>\\n<small>$LNGT $language </small> \\n<small><a href='$LNK'>$NM</a></small>"
		ret=$?

		if [ $ret -eq 2 ]; then
			xdg-open "$LNK"
		exit 1

		elif [ $ret -eq 0 ]; then
			sv=$($yad --save --center --borders=10 \
			--on-top --filename="$tpcd.idmnd" \
			--window-icon=idiomind --skip-taskbar --title="Save" \
			--file --width=600 --height=500 --button=gtk-ok:0 )
			ret=$?
			
			curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
			$yad --window-icon=idiomind --on-top \
			--image="info" --name=idiomind \
			--text="<b>$conn_err  \\n  </b>" \
			--image-on-top --center --sticky \
			--width=320 --height=100 --borders=5 \
			--skip-taskbar --title="Idiomind" \
			--button="  Ok  ":0 >&2; exit 1;}

			rm $HOME/$userid."$tpcd".idmnd

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
			$yad --progress --timeout=100 --borders=10 --auto-close \
			--geometry=240x40-5-5 --no-buttons --skip-taskbar --undecorated \
			--title="Downloading"< $pipe
			if [ "`ps -A |grep "$wget_pid"`" ];then
			kill $wget_pid
			fi
			rm -f $pipe
			}
			cd /tmp
			[ -f "/tmp/$userid.$tpcd.idmnd" ] && rm -f "/tmp/$userid.$tpcd.idmnd"
			
			WGET "$file"
			
			if [ -f "/tmp/$userid.$tpcd.idmnd" ] ; then
			
				mv -f "/tmp/$userid.$tpcd.idmnd" "$sv"
				
			else
				$yad --fixed --name=idiomind --center \
				--image=info --text="<b>file_err</b>" \
				--fixed --sticky --width=220 --height=80 --borders=3 \
				--skip-taskbar --window-icon=$DS/images/icon.png \
				--on-top --title="Idiomind" --button="Info":3 \
				--button="Ok":0 && exit 1
			fi
			exit 1
		else
			exit 1
		fi
fi

lnglbl=$(echo $lgtl | awk '{print tolower($0)}')
nt=$(sed -n 2p $DC_s/cnfg4)
user=$(echo "$(whoami)")
userid=$(sed -n 1p $DC_s/cnfg4)
mail=$(sed -n 2p $DC_s/cnfg4)
skp=$(sed -n 3p $DC_s/cnfg4)
nme=$(echo "$tpc" | sed 's/ /_/g' \
| sed 's/"//g' | sed 's/’//g')
chk1="$DC_tlt/cnfg0"
chk2="$DC_tlt/cnfg1"
chk3="$DC_tlt/cnfg2"
chk4="$DC_tlt/cnfg3"
chk5="$DC_tlt/cnfg4"
chk6="$DC_tlt/nt"

if [ -z "$cat chk1" ]; then
	cp -f "$DC_tlt/cnfg0~" "$DC_tlt/cnfg0"
fi
if [ -z "$cat chk2" ]; then
	cp -f "$DC_tlt/cnfg1~" "$DC_tlt/cnfg1"
fi
if [ -z "$cat chk3" ]; then
	cp -f "$DC_tlt/cnfg2~" "$DC_tlt/cnfg2"
fi
if [ -z "$cat chk4" ]; then
	cp -f "$DC_tlt/cnfg3~" "$DC_tlt/cnfg3"
fi
if [ -z "$cat chk5" ]; then
	cp -f "$DC_tlt/cnfg4~" "$DC_tlt/cnfg4"
fi
if [ -z "$cat chk6" ]; then
	cp -f "$DC_tlt/.nt~" "$DC_tlt/nt"
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

chk1=$(cat "$DC_tlt/cnfg0" | wc -l)
chk2=$(cat "$DC_tlt/cnfg1" | wc -l)
chk3=$(cat "$DC_tlt/cnfg2" | wc -l)
chk4=$(cat "$DC_tlt/cnfg3" | wc -l)
chk5=$(cat "$DC_tlt/cnfg4" | wc -l)

if [[ "$(($chk4 + $chk5))" != $chk1 \
	|| "$(($chk2 + $chk3))" != $chk1 ]]; then
	notify-send -i idiomind "index_err1" "$index_err2" -t 5000 &
	
	rm -f $DT/ind
	rm -f $DT/ind_ok
	
	cd "$DM_tlt/"
	for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	ls *.mp3 | sed 's/.mp3//g' > $DT/ind
	cd "$DM_tlt/words/"
	for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
	if [ -f ".mp3" ]; then rm .mp3; fi
	ls *.mp3 | sed 's/.mp3//g' >> $DT/ind
	rm "$DC_tlt/cnfg3"
	rm "$DC_tlt/cnfg4"
	
	n=1
	while [ $n -le $(cat "$DT/ind" | wc -l) ]; do
		chk1=$(sed -n "$n"p "$DC_tlt/cnfg0")
		if cat "$DT/ind" | grep -Fxo "$chk1"; then
				if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
					echo "$chk1" >> "$DC_tlt/cnfg3"
				elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
					echo "$chk1" >> "$DC_tlt/cnfg4"
				fi
			echo "$chk1" >> $DT/ind_ok
			grep -v -x -v "$chk1" $DT/ind > $DT/ind_
			sed '/^$/d' $DT/ind_ > $DT/ind
		fi
	
		let n++
	done
	
	n=1
	while [ $n -le $(cat "$DT/ind" | wc -l) ]; do
		chk2=$(sed -n "$n"p "$DT/ind")
		if [ $(echo "$chk2" | wc -w) -eq 1 ]; then
			echo "$chk2" >> "$DC_tlt/cnfg3"
		elif [ $(echo "$chk2" | wc -w) -gt 1 ]; then
			echo "$chk2" >> "$DC_tlt/cnfg4"
		fi
		let n++
	done

	cat $DT/ind >> $DT/ind_ok
	cp -f $DT/ind_ok "$DC_tlt/cnfg0"
	rm "$DC_tlt/cnfg2"
	in1="$DC_tlt/cnfg0"
	if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
		cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in1"
	fi
	in2="$DC_tlt/cnfg4"
	if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
		cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in2"
	fi
	in3="$DC_tlt/cnfg4"
	if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
		cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
		sed '/^$/d' $DT/ind > "$in3"
	fi
	cp -f "$in1" "$DC_tlt/cnfg1"
fi

if cat "$DM_t/saved/ls" \
| grep "$tpc"; then
	inf="Actualizado"
else
	inf="Subido"
fi

cd "$DM_tlt"
MP3=$(ls *.mp3 | wc -l)
WORDS=$(ls ./words/*.mp3 | wc -l)
function suma(){
 let ALL=$MP3+$WORDS
}
suma
if [ $ALL -le 20 ]; then
	cstn=$($yad --image=info --on-top --window-icon=idiomind \
	--text="<b>$min_items  \\n  </b>" \
	--image-on-top --center --sticky --name=idiomind \
	--width=320 --height=100 --borders=5 \
	--skip-taskbar --title="Idiomind" \
	--button="Ok:0")
	exit 1
fi

upld=$($yad --image-on-top --width=400 \
--buttons-layout=end --center --window-icon=idiomind \
--on-top --image=$DS/images/upld.png \
--height=450 --form --borders=20 --skip-taskbar --align=right \
--button=$cancel:1 --button=$upload:0 \
--title="Upload" --text="<b>$tpc\\n</b>" \
--field=" :lbl" "#1" \
--field="    <small>$author</small>:: " "$user" \
--field="    <small>$email</small>:: " "$mail" \
--field="    <small>$skype</small>:: " "$skp" \
--field="    <small>$category</small>::CB" \
"!others!entertainment!history!documentary!films!internet!mathematics!music!education!nature!news!office!policy!podcats!relations!sport!religion!shopping!science!social!technology!travel!places" \
--field="<small>\\n$notes:</small>:TXT" " ")
ret=$?

if [[ "$ret" != 0 ]]; then
	exit 1
fi

Autor=$(echo "$upld" | cut -d "|" -f2)
Mail=$(echo "$upld" | cut -d "|" -f3)
Skype=$(echo "$upld" | cut -d "|" -f4)
Ctgry=$(echo "$upld" | cut -d "|" -f5)
Notes=$(echo "$upld" | cut -d "|" -f6 | sed 's/\n/ /g')
link=$(echo http://$lgs.idiomind.com.ar/$lnglbl/$Ctgry/"$userid"/"$nme")

mkdir "$DT/$nme"
mkdir "$DT/$tpc"
echo ""$tpc"
"$lgtl"
"$lgt"
"$lgsl"
"$lgs"
"$Autor"
"$Mail"
"$Skype"
"$Ctgry"
"$link"
"$Notes"" > "$DT/$tpc"/cnfg13
echo "$userid" > $DC_s/cnfg4
echo "$Skype" >> $DC_s/cnfg4
echo "$Mail" >> $DC_s/cnfg4

if [ -z $Ctgry ]; then

	$yad --window-icon=idiomind --name=idiomind \
	--image=info --on-top \
	--text="<b>$categry_err  \\n</b>" \
	--image-on-top --center --sticky \
	--width=320 --height=100 --borders=5 \
	--skip-taskbar --title="Idiomind" \
	--button="  Ok  ":0
	$DS/ifs/upld.sh &
	rm ./.info_u.sh
	exit 1
	
fi

curl -v www.google.com 2>&1 | \
grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
$yad --window-icon=idiomind --on-top \
--image="info" --name=idiomind \
--text="<b>$conn_err  \\n  </b>" \
--image-on-top --center --sticky \
--width=320 --height=100 --borders=5 \
--skip-taskbar --title=Idiomind \
--button="  Ok  ":0
 >&2; exit 1;}

cd "$DM_tlt"
cp -r * $DT/"$tpc/"
mkdir $DT/"$tpc"/.audio

n=1
while [ $n -le $(cat "$DC_tlt/cnfg5" | wc -l) ]; do
	cp=$(sed -n "$n"p "$DC_tlt/cnfg5")
	cp "$DM/topics/$lgtl/.share/$cp" "$DT/$tpc/.audio/$cp"
	let n++
done

cp -f "$DC_tlt/cnfg0" "$DT/$tpc/cnfg0"
cp -f "$DC_tlt/cnfg3" "$DT/$tpc/cnfg3"
cp -f "$DC_tlt/cnfg4" "$DT/$tpc/cnfg4"
cp -f "$DC_tlt/cnfg5" "$DT/$tpc/cnfg5"
cd $DT
tar -cvf "$tpc.tar" "$tpc"
gzip -9 "$tpc.tar"
mv "$tpc.tar.gz" "$userid.$tpc.idmnd"
rm -f "$tpc"/*

notify-send "$uploading..." "$wait" -i idiomind -t 6000

wget http://www.idmnd.2fh.co/data/.PASS_TMP

HOST=$(sed -n 1p .PASS_TMP)
USER=$(sed -n 2p .PASS_TMP)
PASS=$(sed -n 3p .PASS_TMP)

#-----------------------
NAME=$(echo "$tpc" | sed 's/ /_/g')
dte=$(date "+%d %B %Y")
mkdir $DT/mkhtml
cp -f "$DC_tlt/cnfg3" $DT/mkhtml/w.inx.l
cp -f "$DC_tlt/cnfg4" $DT/mkhtml/s.inx.l
iw=$DT/mkhtml/w.inx.l
is=$DT/mkhtml/s.inx.l
mkdir $DT/$NAME
mkdir $DT/$NAME/images
cp -f "$DT/$userid.$tpc.idmnd" $DT/$NAME/
cd $DT/mkhtml

#-----------------------
n=1
while [ $n -le $(cat $iw | wc -l | awk '{print ($1)}') ]; do
	WL=$(sed -n "$n"p  $iw)
	if [ -f "$DM_tlt/words/images/$WL.jpg" ]; then
		convert "$DM_tlt/words/images/$WL.jpg" -font Verdana-Bold -gravity south -pointsize 35 -fill white -draw \
		"text 0 0 \"$WL\"" -stroke gray22 -draw "text 0 -1 $WL" "$DT/$NAME/images/$n.jpg"
	fi
	tgs=$(eyeD3 "$DM_tlt/words/$WL.mp3")
	wt=$(echo "$tgs" | grep -o -P "(?<=IWI1I0I).*(?=IWI1I0I)")
	ws=$(echo "$tgs" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")
	echo "$wt" >> W.lizt.x
	echo "$ws" >> W.lizs.x
	let n++
done

#-----------------------
n=1
while [[ $n -le "$(cat  $is | wc -l | awk '{print ($1)}')" ]]; do
	WL=$(sed -n "$n"p $is)
	tgs=$(eyeD3 "$DM_tlt/$WL.mp3")
	wt=$(echo "$tgs" | grep -o -P "(?<=ISI1I0I).*(?=ISI1I0I)")
	ws=$(echo "$tgs" | grep -o -P "(?<=ISI2I0I).*(?=ISI2I0I)")
	echo "$wt" >> S.gprt.x
	echo "$ws" >> S.gprs.x
	let n++
done

#-----------------------
lgt=$(sed -n 2p "$DT/$tpc"/cnfg13 | awk '{print tolower($0)}')
ls=$(sed -n 5p "$DT/$tpc"/cnfg13)
cby=$(sed -n 6p "$DT/$tpc"/cnfg13)
cty=$(sed -n 9p "$DT/$tpc"/cnfg13)
lnk=$(sed -n 10p "$DT/$tpc"/cnfg13)
nts=$(sed -n 11p "$DT/$tpc"/cnfg13 | sed 's/https\:\/\///g' | sed 's/http\:\/\///g')

l=$(sort -Ru $DM_t/saved/ls | egrep -v "$tpc" | head -4)
echo "$l" > l
ot1=$(sed -n 1p l)
ot2=$(sed -n 2p l)
ot3=$(sed -n 3p l)
ot4=$(sed -n 4p l)
lt1=$(sed -n 10p "$DM_t/saved/$ot1"cnfg13)
lt2=$(sed -n 10p "$DM_t/saved/$ot2"cnfg13)
lt3=$(sed -n 10p "$DM_t/saved/$ot3"cnfg13)
lt4=$(sed -n 10p "$DM_t/saved/$ot4"cnfg13)

#-----------------------htmlquiz
if [ -n "$(cat $iw)" ]; then
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">' > $DT/$NAME/flashcards.html
echo '<head>
<title>'$tpc'</title>
<link rel="stylesheet" href="ln/flashcards.css" media="screen" />
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js" type="text/javascript"></script>
<script>window.jQuery || document.write("<script src="jquery-1.6.2.min.js">\x3C/script>")</script>
</head>' >> $DT/$NAME/flashcards.html

#-----------------------htmlhome

echo '<script src="ln/utils.js" type="text/javascript"></script>
<div id="fc_container" class="noprint">
  <div id="incorrectBox" class="cardBox" onClick="doAction( MOVE_TO_INCORRECT )">incorrect cards (0)</div>
  <div id="correctBox" class="cardBox" onClick="doAction( MOVE_TO_CORRECT )">correct cards (0)</div>
  <div id="remainingBox" class="cardBox" onClick="doAction( MOVE_TO_REMAINING )">remaining cards (0)</div>
  <div id="correctCards"   class="cardPile" onClick="doAction( UNDO_CORRECT )" ></div>
  <div id="incorrectCards" class="cardPile" onClick="doAction( UNDO_INCORRECT )"></div>
  <div id="remainingCards" class="cardPile" onClick="doAction( MOVE_TO_REMAINING )"></div>
  <div id="currentCard" onClick="doAction( FLIP_CARD )"></div>
  <div id="reverseOrder">
      <input type="checkbox" id="reverseOrderCheckBox" value="reverse" onClick="reverseOrder()" />
              <label class="action" for="reverseOrderCheckBox"> show Answer first</label>
  </div>
  <div id="autoPlayArea" title="Check to flip through cards automatically">
      <input id="autoPlayCheckBox" type="checkbox" onclick="doAction( TOGGLE_AUTO_PLAY )" id="autoPlay">
      <label id="autoPlayLabel" class="action" for="autoPlayCheckBox">auto play</label>
      <div id="speedBarArea">
         <div id="speedBar" title="Click to set auto play speed" onMouseDown="alert( "speed" );"></div>
         <div id="speedMarker" ></div>
         <div id="delayDescription" ></div>
      </div>
  </div>
  <div id="restartLink" class="action" onClick="doAction( START_OVER )" title="Move all cards back to the "remaining" box">restart</div>
  <table id="infoCard"   class="infoMessage" onClick="doAction( CLOSE_HELP )" title="click to hide" >
    <tr style="height: 326px;  " ><td id="infoCardContent" >
     </td></tr>
</table>
</div>

<script type="text/javascript">
   var embedHeight = 440; 
   var embedWidth =  850;
</script>' >> $DT/$NAME/flashcards.html

#-----------------------htmlhome

echo '<script type="text/javascript">
     //<![CDATA[
  var stack = {name : "'$tpc'",description : "'$tpc'",nextCardId : "50" ,numCards : "49" ,columnNames : [ "'$lgtl'","'$lgsl'"], data : [' >> $DT/$NAME/flashcards.html

n=1
while [ $n -le "$(cat $DT/mkhtml/W.lizt.x | wc -l)" ]; do
	wt=$(sed -n "$n"p $DT/mkhtml/W.lizt.x)
	ws=$(sed -n "$n"p $DT/mkhtml/W.lizs.x)
	echo '["'$wt'","'$ws'"]' >> flashcards
	let n++
done

cat flashcards | tr '\n' ',' >> $DT/$NAME/flashcards.html

#-----------------------

echo ']};;
  // 
  var savedSessionData = "";
  var logonId = "";
      //]]>
</script>
<script src="ln/flashcard.js" type="text/javascript"></script></div>
<p>&nbsp;</p>
</section>
   </div>
        </article>
    </div>
</main>
<footer role="contentinfo">
</footer>
</div></html>' >> $DT/$NAME/flashcards.html
fi
#-----------------------

echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">' > $DT/$NAME/index.html

echo '<head>
<html lang="en" id="abId0.5137621304020286"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta charset="utf-8">
<title>'$tpc'</title>
<link rel="stylesheet" href="./ln/style.css" media="screen" />
<link rel="stylesheet" type="text/css" href="ln/jquery.fancybox-1.3.4.css" media="screen" />
<link rel="stylesheet" href="./ln/spacegallery.css" media="screen" />
<link rel="stylesheet" href="./ln/custom.css" media="screen" />
<script type="text/javascript" src="http://www.idiomind.com.ar/default/js/jquery.js"></script>
<script type="text/javascript" src="http://www.idiomind.com.ar/default/js/eye.js"></script>
<script type="text/javascript" src="http://www.idiomind.com.ar/default/js/utils.js"></script>
<script type="text/javascript" src="http://www.idiomind.com.ar/default/js/spacegallery.js"></script>
<script type="text/javascript" src="http://www.idiomind.com.ar/default/js/layout.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
<script type="text/javascript" src="ln/jquery.fancybox-1.3.4.pack.js"></script>

<script type="text/javascript">
$(document).ready(function() {
$("#various1").fancybox({
"width"			: "100%",
"height"		: "100%",
"autoScale"		: false,
"transitionIn"		: "none",
"transitionOut"		: "none",
"overlayColor"		: "#2B2B2B",
"overlayOpacity"	: 9.9,
"scrolling"	        : "no",
"type"			: "iframe"
});
});

</script>

</head>
<main id="content" class="group" role="main">
    <div class="main">
        <article class="post group">
            <header>
              <h1>'$tpc'</h1>
             </header>
             <div class="entry">' >> $DT/$NAME/index.html

#-----------------------images

cd "$DM_tlt/words/images"

if [ $(ls -1 *.jpg 2>/dev/null | wc -l) != 0 ]; then
	echo '<div class="entry">
	<div id="myGallery" class="spacegallery">' >> $DT/$NAME/index.html
	
	cd $DT/$NAME/images/
	ls *.jpg > $DT/mkhtml/nimg
	cd $DT/mkhtml/
	n=1
	while [ $n -le "$(cat nimg | wc -l)" ]; do
		nimg=$(sed -n "$n"p nimg)
		echo '<img src="images/'$nimg'" alt="" />' >> $DT/$NAME/index.html
		let n++
	done

	echo '</div>' >> $DT/$NAME/index.html

fi

#-----------------------htmlhome
cd $DT/mkhtml/
n=1
while [ $n -le $(cat s.inx.l | wc -l) ]; do
		st=$(sed -n "$n"p S.gprt.x)
		
		if [ -n "$st" ]; then
			ss=$(sed -n "$n"p S.gprs.x)
			fn=$(sed -n "$n"p s.inx.l)
	
			echo '<a href="#'$n'">
			<div class="callout sentence">
			<p>'$st'</p>' > Sgprt.tmp
			echo '<pre>'$ss'</pre>
			</div></a>' > Sgprs.tmp
			echo '<table>
			<tbody>' > Wgprs.tmp
					
			eyeD3 "$DM_tlt/$fn.mp3" > tgs
			> wt
			> ws
			(
			n=1
			while [ $n -le "$(echo "$st" | sed 's/ /\n/g' \
			| grep -v '^.$' | grep -v '^..$' | wc -l)" ]; do
				cat tgs | grep -o -P '(?<=ISTI'$n'I0I).*(?=ISTI'$n'I0I)' >> wt
				cat tgs | grep -o -P '(?<=ISSI'$n'I0I).*(?=ISSI'$n'I0I)' >> ws
				let n++
			done
			)
	
			(
			n=1
			while [ $n -le "$(cat wt | wc -l)" ]; do
				wt=$(sed -n "$n"p wt)
				ws=$(sed -n "$n"p ws)
				wt2=$(sed -n "$n"p wt)
				
				if cat W.lizt.x | grep "$wt2"; then
					echo '<tr>
					<td><mark'$n'>'$wt'</mark></td>
					<td><mark'$n'>'$ws'</mark></td>
					</tr>' >> ./Wgprs.tmp
				else
					echo '<tr>
					<td>'$wt'</td>
					<td>'$ws'</td>
					</tr>' >> ./Wgprs.tmp
				fi
				
				let n++
			done
			)
			
			echo '</tbody>
			</table>
			<a name="'$n'"></a>
			<p>&nbsp;</p>
			<p>&nbsp;</p>' >> ./Wgprs.tmp
			cat ./Sgprt.tmp >> $DT/$NAME/index.html
			cat ./Sgprs.tmp >> $DT/$NAME/index.html
			cat ./Wgprs.tmp >> $DT/$NAME/index.html
		fi
	let n++
done

#-----------------------htmlhome

echo '<a href="#top">Ir Arriba</a>
<p>&nbsp;</p>
</section>
    </div>
    </article>
    </div>
<aside class="secondary">    
    <nav class="ui-tabs mod">
    <div>
       <p> '$nts' </p>
       <p>&nbsp;</p>
       <p>Subido por '$cby',  el '$dte'</p>
    </div>
    <p>&nbsp;</p>
    <div class="tab" id="articles">
  <p class="btn"><a href="'$lnk'">Download this Topic</a>  </p>
  <div class="area"></div>
  <p class="buscarenelsitio">&nbsp;</p>
  <p class="buscarenelsitio">Otros topics del autor
  </p>
      <p><a href="'$lt1'">'$ot1'</a></p>
      <p><a href="'$lt2'">'$ot2'</a></p>
      <p><a href="'$lt3'">'$ot3'</a></p>
	  <p><a href="'$lt4'">'$ot4'</a></p>' >> $DT/$NAME/index.html
		if [ -n "$(cat $iw)" ]; then
		echo '<ul class="navigationTabs">
		<li><a href="./flashcards.html" target="_new" id="various1">Flashcards</a></li>
		</ul>' >> $DT/$NAME/index.html
		fi
      echo '<p>&nbsp;</p>
      <span class="buscarenelsitio">Busca en el sitio</span>
          <div>
            <script>
			  (function() {
			    var cx = "002081832494466994751:1linpaag-om";
			    var gcse = document.createElement("script");
			    gcse.type = "text/javascript";
			    gcse.async = true;
			    gcse.src = (document.location.protocol == "https:" ? "https:" : "http:") +
			        "//www.google.com/cse/cse.js?cx=" + cx;
			    var s = document.getElementsByTagName("script")[0];
			    s.parentNode.insertBefore(gcse, s);
			  })();
            </script>
            <gcse:search></gcse:search>
        </div>
      <tr>
        <td width="15%" height="29">&nbsp;</td>
          <td width="23%" align="center">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
          <p><a href="http://'$ls'.idiomind.com.ar/'$lgt'/'$cty'">Buscar en esta categoria</a></p>
          <p>&nbsp;</p>
     </div>
    </nav>
  </aside>
</main>' >> $DT/$NAME/index.html

#-----------------------htmlhome

echo '<footer role="contentinfo">
	<div class="inner">
    	<img width="64" height="64" class="w3c-logo" alt="W3C HTML5 logo (not CSS3!)" src="/usr/share/idiomind/images/cnn.png">
		<p id="copyright">This site is licensed under a <a href="http://creativecommons.org/licenses/by-nc/2.0/uk/" rel="license">Creative Commons Attribution-Non-Commercial 2.0</a> share alike license. Feel free to change, reuse modify and extend it. Some authors will retain their copyright on certain articles.</p>
        <p>Copyright © 2015 Idiomind. All rights.</p>
	</div>
</footer>
</div></html>' >> $DT/$NAME/index.html
chmod 775  $DT/$NAME/index.html

#-----------------------ftp
(
HOST=$HOST
USER=$USER
PASSWD=$PASS
rm -f $DT/.PASS_TMP
cp -f -R $DS/ifs/ln $DT/$NAME
chmod 775 -R $DT/$NAME
lftp -u $USER,$PASS $HOST << END_SCRIPT
mkdir $NAME
mirror --reverse $DT/$NAME/ public_html/$lgs/$lgtl/$Ctgry/$NAME
quit
END_SCRIPT

curl -T /tmp/$userid."$tpc".idmnd -u $USER:$PASS \
ftp://$HOST/public_html/uploads/recents/$userid."$topic".idmnd
exit=$?

if [ 0 = 0 ] ; then
    cp -f "$DT/$tpc/cnfg13" "$HOME/.idiomind/topics/saved/$tpccnfg13"
    info="$the_topic \\n<b> <a href='$link'>$tpc</a></b> \\n $saved"
else
    info="$upload_err"
fi
)

yad --window-icon=idiomind --name=idiomind \
--image=info --on-top --text="$info" \
--image-on-top --center --fixed --sticky --geometry=320x150 \
--width=320 --height=120 --buttons-layout=right --borders=10 \
--skip-taskbar --title=idiomind \
--button="  Ok  ":0

rm -fr $DT/mkhtml/ $DT/.ti
rm -fr  $DT/"$tpc" $DT/.PASS_TMP $DT/$userid."$tpc".idmnd
rm $DT/.aud $DT/.img $DT/$userid."$tpc".idmnd \
$DT/"$tpc".tar $DT/"$tpc".tar.gz & exit 1
