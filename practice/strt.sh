#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
sz=(500 470); [[ ${swind} = TRUE ]] && sz=(420 410)
source "$DS/ifs/cmns.sh"
pdir="${DC_tlt}/practice"
pdirs="$DS/practice"
export -f f_lock

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

function scoreschk() {
    if [[ ${group} = 1 ]]; then
        decide_group
        if [ $ret = 1 ]; then
            practices ${pr}
        elif [ $ret = 0 ]; then
            if [[ "$(egrep -cv '#|^$' < "${pdir}/${pr}.group")" = 0 ]]; then
                export group=0; score
            else
                practices ${pr}
            fi
        fi
    else
        score
    fi
}

function score() {
    rm ./*.tmp
    [ ! -e ./${pr}.l ] && touch ./${pr}.l
    if [[ $(($(< ./${pr}.l)+easy)) -ge ${all} ]] || [[ ${group} = 0 ]]; then
        _log ${pr}; play "$pdirs/all.mp3" &
        date "+%a %d %B" > ./${pr}.lock
        save_gains 0 & echo 21 > .${icon}
        strt 1
    else
        [ -e ./${pr}.l ] && \
        echo $(($(< ./${pr}.l)+easy)) > ./${pr}.l || \
        echo ${easy} > ./${pr}.l; _log ${pr}
        s=$(< ./${pr}.l)
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
        save_gains 1 & stats; strt 2
    fi
}
    
function save_gains() {
    if [ ${1} = 0 ]; then
        > ./${pr}.2
        > ./${pr}.3
    fi
    cat ./*.1 > ./log1
    if [ ${step} = 1 ]; then
        cat ./*.2 > ./log2
    elif [ ${step} = 2 ]; then
        cat ./*.2 > ./log2
        cat ./*.3 > ./log3
    fi
}

function _log() { 
    if [[ ${mode} -le 1 ]] && [ ${1} != 'e' ]; then
        [ -e ./${1}.1 ] && echo "w1.$(tr -s '\n' '|' < ./${1}.1).w1" |sed '/\.\./d' >> "$log"
    elif [[ ${mode} -gt 1 ]] && [ ${1} != 'e' ]; then
        [ -e ./${1}.2 ] && echo "w2.$(tr -s '\n' '|' < ./${1}.2).w2" |sed '/\.\./d' >> "$log"
        [ -e ./${1}.3 ] && echo "w3.$(tr -s '\n' '|' < ./${1}.3).w3" |sed '/\.\./d' >> "$log"
    elif [ ${1} = 'e' ]; then
        [ -e ./${1}.1 ] && echo "s1.$(tr -s '\n' '|' < ./${1}.1).s1" |sed '/\.\./d' >> "$log"
        [ -e ./${1}.2 ] && echo "s2.$(tr -s '\n' '|' < ./${1}.2).s2" |sed '/\.\./d' >> "$log"
        [ -e ./${1}.3 ] && echo "s3.$(tr -s '\n' '|' < ./${1}.3).s3" |sed '/\.\./d' >> "$log"
    fi
}
    
function practice_a() {
    fonts() {
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${quest} != 1 ]]; then
            trgt="${item}"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"
        else
            srce="${item}"
            trgt="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"
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
        yad --form --title=" " \
        --no-focus --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=400 --height=265 --borders=8 \
        --field="\n$question":lbl "" \
        --field="":lbl "" \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "Continue") >>  !$img_cont":0
    }

    answer() {
        yad --form --title=" " \
        --no-focus --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=400 --height=265 --borders=8 \
        --field="$answer1":lbl "" \
        --field="":lbl "" \
        --field="$answer2":lbl "" \
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
        scoreschk
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
        
        scoreschk
    fi
}

function practice_b(){
    snd="$pdirs/no.mp3"
    fonts() {
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${quest} != 1 ]]; then
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            ras=$(sort -Ru b.srces |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}))
            question="\n<span font_desc='Free Sans ${srce_s}'><b>${trgt}</b></span>\n\n"
        else
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            ras=$(sort -Ru "${cfg3}" |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}))
            question="\n<span font_desc='Free Sans ${srce_s}'><b>${trgt}</b></span>\n\n"
        fi
        }

    ofonts() {
        while read -r name; do
        echo "<span font_desc='Free Sans 13'> $name </span>"
        done <<< "${tmp}"
    }

    mchoise() {
        dlg=$(ofonts | yad --list --title=" " \
        --text="${question}" \
        --no-focus --separator=" " --selectable-labels \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --undecorated \
        --no-headers \
        --width=400 --height=300 --borders=8 \
        --column=Option \
        --button="$(gettext "Exit")":1 \
        --button="   $(gettext "Continue")   !$img_cont":0)
    }

    P=4; s=11
    while read item; do
        fonts; mchoise
        if [ $? = 0 ]; then
            if grep -o "$srce" <<< "${dlg}"; then
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
        scoreschk
    else
        step=2; P=2; s=12
        while read item; do
            fonts; mchoise
            if [ $? = 0 ]; then
                if grep -o "$srce" <<< "${dlg}"; then
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
        
        scoreschk
    fi
}

function practice_c() {

    fonts() {
        item="$(grep -F -m 1 "trgt{${trgt}}" "${cfg0}" |sed 's/}/}\n/g')"
        cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
        if [[ ${quest} != 1 ]]; then
            if [[ $p = 2 ]]; then
                [ $tlng = Japanese -o $tlng = Chinese -o $tlng = Russian ] \
                && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt,,}" |awk '$1=$1' FS= OFS=" " |tr aeiouy '.')
            elif [[ $p = 1 ]]; then
                [ $tlng = Japanese -o $tlng = Chinese -o $tlng = Russian ] \
                && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt^}" |sed "s|[a-z]|"\ \."|g")
            fi
        else
            trgt="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
            lst="${trgt}"
        fi
        s=$((30-${#trgt}))
        lquestion="\n\n<span font_desc='Verdana ${s}'><b>${lst}</b></span>\n\n\n"
    }

    question() {
        cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
        (sleep 0.5 && "$DS/play.sh" play_word "${trgt}" ${cdid}) &

        yad --form --title=" " \
        --text="$lquestion" \
        --no-focus --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --image-on-top --undecorated \
        --width=390 --height=260 --borders=10 \
        --field="!$DS/images/listen.png":BTN "$cmd_play" \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "No")  !$img_no":3 \
        --button="  $(gettext "Yes")  !$img_yes":2
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
        scoreschk
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
        
        scoreschk
    fi
}

function practice_d() {

    fonts() {
        [ -e "$DM_tlt/images/${item,,}.jpg" ] && \
        img="$DM_tlt/images/${item,,}.jpg" || \
        img="$DM_tls/images/${item,,}-0.jpg"
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${quest} = 1 ]]; then
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
        else
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
        fi
        [ ! -e "$img" ] && img="$DS/images/imgmiss.jpg"
        cuest="<span font_desc='Arial Bold 12'>${trgt}</span>"
        aswer="<span font_desc='Arial Bold 12'>${srce}</span>"
    }

    question() {
        yad --form --title=" " \
        --image="$img" \
        --no-focus \ --skip-taskbar --text-align=center \
        --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=360 --borders=5 \
        --field="$cuest":lbl "" \
        --button="$(gettext "Exit")":1 \
        --button="  $(gettext "Continue") >>  !$img_cont":0
    }

    answer() {
        yad --form --title=" " \
        --image="$img" \
        --selectable-labels \
        --no-focus --skip-taskbar --text-align=center \
        --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=360 --borders=5 \
        --field="$aswer":lbl "" \
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
        scoreschk
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
        
        scoreschk
    fi
}

function practice_e() {

    dialog2() {
        if [[ ${quest} != 1 ]]; then
            if [ $tlng = Japanese -o $tlng = Chinese -o $tlng = Russian ]; then
                hint=" "
            else
                hint="$(echo "$@" |tr -d "',.;?!¿¡()" |tr -d '"' \
                |awk '{print tolower($0)}' \
                |sed 's/\b\(.\)/\u\1/g' |sed 's/ /      /g' \
                |sed "s|[a-z]|\.|g" \
                |sed 's|\.|\ .|g' \
                |tr "[:upper:]" "[:lower:]" \
                |sed 's/^\s*./\U&\E/g' \
                |sed "s|\.|<span color='#A3A3A3'>\.<\/span>|g")"
            fi
        else
            hint="$(echo "$@")"
        fi
        text="<span font_desc='Serif Bold 14'>$hint</span>\n"
        
        entry=$(>/dev/null | yad --form --title=" " \
        --text="${text}" \
        --name=Idiomind --class=Idiomind \
        --separator="" --focus-field=1 \
        --window-icon=idiomind --image="$DS/images/bar.png" \
        --buttons-layout=end --skip-taskbar \
        --undecorated --center --on-top \
        --align=center --image-on-top \
        --width=550 --height=240 --borders=8 \
        --field="" "" \
        --button="$(gettext "Exit")":1 \
        --button="!$DS/images/listen.png":"$cmd_play" \
        --button="    $(gettext "Check")    ":0)
    }
        
    check() {
        sz=$((sz+3))
        yad --form --title=" " \
        --text="<span font_desc='Free Sans 12'>${wes^}</span>\\n" \
        --name=Idiomind --class=Idiomind \
        --selectable-labels \
        --window-icon=idiomind \
        --skip-taskbar --wrap --image-on-top --center --on-top \
        --undecorated --buttons-layout=end \
        --width=530 --height=230 --borders=14 \
        --field="":lbl "" \
        --field="<span font_desc='Free Sans 9'>$OK\n\n$prc $hits</span>":lbl \
        --button="    $(gettext "Continue")    ":2
    }
    
    get_text() {
        trgt=$(echo "${1}" |sed 's/^ *//;s/ *$//')
        chk=`echo "${trgt}" |awk '{print tolower($0)}'`
        }

    _clean() {
        sed 's/ /\n/g' \
        | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
        | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' \
        | tr -d '|“”&:!'
    }

    result() {
        if [[ $(wc -w <<< "$chk") -gt 6 ]]; then
        out=$(awk '{print tolower($0)}' <<< "${entry}" |_clean |grep -v '^.$')
        in=$(awk '{print tolower($0)}' <<< "${chk}" |_clean |grep -v '^.$')
        else
        out=$(awk '{print tolower($0)}' <<< "${entry}" |_clean)
        in=$(awk '{print tolower($0)}' <<< "${chk}" |_clean)
        fi
        
        echo "${chk}" > ./chk.tmp; touch ./words.tmp
        for line in `sed 's/ /\n/g' <<< "$out"`; do
            if grep -Fxq "${line}" <<< "$in"; then
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
        val1=$(cat ./mtch.tmp |wc -l)
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
        pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${cfg0}" \
        |sed -n 's/^\([0-9]*\)[:].*/\1/p')
        item=$(sed -n ${pos}p "${cfg0}" |sed 's/}/}\n/g')
        if [[ ${quest} = 1 ]]; then
            push=$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")
        else 
            push="${trgt}"; fi
        cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")
        export trgt; get_text "${trgt}"
        cmd_play="$DS/play.sh play_sentence ${cdid}"
        ( sleep 0.5 && "$DS/play.sh" play_sentence ${cdid} ) &

        dialog2 "${push}"
        ret=$?
        if [[ $ret = 1 ]]; then
            break &
            if ps -A |pgrep -f 'play'; then killall play & fi
            export hard ling
            score
        else
            if ps -A |pgrep -f 'play'; then killall play & fi
            result "${trgt}"
        fi

        check "${trgt}"
        ret=$?
        if [[ $ret = 1 ]]; then
            break &
            if ps -A |pgrep -f 'play'; then killall play & fi
            rm -f ./mtch.tmp ./words.tmp
            export hard ling
            score
        elif [[ $ret -eq 2 ]]; then
            if ps -A |pgrep -f 'play'; then killall play & fi
            rm -f ./mtch.tmp ./words.tmp &
        fi
    done < ./e.tmp
    export hard ling
    
    scoreschk
}

