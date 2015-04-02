#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
DCP="$DM_tl/Feeds/.conf"
DSP="$DS_a/Feeds"

if [ ! -d $DM_tl/Feeds ]; then

    mkdir "$DM_tl/Feeds"
    mkdir "$DM_tl/Feeds/.conf"
    mkdir "$DM_tl/Feeds/cache"
    cd "$DM_tl/Feeds/.conf/"
    touch "0.cfg" "1.cfg" "2.cfg" "3.cfg" "4.cfg" ".updt.lst"
    echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
[ ! -f $DM_tl/Feeds/.conf/8.cfg ] \
&& echo "11" > $DM_tl/Feeds/.conf/8.cfg
echo "$tpc" > $DC_s/4.cfg
echo fd >> $DC_s/4.cfg
idiomind topic
exit 1' > "$DM_tl/Feeds/tpc.sh"
    chmod +x "$DM_tl/Feeds/tpc.sh"
    echo "14" > "$DM_tl/Feeds/.conf/8.cfg"
    "$DS/mngr.sh" mkmn
fi

[[ -e "$DT/cp.lock" ]] && exit || touch "$DT/cp.lock"
[ ! -f "$DCP/4.cfg" ] && touch "$DCP/4.cfg"
[ -f "$DCP/0.cfg" ] && st2=$(sed -n 1p "$DCP/0.cfg") || st2=FALSE

n=1; while read feed; do
    declare url"$n"="$feed"
    ((n=n+1))
done < "$DCP/4.cfg"

CNF=$(gettext "Configure")

if [ -z "$1" ]; then

CNFG=$(yad --form --center --scroll --borders=10 \
--window-icon=idiomind --skip-taskbar --separator="|" \
--name=Idiomind --class=Idiomind --text=" " \
--width=550 --height=360 --always-print-result --print-all --on-top \
--title="$(gettext "Feeds settings")"  \
--field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
--field="" "$url1" --field="" "$url2" --field="" "$url3" \
--field="" "$url4" --field="" "$url5" --field="" "$url6" \
--field="" "$url7" --field="" "$url8" --field="" "$url9" \
--field="" "$url10" \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "Syncronize")":"$DSP/tls.sh 'syndlg'" \
--button="gtk-apply":0)
#--button="$(gettext "Advance")":2 

elif [ "$1" = "adv" ]; then

CNFG=$(yad --form --center --scroll --columns=2 --borders=10 \
--window-icon=idiomind --skip-taskbar --separator="|" \
--name=Idiomind --class=Idiomind --text=" " \
--width=550 --height=360 --always-print-result --print-all --on-top \
--title="$(gettext "Feeds settings")"  \
--field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
--field="1" "$url1" --field="2" "$url2" --field="3" "$url3" \
--field="4" "$url4" --field="5" "$url5" --field="6" "$url6" \
--field="7" "$url7" --field="8" "$url8" --field="9" "$url9" \
--field="10" "$url10" --field=" ":LBL " " \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 1" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 2" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 3" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 4" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 5" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 6" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 7" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 8" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 9" \
--field="<small>$CNF</small>":BTN "$DSP/tls.sh check 10" \
--button="$(gettext "Cancel")":1 --button="gtk-apply":0)
fi

ret=$?

if [ "$ret" -eq 0 ]; then

    printf "$CNFG" | sed 's/|/\n/g' | sed -n 2,11p | \
    sed 's/^ *//; s/ *$//g' > "$DT/feeds.tmp"

    n=1; while read feed; do
        declare mod"$n"="$feed"
        mod="mod$n"; url="url$n"
        if [ "${!url}" != "${!mod}" ]; then
            "$DSP/tls.sh" set_channel "${!mod}" $n & fi
        ((n=n+1))
    done < "$DT/feeds.tmp"

    feedstmp="$(cat "$DT/feeds.tmp")"
    if ([ -n "$feedstmp" ] && [ "$feedstmp" != "$(cat "$DCP/4.cfg")" ]); then
        mv -f "$DT/feeds.tmp" "$DCP/4.cfg"; else rm -f "$DT/feeds.tmp"; fi

    printf "$CNFG" | sed 's/|/\n/g' | head -n 1 > "$DCP/0.cfg";

elif [ "$ret" -eq 2 ]; then

    [[ -e "$DT/cp.lock" ]] && rm -f "$DT/cp.lock"
    "$DS_a/Feeds/cnfg.sh" adv;

fi

[[ -e "$DT/cp.lock" ]] && rm -f "$DT/cp.lock" & exit

