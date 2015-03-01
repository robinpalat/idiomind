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

if [ "$1" = chngi ]; then

    nta=$(sed -n 8p $DC_s/cfg.5)
    sna=$(sed -n 9p $DC_s/cfg.5)
    cfg1="$DC_s/cfg.5"
    indx="$DT/p/indx"
    [[ -z $(cat $DC_s/cfg.2) ]] && echo 8 > $DC_s/cfg.2
    bcl=$(cat $DC_s/cfg.2)
    [ $bcl -le 0 ] && bcl = 0.3 && echo 0.3 > $DC_s/cfg.2
    if ([ $(echo "$nta" | grep "TRUE") ] && [ $bcl -lt 12 ]); then bcl=12; fi

    item="$(sed -n "$2"p $indx)"
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
    
    [[ -f "$DM_tlt/$fname.mp3" ]] && file="$DM_tlt/$fname.mp3" && t=2
    [[ -f "$DM_tlt/words/$fname.mp3" ]] && file="$DM_tlt/words/$fname.mp3" && t=1
    [[ -f "$DM_tl/Feeds/kept/words/$fname.mp3" ]] && file="$DM_tl/Feeds/kept/words/$fname.mp3" && t=1
    [[ -f "$DM_tl/Feeds/kept/$fname.mp3" ]] && file="$DM_tl/Feeds/kept/$fname.mp3" && t=2
    [[ -f "$DM_tl/Feeds/content/$fname.mp3" ]] && file="$DM_tl/Feeds/content/$fname.mp3" && t=2
    [[ -f "$DM_tl/Podcasts/content/$fname.mp3" ]] && file="$DM_tl/Podcasts/content/$fname.mp3" && t=3
    [[ -f "$DM_tl/Podcasts/kept/$fname.mp3" ]] && file="$DM_tl/Podcasts/kept/$fname.mp3" && t=3
    
    if [ -f "$file" ]; then
        
        if [ "$t" = 2 ]; then
        tgs=$(eyeD3 "$file")
        trgt=$(echo "$tgs" | \
        grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
        srce=$(echo "$tgs" | \
        grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
        
        elif [ "$t" = 1 ]; then
        tgs=$(eyeD3 "$file")
        trgt=$(echo "$tgs" | \
        grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        srce=$(echo "$tgs" | \
        grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
        
        elif [ "$t" = 3 ]; then
        trgt="$item"
        srce="By: $(eyeD3 --no-color -v "$file" \
        | grep artist | sed 's/artist/||/g' \
        | sed 's/title\:[^)]*||\://g' | \
        sed -e "s/[[:space:]]\+/ /g")"
        fi

        [[ -z "$trgt" ]] && trgt="$item"
        imgt="$DM_tlt/words/images/$fname.jpg"
        [[ -f $imgt ]] && osdi=$imgt || osdi=idiomind
        
        [[ -n $(echo "$nta" | grep "TRUE") ]] && \
        (notify-send -i "$osdi" "$trgt" "$srce" -t 10000 && sleep 0.5) &
        
        if [[ -n $(echo "$sna" | grep "TRUE") ]]; then

                $DS/ifs/tls.sh play "$file"
        fi
        
        sleep $bcl
        [ -f $DT/.bcle ] && rm -f $DT/.bcle
        
    else
        echo "$item" >> $DT/.bcle
        echo "-- no file found"
        if [ $(cat $DT/.bcle | wc -l) -gt 5 ]; then
            rm -f $DT/.p_ &
            $DS/stop.sh play & exit 1
        fi
    fi

elif [ "$1" != chngi ]; then
    
    if [ ! -f $DC_s/cfg.0 ]; then
        > $DC_s/cfg.0
        fi
        wth=$(sed -n 3p $DC_s/cfg.18)
        eht=$(sed -n 4p $DC_s/cfg.18)
        if [ -n "$1" ]; then
            text="--text=<small>$1\n</small>"
            align="left"; h=1
            img="--image=info"
        else
            lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
            text="--text=<small><small><a href='http://idiomind.sourceforge.net/$lgs/$lgtl'>$(gettext "Search other topics")</a>   </small></small>"
            align="right"
        fi
        [ -f $DM_tl/.cfg.1 ] && info2=$(cat $DM_tl/.cfg.1 | wc -l) || info2=""
        cd $DC_s

        VAR=$(cat $DC_s/cfg.0 | yad --name=idiomind --text-align=$align \
        --class=idiomind --center $img --image-on-top --separator="" \
        "$text" --width=$wth --height=$eht --ellipsize=END \
        --no-headers --list --window-icon=idiomind --borders=5 \
        --button="gtk-add":3 --button="$(gettext "OK")":0 \
        --title="$(gettext "Topics")" --column=img:img --column=File:TEXT)
        ret=$?
            
        if [ $ret -eq 3 ]; then
        
                if [ "$h" = 1 ]; then
                    $DS/add.sh new_topic & exit
                    
                else
                    $DS/add.sh new_topic & exit
                fi
        
        elif [ $ret -eq 0 ]; then
        
                $DS/stop.sh play &
                
                [ -z "$VAR" ] && exit 1
                
                if [[ -f $DM_tl/"$VAR"/tpc.sh ]]; then
                    $DM_tl/"$VAR"/tpc.sh & exit
                else
                    cp -f $DS/default/tpc.sh $DM_tl/"$VAR"/tpc.sh
                    $DM_tl/"$VAR"/tpc.sh & exit
                fi
        else
            exit 1
        fi
fi
