#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if [ "$(sed -n 1p "$DC/addons/Learning with news/.cnf")" = "TRUE" ]; then
	(sleep 200
	"$DS/addons/Learning with news/strt.sh" A
	) &
fi
