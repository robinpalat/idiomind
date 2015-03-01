#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

trgt="$2"
kpt="$DM_tl/Podcasts/kept"
drtc="$DM_tl/Podcasts/.conf/"
fname="$(nmfile "${trgt^}")"

if [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    if [ -f "$kpt/$fname.mp3" ]; then
    
        msg_2 " $(gettext "Are you sure you want to delete this episode?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

            if [ $ret -eq 0 ]; then
                
                (sleep 0.2 && kill -9 $(pgrep -f "yad --text-info "))
                rm "$kpt/$fname.mp3"
                rm "$kpt/$fname.txt"
                cd "$drtc"
                grep -v -x -F "$trgt" ./cfg.2 > ./cfg.2.tmp
                sed '/^$/d' ./cfg.2.tmp > ./cfg.2
                rm ./*.tmp
                rm -f $DT/ps_lk

            elif [ $ret -eq 1 ]; then
            
                rm -f $DT/ps_lk
                exit 1
            fi
    else
        rm -f $DT/ps_lk
        exit 1
    fi
    
elif [ "$1" = delete_episodes ]; then
    
    msg_2 "$(gettext " Are you sure you want to delete all episodes?\n\ (Downloads every 5 days\n will be automatically deleted\).")" dialog-question \
    "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")

        if [ $ret -eq 0 ]; then
        
            rm $DM_tl/Podcasts/content/*
            rm $DM_tl/Podcasts/.conf/.updt.lst
            rm $DM_tl/Podcasts/.conf/cfg.1
            rm $DM_tl/Podcasts/.conf/.dt
        else
            exit
        fi
        
elif [ "$1" = delete_episodes_saved ]; then

        msg_2 "$(gettext " Are you sure you want\n to delete the saved episodes?\n")" dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

    if [ $ret -eq 0 ]; then
    
        rm -r "$drtc"/cfg.2 
        touch "$drtc"/cfg.1
        rm -r "$kpt"/*.mp3
        rm -r "$kpt"/*.txt
    else
        exit
    fi
fi
