#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function notebook_1() {
	
	cat "$ls1" | awk '{print $0"\n"}' | yad \
	--no-headers --list --plug=$KEY --tabnum=1 \
	--dclick-action='./vwr.sh v1' --print-all \
	--expand-column=1 --ellipsize=END \
	--column=Name:TEXT --column=Learned:CHK > "$cnf1" &
	cat "$ls2" | yad \
	--no-headers --list --plug=$KEY --tabnum=2 \
	--expand-column=0 --ellipsize=END --print-all \
	--column=Name:TEXT \
	--dclick-action='./vwr.sh v2' &
	yad --text-info --plug=$KEY --margins=14 \
	--tabnum=3 --text="$itxt2" --fore='gray40' --wrap --editable \
	--show-uri --fontname=vendana \
	--filename="$nt" > "$cnf3" &
	yad --notebook --name=Idiomind --center --key=$KEY \
	--class=Idiomind --align=right \
	--window-icon=$DS/images/idiomind.png \
	--tab-borders=0 --center --title="Idiomind" \
	--image="$img" --text="$itxt" \
	--tab="  $learning ($tb1) " \
	--tab="  $learned ($tb2) " \
	--tab=" $notes " \
	--ellipsize=END --image-on-top --always-print-result \
	--width="$wth" --height="$eht" --borders=0 \
	--button="Play":$DS/play.sh --button="$practice":5 \
	--button="$edit":3
}


function notebook_2() {
	
	yad --align=center --borders=80 \
	--text="<u><b>$learned</b></u>\\n$time_review ($tdays $days)" \
	--bar="":NORM $RM \
	--multi-progress --plug=$KEY --tabnum=1 &
	cat "$ls2" | yad \
	--no-headers --list --plug=$KEY --tabnum=2 \
	--expand-column=1 --ellipsize=END --print-all \
	--column=Name:TEXT \
	--dclick-action='./vwr.sh v2' &
	yad --text-info --plug=$KEY --margins=14 --text="$itxt2" \
	--tabnum=3 --fore='gray40' --wrap --filename="$nt" \
	--show-uri --fontname=vendana --editable > "$cnf3" &
	yad --notebook --name=Idiomind --center \
	--class=Idiomind --align=right --key=$KEY \
	--tab-borders=0 --center --title="Idiomind" \
	--image="$img" --text="$itxt" \
	--window-icon=$DS/images/idiomind.png \
	--tab=" $review " \
	--tab=" $learned ($tb2) " \
	--tab=" $notes " \
	--ellipsize=END --image-on-top --always-print-result \
	--width="$wth" --height="$eht" --borders=0 \
	--button="$edit":3
}


function notebook_3() {
	
	yad --align=center --borders=80 \
	--text="<u><b>$learned</b></u>   * $new_items ($tb1).\\n$time_review: $tdays" \
	--bar="":NORM $RM \
	--multi-progress --plug=$KEY --tabnum=1 &
	cat "$ls2" | yad \
	--no-headers --list --plug=$KEY --tabnum=2 \
	--expand-column=1 --ellipsize=END --print-all \
	--column=Name:TEXT \
	--dclick-action='./vwr.sh v2' &
	yad --text-info --plug=$KEY --margins=14 \
	--wrap --text="$itxt2" --editable --tabnum=3 --fore='gray40' \
	--show-uri --fontname=vendana --filename="$nt" > "$cnf3" &
	yad --notebook --name=Idiomind --center \
	--class=Idiomind --align=right --key=$KEY \
	--tab-borders=0 --center --title="Idiomind" \
	--image="$img" --text="$itxt" \
	--window-icon=$DS/images/idiomind.png \
	--tab=" $review " \
	--tab=" $learned ($tb2) " \
	--tab=" $notes " \
	--ellipsize=END --image-on-top --always-print-result \
	--width="$wth" --height="$eht" --borders=0 \
	--button="$review":4 --button="$edit":3 >/dev/null 2>&1
}


function notebook_0() {
	
	yad --text-info --plug=$KEY --margins=14 \
	--tabnum=1 --fore='gray40' --wrap --filename="$nt" \
	--show-uri --fontname=vendana --editable > "$cnf3" &
	yad --notebook --name=Idiomind --center \
	--class=Idiomind --align=right --key=$KEY \
	--window-icon=$DS/images/idiomind.png \
	--tab-borders=0 --center --title="Idiomind" \
	--image="$img" --text="$itxt" --tab=" $notes " \
	--ellipsize=END --image-on-top --always-print-result \
	--width="$wth" --height="$eht" --borders=0 \
	--button="Play":$DS/play.sh \
	--button="$delete":"$DS/mngr.sh delete_topic"
}


function dialog_1() {
	
	yad --title="$tpc" --window-icon=idiomind \
	--borders=20 --buttons-layout=edge \
	--image=dialog-question --on-top --center \
	--window-icon=$DS/images/idiomind.png \
	--buttons-layout=edge --class=idiomind \
	--button="       $notyet       ":1 \
	--button="        $review        ":2 \
	--text="$adv" --name=idiomind \
	--width=420 --height=150
}


function dialog_2() {
	
	yad --title="$tpc" --window-icon=idiomind \
	--borders=5 --name=idiomind \
	--image=dialog-question \
	--on-top --window-icon=idiomind \
	--center --class=idiomind \
	--button="$onlynews":3 \
	--button="$all":2 \
	--text="  $cuestion_review2 " \
	--width=420 --height=150
}


function calculate_review() {
	
	dts=$(cat "$DC_tlt/cfg.9" | wc -l)
	if [ $dts = 1 ]; then
		dte=$(sed -n 1p "$DC_tlt/cfg.9")
		adv="<b>   10 $cuestion_review </b>"
		TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
		RM=$((100*$TM/10))
		tdays=10
	elif [ $dts = 2 ]; then
		dte=$(sed -n 2p "$DC_tlt/cfg.9")
		adv="<b> 15 $cuestion_review </b>"
		TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
		RM=$((100*$TM/15))
		tdays=15
	elif [ $dts = 3 ]; then
		dte=$(sed -n 3p "$DC_tlt/cfg.9")
		adv="<b>  30 $cuestion_review </b>"
		TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
		RM=$((100*$TM/30))
		tdays=30
	elif [ $dts = 4 ]; then
		dte=$(sed -n 4p "$DC_tlt/cfg.9")
		adv="<b>  60 $cuestion_review </b>"
		TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
		RM=$((100*$TM/60))
		tdays=60
	fi
}
