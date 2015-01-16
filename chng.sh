#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/topics_lists.conf

if [[ "$1" = chngi ]]; then

	nta=$(sed -n 6p $DC_s/cnfg5)
	sna=$(sed -n 7p $DC_s/cnfg5)
	cnfg1="$DC_s/cnfg5"
	indx="$DT/.$user/indx"
	imgt="/$DT/ILLUSTRATION.jpeg"
	[[ -f "$DT/ILLUSTRATION.jpeg" ]] && rm -f "$DT/ILLUSTRATION.jpeg"
	indp="$DT/.$user/indp"
	[[ -z $(cat $DC_s/cnfg2) ]] && echo 8 > $DC_s/cnfg2 \
	&& bcl=$(cat $DC_s/cnfg2) || bcl=$(cat $DC_s/cnfg2)
	[[ -z $bcl ]] && bcl = 5
	[[ $bcl -lt 3 ]] && bcl = 3
	
	item=$(sed -n "$2"p $indx)
	
	[[ -f "$DM_tlt/$item.mp3" ]] && file="$DM_tlt/$item.mp3" && t=2
	[[ -f "$DM_tlt/words/$item.mp3" ]] && file="$DM_tlt/words/$item.mp3" && t=1
	[[ -f "$DM_tl/Feeds/kept/words/$item.mp3" ]] && file="$DM_tl/Feeds/kept/words/$item.mp3" && t=1
	[[ -f "$DM_tl/Feeds/kept/$item.mp3" ]] && file="$DM_tl/Feeds/kept/$item.mp3" && t=2
	[[ -f "$DM_tl/Feeds/conten/$item.mp3" ]] && file="$DM_tl/Feeds/conten/$item.mp3" && t=2
	
	if [ -f "$file" ]; then
		
		if [ "$t" = 2 ]; then
		tgs=$(eyeD3 "$file")
		trgt=$(echo "$tgs" | \
		grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		srce=$(echo "$tgs" | \
		grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		
		elif [ "$t" = 1 ]; then
		tgs=$(eyeD3 "$file")
		trgt=$(echo "$tgs" | \
		grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
		srce=$(echo "$tgs" | \
		grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		fi

		if [ -z "$trgt" ]; then
			trgt="$item"
		fi
		
		cnt=$(echo "$trgt" | wc -w)
		if echo "$nta" | grep "TRUE"; then
			cnt=10
		fi
		
		wmm=$(($bcl + $cnt / 2 ))
		wmt=$(($wmm + 5))
		
		rm -f $imgt
		eyeD3 --write-images=$DT "$file"
		imgt=$DT/ILLUSTRATION.jpeg
		[[ -f $imgt ]] && osdi=$imgt || osdi=idiomind
		
		if echo "$nta" | grep "TRUE"; then
			notify-send -i "$osdi" "$trgt" "$srce\\n" -t 12000  &
		fi
		sleep 1
		if echo "$sna" | grep "TRUE"; then
			play "$file" &
		fi
		
		sleep $wmm

		[[ -f $DT/.bcle ]] && rm -f $DT/.bcle
		
	else
		echo "$item" >> $DT/.bcle
		echo "-- no file found"
		if [ $(cat $DT/.p__$use | wc -l) -gt 5 ]; then
			int="$(sed -n 16p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
			T="$(echo "$int" | sed -n 1p)"
			D="$(echo "$int" | sed -n 2p)" #interrupt
			notify-send -i idiomind "$T" "$D" -t 9000 &
			rm -fr $DT/.p__$user &
			$DS/stop.sh S & exit 1
		fi
	fi

elif [ "$1" != chngi ]; then
	
	if [ ! -d $DC_s ]; then
		/usr/share/idiomind/ifs/1u.sh &
		exit 1
	fi
	if [ ! -f $DC_s/cnfg0 ]; then
		> $DC_s/cnfg0
		fi
		eht=$(sed -n 3p $DC_s/cnfg18)
		wth=$(sed -n 4p $DC_s/cnfg18)
		if [ -n "$1" ]; then
			text="--text=<small>$1\n</small>"
			align="--text-align=left"
		else
			host="http://idiomind.sourceforge.net"
			lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
			text="--text=<small><small><a href='$host/$lgs/$lgtl'>$find_topics</a>\t</small></small>"
			align="--text-align=right"
		fi
		[[ -f $DC_tl/.cnfg1 ]] && info2=$(cat $DC_tl/.cnfg1 | wc -l) || info2=""
		cd $DC_s

		VAR=$(cat $DC_s/cnfg0 | $yad --name=idiomind --ellipsize=END \
		--class=idiomind --center --separator="" $align\
		"$text" --width=$wth --height=$eht \
		--no-headers --list --window-icon=idiomind \
		--button="gtk-add":3 --button="$ok":0 --button="$close":1 \
		--borders=5 --title="$topics" --column=img:img --column=File:TEXT)
			ret=$?
			if [ $ret -eq 3 ]; then
				$DS/add.sh n_t
				exit 1
			elif [ $ret -eq 1 ]; then
				exit 1
			elif [ $ret -eq 0 ]; then
				if [ -n "$1" ]; then
					if [ "$2" = 3 ]; then
						$DC_tl/"$VAR"/tpc.sh
						$DS/add.sh n_i  & exit
					else
						$DC_tl/"$VAR"/tpc.sh 2 & exit
					fi
				else
					$DC_tl/"$VAR"/tpc.sh & exit
				fi
			else
				exit 0
			fi
fi
