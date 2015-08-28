#!/bin/bash
# -*- ENCODING: UTF-8 -*-

strt="$DS/practice/strt.sh"
log="$DC_s/log"
cfg0="$DC_tlt/0.cfg"
cfg1="$DC_tlt/1.cfg"
cfg3="$DC_tlt/3.cfg"
cfg4="$DC_tlt/4.cfg"
dir="$DC_tlt/practice"
touch "$dir/log1" "$dir/log2" "$dir/log3"

function stats() {
    
    n=1; c=1
    while [ ${n} -le 21 ]; do
        if [ ${v} -le ${c} ]; then
        echo ${n} > ./.${icon}; break
        fi
        ((c=c+5))
        let n++
    done
}

function score() {
    
    [ ! -e ./${practice}.l ] && touch ./${practice}.l
    if [[ $(($(< ./${practice}.l)+easy)) -ge ${all} ]]; then
    
        play "$drts/all.mp3" &
        echo -e "w9.$(tr -s '\n' '|' < ./${practice}.1).w9\nokp.1.okp" >> "$log"
        echo "$(date "+%a %d %B")" > ./${practice}.lock
        echo 21 > .${icon}
        comp 0 & "$strt" ${icon} ${practice} & exit
    else
        [ -e ./${practice}.l ] && \
        echo $(($(< ./${practice}.l)+easy)) > ./${practice}.l || \
        echo ${easy} > ./${practice}.l
        s=$(< ./${practice}.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then
                echo $((n-1)) > .${icon}
            elif [ ${v} -le ${c} ]; then
                echo ${n} > .${icon}; break
            fi
            ((c=c+5))
            let n++
        done
        comp 1 & stats
        "$strt" ${_stats} ${practice} ${easy} ${ling} ${hard} & exit
    fi
}
    
function comp() {

    if [ ${1} = 0 ]; then
        > ./${practice}.2
        > ./${practice}.3
    fi
    cat *.1 > ./log1
    if [ ${step} = 1 ]; then
        cat *.2 > ./log2
    elif [ ${step} = 2 ]; then
        cat *.2 > ./log2
        cat *.3 > ./log3
    fi
}

function practice_a() {

    fonts() {

        item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
        srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
        trgt_f_c=$((38-${#trgt}))
        trgt_f_a=$((25-${#trgt}))
        srce_f_a=$((38-${#srce}))
        [ ${trgt_f_c} -lt 5 ] && trgt_f_c=8
        [ ${trgt_f_a} -lt 5 ] && trgt_f_a=8
        [ ${srce_f_a} -lt 5 ] && srce_f_a=8
        cuestion="\n<span font_desc='Free Sans Bold ${trgt_f_c}'>${trgt}</span>"
        answer1="\n<span font_desc='Free Sans ${trgt_f_a}'>${trgt}</span>"
        answer2="<span font_desc='Free Sans Bold ${srce_f_a}'><i>${srce}</i></span>"
    }

    cuestion() {
        
        yad --form --title="$(gettext "Practice")" \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=360 --height=260 --borders=10 \
        --field="\n$cuestion":lbl \
        --button="$(gettext "Exit")":1 \
        --button="    $(gettext "Continue") >>    ":0
    }

    answer() {
        
        yad --form --title="$(gettext "Practice")" \
        --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=360 --height=260 --borders=10 \
        --field="$answer1":lbl \
        --field="":lbl \
        --field="$answer2":lbl \
        --button="  $(gettext "I did not know it")  ":3 \
        --button="  $(gettext "I Knew it")  ":2
    }

    while read trgt; do

        fonts; cuestion

        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            break & score && exit
            
        else
            answer
            ans="$?"

            if [ ${ans} = 2 ]; then
                echo "${trgt}" >> a.1
                easy=$((easy+1))

            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> a.2
                hard=$((hard+1))
            fi
        fi
    done < ./a.tmp

    if [ ! -f ./a.2 ]; then

        score
        
    step=2
    else
        while read trgt; do

            fonts; cuestion
            
            if [ $? = 1 ]; then
                break & score && exit
            
            else
                answer
                ans="$?"
                
                if [ ${ans} = 2 ]; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                    
                elif [ ${ans} = 3 ]; then
                    echo "${trgt}" >> a.3
                fi
            fi
        done < ./a.2
        score
    fi
}


function practice_b(){

    snd="$drts/no.mp3"
    fonts() {

        item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
        srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
        ras=$(sort -Ru b.srces |egrep -v "$srce" |head -${P})
        tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
        srce_s=$((35-${#trgt}))
        cuestion="\n<span font_desc='Free Sans ${srce_s}' color='#636363'><b>${trgt}</b></span>\n\n"
        }

    ofonts() {
        
        while read -r item; do
        echo " <span font_desc='Free Sans Bold ${s}'> $item </span> "
        done <<<"$tmp"
        }
        
    mchoise() {
        
        dlg=$(ofonts | yad --list --title="$(gettext "Practice")" \
        --text="$cuestion" \
        --separator=" " --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --undecorated \
        --no-headers \
        --width=380 --height=340 --borders=12 \
        --column=Option \
        --button="$(gettext "Exit")":1 \
        --button="$(gettext "OK")":0)
    }

    P=5; s=11
    while read trgt; do

        fonts; mchoise

        if [ $? = 0 ]; then

            if grep -o "$srce" <<<"${dlg}"; then

                echo "${trgt}" >> b.1
                easy=$((easy+1))
                
            else
                play "$snd" &
                echo "${trgt}" >> b.2
                hard=$((hard+1))
            fi  
                
        elif [ $? = 1 ]; then
            ling=${hard}; hard=0
            break & score && exit
        fi
        
    done < ./b.tmp
        
    if [ ! -f ./b.2 ]; then

        score
        
    else
        step=2; P=2; s=12
        while read trgt; do

            fonts; mchoise
            
            if [ $? = 0 ]; then
            
                if grep -o "$srce" <<<"${dlg}"; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                    
                else
                    play "$snd" &
                    echo "${trgt}" >> b.3
                fi

            elif [ $? = 1 ]; then
                break & score && exit
            fi
            
        done < ./b.2
        score
    fi
}


function practice_c() {

    fonts() {
        
        if [[ $p = 2 ]]; then
        [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
        && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt,,}" |awk '$1=$1' FS= OFS=" " |tr aeiouy '.')
        elif [[ $p = 1 ]]; then
        [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
        && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt^}" |sed "s|[a-z]|"\ \."|g")
        fi
        
        item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
        id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
        s=$((30-${#trgt}))
        lcuestion="\n\n<span font_desc='Verdana ${s}' color='#717171'><b>${lst}</b></span>\n\n\n"
        }

    cuestion() {
        
        cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${id}"
        (sleep 0.5 && "$DS/play.sh" play_word "${trgt}" ${id}) &

        yad --form --title="$(gettext "Practice")" \
        --text="$lcuestion" \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --image-on-top --undecorated \
        --width=350 --height=210 --borders=10 \
        --field="$(gettext "Pronounce")":BTN "$cmd_play" \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "No")  ":3 \
        --button="  $(gettext "Yes")  ":2
        }

    p=1
    while read trgt; do

        fonts; cuestion
        ans="$?"
        
        if [ ${ans} = 2 ]; then
            echo "${trgt}" >> c.1
            easy=$((easy+1))

        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> c.2
            hard=$((hard+1))

        elif [ ${ans} = 1 ]; then
            ling=${hard}; hard=0
            break & score && exit
        fi
    done < ./c.tmp

    if [ ! -f ./c.2 ]; then

        score
        
    else
        step=2; p=2
        while read trgt; do

            fonts; cuestion
            ans="$?"
              
            if [ ${ans} = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                    
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> c.3

            elif [ ${ans} = 1 ]; then
                break & score && exit
            fi
        done < ./c.2
        score
    fi
}


function practice_d() {

    fonts() {
        
        item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
        srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
        img="$DM_tls/images/${trgt,,}-0.jpg"
        [ ${#trgt} -gt 10 -o ${#srce} -gt 10 ] && trgt_f_c=14 || trgt_f_c=15
        [ ! -f "$img" ] && img="$DS/practice/images/img_2.jpg"
        cuest="<span font_desc='Free Sans Bold ${trgt_f_c}' color='#777777'> ${srce} </span>"
        aswer="<span font_desc='Free Sans Bold ${trgt_f_c}'>${trgt}</span>"
    }

    cuestion() {
        
        yad --form --title="$(gettext "Practice")" \
        --image="$img" \
        --skip-taskbar --text-align=center --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=5 \
        --field="$cuest":lbl \
        --button="$(gettext "Exit")":1 \
        --button=" $(gettext "Continue") >> ":0
    }

    answer() {
        
        yad --form --title="$(gettext "Practice")" \
        --image="$img" \
        --selectable-labels \
        --skip-taskbar --text-align=center --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=5 \
        --field="$aswer":lbl \
        --button="  $(gettext "I did not know it")  ":3 \
        --button="  $(gettext "I Knew it")  ":2
    }
    
    while read -r trgt; do

        fonts; cuestion
        
        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            break & score && exit
            
        else
            answer
            ans="$?"

            if [ ${ans} = 2 ]; then
                echo "${trgt}" >> d.1
                easy=$((easy+1))

            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> d.2
                hard=$((hard+1))
            fi
        fi
        
    done < ./d.tmp

    if [ ! -f ./d.2 ]; then
    
        score
        
    else
        step=2
        while read -r trgt; do

            fonts; cuestion

            if [ $? = 1 ]; then
                break & score && exit

            else
                answer
                ans="$?"
                
                if [ ${ans} = 2 ]; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                    
                elif [ ${ans} = 3 ]; then
                    echo "${trgt}" >> d.3
                fi
            fi
            
        done < ./d.2
        score
    fi
}


function practice_e() {

    dialog2() {

        if [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ]; then
        hint=" "
        else
        hint="$(echo "$@" | tr -d "',.;?!¿¡()" | tr -d '"' \
        | awk '{print tolower($0)}' \
        |sed 's/\b\(.\)/\u\1/g' | sed 's/ /         /g' \
        |sed 's|[a-z]|\.|g' \
        |sed 's|\.|\ .|g' \
        | tr "[:upper:]" "[:lower:]" \
        |sed 's/^\s*./\U&\E/g')"
        fi
        text="<span font_desc='Free Sans Bold $sz' color='#717171'>$hint</span>\n"
        
        entry=$(>/dev/null | yad --form --title="$(gettext "Practice")" \
        --text="$text" \
        --name=Idiomind --class=Idiomind \
        --separator="" \
        --window-icon="$DS/images/icon.png" --image="$DS/practice/images/bar.png" \
        --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
        --text-align=left --align=left --image-on-top \
        --width=510 --height=220 --borders=10 \
        --field="" "" \
        --field="$(gettext "Listen"):BTN" "$cmd_play" \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "Check")  ":0)
        }
        
    check() {
        
        sz=$((sz+3))
        yad --form --title="$(gettext "Practice")" \
        --text="<span font_desc='Free Sans $sz'>${wes}</span>\\n" \
        --name=Idiomind --class=Idiomind \
        --image="/usr/share/idiomind/practice/images/bar.png" $aut \
        --selectable-labels \
        --window-icon="$DS/images/icon.png" \
        --skip-taskbar --wrap --scroll --image-on-top --center --on-top \
        --undecorated --buttons-layout=end \
        --width=510 --height=250 --borders=10 \
        --field="":lbl \
        --field="<span font_desc='Free Sans 10'>$OK\n\n$prc $hits</span>":lbl \
        --button="$(gettext "Continue")":2
        }
        
    get_text() {
        
        trgt=$(echo "${1}" | sed 's/^ *//; s/ *$//')
        [ ${#trgt} -ge 110 ] && sz=10 || sz=11
        [ ${#trgt} -le 80 ] && sz=12
        chk=`echo "${trgt}" | awk '{print tolower($0)}'`
        }

    clean() {
        sed 's/ /\n/g' \
        | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
        | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' \
        | tr -d '|“”&:!'
        }

    result() {
        
        if [[ `wc -w <<<"$chk"` -gt 6 ]]; then
        out=`awk '{print tolower($0)}' <<<"${entry}" | clean | grep -v '^.$'`
        in=`awk '{print tolower($0)}' <<<"${chk}" | clean | grep -v '^.$'`
        else
        out=`awk '{print tolower($0)}' <<<"${entry}" | clean`
        in=`awk '{print tolower($0)}' <<<"${chk}" | clean`
        fi
        
        echo "${chk}" > ./chk.tmp
        while read -r line; do
        
            if grep -Fxq "${line}" <<<"$in"; then
                sed -i "s/"${line}"/<b>"${line}"<\/b>/g" ./chk.tmp
                [ -n "${line}" ] && echo \
                "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
                [ -n "${line}" ] && echo "${line}" >> ./mtch.tmp
            else
                [ -n "${line}" ] && echo \
                "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./words.tmp
            fi
            
        done < <(sed 's/ /\n/g' <<<"$out")
        
        OK=$(tr '\n' ' ' < ./words.tmp)
        
        sed 's/ /\n/g' < ./chk.tmp > ./all.tmp; touch ./mtch.tmp
        
        val1=$(wc -l < ./mtch.tmp); val2=$(wc -l <<<"$out")
        
        yad --text="$val1 ... $val2"
        
        porc=$((100*val1/val2))
        
        if [ ${porc} -ge 70 ]; then
            echo "${trgt}" >> ./e.1
            export easy=$((easy+1))
            color=3AB452
            
        elif [ ${porc} -ge 50 ]; then
            echo "${trgt}" >> ./e.2
             export ling=$((ling+1))
            color=E5801D
            
        else
            [ -n "$entry" ] && echo "${trgt}" >> ./e.3
            [ -n "$entry" ] && export hard=$((hard+1))
            color=D11B5D
        fi
        
        prc="<b>$porc%</b>"
        wes="$(< ./chk.tmp)"
        rm ./chk.tmp
        }

    while read -r trgt; do
        
        export trgt
        pos=`grep -Fon -m 1 "trgt={${trgt}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
        item=`sed -n ${pos}p "${cfg0}" |sed 's/},/}\n/g'`
        fname=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`
        get_text "${trgt}"
        
        cmd_play="$DS/play.sh play_sentence ${fname}"
        ( sleep 0.5 && "$DS/play.sh" play_sentence ${fname} ) &

        dialog2 "${trgt}"
        ret="$?"
        
        if [[ $ret = 1 ]]; then
            break &
            killall play
            score && exit
        else
            killall play &
            result "${trgt}"
        fi

        check "${trgt}"
        ret="$?"
        
        if [[ $ret = 1 ]]; then
            break &
            killall play &
            rm -f ./mtch.tmp ./words.tmp
            score && exit
            
        elif [[ $ret -eq 2 ]]; then
            killall play &
            rm -f ./mtch.tmp ./words.tmp &
        fi

    done < ./e.tmp
    score
}


get_list() {
    
    if [ $practice = a -o $practice = b -o $practice = c ]; then
    
        > "$dir/${practice}.0"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then

            grep -Fvx -f "${cfg4}" "${cfg1}" > "$DT/${practice}.0"
            tac "$DT/${practice}.0" |sed '/^$/d' > "$dir/${practice}.0"
            rm -f "$DT/${practice}.0"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${practice}.0"
        fi
        
        if [ $practice = b ]; then
        
            if [ ! -f "$dir/b.srces" ]; then
            
            ( echo "5"
            while read word; do
            
                item="$(grep -F -m 1 "trgt={${word}}" "${cfg0}" |sed 's/},/}\n/g')"
                echo "$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")" >> "$dir/b.srces"
            
            done < "$dir/${practice}.0" ) | yad --progress \
            --width 50 --height 35 --undecorated \
            --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
        
    elif [ $practice = d ]; then
    
        > "$DT/images"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
        
            grep -Fxvf "${cfg4}" "${cfg1}" > "$DT/images"
        else
            tac "${cfg1}" > "$DT/images"
        fi
        > "$dir/${practice}.0"
        
        ( echo "5"
        while read -r itm; do
        if [ -f "$DM_tls/images/${itm,,}-0.jpg" ]; then
        echo "${itm}" >> "$dir/${practice}.0"; fi
        done < "$DT/images" ) | yad --progress \
        --width 50 --height 35 --undecorated \
        --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        
        sed -i '/^$/d' "$dir/${practice}.0"
        [ -f "$DT/images" ] && rm -f "$DT/images"
    
    elif [ $practice = e ]; then
    
        if [[ `wc -l < "${cfg3}"` -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            tac "$DT/slist" |sed '/^$/d' > "$dir/${practice}.0"
            rm -f "$DT/slist"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${practice}.0"
        fi
    fi
}

lock() {

    if [ -f "$dir/${practice}.lock" ]; then

        info="$dir/${practice}.lock"
        yad --title="$(gettext "Practice Completed")" \
        --text="<b>$(gettext "Practice Completed")</b>\\n   $(< "$info")\n " \
        --window-icon="$DS/images/icon.png" --on-top --skip-taskbar \
        --center --image="$DS/practice/images/21.png" \
        --width=400 --height=130 --borders=5 \
        --button="    $(gettext "Restart")    ":0 \
        --button="    $(gettext "Ok")    ":2
        
        if [ $? -eq 0 ]; then
            rm ./${practice}.lock ./${practice}.0 ./${practice}.1 \
            ./${practice}.2 ./${practice}.3
            [ -f ./${practice}.srces ] && rm ./${practice}.srces
            echo 1 > ./.${icon}; echo 0 > ./${practice}.l
        fi
        "$strt" & exit
    fi
}

starting() {
    
    yad --title="$1" \
    --text=" $1.\n" --image=info \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=400 --height=130 --borders=5 \
    --button="    $(gettext "Ok")    ":1
    "$strt" & exit 1
}

practice() {

    cd "${DC_tlt}/practice"
    practice="${1}"
    [[ $practice = a ]] && icon=1 && _stats=6
    [[ $practice = b ]] && icon=2 && _stats=7
    [[ $practice = c ]] && icon=3 && _stats=8
    [[ $practice = d ]] && icon=4 && _stats=9
    [[ $practice = e ]] && icon=5 && _stats=10
    
    lock
    if [ -f "$dir/${practice}.0" -a -f "$dir/${practice}.1" ]; then
    
        grep -Fxvf "$dir/${practice}.1" "$dir/${practice}.0" > "$dir/${practice}.tmp"
        if [[ "$(egrep -cv '#|^$' < "$dir/${practice}.tmp")" = 0 ]]; then
        lock && exit; fi
        echo " practice --restarting session"
    else
        get_list
        cp -f "$dir/${practice}.0" "$dir/${practice}.tmp"
        
        if [[ `wc -l < "$dir/${practice}.0"` -lt 2 ]]; then \
        starting "$(gettext "Not enough items to start")"
        echo " practice --new session"; fi
    fi
    
    [ -f "$dir/${practice}.2" ] && rm "$dir/${practice}.2"
    [ -f "$dir/${practice}.3" ] && rm "$dir/${practice}.3"
    drts="$DS/practice"
    cd "$DC_tlt/practice"
    all=$(egrep -cv '#|^$' ./${practice}.0)
    hits="$(gettext "hits")"
    easy=0
    hard=0
    ling=0
    step=1
    f=0
    practice_${practice}
}

case "$1" in
    1)
    practice a ;;
    2)
    practice b ;;
    3)
    practice c ;;
    4)
    practice d ;;
    5)
    practice e ;;
esac

