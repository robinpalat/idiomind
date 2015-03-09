#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
wth=$(sed -n 3p $DC_s/18.cfg)
eht=$(sed -n 4p $DC_s/18.cfg)
LOG=$DC_a/stats/.log
NUM=$DC_a/stats/num.tmp
TPS=$DC_a/stats/tpcs.tmp
WKRT=$DC_a/stats/wkrt.tmp
WKRT2=$DC_a/stats/wkrt2.tmp
[[ ! -f "$DC_a/stats/.udt" ]] && touch "$DC_a/stats/.udt"
udt=$(cat "$DC_a/stats/.udt")
[ ! -d "$DC_a/stats" ] && mkdir "$DC_a/stats"

#----------------------------
if [ "$1" = A ]; then
    [[ "$(date +%F)" = "$udt" ]] && exit 1
    echo "$tpc" > $DC_a/stats/tpc.tmp
    echo $(sed -n 2p $DC_s/8.cfg) >> $DC_a/stats/tpc.tmp
    TPCS=$(cat "$LOG" | grep -o -P '(?<=tpcs.).*(?=\.tpcs)' \
    | sort | uniq -dc | sort -n -r | head -3 | sed -e 's/^ *//' -e 's/ *$//')
    tpc1=$(echo "$TPCS" | sed -n 1p | cut -d " " -f2-)
    echo "$tpc1" > "$TPS"
    if [[ "$(echo "$TPCS" | sed -n 2p | awk '{print ($1)}')" -ge 3 ]]; then
        tpc2=$(echo "$TPCS" | sed -n 2p | cut -d " " -f2-)
        echo "$tpc2" >> "$TPS"
    fi
    if [[ "$(echo "$TPCS" | sed -n 3p | awk '{print ($1)}')" -ge 3 ]]; then
        tpc3=$(echo "$TPCS" | sed -n 3p | cut -d " " -f2-)
        echo "$tpc3" >> "$TPS"
    fi

    EITM=$(cat "$LOG" \
    | grep -o -P '(?<=eitm.).*(?=.eitm)' | wc -l)
    AIMG=$(cat "$LOG" \
    | grep -o -P '(?<=aimg.).*(?=.aimg)' | wc -l)
    REIM=$(cat "$LOG" \
    | grep -o -P '(?<=reim.).*(?=.reim)' | tr '\n' '+')
    REIM=$(echo "$REIM""0" | bc -l)
    AITM=$(cat "$LOG" \
    | grep -o -P '(?<=aitm.).*(?=.aitm)' | tr '\n' '+')
    echo "$AITM""0" | bc -l > "$NUM"
    AITM=$(echo "$AITM""0" | bc -l)
    DDC=$(echo "$EITM $AIMG $REIM $AITM" | tr ' ' '+' | bc -l)
    tpc1=$(sed -n 1p $TPS)
    tpc2=$(sed -n 2p $TPS)
    tpc3=$(sed -n 3p $TPS)

    if [ -n "$tpc3" ];then
        [[ -f "$DC_tl/$tpc1/1.cfg" ]] && tlng1="$DC_tl/$tpc1/1.cfg"
        [[ -f "$DC_tl/$tpc2/1.cfg" ]] && tlng2="$DC_tl/$tpc2/1.cfg"
        [[ -f "$DC_tl/$tpc3/1.cfg" ]] && tlng3="$DC_tl/$tpc3/1.cfg"
        touch "$DC_tl/$tpc1/2.cfg" && tok1="$DC_tl/$tpc1/2.cfg"
        touch "$DC_tl/$tpc2/2.cfg" && tok2="$DC_tl/$tpc2/2.cfg"
        touch "$DC_tl/$tpc3/2.cfg" && tok3="$DC_tl/$tpc3/2.cfg"
    elif [ -n "$tpc2" ];then
        [[ -f "$DC_tl/$tpc1/1.cfg" ]] && tlng1="$DC_tl/$tpc1/1.cfg"
        [[ -f "$DC_tl/$tpc2/1.cfg" ]] && tlng2="$DC_tl/$tpc2/1.cfg"
        touch "$DC_tl/$tpc1/2.cfg" && tok1="$DC_tl/$tpc1/2.cfg"
        touch "$DC_tl/$tpc2/2.cfg" && tok2="$DC_tl/$tpc2/2.cfg"
    elif [ -n "$tpc1" ];then
        [[ -f "$DC_tl/$tpc1/1.cfg" ]] && tlng1="$DC_tl/$tpc1/1.cfg"
        touch "$DC_tl/$tpc1/2.cfg" && tok1="$DC_tl/$tpc1/2.cfg"
    fi

    W9=$DC_s/22.cfg
    W9INX=$(cat $W9 | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    n=1
    while [ $n -le 15 ]; do
        if [[ $(echo "$W9INX" | sed -n "$n"p | awk '{print ($1)}') -ge 3 ]]; then
        
            fwk=$(echo "$W9INX" | sed -n "$n"p | awk '{print ($2)}')
            if [ -n "$tpc3" ];then
                if cat "$tlng1" | grep -o "$fwk"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif cat "$tlng2" | grep -o "$fwk"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif cat "$tlng3" | grep -o "$fwk"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            elif [ -n "$tpc2" ]; then
                if cat "$tlng1" | grep -o "$fwk"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                    
                elif cat "$tlng2" | grep -o "$fwk"; then
                    echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            elif [ -n "$tpc1" ]; then
                if cat "$tlng1" | grep -o "$fwk"; then
                echo "$fwk" >> $DC_a/stats/w9.tmp
                fi
            fi
        fi
        let n++
    done
    sed -i '/^$/d' $DC_a/stats/w9.tmp
    
    CTW9=$(cat $DC_a/stats/w9.tmp | wc -l)
    echo "$CTW9" >> "$NUM"
    OKIM=$(cat "$LOG" \
    | grep -o -P '(?<=okim.).*(?=.okim)' | tr '\n' '+')
    echo "$OKIM""0" | bc -l >> "$NUM"
    OKIM=$(echo "$OKIM""0" | bc -l)
    ARCH=$(echo "$CTW9 $OKIM" | tr ' ' '+' | bc -l)
    VWR=$(cat "$LOG" \
    | grep -o -P '(?<=vwr.).*(?=.vwr)' | tr '\n' '+')
    echo "$VWR""0" | bc -l >> "$NUM"
    VWR=$(echo "$VWR""0" | bc -l)
    LRNPR=$(cat "$LOG" \
    | grep -o -P '(?<=lrnpr.).*(?=.lrnpr)' | wc -l)
    echo "$LRNPR">> "$NUM"
    PRCTC=$(cat "$LOG" \
    | grep -o -P '(?<=prctc.).*(?=.prctc)' | wc -l)
    echo "$PRCTC">> "$NUM"
    STDY=$(echo "$VWR $LRNPR $PRCTC" | tr ' ' '+' | bc -l)
    
    [[ $DDC -ge 100 ]] && DDC=100
    [[ $STDY -ge 100 ]] && STDY=100
    [[ $ARCH -ge 100 ]] && ARCH=100
    ttl=$(($DDC+$ARCH+$STDY))
    real=$(($ttl/3))
    acrm=$((100-$real))
    lfD=$((110-$DDC))
    lfS=$((110-$STDY))
    lfL=$((80-$ARCH))
    flD=$(($DDC*$real/$ttl))
    flS=$(($STDY*$real/$ttl))
    flL=$(($ARCH*$real/$ttl))
    [[ $flD -gt 0 ]] && d=1 || d=0
    [[ $flS -gt 0 ]] && s=1 || s=0
    [[ $flL -gt 0 ]] && l=1 || l=0
    FIX=$(($d+$s+$l))
    
    if [ "$real" -le 10 ]; then
    real=10
    fi
    rm "$LOG"
    ext1="$(n=1; while [ $n -le $flD ]; do printf " "; let n++; done)"
    ext2="$(n=1; while [ $n -le $flS ]; do printf " "; let n++; done)"
    ext3="$(n=1; while [ $n -le $flL ]; do printf " "; let n++; done)"
    ext4="$(n=1; while [ $n -le $acrm ]; do printf " "; let n++; done)"
    ext5="$(n=1; while [ $n -le $FIX ]; do printf " "; let n++; done)"
    [[ "$(echo "$tpc1" | wc -c)" -gt 60 ]] && tle1="${tpc1:0:60}..." || tle1="$tpc1"
    [[ "$(echo "$tpc2" | wc -c)" -gt 60 ]] && tle2="${tpc2:0:60}..." || tle2="$tpc2"
    [[ "$(echo "$tpc3" | wc -c)" -gt 60 ]] && tle3="${tpc3:0:60}..." || tle3="$tpc3"

    if [ $(cat $DC_a/stats/.wks | wc -l) -lt 12 ]; then
    ext=$(n=1; while [ $n -le 112 ]; do printf " "; let n++; done)
    seq 0 15 | xargs -Iz echo "<small><sup><span background='#E8E8E8'>$ext</span></sup></small>" > $DC_a/stats/.wks
    sed -i '/^$/d' $DC_a/stats/.wks
    fi

    echo "<small><sup><span background='#F3C879'>$ext1</span><span background='#6E9FD4'>$ext2</span><span background='#76A862'><span color='#FFFFFF'><b>$ext3$real% </b></span><span background='#E8E8E8'>$ext4$ext5</span></span></sup></small>" >> $DC_a/stats/.wks.tmp
    cat $DC_a/stats/.wks | head -n 12 >> $DC_a/stats/.wks.tmp
    mv -f $DC_a/stats/.wks.tmp $DC_a/stats/.wks
    
    echo "<big><big><b>$real%</b></big></big>  Performance
" > $WKRT
if [ -n "$tpc3" ]; then
    echo "$(gettext "Topics"):
 <b>$tle1</b>
 <b>$tle2</b>
 <b>$tle3</b>
">> $WKRT
elif [ -n "$tpc2" ]; then
    echo "$(gettext "Topics"):
 <b>$tle1</b>
 <b>$tle2</b>
">> $WKRT
else
    echo "$(gettext "Topic"):
 <b>$tle1</b>
">> $WKRT
fi
echo "<big><span font='ultralight'>$CTW9</span></big>  $(gettext "Items that could be marked as learned")" >> $WKRT
echo "<big><span font='ultralight'>$OKIM</span></big>  $(gettext "Items marked learned")

" >> $WKRT
cat "$DC_a/stats/.wks" >> $WKRT2
echo "$(date +%F)" > "$DC_a/stats/.udt"
echo "$tpc" > $DC_s/8.cfg
echo wr >> $DC_s/8.cfg
exit 1


#----------------------------
elif [ -z "$1" ]; then

    sttng=$(sed -n 1p $DC_a/stats/cnfg)
    if [ -z $sttng ]; then
        echo FALSE > $DC_a/stats/cnfg
        sttng=$(sed -n 1p $DC_a/stats/cnfg)
    fi
    if [ $sttng = TRUE ]; then
    SW=$(cat $DC_a/stats/.wks | head -n 8)
    else
    SW=" "; fi

    CNFG=$(yad --print-all --align=center \
    --title="$(gettext "Weekly Report")" --borders=10 \
    --center --form --on-top --scroll --skip-taskbar \
    --always-print-result --window-icon=idiomind \
    --button="$(gettext "Close")":0 --width=420 --height=300 \
    --field="$(gettext "active")":CHK $sttng \
    --field="\n$SW:LBL" \
    --field="\n:LBL")
        ret=$?
        
        if [ $ret -eq 0 ]; then
            sttng=$(echo "$CNFG" | cut -d "|" -f1)
            sed -i "1s/.*/$sttng/" $DC_a/stats/cnfg
            rm -f $DT/*.r
            exit
        else
            sttng=$(echo "$CNFG" | cut -d "|" -f1)
            sed -i "1s/.*/$sttng/" $DC_a/stats/cnfg
            exit
        fi
fi
