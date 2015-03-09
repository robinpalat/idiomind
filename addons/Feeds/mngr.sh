#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh


DMC="$DM_tl/Feeds/cache"
DCF="$DM_tl/Feeds/.conf/"


if [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    trgt="$2"
    fname="$(nmfile "${trgt}")"
    
    msg_2 " $(gettext "Are you sure you want to delete this episode?")\n\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")

        if [ $ret -eq 0 ]; then
            
            (sleep 0.2 && kill -9 $(pgrep -f "yad --text-info "))
            
           if ! grep -Fxo "$trgt" < "$DCF/1.cfg"; then
                rm "$DMC/$fname.mp3"
                rm "$DMC/$fname.txt"
                rm "$DMC/$fname.png"
                rm "$DMC/$fname.i"
            fi
            cd "$DCF"
            grep -v -x -F "$trgt" ./.22.cfg > ./.22.cfg.tmp
            sed '/^$/d' ./.22.cfg.tmp > ./.22.cfg
            grep -v -x -F "$trgt" ./2.cfg > ./2.cfg.tmp
            sed '/^$/d' ./2.cfg.tmp > ./2.cfg

            rm ./*.tmp
        fi
            
    rm -f $DT/ps_lk; exit 1

    
elif [ "$1" = delete_episodes ]; then
    
    msg_2 "$(gettext " Are you sure you want to delete all episodes?\n\ (Downloads every 5 days\n will be automatically deleted\).")" dialog-question \
    "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")

        if [ $ret -eq 0 ]; then
        
            rm $DM_tl/Feeds/cache/*
            rm $DM_tl/Feeds/.conf/.updt.lst
            rm $DM_tl/Feeds/.conf/1.cfg
            rm $DM_tl/Feeds/.conf/.dt
        else
            exit
        fi
        
elif [ "$1" = delete_episodes_saved ]; then

        msg_2 "$(gettext " Are you sure you want\n to delete the saved episodes?\n")" dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

    if [ $ret -eq 0 ]; then
    
        rm -r "$DCF"/2.cfg "$DCF"/.22.cfg
        touch "$DCF"/2.cfg "$DCF"/.22.cfg
    fi
    exit
fi
