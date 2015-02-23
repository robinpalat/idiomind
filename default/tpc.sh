#!/bin/bash
# -*- ENCODING: UTF-8 -*-
lgs=$(sed -n 1p $HOME/.config/idiomind/s/cfg.9)
. gettext.sh
LANGUAGE=$lgs
TEXTDOMAIN=idiomind
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR
Encoding=UTF-8
alias gettext='gettext "idiomind"'
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
$DS/stop.sh tpc
gtdr="$(cd "$(dirname "$0")" && pwd)"
topic=$(echo "$gtdr" | sed 's|\/|\n|g' | sed -n 7p)
DC_tlt="$DM_tl/$topic/.conf"
DM_tlt="$DM_tl/$topic"

if [ -d "$DM_tlt" ]; then

    if [ ! -d "$DM_tlt/.conf" ]; then
        
        mkdir -p "$DM_tlt/words/images"
        mkdir "$DM_tlt/.conf"
        cd "$DM_tlt/.conf"
        touch cfg.0 cfg.1 cfg.2 cfg.3 cfg.4 cfg.5
        echo "$(date +%F)" > cfg.12
        echo "1" > cfg.8
        cd $HOME
    fi

    # check index
    #------------------------------------------
    [[ ! -f "$DC_tlt/cfg.0" ]] && touch "$DC_tlt/cfg.0"
    [[ ! -f "$DC_tlt/cfg.1" ]] && touch "$DC_tlt/cfg.1"
    [[ ! -f "$DC_tlt/cfg.2" ]] && touch "$DC_tlt/cfg.2"
    [[ ! -f "$DC_tlt/cfg.3" ]] && touch "$DC_tlt/cfg.3"
    [[ ! -f "$DC_tlt/cfg.4" ]] && touch "$DC_tlt/cfg.4"
    [[ ! -f "$DC_tlt/cfg.10" ]] && touch "$DC_tlt/cfg.10"

    check_index1 "$DC_tlt/cfg.0" "$DC_tlt/cfg.1" \
    "$DC_tlt/cfg.2" "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"

    chk0=$(cat "$DC_tlt/cfg.0" | wc -l)
    chk1=$(cat "$DC_tlt/cfg.1" | wc -l)
    chk2=$(cat "$DC_tlt/cfg.2" | wc -l)
    chk3=$(cat "$DC_tlt/cfg.3" | wc -l)
    chk4=$(cat "$DC_tlt/cfg.4" | wc -l)
    stts=$(cat "$DC_tlt/cfg.8")
    mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
    | sort -k 1n,1 -k 7 | wc -l)"
    
    # fix index
    #------------------------------------------
    if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
    || $mp3s != $chk0 || $stts = 13 ]]; then
        sleep 1
        notify-send -i idiomind "$(gettext "Index error")" "$(gettext "fixing...")" -t 3000 &
        > $DT/ps_lk
        [ -d "$DM_tlt/.conf" ] && mkdir "$DM_tlt/.conf"
        DC_tlt="$DM_tlt/.conf"
        cd "$DM_tlt/words/"
        for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"
        for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
        | sed s'|\.\/||'g | sed s'|\.mp3||'g > $DT/index
        
        
        if ([ -f "$DC_tlt/.cfg.11" ] && \
        [ -n "$(cat "$DC_tlt/.cfg.11")" ]); then
        index="$DC_tlt/.cfg.11"
        echo ok
        else
        index="$DT/index"
        fi

        while read name; do
        
            sfname="$(nmfile "$name")"
            wfname="$(nmfile "$name")"

            if [ -f "$DM_tlt/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
                echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
            elif [ -f "$DM_tlt/$sfname.mp3" ]; then
                tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
                trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$sfname" != "$xname" ] && \
                mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
                echo "$trgt" >> "$DC_tlt/cfg.4.tmp"
            elif [ -f "$DM_tlt/words/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
                echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
            elif [ -f "$DM_tlt/words/$wfname.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$wfname.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$wfname" != "$xname" ] \
                && mv -f "$DM_tlt/words/$wfname.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/cfg.0.tmp"
                echo "$trgt" >> "$DC_tlt/cfg.3.tmp"
            fi
            
        done < "$index"

        mv -f "$DC_tlt/cfg.0.tmp" "$DC_tlt/cfg.0"
        mv -f "$DC_tlt/cfg.3.tmp" "$DC_tlt/cfg.3"
        mv -f "$DC_tlt/cfg.4.tmp" "$DC_tlt/cfg.4"
        cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"
        cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
        
        check_index1 "$DC_tlt/cfg.0" "$DC_tlt/cfg.1" \
        "$DC_tlt/cfg.2" "$DC_tlt/cfg.3" "$DC_tlt/cfg.4"
        
        if [ $? -ne 0 ]; then
            [[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
            msg " $(gettext "File not found")\n\n" error & exit 1
        fi
        
        if [[ -z $stts ]]; then
            echo "1" > "$DC_tlt/cfg.8"
        elif [[ $stts = "13" ]]; then
            if cat "$DM_tl/.cfg.3" | grep -Fxo "$topic"; then
                echo "6" > "$DC_tlt/cfg.8"
            elif cat "$DM_tl/.cfg.2" | grep -Fxo "$topic"; then
                echo "1" > "$DC_tlt/cfg.8"
            else
                echo "1" > "$DC_tlt/cfg.8"
            fi
        fi

        $DS/mngr.sh mkmn
    fi
    #------------------------------------------
    
    # look status
    if [[ $(cat "$DM_tl/.cfg.1" | grep -Fxon "$topic" \
    | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
        if [ -f "$DC_tlt/cfg.9" ]; then
            dts=$(cat "$DC_tlt/cfg.9" | wc -l)
            if [ $dts = 1 ]; then
                dte=$(sed -n 1p "$DC_tlt/cfg.9")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/10))
            elif [ $dts = 2 ]; then
                dte=$(sed -n 2p "$DC_tlt/cfg.9")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/15))
            elif [ $dts = 3 ]; then
                dte=$(sed -n 3p "$DC_tlt/cfg.9")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/30))
            elif [ $dts = 4 ]; then
                dte=$(sed -n 4p "$DC_tlt/cfg.9")
                TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
                RM=$((100*$TM/60))
            fi
            nstll=$(grep -Fxo "$topic" "$DM_tl/.cfg.3")
            if [ -n "$nstll" ]; then
                if [ "$RM" -ge 100 ]; then
                    echo "9" > "$DC_tlt/cfg.8"
                fi
                if [ "$RM" -ge 150 ]; then
                    echo "10" > "$DC_tlt/cfg.8"
                fi
            else
                if [ "$RM" -ge 100 ]; then
                    echo "4" > "$DC_tlt/cfg.8"
                fi
                if [ "$RM" -ge 150 ]; then
                    echo "5" > "$DC_tlt/cfg.8"
                fi
            fi
        fi
        
        $DS/mngr.sh mkmn
    fi
    
    # set
    if cat "$DM_tl/.cfg.3" | grep -Fxo "$topic"; then
        echo "$topic" > $DC_s/cfg.8
        echo istll >> $DC_s/cfg.8
        echo "$topic" > $DM_tl/.cfg.8
        echo istll >> $DM_tl/.cfg.8
        echo "$topic" > $DC_s/cfg.6
    else
        echo "$topic" > $DC_s/cfg.8
        echo wn >> $DC_s/cfg.8
        echo "$topic" > $DM_tl/.cfg.8
        echo wn >> $DM_tl/.cfg.8
        echo "$topic" > $DC_s/cfg.6
    fi
    
    sleep 1
    [[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
    cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
    notify-send --icon=idiomind \
    "$topic" "$(gettext "Is your topic now")" -t 2000 & exit 1
else
    [[ -f $DT/ps_lk ]] && rm -f $DT/ps_lk
    msg " $(gettext "File not found")\n $topic\n" error & exit 1
fi
