#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
sz=(440 470)
source "$DS/ifs/cmns.sh"
export -f tpc_db
dw=$(date +%W |sed 's/^0*//')
if [[ -n "$1" ]]; then
    tpc="$1"
    DM_tlt="$DM_tl/$1"
    DC_tlt="$DM_tlt/.conf"
    stts=$(< "${DC_tlt}/stts")
    tpcdb="$DC_tlt/tpc"
fi
pdir="${DC_tlt}/practice"
pdirs="$DS/practice"
check_dir "$DC_s/logs"
declare -A prcts=( ['a']='Flashcards' ['b']='Multiple-choice' \
['c']='Recognize Pronunciation' ['d']='Images' ['e']='Listen and Writing Sentences')
t2="<span color='#C15F27' font_desc='Verdana 8'>"
t3="<span color='#AE3259' font_desc='Verdana 8'>"

if [ -f "${DC_tlt}/translations/active" ]; then
    act=$(sed -n 1p "${DC_tlt}/translations/active")
    [ -n "$act" ] && slng="$act"
fi
export -f f_lock

# stats for icons 
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
    [ ! -f ./${pr}.l ] && touch ./${pr}.l
    if [[ $(($(< ./${pr}.l)+easy)) -ge ${all} ]]; then
        _log ${pr}; play "$pdirs/all.mp3" &
        echo "1p.$tpc.p1" >> "$log"
        date "+%a %d %B" > ./${pr}.lock
        save_score 0 & echo 21 > .${icon}
        strt 1
    else
        [ -f ./${pr}.l ] && echo $(($(< ./${pr}.l)+easy)) > ./${pr}.l \
        || echo ${easy} > ./${pr}.l; _log ${pr}
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
        save_score 1 & stats; strt 2
    fi
}
    
