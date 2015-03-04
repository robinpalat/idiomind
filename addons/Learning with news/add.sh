#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ "$1" = new_item ]; then

    trgt=$(cat $DT/word.x)
    dir=$(cat $DT/item.x)
    c=$(echo $(($RANDOM%100)))
    DMK="$DM_tl/Feeds/kept"
    DMC="$DM_tl/Feeds/content"
    DCF="$DCF"
    var="$2"

    if [ ! -d "$DMK" ]; then
        mkdir -p "$DMK/words"
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
        
            if [ $(cat "$DCF/cfg.3" | wc -l) -ge 50 ]; then
                msg "$tpe  \n$(gettext "You have reached the maximum number of words") " info & exit
            fi
        
            internet
            mkdir $DT/rss_$c; cd $DT/rss_$c
            srce="$(translate "$trgt" auto $lgs)"
            fname="$(nmfile "${trgt}")"
            [ ! -d "$DMK/words" ] && mkdir "$DMK/words"
            cp "$DMC/$dir/${trgt,,}.mp3" "$DMK/words/$fname.mp3"
            add_tags_2 W "${trgt^}" "${srce^}" "$var" "$DMK/words/$fname.mp3"
            echo "${trgt^}" >> "$DCF/cfg.0"
            echo "${trgt^}" >> "$DCF/.cfg.11"
            echo "${trgt^}" >> "$DCF/cfg.3"
            check_index1 "$DCF/cfg.0"
            rm -rf $DT/rss_$c
            
        # -------------------------------------------------------------
        elif [ $ret -eq 2 ]; then
        
            if [ $(cat "$DCF/cfg.4" | wc -l) -ge 50 ]; then
                msg "$tpe  \n$(gettext "You have reached the maximum number of sentences")" info & exit
            fi
            
            internet
            fname="$(nmfile "${var}")"
            tgs=$(eyeD3 "$DMC/$fname.mp3")
            trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
            cp "$DMC/$fname.mp3" "$DMK/$fname.mp3"
            cp "$DMC/$fname"/* "$DMK/.audio"/
            echo "$trgt" >> "$DCF/cfg.0"
            echo "$trgt" >> "$DCF/.cfg.11"
            echo "$trgt" >> "$DCF/cfg.4"
            check_index1 "$DCF/cfg.0"
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
            
            [[ -f "$DCF/cfg.0" ]] && \
            mv -f "$DCF/cfg.0" "$DM_tl/$jlb/.conf/cfg.0" \
            || touch "$DM_tl/$jlb/.conf/cfg.0"
            [[ -f "$DCF/cfg.3" ]] && \
            mv -f "$DCF/cfg.3" "$DM_tl/$jlb/.conf/cfg.3" \
            || touch "$DM_tl/$jlb/.conf/cfg.3"
            [[ -f "$DCF/cfg.4" ]] && \
            mv -f "$DCF/cfg.4" "$DM_tl/$jlb/.conf/cfg.4" \
            || touch "$DM_tl/$jlb/.conf/cfg.4"
            [[ -f "$DCF/.cfg.11" ]] && \
            mv -f "$DCF/.cfg.11" "$DM_tl/$jlb/.conf/.cfg.11" \
            || touch "$DM_tl/$jlb/.conf/.cfg.11"
            
            cd "$DMK"/
            cp -f *.mp3 "$DM_tl/$jlb"/ && rm *.mp3
            cp -f *.lnk "$DM_tl/$jlb"/ && rm *.lnk
            
            cd "$DMK/.audio"/
            ls *.mp3 > "$DM_tl/$jlb/.conf/cfg.5"
            mv *.mp3 "$DM_tl/.share/"
            
            mkdir -p "$DM_tl/$jlb/words/images"
            cd "$DM_tl/Feeds/kept/words"/
            cp -f *.mp3 "$DM_tl/$jlb/words"/ && rm *.mp3
            
            touch "$DCF/cfg.0"
            touch "$DCF/cfg.3"
            touch "$DCF/cfg.4"
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
