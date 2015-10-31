#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
dir="${DC_tlt}/practice"
dirs="$DS/practice"
export -f f_lock

function _log() \
{ echo "w9.$(tr -s '\n' '|' < ./${1}.1).w9" >> "$log"; }

function stats() {
    n=1; c=1
    while [ ${n} -le 21 ]; do
        if [ ${n} -eq 21 ]; then
            echo $((n-1)) > .${icon}; break
        elif [ ${v} -le ${c} ]; then
            echo ${n} > ./.${icon}; break
        fi
        ((c=c+5))
        let n++
    done
}

function score() {
    rm ./*.tmp
    [ ! -e ./${practice}.l ] && touch ./${practice}.l
    if [[ $(($(< ./${practice}.l)+easy)) -ge ${all} ]]; then
        _log ${practice}; play "$dirs/all.mp3" &
        date "+%a %d %B" > ./${practice}.lock
        comp 0 & echo 21 > .${icon}
        strt 1
    else
        [ -e ./${practice}.l ] && \
        echo $(($(< ./${practice}.l)+easy)) > ./${practice}.l || \
        echo ${easy} > ./${practice}.l
        s=$(< ./${practice}.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then
                echo $((n-1)) > .${icon}; break
            elif [ ${v} -le ${c} ]; then
                echo ${n} > ./.${icon}; break
            fi
            ((c=c+5))
            let n++
        done
        comp 1 & stats
        strt 2
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
    [[ -e ./a.rev ]] && rev=1 || rev=0
    fonts() {
        _item="$(grep -F -m 1 "trgt={${item}}" "${cfg0}" |sed 's/},/}\n/g')"
        if [[ ${rev} = 0 ]]; then
            trgt="${item}"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${_item}")"
        else
            srce="${item}"
            trgt="$(grep -oP '(?<=srce={).*(?=})' <<<"${_item}")"
        fi
        trgt_f_c=$((38-${#trgt}))
        trgt_f_a=$((25-${#trgt}))
        srce_f_a=$((38-${#srce}))
        [ ${trgt_f_c} -lt 5 ] && trgt_f_c=8
        [ ${trgt_f_a} -lt 5 ] && trgt_f_a=8
        [ ${srce_f_a} -lt 5 ] && srce_f_a=8
        question="\n<span font_desc='Free Sans Bold ${trgt_f_c}'>${trgt}</span>"
        answer1="\n<span font_desc='Free Sans ${trgt_f_a}'>${trgt}</span>"
        answer2="<span font_desc='Free Sans Bold ${srce_f_a}'><i>${srce}</i></span>"
    }

    question() {
        yad --form --title="$(gettext "Practice")" \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=380 --height=270 --borders=8 \
        --field="\n$question":lbl \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "Continue") >>  !$img_cont":0
    }

    answer() {
        yad --form --title="$(gettext "Practice")" \
        --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=380 --height=270 --borders=8 \
        --field="$answer1":lbl \
        --field="":lbl \
        --field="$answer2":lbl \
        --button="$(gettext "I did not know it")!$img_no":3 \
        --button="$(gettext "I Knew it")!$img_yes":2
    }

    while read item; do
        fonts; question
        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score
        else
            answer
            ans=$?
            if [ ${ans} = 2 ]; then
                echo "${item}" >> a.1
                easy=$((easy+1))
            elif [ ${ans} = 3 ]; then
                echo "${item}" >> a.2
                hard=$((hard+1))
            fi
        fi
    done < ./a.tmp

    if [ ! -e ./a.2 ]; then
        export hard ling
        score
    else
        step=2
        while read item; do
            fonts; question
            if [ $? = 1 ]; then
                export hard ling
                break & score
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> a.3
                fi
            fi
        done < ./a.2
        export hard ling
        score
    fi
}

function practice_b(){
    [[ -e ./b.rev ]] && rev=1 || rev=0
    snd="$dirs/no.mp3"
    fonts() {
        _item="$(grep -F -m 1 "trgt={${item}}" "${cfg0}" |sed 's/},/}\n/g')"
        if [[ ${rev} = 0 ]]; then
            trgt="${item}"
            srce=`grep -oP '(?<=srce={).*(?=})' <<<"${_item}"`
            ras=$(sort -Ru b.srces |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}))
            question="\n<span font_desc='Free Sans ${srce_s}' color='#636363'><b>${trgt}</b></span>\n\n"
        else
            srce="${item}"
            trgt=`grep -oP '(?<=srce={).*(?=})' <<<"${_item}"`
            ras=$(sort -Ru "${cfg3}" |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}))
            question="\n<span font_desc='Free Sans ${srce_s}' color='#636363'><b>${trgt}</b></span>\n\n"
        fi
        }

    ofonts() {
        while read -r name; do
        echo "<span font_desc='Free Sans 12'> $name </span>"
        done <<<"${tmp}"
        }
        
    mchoise() {
        dlg=$(ofonts | yad --list --title="$(gettext "Practice")" \
        --text="${question}" \
        --separator=" " --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --undecorated \
        --no-headers \
        --width=390 --height=315 --borders=8 \
        --column=Option \
        --button="$(gettext "Exit")":1 \
        --button="   $(gettext "Continue")   !$img_cont":0)
    }

    P=4; s=11
    while read item; do
        fonts; mchoise
        if [ $? = 0 ]; then
            if grep -o "$srce" <<<"${dlg}"; then
                echo "${item}" >> b.1
                easy=$((easy+1))
            else
                play "$snd" &
                echo "${item}" >> b.2
                hard=$((hard+1))
            fi  
        elif [ $? = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score
        fi
    done < ./b.tmp
        
    if [ ! -e ./b.2 ]; then
        export hard ling
        score
    else
        step=2; P=2; s=12
        while read item; do
            fonts; mchoise
            if [ $? = 0 ]; then
                if grep -o "$srce" <<<"${dlg}"; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                else
                    play "$snd" &
                    echo "${item}" >> b.3
                fi
            elif [ $? = 1 ]; then
                export hard ling
                break & score
            fi
        done < ./b.2
        export hard ling
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
        lquestion="\n\n<span font_desc='Verdana ${s}' color='#717171'><b>${lst}</b></span>\n\n\n"
        }

    question() {
        cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${id}"
        (sleep 0.5 && "$DS/play.sh" play_word "${trgt}" ${id}) &

        yad --form --title="$(gettext "Practice")" \
        --text="$lquestion" \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --image-on-top --undecorated \
        --width=370 --height=240 --borders=10 \
        --field="!$DS/images/listen.png":BTN "$cmd_play" \
        --button="$(gettext "Exit")":1 \
        --button=" $(gettext "No") !$img_no":3 \
        --button=" $(gettext "Yes") !$img_yes":2
        }

    p=1
    while read trgt; do
        fonts; question
        ans=$?
        if [ ${ans} = 2 ]; then
            echo "${trgt}" >> c.1
            easy=$((easy+1))
        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> c.2
            hard=$((hard+1))
        elif [ ${ans} = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score
        fi
    done < ./c.tmp

    if [ ! -e ./c.2 ]; then
        export hard ling
        score
    else
        step=2; p=2
        while read trgt; do
            fonts; question
            ans=$?
            if [ ${ans} = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> c.3
            elif [ ${ans} = 1 ]; then
                export hard ling
                break & score
            fi
        done < ./c.2
        export hard ling
        score
    fi
}

function practice_d() {
    [[ -e ./d.rev ]] && rev=1 || rev=0
    fonts() {
        img="$DM_tls/images/${item,,}-0.jpg"
        _item="$(grep -F -m 1 "trgt={${item}}" "${cfg0}" |sed 's/},/}\n/g')"
        if [[ ${rev} = 0 ]]; then
        trgt="${item}"
        srce=`grep -oP '(?<=srce={).*(?=})' <<<"${_item}"`
        else
        srce="${item}"
        trgt=`grep -oP '(?<=srce={).*(?=})' <<<"${_item}"`
        fi
        [ ${#trgt} -gt 20 -o ${#srce} -gt 20 ] && trgt_f_c=11 || trgt_f_c=12
        [ ! -e "$img" ] && img="$DS/images/imgmiss.jpg"
        cuest="<span font_desc='Free Sans ${trgt_f_c}' color='#565656'> ${trgt} </span>"
        aswer="<span font_desc='Free Sans ${trgt_f_c}'>${srce}</span>"
    }

    question() {
        yad --form --title="$(gettext "Practice")" \
        --image="$img" \
        --skip-taskbar --text-align=center --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=5 \
        --field="$cuest":lbl \
        --button="$(gettext "Exit")":1 \
        --button=" $(gettext "Continue") >>!$img_cont":0
    }

    answer() {
        yad --form --title="$(gettext "Practice")" \
        --image="$img" \
        --selectable-labels \
        --skip-taskbar --text-align=center --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=5 \
        --field="$aswer":lbl \
        --button="$(gettext "I did not know it")!$img_no":3 \
        --button="$(gettext "I Knew it")!$img_yes":2
    }
    
    while read -r item; do
        fonts; question
        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score
        else
            answer
            ans=$?
            if [ ${ans} = 2 ]; then
                echo "${item}" >> d.1
                easy=$((easy+1))
            elif [ ${ans} = 3 ]; then
                echo "${item}" >> d.2
                hard=$((hard+1))
            fi
        fi
    done < ./d.tmp

    if [ ! -e ./d.2 ]; then
        export hard ling
        score
    else
        step=2
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export hard ling
                break & score
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    hard=$((hard-1))
                    ling=$((ling+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> d.3
                fi
            fi
        done < ./d.2
        export hard ling
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
        |sed 's/\b\(.\)/\u\1/g' | sed 's/ /     /g' \
        |sed "s|[a-z]|<span color='#B1B1B1'>\.<\/span>|g" \
        |sed 's|\.|\ .|g' \
        | tr "[:upper:]" "[:lower:]" \
        |sed 's/^\s*./\U&\E/g')"
        fi
        text="<span font_desc='Arial Black $sz'> $hint </span>\n"
        
        entry=$(>/dev/null | yad --form --title="$(gettext "Practice")" \
        --text="$text" \
        --name=Idiomind --class=Idiomind \
        --separator="" \
        --window-icon=idiomind  --image="$DS/images/bar.png" \
        --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
        --text-align="left" --align="center" --image-on-top \
        --width=510 --height=200 --borders=6 \
        --field="" "" \
        --button="$(gettext "Exit")":1 \
        --button="!$DS/images/listen.png":"$cmd_play" \
        --button="  $(gettext "Check")  ":0)
        }
        
    check() {
        sz=$((sz+3))
        yad --form --title="$(gettext "Practice")" \
        --text="<span font_desc='Free Sans 12'>${wes}</span>\\n" \
        --name=Idiomind --class=Idiomind \
        --selectable-labels \
        --window-icon=idiomind \
        --skip-taskbar --wrap --scroll --image-on-top --center --on-top \
        --undecorated --buttons-layout=end \
        --width=510 --height=220 --borders=10 \
        --field="":lbl \
        --field="<span font_desc='Free Sans 10'>$OK\n\n$prc $hits</span>":lbl \
        --button="$(gettext "Continue")":2
        }
        
    get_text() {
        trgt=$(echo "${1}" | sed 's/^ *//; s/ *$//')
        [ ${#trgt} -ge 110 ] && sz=11 || sz=12
        [ ${#trgt} -le 80 ] && sz=13
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
        
        echo "${chk}" > ./chk.tmp; touch ./words.tmp
        for line in `sed 's/ /\n/g' <<<"$out"`; do
            if grep -Fxq "${line}" <<<"$in"; then
                sed -i "s/"${line}"/<b>"${line}"<\/b>/g" ./chk.tmp # TODO
                [ -n "${line}" ] && echo \
                "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
                [ -n "${line}" ] && echo "${line}" >> ./mtch.tmp
            else
                [ -n "${line}" ] && echo \
                "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./words.tmp
            fi
        done
        
        OK=$(tr '\n' ' ' < ./words.tmp)
        sed 's/ /\n/g' < ./chk.tmp > ./all.tmp; touch ./mtch.tmp
        val1=$(cat ./mtch.tmp | wc -l)
        val2=$(wc -l < ./all.tmp)
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
        
    step=2
    while read -r trgt; do
        export trgt
        pos=`grep -Fon -m 1 "trgt={${trgt}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
        item=`sed -n ${pos}p "${cfg0}" |sed 's/},/}\n/g'`
        fname=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`
        get_text "${trgt}"
        cmd_play="$DS/play.sh play_sentence ${fname}"
        ( sleep 0.5 && "$DS/play.sh" play_sentence ${fname} ) &

        dialog2 "${trgt}"
        ret=$?
        if [[ $ret = 1 ]]; then
            break &
            if ps -A | pgrep -f 'play'; then killall play & fi
            export hard ling
            score
        else
            if ps -A | pgrep -f 'play'; then killall play & fi
            result "${trgt}"
        fi

        check "${trgt}"
        ret=$?
        if [[ $ret = 1 ]]; then
            break &
            if ps -A | pgrep -f 'play'; then killall play & fi
            rm -f ./mtch.tmp ./words.tmp
            export hard ling
            score
        elif [[ $ret -eq 2 ]]; then
            if ps -A | pgrep -f 'play'; then killall play & fi
            rm -f ./mtch.tmp ./words.tmp &
        fi
    done < ./e.tmp
    export hard ling
    score
}

function get_list() {
    if [ ${practice} = a -o ${practice} = b -o ${practice} = c ]; then
        > "$dir/${practice}.0"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
            grep -Fvx -f "${cfg4}" "${cfg1}" > "$DT/${practice}.0"
            tac "$DT/${practice}.0" |sed '/^$/d' > "$dir/${practice}.0"
            rm -f "$DT/${practice}.0"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${practice}.0"
        fi
        
        if [ ${practice} = b ]; then
            if [ ! -e "$dir/b.srces" ]; then
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
        
    elif [ ${practice} = d ]; then
        > "$DT/images"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
            grep -Fxvf "${cfg4}" "${cfg1}" > "$DT/images"
        else
            tac "${cfg1}" > "$DT/images"
        fi
        > "$dir/${practice}.0"
        
        ( echo "5"
        while read -r itm; do
        if [ -e "$DM_tls/images/${itm,,}-0.jpg" ]; then
        echo "${itm}" >> "$dir/${practice}.0"; fi
        done < "$DT/images" ) | yad --progress \
        --width 50 --height 35 --undecorated \
        --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        
        sed -i '/^$/d' "$dir/${practice}.0"
        [ -f "$DT/images" ] && rm -f "$DT/images"
    
    elif [ ${practice} = e ]; then
        if [[ `wc -l < "${cfg3}"` -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            tac "$DT/slist" |sed '/^$/d' > "$dir/${practice}.0"
            rm -f "$DT/slist"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${practice}.0"
        fi
    fi
}

function lock() {
    if [ -f "$dir/${practice}.lock" ]; then
        local lock="$dir/${practice}.lock"
        if ! grep 'wait' <<< "$(< "${lock}")"; then
            text_dlg="<b>$(gettext "Practice Completed")</b>\\n   $(< "${lock}")\n"
            if grep -o -E 'a|b|d' <<< ${practice}; then
                yad --title="$(gettext "Practice Completed")" \
                --text="${text_dlg}" \
                --image="$dirs/images/21.png" \
                --window-icon=idiomind --on-top --skip-taskbar --center \
                --width=400 --height=130 --borders=5 \
                --button=" $(gettext "B  Restart") !!$(gettext "Questions in $lgsl - Answers in $lgtl") ":2 \
                --button=" $(gettext "A  Restart") !!$(gettext "Questions in $lgtl - Answers in $lgsl") ":0 \
                --button="    $(gettext "OK")    ":1
                ret=$?
            elif grep -o -E 'c|e' <<< ${practice}; then
                yad --title="$(gettext "Practice Completed")" \
                --text="${text_dlg}" \
                --image="$dirs/images/21.png" \
                --window-icon=idiomind --on-top --skip-taskbar --center \
                --width=400 --height=130 --borders=5 \
                --button=" $(gettext "Restart") !!$(gettext "Questions: $lgtl | Answers: $lgsl") ":0 \
                --button="    $(gettext "OK")    ":1
                ret=$?
            fi
        else
            if [ $(grep -o "wait"=\"[^\"]* "${lock}" |grep -o '[^"]*$') != `date +%d` ]; then
                rm "${lock}" & return 0
            else
                text_dlg="$(gettext "Consider waiting a while before resuming to practice some items")"
                yad --title="$(gettext "Wait")" \
                --text="${text_dlg}" \
                --image="info" \
                --window-icon=idiomind --on-top --skip-taskbar --center \
                --width=400 --height=130 --borders=5 \
                --button="    "$(gettext "Practice")"    ":4 \
                --button="    $(gettext "OK")    ":1
                ret=$?
            fi
        fi
        if [ $ret -eq 0 -o $ret -eq 2 ]; then
        
            rm "${lock}" ./${practice}.0 ./${practice}.1 \
            ./${practice}.2 ./${practice}.3
            [ -e ./${practice}.srces ] && rm ./${practice}.srces
            [ -e ./${practice}.rev ] && rm ./${practice}.rev
            echo 1 > ./.${icon}; echo 0 > ./${practice}.l
            [ $ret -eq 2 ] && > ./${practice}.rev
            
        elif [ $ret -eq 4 ]; then
            rm "${lock}" & return 0
        fi
        strt 0
    fi
}

function starting() {
    yad --title=$(gettext "Information") \
    --text=" $1\t\n" --image=info \
    --window-icon=idiomind \
    --skip-taskbar --center --on-top \
    --width=340 --height=120 --borders=5 \
    --button="    $(gettext "Ok")    ":1
    strt 0
}

function practices() {
    log="$DC_s/log"
    cfg0="$DC_tlt/0.cfg"
    cfg1="$DC_tlt/1.cfg"
    cfg3="$DC_tlt/3.cfg"
    cfg4="$DC_tlt/4.cfg"
    hits="$(gettext "hits")"
    touch "$dir/log1" "$dir/log2" "$dir/log3"
    practice="${1}"
    if [ $practice = a ]; then icon=1
    elif [ $practice = b ]; then icon=2
    elif [ $practice = c ]; then icon=3
    elif [ $practice = d ]; then icon=4
    elif [ $practice = e ]; then icon=5
    else exit; fi
    lock
    
    if [ -f "$dir/${practice}.0" -a -f "$dir/${practice}.1" ]; then
        grep -Fxvf "$dir/${practice}.1" "$dir/${practice}.0" > "$dir/${practice}.tmp"
        if [[ "$(egrep -cv '#|^$' < "$dir/${practice}.tmp")" = 0 ]]; then
        lock; fi
        echo " practice --restarting session"
    else
        get_list
        cp -f "$dir/${practice}.0" "$dir/${practice}.tmp"
        if [[ `wc -l < "$dir/${practice}.0"` -lt 2 ]]; then \
            starting "$(gettext "Insufficient number of items to start")"; return 1
        fi
        echo " practice --new session"
    fi
    
    [ -f "$dir/${practice}.2" ] && rm "$dir/${practice}.2"
    [ -f "$dir/${practice}.3" ] && rm "$dir/${practice}.3"
    all=$(egrep -cv '#|^$' ./${practice}.0)
    img_cont="$DS/images/cont.png"
    img_no="$DS/images/no.png"
    img_yes="$DS/images/yes.png"
    export easy=0
    export hard=0
    export ling=0
    export step=1
    practice_${practice}
}

function strt() {
    [ ! -d "${dir}" ] && mkdir -p "${dir}"
    cd "${dir}"
    [ ! -e ./.1 ] && echo 1 > .1
    [ ! -e ./.2 ] && echo 1 > .2
    [ ! -e ./.3 ] && echo 1 > .3
    [ ! -e ./.4 ] && echo 1 > .4
    [ ! -e ./.5 ] && echo 1 > .5
    [[ ${hard} -lt 0 ]] && hard=0
    if [[ ${step} -gt 1 && ${ling} -ge 1 && ${hard} = 0 ]]; then
        echo -e "wait=\"`date +%d`\"" > ./${practice}.lock; fi

    if [ ${1} = 1 ]; then
        declare info${icon}="<span font_desc='Arial Bold 12'>$(gettext "Test completed!")</span>"
        echo 21 > .${icon}
    elif [ ${1} = 2 ]; then
        learnt=$(< ./${practice}.l); declare info${icon}="* "
        info="<small>$(gettext "Learnt")</small> <span color='#6E6E6E'><b><big>$learnt </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easy </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$ling </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hard </big></b></span>\n"
    fi

    VAR="$(yad --list --title="$(gettext "Practice ")" \
    --text="$info" \
    --class=Idiomind --name=Idiomind \
    --print-column=1 --separator="" \
    --window-icon=idiomind \
    --buttons-layout=edge --image-on-top --center --on-top --text-align=center \
    --ellipsize=NONE --no-headers --expand-column=2 --hide-column=1 \
    --width=500 --height=460 --borders=10 \
    --column="Action" --column="Pick":IMG --column="Label" \
    "a" "$dirs/images/`< ./.1`.png" "   $info1   $(gettext "Flashcards")" \
    "b" "$dirs/images/`< ./.2`.png" "   $info2   $(gettext "Multiple Choice")" \
    "c" "$dirs/images/`< ./.3`.png" "   $info3   $(gettext "Recognizing Words")" \
    "d" "$dirs/images/`< ./.4`.png" "   $info4   $(gettext "Images")" \
    "e" "$dirs/images/`< ./.5`.png" "   $info5   $(gettext "Writing Sentences")" \
    --button="$(gettext "Restart")":3 \
    --button="$(gettext "Start")":0)"
    ret=$?
    unset practice info info1 info2 info3 info4 info5

    if [ $ret -eq 0 ]; then
        if [ -z "$VAR" ]; then
        msg " $(gettext "You must choose a practice.")\n" info
        strt 0
        else
        practices ${VAR}
        fi
    elif [ $ret -eq 3 ]; then
        if [ -d "${dir}" ]; then
        cd "${dir}"; rm .*; rm *
        touch ./log1 ./log2 ./log3; fi
        strt 0
    else
        "$DS/ifs/tls.sh" colorize & exit
    fi
}

strt 0
