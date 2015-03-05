#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh


DMC="$DM_tl/Podcasts/content"
DCP="$DM_tl/Podcasts/.conf/"


if [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    trgt="$2"
    fname="$(nmfile "${trgt}")"
    
    msg_2 " $(gettext "Are you sure you want to delete this episode?")\n\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")

        if [ $ret -eq 0 ]; then
            
            (sleep 0.2 && kill -9 $(pgrep -f "yad --text-info "))
            
           if ! grep -Fxo "$trgt" < "$DCP/cfg.1"; then
                rm "$DMC/$fname.mp3"
                rm "$DMC/$fname.txt"
                rm "$DMC/$fname.png"
                rm "$DMC/$fname.i"
            fi
            cd "$DCP"
            grep -v -x -F "$trgt" ./.cfg.22 > ./.cfg.22.tmp
            sed '/^$/d' ./.cfg.22.tmp > ./.cfg.22
            grep -v -x -F "$trgt" ./cfg.2 > ./cfg.2.tmp
            sed '/^$/d' ./cfg.2.tmp > ./cfg.2

            rm ./*.tmp
        fi
            
    rm -f $DT/ps_lk; exit 1

    
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
    
        rm -r "$DCP"/cfg.2 "$DCP"/.cfg.22
        touch "$DCP"/cfg.2 "$DCP"/.cfg.22
    fi
    exit
fi
