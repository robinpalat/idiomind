#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
topic="$1"
DC_tlt="$DM_tl/$topic/.conf"
DM_tlt="$DM_tl/$topic"
list="Podcasts"
cfg="name=\"$topic\"
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
level=\"$level\""

if grep -Fxo "$topic" <<<"$list"; then

    "$DS/ifs/mods/topic/$topic.sh" & exit

else
    if [ -d "$DM_tlt" ]; then

        if [ ! -d "$DM_tlt/.conf" ]; then
        mkdir -p "$DM_tlt/words/images"
        mkdir "$DM_tlt/.conf"
        cd "$DM_tlt/.conf"
        c=0; while [ $c -le 10 ]; do
        touch "$c.cfg"; let c++
        done
        rm "$DM_tlt/.conf/9.cfg"
        echo -e "$cfg" > "12.cfg"
        echo "1" > "8.cfg"
        cd "$HOME"
        fi
        
        if [ ! -f "$DC_tlt/7.cfg" ]; then
        "$DS/ifs/tls.sh" check_index "$topic"; fi
        
        stts=$(sed -n 1p < "$DC_tlt/8.cfg")
        if [[ $(grep -Fxon "$topic" < "$DM_tl/.1.cfg" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
        
            if [ -f "$DC_tlt/9.cfg" ]; then
            
                calculate_review

                if [[ $((stts%2)) = 0 ]]; then
                if [ "$RM" -ge 100 ]; then echo "8" > "$DC_tlt/8.cfg"; fi
                if [ "$RM" -ge 150 ]; then echo "10" > "$DC_tlt/8.cfg"; fi
                else
                if [ "$RM" -ge 100 ]; then echo "7" > "$DC_tlt/8.cfg"; fi
                if [ "$RM" -ge 150 ]; then echo "9" > "$DC_tlt/8.cfg"; fi
                fi
            fi
            "$DS/mngr.sh" mkmn
        fi
        
        echo "$topic" > "$DC_s/4.cfg"
        echo "$topic" > "$DM_tl/.8.cfg"
        echo "$topic" > "$DT/tpe"
        echo '0' >> "$DC_s/4.cfg" 
        echo '0' >> "$DM_tl/.8.cfg"

        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        
        if [ "$2" = 1 ]; then 
        
            sleep 2
            notify-send --icon=idiomind \
            "$topic" "$(gettext "Is your topic now")" -t 2000 & exit
            
        else
            idiomind topic & exit
        fi
        
    else
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        msg " $(gettext "File not found")\n $topic\n" error & exit 1
    fi
fi
