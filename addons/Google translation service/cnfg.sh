#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
sttng4=$(sed -n 1p $DC_s/3.cfg)
sttng5=$(sed -n 2p $DC_s/3.cfg)
if [ -z $sttng4 ]; then
echo 'FALSE' > $DC_s/3.cfg
echo ' ' >> $DC_s/3.cfg
sttng4=$(sed -n 1p $DC_s/3.cfg); fi

c=$(yad --center --form --on-top \
--skip-taskbar --borders=15 --expand-column=3 --no-headers \
--button="$(gettext "OK")":0 --width=480 --height=350 \
--always-print-result --editable --print-all \
--title="Google translation service" --window-icon=idiomind \
--field="\n$(gettext "Use Google translator")\n":CHK "$sttng4" \
--field="$(gettext "Key (optional)")"::TXT "$sttng5");
echo "$(echo "$c" | cut -d "|" -f1)" > $DC_s/3.cfg
echo "$(echo "$c" | cut -d "|" -f2)" >>  $DC_s/3.cfg; exit

