#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/addons/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
lns=$(cat mcin"$1" | wc -l)
n=1

function mchoise() {
	dlg=$(cat word2.id | awk '{print "\n"$0}' \
	| yad --list --list --on-top --skip-taskbar \
	--width=365 --height=340 --center --buttons-layout=edge --undecorated \
	--text-align=center --no-headers --borders=5 --window-icon=idiomind \
	--button=gtk-close:1 \
	--button="  Ok  ":0 --title=" " \
	--text="\\n<big><big><big><big><big><big><big><b>$1</b></big></big></big></big></big></big></big>\\n\\n\\n<small></small>" \
	--column=Opcion --column=Opciodn)
}

while [ $n -le "$lns" ]; do

	w1=$(sed -n "$n"p mcin"$1")
	file="$drtt/$w1.mp3"

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
		
		if [ "$1" = 1 ]; then
			trgt=$(echo "$tgt")
		elif [ "$1" = 2 ]; then
			trgt=$(echo "<u>$tgt</u>")
		fi
		
		mchoise "$trgt"
		ret=$(echo "$?")

		if [[ $ret = 0 ]]; then
			if echo "$dlg" | grep "$wes"; then
				if [[ $1 = 1 ]]; then
					sed -i 's/'"$w1"'//g' mcin.tmp & echo "$w1" >> ./mcin.1.ok &
				else
					echo "$w1" >> ./mcin.2.ok &
				fi
			else
				echo "$w1" >> ./mcin.$1.no
			fi	
		elif [[ $ret = 1 ]]; then
			$drts/cls "$1" m &
			break &
			exit 1
		fi
	fi
	let n++
done
