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
    nt="$(cat $DCP/10.cfg)"
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
    yad --form --scroll --borders=10 --plug=$KEY --tabnum=3 --columns=2 \
    --field="$(gettext "Notes")$spc":txt "$nt" \
    --field=" :LBL" " " --field=" :LBL" " " --field=" $itxt2":lbl " " \
    --field="$(gettext "Syncronize")":FBTN "$DS/addons/Feeds/tls.sh 'sync'" \
    --field="$(gettext "Delete")":FBTN "$DS/addons/Feeds/mngr.sh 'delete'" > "$fdit" &
    yad --notebook --name=Idiomind --center --fixed \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="Feeds  ${info^}" \
    --tab=" $(gettext "New episodes") " \
    --tab=" $(gettext "Saved episodes") " \
    --tab=" $(gettext "Edit") " --always-print-result \
    --ellipsize=END --image-on-top --window-icon="$DS/images/logo.png" \
    --width=640 --height=560 --borders=5 \
    --button="$(gettext "Playlist")":"/usr/share/idiomind/play.sh" \
    --button="gtk-refresh":2 --button="gtk-close":1
    ret=$?
        
    if [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    nnt=$(cut -d '|' -f 1 < "$fdit")
    rm -f "$fdit"
    if [ "$nt" != "$nnt" ]; then
        if [ -z "$nnt" ]; then msg_2 " $(gettext "Really delete note?")\n" gtk-delete "Delete" "No"
        [ $? = 0 ] && echo "$nnt" | cut -c1-90000 > "$DCP/10.cfg"; else
        echo "$nnt" | cut -c1-90000 > "$DCP/10.cfg"; fi
    fi
}


if echo "$mde" | grep "fd"; then
    feedmode; exit 1
fi
