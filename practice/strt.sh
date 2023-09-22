#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source $DS/default/sets.cfg
sz=(440 470)
source "$DS/ifs/cmns.sh"
export -f tpc_db
date_week=$(date +%W |sed 's/^0*//')

if [[ -n "$1" ]]; then
    tpc="$1"
    DM_tlt="$DM_tl/$1"
    DC_tlt="$DM_tlt/.conf"
    stts=$(< "${DC_tlt}/stts")
    tpcdb="$DC_tlt/tpc"
fi
dir_practice="${DC_tlt}/practice"
dir_practices="$DS/practice"
check_dir "$DC_s/logs"
Level="$(cdb "${cfgdb}" 1 opts level)"
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
            echo ${n} > .${icon}; break
        fi
        (( c=c+5 ))
        (( n++ ))
    done
}

function scoreschk() {
    if [[ ${group} = 1 ]]; then
        decide_group
        if [ $ret = 1 ]; then
            practices $active_practice
        elif [ $ret = 0 ]; then
            if [[ "$(grep -Ecv '#|^$' < "${dir_practice}/$active_practice.group")" = 0 ]]; then
                export group=0; score
            else
                practices $active_practice
            fi
        fi
    else
        score
    fi
}

function score() {
    rm ./*.tmp
    [ ! -f ./$active_practice.l ] && touch ./$active_practice.l
    if [[ $(($(< ./$active_practice.l)+count_easy)) -ge ${count_seccion_active_practice} ]] && \
    [[ ${count_seccion_active_practice} -gt 0 ]]; then
		cleanups ./$active_practice.0
		> ./$active_practice.2; > ./$active_practice.3
        _log $active_practice; play "$dir_practices/all.mp3" &
        echo "1p.$tpc.p1" >> "$log"
        date "+%a %d %B" > ./$active_practice.lock
        [ -f ./$active_practice.df ] && rm ./$active_practice.df
        save_score 0 & echo 21 > .${icon}
        strt 1
    else
        [ -f ./$active_practice.l ] && echo $(($(< ./$active_practice.l)+count_easy)) > ./$active_practice.l \
        || echo ${count_easy} > ./$active_practice.l; _log $active_practice
        s=$(< ./$active_practice.l)
        v=$((100*s/count_seccion_active_practice))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then
                echo $((n-1)) > .${icon}; break
            elif [ ${v} -le ${c} ]; then
                echo ${n} > ./.${icon}; break
            fi
            (( c=c+5 ))
            (( n++ ))
        done
        save_score 1 & stats
        strt 2
    fi
}

function save_score() {

    > ./log1
    if [ $(ls *.1 | wc -l) -ge 3  ]; then # si hay 3 o mas practicas con notas aprendidas
    	while read -r note; do
			[ $(grep "$note" *.1 | wc -l) -ge 3 ] && echo "$note" >> ./log1 # se listan solo las notas que han pasado mas 3 practicas
		done <<< $(sort -u *.1) # se listan las notas de la lista "aprendiendo"
	fi
	
	if [[ -f ./e.1 ]]; then sort -u ./e.1 >> ./log1; fi
	if ls ./*.2 >/dev/null 2>&1; then sort -u ./*.2 > ./log2; fi
	if ls ./*.3 >/dev/null 2>&1; then sort -u ./*.3 > ./log3; fi

    if [[ ${step} = 3 ]]; then # si se ha llegado al nivel 3 (palabras dificiles de aprender)
 
        while read -r rem; do # se quitan todas las notas del nivel 2 que estan en el nivel 3
			if grep -Fxq "${rem}" ./log2; then
				grep -vxF "${rem}" ./log2 >> ./rm.tmp
			fi	
		done < ./log3
		sed '/^$/d' ./rm.tmp | sort -u > ./log2
		[ -f ./rm.tmp ] && rm ./rm.tmp
	fi
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
        _item="$(grep -F -m 1 "trgt{${item}}" "${list_data}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} != 1 ]]; then
        
            trgt="${item}"
            srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"

            if [ -z "${srce##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				srce="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi

            if [ -z "${srce##+([[:space:]])}" ]; then # busca traduccion en en share db 
				srce="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${trgt^}' limit 1;")"
            fi
        else
            srce="${item}"
            trgt="$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")"
            
            if [ -z "${trgt##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				trgt="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi

            if [ -z "${trgt##+([[:space:]])}" ]; then # busca traduccion en en share db 
				trgt="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${srce^}' limit 1;")"
            fi
        fi
        
        trgt_f_c=$((38-${#trgt}))
        trgt_f_a=$((18-${#trgt}))
        srce_f_a=$((38-${#srce}))
        [ ${trgt_f_c} -lt 12 ] && trgt_f_c=12
        [ ${trgt_f_a} -lt 12 ] && trgt_f_a=12
        [ ${srce_f_a} -lt 12 ] && srce_f_a=12

        if [ $step -eq 2 ]; then 
			question="\n<span color='#E5801D' font_desc='Arial Bold ${trgt_f_c}'>${trgt}</span>"
			answer1="\n<span color='#E5801D' font_desc='Arial Bold ${trgt_f_a}'>${trgt}</span>\n"
        elif [ $step -eq 3 ];then
			question="\n<span color='#D11B5D' font_desc='Arial Bold ${trgt_f_c}'>${trgt}</span>"
			answer1="\n<span color='#D11B5D' font_desc='Arial Bold ${trgt_f_a}'>${trgt}</span>\n"
        else
			question="\n<span font_desc='Arial Bold ${trgt_f_c}'>${trgt}</span>"
			answer1="\n<span font_desc='Arial Bold ${trgt_f_a}'>${trgt}</span>\n"
        fi
        
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

    while read -r item; do
        fonts; question
        if [ $? = 1 ]; then
            count_learn=${count_hard}; count_hard=0
            export count_hard count_learn
            break & score && return
        else
            answer
            ans=$?
            if [ ${ans} = 2 ]; then
                echo "${item}" >> a.1
                count_easy=$((count_easy+1))
            elif [ ${ans} = 3 ]; then
                echo "${item}" >> a.2
                count_hard=$((count_hard+1))
            fi
        fi
    done < ./a.tmp
    
    if [ ! -f ./a.2 ]; then
        export count_hard count_learn; scoreschk
    else
        step=2
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> a.3
                fi
            fi
        done < ./a.2
     fi

     if [ ! -f ./a.3 ]; then
        export count_hard count_learn; scoreschk
    else
        step=3
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> a.3.tmp
                fi
            fi
        done < ./a.3
        
        mv -f a.3.tmp a.3
        export count_hard count_learn; scoreschk
    fi
}

# practice B
function practice_b(){
    snd="$dir_practices/no.mp3"
    fonts() {
        _item="$(grep -F -m 1 "trgt{${item}}" "${list_data}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} != 1 ]]; then
        
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            
            if [ -z "${srce##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				srce="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi
            
            if [ -z "${srce##+([[:space:]])}" ]; then
				srce="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${trgt^}' limit 1;")"
            fi
            
            ras=$(sort -Ru b.srces |grep -Ev "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt}));  [ ${srce_s} -lt 12 ] && srce_s=12
            question="\n<span font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
            if [ $step -eq 2 ]; then 
					question="\n<span color='#E5801D' font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
				elif [ $step -eq 3 ];then
					question="\n<span color='#D11B5D' font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
				else
					question="\n<span font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
			fi
        else
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            
            if [ -z "${trgt##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				trgt="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi
            
            if [ -z "${trgt##+([[:space:]])}" ]; then
				trgt="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${srce^}' limit 1;")"
            fi
            
            ras=$(sort -Ru <<< "${list_words}" |grep -Ev "$srce" |head -${P})
            tmp="$(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')"
            srce_s=$((35-${#trgt})); [ ${srce_s} -lt 12 ] && srce_s=12
            if [ $step -eq 2 ]; then 
				question="\n<span color='#E5801D' font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
				elif [ $step -eq 3 ];then
					question="\n<span color='#D11B5D' font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
				else
					question="\n<span font_desc='Arial ${srce_s}'><b>${trgt}</b></span>\n\n"
			fi
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
                count_easy=$((count_easy+1))
            else
                (play "$snd" & echo "${item}" >> b.2)
                count_hard=$((count_hard+1))
            fi
        elif [ $ret = 1 ]; then
            count_learn=${count_hard}; count_hard=0
            export count_hard count_learn
            break & score && return
        fi
    done < ./b.tmp
    
    if [ ! -f ./b.2 ]; then
        export count_hard count_learn; scoreschk
    else
        step=2; P=2; s=12
        while read -r item; do
            fonts; mchoise
            if [ $? = 0 ]; then
                if grep -o "$srce" <<< "${dlg}"; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                else
                    play "$snd" &
                    echo "${item}" >> b.3
                fi
            elif [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            fi
        done < ./b.2
    fi
    
    if [ ! -f ./b.3 ]; then
        export count_hard count_learn; scoreschk
    else
        step=3; P=2; s=12
        while read -r item; do
            fonts; mchoise
            if [ $? = 0 ]; then
                if grep -o "$srce" <<< "${dlg}"; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                else
                    play "$snd" &
                    echo "${item}" >> b.3.tmp
                fi
            elif [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            fi
        done < ./b.3

		mv -f b.3.tmp b.3
        export count_hard count_learn; scoreschk
    fi
}

# practice C
function practice_c() {

    fonts() {
        item="$(grep -F -m 1 "trgt{${trgt}}" "${list_data}" |sed 's/}/}\n/g')"
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
        
        if [ $step -eq 2 ]; then 
			lquestion="\n<span color='#E5801D' font_desc='Verdana ${s}'><b>${lst}</b></span>\n\n"
		elif [ $step -eq 3 ];then
			lquestion="\n<span color='#D11B5D' font_desc='Verdana ${s}'><b>${lst}</b></span>\n\n"
		else
			lquestion="\n<span color='#989898' font_desc='Verdana ${s}'><b>${lst}</b></span>\n\n"
		fi
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
    while read -r trgt; do
        fonts; question
        ans=$?
        if [ ${ans} = 2 ]; then
            echo "${trgt}" >> c.1
            count_easy=$((count_easy+1))
        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> c.2
            count_hard=$((count_hard+1))
        elif [ ${ans} = 1 ]; then
            count_learn=${count_hard}; count_hard=0
            export count_hard count_learn
            break & score && return
        fi
    done < ./c.tmp
    
    if [ ! -f ./c.2 ]; then
        export count_hard count_learn; scoreschk
    else
        step=2; p=2
        while read -r trgt; do
            fonts; question
            ans=$?
            if [ ${ans} = 2 ]; then
                count_hard=$((count_hard-1))
                count_learn=$((count_learn+1))
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> c.3
            elif [ ${ans} = 1 ]; then
                export count_hard count_learn
                break & score && return
            fi
        done < ./c.2
    fi
    
    if [ ! -f ./c.3 ]; then
        export count_hard count_learn; scoreschk
    else
        step=3; p=2
        while read -r trgt; do
            fonts; question
            ans=$?
            if [ ${ans} = 2 ]; then
                count_hard=$((count_hard-1))
                count_learn=$((count_learn+1))
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> c.3.tmp
            elif [ ${ans} = 1 ]; then
                export count_hard count_learn
                break & score && return
            fi
        done < ./c.3
        
        mv -f c.3.tmp c.3
        export count_hard count_learn; scoreschk
    fi
    
}

# practice D
function practice_d() {

    fonts() {
        [ -f "$DM_tlt/images/${item,,}.jpg" ] && \
        img="$DM_tlt/images/${item,,}.jpg" || \
        img="$DM_tls/images/${item,,}-1.jpg"
        _item="$(grep -F -m 1 "trgt{${item}}" "${list_data}" |sed 's/}/}\n/g')"
        if [[ ${lang_question} != 1 ]]; then
        
            trgt="${item}"
            srce=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            
	        if [ -z "${srce##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				srce="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi
            
            if [ -z "${srce##+([[:space:]])}" ]; then
				srce="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${trgt^}' limit 1;")"
            fi
        else
            srce="${item}"
            trgt=$(grep -oP '(?<=srce{).*(?=})' <<< "${_item}")
            
            if [ -z "${trgt##+([[:space:]])}" ]; then # busca traduccion en en tpc data file 
				trgt="$(grep -o -m 1 "_${trgt}_[^_]*_"  "$list_data" |awk -F '_' '{print $3}' |head -n 1)"
            fi
            
            if [ -z "${trgt##+([[:space:]])}" ]; then
				trgt="$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${srce^}' limit 1;")"
            fi
        fi
        
        [ ! -f "$img" ] && img="$DS/images/imgmiss.jpg"
        cuest="<span font_desc='Arial Bold 12'> ${trgt} </span>\n"
        
        if [ $step -eq 2 ]; then 
			cuest="<span color='#E5801D' font_desc='Arial Bold 12'> ${trgt} </span>\n"
			aswer="<span color='#E5801D' font_desc='Arial Bold 12'> ${trgt}</span> <i>/ ${srce}</i> \n"
		elif [ $step -eq 3 ];then
			cuest="<span color='#D11B5D' font_desc='Arial Bold 12'> ${trgt} </span>\n"
			aswer="<span color='#D11B5D' font_desc='Arial Bold 12'> ${trgt}</span> <i>/ ${srce}</i> \n"
		else
			cuest="<span font_desc='Arial Bold 12'> ${trgt} </span>\n"
			aswer="<span font_desc='Arial Bold 12'> ${trgt}</span> <i>/ ${srce}</i> \n"
		fi
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
            count_learn=${count_hard}; count_hard=0
            export count_hard count_learn
            break & score && return
        else
            answer
            ans=$?
            if [ ${ans} = 2 ]; then
                echo "${item}" >> d.1
                count_easy=$((count_easy+1))
            elif [ ${ans} = 3 ]; then
                echo "${item}" >> d.2
                count_hard=$((count_hard+1))
            fi
        fi
    done < ./d.tmp
    
    if [ ! -f ./d.2 ]; then
        export count_hard count_learn; scoreschk
    else
        step=2
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> d.3
                fi
            fi
        done < ./d.2

    fi
    
    if [ ! -f ./d.3 ]; then
        export count_hard count_learn; scoreschk
    else
        step=3
        while read -r item; do
            fonts; question
            if [ $? = 1 ]; then
                export count_hard count_learn
                break & score && return
            else
                answer
                ans=$?
                if [ ${ans} = 2 ]; then
                    count_hard=$((count_hard-1))
                    count_learn=$((count_learn+1))
                elif [ ${ans} = 3 ]; then
                    echo "${item}" >> d.3.tmp
                fi
            fi
        done < ./d.3
        
        mv -f d.3.tmp d.3
        export count_hard count_learn; scoreschk
    fi
}

# practice E
function practice_e() {
    
    dlg_question() {
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
                |sed "s|\.|<span color='#989898'>\.<\/span>|g")"
            fi
        else
            hint="$@"
        fi
        text="<small><small>$(gettext "Listen and then try to write this sentence")</small></small>\n\n<span color='#818181' font_desc='Verdana Bold 13'>$hint</span>\n"
        
        entry=$(>/dev/null |yad --form --title=" " \
        --text="${text}" \
        --name=Idiomind --class=Idiomind \
        --separator="" --focus-field=1 \
        --window-icon=$DS/images/logo.png \
        --image="$DS/images/bar.png" \
        --buttons-layout=end --skip-taskbar \
        --undecorated --center --on-top \
        --align=center --image-on-top \
        --width=620 --height=250 --borders=15 \
        --field="" "" \
        --button="!window-close":1 \
        --button="!audio-volume-high":"$cmd_play" \
        --button="!media-seek-forward":0)
    }
        
    check() {
        sz=$((sz+3))
        yad --form --title=" " \
        --text="<small><small>$(gettext "Result:")</small></small>\n\n<span font_desc='Arial 15'>${check_trgt_label^}</span>\\n" \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind \
        --skip-taskbar --wrap --image-on-top --center --on-top \
        --undecorated --buttons-layout=end \
        --width=620 --height=250 --borders=15 \
        --field="":lbl "" \
        --field="<span font_desc='Arial 12'>$green_words</span>\n\n<small>$porcent_match_label $hits</small>":lbl \
        --button="!audio-volume-high":"$cmd_play" \
        --button="!media-seek-forward":2
    }
    
    get_text() {
        trgt=$(echo "${1}" |sed 's/^ *//;s/ *$//')
        check_trgt="$(echo "${trgt}" |awk '{print tolower($0)}')"
    }

    _clean() {
        sed 's/ /\n/g' \
        | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
        | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' \
        | tr -d '|“”&:!'
    }

    result() {
        if [[ $(wc -w <<< "$check_trgt") -gt 6 ]]; then
            out=$(awk '{print tolower($0)}' <<< "${entry}" |_clean |grep -v '^.$')
            in=$(awk '{print tolower($0)}' <<< "${check_trgt}" |_clean |grep -v '^.$')
        else
            out=$(awk '{print tolower($0)}' <<< "${entry}" |_clean)
            in=$(awk '{print tolower($0)}' <<< "${check_trgt}" |_clean)
        fi
        echo "${check_trgt}" > ./check_trgt.tmp; touch ./words.tmp
        tr -s '[:space:]' '\n' < check_trgt.tmp > ./all_words.tmp # prepara para listar las palabras para practicar individualmente
        
        for line in $(sed 's/ /\n/g' <<< "$out"); do
            if grep -Fxq "${line}" <<< "$in"; then
                sed -i "s/"${line}"/<b>"${line}"<\/b>/g" ./check_trgt.tmp # TODO
                [ -n "${line}" ] && echo "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
                [ -n "${line}" ] && echo "${line}" >> ./mtch.tmp
            else
                [ -n "${line}" ] && echo "<span color='#984245'><b>${line^}</b></span>  " >> ./words.tmp
            fi
        done
        
        green_words=$(tr '\n' ' ' < ./words.tmp)
        sed 's/ /\n/g' < ./check_trgt.tmp > ./all.tmp
        touch ./mtch.tmp
        val1=$(wc -l < ./mtch.tmp)
        val2=$(wc -l < ./all.tmp)
        porcent_match=$((100*val1/val2))
        
        # lista las palabras para practicar individualmente
        if [ ${porcent_match} -ge 10 ]; then
			vrbl="$(grep -xvf ./mtch.tmp ./all_words.tmp)"
			echo "${vrbl}" |tr -d '.' \
			|tr -d '*)(,;"“”:' |tr -s '_&|{}[]' ' ' \
			|sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
			|sed 's/\]//;s/\[//;s/<[^>]*>//g' |sed "s/'$//;s/^'//" \
			|sed 's/-$//;s/^-//;s/"//g' \
			|sed 's/^ *//; s/ *$//; /^$/d; s/^\(.\)/\U\1/; /^.$/d' \
			|sed 's/ \+/ /g' |sed -e ':a;N;$!ba;s/\n/\n/g' >> ./0.s
        fi

        if [ ${porcent_match} -ge 90 ]; then
            echo "${trgt}" >> ./e.1
            export count_easy=$((count_easy+1))
            color="#3AB452"
        elif [ ${porcent_match} -ge 50 ]; then
            echo "${trgt}" >> ./e.2
             export count_learn=$((count_learn+1))
            color="#E5801D"
        else
            [ -n "$entry" ] && echo "${trgt}" >> ./e.3
            [ -n "$entry" ] && export count_hard=$((count_hard+1))
            color="#D11B5D"
        fi
        porcent_match_label="<b>$porcent_match%</b>"
        check_trgt_label="$(< ./check_trgt.tmp)"
        rm ./check_trgt.tmp
        }
    
    cleanups ./0.s
    step=2
    while read -r trgt; do
        pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${list_data}" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
        item=$(sed -n ${pos}p "${list_data}" |sed 's/}/}\n/g')
        if [[ ${lang_question} = 1 ]]; then
            push=$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")
        else 
            push="${trgt}"
        fi
        cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")
        export trgt
        get_text "${trgt}"
        cmd_play="$DS/play.sh play_sentence ${cdid}"
        ( sleep 0.5 && "$DS/play.sh" play_sentence ${cdid} ) &

        dlg_question "${push}"
        ret=$?
        if [ $ret = 1 ]; then
            break &
            if [ -f "${dir_practice}/0.s" ]; then
			    msg_2 "$(gettext "There are selected words from the sentence practice that can be added to the word practices.")\n" info "$(gettext "No add")" "$(gettext "Add these words")"
			     if [ $? = 0 ]; then
					cleanups "${dir_practice}/0.s"
				 else 
					count_tmp=$(wc -l < "${dir_practice}/0.s")
					notify-send "Idiomind - $(gettext "Notice")" "$count_tmp $(gettext "new words have been added for practice in new sections")" -i info
				fi
		    fi
            if ps -A |pgrep -f 'play'; then killall play & fi
            export count_hard count_learn
            score && return
        else
            if ps -A |pgrep -f 'play'; then killall play & fi
            result "${trgt}"
            check "${trgt}"
            ret=$?
            rm -f ./mtch.tmp ./words.tmp
            if [ $ret = 1 ]; then
                break &
                if ps -A |pgrep -f 'play'; then killall play & fi

                export count_hard count_learn
                score && return
            elif [ $ret -eq 2 ]; then
                if ps -A |pgrep -f 'play'; then killall play & fi
            fi
        fi
    done < ./e.tmp

    export count_hard count_learn
    scoreschk
}

