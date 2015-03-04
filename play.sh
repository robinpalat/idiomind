#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf

itms="Words
Sentences
Marks
Practice
News
News episodes
Saved epidodes
Text
Audio
Repeat
Only videos"

if [ "$1" = time ]; then

    cd $DT/p
    c=$(mktemp $DT/c.XXX)
    bcl=$(cat $DC_s/cfg.2)
    if [ -z "$bcl" ]; then
        echo 8 > $DC_s/cfg.2
        bcl=$(sed -n 1p $DC_s/cfg.2); fi
    yad --mark="8 s":8 --mark="60 s":60 \
    --mark="120 s":120 --borders=20 --scale \
    --max-value=128 --value="$bcl" --step 1 \
    --name=idiomind --on-top --skip-taskbar \
    --window-icon=idiomind --borders=5 \
    --title=" " --width=280 --height=240 \
    --min-value=0 --button="Ok":0 > $c
    [ "$?" -eq 0 ] && cat "$c" > $DC_s/cfg.2
    rm -f $c; exit 1

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
    in5=$(cat $DM_tl/Feeds/.conf/cfg.0 | sed '/^$/d')
    in6=$(tac $DM_tl/Podcasts/.conf/.cfg.11 | sed '/^$/d')
    in7=$(tac $DM_tl/Podcasts/.conf/.cfg.22 | sed '/^$/d')
    nnews=$(tac $DM_tl/Feeds/.conf/cfg.1 | head -n 8)
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    [ ! -d $DT/p ] && mkdir $DT/p; cd $DT/p
    
    function setting_() {
        n=1
        while [ $n -lt 12 ]; do

            if [ $n -gt 7 ]; then
                echo "$DS/images/set.png"
            else
                arr="in$n"
                [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
                || echo "$DS/images/add.png"
            fi
            echo "$(gettext "$(echo "$itms" | sed -n "$n"p)")"
            echo $(sed -n "$n"p $DC_s/cfg.5 | cut -d '|' -f 3)
            let n++
        done
    }

    slct=$(mktemp $DT/slct.XXXX)
    [ -f $DT/.p_ ] && btn="gtk-media-stop:2" || btn="Play:0"
    setting_ | yad --list --on-top --separator="|" \
    --expand-column=2 --print-all --center \
    --width=410 --name=idiomind --class=idmnd \
    --height=340 --title="$tpc" --skip-taskbar \
    --window-icon=idiomind --no-headers \
    --borders=5 --button="$btn" --always-print-result \
    --column=IMG:IMG --column=TXT:TXT --column=CHK:CHK > "$slct"
    ret=$?

    if  [ "$ret" -eq 0 ]; then
    
        mv -f "$slct" $DC_s/cfg.5; cd $DT/p; > ./indx; n=1
        
        while [ $n -lt 7 ]; do
        
            if sed -n "$n"p $DC_s/cfg.5 | grep TRUE; then
                arr="in$n"
                echo "${!arr}" >> ./indx
            fi
            let n++
        done
        
    elif [ "$ret" -eq 2 ]; then
        rm -f "$slct"
        [ -d $DT/p ] && rm -fr $DT/p
        [ -f $DT/.p_ ] && rm -f $DT/.p_
        /usr/share/idiomind/stop.sh play & exit
    else
        if  [ ! -f $DT/.p_ ]; then
            [ -d $DT/p ] && rm -fr $DT/p
        fi
        rm -f "$slct"
        exit 1
    fi

    rm -f $slct
    $DS/stop.sh playm

    if ! [ "$(cat $DC_s/cfg.5 | head -n7 | grep -o "TRUE")" ]; then
        notify-send "$(gettext "Exiting")" "$(gettext "Nothing specified to play")" -i idiomind -t 3000 &&
        sleep 5
        $DS/stop.sh play
    fi

    if [ -z "$(cat $DT/p/indx)" ]; then
        echo "$(cat $DT/p/indx)"
        notify-send -i idiomind "$(gettext "Exiting")" "$(gettext "Nothing to play")" -t 3000 &
        rm -f $DT/.p_ &
        $DS/stop.sh play & exit 1
    fi
    
    printf "plyrt.$tpc.plyrt\n" >> $DC_s/cfg.30 &
    sleep 1
    $DS/bcle.sh & exit
fi
