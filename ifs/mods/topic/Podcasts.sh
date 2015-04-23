#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
tpa="$(sed -n 1p "$DC_a/4.cfg")"
if [ "$tpa" != 'Podcasts' ]; then
[ ! -f "$DM_tl/Podcasts/.conf/8.cfg" ] \
&& echo "11" > "$DM_tl/Podcasts/.conf/8.cfg"
echo "Podcasts" > "$DC_a/4.cfg"
echo "$tpc" > "$DC_s/4.cfg"
echo '2' >> "$DC_s/4.cfg"
fi

echo "$tpc" > "$DC_s/4.cfg"
echo '2' >> "$DC_s/4.cfg"

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

    DMP="$DM_tl/Podcasts"
    DCP="$DM_tl/Podcasts/.conf"
    DSP="$DS/addons/Podcasts"
    nt="$DCP/10.cfg"
    fdit=$(mktemp "$DT/fdit.XXXX")
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && info="- $(gettext "Updating")..."
    infolabel="$(< "$DM_tl/Podcasts/.update")"
    
    list_1 | yad --list --tabnum=1 \
    --plug=$KEY --print-all --dclick-action="$DSP/vwr.sh" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name:TXT &
    list_2 | yad --list --tabnum=2 \
    --plug=$KEY --print-all --dclick-action="$DSP/vwr.sh" \
    --no-headers --expand-column=2 --ellipsize=END \
    --column=Name:IMG \
    --column=Name:TXT &
    yad --text-info --tabnum=3 \
    --text="<small>$infolabel</small>" \
    --plug=$KEY --filename="$nt" \
    --wrap --editable --fore='gray40' \
    --show-uri --margins=14 --fontname=vendana > "$fdit" &
    yad --notebook --title="Podcasts  ${info^}" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --window-icon="$DS/images/icon.png" --image-on-top \
    --ellipsize=END --align=right --center --fixed \
    --width=640 --height=560 --borders=2 --tab-borders=5 \
    --tab=" $(gettext "Episodes") " \
    --tab=" $(gettext "Saved episodes") " \
    --tab=" $(gettext "Notes") " \
    --button="$(gettext "Lists")":"/usr/share/idiomind/play.sh" \
    --button="$(gettext "Update")":2 \
    --button="$(gettext "Close")":1
    ret=$?
        
    if [[ $ret -eq 2 ]]; then
    "$DSP/strt.sh"; fi
    
    note_mod="$(< $fdit)"
    if [ "$note_mod" != "$(< $nt)" ]; then
    mv -f "$fdit" "$nt"; fi
    
    [ "$fdit" ] && rm -f "$fdit"
}

feedmode & exit
