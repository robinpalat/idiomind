#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

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
    nt="$DCP/10.cfg"
    fdit=$(mktemp "$DT/fdit.XXXX")
    c=$(echo $(($RANDOM%100000))); KEY=$c
    info=$(< "$DM_tl/Feeds/.dt")
    [ -f "$DT/.uptp" ] && info="- $(gettext "Updating")..."
    
    list_1 | yad --list --tabnum=1 \
    --plug=$KEY --print-all --dclick-action="$DSP/vwr.sh" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name &
    list_2 | yad --list --tabnum=2 \
    --plug=$KEY --print-all --dclick-action="$DSP/vwr.sh" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name &
    yad --text-info --tabnum=3 \
    --plug=$KEY --filename="$nt" \
    --fore='gray40' --wrap --editable \
    --show-uri --margins=14 --fontname=vendana > "$fdit" &
    yad --notebook --title="Feeds  ${info^}" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --window-icon="idiomind" --image-on-top \
    --ellipsize=END --align=right --center --fixed \
    --width=640 --height=560 --borders=2 --tab-borders=5 \
    --tab=" $(gettext "New episodes") " \
    --tab=" $(gettext "Saved episodes") " \
    --tab=" $(gettext "Notes") " \
    --button="$(gettext "Playlist")":"/usr/share/idiomind/play.sh" \
    --button="gtk-refresh":2 --button="$(gettext "Close")":1
    ret=$?
        
    if [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    note_mod="$(< $fdit)"
    if [ "$note_mod" != "$(< $nt)" ]; then
    mv -f "$fdit" "$nt"; else rm -f "$fdit"; fi
}


if echo "$mde" | grep "fd"; then
    feedmode; exit 1
fi
