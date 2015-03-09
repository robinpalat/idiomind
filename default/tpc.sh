#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
$DS/stop.sh tpc
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic=$(echo "$gtdr" | sed 's|\/|\n|g' | sed -n 7p)
DC_tlt="$DM_tl/$topic/.conf"
DM_tlt="$DM_tl/$topic"

if [ -d "$DM_tlt" ]; then

    if [ ! -d "$DM_tlt/.conf" ]; then
        mkdir -p "$DM_tlt/words/images"
        mkdir "$DM_tlt/.conf"
        cd "$DM_tlt/.conf"
        touch "0.cfg" "1.cfg" "2.cfg" "3.cfg" "4.cfg" "5.cfg"
        echo "$(date +%F)" > "12.cfg"
        echo "1" > "8.cfg"
        cd "$HOME"
    fi

   "$DS/ifs/tls.sh" check_index "$topic"

    # look status
    if [[ $(cat "$DM_tl/.1.cfg" | grep -Fxon "$topic" \
    | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
        if [ -f "$DC_tlt/9.cfg" ]; then
            dts=$(cat "$DC_tlt/9.cfg" | wc -l)
            if [ "$dts" = 1 ]; then
                dte=$(sed -n 1p "$DC_tlt/9.cfg")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/10))
            elif [ "$dts" = 2 ]; then
                dte=$(sed -n 2p "$DC_tlt/9.cfg")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/15))
            elif [ "$dts" = 3 ]; then
                dte=$(sed -n 3p "$DC_tlt/9.cfg")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/30))
            elif [ "$dts" = 4 ]; then
                dte=$(sed -n 4p "$DC_tlt/9.cfg")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/60))
            fi
            nstll=$(grep -Fxo "$topic" "$DM_tl/.3.cfg")
            if [ -n "$nstll" ]; then
                if [ "$RM" -ge 100 ]; then echo "9" > "$DC_tlt/8.cfg"; fi
                if [ "$RM" -ge 150 ]; then echo "10" > "$DC_tlt/8.cfg"; fi
            else
                if [ "$RM" -ge 100 ]; then echo "4" > "$DC_tlt/8.cfg"; fi
                if [ "$RM" -ge 150 ]; then echo "5" > "$DC_tlt/8.cfg"; fi
            fi
        fi
        "$DS/mngr.sh" mkmn
    fi
    
    if cat "$DM_tl/.3.cfg" | grep -Fxo "$topic"; then
        echo "$topic" > "$DC_s/8.cfg"
        echo istll >> "$DC_s/8.cfg"
        echo "$topic" > "$DM_tl/.8.cfg"
        echo istll >> "$DM_tl/.8.cfg"
        echo "$topic" > "$DC_s/6.cfg"
    else
        echo "$topic" > "$DC_s/8.cfg"
        echo wn >> "$DC_s/8.cfg"
        echo "$topic" > "$DM_tl/.8.cfg"
        echo wn >> "$DM_tl/.8.cfg"
        echo "$topic" > "$DC_s/6.cfg"
    fi
    
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
    idiomind topic &
    sleep 2
    notify-send --icon=idiomind \
    "$topic" "$(gettext "Is your topic now")" -t 2000 & exit 0
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    msg " $(gettext "File not found")\n $topic\n" error & exit 1
fi
