#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if ([ "$(date +%u)" = 7 ] && \
	[ "$(sed -n 1p $DC/addons/stats/cnf)" = "TRUE" ]); then
	"$DS/addons/weekly report/cnfg.sh" A &
fi
