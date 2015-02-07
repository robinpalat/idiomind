#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

wrd="$1"
Wrd="${wrd^}"
DT_r="$2"
dir="$DC/addons/dict/"

function dict() {
	if [ "$3" = swrd ]; then

		cd $DT_r
		if [ -f "$DM_tl/.share/$Wrd.mp3" ]; then
				cp -f "$DM_tl/.share/$Wrd.mp3" "$Wrd.mp3" && exit
		else
			n=1
			while [ $n -le $(cat "$dir/.dicts" | wc -l) ]; do
				sh "$(sed -n "$n"p $dir/.dicts)" "$wrd"
				if [ -f "$wrd.mp3" ]; then
					mv "$wrd.mp3" "$Wrd.mp3"
					break && exit
				fi
				let n++
			done
			exit
		fi

	else

		cd $DT_r
		if [ -f "$DM_tl/.share/$Wrd.mp3" ]; then
			echo "$Wrd.mp3" >> "$DC_tlt/cfg.5" && exit
		else
			n=1
			while [ $n -le $(cat $dir/.dicts | wc -l) ]; do
				sh "$(sed -n "$n"p $dir/.dicts)" "$wrd"
				if [ -f "$wrd.mp3" ]; then
					mv "$wrd.mp3" "$DM_tl/.share/$Wrd.mp3"
					echo "$Wrd.mp3" >> "$DC_tlt/cfg.5"
					break && exit
				fi
				let n++
			done
			exit
		fi
	fi

}
