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
    mkdir $DM_tl/Podcasts/kept/.audio
    mkdir $DM_tl/Podcasts/kept/words
    mkdir "$DC_a/Podcasts"
    cd $DM_tl/Podcasts/.conf/
    touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
fi

if [ ! -d "$DC_a/Podcasts/$lgtl" ]; then

    mkdir "$DC_a/Podcasts/$lgtl"
    mkdir "$DC_a/Podcasts/$lgtl/rss"
    cp -f "$DSF/examples/$lgtl" "$DCF/$lgtl/rss/$sample"
fi


[ -f "$DCF/$lgtl/.rss" ] && url_rss=$(sed -n 1p "$DCF/$lgtl/.rss")

if [ -z "$1" ]; then

    [ ! -f $DCF/$lgtl/link ] && touch $DCF/$lgtl/link
    [ -f "$DCF/.cnf" ] && st2=$(sed -n 1p "$DCF/.cnf") || st2=FALSE
    CNFG=$(yad --form --center --columns=2 \
    --text="  $(gettext "Subscriptions") [$lgtl]" --borders=5 \
    --window-icon=idiomind --skip-taskbar --separator="\n"\
    --width=460 --height=310 --always-print-result \
    --title="Podcasts"  \
    --field="" "$(sed -n 1p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 2p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 3p $DCF/$lgtl/link)" \
    --field="" "$(sed -n 4p $DCF/$lgtl/link)" \
    --field="$(gettext "Update at startup")\t\t\t\t\t\t\t\t\t\t\t":CHK "$st2" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 1" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 2" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 3" \
    --field="<small>$(gettext "Configure")</small>":BTN "$DS/addons/Podcasts/tls.sh check 4" \
    --button="gtk-apply":4)
    printf "$CNFG" | head -n 4 > $DCF/$lgtl/link
    printf "$CNFG" | tail -n 1 > $DCF/.cnf
        
        
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

elif [ "$1" = edit ]; then

    slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$DM_tl/Podcasts/.conf/cfg.0" | wc -l)" -ge 20 ]]; then
dd="id01
$DSF/images/save.png
$(gettext "Create topic")
id02
$DSF/images/del.png
$(gettext "Delete episodes")
id03
$DSF/images/del.png
$(gettext "Delete episodes saved")
id04
$DSF/images/edit.png
$(gettext "Subscriptions")
id05
$DSF/images/sync.png
$(gettext "Syncronize")"
else
dd="id02
$DSF/images/del.png
$(gettext "Delete episodes")
id03
$DSF/images/del.png
$(gettext "Delete episodes saved")
id04
$DSF/images/edit.png
$(gettext "Subscriptions")
id05
$DSF/images/sync.png
$(gettext "Syncronize")"
fi

    echo "$dd" | yad --list --on-top \
    --expand-column=2 --center --print-column=1 \
    --width=290 --name=idiomind --class=idiomind \
    --height=240 --title="$(gettext "Edit")" --skip-taskbar \
    --window-icon=idiomind --no-headers --hide-column=1 \
    --buttons-layout=end --borders=0 --button=Ok:0 \
    --column=id:TEXT --column=icon:IMG --column=Action:TEXT > "$slct"
    ret=$?
    slt=$(cat "$slct")
    
    if  [[ "$ret" -eq 0 ]]; then
        if echo "$slt" | grep -o "id01"; then
            "$DSF/add.sh" new_topic
        elif echo "$slt" | grep -o "id02"; then
            "$DSF/mngr.sh" delete_episodes
        elif echo "$slt" | grep -o "id03"; then
            "$DSF/mngr.sh" delete_episodes_saved
        elif echo "$slt" | grep -o "id04"; then
            "$DSF/cnfg.sh"
        elif echo "$slt" | grep -o "id05"; then
            "$DSF/tls.sh" syncronize
        fi
        rm -f "$slct"

    elif [[ "$ret" -eq 1 ]]; then
        exit 1
    fi
fi
