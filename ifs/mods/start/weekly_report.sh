#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if ([ "$(date +%u)" = '4' ] && \
	[ "$(sed -n 1p $DC_a/stats/cnfg)" = "TRUE" ]); then
	(sleep 10 "$DS/addons/weekly report/cnfg.sh" A) &
fi
