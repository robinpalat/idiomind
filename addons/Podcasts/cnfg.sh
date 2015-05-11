#!/bin/bash
# -*- ENCODING: UTF-8 -*-
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
DCP="$DM_tl/Podcasts/.conf"
DSP="$DS_a/Podcasts"
CNF=$(gettext "Configure")
sets=('update' 'sync' 'path')
if [ -n "$(< "$DCP/0.cfg")" ]; then cfg=1; else
> "$DCP/0.cfg"; fi

if [ ! -d "$DM_tl/Podcasts" ]; then
    mkdir "$DM_tl/Podcasts"
    mkdir "$DM_tl/Podcasts/.conf"
    mkdir "$DM_tl/Podcasts/cache"
    cd "$DM_tl/Podcasts/.conf/"
    touch "0.cfg" "1.cfg" "2.cfg" "3.cfg" "4.cfg" ".updt.lst"
    echo 14 > "$DM_tl/Podcasts/.conf/8.cfg"
    echo " " > "$DM_tl/Podcasts/.conf/10.cfg"
    echo -e " $(gettext "Last update:")
 $(gettext "Latest downloads:") 0  $(gettext "Saved episodes:") \
0 "> "$DM_tl/Podcasts/update"
    "$DS/mngr.sh" mkmn
fi

[[ -e "$DT/cp.lock" ]] && exit || touch "$DT/cp.lock"
[ ! -f "$DCP/4.cfg" ] && touch "$DCP/4.cfg"
[ -f "$DCP/0.cfg" ] && st2=$(sed -n 1p "$DCP/0.cfg") || st2=FALSE

n=1; while read feed; do
    declare url$n="$feed"
    ((n=n+1))
done < "$DCP/4.cfg"

n=0
while [[ $n -lt 3 ]]; do

    if [ "$cfg" = 1 ]; then
        itn=$((n+1))
        get="${sets[$n]}"
        val=$(sed -n "$itn"p < "$DCP/0.cfg" \
        | grep -o "$get"=\"[^\"]* | grep -o '[^"]*$')
        declare ${sets[$n]}="$val"
        
    else
        if [ $n -lt 2 ]; then
        val="FALSE"; else val="/uu"; fi
        echo -e "${sets[$n]}=\"$val\"" >> "$DCP/0.cfg"
    fi
    ((n=n+1))
done
    
apply() {
    
    printf "$CNFG" | sed 's/|/\n/g' | sed -n 4,15p | \
    sed 's/^ *//; s/ *$//g' > "$DT/podcasts.tmp"

    n=1; while read feed; do
        declare mod$n="$feed"
        mod="mod$n"; url="url$n"
        if [ "${!url}" != "${!mod}" ]; then
            "$DSP/tls.sh" set_channel "${!mod}" $n & fi
        ((n=n+1))
    done < "$DT/podcasts.tmp"

    podcaststmp="$(cat "$DT/podcasts.tmp")"
    if ([ -n "$podcaststmp" ] && [ "$podcaststmp" != "$(cat "$DCP/4.cfg")" ]); then
    mv -f "$DT/podcasts.tmp" "$DCP/4.cfg"; else rm -f "$DT/podcasts.tmp"; fi


    val1=$(cut -d "|" -f1 <<<"$CNFG")
    val2=$(cut -d "|" -f2 <<<"$CNFG")
    val3=$(cut -d "|" -f18 <<<"$CNFG" | sed 's|/|\\/|g')
    if [ ! -d "$val3" ] || [ -z "$val3" ]; then path=/uu; fi
    sed -i "s/update=.*/update=\"$val1\"/g" "$DCP/0.cfg"
    sed -i "s/sync=.*/sync=\"$val2\"/g" "$DCP/0.cfg"
    sed -i "s/path=.*/path=\"${val3}\"/g" "$DCP/0.cfg"
    [ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
}

if [ ! -d "$path" ] || [ ! -n "$path" ]; then path=/uu; fi
if [ -f "$DM_tl/Podcasts/.conf/feed.err" ]; then
e="$(head -n 2 < "$DM_tl/Podcasts/.conf/feed.err" | tr '&' ' ' | uniq)"
rm "$DM_tl/Podcasts/.conf/feed.err"
(sleep 2 && msg "$(gettext "Errors found in log file:")\n$e\n" info Info) &
fi

CNFG=$(yad --form --title="$(gettext "Podcasts settings")" \
--name=Idiomind --class=Idiomind \
--always-print-result --print-all --separator="|" \
--window-icon="$DS/images/icon.png" --center --scroll --on-top \
--width=550 --height=440 --borders=10 \
--text="$(gettext "Configure feed URLs to learn with educational podcasts.")" \
--field="$(gettext "Update at startup")":CHK "$update" \
--field="$(gettext "Sync after update")":CHK "$sync" \
--field="$(gettext "URL")":LBL " " \
--field="" "$url1" --field="" "$url2" --field="" "$url3" \
--field="" "$url4" --field="" "$url5" --field="" "$url6" \
--field="" "$url7" --field="" "$url8" --field="" "$url9" \
--field="" "$url10" --field="" "$url11" --field="" "$url12" \
--field=" ":LBL " " \
--field="$(gettext "Path where episodes should be synced")":LBL " " \
--field="":DIR "$path" \
--field="$(gettext "Remove Episodes")":FBTN "$DSP/mngr.sh 'delete_1'" \
--field="$(gettext "Remove Saved Episodes")":FBTN "$DSP/mngr.sh 'delete_2'" \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "Syncronize")":5 \
--button="gtk-apply":0)

ret=$?

if [ "$ret" -eq 0 ]; then
    
    apply;
    
elif [ "$ret" -eq 5 ]; then

    apply
    "$DSP/tls.sh" sync
fi

[ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
exit
