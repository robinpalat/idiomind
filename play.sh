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
Repeat"

if [[ "$1" = time ]]; then

    cd $DT/p
    cnf1=$(mktemp $DT/cnf1.XXXX.s)
    bcl=$(cat $DC_s/cfg.2)

    if [[ -z "$bcl" ]]; then
        echo 8 > $DC_s/cfg.2
        bcl=$(sed -n 1p $DC_s/cfg.2)
    fi
    yad --mark="8 s":8 --mark="60 s":60 \
    --mark="120 s":120 --borders=20 --scale \
    --max-value=128 --value="$bcl" --step 1 \
    --name=idiomind --on-top --skip-taskbar \
    --window-icon=idiomind --borders=5 \
    --title=" " --width=280 --height=240 \
    --min-value=0 --button="Ok":0 > $cnf1

    if [[ "$?" -eq 0 ]]; then
        cat "$cnf1" > $DC_s/cfg.2
    fi
        rm -f $cnf1
    [[ "$?" -eq 1 ]] & rm -f $cnf1 & exit 1
    exit 1

elif [[ -z "$1" ]]; then

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
    in5=$(cat $DM_tl/Feeds/.conf/cfg.0)
    in6=$(cat $DM_tl/Podcasts/.conf/.cfg.11)
    in7=$(cat $DM_tl/Podcasts/.conf/.cfg.22)
    nnews=$(cat $DM_tl/Feeds/.conf/cfg.1 | head -n 8)
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    [ ! -d $DT/p ] && mkdir $DT/p; cd $DT/p
    
    function setting_() {
        n=1
        while read x; do

            if [ $n -gt 7 ]; then
                echo "$DS/images/set.png"
            else
                arr="in$n"
                [[ -z ${!arr} ]] && echo "$DS/images/addi.png" \
                || echo "$DS/images/add.png"
            fi
            echo "$(gettext "$(echo "$itms" | sed -n "$n"p)")"
            echo $(sed -n "$n"p $DC_s/cfg.5)
            let n++
        done < $DC_s/cfg.5
    }

    if [ ! -f $DC_s/cfg.5 ]; then
    printf 'FALSE\nFALSE\nFALSE\nFALSE\nFALSE\nFALSE\nFALSE\nTRUE\nTRUE\nFALSE' > $DC_s/cfg.5; fi

    slct=$(mktemp $DT/slct.XXXX)
    [ ! -f $DT/.p_ ] && btn="Time:$DS/play.sh time" || btn="gtk-media-stop:2"
    setting_ | yad --list --on-top \
    --expand-column=2 --print-all --center \
    --width=340 --name=idiomind --class=idmnd \
    --height=260 --title="$tpc" --skip-taskbar \
    --window-icon=idiomind --no-headers \
    --borders=0 --button="$btn" --button=Ok:0  \
    --column=icon:IMG \
    --column=icon:TXT --column=icon:CHK > "$slct"
    ret=$?
    slt=$(cat "$slct")


    if  [[ "$ret" -eq 0 ]]; then
        cd $DT/p
        > ./indx
        if echo "$(echo "$slt" | sed -n 1p)" | grep TRUE; then
            sed -i "1s/.*/TRUE/" $DC_s/cfg.5
            echo "$in1" >> ./indx
        else
            sed -i "1s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 2p)" | grep TRUE; then
            sed -i "2s/.*/TRUE/" $DC_s/cfg.5
            echo "$in2" >> ./indx
        else
            sed -i "2s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 3p)" | grep TRUE; then
            sed -i "3s/.*/TRUE/" $DC_s/cfg.5
            echo "$in3" >> ./indx
        else
            sed -i "3s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 4p)" | grep TRUE; then
            sed -i "4s/.*/TRUE/" $DC_s/cfg.5
            echo "$in4" >> ./indx
        else
            sed -i "4s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 5p)" | grep TRUE; then
            sed -i "5s/.*/TRUE/" $DC_s/cfg.5
            echo "$in5" >> ./indx
        else
            sed -i "5s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 6p)" | grep TRUE; then
            sed -i "6s/.*/TRUE/" $DC_s/cfg.5
            echo "$in6" >> ./indx
        else
            sed -i "6s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 7p)" | grep TRUE; then
            sed -i "7s/.*/TRUE/" $DC_s/cfg.5
            echo "$in7" >> ./indx
        else
            sed -i "7s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 8p)" | grep TRUE; then
            sed -i "8s/.*/TRUE/" $DC_s/cfg.5
        else
            sed -i "8s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 9p)" | grep TRUE; then
            sed -i "9s/.*/TRUE/" $DC_s/cfg.5
        else
            sed -i "9s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 10p)" | grep TRUE; then
            sed -i "10s/.*/TRUE/" $DC_s/cfg.5
        else
            sed -i "10s/.*/FALSE/" $DC_s/cfg.5
        fi
        
        rm -f "$slct"

    #-------------------------------------stop 
    elif [[ "$ret" -eq 2 ]]; then
        rm -f "$slct"
        [[ -d $DT/p ]] && rm -fr $DT/p
        [[ -f $DT/.p_ ]] && rm -f $DT/.p_
        /usr/share/idiomind/stop.sh play & exit
    else
        if  [ ! -f $DT/.p_ ]; then
            [[ -d $DT/p ]] && rm -fr $DT/p
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

    if [[ -z "$(cat $DT/p/indx)" ]]; then
        echo "$(cat $DT/p/indx)"
        notify-send -i idiomind "$(gettext "Exiting")" "$(gettext "Nothing to play")" -t 3000 &
        rm -f $DT/.p_ &
        $DS/stop.sh play & exit 1
    fi

    printf "plyrt.$tpc.plyrt\n" >> $DC_s/cfg.30 &
    sleep 1
    $DS/bcle.sh & exit
fi
