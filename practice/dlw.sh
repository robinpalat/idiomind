#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt"
cd "$DC_tlt/practice"
all=$(cat lwin | wc -l)
easy=0
hard=0
ling=0

[[ -f lwin2 ]] && rm lwin2
[[ -f lwin3 ]] && rm lwin3

function score() {

	if [ "$(($(cat l_w)+$1))" -ge "$all" ] ; then
		rm lwin lwin1 lwin2 lwin3 ok.w
		echo "$(date "+%a %d %B")" > look_lw
		echo 21 > .iconlw
		play $drts/all.mp3 & $strt 3 &
		killall dlw.sh
		exit 1
		
	else
		[[ -f l_w ]] && echo "$(($(cat l_w)+$easy))" > l_w || echo $easy > l_w
		s=$(cat l_w)
		v=$((100*$s/$all))
		if [ $v -le 1 ]; then
			echo 1 > .iconlw
		elif [ $v -le 5 ]; then
			echo 2 > .iconlw
		elif [ $v -le 10 ]; then
			echo 3 > .iconlw
		elif [ $v -le 15 ]; then
			echo 4 > .iconlw
		elif [ $v -le 20 ]; then
			echo 5 > .iconlw
		elif [ $v -le 25 ]; then
			echo 6 > .iconlw
		elif [ $v -le 30 ]; then
			echo 7 > .iconlw
		elif [ $v -le 35 ]; then
			echo 8 > .iconlw
		elif [ $v -le 40 ]; then
			echo 9 > .iconlw
		elif [ $v -le 45 ]; then
			echo 10 > .iconlw
		elif [ $v -le 50 ]; then
			echo 11 > .iconlw
		elif [ $v -le 55 ]; then
			echo 12 > .iconlw
		elif [ $v -le 60 ]; then
			echo 13 > .iconlw
		elif [ $v -le 65 ]; then
			echo 14 > .iconlw
		elif [ $v -le 70 ]; then
			echo 15 > .iconlw
		elif [ $v -le 75 ]; then
			echo 16 > .iconlw
		elif [ $v -le 80 ]; then
			echo 17 > .iconlw
		elif [ $v -le 85 ]; then
			echo 18 > .iconlw
		elif [ $v -le 90 ]; then
			echo 19 > .iconlw
		elif [ $v -le 95 ]; then
			echo 20 > .iconlw
		elif [ $v -eq 100 ]; then
			echo 21 > .iconlw
		fi
		
		[[ -f lwin2 ]] && rm lwin2
		[[ -f lwin3 ]] && rm lwin3
		$strt 7 $easy $ling $hard & exit 1
	fi
}

function fonts() {
	
	#if [ "$1" = 1 ]; then
		#[[ $lgtl = Japanese ]] || [[ $lgtl = Chinese ]] && lst=? || lst="${w1:0:1}"
	#elif [ "$1" = 2 ]; then
	[[ $lgtl = Japanese ]] || [[ $lgtl = Chinese ]] && lst="" || lst=$(echo "$1" | awk '$1=$1' FS= OFS=" " | tr aeiouy ' ')
	#fi
	
	#lt="$1"
	#[[ $(echo "$lt" | wc -c) -ge 8 ]] && lt="${lt:0:40}..."
	#[[ $(echo "$lt" | wc -c) -ge 8 ]] && lt="${lt:0:40}..."
	
	if [[ -f "$drtt/images/$1.jpg" ]]; then
	img="$drtt/images/$1.jpg"
	trgts="<big>$lst</big>"
	tr="<big><big><big><big><b>$1</b></big></big></big></big>"
	else
	img="/usr/share/idiomind/images/fc.png"
	trgts="<big><big>$lst</big></big>"
	tr="<big><big><big><big><big><big><big><b>$1</b></big></big></big></big></big></big></big>"
	fi
	}

function cuestion() {
	
	play="play '$drtt/$1.mp3'"
	play "$drtt/$1".mp3 &
	yad --form --align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=0 \
	--window-icon=idiomind --buttons-layout=edge \
	--field="<span color='#808080'>$trgts</span>":lbl \
	--width=365 --height=280 \
	--button="gtk-media-stop":1 \
	--button="$listen":"$play" \
	--button="$answer2 >":0
	}

function answer() {
	
	yad --form --align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=0 \
	--window-icon=idiomind --buttons-layout=spread \
	--field="$tr":lbl --width=365 --height=280 \
	--button="$listen":"$play" \
	--button="$no_know":3 \
	--button="$ok_know":2
	
	}

n=1
while [ $n -le $(cat ./lwin1 | wc -l) ]; do

	trgt=$(sed -n "$n"p ./lwin1)
	fonts "$trgt"
	cuestion "$trgt"
	ret=$(echo "$?")
	
	if [[ $ret = 0 ]]; then
		answer "$trgt"
		ans=$(echo "$?")

		if [[ $ans = 2 ]]; then
			echo "$trgt" >> ok.w
			easy=$(($easy+1))

		elif [[ $ans = 3 ]]; then
			echo "$trgt" >> lwin2
			hard=$(($hard+1))
		fi

	elif [[ $ret = 1 ]]; then
		$drts/cls w $easy $ling $hard $all &
		break &
		exit 1
		
	fi
	let n++
done

if [[ ! -f lwin2 ]]; then

	score $easy
	
else
	n=1
	while [ $n -le $(cat ./lwin2 | wc -l) ]; do

		trgt=$(sed -n "$n"p ./lwin2)
		fonts "$trgt"
		cuestion "$trgt"
		ret=$(echo "$?")
		
		if [[ $ret = 0 ]]; then
			answer "$trgt"
			ans=$(echo "$?")
			
			if [[ $ans = 2 ]]; then
				hard=$(($hard-1))
				ling=$(($ling+1))
				
			elif [[ $ans = 3 ]]; then
				echo "$trgt" >> lwin3
			fi
			
		elif [[ $ret = 1 ]]; then
			$drts/cls w $easy $ling $hard $all &
			break &
			exit 1
		fi
		let n++
	done
	
	score $easy
fi
