#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
drts="$DS/practice/"
strt="$drts/strt.sh"
u=$(echo "$(whoami)")
DT=/tmp/.idmtp1.$u
cd "$DC_tlt/practice"
all=$(cat lsin | wc -l)
easy=0
hard=0
ling=0
f=0

function score() {

	if [ "$1" -ge "$all" ] ; then
		rm lsin ok.s
		echo "$(date "+%a %d %B")" > look_ls
		echo 21 > .iconls
		play $drts/all.mp3 & $strt 4 &
		killall dls.sh
		exit 1
		
	else
		[[ -f l_s ]] && echo "$(($(cat l_s)+$easy))" > l_s || echo $easy > l_s
		s=$(cat l_s)
		v=$((100*$s/$all))
		if [ $v -le 1 ]; then
			echo 1 > .iconls
		elif [ $v -le 5 ]; then
			echo 2 > .iconls
		elif [ $v -le 10 ]; then
			echo 3 > .iconls
		elif [ $v -le 15 ]; then
			echo 4 > .iconls
		elif [ $v -le 20 ]; then
			echo 5 > .iconls
		elif [ $v -le 25 ]; then
			echo 6 > .iconls
		elif [ $v -le 30 ]; then
			echo 7 > .iconls
		elif [ $v -le 35 ]; then
			echo 8 > .iconls
		elif [ $v -le 40 ]; then
			echo 9 > .iconls
		elif [ $v -le 45 ]; then
			echo 10 > .iconls
		elif [ $v -le 50 ]; then
			echo 11 > .iconls
		elif [ $v -le 55 ]; then
			echo 12 > .iconls
		elif [ $v -le 60 ]; then
			echo 13 > .iconls
		elif [ $v -le 65 ]; then
			echo 14 > .iconls
		elif [ $v -le 70 ]; then
			echo 15 > .iconls
		elif [ $v -le 75 ]; then
			echo 16 > .iconls
		elif [ $v -le 80 ]; then
			echo 17 > .iconls
		elif [ $v -le 85 ]; then
			echo 18 > .iconls
		elif [ $v -le 90 ]; then
			echo 19 > .iconls
		elif [ $v -le 95 ]; then
			echo 20 > .iconls
		elif [ $v -eq 100 ]; then
			echo 21 > .iconls
		fi

		$strt 8 $easy $ling $hard & exit 1
	fi
}


function dialog1() {
	
	SE=$(yad --center --text-info --image="$IMAGE" "$info" \
	--fontname="Verdana Black" --justify=fill --editable --wrap \
	--buttons-layout=end --borders=0 --title=" " --image-on-top \
	--skip-taskbar --margins=8 --text-align=left --height=400 --width=460 \
	--align=left --window-icon=idiomind --fore=4A4A4A \
	--button=Hint:"/usr/share/idiomind//practice/hint.sh '$n'" \
	--button=Listen:"play '$DM_tlt/$1.mp3'" \
	--button="  Ok >> ":0)
	}
	
function dialog2() {

	SE=$(yad --center --text-info --fore=4A4A4A \
	--fontname="Verdana Black" --justify=fill --editable --wrap \
	--buttons-layout=end --borders=0 --title=" " "$info" \
	--skip-taskbar --margins=8 --text-align=left --height=160 --width=460 \
	--align=left --window-icon=idiomind \
	--button=$hint:"/usr/share/idiomind//practice/hint.sh '$n'" \
	--button="$listen":"play '$DM_tlt/$1.mp3'" \
	--button="      Ok >     ":0)
	}
	
function get_image_text() {
	
	WEN=$(eyeD3 "$DM_tlt/$1".mp3 | \
	grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	eyeD3 --write-images=$DT "$DM_tlt/$1.mp3"
	echo "$WEN" | awk '{print tolower($0)}' > ./sentc
	}

function result() {
	
	echo "$SE" | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > ing
	cat sentc | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > all
	(
	ff="$(cat ing | sed 's/ /\n/g')"
	n=1
	while [ $n -le $(echo "$ff" | wc -l) ]; do
		line="$(echo "$ff" | sed -n "$n"p )"
		if cat all | grep -o "$line"; then
			[[ -n "$line" ]] && echo "<span color='#3A9000'>$line</span>" >> wrds
			[[ -n "$line" ]] && echo "$line" >> w.ok
		else
			[[ -n "$line" ]] && echo "<span color='#9E3E18'>$line</span>" >> wrds
		fi
		let n++
	done
	)
	OK=$(cat wrds | tr '\n' ' ')
	cat sentc | sed 's/ /\n/g' > all
	porc=$((100*$(cat w.ok | wc -l)/$(cat all | wc -l)))
	
	if [ $porc -ge 70 ]; then
		echo "$trgt" >> ok.s
		easy=$(($easy+1))
		prc="<span background='#3AB452'><span color='#FFFFFF'> <b>$porc% Pass! </b></span></span>"
		
	elif [ $porc -ge 50 ]; then
		ling=$(($ling+1))
		prc="<span background='#E5801D'><span color='#FFFFFF'> <b>$porc%</b> </span></span>"
		
	else
		hard=$(($hard+1))
		prc="<span background='#D11B5D'><span color='#FFFFFF'> <b>$porc%</b> </span></span>"
	fi
	rm allc sentc
	}
	
function check() {
	yad --form --center --name=idiomind --buttons-layout=end \
	--width=470 --height=230 --on-top --skip-taskbar --scroll \
	--class=idiomind $aut --wrap --window-icon=idiomind \
	--text-align=left --borders=5 --selectable-labels \
	--title="" --button=$listen:"play '$DM_tlt/$1.mp3'" \
	--button="$next__sentence:2" \
	--field="<big>$WEN</big>\\n":lbl \
	--field="":lbl \
	--field="$OK  <small>$prc</small>\\n":lbl
	}

n=1
while [ $n -le $(cat lsin | wc -l) ]; do

	namefile=$(sed -n "$n"p lsin)
	if [[ $n = 1 ]]; then
	info="--text=<sup><tt> $write_sentence...</tt></sup>"
	else
	info=""
	fi
	
	if [ -f "$DM_tlt/$namefile".mp3 ]; then
		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			rm -f "$DT/ILLUSTRATION".jpeg
		fi
		
		get_image_text "$namefile"

		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			IMAGE="$DT/ILLUSTRATION".jpeg
			(sleep 0.5 && play "$DM_tlt/$namefile".mp3) &
			dialog1 "$namefile"
		else
			(sleep 0.5 && play "$DM_tlt/$namefile".mp3) &
			dialog2 "$namefile"
		fi
		ret=$(echo "$?")
		
		if [[ $ret -eq 0 ]]; then
			killall play
			result "$namefile"
		else
			$drts/cls s $easy $ling $hard $all &
			break &
			exit 1
		fi
	
		check "$namefile"
		ret=$(echo "$?")
		
		if [[ $ret -eq 2 ]]; then
			rm -f w.ok wrds $DT/*.jpeg *.png &
			killall play &
		else
			rm -f w.ok wrds $DT/*.jpeg *.png
			$drts/cls s $easy $ling $hard $all &
			break &
			exit 1
		fi
	fi
	let n++
done

score $easy

