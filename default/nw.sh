#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

if [ -d $DM ]; then
	yad --geometry=185x318-120-420 --width=160 \
		--height=220 --fixed --title=" Idiomind" --no-buttons \
		--window-icon=$DS/images/icon.png \
		--icons --single-click --skip-taskbar\
		--on-top --borders=0 \
		--read-dir=$DS/default/new --item-width=60 \
		--always-print-result
		ret=$?
		if  [[ "$ret" -eq 0 ]]; then
			exit 1 & rm "$DC_tlt/lstntry"
		fi
else
	$DS/ifs/1u
fi
