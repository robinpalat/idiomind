#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt"
cd "$DC_tlt/practice"
all=$(cat fin | wc -l)
easy=0
hard=0
ling=0

[[ -f fin2 ]] && rm fin2
[[ -f fin3 ]] && rm fin3

function score() {

	if [ "$(($(cat l_f)+$1))" -ge "$all" ]; then
	
		rm fin fin1 fin2 fin3 ok.f
		echo "$(date "+%a %d %B")" > look_f
		echo 21 > .iconf
		play $drts/all.mp3 & $strt 1 &
		killall df.sh
		exit 1
		
	else
		[[ -f l_f ]] && echo "$(($(cat l_f)+$easy))" > l_f || echo $easy > l_f
		s=$(cat l_f)
		v=$((100*$s/$all))
		
		if [ $v -le 1 ]; then
			echo 1 > .iconf
		elif [ $v -le 5 ]; then
			echo 2 > .iconf
		elif [ $v -le 10 ]; then
			echo 3 > .iconf
		elif [ $v -le 15 ]; then
			echo 4 > .iconf
		elif [ $v -le 20 ]; then
			echo 5 > .iconf
		elif [ $v -le 25 ]; then
			echo 6 > .iconf
		elif [ $v -le 30 ]; then
			echo 7 > .iconf
		elif [ $v -le 35 ]; then
			echo 8 > .iconf
		elif [ $v -le 40 ]; then
			echo 9 > .iconf
		elif [ $v -le 45 ]; then
			echo 10 > .iconf
		elif [ $v -le 50 ]; then
			echo 11 > .iconf
		elif [ $v -le 55 ]; then
			echo 12 > .iconf
		elif [ $v -le 60 ]; then
			echo 13 > .iconf
		elif [ $v -le 65 ]; then
			echo 14 > .iconf
		elif [ $v -le 70 ]; then
			echo 15 > .iconf
		elif [ $v -le 75 ]; then
			echo 16 > .iconf
		elif [ $v -le 80 ]; then
			echo 17 > .iconf
		elif [ $v -le 85 ]; then
			echo 18 > .iconf
		elif [ $v -le 90 ]; then
			echo 19 > .iconf
		elif [ $v -le 95 ]; then
			echo 20 > .iconf
		elif [ $v -eq 100 ]; then
			echo 21 > .iconf
		fi
		
		[[ -f fin2 ]] && rm fin2
		[[ -f fin3 ]] && rm fin3
		$strt 5 $easy $ling $hard & exit 1
	fi
}

function fonts() {
	
	s=$(eyeD3 "$drtt/$1.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	if [[ -f "$drtt/images/$1.jpg" ]]; then
	img="$drtt/images/$1.jpg"
	trgts="<big><big><big><big>$1</big></big></big></big>   <small><tt>$means</tt>...</small>"
	srces="<big><big><big><big><b>$s</b></big></big></big></big>"
	else
	img="/usr/share/idiomind/images/fc.png"
	trgts="<big><big><big><big><big><big><big>$1</big></big></big></big></big></big></big>   <small><tt>$means</tt>...</small>"
	srces="<big><big><big><big><big><big><big><b>$s</b></big></big></big></big></big></big></big>"
	fi
	}

function cuestion() {
	
	yad --form --align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=0 \
	--window-icon=idiomind --buttons-layout=edge \
	--field="$trgts":lbl --width=365 --height=280 \
	--button="gtk-media-stop":1 \
	--button="      $answer1 >     ":0
	}

function answer() {
	
	yad --form --align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=0 \
	--window-icon=idiomind --buttons-layout=spread \
	--field="$srces":lbl --width=365 --height=280 \
	--button="      $no_know      ":3 \
	--button="      $ok_know      ":2
	
	}

n=1
while [ $n -le $(cat ./fin1 | wc -l) ]; do

	trgt=$(sed -n "$n"p ./fin1)
	fonts "$trgt"
	cuestion
	ret=$(echo "$?")
	
	if [[ $ret = 0 ]]; then
		answer
		ans=$(echo "$?")

		if [[ $ans = 2 ]]; then
			echo "$trgt" >> ok.f
			easy=$(($easy+1))

		elif [[ $ans = 3 ]]; then
			echo "$trgt" >> fin2
			hard=$(($hard+1))
		fi

	elif [[ $ret = 1 ]]; then
		$drts/cls f $easy $ling $hard $all &
		break &
		exit 1
		
	fi
	let n++
done

if [[ ! -f fin2 ]]; then

	score $easy
	
else
	n=1
	while [ $n -le $(cat ./fin2 | wc -l) ]; do

		trgt=$(sed -n "$n"p ./fin2)
		fonts "$trgt"
		cuestion
		ret=$(echo "$?")
		
		if [[ $ret = 0 ]]; then
			answer
			ans=$(echo "$?")
			
			if [[ $ans = 2 ]]; then
				hard=$(($hard-1))
				ling=$(($ling+1))
				
			elif [[ $ans = 3 ]]; then
				echo "$trgt" >> fin3
			fi
			
		elif [[ $ret = 1 ]]; then
			$drts/cls f $easy $ling $hard $all &
			break &
			exit 1
		fi
		let n++
	done
	
	score $easy
fi
