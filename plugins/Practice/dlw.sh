#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/topic.id)
lgtl=$(sed -n 2p ~/.config/idiomind/s/lang)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/plugins/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"

n=1
while [ $n -le $(cat ./stp$1 | wc -l) ]; do

	w1=$(sed -n "$n"p stp$1)
	wrong=$(cat lwin.no | wc -l)
	good=$(cat lwin.ok | wc -l)
	listen="play '$drtt/$w1.mp3'"
	[ $lgtl = Japanese ] || [ $lgtl = Chinese ] && lst=? \
	|| lst=$(echo "$w1" | awk '$1=$1' FS= OFS=" " | tr aeiouáéíóúy ' ')
	
	if [ "$2" = 1 ]; then
		trgt=$(echo "$w1" | tr aeiouáéíóúyñ ' ')
	elif [ "$2" = 2 ]; then
		trgt="$(echo "$wi" | tr iouñ ' ')"
		exc="<span font='ultralight'><span color='#DF6A75'><b><i>!  </i></b></span></span>  "
	fi
	
	if [ -f "$drtt/images/$w1".jpg ]; then
	
		IMAGE="$drtt/images/$w1".jpg
		play "$drtt/$w1".mp3 &
		yad --form --align=center \
		--center --on-top --image="$IMAGE" --image-on-top \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--skip-taskbar --title=" " --undecorated \
		--field="Play:BTN" "$listen" \
		--field="<big><big><big><big><big><big><b>$exc<span color='#949494'>$lst</span></b></big></big></big></big></big></big>":lbl \
		--button=Close:1 \
		--button="   ( $good ) Got It   ":3 \
		--button="   ( $wrong ) Nope   ":4 \
		--width=365 --height=180
			
	else
		play "$drtt/$w1".mp3 &
		yad --form --align=center --undecorated \
		--center --on-top --text-align=center --name=idiomind \
		--window-icon=idiomind --buttons-layout=edge --borders=0 \
		--skip-taskbar  --title=" " --class=idiomind \
		--field="
Play
:BTN" "$listen" \
		--text="\\n\\n\\n<big><big><big><big><big><big><b>$exc<span color='#949494'>$lst</span></b></big></big></big></big></big></big>" \
		--field=" ":lbl \
		--button=Close:1 \
		--button="   ( $good ) Got It   ":3 \
		--button="   ( $wrong ) Nope   ":4 \
		--width=365 --height=220
	fi
	
	ret=$?
	if [[ $ret -eq 3 ]]; then
		play $drts/d.mp3 & sed -i 's/'"$w1"'//g' ./lwin.tmp
		echo "$w1" >> ./lwin.ok
		rm -f /tmp/.idmtp1/FRONT_COVER.jpeg
	elif [[ $ret -eq 4 ]]; then
		play $drts/d.mp3 & echo "$w1" >> ./lwin.no
		rm -f /tmp/.idmtp1/FRONT_COVER.jpeg
	else
		rm -f /tmp/.idmtp1/FRONT_COVER.jpeg
		$drts/cls "$2" w && exit 1
	fi

	let n++
done