function get_list() {
    
    if grep -o -E 'a|b|c' <<< ${pr}; then
        > "${pdir}/${pr}.0"
        if [[ $(wc -l < "${cfg4}") -gt 0 ]]; then
            grep -Fvx -f "${cfg4}" "${cfg1}" > "$DT/${pr}.0"
            sed '/^$/d' < "$DT/${pr}.0" > "${pdir}/${pr}.0"
            rm -f "$DT/${pr}.0"
        else
            sed '/^$/d' < "${cfg1}" > "${pdir}/${pr}.0"
        fi
    
        if [ ${pr} = b ]; then
            if [ ! -e "${pdir}/b.srces" ]; then
            ( echo "5"
            while read word; do
                item="$(grep -F -m 1 "trgt{${word}}" "${cfg0}" |sed 's/}/}\n/g')"
                echo "$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")" >> "${pdir}/b.srces"
            done < "${pdir}/${pr}.0" ) | yad --progress \
            --undecorated \
            --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
    
    elif [ ${pr} = d ]; then
        > "$DT/images"
        if [[ $(wc -l < "${cfg4}") -gt 0 ]]; then
            grep -Fxvf "${cfg4}" "${cfg1}" > "$DT/images"
        else
            cat "${cfg1}" > "$DT/images"
        fi
        > "${pdir}/${pr}.0"
    
        ( echo "5"
        while read -r itm; do
        _item="$(grep -F -m 1 "trgt{${itm}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [ -e "$DM_tls/images/${itm,,}-0.jpg" \
        -o -e "$DM_tlt/images/${itm,,}.jpg" ]; then
            [ -n "${itm}" ] && echo "${itm}" >> "${pdir}/${pr}.0"
        fi
        done < "$DT/images" ) | yad --progress \
        --name=Idiomind --class=Idiomind \
        --undecorated \
        --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        cleanups "$DT/images"
    
    elif [ ${pr} = e ]; then
        if [[ $(wc -l < "${cfg3}") -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            sed '/^$/d' < "$DT/slist" > "${pdir}/${pr}.0"
            rm -f "$DT/slist"
        else
            sed '/^$/d' < "${cfg1}" > "${pdir}/${pr}.0"
        fi
    fi
}

function lock() {
    if [ -e "${pdir}/${pr}.lock" ]; then
        local lock="${pdir}/${pr}.lock"
        if ! grep 'wait' <<< "$(< "${lock}")"; then
            text_dlg="<b>$(gettext "Practice Completed")</b>\\n$(< "${lock}")"
            msg_2 "$text_dlg" \
            dialog-ok-apply "$(gettext "Restart")" "$(gettext "OK")" "$(gettext "Practice Completed")"
            ret=$?
        else
            if [ $(grep -o "wait"=\"[^\"]* "${lock}" |grep -o '[^"]*$') != $(date +%d) ]; then
                rm "${lock}" & return 0
            else
                msg_2 "$(gettext "Consider waiting a while before resuming to practice some items")\n" \
                dialog-information "$(gettext "OK")" "$(gettext "Practice")"
                ret=$?; [ $ret = 1 ] && ret=4 #TODO
            fi
        fi
        if [ $ret -eq 0 ]; then
            cleanups "${lock}" ./${pr}.0 ./${pr}.1 \
            ./${pr}.2 ./${pr}.3 ./${pr}.srces ./${pr}
            echo 1 > ./.${icon}; echo 0 > ./${pr}.l
        elif [ $ret -eq 4 ]; then
            cleanups "${lock}"; return 0
        fi
        strt 0
    fi
}

function decide_group() {
    optns=$(yad --form --title=" " \
    --always-print-result \
    --no-focus --skip-taskbar --undecorated --buttons-layout=spread \
    --align=center --center --on-top --borders=5 \
    --button="$(gettext "Exit")":5 \
    --button="$(gettext "Again")!view-refresh!$(gettext "Go back to practice the above items")":1 \
    --button="$(gettext "Next")!go-next!$(gettext "Practice the next group")":0); ret="$?"

    if [ $ret -eq 0 ]; then
        grep -Fxvf "${pdir}/${pr}.1" "${pdir}/${pr}.group" \
        |sed '/^$/d' > "${pdir}/${pr}.tmp"
        mv -f "${pdir}/${pr}.tmp" "${pdir}/${pr}.group"
        head -n ${split} "${pdir}/${pr}.group" > "${pdir}/${pr}.tmp"
        sed '/^$/d' "${pdir}/${pr}.1" \
        |awk '!a[$0]++' |wc -l > "${pdir}/${pr}.l"
        
    elif [ $ret -eq 1 ]; then
        head -n ${split} "${pdir}/${pr}.group" > "${pdir}/${pr}.tmp"
        grep -Fxvf "${pdir}/${pr}.tmp" "${pdir}/${pr}.1" \
        |sed '/^$/d' > "${pdir}/${pr}.1tmp"
        mv -f "${pdir}/${pr}.1tmp" "${pdir}/${pr}.1"
        sed '/^$/d' "${pdir}/${pr}.1" \
        |awk '!a[$0]++' |wc -l > "${pdir}/${pr}.l"
        easy=0; hard=0; ling=0; step=1
        export easy hard ling step
        
    elif [ $ret -eq 5 ]; then
        score
    fi
}

function practices() {
    log="$DC_s/log"
    cfg0="$DC_tlt/0.cfg"
    cfg1="$DC_tlt/1.cfg"
    cfg3="$DC_tlt/3.cfg"
    cfg4="$DC_tlt/4.cfg"
    hits="$(gettext "hits")"
    touch "${pdir}/log1" "${pdir}/log2" "${pdir}/log3"
    pr="${1}"
    group=""; split=""; quest=""
    if [ -f "${pdir}/$pr" ]; then 
        optns="$(cat "${pdir}/$pr")"
        group="$(cut -d "|" -f1 <<< "${optns}")"
        split="$(cut -d "|" -f2 <<< "${optns}")"
        quest="$(cut -d "|" -f3 <<< "${optns}")"
    fi
    if [ ${pr} = a ]; then icon=1
    elif [ ${pr} = b ]; then icon=2
    elif [ ${pr} = c ]; then icon=3
    elif [ ${pr} = d ]; then icon=4
    elif [ ${pr} = e ]; then icon=5
    else exit; fi
    lock
    
    if [ -e "${pdir}/${pr}.0" -a -e "${pdir}/${pr}.1" ]; then
    
        if [[ ${group} = 1 ]]; then
            head -n ${split} "${pdir}/${pr}.group" \
            |grep -Fxvf "${pdir}/${pr}.1" \
            |sed '/^$/d' > "${pdir}/${pr}.tmp"
        else
            grep -Fxvf "${pdir}/${pr}.1" "${pdir}/${pr}.0" \
            |sed '/^$/d' > "${pdir}/${pr}.tmp"
        fi
        if [[ "$(egrep -cv '#|^$' < "${pdir}/${pr}.tmp")" = 0 ]]; then
            if [[ ${group} = 1 ]]; then 
				export easy=0; decide_group
			else 
				lock
			fi
        fi
    else
        if [ ! -e "${pdir}/${pr}.0" ]; then
  
            optns=$(yad --form --title=" " \
            --always-print-result \
            --no-focus --skip-taskbar --undecorated --buttons-layout=spread \
            --align=center --center --on-top \
            --width=350 --height=105 --borders=5 \
            --field="":CB "$(gettext "Practice all items")!$(gettext "In groups of 10")!$(gettext "In groups of 20")!$(gettext "In groups of 30")" \
            --button="      $(gettext "$slng")      !!$(gettext "Questions in $slng - Answers in $tlng")":3 \
            --button="      $(gettext "$tlng")      !!$(gettext "Questions in $tlng - Answers in $slng")":2); ret="$?"
            if grep '10' <<< "${optns}"; then group=1; split=10;
            elif grep '20' <<< "${optns}"; then group=1; split=20
            elif grep '30' <<< "${optns}"; then group=1; split=30; fi
            if [ "$ret" = 3 ]; then quest=1; else quest=0; fi
            echo -e "$group|$split|$quest" > ${pr}
        fi
        
        export group split quest; get_list
        
        if [[ ${group} = 1 ]]; then
            head -n ${split} "${pdir}/${pr}.0" > "${pdir}/${pr}.tmp"
            cp -f "${pdir}/${pr}.0" "${pdir}/${pr}.group"
        else
            cp -f "${pdir}/${pr}.0" "${pdir}/${pr}.tmp"
        fi
    fi
    
    if [[ $(wc -l < "${pdir}/${pr}.0") -lt 2 ]]; then \
        msg "$(gettext "Insufficient number of items to start")\n" \
        dialog-information " " "$(gettext "OK")"
        strt 0 & return 1
    fi

    cleanups "${pdir}/${pr}.2" "${pdir}/${pr}.3"
    all=$(egrep -cv '#|^$' ./${pr}.0)
    img_cont="$DS/images/cont.png"
    img_no="$DS/images/no.png"
    img_yes="$DS/images/yes.png"
    easy=0; hard=0; ling=0; step=1
    export easy hard ling step
    practice_${pr}
}

function strt() {
    [ ! -d "${pdir}" ] && mkdir -p "${pdir}"
    cd "${pdir}"
    [ ! -e ./.1 ] && echo 1 > .1
    [ ! -e ./.2 ] && echo 1 > .2
    [ ! -e ./.3 ] && echo 1 > .3
    [ ! -e ./.4 ] && echo 1 > .4
    [ ! -e ./.5 ] && echo 1 > .5
    [[ ${hard} -lt 0 ]] && hard=0
    
    if [[ ${step} -gt 1 && ${ling} -ge 1 && ${hard} = 0 ]]; then
        echo -e "wait=\"$(date +%d)\"" > ./${pr}.lock; fi

    if [ ${1} = 1 ]; then
        NUMBER="<span color='#6E6E6E'><b><big>$(wc -l < ${pr}.0)</big></b></span>"; declare info${icon}="<span font_desc='Arial Bold 12'>$(gettext "Test completed") </span> —"
        [ ${pr} = e ] && \
        info="<span font_desc='Arial 11'>$(gettext "Congratulations! You have completed this test of $NUMBER sentences")</span>\n" \
        || info="<span font_desc='Arial 11'>$(gettext "Congratulations! You have completed this test of $NUMBER words")</span>\n"
        echo 21 > .${icon}
    elif [ ${1} = 2 ]; then
        learnt=$(< ./${pr}.l); declare info${icon}="* "
        info="<small>$(gettext "Learnt")</small> <span color='#6E6E6E'><b><big>$learnt </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easy </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$ling </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hard </big></b></span>\n"
    fi

    pr="$(yad --list --title="$(gettext "Practice ")" \
    --text="$info" \
    --class=Idiomind --name=Idiomind \
    --print-column=1 --separator="" \
    --window-icon=idiomind \
    --buttons-layout=edge --image-on-top --center --on-top --text-align=center \
    --ellipsize=NONE --no-headers --expand-column=2 --hide-column=1 \
    --width=${sz[0]} --height=${sz[1]} --borders=10 \
    --column="Action" --column="Pick":IMG --column="Label" \
    "a" "$pdirs/images/$(< ./.1).png" "   $info1  $(gettext "Flashcards")" \
    "b" "$pdirs/images/$(< ./.2).png" "   $info2  $(gettext "Multiple Choice")" \
    "c" "$pdirs/images/$(< ./.3).png" "   $info3  $(gettext "Recognizing Words")" \
    "d" "$pdirs/images/$(< ./.4).png" "   $info4  $(gettext "Images")" \
    "e" "$pdirs/images/$(< ./.5).png" "   $info5  $(gettext "Writing Sentences")" \
    --button="$(gettext "Restart")":3 \
    --button="$(gettext "Start")":0)"
    ret=$?
    unset info info1 info2 info3 info4 info5

    if [ $ret -eq 0 ]; then
        if [ -z "$pr" ]; then
            msg " $(gettext "You must choose a practice.")\n" dialog-information
            strt 0
        else
            practices ${pr}
        fi
    elif [ $ret -eq 3 ]; then
        if [ -d "${pdir}" ]; then
            cd "${pdir}"/; rm ./.[^.]; rm ./*
            touch ./log1 ./log2 ./log3
        fi
        unset pr; strt 0
    else
        "$DS/ifs/tls.sh" colorize 1 & exit
    fi
}

strt 0
