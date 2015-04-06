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


if [ ! -f "$DCP/0.cfg" ] \
|| [ -z "$(<"$DCP/0.cfg")" ]; then
> "$DCP/0.cfg"
echo -e "update=\"\"
sync=\"\" >> 
path=\"\"" >> "$DCP/0.cfg"; fi
source "$DCP/0.cfg"

apply() {
    
    printf "$CNFG" | sed 's/|/\n/g' | sed -n 7,16p | \
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

    val1=$(cut -d "|" -f1 <<<"$CNFG")
    val2=$(cut -d "|" -f2 <<<"$CNFG")
    val3=$(cut -d "|" -f4 <<<"$CNFG" | sed 's|/|\\/|g')
    sed -i "s/update=.*/update=$val1/;s/sync=.*/sync=$val2/;s/path=.*/path=$val3/g" "$DCP/0.cfg"
    [ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
}

if [ -z "$1" ]; then

CNFG=$(yad --form --center --scroll --borders=20 \
--window-icon=idiomind --skip-taskbar --separator="|" \
--name=Idiomind --class=Idiomind --text=" " \
--width=600 --height=460 --always-print-result --print-all --on-top \
--title="$(gettext "Feeds settings")"  \
--text="$(gettext "Configure feeds to learn with podcasts or news.")"  \
--field="$(gettext "Update at startup")":CHK "$update" \
--field="$(gettext "Sync after update")":CHK "$sync" \
--field="$(gettext "Mountpoint or path where episodes should be synced.")":LBL " " \
--field="":DIR "$path" \
--field=" ":LBL " " \
--field="$(gettext "Feeds")":LBL " " \
--field="" "$url1" --field="" "$url2" --field="" "$url3" \
--field="" "$url4" --field="" "$url5" --field="" "$url6" \
--field="" "$url7" --field="" "$url8" --field="" "$url9" \
--field="" "$url10" \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "Advance")":2 \
--button="$(gettext "Syncronize")":5 \
--button="gtk-apply":0)



elif [ "$1" = "adv" ]; then

CNFG=$(yad --form --center --scroll --columns=2 --borders=10 \
--window-icon=idiomind --skip-taskbar --separator="|" \
--name=Idiomind --class=Idiomind --text=" " \
--width=550 --height=360 --always-print-result --print-all --on-top \
--title="$(gettext "Feeds settings")"  \
--field="1 $url1":lbl --field="2 $url2":lbl --field="3 $url3":lbl \
--field="4 $url4":lbl --field="5 $url5":lbl --field="6 $url6":lbl \
--field="7 $url7":lbl --field="8 $url8":lbl --field="9 $url9":lbl \
--field="10 $url10":lbl --field=" ":LBL " " \
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

    apply;

elif [ "$ret" -eq 2 ]; then
    
    apply
    "$DS_a/Feeds/cnfg.sh" adv;
    
elif [ "$ret" -eq 5 ]; then

    apply
    "$DSP/tls.sh" sync;

fi
[ -f "$DT/cp.lock" ] && rm -f "$DT/cp.lock"
exit
