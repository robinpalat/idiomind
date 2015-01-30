#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf

itdl="$2"
kpt="$DM_tl/Feeds/kept"
drtc="$DC_tl/Feeds/"

if [[ $1 = dlti ]]; then
	if [ -f "$kpt/words/$itdl.mp3" ]; then
		$yad --title="$confirm" --width=420 \
		--height=150 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text=" $delete_word" \
		--window-icon=idiomind --borders=5 \
		--button="$yes":0 --button="$no":1

		ret=$?
			if [[ $ret -eq 0 ]]; then
				rm "$kpt/words/$itdl.mp3"
				cd "$drtc"
				grep -v -x -F "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -F "$itdl" ./cfg.3 > ./cfg.3_
				sed '/^$/d' ./cfg.3_ > ./cfg.3
				rm ./cfg.3_
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0_
				sed '/^$/d' ./cfg.0_ > ./cfg.0
				rm ./cfg.0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	
	elif [ -f "$kpt/$itdl.mp3" ]; then
		$yad --title="$confirm" --width=420 \
		--height=150 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text=" $delete_sentence" \
		--window-icon=idiomind --borders=5 \
		--button="$yes":0 --button="$no":1
		ret=$?
			if [[ $ret -eq 0 ]]; then
				rm "$kpt/$itdl.mp3"
				rm "$kpt/$itdl.lnk"
				cd "$drtc"
				grep -v -x -F "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -F "$itdl" ./cfg.4 > ./cfg.4_
				sed '/^$/d' ./cfg.4_ > ./cfg.4
				rm ./cfg.4_
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0_
				sed '/^$/d' ./cfg.0_ > ./cfg.0
				rm ./cfg.0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	else
		yad --title="$confirm" --width=420 \
		--height=150 --on-top --center \
		--image=dialog-question --skip-taskbar \
		--text=" $delete_item" \
		--window-icon=idiomind --borders=5 \
		--button="$yes":0 --button="$no":1
		ret=$?
			if [[ $ret -eq 0 ]]; then
				rm "$kpt/$itdl.mp3"
				rm "$kpt/$itdl.lnk"
				cd "$drtc"
				grep -v -x -F "$itdl" ./.inx > ./inx
				sed '/^$/d' ./inx > ./.inx
				rm ./inx
				grep -v -x -F "$itdl" ./cfg.3 > ./cfg.3_
				sed '/^$/d' ./cfg.3_ > ./cfg.3
				rm ./cfg.3_
				grep -v -x -F "$itdl" ./cfg.4 > ./cfg.4_
				sed '/^$/d' ./cfg.4_ > ./cfg.4
				rm ./cfg.4_
				grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0_
				sed '/^$/d' ./cfg.0_ > ./cfg.0
				rm ./cfg.0_
				notify-send  -i idiomind "$itdl" "$deleted"  -t 1500
			fi
			if [[ $ret -eq 1 ]]; then
				exit
			fi
	fi
elif [[ $1 = dlns ]]; then
	$yad --width=420 --height=150 --title="$confirm" \
	--on-top --image=dialog-question --center --skip-taskbar \
	--window-icon=idiomind --text=" $delete_all" \
	--borders=5 --button="$yes":0 --button="$no":1
		ret=$?
		if [[ $ret -eq 0 ]]; then
			rm -r $DM_tl/Feeds/conten/*
			rm $DC_tl/Feeds/.updt.lst
			rm $DC_tl/Feeds/cfg.1
			rm $DC_tl/Feeds/.dt
			notify-send  -i idiomind "$deleted" " " -t 2000
		else
			exit 1
		fi
elif [[ $1 = dlkt ]]; then

	$yad --image=dialog-question \
	--window-icon=idiomind --width=400 --height=140  \
	--title="$confirm" --on-top --center --skip-taskbar \
	--borders=5 --text=" $delete_saved2" --name=idiomind \
	--button="$yes":0 --button="$no":1
	ret=$?
	if [[ $ret -eq 0 ]]; then
		rm -r "$drtc"/.inx "$drtc"/cfg.3 "$drtc"/cfg.4 "$drtc"/cfg.0
		touch "$drtc"/.inx "$drtc"/cfg.3 "$drtc"/cfg.4 "$drtc"/cfg.0
		rm -r "$kpt"/*.mp3
		rm -r "$kpt"/words/*.mp3
	else
		exit 1
	fi

fi