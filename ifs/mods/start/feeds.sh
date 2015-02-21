#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if [ -f "$DC_a/Learning with news/.cnf" ]; then
	if [ "$(sed -n 1p "$DC_a/Learning with news/.cnf")" = "TRUE" ]; then
		(sleep 200
		"$DS_a/Learning with news/strt.sh" A
		) &
	fi
fi
