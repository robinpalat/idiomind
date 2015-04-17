#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
DMC="$DM_tl/Podcasts/cache"
DCP="$DM_tl/Podcasts/.conf/"

if [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    fname="$(nmfile "${item}")"
    
    if ! grep -Fxo "$item" < "$DCP/1.cfg"; then
    
        msg_2 "$lbl" gtk-delete "$(gettext "Delete")" "$(gettext "No")" "$(gettext "Confirm")"
        ret=$(echo "$?")
    
        if [ $ret -eq 0 ]; then
            
            (sleep 0.2 && kill -9 $(pgrep -f "yad --html "))

            [ "$DMC/$fname.mp3" ] && rm "$DMC/$fname.mp3"
            [ "$DMC/$fname.ogg" ] && rm "$DMC/$fname.ogg"
            [ "$DMC/$fname.mp4" ] && rm "$DMC/$fname.mp4"
            [ "$DMC/$fname.m4v" ] && rm "$DMC/$fname.m4v"
            [ "$DMC/$fname.flv" ] && rm "$DMC/$fname.flv"
            [ "$DMC/$fname.jpg" ] && rm "$DMC/$fname.jpg"
            [ "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
            [ "$DMC/$fname.html" ] && rm "$DMC/$fname.html"
            [ "$DMC/$fname" ] && rm "$DMC/$fname"
            cd "$DCP"
            grep -vxF "$item" ./.22.cfg > ./.22.cfg.tmp
            sed '/^$/d' ./.22.cfg.tmp > ./.22.cfg
            grep -vxF "$item" ./2.cfg > ./2.cfg.tmp
            sed '/^$/d' ./2.cfg.tmp > ./2.cfg
            rm ./*.tmp; fi

    else
        notify-send -i info "$(gettext "Removed from list of saved")" "$item" 
    
        cd "$DCP"
        grep -vxF "$item" ./.22.cfg > ./.22.cfg.tmp
        sed '/^$/d' ./.22.cfg.tmp > ./.22.cfg
        grep -vxF "$item" ./2.cfg > ./2.cfg.tmp
        sed '/^$/d' ./2.cfg.tmp > ./2.cfg
        rm ./*.tmp
    fi
            
    rm -f $DT/ps_lk; exit 1

elif [ "$1" = delete_1 ]; then

    if [ "$(wc -l < "$DCP/1.cfg")" -gt 0 ]; then
    msg_2 "$(gettext "Are you sure you want to delete all episodes?")\n" gtk-delete "$(gettext "Delete")" "$(gettext "No")" "$(gettext "Confirm")"
    else exit 1; fi
    ret=$(echo "$?")
            
    if [ $ret -eq 0 ]; then

        rm "$DM_tl/Podcasts/cache"/*
        rm "$DM_tl/Podcasts/.conf/.updt.lst"
        rm "$DM_tl/Podcasts/.conf/1.cfg"
        rm "$DM_tl/Podcasts/.conf/.dt"
        touch "$DM_tl/Podcasts/.conf/1.cfg"
    fi
    exit

elif [ "$1" = delete_2 ]; then

    if [ "$(wc -l < "$DCP/2.cfg")" -gt 0 ]; then
    msg_2 "$(gettext "Are you sure you want to delete all saved episodes?")\n" gtk-delete "$(gettext "Delete")" "$(gettext "No")" "$(gettext "Confirm")"
    else exit 1; fi
    ret=$(echo "$?")
    
   if [ $ret -eq 0 ]; then

        rm "$DCP/2.cfg" "$DCP/.22.cfg"
        touch "$DCP/2.cfg" "$DCP/.22.cfg"
    fi
    exit
fi
