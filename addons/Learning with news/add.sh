#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ "$1" = new_item ]; then

    trgt=$(cat $DT/word.x)
    dir=$(cat $DT/item.x)
    c=$(echo $(($RANDOM%100)))
    dir_kept="$DM_tl/Feeds/kept"
    dir_conten="$DM_tl/Feeds/conten"
    dir_conf="$DM_tl/Feeds/.conf"
    var="$2"

    if [ ! -d "$DM_tl/Feeds"/kept ]; then
        mkdir -p "$DM_tl/Feeds/kept/words"
    fi

    if [ -f $DT/word.x ]; then
        bttn="--button="$(gettext "Save Word")":0"
        txt="<b>"$(gettext "Word")"</b>"
    fi

    yad --width=480 --height=210 --window-icon=idiomind \
    --title="$(gettext "Save")" --center --on-top --borders=10 \
    --image=dialog-question --skip-taskbar \
    --text="  <b>"$(gettext "Sentence")"</b>\n  $var\n\n  $txt\n  $trgt\n" \
    --button="$(gettext "Save Sentence")":2 "$bttn"
    ret=$?
        
        # -------------------------------------------------------------
        if [ $ret -eq 0 ]; then
        
            if [ $(cat "$dir_conf/cfg.3" | wc -l) -ge 50 ]; then
                msg "$tpe  \n$(gettext "You have reached the maximum number of words") " info & exit
            fi
        
            internet
            mkdir $DT/rss_$c; cd $DT/rss_$c
            srce="$(translate "$trgt" auto $lgs)"
            fname="$(nmfile "${trgt^}")"
            [ ! -d "$dir_kept/words" ] && mkdir "$dir_kept/words"
            cp "$dir_conten/$dir/${trgt,,}.mp3" "$dir_kept/words/$fname.mp3"
            add_tags_2 W "${trgt^}" "${srce^}" "$var" "$dir_kept/words/$fname.mp3"
            echo "${trgt^}" >> "$dir_conf/cfg.0"
            echo "${trgt^}" >> "$dir_conf/.cfg.11"
            echo "${trgt^}" >> "$dir_conf/cfg.3"
            check_index1 "$dir_conf/cfg.0"
            rm -rf $DT/rss_$c
            
        # -------------------------------------------------------------
        elif [ $ret -eq 2 ]; then
        
            if [ $(cat "$DM_tl/Feeds/.conf/cfg.4" | wc -l) -ge 50 ]; then
                msg "$tpe  \n$(gettext "You have reached the maximum number of sentences")" info & exit
            fi
            
            internet
            fname="$(nmfile "${var^}")"
            tgs=$(eyeD3 "$dir_conten/$fname.mp3")
            trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
            cp "$dir_conten/$fname.mp3" "$dir_kept/$fname.mp3"
            cp "$dir_conten/$fname"/* "$dir_kept/.audio"/
            echo "$trgt" >> "$dir_conf/cfg.0"
            echo "$trgt" >> "$dir_conf/.cfg.11"
            echo "$trgt" >> "$dir_conf/cfg.4"
            check_index1 "$dir_conf/cfg.0"
            rm -f -r $DT/word.x $DT/rss_$c & exit
            
        else
            rm -fr $DT/word.x $DT/rss_$c & exit
        fi
        
# -------------------------------------------------------------
elif [ "$1" = new_topic ]; then
    
    dte=$(date "+%a %d %B")
    if [ $(cat "$DC_tl/.cfg.1" | wc -l) -ge 80 ]; then
        msg "$(gettext "You have reached the maximum number of topics")" info & exit
    fi

    jlbi=$(yad --form --window-icon=idiomind --borders=10 \
    --fixed --width=400 --height=120 --on-top --center --skip-taskbar \
    --field=" : " "News - $dte" --button="$(gettext "Create")":0 \
    --title="$(gettext "New Topic")" )
        
        if [ -z "$jlbi" ];then
            exit 1
        else
            
            jlb=$(echo "$jlbi" | cut -d "|" -f1 | sed s'/!//'g)
            mkdir "$DM_tl/$jlb"
            mkdir "$DM_tl/$jlb./conf"
            
            [[ -f "$DM_tl/Feeds/.conf/cfg.0" ]] && \
            mv -f "$DM_tl/Feeds/.conf/cfg.0" "$DM_tl/$jlb/.conf/cfg.0" \
            || touch "$DM_tl/$jlb/.conf/cfg.0"
            [[ -f "$DM_tl/Feeds/.conf/cfg.3" ]] && \
            mv -f "$DM_tl/Feeds/.conf/cfg.3" "$DM_tl/$jlb/.conf/cfg.3" \
            || touch "$DM_tl/$jlb/.conf/cfg.3"
            [[ -f "$DM_tl/Feeds/.conf/cfg.4" ]] && \
            mv -f "$DM_tl/Feeds/.conf/cfg.4" "$DM_tl/$jlb/.conf/cfg.4" \
            || touch "$DM_tl/$jlb/.conf/cfg.4"
            [[ -f "$DM_tl/Feeds/.conf/.cfg.11" ]] && \
            mv -f "$DM_tl/Feeds/.conf/.cfg.11" "$DM_tl/$jlb/.conf/.cfg.11" \
            || touch "$DM_tl/$jlb/.conf/.cfg.11"
            
            cd "$DM_tl/Feeds/kept"/
            cp -f *.mp3 "$DM_tl/$jlb"/ && rm *.mp3
            cp -f *.lnk "$DM_tl/$jlb"/ && rm *.lnk
            
            cd "$DM_tl/Feeds/kept/.audio"/
            ls *.mp3 > "$DM_tl/$jlb/.conf/cfg.5"
            mv *.mp3 "$DM_tl/.share/"
            
            mkdir -p "$DM_tl/$jlb/words/images"
            cd "$DM_tl/Feeds/kept/words"/
            cp -f *.mp3 "$DM_tl/$jlb/words"/ && rm *.mp3
            
            touch "$DM_tl/Feeds/.conf/cfg.0"
            touch "$DM_tl/Feeds/.conf/cfg.3"
            touch "$DM_tl/Feeds/.conf/cfg.4"
            touch "$DM_tl/$jlb/.conf/cfg.2"
            
            cnt=$(cat "$DM_tl/$jlb/.conf/cfg.0" | wc -l)
            echo "aitm.$cnt.aitm" >> $DC_s/cfg.30 &
            
            [ -f $DT/ntpc ] && rm -f $DT/ntpc
            cp -f "$DM_tl/$jlb/.conf/cfg.0" "$DM_tl/$jlb/.conf/cfg.1"
            cp -f $DS/default/tpc.sh "$DM_tl/$jlb/tpc.sh"
            chmod +x "$DM_tl/$jlb/tpc.sh"
            echo "$(date +%F)" > "$DM_tl/$jlb/.conf/cfg.12"
            echo "1" > "$DM_tl/$jlb/.conf/cfg.8"
            echo "$jlb" >> $DM_tl/.cfg.2
            "$DM_tl/$jlb/tpc.sh"
            $DS/mngr.sh mkmn
        fi
fi
