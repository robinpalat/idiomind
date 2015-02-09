#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function weeklyreport() {
	
	eht=$(sed -n 3p $DC_s/cfg.18)
	wth=$(sed -n 4p $DC_s/cfg.18)
	tpc1=$(sed -n 1p $TPS) #topics
	tpc2=$(sed -n 2p $TPS)
	tpc3=$(sed -n 3p $TPS)
	tpcr=$(cat $DC/addons/stats/tpc.tmp)
	c=$(echo $(($RANDOM%100000)))
	KEY=$c
	cd $DS
	$yad --form --align=center --scroll \
	--borders=12 --plug=$KEY --tabnum=1 \
	--print-all --text="$(cat $WKRT)" \
	--field="\n$(cat $DC/addons/stats/.wks)":lbl &
	cat $DC/addons/stats/w9.tmp \
	| awk '{print "TRUE\n"$0}' | $yad \
	--list --ellipsize=END --print-all \
	--plug=$KEY --tabnum=2 --always-print-result \
	--column="$(cat $DC/addons/stats/w9.tmp | wc -l)" \
	--column="$items_to_mark_ok" \
	--checklist --class=idiomind --center > "$DT/slt" &
	$yad --notebook --on-top --name=idiomind --center \
	--class=idiomind --align=right --key=$KEY \
	--tab-borders=0 --center --title="$weekly_report" \
	--tab=" $report   $(date "+%B %d") " --tab=" $items " \
	--buttons-layout=end --class=idiomind \
	--image-on-top --window-icon=idiomind \
	--width="$wth" --height="$eht" --borders=0 \
	--button=Ok:0
		ret=$?
		
		if [[ $ret -eq 0 ]]; then
		
			if [ -n "$tpc3" ];then
				[[ -f "$DC_tl/$tpc1/cfg.1" ]] && tlng1="$DC_tl/$tpc1/cfg.1"
				[[ -f "$DC_tl/$tpc2/cfg.1" ]] && tlng2="$DC_tl/$tpc2/cfg.1"
				[[ -f "$DC_tl/$tpc3/cfg.1" ]] && tlng3="$DC_tl/$tpc3/cfg.1"
				touch "$DC_tl/$tpc1/cfg.2" && tok1="$DC_tl/$tpc1/cfg.2"
				touch "$DC_tl/$tpc2/cfg.2" && tok2="$DC_tl/$tpc2/cfg.2"
				touch "$DC_tl/$tpc3/cfg.2" && tok3="$DC_tl/$tpc3/cfg.2"
			elif [ -n "$tpc2" ];then
				[[ -f "$DC_tl/$tpc1/cfg.1" ]] && tlng1="$DC_tl/$tpc1/cfg.1"
				[[ -f "$DC_tl/$tpc2/cfg.1" ]] && tlng2="$DC_tl/$tpc2/cfg.1"
				touch "$DC_tl/$tpc1/cfg.2" && tok1="$DC_tl/$tpc1/cfg.2"
				touch "$DC_tl/$tpc2/cfg.2" && tok2="$DC_tl/$tpc2/cfg.2"
			elif [ -n "$tpc1" ];then
				[[ -f "$DC_tl/$tpc1/cfg.1" ]] && tlng1="$DC_tl/$tpc1/cfg.1"
				touch "$DC_tl/$tpc1/cfg.2" && tok1="$DC_tl/$tpc1/cfg.2"
			fi
			
			#--------------------------------------
			if [[ -n "$(cat "$DC/addons/stats/w9.tmp")" ]]; then
				list=$(cat "$DT/slt" | sed 's/|//g' | sed 's/TRUE//g')
				echo "$list" > $DT/t.tmp
				n=1
				while [ $n -le "$(cat "$DT/t.tmp" | wc -l)" ]; do
					itm=$(sed -n "$n"p $DT/t.tmp)

					if [ -n "$tpc3" ];then #-----------------------------
						if [ -f "$tlng1" ]; then
							if cat "$tlng1" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng1" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng1"
								echo "$itm" >> "$tok1"; echo "1 --> $itm"
							fi
						fi
						if [ -f "$tlng2" ]; then
							if cat "$tlng2" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng2" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng2"
								echo "$itm" >> "$tok2"; echo "2 --> $itm"
							fi
						fi
						if [ -f "$tlng3" ]; then
							if cat "$tlng3" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng3" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng3"
								echo "$itm" >> "$tok3"; echo "3 --> $itm"
							fi
						fi
					elif [ -n "$tpc2" ];then #-----------------------------
						if [ -f "$tlng1" ]; then
							if cat "$tlng1" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng1" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng1"
								echo "$itm" >> "$tok1"; echo "1 --> $itm"
							fi
						fi
						if [ -f "$tlng2" ]; then
							if cat "$tlng2" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng2" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng2"
								echo "$itm" >> "$tok2"; echo "2 --> $itm"
							fi
						fi
					elif [ -n "$tpc1" ];then #-----------------------------
						if [ -f "$tlng1" ]; then
							if cat "$tlng1" | grep -o "$itm"; then
								grep -v -x -v "$itm" "$tlng1" > $DT/tlng.tmp
								sed '/^$/d' $DT/tlng.tmp > "$tlng1"
								echo "$itm" >> "$tok1"; echo "1 --> $itm"
							fi
						fi
					fi
					let n++
				done
			fi
			echo $(sed -n 1p $DC/addons/stats/tpc.tmp) > $DC_s/cfg.8
			echo $(sed -n 2p $DC/addons/stats/tpc.tmp) >> $DC_s/cfg.8
			rm -f $DT/*.tmp
			rm $DC/addons/stats/*.tmp $DC/addons/practice/w9 $DC/addons/practice/w6
		else
			echo $(sed -n 1p $DC/addons/stats/tpc.tmp) > $DC_s/cfg.8
			echo $(sed -n 2p $DC/addons/stats/tpc.tmp) >> $DC_s/cfg.8
			rm -f $DT/*.x
		fi
}