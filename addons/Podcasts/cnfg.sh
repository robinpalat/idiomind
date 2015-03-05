#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
DCP="$DM_tl/Podcasts/.conf"
DSP="$DS_a/Podcasts"

if [ ! -d $DM_tl/Podcasts ]; then

    mkdir "$DM_tl/Podcasts"
    mkdir "$DM_tl/Podcasts/.conf"
    mkdir "$DM_tl/Podcasts/content"
    cd "$DM_tl/Podcasts/.conf/"
    touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
    echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/cfg.4)
[ ! -f $DM_tl/Podcasts/.conf/cfg.8 ] \
&& echo "14" > $DM_tl/Podcasts/.conf/cfg.8
sleep 1
echo "$tpc" > $DC_s/cfg.8
echo pd >> $DC_s/cfg.8
#notify-send -i idiomind "Podcast Mode" " $FEED" -t 3000
exit 1' > "$DM_tl/Podcasts/tpc.sh"
    chmod +x "$DM_tl/Podcasts/tpc.sh"
    echo "14" > "$DM_tl/Podcasts/.conf/cfg.8"
    "$DS/mngr.sh" mkmn
fi


if [ -z "$1" ]; then
    
    [[ -e "$DT/cp.lock" ]] && exit || touch "$DT/cp.lock"
    [ ! -f "$DCP/cfg.4" ] && touch "$DCP/cfg.4"
    cp "$DCP/cfg.4" "$DCP/cfg.4_"
    [ -f "$DCP/cfg.0" ] && st2=$(sed -n 1p "$DCP/cfg.0") || st2=FALSE
    
    CNF=$(gettext "Configure")
    CNFG=$(yad --form --center --columns=2 --borders=10 \
    --window-icon=idiomind --skip-taskbar --separator="\n"\
    --width=550 --height=360 --always-print-result \
    --title="$(gettext "Podcasts settings")"  \
    --field="" "$(sed -n 1p $DCP/cfg.4)" \
    --field="" "$(sed -n 2p $DCP/cfg.4)" \
    --field="" "$(sed -n 3p $DCP/cfg.4)" \
    --field="" "$(sed -n 4p $DCP/cfg.4)" \
    --field="" "$(sed -n 5p $DCP/cfg.4)" \
    --field="" "$(sed -n 6p $DCP/cfg.4)" \
    --field="" "$(sed -n 7p $DCP/cfg.4)" \
    --field="" "$(sed -n 8p $DCP/cfg.4)" \
    --field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 1" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 2" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 3" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 4" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 5" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 6" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 7" \
    --field="<small>$CNF</small>":BTN "$DSP/tls.sh check 8" \
    --field="$(gettext "Syncronize")":BTN "$DSP/tls.sh syndlg" \
    --button="gtk-apply":0)

    printf "$CNFG" | head -n 8 | sed 's/^ *//; s/ *$//; /^$/d' > "$DT/pc.tmp"
    [[ -n "$(cat "$DT/pc.tmp")" ]] && mv -f "$DT/pc.tmp" "$DCP/cfg.4" || cp -f "$DCP/cfg.4_" "$DCP/cfg.4"
    printf "$CNFG" | tail -n 1 > "$DCP/cfg.0"
    [[ -f "$DCP/cfg.4_" ]] && rm "$DCP/cfg.4_"
    [[ -e "$DT/cp.lock" ]] && rm -f "$DT/cp.lock"
    
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

elif [ "$1" = edit ]; then

    slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$DM_tl/Podcasts/.conf/cfg.0" | wc -l)" -ge 20 ]]; then
dd="id01
$DSP/images/edit.png
$(gettext "Subscriptions")
id02
$DSP/images/sync.png
$(gettext "Syncronize")
id03
$DSP/images/save.png
$(gettext "Create topic")
id04
$DSP/images/del.png
$(gettext "Delete episodes")
id05
$DSP/images/del.png
$(gettext "Delete episodes saved")"
else
dd="id01
$DSP/images/edit.png
$(gettext "Subscriptions")
id02
$DSP/images/sync.png
$(gettext "Syncronize")
id04
$DSP/images/del.png
$(gettext "Delete episodes")
id05
$DSP/images/del.png
$(gettext "Delete episodes saved")"
fi

    echo "$dd" | yad --list --on-top \
    --expand-column=2 --center --print-column=1 \
    --width=360 --name=idiomind --class=idiomind \
    --height=300 --title="$(gettext "Edit")" --skip-taskbar \
    --window-icon=idiomind --no-headers --hide-column=1 \
    --buttons-layout=end --borders=5 --button=OK:0 \
    --column=id:TEXT --column=icon:IMG --column=Action:TEXT > "$slct"
    ret=$?
    slt=$(cat "$slct")
    
    if  [ "$ret" -eq 0 ]; then
        if echo "$slt" | grep -o "id03"; then
            "$DSP/add.sh" new_topic
        elif echo "$slt" | grep -o "id04"; then
            "$DSP/mngr.sh" delete_episodes
        elif echo "$slt" | grep -o "id05"; then
            "$DSP/mngr.sh" delete_episodes_saved
        elif echo "$slt" | grep -o "id01"; then
            "$DSP/cnfg.sh"
        elif echo "$slt" | grep -o "id02"; then
            "$DSP/tls.sh" syncronize
        fi
        rm -f "$slct"

    elif [ "$ret" -eq 1 ]; then
        exit 1
    fi
fi
