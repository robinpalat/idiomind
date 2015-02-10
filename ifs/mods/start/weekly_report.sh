#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if ([ "$(date +%u)" = 2 ] && \
	[ "$(sed -n 1p $DC_a/stats/cnfg)" = "TRUE" ]); then
	"$DS/addons/weekly report/cnfg.sh" A &
fi
