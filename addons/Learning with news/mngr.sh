#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf
source $DS/ifs/mods/cmns.sh

itdl="$2"
kpt="$DM_tl/Feeds/kept"
drtc="$DM_tl/Feeds/.conf/"

if [[ "$1" = delete_item ]]; then

    touch $DT/ps_lk
    if [ -f "$kpt/words/$itdl.mp3" ]; then
    
        msg_2 " $delete_word\n\n" dialog-question "$yes" "$no" "$confirm"
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
    
        msg_2 " $delete_sentence\n\n" dialog-question "$yes" "$no" "$confirm"
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
    
        msg_2 " $delete_item\n\n" dialog-question "$yes" "$no" "$confirm"
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
    
    msg_2 " $delete_all" dialog-question "$yes" "$no" "$confirm"
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

        msg_2 " $delete_saved2\n\n" dialog-question "$yes" "$no" "$confirm"
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
