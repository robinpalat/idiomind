#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#0
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf
source $DS/ifs/mods/cmns.sh

$DS/stop.sh T
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic=$(echo "$gtdr" | sed 's|\/|\n|g' | sed -n 8p)
DC_tlt="$DC_tl/$topic"
DM_tlt="$DM_tl/$topic"

if [ -d "$DC_tlt" ]; then

	if [ ! -d "$DM_tlt" ]; then
		
		mkdir -p "$DM_tlt/words/images"
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
		sed '/^$/d' $DT/ls0.x > "$chk1"; fi
	if [ -n "$(cat "$chk2" | sort -n | uniq -dc)" ]; then
		cat "$chk2" | awk '!array_temp[$0]++' > $DT/ls1.x
		sed '/^$/d' $DT/ls1.x > "$chk2"; fi
	if [ -n "$(cat "$chk3" | sort -n | uniq -dc)" ]; then
		cat "$chk3" | awk '!array_temp[$0]++' > $DT/ls2.x
		sed '/^$/d' $DT/ls2.x > "$chk3"; fi
	if [ -n "$(cat "$chk4" | sort -n | uniq -dc)" ]; then
		cat "$chk4" | awk '!array_temp[$0]++' > $DT/ls1.x
		sed '/^$/d' $DT/ls1.x > "$chk4"; fi
	if [ -n "$(cat "$chk5" | sort -n | uniq -dc)" ]; then
		cat "$chk5" | awk '!array_temp[$0]++' > $DT/ls2.x
		sed '/^$/d' $DT/ls2.x > "$chk5"; fi
	
	chk1=$(cat "$DC_tlt/cfg.0" | wc -l)
	chk2=$(cat "$DC_tlt/cfg.1" | wc -l)
	chk3=$(cat "$DC_tlt/cfg.2" | wc -l)
	chk4=$(cat "$DC_tlt/cfg.3" | wc -l)
	chk5=$(cat "$DC_tlt/cfg.4" | wc -l)
	stts=$(cat "$DC_tlt/cfg.8")
	mp3s="$(find "$DM_tl/$topic/" * \
	| sort -k 1n,1 -k 7 | cut -d' ' -f2- | wc -l)"
	
	# fix index
	if [[ $(($chk4 + $chk5)) != $chk1 || $(($chk2 + $chk3)) != $chk1 \
	|| $(($mp3s - 2)) != $chk1 || $stts = 13 ]]; then
		sleep 1
		notify-send -i idiomind "$index_err1" "$index_err2" -t 3000 &
		> $DT/ps_lk
		cd "$DM_tl/$topic/words/"
		for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		cd "$DM_tl/$topic"
		for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
		if [ -f ".mp3" ]; then rm .mp3; fi
		find . | sort -k 1n,1 -k 7 | sed s'/words\///'g \
		| sed s'/images\///'g | sed s'|\.\/words\/||'g \
		| sed s'|\.\/||'g | sed s'|\.mp3||'g > $DT/index
		
		touch "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.4.tmp"
		
		if ([ -f "$DC_tlt/.cfg.11" ] && \
		[ -n $(cat "$DC_tlt/.cfg.11") ]); then
		index="$DC_tlt/.cfg.11"
		else
		index="$DT/index"
		fi

		n=1
		while [ $n -le $(cat "$index" | wc -l) ]; do
		
			name="$(sed -n "$n"p "$index")"
			sfname="$(nmfile "$name")"
			wfname="$(nmfile "$name")"

			if [ -f "$DM_tlt/$name.mp3" ]; then
				tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
				trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
				xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
				mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
				echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
				echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
			elif [ -f "$DM_tlt/$sfname.mp3" ]; then
				tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
				trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
				xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
				mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
				echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
				echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
			elif [ -f "$DM_tlt/words/$name.mp3" ]; then
				tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
				trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
				xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
				mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
				echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
				echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
			elif [ -f "$DM_tlt/words/$wfname.mp3" ]; then
				tgs="$(eyeD3 "$DM_tlt/words/$wfname.mp3")"
				trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
				xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
				mv -f "$DM_tlt/words/$wfname.mp3" "$DM_tlt/words/$xname.mp3"
				echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
				echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
			fi
			let n++
		done

		cp -f "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.0"
		cp -f "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.3"
		cp -f "$DC_tlt/cfg.4.tmp" "$DC_tlt/cfg.4"
		cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"
		rm "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.4.tmp"
		
		if [ $? -ne 0 ]; then
			[[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
			msg " $files_err\n\n" error & exit 1
		fi
		
		in0="$DC_tlt/cfg.0"
		if [ -n "$(cat "$in0" | sort -n | uniq -dc)" ]; then
			cat "$in0" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in0"; fi
		in1="$DC_tlt/cfg.1"
		if [ -n "$(cat "$in1" | sort -n | uniq -dc)" ]; then
			cat "$in1" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in1"; fi
		in2="$DC_tlt/cfg.2"
		if [ -n "$(cat "$in2" | sort -n | uniq -dc)" ]; then
			cat "$in2" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in2"; fi
		in3="$DC_tlt/cfg.3"
		if [ -n "$(cat "$in3" | sort -n | uniq -dc)" ]; then
			cat "$in3" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in3"; fi
		in4="$DC_tlt/cfg.4"
		if [ -n "$(cat "$in4" | sort -n | uniq -dc)" ]; then
			cat "$in4" | awk '!array_temp[$0]++' > $DT/ind
			sed '/^$/d' $DT/ind > "$in4"; fi
		if [[ $stts = "13" ]]; then
			if cat "$DC_tl/.cfg.3" | grep -Fxo "$topic"; then
				echo "6" > "$DC_tlt/cfg.8"
			elif cat "$DC_tl/.cfg.2" | grep -Fxo "$topic"; then
				echo "1" > "$DC_tlt/cfg.8"
			else
				echo "1" > "$DC_tlt/cfg.8"
			fi
		fi

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
	[[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
	cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
	notify-send --icon=idiomind \
	"$topic" "$its_your_topic_now" -t 2000 & exit 1
else
	[[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
	msg " $path_err\n $topic\n" error & exit 1
fi
