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
		--center --on-top --image-on-top --image="$2" \
		--skip-taskbar --text-align=center --title=" "  \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--field="<big><big><big><big><big><big><big><big><b>$1</b></big></big></big></big></big></big></big></big>":lbl \
		--button="gtk-close":1 \
		--button=" Answer ":5 \
		--button="  Got It  ":3 \
		--button="  Nope  ":4 \
		--width=365 --height=350
		
			ret=$?
		if [[ $ret -eq 5 ]]; then 
			answer "$3"
	
		elif [[ $ret -eq 3 ]]; then
			if [[ $1 = 1 ]]; then
				play $drts/d.mp3 & sed -i 's/'"$w1"'//g' fin.tmp & echo "$w1" >> ./fin.1.ok
			else
				play $drts/d.mp3 & echo "$w1" >> ./fin.2.ok
			fi
		elif [[ $ret -eq 4 ]]; then
			play $drts/d.mp3 & echo "$w1" >> ./fin.$1.no
		else
			$drts/cls "$1" f && break & exit 1
		fi
}


function answer() {
		yad --form --align=center --undecorated \
		--center --on-top --image-on-top \
		--skip-taskbar --text-align=center --title=" "  \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--field="<big><big><big><big><big><big><big><big><b>$1</b></big></big></big></big></big></big></big></big>":lbl \
		--button="  Got It  ":3 \
		--button="  Nope  ":4 \
		--width=365 --height=350
		
			ret=$?
	
		if [[ $ret -eq 3 ]]; then
			if [[ $1 = 1 ]]; then
				play $drts/d.mp3 & sed -i 's/'"$w1"'//g' fin.tmp & echo "$w1" >> ./fin.1.ok
			else
				play $drts/d.mp3 & echo "$w1" >> ./fin.2.ok
			fi
		elif [[ $ret -eq 4 ]]; then
			play $drts/d.mp3 & echo "$w1" >> ./fin.$1.no
		else
			$drts/cls "$1" f && break & exit 1
		fi
}



n=1
while [ $n -le $(cat ./fin$1 | wc -l) ]; do
	w1=$(sed -n "$n"p ./fin$1)
	file="$drtt/$w1.mp3"
	tgt="$w1"
	lst=$(eyeD3 "$file" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	#if [ $1 = 1 ]; then
	#trgt=$(echo "<span font='ultralight'>$tgt</span>")
	#[[ $lgsl = Japanese ]] || [[ $lgsl = Chinese ]] || [[ $lgsl = Vietnamese ]] && stgt=? \
	#|| stgt="<span color='#949494'><span font='monospace'><b>$(echo "$lst" | tr aeiouy ' ')</b></span></span>"
	#elif [ $1 = 2 ]; then
	trgt=$(echo "<span font='ultralight'>$tgt</span>")
		#[ $lgsl = Japanese ] || [ $lgsl = Chinese ] || [ $lgsl = Vietnamese ] && stgt="$lst" || stgt="<span color='#949494'><big><b>$lst</b></big></span>"
	
	if [ -f "$drtt/images/$w1".jpg ]; then
		IMAGE="$drtt/images/$w1".jpg
	else
		IMAGE="/usr/share/idiomind/images/fc.png".jpg
	fi
	
	cuestion "$trgt" "$IMAGE" "$lst"



	let n++
done


