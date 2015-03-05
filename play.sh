#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

itms="Words
Sentences
Marks
Practice
News
News episodes
Saved epidodes"

if [ "$1" = time ]; then

    c=$(mktemp "$DT"/c.XXX)
    bcl=$(cat "$DC_s/cfg.2")
    if [ -z "$bcl" ]; then
        echo 8 > "$DC_s/cfg.2"
        bcl=$(sed -n 1p "$DC_s/cfg.2"); fi
    yad --mark="8 s":8 --mark="60 s":60 \
    --mark="120 s":120 --borders=20 --scale \
    --max-value=128 --value="$bcl" --step 1 \
    --name=idiomind --on-top --skip-taskbar \
    --window-icon=idiomind --borders=5 \
    --title=" " --width=280 --height=240 \
    --min-value=0 --button="Ok":0 > $c
    [ "$?" -eq 0 ] && cat "$c" > "$DC_s/cfg.2"
    rm -f "$c"; exit 1

elif [ -z "$1" ]; then

    echo "$tpc"
    tlng="$DC_tlt/cfg.1"
    winx="$DC_tlt/cfg.3"
    sinx="$DC_tlt/cfg.4"
    [ -z "$tpc" ] && exit 1
    if [ "$(cat "$sinx" | wc -l)" -gt 0 ]; then
        in1=$(grep -F -x -v -f "$sinx" "$tlng")
    else
        in1=$(cat "$tlng")
    fi
    if [ "$(cat "$winx" | wc -l)" -gt 0 ]; then
        in2=$(grep -F -x -v -f "$winx" "$tlng")
    else
        in2=$(cat "$tlng")
    fi
    in3=$(cat "$DC_tlt/cfg.6")
    cd "$DC_tlt/practice"
    in4=$(cat w6 | sed '/^$/d' | sort | uniq)
    in5=$(cat "$DM_tl/Feeds/.conf/cfg.0" | sed '/^$/d')
    in6=$(cat "$DM_tl/Podcasts/.conf/cfg.1" | sed '/^$/d')
    in7=$(cat "$DM_tl/Podcasts/.conf/cfg.2" | sed '/^$/d')
    nnews=$(cat "$DM_tl/Feeds/.conf/cfg.1" | head -n 8)
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    [ ! -d "$DT/p" ] && mkdir "$DT/p"; cd "$DT/p"
    
    function setting_1() {
        n=1
        while [ $n -le 7 ]; do
                arr="in$n"
                [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
                || echo "$DS/images/add.png"
            echo "<span font_desc='Verdana 10'>$(gettext "$(echo "$itms" | sed -n "$n"p)")</span>"
            echo $(sed -n "$n"p "$DC_s/cfg.5" | cut -d '|' -f 3)
            let n++
        done
    }
    
    n=1
    while [ $n -le 7 ]; do
            declare st$n="$(sed -n "$n"p < "$DC_s/cfg.11")"
        let n++
    done

    c=$(echo $(($RANDOM%100000))); KEY=$c
    slct1=$(mktemp "$DT"/slct1.XXXX)
    slct2=$(mktemp "$DT"/slct2.XXXX)
    [ -f "$DT/.p_" ] && btn="gtk-media-stop:2" || btn="Play:0"
    setting_1 | yad --list  --separator="|" \
    --expand-column=2 --print-all \
    --no-headers --plug=$KEY --tabnum=1 \
    --column=IMG:IMG --column=TXT:TXT --column=CHK:CHK > "$slct1" &
    yad --form  --separator="\n" --borders=5 \
    --plug=$KEY --tabnum=2 --columns=2 \
    --field=" ":SCL "$st1" \
    --field="Texto":CHK "$st1" \
    --field="Audio":CHK "$st2" \
    --field="Repeat":CHK "$st3" \
    --field="Only videos":CHK "$st4" \
    --field="Play from select item":CHK "$st5" \
    --field="Videos on fullscreen":CHK "$st6" \
    --field="Time lapsus":lbl > "$slct2" &
     yad --notebook --name=idiomind --center \
    --class=Idiomind --align=right --key=$KEY --center  \
    --tab=" $(gettext "Lists") " \
    --tab=" $(gettext "Options") " \
    --width=400 --height=330 --title="$tpc" --on-top \
    --window-icon=idiomind --borders=0 --always-print-result \
    --button="$btn"  --skip-taskbar
    ret=$?

    if  [ "$ret" -eq 0 ]; then
    
        mv -f "$slct1" "$DC_s/cfg.5"
        mv -f "$slct2" "$DC_s/cfg.11"
        cd "$DT/p"; > ./indx; n=1
        
        while [ $n -le 7 ]; do
        
            if sed -n "$n"p "$DC_s/cfg.5" | grep TRUE; then
                arr="in$n"
                echo "${!arr}" >> ./indx
            fi
            let n++
        done
        
    elif [ "$ret" -eq 2 ]; then
        rm -f "$slct"
        [ -d "$DT/p" ] && rm -fr "$DT/p"
        [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
        /usr/share/idiomind/stop.sh play & exit
    else
        if  [ ! -f "$DT/.p_" ]; then
            [ -d "$DT/p" ] && rm -fr "$DT/p"
        fi
        mv -f "$slct2" "$DC_s/cfg.11"
        rm -f "$slct1" "$slct2"
        exit 1
    fi

    rm -f "$slct"
    "$DS/stop.sh" playm

    if ! [ "$(cat "$DC_s/cfg.5" | head -n7 | grep -o "TRUE")" ]; then
        notify-send "$(gettext "Exiting")" "$(gettext "Nothing specified to play")" -i idiomind -t 3000 &&
        sleep 5
        "$DS/stop.sh" play
    fi

    if [ -z "$(cat "$DT/p/indx")" ]; then
        notify-send -i idiomind "$(gettext "Exiting")" "$(gettext "Nothing to play")" -t 3000 &
        rm -f "$DT/.p_" &
        "$DS/stop.sh" play & exit 1
    fi
    
    printf "plyrt.$tpc.plyrt\n" >> "$DC_s/cfg.30" &
    sleep 1
    "$DS/bcle.sh" & exit
fi
