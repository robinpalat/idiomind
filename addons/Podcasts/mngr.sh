#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

trgt="$2"
dir_kept="$DM_tl/Podcasts/kept"
dir_conf="$DM_tl/Podcasts/.conf/"
fname="$(nmfile "${trgt^}")"

if [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    if [ -f "$dir_kept/$fname.mp3" ]; then
    
        msg_2 " $(gettext "Are you sure you want to delete this episode?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

            if [ $ret -eq 0 ]; then
                
                (sleep 0.2 && kill -9 $(pgrep -f "yad --text-info "))
                rm "$dir_kept/$fname.mp3"
                rm "$dir_kept/$fname.txt"
                rm "$dir_kept/$fname.png"
                rm "$dir_kept/$fname"
                cd "$dir_conf"
                grep -v -x -F "$trgt" ./.cfg.22 > ./.cfg.22.tmp
                sed '/^$/d' ./.cfg.22.tmp > ./.cfg.22
                rm $dir_conf/cfg.2

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
    
        rm -r "$dir_conf"/cfg.2 
        touch "$dir_conf"/cfg.1
        rm "$dir_kept"/*

    else
        exit
    fi
fi
