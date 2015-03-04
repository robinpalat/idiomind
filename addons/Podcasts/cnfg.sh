#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
DCF="$DC/addons/Podcasts"
DSF="$DS/addons/Podcasts"

if [ ! -d $DM_tl/Podcasts ]; then

    mkdir $DM_tl/Podcasts
    mkdir $DM_tl/Podcasts/.conf
    mkdir $DM_tl/Podcasts/content
    mkdir $DM_tl/Podcasts/kept
    cd $DM_tl/Podcasts/.conf/
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
exit 1' > $DM_tl/Podcasts/tpc.sh
    chmod +x $DM_tl/Podcasts/tpc.sh
    echo "14" > $DM_tl/Podcasts/.conf/cfg.8
    $DS/mngr.sh mkmn
fi


if [ -z "$1" ]; then

    [ ! -f $DCF/$lgtl/link ] && touch $DCF/$lgtl/link
    [ -f "$DCF/.cnf" ] && st2=$(sed -n 1p "$DCF/.cnf") || st2=FALSE
    [ -f "$DCF/.cnf" ] && st3=$(sed -n 2p "$DCF/.cnf") || st3=FALSE
    
    CNFG=$(yad --form --center --columns=2 --borders=10 \
    --window-icon=idiomind --skip-taskbar --separator="\n"\
    --width=550 --height=360 --always-print-result \
    --title="$(gettext "Podcasts settings")"  \
    --field="" "$(sed -n 1p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 2p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 3p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 4p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 5p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 6p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 7p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 8p $DCF/$lgtl/link)" \
    --field="$(gettext "Update at startup")":CHK "$st2" \
    --field="$(gettext "Videos on fullscreen")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st3" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 1" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 2" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 3" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 4" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 5" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 6" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 7" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 8" \
    --field="$(gettext "Syncronize")":BTN "$DSF/tls.sh syndlg" --field=" ":lbl \
    --button="gtk-apply":0)

    printf "$CNFG" | head -n 8 | sed 's/^ *//; s/ *$//; /^$/d' > $DCF/$lgtl/link
    printf "$CNFG" | tail -n 2 > $DCF/.cnf
    
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

elif [ "$1" = edit ]; then

    slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$DM_tl/Podcasts/.conf/cfg.0" | wc -l)" -ge 20 ]]; then
dd="id01
$DSF/images/edit.png
$(gettext "Subscriptions")
id02
$DSF/images/sync.png
$(gettext "Syncronize")
id03
$DSF/images/save.png
$(gettext "Create topic")
id04
$DSF/images/del.png
$(gettext "Delete episodes")
id05
$DSF/images/del.png
$(gettext "Delete episodes saved")"
else
dd="id01
$DSF/images/edit.png
$(gettext "Subscriptions")
id02
$DSF/images/sync.png
$(gettext "Syncronize")
id04
$DSF/images/del.png
$(gettext "Delete episodes")
id05
$DSF/images/del.png
$(gettext "Delete episodes saved")"
fi

    echo "$dd" | yad --list --on-top \
    --expand-column=2 --center --print-column=1 \
    --width=400 --name=idiomind --class=idiomind \
    --height=340 --title="$(gettext "Edit")" --skip-taskbar \
    --window-icon=idiomind --no-headers --hide-column=1 \
    --buttons-layout=end --borders=5 --button=OK:0 \
    --column=id:TEXT --column=icon:IMG --column=Action:TEXT > "$slct"
    ret=$?
    slt=$(cat "$slct")
    
    if  [[ "$ret" -eq 0 ]]; then
        if echo "$slt" | grep -o "id03"; then
            "$DSF/add.sh" new_topic
        elif echo "$slt" | grep -o "id04"; then
            "$DSF/mngr.sh" delete_episodes
        elif echo "$slt" | grep -o "id05"; then
            "$DSF/mngr.sh" delete_episodes_saved
        elif echo "$slt" | grep -o "id01"; then
            "$DSF/cnfg.sh"
        elif echo "$slt" | grep -o "id02"; then
            "$DSF/tls.sh" syncronize
        fi
        rm -f "$slct"

    elif [[ "$ret" -eq 1 ]]; then
        exit 1
    fi
fi