function get_notes() {

	echo -e "\n--- get notes....\t-> $active_practice\n "
    if grep -o -E 'a|b|c' <<< $active_practice; then
        > "${dir_practice}/$active_practice.0"
        if [[ $(wc -l <<< "${list_sents}") -gt 0 ]]; then
            grep -Fvx "${list_sents}" <<< "${list_learn}" > "$DT/$active_practice.0"
            sed '/^$/d' < "$DT/$active_practice.0" > "${dir_practice}/$active_practice.0"
            rm -f "$DT/$active_practice.0"
        else
            sed '/^$/d' <<< "${list_learn}" > "${dir_practice}/$active_practice.0"
        fi

        if [ "$1" = "restart" ] && [ -f "${dir_practice}/0.s" ]; then # si hay palabras no aprendidas desde el test de oraciones
			sort -u < "${dir_practice}/0.s" >> "${dir_practice}/$active_practice.0"
			count_tmp=$(wc -l < "${dir_practice}/0.s")
			notify-send "Idiomind - $(gettext "Notice")" "$count_tmp $(gettext "Selected words from the sentence test have been added to this practice.")" -i info
		fi

        if [ $active_practice = b ]; then
            if [ ! -f "${dir_practice}/b.srces" ]; then
            (echo "#"
            while read -r word; do
                item="$(grep -F -m 1 "trgt{${word}}" "${list_data}" |sed 's/}/}\n/g')"
                grep -oP '(?<=srce{).*(?=})' <<< "${item}" >> "${dir_practice}/b.srces"
            done <<< "${list_words}") | yad --progress \
            --undecorated --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
            #TODO
            if [ -f "${dir_practice}/0.s" ]; then # buscar srces para palabras de las oraciones
				while read -r word; do
					:
				done < "${dir_practice}/0.s"
			fi
        fi
        
    elif [ $active_practice = d ]; then
        > "$DT/images"
        if [[ $(wc -l <<< "${list_sents}") -gt 0 ]]; then
            grep -Fxv "${list_sents}" <<< "${list_learn}" > "$DT/images"
        else
            echo "${list_learn}" > "$DT/images"
        fi
        > "${dir_practice}/$active_practice.0"
    
        (echo "#"
        while read -r itm; do
        _item="$(grep -F -m 1 "trgt{${itm}}" "${list_data}" |sed 's/}/}\n/g')"
        if [ -f "$DM_tls/images/${itm,,}-1.jpg" ] || [ -f "$DM_tlt/images/${itm,,}.jpg" ]; then
            [ -n "${itm}" ] && echo "${itm}" >> "${dir_practice}/$active_practice.0"
        fi
        done < "$DT/images") | yad --progress \
        --undecorated --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        cleanups "$DT/images"
        
    elif [ $active_practice = e ]; then
        if [[ $(wc -l <<< "${list_words}") -gt 0 ]]; then
            grep -Fxv "${list_words}" <<< "${list_learn}" > "$DT/slist"
            sed '/^$/d' < "$DT/slist" > "${dir_practice}/$active_practice.0.tmp"
            rm -f "$DT/slist"
        else
            sed '/^$/d' <<< "${list_learn}" > "${dir_practice}/$active_practice.0.tmp"
        fi
         inf=0
         if [ -s "${dir_practice}/$active_practice.0.tmp" ]; then
			 while read -r itm; do
				if [ ${Level} = 0 ]; then
					if [ $(wc -w <<< "$itm") -le ${sentence_words_level0} ]; then
						echo "$itm" >> "${dir_practice}/$active_practice.0"
					else
						inf=1
					fi
				fi
			done < "${dir_practice}/$active_practice.0.tmp"
		else 
			cleanups "${dir_practice}/$active_practice.0.tmp"
			touch "${dir_practice}/$active_practice.0"
        fi
        
        if [ ${inf} = 1 ]; then
            notify-send "Idiomind - $(gettext "Listen and Writing Sentences")" "$(gettext "Some sentences were set aside because they are too complex for your learning level.")" -i info
        fi
    fi
}

