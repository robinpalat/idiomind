#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/words"
drts="/usr/share/idiomind/addons/Practice/"
cd "$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"

n=1
while [ $n -le $(cat ./lwin$1 | wc -l) ]; do
	trgt=$(sed -n "$n"p lwin$1)
	listen="play '$drtt/$trgt.mp3'"
	
	if [ "$1" = 1 ]; then
		[[ $lgtl = Japanese ]] || [[ $lgtl = Chinese ]] && lst=? || lst="$(echo $trgt | sed "s/\b\(.\)/\u\1/g" | sed "s|[a-z]|"\*"|g" | sed "s| |\t|g")"
		
		


		
		
		
	elif [ "$1" = 2 ]; then
		[[ $lgtl = Japanese ]] || [[ $lgtl = Chinese ]] && lst=? || lst=$(echo "$trgt" | awk '$1=$1' FS= OFS=" " | tr aeiouy '*')
	fi
	
	if [[ -f "$drtt/images/$trgt.jpg" ]]; then
	img="$drtt/images/$trgt.jpg"
	else
	img="/usr/share/idiomind/images/fc.png"
	fi
	play "$drtt/$w1".mp3 &
	yad --form --align=center \
	--center --on-top --image="$img" --image-on-top \
	--window-icon=idiomind --buttons-layout=edge --borders=0 \
	--skip-taskbar --title=" " --undecorated \
	--field="<big><big><big><big><big><b><span color='#949494'>$lst</span></b></big></big></big></big></big>\n":lbl \
	--button=gtk-close:1 \
	--button=" Play ":"$listen" \
	--button=" Got It ":3 \
	--button=" Nope ":4 \
	--width=365 --height=360
	
	ret=$?
	
	if [[ $ret -eq 3 ]]; then
		if [[ $1 = 1 ]]; then
			sed -i 's/'"$trgt"'//g' lwin.tmp & echo "$trgt" >> ./lwin.1.ok
		else
			echo "$trgt" >> ./lwin.2.ok
		fi
	elif [[ $ret -eq 4 ]]; then
		echo "$trgt" >> ./lwin.$1.no
	else
		$drts/cls "$1" w && exit 1
	fi
	let n++
done
