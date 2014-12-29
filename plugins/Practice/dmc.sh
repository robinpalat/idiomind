#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/topic.id)
lgtl=$(sed -n 2p ~/.config/idiomind/s/lang)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/plugins/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
lns=$(cat stp"$1" | wc -l)
n=1

while [ $n -le "$lns" ]; do

	w1=$(sed -n "$n"p stp"$1")
	if [ -f "$drtt/$w1.mp3" ]; then
		file="$drtt/$w1.mp3"
	else
		file="$drtt/$w1.omd"
	fi
	
	if [ -f "$file" ]; then
		tgt="$w1"
		wes=$(eyeD3 "$file" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		ras=$(sort -Ru word1.idx | egrep -v "$wes" | head -4)
		ess=$(grep "$wes" word1.idx)
		echo "$ras
$ess" > word2.tmp
		ells=$(sort -Ru word2.tmp | head -6)
		echo "$ells" > word2.tmp
		sed '/^$/d' word2.tmp > word2.id
		
		wrong=$(cat mcin.no | wc -l)
		good=$(cat mcin.ok | wc -l)

		if [ "$2" = 1 ]; then
			trgt=$(echo "<span font='ultralight'>$tgt</span>")
		elif [ "$2" = 2 ]; then
			trgt=$(echo "<span font='ultralight'><span color='#B04541'><b><i>!  </i></b></span>$tgt</span>")
		elif [ "$2" = 3 ]; then
			trgt=$(echo "<span font='ultralight'><span color='#B04541'><b><i>!  </i></b></span>$tgt</span>")
		fi
		
		dlg=$(cat word2.id | awk '{print "\n"$0}' \
		|/lib32/yad_idiomind --list --list --on-top --skip-taskbar \
		--width=330 --height=300 --center --buttons-layout=edge --undecorated \
		--text-align=center --no-headers --borders=8 --window-icon=idiomind \
		--button=Close:1 \
		--button="  Ok  ( $good )  ":0 --title=" " \
		--text="<big><big><big><big><big><big><big><b>$trgt</b></big></big></big></big></big></big></big>\\n<small></small>" --column=Opcion --column=Opciodn)

		ret=$?
		if [[ $ret -eq 0 ]]; then	
			if echo "$dlg" | grep "$wes"; then
				play $drts/d.mp3 & sed -i 's/'"$w1"'//g'  \
				./mcin.tmp & echo "$w1" >> ./mcin.ok &
			else
				play $drts/d.mp3 & echo "$w1" >> ./mcin.no
			fi	
		else
			$drts/cls "$2" m && exit 1
		fi
	fi

	let n++
done
