#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
w9=$DC_s/cfg.22
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
	
	fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
	s=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	
	if [ $(echo "$1" | wc -c) -le 8 ]; then
	c="<big><big><big><big>$1</big></big></big></big>"
	elif [ $(echo "$1" | wc -c) -le 14 ]; then
	c="<big><big><big>$1</big></big></big>"
	elif [ $(echo "$1" | wc -c) -gt 14 ]; then
	c="<big>$1</big>"
	fi
	if [ $(echo "$s" | wc -c) -le 8 ]; then
	a="<big><big><big><big>$s</big></big></big></big>"
	elif [ $(echo "$s" | wc -c) -le 14 ]; then
	a="<big><big><big>$s</big></big></big>"
	elif [ $(echo "$s" | wc -c) -gt 14 ]; then
	a="<big>$s</big>"
	fi
	if [[ -f "$drtt/images/$fname.jpg" ]]; then
	img="$drtt/images/$fname.jpg"
	trgts="$c   <small>$means...</small>"
	srces="$a"
	else
	img="/usr/share/idiomind/images/fc.png"
	trgts="<big><big><big>$c</big></big></big>   <small>\n$means...</small>"
	srces="<big><big><big>$a</big></big></big>"
	fi
	}

function cuestion() {
	
	yad --form --align=center --text-align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=3 \
	--buttons-layout=spread \
	--field="$trgts":lbl --width=371 --height=280 \
	--button="$exit":1 \
	--button=" $answer1 > ":0
	}

function answer() {
	
	yad --form --align=center --text-align=center --undecorated \
	--center --on-top --image-on-top --image="$img" \
	--skip-taskbar --title=" " --borders=3 \
	--buttons-layout=spread \
	--field="$srces":lbl --width=371 --height=280 \
	--button="<span color='#818181'>   $no_know   </span>":3 \
	--button="<span color='#818181'>   $ok_know   </span>":2
	}

n=1
while [ $n -le $(cat fin1 | wc -l) ]; do

	trgt=$(sed -n "$n"p fin1)
	fonts "$trgt"
	cuestion
	ret=$(echo "$?")
	
	if [[ $ret = 0 ]]; then
		answer
		ans=$(echo "$?")

		if [[ $ans = 2 ]]; then
			echo "$trgt" | tee -a ok.f $w9
			easy=$(($easy+1))

		elif [[ $ans = 3 ]]; then
			echo "$trgt" | tee -a fin2 w6
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
	while [ $n -le $(cat fin2 | wc -l) ]; do

		trgt=$(sed -n "$n"p fin2)
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
				echo "$trgt" | tee -a fin3 w6
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
