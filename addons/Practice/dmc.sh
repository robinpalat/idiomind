#!/bin/bash

source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/addons/Practice/"
strt="$drts/strt"
cd "$DC_tlt/Practice"
all=$(cat mcin | wc -l)
easy=0
hard=0
ling=0

[[ ! -f mcin2 ]] && rm mcin2

function score() {

	if [ "$1" -ge "$all" ] ; then
		rm mcin mcin1 mcin2 mcin3 ok.m
		echo "$(date "+%a %d %B")" > look_mc
		echo 21 > .iconmc
		play $drts/all.mp3 & $strt 2 &
		killall dmc.sh
		exit 1
		
	else
		[[ -f l_mc ]] && echo "$(($(cat l_mc)+$easy))" > l_mc || echo $easy > l_mc
		s=$(cat l_mc)
		v=$((100*$s/$all))
		if [ $v -le 1 ]; then
			echo 1 > .iconmc
		elif [ $v -le 5 ]; then
			echo 2 > .iconmc
		elif [ $v -le 10 ]; then
			echo 3 > .iconmc
		elif [ $v -le 15 ]; then
			echo 4 > .iconmc
		elif [ $v -le 20 ]; then
			echo 5 > .iconmc
		elif [ $v -le 25 ]; then
			echo 6 > .iconmc
		elif [ $v -le 30 ]; then
			echo 7 > .iconmc
		elif [ $v -le 35 ]; then
			echo 8 > .iconmc
		elif [ $v -le 40 ]; then
			echo 9 > .iconmc
		elif [ $v -le 45 ]; then
			echo 10 > .iconmc
		elif [ $v -le 50 ]; then
			echo 11 > .iconmc
		elif [ $v -le 55 ]; then
			echo 12 > .iconmc
		elif [ $v -le 60 ]; then
			echo 13 > .iconmc
		elif [ $v -le 65 ]; then
			echo 14 > .iconmc
		elif [ $v -le 70 ]; then
			echo 15 > .iconmc
		elif [ $v -le 75 ]; then
			echo 16 > .iconmc
		elif [ $v -le 80 ]; then
			echo 17 > .iconmc
		elif [ $v -le 85 ]; then
			echo 18 > .iconmc
		elif [ $v -le 90 ]; then
			echo 19 > .iconmc
		elif [ $v -le 95 ]; then
			echo 20 > .iconmc
		elif [ $v -eq 100 ]; then
			echo 21 > .iconmc
		fi
		
		$strt 6 $easy $ling $hard & exit 1
	fi
}

function fonts() {
	
	tgt="$1"
	file="$drtt/$1.mp3"
	wes=$(eyeD3 "$file" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	ras=$(sort -Ru word1.idx | egrep -v "$wes" | head -4)
	ess=$(grep "$wes" word1.idx)
	echo "$ras
$ess" > word2.tmp
	ells=$(sort -Ru word2.tmp | head -6)
	echo "$ells" > word2.tmp
	sed '/^$/d' word2.tmp > word2.id
	trgts="<big><big><big><big><big><big><big><b>$1</b></big></big></big></big></big></big></big>"
	}

function mchoise() {
	
	dlg=$(cat word2.id | awk '{print "\n"$0}' \
	| yad --list --on-top --skip-taskbar \
	--width=365 --height=340 --center --buttons-layout=edge --undecorated \
	--text-align=center --no-headers --borders=5 --window-icon=idiomind \
	--button=gtk-close:1 \
	--button="  Ok  ":0 --title=" " \
	--text="\\n$trgts\\n\\n\\n" \
	--column=Opcion --column=Opciodn)
}

n=1
while [ $n -le $(cat ./mcin1 | wc -l) ]; do

	trgt=$(sed -n "$n"p ./mcin1)
	fonts "$trgt"
	mchoise "$trgt"
	ret=$(echo "$?")
	
	if [[ $ret = 0 ]]; then
	
		if echo "$dlg" | grep "$wes"; then
			echo "$trgt" >> ok.m
			easy=$(($easy+1))
			
		else
			echo "$trgt" >> mcin2
			hard=$(($hard+1))
		fi	
			
	elif [[ $ret = 1 ]]; then
		$drts/cls m $easy $ling $hard $all &
		break &
		exit 1
	fi
	let n++
done
	
if [[ ! -f mcin2 ]]; then

	score $easy
	
else
	n=1
	while [ $n -le $(cat mcin2 | wc -l) ]; do

		trgt=$(sed -n "$n"p mcin2)
		fonts "$trgt"
		mchoise "$trgt"
		ret=$(echo "$?")
		
		if [[ $ret = 0 ]]; then
		
			if echo "$dlg" | grep "$wes"; then
				hard=$(($hard-1))
				ling=$(($ling+1))
				
			else
				echo "$trgt" >> mcin3
			fi	

		elif [[ $ret = 1 ]]; then
			$drts/cls m $easy $ling $hard $all &
			break &
			exit 1
		fi
		let n++
	done
	
	score $easy
fi
