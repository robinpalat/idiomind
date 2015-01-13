#!/bin/bash
# -*- ENCODING: UTF-8 -*-
tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
lgsl=$(sed -n 2p ~/.config/idiomind/s/cnfg9)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/addons/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"

function cuestion() {
		yad --form --align=center --undecorated \
		--center --on-top --image-on-top --image="$3" \
		--skip-taskbar --title=" "  \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--field="$1":lbl \
		--button="gtk-close":1 \
		--button="     Answer     ":0 \
		--width=365 --height=360
}

function answer() {
		yad --form --align=center --undecorated \
		--center --on-top --image-on-top --image="$3" \
		--skip-taskbar --title=" "  \
		--window-icon=idiomind --borders=0 \
		--field="$2":lbl \
		--buttons-layout=spread \
		--button="      I Know it      ":2 \
		--button="      I Don't Know      ":3 \
		--width=365 --height=360
}

n=1
while [ $n -le $(cat ./fin$1 | wc -l) ]; do

	trgt=$(sed -n "$n"p ./fin$1)
	srce=$(eyeD3 "$drtt/$trgt.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	step=$1
	if [[ -f "$drtt/images/$trgt.jpg" ]]; then
	img="$drtt/images/$trgt.jpg"
	trgt="<big><big><big><big><b>$trgt</b></big></big></big></big>"
	srce="<big><big><big><big><b>$srce</b></big></big></big></big>"
	else
	img="/usr/share/idiomind/images/fc.png"
	trgt="<big><big><big><big><big><big><big><b>$trgt</b></big></big></big></big></big></big></big>"
	srce="<big><big><big><big><big><big><big><b>$srce</b></big></big></big></big></big></big></big>"
	fi

	cuestion "$trgt" "$srce" "$img"
	ret=$(echo "$?")
	
	if [[ $ret = 0 ]]; then # ------------------------------
	
		answer "$trgt" "$srce" "$img"
		ans=$(echo "$?")
		
		if [[ $ans = 2 ]]; then
			if [[ $step = 1 ]]; then
				sed -i 's/'"$trgt"'//g' fin.tmp & echo "$trgt" >> ./fin.1.ok
			else
				echo "$trgt" >> ./fin.2.ok
			fi
		elif [[ $ans = 3 ]]; then
		
			echo "$trgt" >> ./fin.$step.no
		fi
		
	elif [[ $ret = 1 ]]; then # ------------------------------
	
		$drts/cls "$step" f &
		break &
		exit 1
	fi
	
	let n++
done
