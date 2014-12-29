#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
$DS/stop.sh T
icn=$DS/icon/cnn.png
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic=$(echo "$gtdr" | sed 's|\/|\n|g' | sed -n 8p)
DC_tlt="$DC_tl/$topic"
if [[ "$(echo "$topic" \
| wc -c)" -gt 38 ]]; then
	title="${topic:0:40}..."
else
	title="$topic"
fi

if [ $1 = 2 ]; then
	if cat "$DC_tl/.nstll" | grep -Fxo "$topic"; then
		$DC_s/chng.sh $DS/ifs/info2 2 & exit 1
	else
		echo "$topic" > $DC_s/fnew.id
		echo "$title" >> $DC_s/fnew.id
		echo "Normal" >> $DC_s/fnew.id
		sleep 1
		$DS/default/pnls & exit 1
	fi
fi

if [ -d "$DC_tlt" ]; then
	chk1="$DC_tlt/.t-inx"
	chk2="$DC_tlt/.tlng-inx"
	chk3="$DC_tlt/.tok-inx"
	chk4="$DC_tlt/.winx"
	chk5="$DC_tlt/.sinx"
	chk6="$DC_tlt/nt"
	
	if [[ -z "$cat chk1" ]]; then
		cp -f "$DC_tlt/.t-inx~" "$DC_tlt/.t-inx"
	fi
	if [[ -z "$cat chk2" ]]; then
		cp -f "$DC_tlt/.tlng-inx~" "$DC_tlt/.tlng-inx"
	fi
	if [[ -z "$cat chk3" ]]; then
		cp -f "$DC_tlt/.tok-inx~" "$DC_tlt/.tok-inx"
	fi
	if [[ -z "$cat chk6" ]]; then
		cp -f "$DC_tlt/.nt~" "$DC_tlt/nt"
	fi
	
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
	
	chk1=$(cat "$DC_tlt/.t-inx" | wc -l)
	chk2=$(cat "$DC_tlt/.tlng-inx" | wc -l)
	chk3=$(cat "$DC_tlt/.tok-inx" | wc -l)
	chk4=$(cat "$DC_tlt/.winx" | wc -l)
	chk5=$(cat "$DC_tlt/.sinx" | wc -l)
	
	if [[ $(($chk4 + $chk5)) != $chk1 \
	|| $(($chk2 + $chk3)) != $chk1 ]]; then
		notify-send --icon=error "Error en indice" \
		"Repararando..." -t 2000 &
		
		rm -f $DT/ind
		rm -f $DT/ind_ok
		
		cd "$DM_tl/$topic"
		for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		ls *.mp3 | sed 's/.mp3//g' > $DT/ind
			
		cd "$DM_tl/$topic/words/"
		for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		ls *.mp3 | sed 's/.mp3//g' >> $DT/ind
		
		rm "$DC_tlt/.winx"
		rm "$DC_tlt/.sinx"
		n=1
		while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
			chk1=$(sed -n "$n"p "$DC_tlt/.t-inx")
			if cat "$DT/ind" | grep -Fxo "$chk1"; then
					if [[ "$(echo "$chk1" | wc -w)" -eq 1 ]]; then
						echo "$chk1" >> "$DC_tlt/.winx"
					elif [[ "$(echo "$chk1" | wc -w)" -gt 1 ]]; then
						echo "$chk1" >> "$DC_tlt/.sinx"
					fi
				echo "$chk1" >> $DT/ind_ok
				grep -v -x -v "$chk1" $DT/ind > $DT/ind_
				sed '/^$/d' $DT/ind_ > $DT/ind
			fi
			let n++
		done
		
		n=1
		while [[ $n -le $(cat "$DT/ind" | wc -l) ]]; do
			chk2=$(sed -n "$n"p "$DT/ind")
			if [[ "$(echo "$chk2" | wc -w)" -eq 1 ]]; then
				echo "$chk2" >> "$DC_tlt/.winx"
			elif [[ "$(echo "$chk2" | wc -w)" -gt 1 ]]; then
				echo "$chk2" >> "$DC_tlt/.sinx"
			fi
			let n++
		done
	
		cat $DT/ind >> $DT/ind_ok
		cp -f $DT/ind_ok "$DC_tlt/.t-inx"
		rm "$DC_tlt/.tok-inx"
		in1="$DC_tlt/.t-inx"
		if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
			cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in1"
		fi
		in2="$DC_tlt/.sinx"
		if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
			cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in2"
		fi
		in3="$DC_tlt/.sinx"
		if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
			cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in3"
		fi
		cp -f "$in1" "$DC_tlt/.tlng-inx"
	fi
	
	if cat "$DC_tl/.nstll" | grep -Fxo "$topic"; then
	
		$ > $DC_s/fnew.id
		echo "- $title" > $DC_s/topic_m
		echo "$topic" > $DC_s/topic.id
		echo istll >> $DC_s/topic.id
		echo "$title" >> $DC_s/topic.id
		echo "$topic" > $DC_tl/.lst
		echo istll >> $DC_tl/.lst
	else
		echo "- $title" > $DC_s/topic_m
		echo "$topic" > $DC_s/topic.id
		echo "$topic" > $DC_s/fnew.id
		echo "$title" >> $DC_s/fnew.id
		echo wn >> $DC_s/topic.id
		echo "$title" >> $DC_s/topic.id
		echo "$topic" > $DC_tl/.lst
		echo wn >> $DC_tl/.lst
	fi
	
	if [[ $(cat "$DC_tl/.in" | grep -Fxon "$topic" \
	| sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 31 ]]; then
		if [ -f "$DC_tl/$topic/.trw" ]; then
			dts=$(cat "$DC_tl/$topic/.trw" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tl/$topic/.trw")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tl/$topic/.trw")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/25))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tl/$topic/.trw")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tl/$topic/.trw")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/150))
			fi
			nstll=$(grep -Fxo "$topic" "$DC_tl/.nstll")
			if [ -n "$nstll" ]; then
				if [ "$RM" -ge 100 ]; then
					echo "9" > "$DC_tl/$topic/.stts"
				fi
				if [ "$RM" -ge 200 ]; then
					echo "10" > "$DC_tl/$topic/.stts"
				fi
			else
				if [ "$RM" -ge 100 ]; then
					echo "4" > "$DC_tl/$topic/.stts"
				fi
				if [ "$RM" -ge 200 ]; then
					echo "5" > "$DC_tl/$topic/.stts"
				fi
			fi
		fi
	fi
	
	sleep 1
	notify-send --icon=$icn \
	"$topic" "It's your topic now" -t 2000 & exit
else
	$yad --name=idiomind \
	--image="error" --sticky --center \
	--text=" <b>no se encuentra la ruta del archivo  </b>\\n para el topic : <b>$topic</b>   \\n" --on-top \
	--image-on-top --width=400 --height=80 --borders=3 \
	--skip-taskbar --window-icon=idiomind \
	--title="Error" --button="gtk-ok:0" & exit
fi
