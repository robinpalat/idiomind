#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston
#  MA 02110-1301, USA.
#
#  2015/02/27

_version='0.1.10'
wicon="/usr/share/idiomind/images/icon.png"

if [ ! -d "$HOME/.idiomind" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
fi

source /usr/share/idiomind/ifs/c.conf

if [ -e "$DT/ps_lk" -o -e "$DT/el_lk" ]; then
    sleep 5
    [ -e "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    [ -e "$DT/el_lk" ] && rm -f "$DT/el_lk"
    exit 1
fi

function new_session() {
    echo "--new session"
    date "+%d" > "$DC_s/10.cfg"
    source "$DS/ifs/mods/cmns.sh"
    
    # mkdir /tmp/user
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    if [ $? -ne 0 ]; then
    msg "$(gettext "Fail on try write in /tmp")\n" error "$(gettext "Information")" & exit 1; fi
    
    f_lock "$DT/ps_lk"

    for strt in "$DS/ifs/mods/start"/*; do
    ( sleep 20 && "${strt}" ); done &
    
    list_inadd > "$DM_tl/.2.cfg"
    check_index1 "$DM_tl/.3.cfg"
    
    if ls "$DC_s"/*.p 1> /dev/null 2>&1; then
    cd "$DC_s"/; rename 's/\.p$//' *.p; fi
    cd /
    
    s="$(xrandr | grep '*' |awk '{ print $1 }' |sed 's/x/\n/')"
    sed -n 1p <<<"$s" >> "$DC_s/10.cfg"
    sed -n 2p <<<"$s" >> "$DC_s/10.cfg"
    
    # create database if not exist
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    if [[ ! -e ${cdb} ]]; then
    [ ! -d "$DM_tls/Dictionary" ] && mkdir -p "$DM_tls/Dictionary" 
    echo -n "create table if not exists Words (Word TEXT);" |sqlite3 ${cdb}
    echo -n "create table if not exists Config (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
    fi
    link="$(readlink -f "$(find "$DM_tl"/ -maxdepth 1 -type l)")"
    if [[ "$(basename "$link")" !=  "$(basename "$DM_tls/Dictionary")" ]]; then
	[ "$u" != 1 ] && ln -fs "$DM_tls/Dictionary" "$DM_tl/$(gettext "New Words")"; fi

    # log file
    if [ -f "$DC_s/log" ]; then
        if [[ "$(du -sb "$DC_s/log" |awk '{ print $1 }')" -gt 100000 ]]; then
        tail -n2000 < "$DC_s/log" > "$DT/log"
        mv -f "$DT/log" "$DC_s/log"; fi
    fi

    # update status
    [ ! -e "$DM_tl/.1.cfg" ] && touch "$DM_tl/.1.cfg"
    while read -r line; do
    unset stts
    DM_tlt="$DM_tl/${line}"
    stts=$(sed -n 1p "${DM_tlt}/.conf/8.cfg")
    [ -z $stts ] && stts=1
    if [ -e "${DM_tlt}/.conf/9.cfg" ] && \
    [ -e "${DM_tlt}/.conf/7.cfg" ]; then
        calculate_review "${line}"
        if [[ $((stts%2)) = 0 ]]; then
            if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                echo 10 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
            elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                echo 8 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"; fi
        else
            if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                echo 9 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
            elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                echo 7 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"; fi
        fi
    fi
    done < "$DM_tl/.1.cfg"
    rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn &
}

if grep -o '.idmnd' <<<"${1: -6}"; then
    source "$DS/ifs/mods/cmns.sh"
    source "$DS/ifs/tls.sh"
    check_format_1 "${1}"
    if [ $? != 18 ]; then
    msg "$(gettext "File is corrupted.")\n" error "$(gettext "Information")" & exit 1; fi
    file="${1}"
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    level="${lv[${level}]}"
    itxt="<span font_desc='Droid Sans Bold 12' color='#616161'>$tname</span>\n<sup>$nword $(gettext "Words") $nsent $(gettext "Sentences") $nimag $(gettext "Images") \n$(gettext "Level:") $level \n$(gettext "Language:") $(gettext "$langt")  $(gettext "Translation:") $(gettext "$langs")</sup>"
    dclk="$DS/play.sh play_word"
    _lst() { while read -r item; do
        grep -oP '(?<=trgt={).*(?=},srce)' <<<"${item}"
    done < <(tac "${file}"); }

    _lst | yad --list --title="Idiomind" \
    --text="${itxt}" \
    --name=Idiomind --class=Idiomind \
    --no-click --print-column=0 --dclick-action="$dclk" \
    --window-icon=$wicon \
    --no-headers --ellipsize=END --center \
    --width=638 --height=570 --borders=6 \
    --column="$langt" \
    --button="$(gettext "Install")":0
    ret=$?
        if [ $ret -eq 0 ]; then
            if [[ $(wc -l < "$DM_t/$langt/.1.cfg") -ge 120 ]]; then
                msg "$(gettext "Maximum number of topics reached.")\n" info "$(gettext "Information")" & exit
            fi
            cn=0
            if [[ `grep -Fxo "${tname}" "$DM_t/$langt/.1.cfg" |wc -l` -ge 1 ]]; then
                cn=1
                for i in {1..50}; do
                chck=$(grep -Fxo "${tname} ($i)" "$DM_t/$langt/.1.cfg")
                [ -z "$chck" ] && break; done
            
                tname="${tname} ($i)"
                msg_2 "$(gettext "Another topic with the same name already exist.")\n$(gettext "Notice that the name for this one is now\:")\n<b>$tname</b>\n" info "$(gettext "OK")" "$(gettext "Cancel")"
  
                if [ $? != 0 ]; then exit 1; fi
            fi
            if [ ! -d "$DM_t/$langt" ]; then
                mkdir "$DM_t/$langt"
                mkdir -p "$DM_t/$langt/.share/images"; fi
            mkdir -p "$DM_t/$langt/${tname}/.conf/practice"
            DM_tlt="$DM_t/$langt/${tname}"
            DC_tlt="$DM_t/$langt/${tname}/.conf"
            
            for i in {1..6}; do > "${DC_tlt}/${i}.cfg"; done
            for i in {1..3}; do > "${DC_tlt}/practice/log.${i}"; done
            tail -n 1 < "${file}" |tr '&' '\n' > "${DC_tlt}/id.cfg"
            
            if [ ${cn} = 1  ]; then
            sed -i "s/tname=.*/tname=\"${tname}\"/g" "${DC_tlt}/id.cfg"; fi
            sed -i "s/datei=.*/datei=\"$(date +%F)\"/g" "${DC_tlt}/id.cfg"

            chkaud="$(grep -oP '(?<=naudi={).*(?=})' < "${DC_tlt}/id.cfg")"
            chkimg="$(grep -oP '(?<=nimag={).*(?=})' < "${DC_tlt}/id.cfg")"
            [[ $((chkaud+chkimg)) -ge 2 ]] && > "${DC_tlt}/download" || echo -e "\n" > "${DC_tlt}/download"

            while read item_; do
                item="$(sed 's/},/}\n/g' <<<"${item_}")"
                type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
                trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
                if [ -n "${trgt}" ]; then
                    if [[ ${type} = 1 ]]; then
                        echo "${trgt}" >> "${DC_tlt}/3.cfg"
                    else 
                        echo "${trgt}" >> "${DC_tlt}/4.cfg"
                    fi
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"
                    echo "${item_}" >> "${DC_tlt}/0.cfg"
                fi    
            done < <(head -n -1 < "${file}")

            "$DS/ifs/tls.sh" colorize
            echo -e "$langt\n$lgsl" > "$DC_s/6.cfg"
            echo 1 > "${DC_tlt}/8.cfg"
            echo "${tname}" >> "$DM_tl/.3.cfg"
            source /usr/share/idiomind/ifs/c.conf
            "$DS/mngr.sh" mkmn
            "$DS/default/tpc.sh" "${tname}" &
        fi
    exit 1
fi

function topic() {
    export mode=`sed -n 1p "${DC_tlt}/8.cfg"`
    source "$DS/ifs/mods/cmns.sh"
    if ! [[ ${mode} =~ $numer ]]; then exit 1; fi

    if ((mode>=1 && mode<=10)); then
        [ -z "${tpc}" ] && exit 1
        source "$DS/ifs/mods/topic/items_list.sh"
        for n in {0..4}; do
            [ ! -e "${DC_tlt}/${n}.cfg" ] && touch "${DC_tlt}/${n}.cfg"
            declare ls${n}="${DC_tlt}/${n}.cfg"
            declare inx${n}=$(wc -l < "${DC_tlt}/${n}.cfg")
            export inx${n}
        done
        nt="${DC_tlt}/info"
        author="$(grep -o 'authr="[^"]*' "${DC_tlt}/id.cfg" |grep -o '[^"]*$')"
        auto_mrk=$(grep -o 'acheck=\"[^\"]*' "${DC_tlt}/10.cfg" |grep -o '[^"]*$')
        c=$((RANDOM%100000)); KEY=$c
        cnf1=$(mktemp "$DT/cnf1.XXX.x")
        cnf3=$(mktemp "$DT/cnf3.XXX.x")
        cnf4=$(mktemp "$DT/cnf4.XXX.x")
        sx=600; sy=560
        [ ! -z "$author" ] && author=" $(gettext "Created by") $author"
        lbl1="<span font_desc='Free Sans 15' color='#505050'>${tpc}</span><small>\n $inx4 $(gettext "Sentences") $inx3 $(gettext "Words") \n$author</small>"

        apply() {
            note_mod="$(< "${cnf3}")"
            if [ "${note_mod}" != "$(< "${nt}")" ]; then
            mv -f "${cnf3}" "${DC_tlt}/info"; fi
            
            auto_mrk_mod=$(cut -d '|' -f 3 < "${cnf4}")
            if [[ $auto_mrk_mod != $auto_mrk ]] && [ -n "$auto_mrk_mod" ]; then
            sed -i "s/acheck=.*/acheck=\"$auto_mrk_mod\"/g" "${DC_tlt}/10.cfg"; fi
            
            if grep TRUE "${cnf1}"; then
                grep -Rl "|FALSE|" "${cnf1}" | while read tab1 ; do
                     sed '/|FALSE|/d' "${cnf1}" > "$DT/tmpf1"
                     mv "$DT/tmpf1" "$tab1"
                done
                
                sed -i 's/|TRUE|//;s/|//;s/<[^>]*>//g' "${cnf1}"
                cat "${cnf1}" >> "${ls2}"

                grep -Fxvf "${cnf1}" "${ls1}" > "$DT/ls1.x"
                mv -f "$DT/ls1.x" "${ls1}"
                if [ -n "$(cat "${ls1}" |sort -n |uniq -dc)" ]; then
                    cat "${ls1}" | awk '!array_temp[$0]++' > "$DT/ls1.x"
                    sed '/^$/d' "$DT/ls1.x" > "${ls1}"
                fi
                "$DS/ifs/tls.sh" colorize
                echo -e "oki.$(wc -l < "${cnf1}").oki" >> "$DC_s/log"
            fi
        
            ntpc=$(cut -d '|' -f 1 < "${cnf4}")
            if [ "${tpc}" != "${ntpc}" -a -n "$ntpc" ]; then
            if [[ "${tpc}" != "$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")" ]]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n" info "$(gettext "Information")" & exit; fi
            "$DS/mngr.sh" rename_topic "${ntpc}" & exit; fi
        }
    
        if [[ ${inx0} -lt 1 ]]; then
            
            notebook_1; ret=$?
                    
                if [ ! -f "$DT/ps_lk" ]; then apply; fi
                
                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

            rm -f "$DT"/*.x

        elif [[ ${inx1} -ge 1 ]]; then
        
            if [ -f "${DC_tlt}/9.cfg" -a -f "${DC_tlt}/7.cfg" ]; then
            
                calculate_review "${tpc}"
                if [[ ${RM} -ge 100 ]]; then
                
                    RM=100; dialog_1; ret=$?
                    
                        if [ $ret -eq 2 ]; then
                            "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                            idiomind topic & exit 1
                        elif [ $ret -eq 3 ]; then
                           exit 1
                        fi 
                fi

                pres="<u><b>$(gettext "Topic learnt")</b></u>  $(gettext "* however you have new notes") ($inx1).\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
                notebook_2
            else
                notebook_1
            fi
                ret=$?
                if [ ! -f "$DT/ps_lk" ]; then apply; fi

                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

                rm -f "$DT"/*.x

        elif [[ ${inx1} -eq 0 ]]; then
            if [ ! -f "${DC_tlt}/7.cfg" -o ! -f "${DC_tlt}/9.cfg" ]; then
                "$DS/mngr.sh" mark_as_learned "${tpc}" 0
            fi
            
            calculate_review "${tpc}"
            if [[ ${RM} -ge 100 ]]; then

                RM=100; dialog_1; ret=$?
                    
                    if [ $ret -eq 2 ]; then
                        "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                        idiomind topic & exit 1
                    elif [ $ret -eq 3 ]; then
                        exit 1
                    fi 
            fi
            
            pres="<u><b>$(gettext "Topic learnt")</b></u>\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
            notebook_2
            
            if [ ! -f "$DT/ps_lk" ]; then apply; fi
          
            rm -f "$DT"/*.x & exit
        fi
        rm -f "$DT"/*.x
    
    elif [[ ${mode} = 14 ]]; then
        source "$DS/ifs/mods/topic/tags.sh"
        tags_list & exit 1
        
    elif [[ ${mode} = 0 ]]; then
        source "$DS/ifs/mods/topic/Dictionary.sh"
        Dictionary & exit 1
    else
        tpa="$(sed -n 1p "$DC_s/4.cfg")"
        source "$DS/ifs/mods/topic/${tpa}.sh"
        ${tpa} & exit 1
    fi
}

panel() {
    if [ ! -d "$DT" ]; then new_session; ns=TRUE; fi
    [ ! -e "$DT/tpe" ] && sed -n 1p "$DC_s/4.cfg" > "$DT/tpe"
    [ "$(< "$DT/tpe")" != "${tpc}" ] && sed -n 1p "$DC_s/4.cfg" > "$DT/tpe"
    [ -e "$DC_s/10.cfg" ] && date=$(sed -n 1p "$DC_s/10.cfg")
    
    if [[ "$(date +%d)" != "$date" ]] || [ ! -e "$DC_s/10.cfg" ]; then
    new_session; ns=TRUE; fi

    ( if [ "${ns}" = TRUE ]; then
    "$DS/ifs/tls.sh" a_check_updates; fi ) &

    if [ -e "$DC_s/10.cfg" ]; then
        x=$(($(sed -n 2p "$DC_s/10.cfg")/2))
        y=$(($(sed -n 3p "$DC_s/10.cfg")/2)); fi
    if ! [[ ${x} =~ $numer ]]; then x=100; y=100; fi

    if [[ `grep -oP '(?<=clipw=\").*(?=\")' "$DC_s/1.cfg"` = TRUE ]] \
    && [ ! -e /tmp/.clipw ]; then "$DS/ifs/mods/clipw.sh" & fi

    yad --title="" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=$wicon \
    --form --fixed --on-top --no-buttons --align=center \
    --width=80 --height=165 --borders=0 --geometry=80x190-${x}-${y} \
    --field="!$DS/images/new.png!$(gettext "Add new note")":fbtn "$DS/add.sh 'new_items'" \
    --field="!$DS/images/topic.png!$(gettext "Open active topic")":fbtn "idiomind 'topic'" \
    --field="!$DS/images/index.png!$(gettext "Open topics list")":fbtn "$DS/chng.sh"
    [ $? != 0 ] && "$DS/stop.sh" 1 &
    exit
}

case "$1" in
    topic)
    topic ;;
    first_run)
    "$DS/ifs/tls.sh" $@ ;;
    translate)
    "$DS/ifs/tls.sh" $@ ;;
    -v)
    echo -n "$_version" ;;
    -s)
    new_session; idiomind & ;;
    autostart)
    sleep 50; [ ! -e "$DT/ps_lk" ] && new_session ;;
    add)
    "$DS/add.sh" new_items "$dir" 2 "${2}" ;;
    play)
    "$DS/bcle.sh" ;;
    stop)
    "$DS/stop.sh" 2 ;;
    *)
    panel ;;
esac
