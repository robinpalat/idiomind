#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DC_a/stats/wr.cfg"

charts() {
    
    LABELS=("Dedication"  "Study" "Achievements" "Discard")
    COLORS=("#1c28a1" "#ff6d00" "#107a3f" "#bf0000");
     
    TARGET_DIR='images'
    PRO=$(($pro+100))
     
    arc=()
    sum=0
    for piece in "$@"
    do
            sum=$(( $piece + $sum ))
    done
     
    WIDTHxHEIGHT='330x330'
    RADIUS=135
    CENTERX=160
    CENTERY=160
     
    count=0
    startAngle=0
    endAngle=0
    arc=0
    total=0
    x1=0
    x2=0
    y1=0
    y2=0
    pi=$(echo "scale=10; 4*a(1)" | bc -l)
    cmd='convert -size '$WIDTHxHEIGHT' xc:white -stroke white -strokewidth 5 '
    first=0
    for piece in "$@"
    do
            startAngle=$endAngle
            endAngle=$(echo "scale=10;$startAngle+(360*$piece/$PRO)" | bc -l)
            x1=$(echo "scale=10;$CENTERX+$RADIUS*c($pi*$startAngle/180)" | bc -l)
            y1=$(echo "scale=10;$CENTERY+$RADIUS*s($pi*$startAngle/180)" | bc -l)
            x2=$(echo "scale=10;$CENTERX+$RADIUS*c($pi*$endAngle/180)" | bc -l)
            y2=$(echo "scale=10;$CENTERY+$RADIUS*s($pi*$endAngle/180)" | bc -l)
            if [ $piece -ge 50 ]
            then
                    FIFTY=1
            else
                    FIFTY=0
              fi
            cmd=$cmd"-fill '${COLORS[count]}' -draw \"path 'M $CENTERX,$CENTERY L $x1,$y1 A $RADIUS,$RADIUS 0 $FIFTY,1 $x2,$y2 Z'\" "
     
            count=$(( $count + 1 ))
    done
    cmd=$cmd" $DC_a/stats/chart.jpg"
     
    eval $cmd
     
    KEY_SIZE=20
    MARGIN=5
    TEXT_X=$(( $KEY_SIZE+$MARGIN ))
     
    legends=$(( $#*($KEY_SIZE+$MARGIN) ))
     
    cmd='convert -size 125x'$legends' xc:white -fill white '
    label=" -font 'Nimbus-Sans-Bold' -stroke none -pointsize 12 "
    count=0;
    y1=5
    for piece in "$@"
    do
            y2=$(( $y1+$KEY_SIZE ))
            y3=$(( $y2-$MARGIN ))
            label=$label"-fill '${COLORS[count]}' -draw 'rectangle 0,$y1 $KEY_SIZE,$y2 ' -draw \"text $TEXT_X,$y3 '$piece% ${LABELS[count]}'\" "
            count=$(( $count + 1 ))
            y1=$(( $y1+$KEY_SIZE+$MARGIN ))
    done
    cmd=$cmd$label" $DC_a/stats/legend.jpg"
     
    eval $cmd

}

LOG="$DC_s/8.cfg"
NUM=$DC_a/stats/num.tmp
TPS=$DC_a/stats/tpcs.tmp
[ ! -f "$DC_a/stats/.udt" ] && touch "$DC_a/stats/.udt"
udt=$(< "$DC_a/stats/.udt")
[ ! -d "$DC_a/stats" ] && mkdir "$DC_a/stats"

if [ "$1" = A ]; then
    [ "$(date +%F)" = "$udt" ] && exit 1
    
    TPCS=$(grep -o -P '(?<=tpcs.).*(?=\.tpcs)' < "$LOG" \
    | sort | uniq -dc | sort -n -r | head -3 | sed -e 's/^ *//' -e 's/ *$//')
    tpc1=$(sed -n 1p <<<"$TPCS" | cut -d " " -f2-)
    echo "$tpc1" > "$TPS"
    if [ "$(sed -n 2p <<<"$TPCS" | awk '{print ($1)}')" -ge 3 ]; then
        tpc2=$(sed -n 2p <<<"$TPCS" | cut -d " " -f2-)
        echo "$tpc2" >> "$TPS"; fi
    if [ "$(sed -n 3p <<<"$TPCS" | awk '{print ($1)}')" -ge 3 ]; then
        tpc3=$(sed -n 3p <<<"$TPCS" | cut -d " " -f2-)
        echo "$tpc3" >> "$TPS"; fi

    EITM=$(grep -o -P '(?<=eitm.).*(?=.eitm)' < "$LOG" | wc -l)
    AIMG=$(grep -o -P '(?<=aimg.).*(?=.aimg)' < "$LOG" | wc -l)
    REIM=$(grep -o -P '(?<=reim.).*(?=.reim)' < "$LOG" | tr '\n' '+')
    REIM=$(bc -l <<<"$REIM""0")
    AITM=$(grep -o -P '(?<=aitm.).*(?=.aitm)' < "$LOG" | tr '\n' '+')
    echo "$AITM""0" | bc -l > "$NUM"
    AITM=$(bc -l <<<"$AITM""0")
    DDC=$(tr ' ' '+' <<<"$EITM $AIMG $REIM $AITM" | bc -l)
    W9INX=$(grep -o -P '(?<=w9.).*(?=\.w9)' < "$LOG" | tr -s ';' '\n' \
    | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    tpc1=$(sed -n 1p $TPS)
    tpc2=$(sed -n 2p $TPS)
    tpc3=$(sed -n 3p $TPS)

    if [ -n "$tpc3" ];then
        [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && tlng1="$DM_tl/$tpc1/.conf/1.cfg"
        [ -f "$DM_tl/$tpc2/.conf/1.cfg" ] && tlng2="$DM_tl/$tpc2/.conf/1.cfg"
        [ -f "$DM_tl/$tpc3/.conf/1.cfg" ] && tlng3="$DM_tl/$tpc3/.conf/1.cfg"
        touch "$DM_tl/$tpc1/.conf/2.cfg" && tok1="$DM_tl/$tpc1/.conf/2.cfg"
        touch "$DM_tl/$tpc2/.conf/2.cfg" && tok2="$DM_tl/$tpc2/.conf/2.cfg"
        touch "$DM_tl/$tpc3/.conf/2.cfg" && tok3="$DM_tl/$tpc3/.conf/2.cfg"
    elif [ -n "$tpc2" ];then
        [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && tlng1="$DM_tl/$tpc1/.conf/1.cfg"
        [ -f "$DM_tl/$tpc2/.conf/1.cfg" ] && tlng2="$DM_tl/$tpc2/.conf/1.cfg"
        touch "$DM_tl/$tpc1/.conf/2.cfg" && tok1="$DM_tl/$tpc1/.conf/2.cfg"
        touch "$DM_tl/$tpc2/.conf/2.cfg" && tok2="$DM_tl/$tpc2/.conf/2.cfg"
    elif [ -n "$tpc1" ];then
        [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && tlng1="$DM_tl/$tpc1/.conf/1.cfg"
        touch "$DM_tl/$tpc1/.conf/2.cfg" && tok1="$DM_tl/$tpc1/.conf/2.cfg"
    fi

    n=1; > "$DC_a/stats/w9.tmp"
    while [ $n -le 15 ]; do
        if [ $(sed -n "$n"p <<<"$W9INX" | awk '{print ($1)}') -ge 3 ]; then
        
            fwk=$(sed -n "$n"p <<<"$W9INX" | awk '{print ($2)}')
            if [ -n "$tpc3" ];then
                if grep -o "$fwk" < "$tlng1"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif grep -o "$fwk" < "$tlng2"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif grep -o "$fwk" < "$tlng3"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            elif [ -n "$tpc2" ]; then
                if grep -o "$fwk" < "$tlng1"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif grep -o "$fwk" < "$tlng2"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            elif [ -n "$tpc1" ]; then
                if grep -o "$fwk" < "$tlng1"; then
                echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            fi
        fi
        let n++
    done
    sed -i '/^$/d' $DC_a/stats/w9.tmp
    
    CTW9=$(wc -l < $DC_a/stats/w9.tmp)
    echo "$CTW9" >> "$NUM"
    OKIM=$(grep -o -P '(?<=okim.).*(?=.okim)' < "$LOG" | tr '\n' '+')
    echo "$OKIM""0" | bc -l >> "$NUM"
    OKIM=$(bc -l <<<"$OKIM""0")
    ARCH=$(tr ' ' '+' <<<"$CTW9 $OKIM" | bc -l)
    VWR=$(grep -o -P '(?<=vwr.).*(?=.vwr)' < "$LOG" | tr '\n' '+')
    echo "$VWR""0" | bc -l >> "$NUM"
    VWR=$(bc -l <<<"$VWR""0")
    LRNPR=$(grep -o -P '(?<=lrnpr.).*(?=.lrnpr)' < "$LOG" | wc -l)
    echo "$LRNPR">> "$NUM"
    PRCTC=$(grep -o -P '(?<=prctc.).*(?=.prctc)' < "$LOG" | wc -l)
    echo "$PRCTC">> "$NUM"
    STDY=$(tr ' ' '+' <<<"$VWR $LRNPR $PRCTC" | bc -l)
    
    [ $DDC -ge 100 ] && DDC=100
    [ $STDY -ge 100 ] && STDY=100
    [ $ARCH -ge 100 ] && ARCH=100
    ttl=$(($DDC+$ARCH+$STDY))
    real=$(($ttl/3))
    acrm=$((100-$real))
    lfD=$((110-$DDC))
    lfS=$((110-$STDY))
    lfL=$((80-$ARCH))
    flD=$(($DDC*$real/$ttl))
    flS=$(($STDY*$real/$ttl))
    flL=$(($ARCH*$real/$ttl))
    
    charts $flD $flS $flL
    if [ "$aut" = TRUE ]; then
    while read itm; do

        if [ -n "$tpc3" ];then
            if [ -f "$tlng1" ]; then
                if grep -o "$itm" < "$tlng1"; then
                    grep -vxF "$itm" "$tlng1" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng1"
                    echo "$itm" >> "$tok1"; printf "$tpc1%s\n --> $itm"
                fi
            fi
            if [ -f "$tlng2" ]; then
                if grep -o "$itm" < "$tlng2"; then
                    grep -vxF "$itm" "$tlng2" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng2"
                    echo "$itm" >> "$tok2"; printf "$tpc2%s\n --> $itm"
                fi
            fi
            if [ -f "$tlng3" ]; then
                if grep -o "$itm" < "$tlng3"; then
                    grep -vxF "$itm" "$tlng3" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng3"
                    echo "$itm" >> "$tok3"; printf "$tpc3%s\n --> $itm"
                fi
            fi
        elif [ -n "$tpc2" ];then
            if [ -f "$tlng1" ]; then
                if grep -o "$itm" < "$tlng1"; then
                    grep -vxF "$itm" "$tlng1" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng1"
                    echo "$itm" >> "$tok1"; printf "$tpc1%s\n --> $itm"
                fi
            fi
            if [ -f "$tlng2" ]; then
                if grep -o "$itm" < "$tlng2"; then
                    grep -vxF "$itm" "$tlng2" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng2"
                    echo "$itm" >> "$tok2"; printf "$tpc2%s\n --> $itm"
                fi
            fi
        elif [ -n "$tpc1" ];then
            if [ -f "$tlng1" ]; then
                if grep -o "$itm" < "$tlng1"; then
                    grep -vxF "$itm" "$tlng1" > $DT/tlng.tmp
                    sed '/^$/d' $DT/tlng.tmp > "$tlng1"
                    echo "$itm" >> "$tok1"; printf "$tpc1%s\n --> $itm"
                fi
            fi
        fi
        
    done < "$DC_a/stats/w9.tmp"
    fi
    #rm "$DC_s/8.cfg"; touch "$DC_s/8.cfg"
    #echo "$(date +%F)" > "$DC_a/stats/.udt"
    exit 0

#----------------------------
elif [ -z "$1" ]; then

    if [ ! -f "$DC_a/stats/wr.cfg" ] || [ -z "$(< "$DC_a/stats/wr.cfg")" ]; then
    echo -e "act=\"FALSE\"" > "$DC_a/stats/wr.cfg"
    echo -e "pro=\"0\"" >> "$DC_a/stats/wr.cfg"
    echo -e "aut=\"FALSE\"" >> "$DC_a/stats/wr.cfg";fi
    source "$DC_a/stats/wr.cfg"

    C=$(yad --print-all --name=Idiomind \
    --title="$(gettext "Weekly Report")" --borders=10 \
    --image=$DC_a/stats/chart.jpg --separator='|' \
    --center --form --on-top --scroll --skip-taskbar \
    --always-print-result --window-icon=idiomind --class=Idiomind \
    --button="$(gettext "Close")":0 --width=530 --height=400 \
    --field="$(gettext "active")":CHK $act \
    --field="$(gettext "Automark items")":CHK $aut \
    --field="\n\n\n\n$(gettext "Challenge")":lbl " " \
    --field=":scl" $pro \
    --field="<sup>Normal\t\t\t\tHard</sup>\n":lbl " " )
        ret=$?

        if [ $ret -eq 0 ]; then
            val1="$(cut -d "|" -f1 <<<"$C")"
            val2="$(cut -d "|" -f4 <<<"$C")"
            val3="$(cut -d "|" -f2 <<<"$C")"
            sed -i "s/act=.*/act=\"$val1\"/g" "$DC_a/stats/wr.cfg"
            sed -i "s/pro=.*/pro=\"$val2\"/g" "$DC_a/stats/wr.cfg"
            sed -i "s/aut=.*/aut=\"$val3\"/g" "$DC_a/stats/wr.cfg"
        fi
fi
