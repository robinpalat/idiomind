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
		cd "$DC_tlt"; touch cfg.0 cfg.1 cfg.2 cfg.3 cfg.4 cfg.5
		echo "$(date +%F)" > cfg.12
		echo "1" > cfg.8
		cd $HOME
	fi

	# check index
	[[ ! -f "$DC_tlt/cfg.0" ]] && touch "$DC_tlt/cfg.0"
	chk1="$DC_tlt/cfg.0"
	[[ ! -f "$DC_tlt/cfg.1" ]] && touch "$DC_tlt/cfg.1"
	chk2="$DC_tlt/cfg.1"
	[[ ! -f "$DC_tlt/cfg.2" ]] && touch "$DC_tlt/cfg.2"
	chk3="$DC_tlt/cfg.2"
	[[ ! -f "$DC_tlt/cfg.3" ]] && touch "$DC_tlt/cfg.3"
	chk4="$DC_tlt/cfg.3"
	[[ ! -f "$DC_tlt/cfg.4" ]] && touch "$DC_tlt/cfg.4"
	chk5="$DC_tlt/cfg.4"
	[[ ! -f "$DC_tlt/cfg.10" ]] && touch "$DC_tlt/cfg.10"
	chk6="$DC_tlt/cfg.10"
	
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
	
	chk1=$(cat "$DC_tlt/cfg.0" | wc -l)
	chk2=$(cat "$DC_tlt/cfg.1" | wc -l)
	chk3=$(cat "$DC_tlt/cfg.2" | wc -l)
	chk4=$(cat "$DC_tlt/cfg.3" | wc -l)
	chk5=$(cat "$DC_tlt/cfg.4" | wc -l)
	stts=$(cat "$DC_tlt/cfg.8")
	
	# try fix if something is wrong
	if [[ $(($chk4 + $chk5)) != $chk1 \
	|| $(($chk2 + $chk3)) != $chk1 || $stts = 13 ]]; then
			sleep 1
			notify-send -i idiomind "$index_err1" "$index_err2" -t 3000 &

			[[ -f $DT/trgt_s ]] && rm -f $DT/trgt_s
			[[ -f $DT/trgt_w ]] && rm -f $DT/trgt_w
			[[ -f $DT/cfg.5 ]] && rm -f $DT/cfg.5

			cd "$DM_tl/$topic"
			for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
			if [ -f ".mp3" ]; then rm .mp3; fi
			ls *.mp3 > $DT/ind_s
				
			cd "$DM_tl/$topic/words/"
			for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
			if [ -f ".mp3" ]; then rm .mp3; fi
			ls *.mp3  >> $DT/ind_w
			
			n=1
			while [[ $n -le $(cat "$DT/ind_s" | wc -l) ]]; do
				
					fname=$(sed -n "$n"p "$DT/ind_s")
					tgs=$(eyeD3 "$DM_tlt/$fname")
					trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
					lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
					echo "$trgt" >> $DT/trgt_s
					echo "$lwrd" >> $DT/cfg.5
					let n++
			done
			n=1
			while [[ $n -le $(cat "$DT/ind_w" | wc -l) ]]; do
				
					fname=$(sed -n "$n"p "$DT/ind_w")
					trgt=$(eyeD3 "$DM_tlt/words/$fname" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
					echo "$trgt" >> $DT/trgt_w
					let n++
			done
			
			rm "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"
			if [[ -f "$DC_tlt/.cfg.11" ]]; then
			
				cp -f "$DC_tlt/.cfg.11" "$DC_tlt/cfg.0"
				cp -f "$DC_tlt/.cfg.11" "$DC_tlt/cfg.1"
				mv -f $DT/cfg.5 "$DC_tlt/cfg.5"
				n=1
				while [[ $n -le $(cat "$DC_tlt/cfg.0" | wc -l) ]]; do
					chk1=$(sed -n "$n"p "$DC_tlt/cfg.0")
					if cat "$DT/trgt_s" | grep -Fxo "$chk1"; then
						echo "$chk1" >> "$DC_tlt/cfg.4"
					fi
					if cat "$DT/trgt_w" | grep -Fxo "$chk1"; then
							echo "$chk1" >> "$DC_tlt/cfg.3"
					fi
					let n++
				done

			else
				cat $DT/trgt_s $DT/trgt_w > "$DC_tlt/.cfg.11"
				cp -f "$DC_tlt/.cfg.11" "$DC_tlt/cfg.0"
				cp -f "$DC_tlt/.cfg.11" "$DC_tlt/cfg.1"
				mv -f $DT/trgt_s "$DC_tlt/cfg.4"
				mv -f $DT/trgt_w "$DC_tlt/cfg.3"
				mv -f $DT/cfg.5 "$DC_tlt/cfg.5"
			fi
			
			if [ $? -ne 0 ]; then
				yad --name=idiomind --image=error --button=gtk-ok:1 \
				--text=" $files_err\n\n" --image-on-top --sticky  \
				--width=360 --height=120 --borders=3 --title=Idiomind \
				--skip-taskbar --center --window-icon=idiomind & exit 1
			fi
			
			rm "$DC_tlt/cfg.2"
			in1="$DC_tlt/cfg.0"
			if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
				cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
				sed '/^$/d' $DT/ind > "$in1"
			fi
			in2="$DC_tlt/cfg.4"
			if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
				cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
				sed '/^$/d' $DT/ind > "$in2"
			fi
			in3="$DC_tlt/cfg.4"
			if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
				cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
				sed '/^$/d' $DT/ind > "$in3"
			fi
			cp -f "$in1" "$DC_tlt/cfg.1"
			
			if [[ $stts = "13" ]]; then
				if cat "$DC_tl/.cfg.3" | grep -Fxo "$topic"; then
					echo "6" > "$DC_tlt/cfg.8"
				elif cat "$DC_tl/.cfg.2" | grep -Fxo "$topic"; then
					echo "1" > "$DC_tlt/cfg.8"
				else
					echo "1" > "$DC_tlt/cfg.8"
				fi
			fi
			
			[[ ! -f "$DC_tlt/cnfg.11" ]] && cp "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
			touch "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"
			
			$DS/mngr.sh mkmn
	fi
	
	# set
	if cat "$DC_tl/.cfg.3" | grep -Fxo "$topic"; then
		echo "$topic" > $DC_s/cfg.8
		echo istll >> $DC_s/cfg.8
		echo "$topic" > $DC_tl/.cfg.8
		echo istll >> $DC_tl/.cfg.8
		echo "$topic" > $DC_s/cfg.6
	else
		echo "$topic" > $DC_s/cfg.8
		echo wn >> $DC_s/cfg.8
		echo "$topic" > $DC_tl/.cfg.8
		echo wn >> $DC_tl/.cfg.8
		echo "$topic" > $DC_s/cfg.6
	fi
	
	# look status
	if [[ $(cat "$DC_tl/.cfg.1" | grep -Fxon "$topic" \
	| sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
		if [ -f "$DC_tl/$topic/cfg.9" ]; then
			dts=$(cat "$DC_tl/$topic/cfg.9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tl/$topic/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tl/$topic/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tl/$topic/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tl/$topic/cfg.9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			nstll=$(grep -Fxo "$topic" "$DC_tl/.cfg.3")
			if [ -n "$nstll" ]; then
				if [ "$RM" -ge 100 ]; then
					echo "9" > "$DC_tl/$topic/cfg.8"
				fi
				if [ "$RM" -ge 150 ]; then
					echo "10" > "$DC_tl/$topic/cfg.8"
				fi
			else
				if [ "$RM" -ge 100 ]; then
					echo "4" > "$DC_tl/$topic/cfg.8"
				fi
				if [ "$RM" -ge 150 ]; then
					echo "5" > "$DC_tl/$topic/cfg.8"
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
	--width=360 --height=120 --skip-taskbar --window-icon=idiomind \
	--title="$err" --button="Ok:0" --borders=3 & exit 1
fi
