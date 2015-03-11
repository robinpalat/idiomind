#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

function list_1() {
    while read list1; do
        echo "$DMP/cache/$(nmfile "$list1").png"
        echo "$list1"
    done < "$DCP/1.cfg"
}

function list_2() {
    while read list2; do
        echo "$DMP/cache/$(nmfile "$list2").png"
        echo "$list2"
    done < "$DCP/2.cfg"
}

function feedmode() {

    DMP="$DM_tl/Feeds"
    DCP="$DM_tl/Feeds/.conf"
    DSP="$DS/addons/Feeds"
    nt="$(cat $DCP/10.cfg)"
    info="$(cat $DCP/9.cfg)"
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && \
    info=$(echo "<i>"$(gettext "Updating")"...</i>") || \
    info=$(cat "$DM_tl/Feeds/.dt")

    list_1 | yad --no-headers --list --plug=$KEY \
    --tabnum=1 --print-all --expand-column=2 --ellipsize=END \
    --text="  <small>${info^}</small>" \
    --column=Name:IMG --column=Name --dclick-action="$DSP/vwr.sh" &
    list_2 | yad --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=2 --ellipsize=END --print-all --column=Name:IMG \
    --column=Name --dclick-action="$DSP/vwr.sh" &
    yad --form --borders=10 --plug=$KEY --tabnum=3 --columns=1 --separator="" \
    --field="Notes":txt "$nt" \
    --field="Syncronize":btn "/usr/share/idiomind/addons/Feeds/tls.sh 'syncronize'" \
    --field="Delete":btn "/usr/share/idiomind/ifs/tls.sh 'syncronize'" > "$DT/f.edit" &
    yad --notebook --name=idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="$FEED" \
    --tab=" $(gettext "Episodes") " \
    --tab=" $(gettext "Saved Episodes") " \
    --tab=" $(gettext "Edit") " --always-print-result \
    --ellipsize=END --image-on-top \
    --window-icon=$DS/images/idiomind.png \
    --width="$wth" --height="$eht" --borders=0 \
    --button="Playlist":/usr/share/idiomind/play.sh \
    --button="gtk-refresh":2
    ret=$?
        
    if [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    if ([ "$(cat "$DT/f.edit")" != "$(cat "$DCP/10.cfg")" ] \
    && [ -n "$(cat "$DT/f.edit")" ]); then
    mv -f "$DT/f.edit" "$DCP/10.cfg";
    fi
}


if echo "$mde" | grep "fd"; then
    feedmode; exit 1
fi
