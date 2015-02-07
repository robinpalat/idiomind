#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if ([ "$(date +%u)" = 6 ] && \
[ "$(sed -n 1p $DC_s/cfg.12)" = "TRUE" ]); then
	"$DS/addons/User data/cnfg.sh" C &
fi