function lock() {
    if [ -f "${dir_practice}/$active_practice.lock" ]; then
        local lock="${dir_practice}/$active_practice.lock"
        if ! grep 'wait' <<< "$(< "${lock}")"; then
            text_dlg="<b>$(gettext "Practice Completed")</b>\\n$(< "${lock}")"
            msg_2 "$text_dlg" \
            "$DS/images/practice/21.png" "$(gettext "Restart")" "$(gettext "OK")" "$(gettext "Practice Completed")"
            ret=$?
        else
            if [ $(grep -o "wait"=\"[^\"]* "${lock}" |grep -o '[^"]*$') != $(date +%d) ]; then
                rm "${lock}" & strt 0
            else
                msg_2 "$(gettext "Consider waiting a while before resuming to practice some notes") \n" \
                dialog-information "$(gettext "OK")" "$(gettext "Practice")"
                ret=$?
                [ $ret = 0 ] && ret=4
                [ $ret = 1 ] && ret=5
            fi
        fi

        if [ $ret -eq 0 ]; then # restart
            cleanups "${lock}" ./$active_practice.0 ./$active_practice.1 \
            ./$active_practice.2 ./$active_practice.3 ./$active_practice.srces \
            ./$active_practice ./$active_practice.df
            echo 1 > ./.${icon}; echo 0 > ./$active_practice.l
            get_notes restart && strt 0
        elif [ $ret -eq 4 ]; then
            cleanups "${lock}"
            strt 0
            
        elif [ $ret -eq 1 ]; then
			strt 0
        fi

    fi
}

function decide_group() {
    [ -f ./$active_practice.l ] && count_learnt=$(($(< ./$active_practice.l)+count_easy)) || count_learnt=${count_easy}
    precount_easy=$((count_learnt+count_easy)); left=$((count_seccion_active_practice-count_learnt))
    if [[ ${count_easy} = 10 ]]; then
        cleanups ./$active_practice.df; export plus$active_practice=""
    fi
    
    info="$(gettext "Left")  <b><big>$left</big></b>    $(gettext "Learnt")  <b><big>$count_learnt</big></b>    $(gettext "Easy")  <b><big>$count_easy</big></b>    $(gettext "Learning")  <b><big>$count_learn</big></b>    $(gettext "Difficult")  <b><big>$count_hard</big></b>"
    
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
        grep -Fxvf "${dir_practice}/$active_practice.1" "${dir_practice}/$active_practice.group" \
        |sed '/^$/d' > "${dir_practice}/$active_practice.tmp"
        mv -f "${dir_practice}/$active_practice.tmp" "${dir_practice}/$active_practice.group"
        head -n ${split} "${dir_practice}/$active_practice.group" > "${dir_practice}/$active_practice.tmp"
        sed '/^$/d' "${dir_practice}/$active_practice.1" \
        |awk '!a[$0]++' |wc -l > "${dir_practice}/$active_practice.l"
    elif [ $ret -eq 1 ]; then
        head -n ${split} "${dir_practice}/$active_practice.group" > "${dir_practice}/$active_practice.tmp"
        grep -Fxvf "${dir_practice}/$active_practice.tmp" "${dir_practice}/$active_practice.1" \
        |sed '/^$/d' > "${dir_practice}/$active_practice.1tmp"
        mv -f "${dir_practice}/$active_practice.1tmp" "${dir_practice}/$active_practice.1"
        sed '/^$/d' "${dir_practice}/$active_practice.1" \
        |awk '!a[$0]++' |wc -l > "${dir_practice}/$active_practice.l"
        export count_easy=0 count_hard=0 count_learn=0 step=1
    elif [ $ret -gt 1 ]; then
        score && strt
    fi
}

function practices() {

    log="$DC_s/logs/$date_week.log"
    export count_check_tasks1="$(grep "1p.$tpc.p1" "$log" | wc -l)"
    list_data="$DC_tlt/data"
    list_sents="$(tpc_db 5 sentences)"
    list_words="$(tpc_db 5 words)"
    list_learn="$(tpc_db 5 learning)"
    hits="$(gettext "hits")"
    touch "${dir_practice}/log1" "${dir_practice}/log2" "${dir_practice}/log3"
    export count_easy=0 count_hard=0 count_learn=0 step=1
    group=""; split=""; lang_question=""

	export count_seccion_active_practice=$(grep -Ecv '#|^$' "${dir_practice}/$active_practice.0")
    if [ ! -f "${dir_practice}/$active_practice" ] && [[ ${count_seccion_active_practice} -gt 0 ]]; then # establecer las opciones de la practica activa si esta contiene notas
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
		
		if [ $ret = 3 ] || [ $ret = 2 ]; then
			if grep 'TRUE' <<< "${optns}"; then group=1; split=10; fi
			if [ $ret = 3 ]; then lang_question=1; else lang_question=0; fi
			echo -e "$group|$split|$lang_question" > $active_practice
		else
			strt & exit
		fi
    fi
    optns="$(< "${dir_practice}/$active_practice")"
    group="$(cut -d "|" -f1 <<< "${optns}")"
    split="$(cut -d "|" -f2 <<< "${optns}")"
    lang_question="$(cut -d "|" -f3 <<< "${optns}")"

    if [ $active_practice = a ]; then icon=1; title_act_pract="- $(gettext "Flashcards")"
    elif [ $active_practice = b ]; then icon=2; title_act_pract="- $(gettext "Multiple-choice")"
    elif [ $active_practice = c ]; then icon=3; title_act_pract="- $(gettext "Recognize Pronunciation")"
    elif [ $active_practice = d ]; then icon=4; title_act_pract="- $(gettext "Images")"
    elif [ $active_practice = e ]; then icon=5; title_act_pract="- $(gettext "Listen and Writing Sentences")"
    else exit; fi
    lock
    
    if [ -f "${dir_practice}/$active_practice.0" ] && [ -f "${dir_practice}/$active_practice.1" ]; then

        if [[ ${group} = 1 ]]; then
            head -n ${split} "${dir_practice}/$active_practice.group" \
            |grep -Fxvf "${dir_practice}/$active_practice.1" \
            |sed '/^$/d' > "${dir_practice}/$active_practice.tmp"
        else
            grep -Fxvf "${dir_practice}/$active_practice.1" "${dir_practice}/$active_practice.0" \
            |sed '/^$/d' > "${dir_practice}/$active_practice.tmp"
        fi
        
        if [[ "$(grep -Ecv '#|^$' < "${dir_practice}/$active_practice.tmp")" = 0 ]]; then
            if [[ ${group} = 1 ]]; then 
                export count_easy=0; decide_group
            else 
                lock
            fi
        fi
    else
        if [[ ${group} = 1 ]]; then
            head -n ${split} "${dir_practice}/$active_practice.0" > "${dir_practice}/$active_practice.tmp"
            cp -f "${dir_practice}/$active_practice.0" "${dir_practice}/$active_practice.group"
        else
            cp -f "${dir_practice}/$active_practice.0" "${dir_practice}/$active_practice.tmp"
        fi
        export count_seccion_active_practice=$(grep -Ecv '#|^$' "${dir_practice}/$active_practice.0")
    fi
    if [[ ${count_seccion_active_practice} -lt 1 ]]; then
    
		touch "${dir_practice}/$active_practice.0"
		
        if [ "$(grep -Ecv '#|^$' <<< "${list_learn}")" -lt 1 ]; then
            msg "$(gettext "There are not enough notes to practice.") \n" \
            dialog-information " " "$(gettext "OK")"
        elif grep -o -E 'a|b|c|d' <<< $active_practice; then
            msg "$(gettext "There are not enough words for this practice in the \"Learning\" list"). \n" \
            dialog-information " " "$(gettext "OK")"
        elif grep -o 'e' <<< $active_practice; then
            msg "$(gettext "There are not enough sentences for this practice in the \"Learning\" list"). \n" \
            dialog-information " " "$(gettext "OK")"
        fi
        strt 0
    else
        cleanups "${dir_practice}/$active_practice.2" "${dir_practice}/$active_practice.3"
        img_cont="$DS/images/cont.png"
        img_no="$DS/images/nou.png"
        img_yes="$DS/images/yes.png"
        echo "0p.$tpc.p0" >> "$log"
        practice_$active_practice
    fi
}

