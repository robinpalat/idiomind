#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

itdl="$2"
kpt="$DM_tl/Feeds/kept"
drtc="$DM_tl/Feeds/.conf/"

if [[ "$1" = delete_item ]]; then

    touch $DT/ps_lk
    if [ -f "$kpt/words/$itdl.mp3" ]; then
    
        msg_2 " $(gettext "Are you sure you want to delete this word?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

            if [[ $ret -eq 0 ]]; then
                
                (sleep 0.2 && kill -9 $(pgrep -f "$yad --form "))
                rm "$kpt/words/$itdl.mp3"
                cd "$drtc"
                grep -v -x -F "$itdl" ./cfg.3 > ./cfg.3.tmp
                sed '/^$/d' ./cfg.3.tmp > ./cfg.3
                grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
                sed '/^$/d' ./cfg.0.tmp > ./cfg.0
                rm ./*.tmp
                rm -f $DT/ps_lk

            elif [[ $ret -eq 1 ]]; then
            
                rm -f $DT/ps_lk
                exit 1
            fi
    
    elif [ -f "$kpt/$itdl.mp3" ]; then
    
        msg_2 "$(gettext "Are you sure you want to delete this Sentence?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")
        
            if [[ $ret -eq 0 ]]; then
            
                (sleep 0.2 && kill -9 $(pgrep -f "$yad --form "))
                rm "$kpt/$itdl.mp3"
                rm "$kpt/$itdl.lnk"
                cd "$drtc"
                grep -v -x -F "$itdl" ./cfg.4 > ./cfg.4.tmp
                sed '/^$/d' ./cfg.4.tmp > ./cfg.4
                grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
                sed '/^$/d' ./cfg.0.tmp > ./cfg.0
                rm ./*.tmp
                rm -f $DT/ps_lk

            elif [[ $ret -eq 1 ]]; then
            
                rm -f $DT/ps_lk
                exit 1
            fi
    else
    
        msg_2 "$(gettext "Are you sure you want to delete this Item?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")
        
            if [[ $ret -eq 0 ]]; then
            
                (sleep 0.2 && kill -9 $(pgrep -f "$yad --form "))
                rm "$kpt/$itdl.mp3"
                rm "$kpt/$itdl.lnk"
                cd "$drtc"
                grep -v -x -F "$itdl" ./cfg.3 > ./cfg.3.tmp
                sed '/^$/d' ./cfg.3.tmp > ./cfg.3
                grep -v -x -F "$itdl" ./cfg.4 > ./cfg.4.tmp
                sed '/^$/d' ./cfg.4.tmp > ./cfg.4
                grep -v -x -F "$itdl" ./cfg.0 > ./cfg.0.tmp
                sed '/^$/d' ./cfg.0.tmp > ./cfg.0
                rm ./*.tmp
                rm -f $DT/ps_lk
            
            elif [[ $ret -eq 1 ]]; then
            
                rm -f $DT/ps_lk
                exit 1
            fi
    fi

elif [[ "$1" = delete_news ]]; then
    
    msg_2 "$(gettext " Are you sure you want to delete all entries?\n\ (Downloads subscriptions every 5 days\n will be automatically deleted\).")" dialog-question \
    "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")

        if [[ $ret -eq 0 ]]; then
        
            rm -r $DM_tl/Feeds/conten/*
            rm $DM_tl/Feeds/.conf/.updt.lst
            rm $DM_tl/Feeds/.conf/cfg.1
            rm $DM_tl/Feeds/.conf/.dt
        else
            exit 1
        fi
        
elif [[ "$1" = delete_saved ]]; then

        msg_2 "$(gettext " Are you sure you want\n to delete the saved entries?\n")" dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        ret=$(echo "$?")

    if [[ $ret -eq 0 ]]; then
    
        rm -r "$drtc"/cfg.3 "$drtc"/cfg.4 "$drtc"/cfg.0
        touch "$drtc"/cfg.3 "$drtc"/cfg.4 "$drtc"/cfg.0
        rm -r "$kpt"/*.mp3
        rm -r "$kpt"/words/*.mp3
    else
        exit 1
    fi

fi
