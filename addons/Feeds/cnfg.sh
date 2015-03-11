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
    touch 0.cfg 1.cfg 3.cfg 4.cfg .updt.lst
    echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/4.cfg)
[ ! -f $DM_tl/Feeds/.conf/8.cfg ] \
&& echo "14" > $DM_tl/Feeds/.conf/8.cfg
sleep 1
echo "$tpc" > $DC_s/8.cfg
echo pd >> $DC_s/8.cfg
#notify-send -i idiomind "Podcast Mode" " $FEED" -t 3000
exit 1' > "$DM_tl/Feeds/tpc.sh"
    chmod +x "$DM_tl/Feeds/tpc.sh"
    echo "14" > "$DM_tl/Feeds/.conf/8.cfg"
    "$DS/mngr.sh" mkmn
fi


if [ -z "$1" ]; then
    
    [[ -e "$DT/cp.lock" ]] && exit || touch "$DT/cp.lock"
    [ ! -f "$DCP/4.cfg" ] && touch "$DCP/4.cfg"
    cp "$DCP/4.cfg" "$DCP/4.cfg_"
    [ -f "$DCP/0.cfg" ] && st2=$(sed -n 1p "$DCP/0.cfg") || st2=FALSE
    
    CNF=$(gettext "Configure")
    CNFG=$(yad --form --center --scroll --columns=2 --borders=10 \
    --window-icon=idiomind --skip-taskbar --separator="\n"\
    --width=550 --height=360 --always-print-result --on-top \
    --title="$(gettext "Feeds settings")"  \
    --field="" "$(sed -n 1p $DCP/4.cfg)" \
    --field="" "$(sed -n 2p $DCP/4.cfg)" \
    --field="" "$(sed -n 3p $DCP/4.cfg)" \
    --field="" "$(sed -n 4p $DCP/4.cfg)" \
    --field="" "$(sed -n 5p $DCP/4.cfg)" \
    --field="" "$(sed -n 6p $DCP/4.cfg)" \
    --field="" "$(sed -n 7p $DCP/4.cfg)" \
    --field="" "$(sed -n 8p $DCP/4.cfg)" \
    --field="" "$(sed -n 9p $DCP/4.cfg)" \
    --field="" "$(sed -n 10p $DCP/4.cfg)" \
    --field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
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
    --field="$(gettext "Syncronize")":BTN "$DSP/tls.sh syndlg" \
    --button="gtk-apply":0)

    printf "$CNFG" | head -n 10 | sed 's/^ *//; s/ *$//; /^$/d' > "$DT/pc.tmp"
    [[ -n "$(cat "$DT/pc.tmp")" ]] && mv -f "$DT/pc.tmp" "$DCP/4.cfg" || cp -f "$DCP/4.cfg_" "$DCP/4.cfg"
    printf "$CNFG" | tail -n 1 > "$DCP/0.cfg"
    [[ -f "$DCP/4.cfg_" ]] && rm "$DCP/4.cfg_"
    [[ -e "$DT/cp.lock" ]] && rm -f "$DT/cp.lock"
    
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

fi
