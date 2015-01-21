#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/topics_lists.conf

if [[ "$1" = chngi ]]; then

	nta=$(sed -n 6p $DC_s/cnfg5)
	sna=$(sed -n 7p $DC_s/cnfg5)
	cnfg1="$DC_s/cnfg5"
	indx="$DT/.$user/indx"
	[[ -z $(cat $DC_s/cnfg2) ]] && echo 8 > $DC_s/cnfg2 \
	&& bcl=$(cat $DC_s/cnfg2) || bcl=$(cat $DC_s/cnfg2)
	[[ -z $bcl ]] && bcl = 4
	[[ $bcl -lt 4 ]] && bcl = 4 && echo 8 > $DC_s/cnfg2
	if [ -n $(echo "$nta" | grep "TRUE") ] && [ $bcl -lt 10 ]; then bcl=10; fi
	
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

		[[ -z "$trgt" ]] && trgt="$item"
		[[ -f "$DM_tl/Feeds/kept/words/$item.mp3" ]] && \
		osdi="$DM_tl/Feeds/kept/words/$item.mp3" || osdi=idiomind
		[[ -f $imgt ]] && osdi=$imgt || osdi=idiomind
		
		[[ -n $(echo "$nta" | grep "TRUE") ]] && notify-send -i "$osdi" "$trgt" "$srce" -t 12000  &
		sleep 1
		[[ -n $(echo "$sna" | grep "TRUE") ]] && play "$file" &
		
		cnt=$(echo "$trgt" | wc -c)
		echo "TOTAL=$(($bcl+$cnt/20)) ____ loop=$bcl  ____  characters=$cnt "
		sleep $(($bcl+$cnt/20))
		
		[[ -f $DT/.bcle ]] && rm -f $DT/.bcle
		
	else
		echo "$item" >> $DT/.bcle
		echo "-- no file found"
		if [ $(cat $DT/.p__$use | wc -l) -gt 5 ]; then
			int="$(sed -n 16p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
			T="$(echo "$int" | sed -n 1p)"
			D="$(echo "$int" | sed -n 2p)" #interrupt
			notify-send -i idiomind "$T" "$D" -t 9000 &
			rm -f $DT/.p__$user &
			$DS/stop.sh S & exit 1
		fi
	fi

elif [ "$1" != chngi ]; then
	
	if [ ! -f $DC_s/cnfg0 ]; then
		> $DC_s/cnfg0
		fi
		wth=$(sed -n 3p $DC_s/cnfg18)
		eht=$(sed -n 4p $DC_s/cnfg18)
		if [ -n "$1" ]; then
			text="--text=<small>$1\n</small>"
			align="--text-align=left"
		else
			lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
			text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/$lgtl'>$find_topics</a>   </small></small>"
			align="--text-align=right"
		fi
		[[ -f $DC_tl/.cnfg1 ]] && info2=$(cat $DC_tl/.cnfg1 | wc -l) || info2=""
		cd $DC_s

		VAR=$(cat $DC_s/cnfg0 | $yad --name=idiomind \
		--class=idiomind --center --separator="" $align\
		"$text" --width=$wth --height=$eht --ellipsize=END \
		--no-headers --list --window-icon=idiomind --borders=5 \
		--button="gtk-add":3 --button="$ok":0 \
		--title="$topics" --column=img:img --column=File:TEXT)
			ret=$?
			if [ $ret -eq 3 ]; then
				$DS/add.sh n_t
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
					if [[ -f $DC_tl/"$VAR"/tpc.sh ]]; then
						$DC_tl/"$VAR"/tpc.sh & exit
					else
						cp -f $DS/default/tpc.sh $DC_tl/"$VAR"/tpc.sh
						$DC_tl/"$VAR"/tpc.sh & exit
					fi
				fi
			else
				exit 0
			fi
fi