function save_score() {

    if [[ ${1} = 0 ]]; then 
        > ./${pr}.2; > ./${pr}.3
    fi
    
    [ -f ./*.1 ] && cat ./*.1 > ./log1
    
    if [[ ${step} = 1 ]]; then
        [ -f ./*.2 ] && cat ./*.2 > ./log2
        
    elif [[ ${step} = 2 ]]; then
        [ -f ./*.2 ] && cat ./*.2 > ./log2
        [ -f ./*.3 ] && cat ./*.3 > ./log3
    fi
    
	while read -r rem; do
		if grep -Fxq "${rem}" ./log1; then
			grep -vxF "${rem}" ./log1 > ./rm.tmp
			sed '/^$/d' ./rm.tmp > ./log1
		fi	
	done < <(cat ./log2 ./log3)
	
	while read -r rem; do
		if grep -Fxq "${rem}" ./log2; then
			grep -vxF "${rem}" ./log2 > ./rm.tmp
			sed '/^$/d' ./rm.tmp > ./log2
		fi	
	done < <(cat./log3)
	
	cleanups ./rm.tmp

}

# just for stats
function _log() { 

    if [ ${1} != 'e' ]; then
    
        if [ -f ./${1}.1 ]; then
            echo "w1.$(tr -s '\n' '|' < ./${1}.1).w1.<${stts}>" \
            |sed '/\.\./d' >> "$log"
        fi
        if [ -f ./${1}.2 ]; then
            if [ -f ./${1}.3 ]; then
                lg2="$(grep -Fvxf ./${1}.3 < ./${1}.2)"
                [ -n "${lg2}" ] && erw="${t2} </span> " || erw=""
                lg3="$(< ./${1}.3)"
                echo "w2.$(tr -s '\n' '|' <<< "${lg2}").w2.<${stts}>" |sed '/\.\./d' >> "$log"
                echo "w3.$(tr -s '\n' '|' <<< "${lg3}").w3.<${stts}>" |sed '/\.\./d' >> "$log"
                i2="${t2}$(echo "${lg2}" |head -n8 |sed -e ':a;N;$!ba;s/\n/  /g')</span>"
                i3="${t3}$(echo "${lg3}" |head -n8 |sed -e ':a;N;$!ba;s/\n/  /g')</span>"
                echo -n "${i2}${erw}${i3}" > ./${1}.df
            else
                lg2="$(< ./${1}.2)"
                echo "w2.$(tr -s '\n' '|' <<< "${lg2}").w2.<${stts}>" |sed '/\.\./d' >> "$log"
                i2="$t2$(echo "${lg2}" |head -n16 |sed -e ':a;N;$!ba;s/\n/  /g') </span>"
                echo -n "${i2}" > ./${1}.df
            fi
        elif [ -f ./${1}.3 ]; then
            lg3="$(< ./${1}.3)"
            echo "w3.$(tr -s '\n' '|' <<< "${lg3}").w3.<${stts}>" |sed '/\.\./d' >> "$log"
            i3="$t3$(head -n16 <<< "${lg3}") |sed -e ':a;N;$!ba;s/\n/  /g')</span>"
            echo -n "${i3}" > ./${1}.df
        fi

    elif [ ${1} = 'e' ]; then
        if [ -f ./${1}.1 ]; then
            echo "s1.$(tr -s '\n' '|' < ./${1}.1).s1.<${stts}>" |sed '/\.\./d' >> "$log"
        fi
        if [ -f ./${1}.2 ]; then
            echo "s2.$(tr -s '\n' '|' < ./${1}.2).s2.<${stts}>" |sed '/\.\./d' >> "$log"
        fi
        if [ -f ./${1}.3 ]; then
            echo "s3.$(tr -s '\n' '|' < ./${1}.3).s3.<${stts}>" |sed '/\.\./d' >> "$log"
        fi
    fi
}

# practice A
function practice_a() {
    fonts() {
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} != 1 ]]; then
            trgt="${item}"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"
        else
            srce="${item}"
            trgt="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"
        fi
        trgt_f_c=$((38-${#trgt}))
        trgt_f_a=$((18-${#trgt}))
        srce_f_a=$((38-${#srce}))
        [ ${trgt_f_c} -lt 12 ] && trgt_f_c=12
        [ ${trgt_f_a} -lt 12 ] && trgt_f_a=12
        [ ${srce_f_a} -lt 12 ] && srce_f_a=12
        question="\n<span font_desc='Arial Bold ${trgt_f_c}'>${trgt}</span>"
        answer1="\n<span font_desc='Arial Bold ${trgt_f_a}'>${trgt}</span>\n"
        answer2="<span font_desc='Arial ${srce_f_a}'><i>${srce}</i></span>"
    }

    question() {
        yad --form --title=" " \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=460 --height=280 --borders=16  \
        --field="\n$question":lbl "" \
        --field="":lbl "" \
        --button="!window-close":1 \
        --button="!media-seek-forward":0
    }

    answer() {
        yad --form --title=" " \
        --skip-taskbar --text-align=center --center --on-top \
        --undecorated --buttons-layout=spread --align=center \
        --width=460 --height=280 --borders=16  \
        --field="$answer1":lbl "" \
        --field="":lbl "" \
        --field="$answer2":lbl "" \
        --button="    $(gettext "I did not know it")   !$img_no":3 \
        --button="    $(gettext "I Knew it")   !$img_yes":2
    }

    while read item; do
        fonts; question
        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score && return
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
    
    if [ ! -f ./a.2 ]; then
        export hard ling; scoreschk
    else
        step=2
        while read item; do
            fonts; question
            if [ $? = 1 ]; then
                export hard ling
                break & score && return
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
        
        export hard ling; scoreschk
    fi
}

# practice B
function practice_b(){
    snd="$pdirs/no.mp3"
    fonts() {
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} != 1 ]]; then
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            ras=$(sort -Ru b.srces |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}));  [ ${srce_s} -lt 12 ] && srce_s=12
            question="\n<span font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
        else
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            ras=$(sort -Ru <<< "${cfg3}" |egrep -v "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt})); [ ${srce_s} -lt 12 ] && srce_s=12
            question="\n<span font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
        fi
    }

    ofonts() {
        while read -r name; do
        echo "<span font_desc='Arial 13'> $name </span>"
        done <<< "${tmp}"
    }

    mchoise() {
        dlg="$(ofonts | yad --list --title=" " \
        --text="${question}" \
        --separator=" " --always-print-result \
        --skip-taskbar --no-scroll --vscroll-policy=never \
        --text-align=center --center --on-top \
        --buttons-layout=edge --undecorated \
        --no-headers --select-action=: \
        --width=450 --height=320 --borders=16 \
        --column=Option \
        --button="!window-close":1 \
        --button="!media-seek-forward":0)"
    }

    P=4; s=11
    while read -r item; do
        fonts; mchoise; ret=$?
        if [ $ret = 0 ]; then
            if grep -o "$srce" <<< "${dlg}"; then
                echo "${item}" >> b.1
                easy=$((easy+1))
            else
                (play "$snd" & echo "${item}" >> b.2)
                hard=$((hard+1))
            fi
        elif [ $ret = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score && return
        fi
    done < ./b.tmp
    
    if [ ! -f ./b.2 ]; then
        export hard ling; scoreschk
    else
        step=2; P=2; s=12
        while read -r item; do
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
                break & score && return
            fi
        done < ./b.2
        
        export hard ling; scoreschk
    fi
}

# practice C
function practice_c() {

    fonts() {
        item="$(grep -F -m 1 "trgt{${trgt}}" "${cfg0}" |sed 's/}/}\n/g')"
        cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
        if [[ ${lang_question} != 1 ]]; then
            if [[ $p = 2 ]]; then
                if grep -o -E 'Japanese|Chinese|Russian' <<< ${tlng}; then
                    lst="${trgt:0:1} ${trgt:5:5}"
                else
                    lst=$(echo "${trgt,,}" |awk '$1=$1' FS= OFS=" " |tr aeiouy '.')
                fi
            elif [[ $p = 1 ]]; then
                if grep -o -E 'Japanese|Chinese|Russian' <<< ${tlng}; then
                    lst="${trgt:0:1} ${trgt:5:5}"
                else
                    lst=$(echo "${trgt^}" |sed "s|[a-z]|"\ \."|g")
                fi
            fi
        else
            local trgt="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
            lst="<span color='#757575'>${trgt}</span>"
        fi
        s=$((30-${#trgt}));  [ ${s} -lt 12 ] && s=12
        lquestion="\n<span color='#818181' font_desc='Verdana ${s}'><b>${lst}</b></span>\n\n"
    }

    question() {
        cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
        (sleep 0.5 && "$DS/play.sh" play_word "${trgt}" ${cdid}) &

        yad --form --title=" " \
        --text="<small><small>$(gettext "Do you recognize this word?")</small></small>\n\n$lquestion" \
        --skip-taskbar --text-align=center --center --on-top \
        --buttons-layout=edge --image-on-top --undecorated \
        --width=450 --height=270 --borders=16 \
        --button="!window-close":1 \
        --button="      $(gettext "No")     !$img_no":3 \
        --button="      $(gettext "Yes")    !$img_yes":2 \
        --button="!audio-volume-high":"$cmd_play"
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
            break & score && return
        fi
    done < ./c.tmp
    
    if [ ! -f ./c.2 ]; then
        export hard ling; scoreschk
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
                break & score && return
            fi
        done < ./c.2
        
        export hard ling; scoreschk
    fi
}

# practice D
function practice_d() {

    fonts() {
        [ -f "$DM_tlt/images/${item,,}.jpg" ] && \
        img="$DM_tlt/images/${item,,}.jpg" || \
        img="$DM_tls/images/${item,,}-1.jpg"
        _item="$(grep -F -m 1 "trgt{${item}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} = 1 ]]; then
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
        else
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
        fi
        [ ! -f "$img" ] && img="$DS/images/imgmiss.jpg"
        cuest="<span font_desc='Arial Bold 12'> ${trgt} </span>\n"
        aswer="<span font_desc='Arial Bold 12'> ${trgt}</span> <i>/ ${srce}</i> \n"
    }

    question() {
        yad --form --title=" " \
        --image="$img" \
        --skip-taskbar --text-align=center \
        --skip-taskbar --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=16 \
        --field="$cuest":lbl "" \
        --field="":lbl "" \
        --button="!window-close":1 \
        --button="!media-seek-forward":0
    }

    answer() {
        yad --form --title=" " \
        --image="$img" \
        --skip-taskbar --text-align=center \
        --align=center --center --on-top \
        --image-on-top --undecorated --buttons-layout=spread \
        --width=418 --height=370 --borders=16 \
        --field="$aswer":lbl "" \
        --field="":lbl "" \
        --button="$(gettext "I did not know it")!$img_no":3 \
        --button="$(gettext "I Knew it")!$img_yes":2
    }
    
    while read -r item; do
        fonts; question
        if [ $? = 1 ]; then
            ling=${hard}; hard=0
            export hard ling
            break & score && return
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
    
    if [ ! -f ./d.2 ]; then
        export hard ling; scoreschk
    else
        step=2
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export hard ling
                break & score && return
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
        
        export hard ling; scoreschk
    fi
}

# practice E
function practice_e() {
    
    dialog2() {
        if [[ ${lang_question} != 1 ]]; then
            if grep -o -E 'Japanese|Chinese|Russian' <<< ${tlng}; then
                hint=" "
            else
                hint="$(echo "$@" |tr -d "',.;?!¿¡()" |tr -d '"' \
                |awk '{print tolower($0)}' \
                |sed 's/\b\(.\)/\u\1/g' |sed 's/ /      /g' \
                |sed "s|[a-z]|\.|g" \
                |sed 's|\.|\ .|g' \
                |sed 's/^\s*./\U&\E/g' \
                |sed "s|\.|<span color='#868686'>\.<\/span>|g")"
            fi
        else
            hint="$(echo "$@")"
        fi
        text="<small><small>$(gettext "Listen and then try to write this sentence")</small></small>\n\n<span color='#818181' font_desc='Verdana Bold 12'>$hint</span>\n"
        
        entry=$(>/dev/null |yad --form --title=" " \
        --text="${text}" \
        --name=Idiomind --class=Idiomind \
        --separator="" --focus-field=1 \
        --window-icon=$DS/images/logo.png \
        --image="$DS/images/bar.png" \
        --buttons-layout=end --skip-taskbar \
        --undecorated --center --on-top \
        --align=center --image-on-top \
        --width=560 --height=250 --borders=16 \
        --field="" "" \
        --button="!window-close":1 \
        --button="!audio-volume-high":"$cmd_play" \
        --button="!media-seek-forward":0)
    }
        
    check() {
        sz=$((sz+3))
        yad --form --title=" " \
        --text="<small><small>$(gettext "Result:")</small></small>\n\n<span font_desc='Arial 12'>${wes^}</span>\\n" \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind \
        --skip-taskbar --wrap --image-on-top --center --on-top \
        --undecorated --buttons-layout=end \
        --width=560 --height=250 --borders=16 \
        --field="":lbl "" \
        --field="<span font_desc='Arial 7'>$OK\n\n$prc $hits</span>":lbl \
        --button="!audio-volume-high":"$cmd_play" \
        --button="!media-seek-forward":2
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
                [ -n "${line}" ] && echo "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
                [ -n "${line}" ] && echo "${line}" >> ./mtch.tmp
            else
                [ -n "${line}" ] && echo "<span color='#984C42'><b>${line^}</b></span>  " >> ./words.tmp
            fi
        done
        OK=$(tr '\n' ' ' < ./words.tmp)
        sed 's/ /\n/g' < ./chk.tmp > ./all.tmp; touch ./mtch.tmp
        val1=$(< ./mtch.tmp |wc -l)
        val2=$(wc -l < ./all.tmp)
        porc=$((100*val1/val2))
        
        if [ ${porc} -ge 70 ]; then
            echo "${trgt}" >> ./e.1
            export easy=$((easy+1))
            color="#3AB452"
        elif [ ${porc} -ge 50 ]; then
            echo "${trgt}" >> ./e.2
             export ling=$((ling+1))
            color="#E5801D"
        else
            [ -n "$entry" ] && echo "${trgt}" >> ./e.3
            [ -n "$entry" ] && export hard=$((hard+1))
            color="#D11B5D"
        fi
        prc="<b>$porc%</b>"
        wes="$(< ./chk.tmp)"
        rm ./chk.tmp
        }
    
    step=2
    while read -r trgt; do
        pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
        item=$(sed -n ${pos}p "${cfg0}" |sed 's/}/}\n/g')
        if [[ ${lang_question} = 1 ]]; then
            push=$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")
        else 
            push="${trgt}"; fi
        cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")
        export trgt; get_text "${trgt}"
        cmd_play="$DS/play.sh play_sentence ${cdid}"
        ( sleep 0.5 && "$DS/play.sh" play_sentence ${cdid} ) &

        dialog2 "${push}"
        ret=$?
        if [ $ret = 1 ]; then
            break &
            if ps -A |pgrep -f 'play'; then killall play & fi
            export hard ling
            score && return
        else
            if ps -A |pgrep -f 'play'; then killall play & fi
            result "${trgt}"
            check "${trgt}"
            ret=$?
            if [ $ret = 1 ]; then
                break &
                if ps -A |pgrep -f 'play'; then killall play & fi
                rm -f ./mtch.tmp ./words.tmp
                export hard ling
                score && return
            elif [ $ret -eq 2 ]; then
                if ps -A |pgrep -f 'play'; then killall play & fi
                rm -f ./mtch.tmp ./words.tmp &
            fi
        fi
    done < ./e.tmp
    
    export hard ling; scoreschk
}

function get_list() {
    
    if grep -o -E 'a|b|c' <<< ${pr}; then
        > "${pdir}/${pr}.0"
        if [[ $(wc -l <<< "${cfg4}") -gt 0 ]]; then
            grep -Fvx "${cfg4}" <<< "${cfg1}" > "$DT/${pr}.0"
            sed '/^$/d' < "$DT/${pr}.0" > "${pdir}/${pr}.0"
            rm -f "$DT/${pr}.0"
        else
            sed '/^$/d' <<< "${cfg1}" > "${pdir}/${pr}.0"
        fi
        if [ ${pr} = b ]; then
            if [ ! -f "${pdir}/b.srces" ]; then
            (echo "#"
            while read word; do
                item="$(grep -F -m 1 "trgt{${word}}" "${cfg0}" |sed 's/}/}\n/g')"
                echo "$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")" >> "${pdir}/b.srces"
            done < "${pdir}/${pr}.0") | yad --progress \
            --undecorated --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
    elif [ ${pr} = d ]; then
        > "$DT/images"
        if [[ $(wc -l <<< "${cfg4}") -gt 0 ]]; then
            grep -Fxv "${cfg4}" <<< "${cfg1}" > "$DT/images"
        else
            echo "${cfg1}" > "$DT/images"
        fi
        > "${pdir}/${pr}.0"
    
        (echo "#"
        while read -r itm; do
        _item="$(grep -F -m 1 "trgt{${itm}}" "${cfg0}" |sed 's/}/}\n/g')"
        if [ -f "$DM_tls/images/${itm,,}-1.jpg" \
        -o -f "$DM_tlt/images/${itm,,}.jpg" ]; then
            [ -n "${itm}" ] && echo "${itm}" >> "${pdir}/${pr}.0"
        fi
        done < "$DT/images") | yad --progress \
        --undecorated --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        cleanups "$DT/images"
    elif [ ${pr} = e ]; then
        if [[ $(wc -l <<< "${cfg3}") -gt 0 ]]; then
            grep -Fxv "${cfg3}" <<< "${cfg1}" > "$DT/slist"
            sed '/^$/d' < "$DT/slist" > "${pdir}/${pr}.0.tmp"
            rm -f "$DT/slist"
        else
            sed '/^$/d' <<< "${cfg1}" > "${pdir}/${pr}.0.tmp"
            
        fi
         inf=0; while read -r itm; do
            cnt="$(echo "$itm" |wc -c)"
            if [ ${cnt} -lt 90 ]; then
                echo "$itm" >> "${pdir}/${pr}.0"
            else
                inf=1
            fi
        done < "${pdir}/${pr}.0.tmp"
        if [ ${inf} = 1 ]; then
            msg "$(gettext "Some sentences could not be added because they are too long")\n" info
        fi
        > "${pdir}/${pr}.1"
    fi
}

function lock() {
    if [ -f "${pdir}/${pr}.lock" ]; then
        local lock="${pdir}/${pr}.lock"
        if ! grep 'wait' <<< "$(< "${lock}")"; then
            text_dlg="<b>$(gettext "Practice Completed")</b>\\n$(< "${lock}")"
            msg_2 "$text_dlg" \
            "$DS/images/practice/21.png" "$(gettext "Restart")" "$(gettext "OK")" "$(gettext "Practice Completed")"
            ret=$?
        else
            if [ $(grep -o "wait"=\"[^\"]* "${lock}" |grep -o '[^"]*$') != $(date +%d) ]; then
                rm "${lock}" & return 0
            else
                msg_2 "$(gettext "Consider waiting a while before resuming to practice some notes") \n" \
                dialog-information "$(gettext "OK")" "$(gettext "Practice")"
                ret=$?; [ $ret = 1 ] && ret=4; [ $ret = 0 ] && ret=5
            fi
        fi
        if [ $ret -eq 0 ]; then
            cleanups "${lock}" ./${pr}.0 ./${pr}.1 \
            ./${pr}.2 ./${pr}.3 ./${pr}.srces ./${pr} ./${pr}.df
            echo 1 > ./.${icon}; echo 0 > ./${pr}.l
        elif [ $ret -eq 4 ]; then
            cleanups "${lock}"
            return 0
        fi
        strt 0
    fi
}

function decide_group() {
    [ -f ./${pr}.l ] && learnt=$(($(< ./${pr}.l)+easy)) || learnt=${easy}
    preeasy=$((learnt+easy)); left=$((all-learnt))
    if [[ ${easy} = 10 ]]; then
        cleanups ./${pr}.df; export plus${pr}=""
    fi
    
    info="<small>$(gettext "Left")</small>  <b><big>$left</big></b>    <small>$(gettext "Learnt")</small>  <b><big>$learnt</big></b>    <small>$(gettext "Easy")</small>  <b><big>$easy</big></b>    <small>$(gettext "Learning")</small>  <b><big>$ling</big></b>    <small>$(gettext "Difficult")</small>  <b><big>$hard</big></b>"
    
    optns=$(yad --form --title="$(gettext "Learning Mode")" \
    --window-icon=$DS/images/logo.png \
    --always-print-result \
    --skip-taskbar  --fixed --buttons-layout=spread \
    --align=center --text-align=center --center --on-top \
    --text="${info}" "" \
    --width=450 --height=120 --borders=12 \
    --button="$(gettext "Again")!view-refresh!$(gettext "Go back to practice the above notes")":1 \
    --button="$(gettext "Continue")!go-next!$(gettext "Practice the next group")":0); ret="$?"
    
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
        export easy=0 hard=0 ling=0 step=1
    elif [ $ret -gt 1 ]; then
        score && return
    fi
}

function practices() {
    pr=${1}
    log="$DC_s/logs/$dw.log"
    cfg0="$DC_tlt/data"
    cfg4="$(tpc_db 5 sentences)"
    cfg3="$(tpc_db 5 words)"
    cfg1="$(tpc_db 5 learning)"
    hits="$(gettext "hits")"
    touch "${pdir}/log1" "${pdir}/log2" "${pdir}/log3"
    export easy=0 hard=0 ling=0 step=1
    group=""; split=""; lang_question=""
    if [ -f "${pdir}/$pr" ]; then 
    optns="$(< "${pdir}/$pr")"
    group="$(cut -d "|" -f1 <<< "${optns}")"
    split="$(cut -d "|" -f2 <<< "${optns}")"
    lang_question="$(cut -d "|" -f3 <<< "${optns}")"
    fi
    if [ ${pr} = a ]; then icon=1; title_act_pract="- $(gettext "Flashcards")"
    elif [ ${pr} = b ]; then icon=2; title_act_pract="- $(gettext "Multiple-choice")"
    elif [ ${pr} = c ]; then icon=3; title_act_pract="- $(gettext "Recognize Pronunciation")"
    elif [ ${pr} = d ]; then icon=4; title_act_pract="- $(gettext "Images")"
    elif [ ${pr} = e ]; then icon=5; title_act_pract="- $(gettext "Listen and Writing Sentences")"
    else exit; fi
    lock
    
    if [ -f "${pdir}/${pr}.0" ] && [ -f "${pdir}/${pr}.1" ]; then
    
        export all=$(egrep -cv '#|^$' "${pdir}/${pr}.0")
    
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
        if [ ! -f "${pdir}/${pr}.0" ]; then
            optns=$(yad --form --title="$(gettext "Starting")" \
            --always-print-result \
            --window-icon=$DS/images/logo.png \
            --skip-taskbar --buttons-layout=spread \
            --align=center --center --on-top \
            --width=420 --height=120 --borders=10 \
            --field=" $(gettext "Learning mode, practice in sets of 10 notes")":CHK "" \
            --field=" ":LBL "" \
            --field=" $(gettext "Choose the challenge language:")\n":LBL "" \
            --button="      $(gettext "$slng")      !!$(gettext "Questions in") $(gettext "$slng") / $(gettext "Answers in") $(gettext "$tlng")":3 \
            --button="      $(gettext "$tlng")      !!$(gettext "Questions in") $(gettext "$tlng") / $(gettext "Answers in") $(gettext "$slng")":2); ret="$?"
            
            if [ $ret = 3 -o $ret = 2 ]; then
                if grep 'TRUE' <<< "${optns}"; then group=1; split=10; fi
                if [ $ret = 3 ]; then lang_question=1; else lang_question=0; fi
                
                echo -e "$group|$split|$lang_question" > ${pr}
            else
                strt & return
            fi
        fi
        
        export group split lang_question; get_list
        
        if [[ ${group} = 1 ]]; then
            head -n ${split} "${pdir}/${pr}.0" > "${pdir}/${pr}.tmp"
            cp -f "${pdir}/${pr}.0" "${pdir}/${pr}.group"
        else
            cp -f "${pdir}/${pr}.0" "${pdir}/${pr}.tmp"
        fi
        export all=$(egrep -cv '#|^$' "${pdir}/${pr}.0")
    fi
    if [[ ${all} -lt 1 ]]; then
        if [ "$(egrep -cv '#|^$' <<< "${cfg1}")" -lt 1 ]; then
            msg "$(gettext "There are not enough notes to practice.") \n" \
            dialog-information " " "$(gettext "OK")"
        elif grep -o -E 'a|b|c|d' <<< ${pr}; then
            msg "$(gettext "There are not enough words for this practice in the \"Learning\" list"). \n" \
            dialog-information " " "$(gettext "OK")"
        elif grep -o 'e' <<< ${pr}; then
            msg "$(gettext "There are not enough sentences for this practice in the \"Learning\" list"). \n" \
            dialog-information " " "$(gettext "OK")"
        fi
        strt 0 & return
    else
        cleanups "${pdir}/${pr}.2" "${pdir}/${pr}.3"
        img_cont="$DS/images/cont.png"
        img_no="$DS/images/nou.png"
        img_yes="$DS/images/yes.png"
        echo "0p.$tpc.p0" >> "$log"
        practice_${pr}
    fi
}

function strt() {
	
    check_dir "${pdir}"
    cd ~ && cd "${pdir}"

    for i in {1..5}; do
        if [ ! -f ./.${i} ]; then
        echo 1 > ./.${i}
        fi
    done
    [[ ${hard} -lt 0 ]] && hard=0
    if [[ ${step} -gt 1 ]] && [[ ${ling} -ge 1 ]] && \
    [[ ${hard} = 0 ]] && [[ ${group} != 1 ]]; then
        echo -e "wait=\"$(date +%d)\"" > ./${pr}.lock
    fi
    for i in a b c d; do
        if [ -f ./${i}.df ]; then
        declare plus${i}=" /  $(< ./${i}.df)"
        fi
    done
    
    #------
    include "$DS/ifs/mods/practice"
    
    if [[ "${1}" = 1 ]]; then
        NUMBER="$(wc -l < ${pr}.0)"
        declare congr${icon}="<span font_desc='Arial Bold 12'>  —  $(gettext "Test completed") </span>"
        [[ "${pr}" = e ]] && \
        info="\n<span font_desc='Arial Bold 11'>$(gettext "Congratulations, You have completed a test of") $NUMBER $(gettext "sentences!")</span>\n" \
        || info="\n<span font_desc='Arial Bold  11'>$(gettext "Congratulations, You have completed a test of") $NUMBER $(gettext "words!")</span>\n"
        echo 21 > .${icon}; export plus${pr}=""; [ -f ./${pr}.df ] && rm ./${pr}.df
        align=left
    elif [[ "${1}" = 2 ]]; then
        learnt=$(< ./${pr}.l); declare info${icon}="  *  "
        info=" <b><small>$(gettext "Learnt")</small> <b>$learnt</b>    <small>$(gettext "Easy")</small> <b>$easy</b>    <small>$(gettext "Learning")</small> <b>$ling</b>    <small>$(gettext "Difficult")</small> <b>$hard</b></b>  \n"
        align=right
    fi
	[ -z $all ] && t="$(gettext "Practice ") - $tpc" || t="$(gettext "Practice ") -  $all $(gettext "notes")"
    pr="$(yad --list --title="$t"\
    --text="${info}" \
    --class=Idiomind --name=Idiomind \
    --print-column=1 --separator="" \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=edge --image-on-top --center --on-top --text-align=$align \
    --no-headers --expand-column=3 --hide-column=1 \
    --width=${sz[0]} --height=${sz[1]} --borders=10 \
    --ellipsize=end --wrap-width=200 --ellipsize-cols=1 \
    --column="Action" --column="Pick":IMG --column="Label" \
    "a" "$DS/images/practice/$(< ./.1).png" "$info1$(gettext "Flashcards")$congr1 <small>$plusa</small>"  \
    "b" "$DS/images/practice/$(< ./.2).png" "$info2$(gettext "Multiple-choice")$congr2 <small>$plusb</small>" \
    "c" "$DS/images/practice/$(< ./.3).png" "$info3$(gettext "Recognize Pronunciation")$congr3 <small>$plusc</small>" \
    "d" "$DS/images/practice/$(< ./.4).png" "$info4$(gettext "Images")$congr4 <small>$plusd</small>" \
    "e" "$DS/images/practice/$(< ./.5).png" "$info5$(gettext "Listen and Writing Sentences")$congr5" \
    --button="$(gettext "Restart")":3 \
    --button="$(gettext "Start")":0)"
    ret=$?
    unset info info1 info2 info3 info4 info5 title_act_pract \
    congr1 congr2 congr3 congr4 congr5

    if [ $ret -eq 0 ]; then
        if [ -z "$pr" ]; then
            msg " $(gettext "You must choose a practice.")\n" dialog-information
            strt 0
        else
            practices ${pr}
        fi
    elif [ $ret -eq 3 ]; then
        unset plusa plusb plusc plusd pr
        if [ -d "${pdir}" ]; then
            cd "${pdir}"/; rm ./.[^.]; rm ./*
            touch ./log1 ./log2 ./log3
        fi
        strt 0
    else
        if [ "${1}" = 2 ]; then
            if [[ -z "$(cdb ${shrdb} 8 T8 list "${tpc}")" ]]; then
                cdb ${shrdb} 2 T8 list "${tpc}"
            fi
        elif [ "${1}" = 1 ]; then
            cdb ${shrdb} 4 T8 list "${tpc}"
        fi &
        idiomind tasks
        "$DS/ifs/tls.sh" colorize 1 & exit 0
    fi
}

touch "${DM_tlt}"
strt 0 & exit 0
