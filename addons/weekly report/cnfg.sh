#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

eht=$(sed -n 3p $DC_s/cfg.18)
wth=$(sed -n 4p $DC_s/cfg.18)
LOG=$DC/addons/stats/.log
NUM=$DC/addons/stats/num.tmp
TPS=$DC/addons/stats/tpcs.tmp
WKRT=$DC/addons/stats/wkrt.tmp
WKRT2=$DC/addons/stats/wkrt2.tmp
[[ ! -f "$DC/addons/stats/.udt" ]] && touch "$DC/addons/stats/.udt"
udt=$(cat "$DC/addons/stats/.udt")
[ ! -d "$DC/addons/stats" ] && mkdir "$DC/addons/stats"

#-----------------------------------------------------------------------
if [ "$1" = A ]; then
	#[[ "$(date +%F)" = "$udt" ]] && exit 1
	echo "$tpc" > $DC/addons/stats/tpc.tmp
	echo $(sed -n 2p $DC_s/cfg.8) >> $DC/addons/stats/tpc.tmp
	TPCS=$(cat "$LOG" | grep -o -P '(?<=tpcs.).*(?=\.tpcs)' \
	| sort | uniq -dc | sort -n -r | head -3 | sed -e 's/^ *//' -e 's/ *$//')
	tpc1=$(echo "$TPCS" | sed -n 1p | cut -d " " -f2-)
	echo "$tpc1" > "$TPS"
	if [[ "$(echo "$TPCS" | sed -n 2p | awk '{print ($1)}')" -ge 3 ]]; then
		tpc2=$(echo "$TPCS" | sed -n 2p | cut -d " " -f2-)
		echo "$tpc2" >> "$TPS"
	fi
	if [[ "$(echo "$TPCS" | sed -n 3p | awk '{print ($1)}')" -ge 3 ]]; then
		tpc3=$(echo "$TPCS" | sed -n 3p | cut -d " " -f2-)
		echo "$tpc3" >> "$TPS"
	fi

	EITM=$(cat "$LOG" \
	| grep -o -P '(?<=eitm.).*(?=.eitm)' | wc -l)
	AIMG=$(cat "$LOG" \
	| grep -o -P '(?<=aimg.).*(?=.aimg)' | wc -l)
	REIM=$(cat "$LOG" \
	| grep -o -P '(?<=reim.).*(?=.reim)' | tr '\n' '+')
	REIM=$(echo "$REIM""0" | bc -l)
	AITM=$(cat "$LOG" \
	| grep -o -P '(?<=aitm.).*(?=.aitm)' | tr '\n' '+')
	echo "$AITM""0" | bc -l > "$NUM"
	AITM=$(echo "$AITM""0" | bc -l)
	DDC=$(echo "$EITM $AIMG $REIM $AITM" | tr ' ' '+' | bc -l)
	tpc1=$(sed -n 1p $TPS)
	tpc2=$(sed -n 2p $TPS)
	tpc3=$(sed -n 3p $TPS)

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

	W9=$DC/addons/practice/w9
	W9INX=$(cat $W9 | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
	n=1
	while [ $n -le 15 ]; do
		if [[ $(echo "$W9INX" | sed -n "$n"p | awk '{print ($1)}') -ge 3 ]]; then
		
			fwk=$(echo "$W9INX" | sed -n "$n"p | awk '{print ($2)}')
			if [ -n "$tpc3" ];then
				if cat "$tlng1" | grep -o "$fwk"; then
					echo "$fwk" >> $DC/addons/stats/w9.tmp
					
				elif cat "$tlng2" | grep -o "$fwk"; then
					echo "$fwk" >> $DC/addons/stats/w9.tmp
					
				elif cat "$tlng3" | grep -o "$fwk"; then
					echo "$fwk" >> $DC/addons/stats/w9.tmp
				fi
			elif [ -n "$tpc2" ];then
				if cat "$tlng1" | grep -o "$fwk"; then
					echo "$fwk" >> $DC/addons/stats/w9.tmp
					
				elif cat "$tlng2" | grep -o "$fwk"; then
					echo "$fwk" >> $DC/addons/stats/w9.tmp
				fi
			elif [ -n "$tpc1" ];then
				if cat "$tlng1" | grep -o "$fwk"; then
				echo "$fwk" >> $DC/addons/stats/w9.tmp
				fi
			fi
		fi
		let n++
	done
	sed -i '/^$/d' $DC/addons/stats/w9.tmp
	
	CTW9=$(cat $DC/addons/stats/w9.tmp | wc -l)
	echo "$CTW9" >> "$NUM"
	OKIM=$(cat "$LOG" \
	| grep -o -P '(?<=okim.).*(?=.okim)' | tr '\n' '+')
	echo "$OKIM""0" | bc -l >> "$NUM"
	OKIM=$(echo "$OKIM""0" | bc -l)
	ARCH=$(echo "$CTW9 $OKIM" | tr ' ' '+' | bc -l)
	VWR=$(cat "$LOG" \
	| grep -o -P '(?<=vwr.).*(?=.vwr)' | tr '\n' '+')
	echo "$VWR""0" | bc -l >> "$NUM"
	VWR=$(echo "$VWR""0" | bc -l)
	LRNPR=$(cat "$LOG" \
	| grep -o -P '(?<=lrnpr.).*(?=.lrnpr)' | wc -l)
	echo "$LRNPR">> "$NUM"
	PRCTC=$(cat "$LOG" \
	| grep -o -P '(?<=prctc.).*(?=.prctc)' | wc -l)
	echo "$PRCTC">> "$NUM"
	STDY=$(echo "$VWR $LRNPR $PRCTC" | tr ' ' '+' | bc -l)
	
	[[ $DDC -ge 100 ]] && DDC=100
	[[ $STDY -ge 100 ]] && STDY=100
	[[ $ARCH -ge 100 ]] && ARCH=100
	ttl=$(($DDC+$ARCH+$STDY))
	real=$(($ttl/3))
	acrm=$((100-$real))
	lfD=$((110-$DDC))
	lfS=$((110-$STDY))
	lfL=$((80-$ARCH))
	flD=$(($DDC*$real/$ttl))
	flS=$(($STDY*$real/$ttl))
	flL=$(($ARCH*$real/$ttl))
	
	if [ "$real" -le 10 ]; then
	real=10
	fi
	rm "$LOG"
	ext1=$(n=1
	while [ $n -le $flD ]; do printf " ";
		let n++
	done)
	ext2=$(n=1
	while [ $n -le $flS ]; do printf " ";
		let n++
	done)
	ext3=$(n=1
	while [ $n -le $flL ]; do printf " ";
		let n++
	done)
	ext4=$(n=1
	while [ $n -le $acrm ]; do printf " ";
		let n++
	done)

	[[ "$(echo "$tpc1" | wc -c)" -gt 40 ]] && tle1="${tpc1:0:37}..." || tle1="$tpc1"
	[[ "$(echo "$tpc2" | wc -c)" -gt 40 ]] && tle2="${tpc2:0:37}..." || tle2="$tpc2"
	[[ "$(echo "$tpc3" | wc -c)" -gt 40 ]] && tle3="${tpc3:0:37}..." || tle3="$tpc3"

	echo "<small><sup><span background='#F3C879'>$ext1</span><span background='#6E9FD4'>$ext2</span><span background='#76A862'><span color='#FFFFFF'><b>$ext3$real% </b></span><span background='#E8E8E8'>$ext4</span></span></sup></small>" >> $DC/addons/stats/.wks_
	cat $DC/addons/stats/.wks | head -n 12 >> $DC/addons/stats/.wks_
	mv -f $DC/addons/stats/.wks_ $DC/addons/stats/.wks
	
	echo "<big><big><b>$real%</b></big></big>  Performance
" > $WKRT
if [ -n "$tpc3" ]; then
	echo "$topics:
<b>$tle1</b>
<b>$tle2</b>
<b>$tle3</b>
">> $WKRT
elif [ -n "$tpc2" ]; then
	echo "$topics:
<b>$tle1</b>
<b>$tle2</b>
">> $WKRT
else
	echo "$topic:
<b>$tle1</b>
">> $WKRT
fi
echo "<big><span font='ultralight'>$CTW9</span></big>  $items_to_mark_ok" >> $WKRT
echo "<big><span font='ultralight'>$OKIM</span></big>  $items_ok

" >> $WKRT
cat "$DC/addons/stats/.wks" >> $WKRT2
echo "$(date +%F)" > "$DC/addons/stats/.udt"
echo "$tpc" > $DC_s/cfg.8
echo wr >> $DC_s/cfg.8
exit 1

#-----------------------
elif [ "$1" = T ]; then
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

#-----------------------------------------------------------------------
elif [ -z "$1" ]; then
	sttng=$(sed -n 1p $DC/addons/stats/cnf)
	if [ -z $sttng ]; then
		echo FALSE > $DC/addons/stats/cnf
		sttng=$(sed -n 1p $DC/addons/stats/cnf)
	fi
	if [ $sttng = TRUE ]; then
		SW=$(cat $DC/addons/stats/.wks | head -n 8)
	else
		SW=" "
	fi
	CNFG=$($yad --title="$weekly_report" --borders=10 --print-all \
	--center --form --on-top --scroll --skip-taskbar --align=center \
	--always-print-result --window-icon=idiomind \
	--button=Close:0 --width=440 --height=340 \
	--text="<sup>$description</sup>" \
	--field="$active:CHK" $sttng \
	--field="\n$SW:LBL")
		ret=$?
		
		if [ $ret -eq 0 ]; then
			sttng=$(echo "$CNFG" | cut -d "|" -f1)
			sed -i "1s/.*/$sttng/" $DC/addons/stats/cnf
			rm -f $DT/*.r
			exit
		else
			sttng=$(echo "$CNFG" | cut -d "|" -f1)
			sed -i "1s/.*/$sttng/" $DC/addons/stats/cnf
			exit
		fi
fi
