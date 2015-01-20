#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#0
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

$DS/stop.sh T
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic=$(echo "$gtdr" | sed 's|\/|\n|g' | sed -n 8p)
DC_tlt="$DC_tl/$topic"
DM_tlt="$DM_tl/$topic"


if [ -d "$DC_tlt" ]; then

	if [ ! -d "$DM_tlt" ]; then
		
		mkdir "$DM_tlt" "$DM_tlt/words" "$DM_tlt/words/images"
		cd "$DC_tlt"; touch cnfg0 cnfg1 cnfg2 cnfg3 cnfg4 cnfg5
		mkdir ./practice
		echo "$(date +%F)" > cnfg12
		echo "1" > cnfg8
		echo "--make dir"
	fi

	# check index
	chk1="$DC_tlt/cnfg0"
	chk2="$DC_tlt/cnfg1"
	chk3="$DC_tlt/cnfg2"
	chk4="$DC_tlt/cnfg3"
	chk5="$DC_tlt/cnfg4"
	chk6="$DC_tlt/cnfg10"
	
	if [ -n "$(cat "$chk1" | sort -n | uniq -dc)" ]; then
		cat "$chk1" | awk '!array_temp[$0]++' > $DT/ls0.x
		sed '/^$/d' $DT/ls0.x > "$chk1"
	fi
	if [ -n "$(cat "$chk2" | sort -n | uniq -dc)" ]; then
		cat "$chk2" | awk '!array_temp[$0]++' > $DT/ls1.x
		sed '/^$/d' $DT/ls1.x > "$chk2"
	fi
	if [ -n "$(cat "$chk3" | sort -n | uniq -dc)" ]; then
		cat "$chk3" | awk '!array_temp[$0]++' > $DT/ls2.x
		sed '/^$/d' $DT/ls2.x > "$chk3"
	fi
	if [ -n "$(cat "$chk4" | sort -n | uniq -dc)" ]; then
		cat "$chk4" | awk '!array_temp[$0]++' > $DT/ls1.x
		sed '/^$/d' $DT/ls1.x > "$chk4"
	fi
	if [ -n "$(cat "$chk5" | sort -n | uniq -dc)" ]; then
		cat "$chk5" | awk '!array_temp[$0]++' > $DT/ls2.x
		sed '/^$/d' $DT/ls2.x > "$chk5"
	fi
	
	chk1=$(cat "$DC_tlt/cnfg0" | wc -l)
	chk2=$(cat "$DC_tlt/cnfg1" | wc -l)
	chk3=$(cat "$DC_tlt/cnfg2" | wc -l)
	chk4=$(cat "$DC_tlt/cnfg3" | wc -l)
	chk5=$(cat "$DC_tlt/cnfg4" | wc -l)
	stts=$(cat "$DC_tlt/cnfg8")
	
	# try fix if something is wrong
	if [[ $(($chk4 + $chk5)) != $chk1 \
	|| $(($chk2 + $chk3)) != $chk1 || $stts = 13 ]]; then
		sleep 1
		notify-send -i idiomind "$index_err1" "$index_err2" -t 3000 &
		
		[[ -f $DT/ind ]] && rm -f $DT/ind
		[[ -f $DT/ind_ok ]] && rm -f $DT/ind_ok
		
		cd "$DM_tl/$topic"
		for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		ls *.mp3 | sed 's/.mp3//g' > $DT/ind
			
		cd "$DM_tl/$topic/words/"
		for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		ls *.mp3 | sed 's/.mp3//g' >> $DT/ind
		
		rm "$DC_tlt/cnfg3" "$DC_tlt/cnfg4"
		
		if [[ -f "$DC_tlt/.cnfg11" ]]; then
		
			cp -f "$DC_tlt/.cnfg11" "$DC_tlt/cnfg0"
			n=1
			while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
			
				chk1=$(sed -n "$n"p "$DC_tlt/cnfg0")
				if cat "$DT/ind" | grep -Fxo "$chk1"; then
						if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
							echo "$chk1" >> "$DC_tlt/cnfg3"
						elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
							echo "$chk1" >> "$DC_tlt/cnfg4"
						fi
					echo "$chk1" >> $DT/ind_ok
					grep -v -x -v "$chk1" $DT/ind > $DT/ind_
					sed '/^$/d' $DT/ind_ > $DT/ind
				fi
				let n++
			done
		else
			n=1
			while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
			
				chk1=$(sed -n "$n"p "$DT/ind")
					if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
						echo "$chk1" >> "$DC_tlt/cnfg3"
					elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
						echo "$chk1" >> "$DC_tlt/cnfg4"
					fi
					echo "$chk1" >> $DT/ind_ok
				let n++
			done
		fi
		
		if [ $? -ne 0 ]; then
			yad --name=idiomind --image=error --button=gtk-ok:1\
			--text=" $files_err\n\n" --image-on-top --sticky  \
			--width=420 --height=150 --borders=5 --title=Idiomind \
			--skip-taskbar --center --window-icon=idiomind
			$DS/mngr.sh dlt & exit
		fi
		
		n=1
		while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
			chk2=$(sed -n "$n"p "$DT/ind")
			if [[ "$(echo "$chk2" | wc -w)" -eq 1 ]]; then
				echo "$chk2" >> "$DC_tlt/cnfg3"
			elif [[ "$(echo "$chk2" | wc -w)" -gt 1 ]]; then
				echo "$chk2" >> "$DC_tlt/cnfg4"
			fi
			let n++
		done
	
		cat $DT/ind >> $DT/ind_ok
		cp -f $DT/ind_ok "$DC_tlt/cnfg0"
		rm "$DC_tlt/cnfg2"
		in1="$DC_tlt/cnfg0"
		if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
			cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in1"
		fi
		in2="$DC_tlt/cnfg4"
		if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
			cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in2"
		fi
		in3="$DC_tlt/cnfg4"
		if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
			cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in3"
		fi
		cp -f "$in1" "$DC_tlt/cnfg1"
		
		if [[ $stts = "13" ]]; then
			if cat "$DC_tl/.cnfg3" | grep -Fxo "$topic"; then
				echo "6" > "$DC_tlt/cnfg8"
			elif cat "$DC_tl/.cnfg2" | grep -Fxo "$topic"; then
				echo "1" > "$DC_tlt/cnfg8"
			fi
		fi
		[[ ! -f "$DC_tlt/cnfg.11" ]] && cp "$DC_tlt/cnfg0" "$DC_tlt/.cnfg11"
		touch "$DC_tlt/cnfg3" "$DC_tlt/cnfg4"
		
		$DS/mngr.sh mkmn
	fi
	
	# set
	if cat "$DC_tl/.cnfg3" | grep -Fxo "$topic"; then
		echo "$topic" > $DC_s/cnfg8
		echo istll >> $DC_s/cnfg8
		echo "$topic" > $DC_tl/.cnfg8
		echo istll >> $DC_tl/.cnfg8
		echo "$topic" > $DC_s/cnfg6
	else
		echo "$topic" > $DC_s/cnfg8
		echo wn >> $DC_s/cnfg8
		echo "$topic" > $DC_tl/.cnfg8
		echo wn >> $DC_tl/.cnfg8
		echo "$topic" > $DC_s/cnfg6
	fi
	
	# look status
	if [[ $(cat "$DC_tl/.cnfg1" | grep -Fxon "$topic" \
	| sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 31 ]]; then
		if [ -f "$DC_tl/$topic/cnfg9" ]; then
			dts=$(cat "$DC_tl/$topic/cnfg9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tl/$topic/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tl/$topic/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tl/$topic/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tl/$topic/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			nstll=$(grep -Fxo "$topic" "$DC_tl/.cnfg3")
			if [ -n "$nstll" ]; then
				if [ "$RM" -ge 100 ]; then
					echo "9" > "$DC_tl/$topic/cnfg8"
				fi
				if [ "$RM" -ge 150 ]; then
					echo "10" > "$DC_tl/$topic/cnfg8"
				fi
			else
				if [ "$RM" -ge 100 ]; then
					echo "4" > "$DC_tl/$topic/cnfg8"
				fi
				if [ "$RM" -ge 150 ]; then
					echo "5" > "$DC_tl/$topic/cnfg8"
				fi
			fi
		fi
		$DS/mngr.sh mkmn
	fi
	
	sleep 1

	notify-send --icon=idiomind \
	"$topic" "$its_your_topic_now" -t 2000 & exit 1
else
	yad --name=idiomind --image=error --sticky --center \
	--text=" $path_err\n $topic\n" --on-top --image-on-top \
	--width=420 --height=150 --skip-taskbar --window-icon=idiomind \
	--title="$err" --button="Ok:0" & exit 1
fi
