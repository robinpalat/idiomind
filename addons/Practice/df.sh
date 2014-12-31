#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/topic.id)
lgtl=$(sed -n 2p ~/.config/idiomind/s/lang)
lgsl=$(sed -n 2p ~/.config/idiomind/s/langt)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/addons/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"

n=1
while [ $n -le $(cat ./stp$1 | wc -l) ]; do

	w1=$(sed -n "$n"p ./stp$1)
	file="$drtt/$w1.mp3"
	tgt="$w1"
	lst=$(eyeD3 "$file" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	
	trgt=$(echo "<span font='ultralight'>$tgt</span>")
	
	[ $lgsl = Japanese ] || [ $lgsl = Chinese ] || [ $lgsl = Vietnamese ] && stgt=? \
	|| stgt=$(echo "$lst" | tr aeiouáéíóúyñ ' ')
	
	if [ $2 = 2 ]; then
		trgt=$(echo "<span font='ultralight'>\
<span color='#DF6A75'><b><i>!  </i></b></span>$tgt</span>")
		[ $lgsl = Japanese ] || [ $lgsl = Chinese ] || [ $lgsl = Vietnamese ] && stgt="$lst"
	
	fi
	
	wrong=$(cat fin.no | wc -l)
	good=$(cat fin.ok | wc -l)
	
	if [ -f "$drtt/images/$w1.jpg" ]; then
		IMAGE="$drtt/images/$w1.jpg"
		yad --form --align=center --undecorated \
		--center --on-top --image-on-top --image="$IMAGE" \
		--skip-taskbar --text-align=center --title=" "  \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--field="<big><big><big><big><big><big><big><big><b>$trgt</b></big></big></big></big></big></big></big></big>":lbl \
		--field="<span color='#949494'><span font='monospace'><b> $stgt </b></span></span>":lbl \
		--button="Close":1 \
		--button="   ( $good ) Got It   ":3 \
		--button="   ( $wrong ) Nope   ":4 \
		--width=365 --height=300
	
	else
		yad --form --align=center \
		--center --on-top --image-on-top --undecorated \
		--skip-taskbar --text-align=center --title=" " \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--field="\\n\\n<big><big><big><big><big><big><big><big><b>$trgt</b></big></big></big></big></big></big></big></big>":lbl \
		--field="<span color='#949494'><span font='monospace'><b>$stgt</b></span></span>\\n\\n\\n":lbl \
		--button="Close":1 \
		--button="   ( $good ) Got It   ":3 \
		--button="   ( $wrong ) Nope   ":4 \
		--width=365 --height=220
	fi
	
	ret=$?
	
	if [[ $ret -eq 3 ]]; then
		play $drts/d.mp3 & sed -i 's/'"$w1"'//g' \
		./fin.tmp & echo "$w1" >> ./fin.ok
		
	elif [[ $ret -eq 4 ]]; then
		play $drts/d.mp3 & echo "$w1" >> ./fin.no
		
	else
		$drts/cls "$2" f && break & exit 1
	fi
	
	let n++
done


