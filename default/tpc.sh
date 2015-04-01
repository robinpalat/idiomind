#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic="$(sed 's|\/|\n|g' <<<"$gtdr" | sed -n 7p)"
DC_tlt="$DM_tl/$topic/.conf"
DM_tlt="$DM_tl/$topic"

if [ -d "$DM_tlt" ]; then

if [ ! -d "$DM_tlt/.conf" ]; then
mkdir -p "$DM_tlt/words/images"
mkdir "$DM_tlt/.conf"
cd "$DM_tlt/.conf"
c=0; while [ $c -le 10 ]; do
touch "$c.cfg"; let c++
done
rm "$DM_tlt/.conf/9.cfg"
echo -e "
name=\"$topic\"
language_source=\"$lgsl\"
language_target=\"$lgtl\"
author=\"$Author\"
contact=\"$Mail\"
category=\"$Ctgry\"
link=\"$link\"
date_c=\"$(date +%F)\"
date_u=\"$date_u\"
nwords=\"$words\"
nsentences=\"$sentences\"
nimages=\"$images\"
level=\"$level\"" > "12.cfg"
echo "1" > "8.cfg"
cd "$HOME"
fi

   "$DS/ifs/tls.sh" check_index "$topic"

    # look status
    if [[ $(grep -Fxon "$topic" < "$DM_tl/.1.cfg" \
    | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
        if [ -f "$DC_tlt/9.cfg" ]; then
            dts=$(wc -l < "$DC_tlt/9.cfg")
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
    
    echo "$topic" > "$DC_s/4.cfg"
    echo "$topic" > "$DM_tl/.8.cfg"
    echo "$topic" > "$DT/tpe"
    if grep -Fxo "$topic" < "$DM_tl/.3.cfg"; then
        echo istll >> "$DC_s/4.cfg" 
        echo istll >> "$DM_tl/.8.cfg"
    else
        echo wn >> "$DC_s/4.cfg"
        echo wn >> "$DM_tl/.8.cfg"
    fi

    cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    [ -z "$1" ] && idiomind topic &
    sleep 2
    notify-send --icon=idiomind \
    "$topic" "$(gettext "Is your topic now")" -t 2000 & exit 0
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    msg " $(gettext "File not found")\n $topic\n" error & exit 1
fi
