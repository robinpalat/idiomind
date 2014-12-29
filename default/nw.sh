#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

if [ -d $DM ]; then
	tpcs=$(cd $DC_tl && ls * -d | wc -l)
	
	if [ $tpcs -lt 1 ]; then
		$DS/ifs/notpc1.sh & exit
	fi
	if [ ! -d "$DC_tlt" ]; then
		$DS/ifs/notpc.sh & exit
	fi

	yad --geometry=185x318-120-420 --width=160 \
		--height=220 --fixed --title=" Idiomind" --no-buttons \
		--window-icon=$DS/icon/icon.png \
		--icons --single-click --skip-taskbar\
		--on-top --borders=0 \
		--read-dir=$DS/default/new --item-width=60
	rm "$DC_tlt/lstntry"
else
	$DS/ifs/1u
fi
