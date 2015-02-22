#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

sttng4=$(sed -n 1p $DC_s/cfg.3)
sttng5=$(sed -n 2p $DC_s/cfg.3)
if [ -z $sttng4 ]; then
    echo 'FALSE' > $DC_s/cfg.3
    echo ' ' >> $DC_s/cfg.3
    sttng4=$(sed -n 1p $DC_s/cfg.3)
fi

CNFG=$(yad --center --form --on-top \
    --skip-taskbar --borders=15 --expand-column=3 --no-headers \
    --print-all --button=$close:0 --width=420 --height=300 \
    --always-print-result --editable \
    --title="Google translation service" --window-icon=idiomind \
    --field="\n$(gettext "Use Google translator")\n":CHK "$sttng4" \
    --field="$(gettext "Key")"::TXT "$sttng5");

        sttng4=$(echo "$CNFG" | cut -d "|" -f1)
        sttng5=$(echo "$CNFG" | cut -d "|" -f2)
        echo "$sttng4" > $DC_s/cfg.3
        echo "$sttng5" >>  $DC_s/cfg.3
        exit

