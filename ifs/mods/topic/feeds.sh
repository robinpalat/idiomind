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
    --field="Notes\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":txt "$nt" \
    --field=" :LBL" "2" \
    --field="$(gettext "Subscriptions")":FBTN "$DS/addons/Feeds/cnfg.sh" \
    --field=" $itxt2":lbl " " \
    --field="$(gettext "Syncronize")":FBTN "$DS/addons/Feeds/tls.sh 'sync'" \
    --field="$(gettext "Delete")":FBTN "$DS/addons/Feeds/mngr.sh 'delete'" > "$DT/f.edit" &
    yad --notebook --name=Idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="Feeds - ${info^}" \
    --tab=" $(gettext "Episodes") " \
    --tab=" $(gettext "Saved Episodes") " \
    --tab=" $(gettext "Edit") " --always-print-result \
    --ellipsize=END --image-on-top --window-icon=idiomind \
    --width="$wth" --height="$eht" --borders=5 \
    --button="$(gettext "Play")":"/usr/share/idiomind/play.sh" \
    --button="gtk-refresh":2 \
    --button="gtk-close":1
    ret=$?
        
    if [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    nnt=$(cut -d '|' -f 1 < "$DT/f.edit")
    if [ "$nt" != "$nnt" ]; then
        if [ -z "$nnt" ]; then msg_2 "$(gettext " Really delete note?")\n" "$DS/images/note.png" "Delete" "No"
        [ $? = 0 ] && echo "$nnt" > "$DCP/10.cfg"; else
        echo "$nnt" > "$DCP/10.cfg"; fi
    fi
}


if echo "$mde" | grep "fd"; then
    feedmode; exit 1
fi
