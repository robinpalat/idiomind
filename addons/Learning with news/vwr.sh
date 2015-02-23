#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DS_pf="$DS/addons/Learning with news"
vwr="$DS_pf/vwr.sh"
ap=$(cat $DC_s/cfg.1 | sed -n 6p)
listen="▷"

if [[ $1 = V1 ]]; then

    DS_pf="$DS/addons/Learning with news"
    wth=$(sed -n 5p $DC_s/cfg.18)
    eht=$(sed -n 6p $DC_s/cfg.18)
    c=$(echo $(($RANDOM%100)))
    re='^[0-9]+$'
    now="$2"
    nuw="$3"

    if ! [[ $nuw =~ $re ]]; then
        nuw=$(cat "$DM_tl/Feeds/.conf/cfg.1" | grep -Fxon "$now" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        nll=" "
    fi

    item="$(sed -n "$nuw"p "$DM_tl/Feeds/.conf/cfg.1")"

    if [ -z "$item" ]; then
        item="$(sed -n 1p "$DM_tl/Feeds/.conf/cfg.1")"
        nuw=1
    fi
    
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

    echo "$fname" > $DT/item.x
    tgs=$(eyeD3 "$DM_tl/Feeds/conten/$fname.mp3")
    trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
    lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
    lnk=$(cat "$DM_tl/Feeds/conten/$fname.lnk")
    
    if [[ -f "$DM_tl/Feeds/conten/$fname.mp3" ]]; then
    
        if [ "$ap" = TRUE ]; then
            (killall play & sleep 0.3 && play "$DM_tl/Feeds/conten/$fname.mp3") &
        fi
        
        echo "$lwrd" | awk '{print $0""}' | $yad --list \
        --window-icon=idiomind --scroll --quoted-output \
        --skip-taskbar --center --title=" " --borders=20 \
        --text="<big><big>$trg</big></big> <a href='$lnk'>$(gettext "More")</a>\\n\\n<i>$srce</i>\\n\\n\\n" \
        --width="$wth" --height="$eht" --center --no-headers \
        --column=$lgtl:TEXT --column=$lgsl:TEXT --selectable-labels \
        --expand-column=0 --limit=20 \
        --button="$(gettext "Save")":"'$DS_pf/add.sh' new_item '$item'" \
        --button="$listen":"'$DS_pf/tls.sh' s '$fname'" \
        --button=gtk-go-up:3 --button=gtk-go-down:2 \
        --dclick-action="'$DS/addons/Learning with news/tls.sh' dclk '$fname'"
        
    else
        ff=$(($nuw + 1))
        $vwr V1 "$nll" "$ff" & exit 1
    fi

        ret=$?
        if [[ $ret -eq 2 ]]; then
            ff=$(($nuw + 1))
            "$vwr" V1 "$nll" "$ff" &
        elif [[ $ret -eq 3 ]]; then
            ff=$(($nuw - 1))
            "$vwr" V1 "$nll" "$ff" &
        else
            rm -f $DT/.*.x &
        exit 1
        fi
        
elif [[ $1 = V2 ]]; then
    
    DM_tlfk="$DM_tl/Feeds/kept"
    DS_pf="$DS/addons/Learning with news"
    trgt="$DS_pf/trgt1"
    wth=$(sed -n 5p $DC_s/cfg.18)
    eht=$(sed -n 6p $DC_s/cfg.18)
    c=$(echo $(($RANDOM%100)))
    re='^[0-9]+$'
    now="$2"
    nuw="$3"
    
    if ! [[ $nuw =~ $re ]]; then
        nuw=$(cat "$DM_tl/Feeds/.conf/cfg.0" | grep -Fxon "$now" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        nll=" "
    fi
    item="$(sed -n "$nuw"p "$DM_tl/Feeds/.conf/cfg.0")"
    
    if [ -z "$item" ]; then
        item="$(sed -n 1p "$DM_tl/Feeds/.conf/cfg.0")"
        nuw=1
    fi
    
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
    
    lnk=$(cat "$DM_tlfk/$fname.lnk")
    echo "$fname" > $DT/item.x
    
    if [ "$ap" = TRUE ]; then
        (killall play & sleep 0.3 && play "$DM_tlfk/words/$fname.mp3") &
    fi

    if [[ -f "$DM_tlfk/words/$fname.mp3" ]]; then
        tgs=$(eyeD3 "$DM_tlfk/words/$fname.mp3")
        trg=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        srce=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
        lswd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
        exm=$(echo "$lswd" | sed -n 1p)
        exmp=$(echo "$exm" | sed "s/"${trg,,}"/<span background='#FDFBCF'>"${trg,,}"<\/\span>/g" \
        | sed "s/"${trg}"/<span background='#FDFBCF'>"${trg}"<\/\span>/g")

        echo "$lwrd" | awk '{print $0""}' | yad --form \
        --window-icon=idiomind --scroll --text-align=center \
        --skip-taskbar --center --title="$MPG " --borders=20 \
        --quoted-output --selectable-labels \
        --text="<big><big>$trg</big></big>\\n\\n<i>$srce</i>\\n\\n" \
        --field="":lbl \
        --field="<i><span color='#7D7D7D'>$exmp</span></i>\\n:lbl" \
        --width="$wth" --height="$eht" --center \
        --button="$(gettext "Delete")":"'$DS_pf/mngr.sh' delete_item '$nme'" \
        --button="$listen":"play '$DM_tlfk/words/$fname.mp3'" \
        --button=gtk-go-up:3 --button=gtk-go-down:2

    elif [[ -f "$DM_tlfk/$fname.mp3" ]]; then
        if [ "$ap" = TRUE ]; then
            (killall play & sleep 0.3 && play "$DM_tlfk/$fname.mp3") &
        fi
        tgs=$(eyeD3 "$DM_tlfk/$fname.mp3")
        trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
        srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
        lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
        
        echo "$lwrd" | awk '{print $0""}' | yad --list \
        --window-icon=idiomind --scroll \
        --skip-taskbar --center --title=" " --borders=15 \
        --quoted-output --selectable-labels --no-headers \
        --text="<big><big>$trg</big></big> <a href='$lnk'>$(gettext "More")</a>\\n\\n<i>$srce</i>\\n\\n\\n" \
        --width="$wth" --height="$eht" --center \
        --column=$lgtl:TEXT --column=$lgsl:TEXT \
        --expand-column=0 --limit=20 --selectable-labels \
        --button="$(gettext "Delete")":"'$DS_pf/mngr.sh' delete_item '$item'" \
        --button="$listen":"'$DS_pf/tls.sh' s '$fname'" \
        --button=gtk-go-up:3 --button=gtk-go-down:2 \
        --dclick-action="'$DS/addons/Learning with news/tls.sh' dclk '.audio'"
        
    else
        ff=$(($nuw + 1))
        "$vwr" V2 "$nll" "$ff" & exit 1
    fi
    
        ret=$?
        if [[ $ret -eq 2 ]]; then
            ff=$(($nuw + 1))
            "$vwr" V2 "$nll" "$ff" &
        elif [[ $ret -eq 3 ]]; then
            ff=$(($nuw - 1))
            "$vwr" V2 "$nll" "$ff" &
        else
            rm -f $DT/.*.x & exit 1
        fi
fi
