#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
DCF="$DM_tl/Feeds/.conf"
DSF="$DS/addons/Feeds"

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
&& echo "11" > $DM_tl/Feeds/.conf/8.cfg
sleep 1
echo "$tpc" > $DC_s/8.cfg
echo fd >> $DC_s/8.cfg
#notify-send -i idiomind "Feed Mode" " $FEED" -t 3000
exit 1' > "$DM_tl/Feeds/tpc.sh"
    chmod +x "$DM_tl/Feeds/tpc.sh"
    echo "14" > "$DM_tl/Feeds/.conf/8.cfg"
    "$DS/mngr.sh" mkmn
fi


if [ -z "$1" ]; then
    
    [[ -e "$DT/cf.lock" ]] && exit || touch "$DT/cf.lock"
    [ ! -f "$DCF/4.cfg" ] && touch "$DCF/4.cfg"
    cp "$DCF/4.cfg" "$DCF/4.cfg_"
    [ -f "$DCF/0.cfg" ] && st2=$(sed -n 1p "$DCF/0.cfg") || st2=FALSE
    
    CNF=$(gettext "Configure")
    CNFG=$(yad --form --center --columns=2 --borders=10 \
    --window-icon=idiomind --skip-taskbar --separator="\n"\
    --width=550 --height=360 --always-print-result \
    --title="$(gettext "Feeds settings")" --scroll \
    --field="1" "$(sed -n 1p $DCF/4.cfg)" \
    --field="2" "$(sed -n 2p $DCF/4.cfg)" \
    --field="3" "$(sed -n 3p $DCF/4.cfg)" \
    --field="4" "$(sed -n 4p $DCF/4.cfg)" \
    --field="5" "$(sed -n 5p $DCF/4.cfg)" \
    --field="6" "$(sed -n 6p $DCF/4.cfg)" \
    --field="7" "$(sed -n 7p $DCF/4.cfg)" \
    --field="8" "$(sed -n 8p $DCF/4.cfg)" \
    --field="9" "$(sed -n 9p $DCF/4.cfg)" \
    --field="10" "$(sed -n 10p $DCF/4.cfg)" \
    --field="11" "$(sed -n 11p $DCF/4.cfg)" \
    --field="12" "$(sed -n 12p $DCF/4.cfg)" \
    --field="13" "$(sed -n 13p $DCF/4.cfg)" \
    --field="14" "$(sed -n 14p $DCF/4.cfg)" \
    --field="15" "$(sed -n 15p $DCF/4.cfg)" \
    --field="16" "$(sed -n 16p $DCF/4.cfg)" \
    --field="17" "$(sed -n 17p $DCF/4.cfg)" \
    --field="18" "$(sed -n 18p $DCF/4.cfg)" \
    --field="19" "$(sed -n 19p $DCF/4.cfg)" \
    --field="20" "$(sed -n 20p $DCF/4.cfg)" \
    --field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 1" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 2" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 3" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 4" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 5" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 6" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 7" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 8" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 9" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 10" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 11" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 12" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 13" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 14" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 15" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 16" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 17" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 18" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 19" \
    --field="<small>$CNF</small>":BTN "'$DSF/tls.sh' check 20" \
    --field=" ":LBL "" \
    --button="gtk-apply":0)

    printf "$CNFG" | head -n 20 | sed 's/^ *//; s/ *$//; /^$/d' > "$DT/pc.tmp"
    [[ -n "$(cat "$DT/pc.tmp")" ]] && mv -f "$DT/pc.tmp" "$DCF/4.cfg" || cp -f "$DCF/4.cfg_" "$DCF/4.cfg"
    printf "$CNFG" | tail -n 1 > "$DCF/0.cfg"
    [[ -f "$DCF/4.cfg_" ]] && rm "$DCF/4.cfg_"
    [[ -e "$DT/cf.lock" ]] && rm -f "$DT/cf.lock"
    
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

fi
