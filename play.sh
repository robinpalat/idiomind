#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf

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
        indw=$(grep -F -x -v -f "$sinx" "$tlng")
    else
        indw=$(cat "$tlng")
    fi
    if [ "$(cat "$winx" | wc -l)" -gt 0 ]; then
        inds=$(grep -F -x -v -f "$winx" "$tlng")
    else
        inds=$(cat "$tlng")
    fi
    indm=$(cat "$DC_tlt/cfg.6")
    cd "$DC_tlt/practice"
    indp=$(cat w6 | sed '/^$/d' | sort | uniq)
    indf=$(cat $DM_tl/Feeds/.conf/cfg.0)
    indp1=$(cat $DM_tl/Podcasts/.conf/cfg.1)
    indp2=$(cat $DM_tl/Podcasts/.conf/cfg.2)
    nnews=$(cat $DM_tl/Feeds/.conf/cfg.1 | head -n 8)
    u=$(echo "$(whoami)")
    infs=$(echo "$snts Sentences" | wc -l)
    infw=$(echo "$wrds Words" | wc -l)

    if [ ! -d $DT/p ]; then
        mkdir $DT/p
        cd $DT/p
        echo "$indw" > ./indw
        echo "$inds" > ./inds
        echo "$indm" > ./indm
        echo "$indp" > ./indp
        echo "$indf" > ./indf
        echo "$nnews" >> ./indf
        echo "$indp1" >> ./indp1
        echo "$indp2" >> ./indp2
    fi
    [[ -z "$indw" ]] && img1=$DS/images/addi.png || img1=$DS/images/add.png
    [[ -z "$inds" ]] && img2=$DS/images/addi.png || img2=$DS/images/add.png
    [[ -z "$indm" ]] && img3=$DS/images/addi.png || img3=$DS/images/add.png
    [[ -z "$indp" ]] && img4=$DS/images/addi.png || img4=$DS/images/add.png
    [[ -z "$indf" ]] && img5=$DS/images/addi.png || img5=$DS/images/add.png
    [[ -z "$indp1" ]] && img6=$DS/images/addi.png || img6=$DS/images/add.png
    [[ -z "$indp2" ]] && img7=$DS/images/addi.png || img7=$DS/images/add.png
    img8=$DS/images/set.png

    if [[ ! -f $DC_s/cfg.5 ]]; then
    printf 'FALSE\nFALSE\nFALSE\nFALSE\nFALSE\nFALSE\nFALSE\nTRUE\nTRUE\nFALSE' > $DC_s/cfg.5; fi
    st1=$(cat $DC_s/cfg.5 | sed -n 1p)
    st2=$(cat $DC_s/cfg.5 | sed -n 2p)
    st3=$(cat $DC_s/cfg.5 | sed -n 3p)
    st4=$(cat $DC_s/cfg.5 | sed -n 4p)
    st5=$(cat $DC_s/cfg.5 | sed -n 5p)
    st6=$(cat $DC_s/cfg.5 | sed -n 6p)
    st7=$(cat $DC_s/cfg.5 | sed -n 7p)
    st8=$(cat $DC_s/cfg.5 | sed -n 8p)
    st9=$(cat $DC_s/cfg.5 | sed -n 9p)
    st10=$(cat $DC_s/cfg.5 | sed -n 10p)
    st11=$(cat $DC_s/cfg.5 | sed -n 11p)
    st12=$(cat $DC_s/cfg.5 | sed -n 12p)
    slct=$(mktemp $DT/slct.XXXX)
    if [ ! -f $DT/.p_ ]; then
        btn="--button=Time:$DS/play.sh time"
    else
        btn="--button=gtk-media-stop:2"; fi
    yad --list --on-top \
    --expand-column=3 --print-all --center \
    --width=290 --name=idiomind --class=idmnd \
    --height=240 --title="$tpc" --skip-taskbar \
    --window-icon=idiomind --no-headers \
    --borders=0 "$btn" --button=Ok:0 --hide-column=1 \
    --column=Action:TEXT --column=icon:IMG \
    --column=Action:TEXT --column=icon:CHK \
    "Words" "$img1" "$(gettext "Words")" $st1 \
    "Sentences" "$img2" "$(gettext "Sentences")" $st2 \
    "Marks" "$img3" "$(gettext "Marks")" $st3 \
    "practice" "$img4" "$(gettext "Practice")" $st4 \
    "Feeds" "$img5" "$(gettext "News")" $st5 \
    "newsepisodes" "$img6" "$(gettext "News episodes")" $st6 \
    "savedepisodes" "$img7" "$(gettext "Saved episodes")" $st7 \
    "Notification" "$img8" "$(gettext "Text")" $st8 \
    "Audio" "$img8" "$(gettext "Audio")" $st9 \
    "Repeat" "$img8" "$(gettext "Repeat")" $st10 > "$slct"
    ret=$?
    slt=$(cat "$slct")

    if  [[ "$ret" -eq 0 ]]; then
        cd $DT/p
        > ./indx
        if echo "$(echo "$slt" | sed -n 1p)" | grep TRUE; then
            sed -i "1s/.*/TRUE/" $DC_s/cfg.5
            cat ./indw >> ./indx
        else
            sed -i "1s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 2p)" | grep TRUE; then
            sed -i "2s/.*/TRUE/" $DC_s/cfg.5
            cat ./inds >> ./indx
        else
            sed -i "2s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 3p)" | grep TRUE; then
            sed -i "3s/.*/TRUE/" $DC_s/cfg.5
            cat ./indm >> ./indx
        else
            sed -i "3s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 4p)" | grep TRUE; then
            sed -i "4s/.*/TRUE/" $DC_s/cfg.5
            cat ./indp >> ./indx
        else
            sed -i "4s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 5p)" | grep TRUE; then
            sed -i "5s/.*/TRUE/" $DC_s/cfg.5
            cat ./indf >> ./indx
        else
            sed -i "5s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 6p)" | grep TRUE; then
            sed -i "6s/.*/TRUE/" $DC_s/cfg.5
            cat ./indp1 >> ./indx
        else
            sed -i "6s/.*/FALSE/" $DC_s/cfg.5
        fi
        if echo "$(echo "$slt" | sed -n 7p)" | grep TRUE; then
            sed -i "7s/.*/TRUE/" $DC_s/cfg.5
            cat ./indp2 >> ./indx
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

    w=$(sed -n 1p $DC_s/cfg.5)
    s=$(sed -n 2p $DC_s/cfg.5)
    m=$(sed -n 3p $DC_s/cfg.5)
    p=$(sed -n 4p $DC_s/cfg.5)
    f=$(sed -n 5p $DC_s/cfg.5)
    p1=$(sed -n 6p $DC_s/cfg.5)
    P2=$(sed -n 7p $DC_s/cfg.5)

    if ! [ "$(echo "$w""$s""$m""$f""$p""$p1""$p2" | grep -o "TRUE")" ]; then
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
