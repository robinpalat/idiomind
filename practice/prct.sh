#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
strt=$DS/practice/strt.sh
cls=$DS/practice/cls
w9=$DC/addons/practice/w9
w6=$DC/addons/practice/w6
DF=$DS/practice/df.sh
DLW=$DS/practice/dlw.sh
DMC=$DS/practice/dmc.sh
DLS=$DS/practice/dls.sh
Wi="$DC_tlt/cfg.3"
Si="$DC_tlt/cfg.4"
Li="$DC_tlt/cfg.1"
cd "$DC_tlt/practice"

function look() {
		yad --title="$practice - $tpc" --borders=5 --center \
		--on-top --skip-taskbar --window-icon=idiomind \
		--center --image="$DS/practice/icons_st/21.png" --button=Ok:2 \
		--button="   $restart   ":0 --width=360 --height=120 \
		--text="<b>   $complete</b>\\n    $(cat $1)\\n\\n"
}

function get_list() {
		if [ "$(cat "$Si" | wc -l)" -gt 0 ]; then
			grep -F -x -v -f "$Si" "$Li" > $1
		else
			cat "$Li" > $1
		fi
}

function get_list_mchoice() {

	(
	echo "5" ; sleep 0
	echo "# " ; sleep 0
	n=1
	while [[ $n -le "$(cat mcin | sed 's/mcin//g' | wc -l)" ]]; do
		word=$(sed -n "$n"p mcin)
		file="$DM_tlt/words/$word.mp3"
		echo "$(eyeD3 "$file" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")" >> word1.idx
		let n++
	done
	) | yad --progress \
	--width 50 --height 35 --undecorated \
	--pulsate --auto-close \
	--skip-taskbar --center --no-buttons

}

function get_list_sentences() {
		if [ "$(cat "$Wi" | wc -l)" -gt 0 ]; then
			grep -F -x -v -f "$Wi" "$Li" > $1
		else
			cat "$Li" > $1
		fi
}

function starting() {
		yad --form --center --borders=5 --image=info \
		--title="$practice" --on-top --window-icon=idiomind \
		--button=Ok:1 --skip-taskbar --width=360 --height=120 \
		--text " $1  "
		$strt & killall prct.sh.sh & exit 1
}

if [[ "$1" = f ]]; then

	cd "$DC_tlt/practice"
	
	if [[ -f look_f ]]; then
		look "look_f"
		ret=$(echo "$?")
		if [[ "$ret" -eq 0 ]]; then
		$cls df & exit
		else
		$strt & exit
		fi
	fi

	if ([ -f fin ] && [ -f ok.f ]); then
		grep -F -x -v -f ok.f fin > fin1
		echo "-- restarting session"
	else
		get_list fin && cp -f fin fin1
		[[ "$(cat fin  | wc -l)" -lt 4 ]] && starting "$starting1"
		echo "-- new session"
	fi
	
	$DF

elif [[ "$1" = m ]]; then

	cd "$DC_tlt/practice"
	
	if [[ -f look_mc ]]; then
		look "look_mc"
		ret=$(echo "$?")
		if [[ "$ret" -eq 0 ]]; then
		$cls dm & exit
		else
		$strt & exit
		fi
	fi

	if ([ -f mcin ] && [ -f ok.m ]); then
		grep -F -x -v -f ok.m mcin > mcin1
		echo "-- restarting session"
		
	else
		get_list mcin && cp -f mcin mcin1
		if [ ! -f word1.idx ]; then
			get_list_mchoice
		fi
		[[ "$(cat mcin  | wc -l)" -lt 4 ]] && starting "$starting1"
		 echo "-- new session"
	fi

	$DMC

elif [[ "$1" = w ]]; then

	cd "$DC_tlt/practice"
	
	if [[ -f look_lw ]]; then
		look "look_lw"
		ret=$(echo "$?")
		if [[ "$ret" -eq 0 ]]; then
		$cls dw & exit
		else
		$strt & exit
		fi
	fi

	if ([ -f lwin ] && [ -f ok.w ]); then
		grep -F -x -v -f ok.w lwin > lwin1
		echo "-- restarting session"
	else
		get_list lwin && cp -f lwin lwin1
		[[ "$(cat lwin  | wc -l)" -lt 4 ]] && starting "$starting1"
		echo "-- new session"
	fi
	
	$DLW

elif [[ "$1" = s ]]; then

	cd "$DC_tlt/practice"
	
	if [[ -f look_ls ]]; then
		look "look_ls"
		ret=$(echo "$?")
		if [[ "$ret" -eq 0 ]]; then
		$cls ds & exit
		else
		$strt & exit
		fi
	fi

	if ([ -f lsin ] && [ -f ok.s ]); then
		grep -F -x -v -f ok.s lsin > lsin1
		echo "-- restarting session"
	else
		get_list_sentences lsin && cp -f lsin lsin1
		[[ "$(cat lsin  | wc -l)" -lt 1 ]] && starting "$starting2"
		echo "-- new session"
	fi
	
	$DLS
fi