function strt() {
	
	touch "${DM_tlt}"
    check_dir "${dir_practice}"
    cd ~ && cd "${dir_practice}"
    label_pra=$(gettext "Flashcards")
	label_prb=$(gettext "Multiple-choice")
	label_prc=$(gettext "Recognize Pronunciation")
	label_prd=$(gettext "Images")
	label_pre=$(gettext "Listen and Writing Sentences")

    [[ ${count_hard} -lt 0 ]] && count_hard=0
    if [[ ${step} -gt 1 ]] && [[ ${count_learn} -ge 1 ]] && \
    [[ ${count_hard} = 0 ]] && [[ ${group} != 1 ]]; then
        echo -e "wait=\"$(date +%d)\"" > ./$active_practice.lock
    fi
    
    list_data="$DC_tlt/data"
	list_sents="$(tpc_db 5 sentences)"
	list_words="$(tpc_db 5 words)"
	list_learn="$(tpc_db 5 learning)"
    count_a=0; count_b=0; count_c=0; count_d=0; count_e=0
    
    i=1
    for practice in a b c d e; do
		if [ ! -f "./$practice.0" ]; then
			active_practice=${practice}; get_notes start
		fi
        if [ -f ./$practice.1 ]; then
			declare label_count_${practice}="<i>( $(($(wc -l < ./$practice.0) - $(wc -l < ./$practice.1))) )</i>"
		elif [ -f ./$practice.0 ]; then
			declare label_count_${practice}="<i>( $(($(wc -l < ./$practice.0))) )</i>"
		else
			declare label_count_${practice}=""
        fi
        if [ -f ./$practice.lock ] && ! grep -o "wait" < ./$practice.lock; then
			declare label_count_${practice}=""
		fi
		if [ -f ./${practice}.df ]; then
            declare plus${practice}=" /  $(< ./${practice}.df)"
        else 
            unset plus${practice}
        fi
        if [ ! -f ./.${i} ]; then echo 1 > ./.${i}; fi
        ((i=i+1))
    done
    
    include "$DS/ifs/mods/practice"
    count_active_practice="$(wc -l < $active_practice.0)"
    
    if [[ "${1}" = 1 ]] || [[ "${1}" = 2 ]]; then
    	if [ $active_practice = "a" ] ; then
			label_pra="<b>*  $(gettext "Flashcards")</b>"
		elif [ $active_practice = "b" ] ; then
			label_prb="<b>*  $(gettext "Multiple-choice")</b>"
		elif [ $active_practice = "c" ] ; then
			label_prc="<b>*  $(gettext "Recognize Pronunciation")</b>"
		elif [ $active_practice = "d" ] ; then
			label_prd="<b>*  $(gettext "Images")</b>"
		elif [ $active_practice = "e" ] ; then
			label_pre="<b>*  $(gettext "Listen and Writing Sentences")</b>"
		fi
	fi

    if [[ "${1}" = 1 ]]; then

        declare congr${icon}="<span font_desc='Arial Bold 12'>  —  $(gettext "Test completed") </span>"
		info="<span font_desc='Arial Bold  11'>$(gettext "Congratulations!")</span> "
        echo 21 > .${icon}; export plus$active_practice=""
        declare label_count_${active_practice}=""
        count_seccion_active_practice=""
        [ -f ./$active_practice.df ] && rm ./$active_practice.df
        unset plus${practice}

    elif [[ "${1}" = 2 ]]; then
    
        count_learnt=$(< ./$active_practice.l); 
        if [ -f ./$active_practice.1 ] || [ -f ./$active_practice.2 ] || [ -f ./$active_practice.3 ]; then
			info=" <b><small>$(gettext "learnt")</small> <b>$count_learnt</b>    <small>$(gettext "Learning")</small> <b>$count_learn</b>    <small>$(gettext "Difficult")</small> <b>$count_hard</b></b>  "
		fi
		declare label_count_${active_practice}=""
    fi

    active_practice="$(yad --list --title="$(gettext "Practice ") - $tpc" \
    --text="${info}" \
    --class=Idiomind --name=Idiomind \
    --print-column=1 --separator="" \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=edge --image-on-top --center \
    --on-top --text-align=center \
    --no-headers --expand-column=3 --hide-column=1 \
    --width=${sz[0]} --height=${sz[1]} --borders=10 \
    --ellipsize=end --wrap-width=200 --ellipsize-cols=1 \
    --column="Action" --column="Pick":IMG --column="Label" \
    "a" "$DS/images/practice/$(< ./.1).png" "$label_count_a $label_pra$congr1 <small>$plusa</small>"  \
    "b" "$DS/images/practice/$(< ./.2).png" "$label_count_b $label_prb$congr2 <small>$plusb</small>" \
    "c" "$DS/images/practice/$(< ./.3).png" "$label_count_c $label_prc$congr3 <small>$plusc</small>" \
    "d" "$DS/images/practice/$(< ./.4).png" "$label_count_d $label_prd$congr4 <small>$plusd</small>" \
    "e" "$DS/images/practice/$(< ./.5).png" "$label_count_e $label_pre$congr5" \
    --button="$(gettext "Restart")":3 \
    --button="$(gettext "Start")":0)"
    ret=$?
    unset info info1 info2 info3 info4 info5 title_act_pract \
    congr1 congr2 congr3 congr4 congr5
    
    if [ $ret -eq 0 ]; then # start a selected practice
        if [ -z "$active_practice" ]; then
            msg " $(gettext "You must choose a practice.")\n" dialog-information
            strt 0
        else
            practices $active_practice
        fi
        
    elif [ $ret -eq 3 ]; then # restar all practices
        unset plusa plusb plusc plusd pr
        if [ -d "${dir_practice}" ]; then
            cd ~ && cd "${dir_practice}"/
            find . -exec rm {} \;
            touch ./log1 ./log2 ./log3
        fi

        strt 0
        
    else # exit (save data)
        if [ "${1}" = 2 ]; then
            if [[ -z "$(cdb ${shrdb} 8 T8 list "${tpc}")" ]]; then
                cdb ${shrdb} 2 T8 list "${tpc}"
            fi
        elif [ "${1}" = 1 ]; then
            cdb ${shrdb} 4 T8 list "${tpc}"
        fi &
        # idiomind tasks
        count_check_tasks2="$(grep "1p.$tpc.p1" "$log" | wc -l)"
        if [ $count_check_tasks2 -gt $count_check_tasks1 ]; then
			grep -vxE "$(gettext "To Practice:") $tpc|$(gettext "Back to Practice:") $tpc|$(gettext "Resume Practice:") $tpc" $DT/tasks >> $DT/tasks.tmp
			sed '/^$/d' $DT/tasks.tmp > $DT/tasks
			rm -f $DT/tasks.tmp
		fi

        "$DS/ifs/tls.sh" colorize 1 & exit 0
    fi
}

strt 0 & exit
