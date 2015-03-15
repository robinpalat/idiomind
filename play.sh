#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
#--text=" <small> $(gettext "Playing:") datos de usauario de podcasts evitar</small>\n \
#<small> $(gettext "Next:") datos de usauario de podcasts evitar </small>" \

itms="Words
Sentences
Marks
Practice
News episodes
Saved epidodes"

if [ -z "$1" ]; then

    echo "$tpc"
    tlng="$DC_tlt/1.cfg"
    winx="$DC_tlt/3.cfg"
    sinx="$DC_tlt/4.cfg"
    [ -z "$tpc" ] && exit 1
    if [ "$(cat "$sinx" | wc -l)" -gt 0 ]; then
        in1=$(grep -Fxvf "$sinx" "$tlng")
    else
        in1=$(cat "$tlng")
    fi
    if [ "$(cat "$winx" | wc -l)" -gt 0 ]; then
        in2=$(grep -Fxvf "$winx" "$tlng")
    else
        in2=$(cat "$tlng")
    fi
    in3=$(cat "$DC_tlt/6.cfg")
    cd "$DC_tlt/practice"
    in4=$(cat w6 | sed '/^$/d' | sort | uniq)
    in5=$(cat "$DM_tl/Feeds/.conf/1.cfg" | sed '/^$/d')
    in6=$(cat "$DM_tl/Feeds/.conf/2.cfg" | sed '/^$/d')
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"
    
    #function setting_1() {
        #n=1
        #while [ $n -le 6 ]; do
                #arr="in$n"
                #[[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
                #|| echo "$DS/images/add.png"
            #echo "  <span font_desc='Verdana 10'>$(gettext "$(echo "$itms" | sed -n "$n"p)")</span>"
            #echo $(sed -n "$n"p "$DC_s/3.cfg" | cut -d '|' -f 3)
            #let n++
        #done
    #}

    #c=$(echo $(($RANDOM%100000))); KEY=$c
    #slct=$(mktemp "$DT"/slct.XXXX)
    [ -f "$DT/.p_" ] && ret="2" || ret="0"
    #setting_1 | yad --list  --separator="|" \
    #--expand-column=2 --print-all --no-headers --name=idiomind \
    #--class=Idiomind --align=right --center  \
    #--width=380 --height=310 --title="Playlists" --on-top \
    #--window-icon=idiomind --borders=5 --always-print-result \
    #--column=IMG:IMG --column=TXT:TXT --column=CHK:CHK \
    #--button="Cancel":1 --button="$btn" --skip-taskbar > "$slct"
    #ret=$?
    
    
    if [ "$ret" -eq 0 ]; then
    
        #mv -f "$slct" "$DC_s/3.cfg"
        cd "$DT"; > ./index; n=1
        while [ $n -le 8 ]; do
                if  sed -n "$n"p "$DC_s/1.cfg" | grep TRUE; then
                    lst="in$n"
                    [ -n "${!lst}" ] && echo "${!lst}" >> ./index
                fi
                let n++
        done
        
        
        #rm -f "$slct"; "$DS/stop.sh" playm

        if ([ -z "$(cat "$DC_s/1.cfg" | head -n6 | grep -o "TRUE")" ] \
        || [ -z "$(cat "$DT/index")" ]); then
            notify-send "$(gettext "Exiting")" "$(gettext "Nothing specified to play")" -i idiomind -t 3000 &&
            sleep 4
            "$DS/stop.sh" play & exit 1
        fi
        
        printf "plyrt.$tpc.plyrt\n" >> "$DC_s/8.cfg" &
        sleep 1
        "$DS/bcle.sh" & exit 0

    elif [ "$ret" -eq 2 ]; then
    
        rm -f "$slct"
        [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
        /usr/share/idiomind/stop.sh play & exit
        
    else
        rm -f "$slct"
        exit 1
    fi

fi
