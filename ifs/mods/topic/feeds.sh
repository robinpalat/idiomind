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
    info="$(cat $DCP/9.cfg)"
    fdit=$(mktemp "$DT/fdit.XXXX")
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && \
    info=$(echo "$(gettext "Updating")...") || \
    info=$(cat "$DM_tl/Feeds/.dt")

    list_1 | yad --no-headers --list --plug=$KEY \
    --tabnum=1 --print-all --expand-column=2 --ellipsize=END \
    --column=Name:IMG --column=Name --dclick-action="$DSP/vwr.sh" &
    list_2 | yad --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=2 --ellipsize=END --print-all --column=Name:IMG \
    --column=Name --dclick-action="$DSP/vwr.sh" &
    yad --text-info --plug=$KEY --margins=14 \
    --tabnum=3 --fore='gray40' --wrap --editable \
    --show-uri --fontname=vendana --print-column=1 \
    --column="" --filename="$nt" > "$fdit" &
    yad --notebook --name=Idiomind --center --fixed \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=5 --center --title="Feeds  ${info^}" \
    --tab=" $(gettext "New episodes") " \
    --tab=" $(gettext "Saved episodes") " \
    --tab=" $(gettext "Notes") " --always-print-result \
    --ellipsize=END --image-on-top --window-icon="$DS/images/logo.png" \
    --width=640 --height=560 --borders=2 \
    --button="$(gettext "Playlist")":"/usr/share/idiomind/play.sh" \
    --button="gtk-refresh":2 --button="gtk-close":1
    ret=$?
        
    if [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    note_mod="$(< $fdit)"
    if [ "$note_mod" != "$(< $nt)" ]; then
        mv -f "$fdit" "$nt"
    fi
}


if echo "$mde" | grep "fd"; then
    feedmode; exit 1
fi
