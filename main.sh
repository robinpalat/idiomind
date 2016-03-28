#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  Copyright 2015-2016 Robin Palatnik
#  Email robinpalat@users.sourceforge.net
#  Web site https://idiomind.sourceforge.net
#
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

if [ ! -d "$HOME/.idiomind" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
fi

source /usr/share/idiomind/default/c.conf

if [ -z "${tlng}" -o -z "${slng}" ]; then
    source "$DS/ifs/cmns.sh"
    msg_2 "$(gettext "Please check the language settings in the preferences dialog")\n" \
    error "$(gettext "Open")" "$(gettext "Cancel")"
    [ $? = 0 ] && "$DS/cnfg.sh"
    exit 1
fi
if [ -e "$DT/ps_lk" -o -e "$DT/el_lk" ]; then
    sleep 5
    [ -e "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    [ -e "$DT/el_lk" ] && rm -f "$DT/el_lk"
    exit 1
fi

function new_session() {
    echo "--new session"
    date "+%d" > "$DC_s/10.cfg"
    source "$DS/ifs/cmns.sh"
    
    # mkdir tmp dir
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    if [ $? -ne 0 ]; then
    msg "$(gettext "An error occurred while trying to write on '/tmp'")\n" \
    error "$(gettext "Error")" & exit 1
    fi
    
    f_lock "$DT/ps_lk"
    # run scripts
    for strt in "$DS/ifs/mods/start"/*; do
    ( sleep 10 && "${strt}" ); done &
    
    check_list > "$DM_tl/.share/2.cfg"
    check_index1 "$DM_tl/.share/3.cfg"
    
    if ls "$DC_s"/*.p 1> /dev/null 2>&1; then
    cd "$DC_s"/; rename 's/\.p$//' *.p; fi; cd /

    # check database
    cdb="$DM_tls/data/${tlng}.db"
    if [ ! -e ${cdb} ]; then
    [ ! -d "$DM_tls/data" ] && mkdir -p "$DM_tls/data" 
    echo -n "create table if not exists Words (Word TEXT);" |sqlite3 ${cdb}
    echo -n "create table if not exists Config (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
    fi

    # log file
    if [ -f "$DC_s/log" ]; then
        if [[ "$(du -sb "$DC_s/log" |awk '{ print $1 }')" -gt 100000 ]]; then
        tail -n2000 < "$DC_s/log" > "$DT/log"
        mv -f "$DT/log" "$DC_s/log"; fi
    fi
    
    # update topic status
    while read -r line; do
        unset stts
        dir="$DM_tl/${line}/.conf"
        dim="$DM_tl/${line}"
        [ ! -d "${dir}" ] && continue
        stts=$(sed -n 1p "${dir}/8.cfg")
        ! [[ ${stts} =~ $numer ]] && stts=1
        [[ ${stts} = 12 ]] && continue
        if [ -e "${dir}/9.cfg" ] && \
        [ -e "${dir}/7.cfg" ]; then
            calculate_review "${line}"
            if [[ $((stts%2)) = 0 ]]; then
                if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                    echo 10 > "${dir}/8.cfg"; touch "${dim}"
                elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                    echo 8 > "${dir}/8.cfg"; touch "${dim}"
                fi
            else
                if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                    echo 9 > "${dir}/8.cfg"; touch "${dim}"
                elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                    echo 7 > "${dir}/8.cfg"; touch "${dim}"
                fi
            fi
        fi
    done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')
    
    while read -r line; do
        unset stts
        dir="$DM_tl/${line}"; [ ! -d "${dir}" ] && continue
        stts=$(sed -n 1p "${dir}/8.cfg")
        ! [[ ${stts} =~ $numer ]] && stts=1
        if [ ${stts} != 12 ]; then
            mv -f "${dir}/8.cfg"  "${dir}/8.bk"
            echo 12 > "${dir}/8.cfg"
        fi
    done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime +80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')

    rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn 0 &
    
    # statistics
    ( source "$DS/ifs/stats.sh"; sleep 5; pre_comp ) &
}

if grep -o '.idmnd' <<<"${1: -6}" >/dev/null 2>&1; then
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    source "$DS/ifs/tls.sh"; check_format_1 "${1}"
    if [ $? != 18 ]; then
        msg "$(gettext "File is corrupted.")\n" error "$(gettext "Information")" & exit 1
    fi
    file="${1}"
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    level="${lv[${levl}]}"
    itxt="<span font_desc='Droid Sans Bold 12' color='#616161'>$name</span>\n$nwrd $(gettext "Words") \
$nsnt $(gettext "Sentences") $nimg $(gettext "Images") \n$(gettext "Level:") \
$level \n$(gettext "Language:") $(gettext "$tlng")  $(gettext "Translation:") $(gettext "$slng")"
    dclk="$DS/play.sh play_word"
    _lst() {
        while read -r line; do
        cut -d ':' -f1 <<< "${line}" |sed 's/\"*//;s/\"$//'
        done < <(sed -n 2p "${file}"|sed 's/},/\n/g'|tr -d '\'|sed '/^$/d')
    }

    _lst | yad --list --title="Idiomind" \
    --text="${itxt}" \
    --name=Idiomind --class=Idiomind \
    --no-click --print-column=0 \
    --dclick-action="${dclk}" \
    --window-icon=idiomind \
    --hide-column=2 --tooltip-column=2 \
    --no-headers --ellipsize=END --center \
    --width=600 --height=560 --borders=8 \
    --column=" " \
    --button="$(gettext "Install")":0
    ret=$?
        if [ $ret -eq 0 ]; then
            listt="$(cd "$DM_tl"; find ./ -maxdepth 1 -type d \
            ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"
            if [ $(wc -l <<< "$listt") -ge 120 ]; then
                msg "$(gettext "Maximum number of topics reached.")\n" \
                dialog-information "$(gettext "Information")" & exit
            fi
            cn=0
            if [[ $(grep -Fxo "${name}" <<< "${listt}" |wc -l) -ge 1 ]]; then
                cn=1
                for i in {1..50}; do
                    chck=$(grep -Fxo "${name} ($i)" <<< "${listt}")
                    [ -z "$chck" ] && break
                done
                name="${name} ($i)"
            fi

            check_dir "$DM_t/$tlng" "$DM_t/$tlng/.share/images" \
            "$DM_t/$tlng/.share/audio" "$DM_t/$tlng/.share/data" \
            "$DM_t/$tlng/${name}/.conf/practice"
            DM_tlt="$DM_t/$tlng/${name}"
            DC_tlt="$DM_t/$tlng/${name}/.conf"
            
            for i in {1..6}; do > "${DC_tlt}/${i}.cfg"; done
            for i in {1..3}; do > "${DC_tlt}/practice/log${i}"; done
            sed -n 3p "${file}" \
            |sed 's/,"/\n/g;s/":/=/g;s/^\s*.//g' > "${DC_tlt}/id.cfg"

            if [ ${cn} = 1  ]; then
            sed -i "s/name=.*/name=\"${name}\"/g" "${DC_tlt}/id.cfg"; fi
            sed -i "s/dtei=.*/dtei=\"$(date +%F)\"/g" "${DC_tlt}/id.cfg"
            > "${DC_tlt}/download"
            
            sed -n 2p "${file}" |tr -d '\' > "${DC_tlt}/0.cfg"
            sed -i 's/},/}\n/g;s|","|}|g;s|":"|{|g;s|":{"|}|g;s/"}/}/g' "${DC_tlt}/0.cfg"
            sed -i 's/^\s*./trgt{/g' "${DC_tlt}/0.cfg"

            while read item_; do
                item="$(sed 's/}/}\n/g' <<< "${item_}")"
                type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
                trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
                if [ -n "${trgt}" ]; then
                    if [[ ${type} = 1 ]]; then
                        echo "${trgt}" >> "${DC_tlt}/3.cfg"
                    else 
                        echo "${trgt}" >> "${DC_tlt}/4.cfg"
                    fi
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"
                fi    
            done < "${DC_tlt}/0.cfg"

            "$DS/ifs/tls.sh" colorize 1
            echo -e "$tlng\n$slng" > "$DC_s/6.cfg"
            echo 1 > "${DC_tlt}/8.cfg"
            echo "${name}" >> "$DM_tl/.share/3.cfg"
            source /usr/share/idiomind/default/c.conf
            "$DS/mngr.sh" mkmn 1
            "$DS/default/tpc.sh" "${name}" 1 &
        fi
    exit 1
fi

function topic() {
    source "$DS/ifs/cmns.sh"
    [ -e "${DC_tlt}/8.cfg" ] && export mode=$(sed -n 1p "${DC_tlt}/8.cfg")
    if ! [[ ${mode} =~ $numer ]]; then exit 1; fi

    readd(){
        [ -z "${tpc}" ] && exit 1
        source "$DS/ifs/mods/topic/items_list.sh"
        for n in {0..4}; do
            [ ! -e "${DC_tlt}/${n}.cfg" ] && touch "${DC_tlt}/${n}.cfg"
            export ls${n}="${DC_tlt}/${n}.cfg"
            export cfg${n}=$(wc -l < "${DC_tlt}/${n}.cfg")
        done
        nt="${DC_tlt}/info"
        inf="$(< "${DC_tlt}/id.cfg")"
        autr=$(grep -oP '(?<=autr=\").*(?=\")' <<< "${inf}")
        dtec=$(grep -oP '(?<=dtec=\").*(?=\")' <<< "${inf}")
        dtei=$(grep -oP '(?<=dtei=\").*(?=\")' <<< "${inf}")
        repass=$(grep -oP '(?<=repass=\").*(?=\")' "${DC_tlt}/10.cfg")
        export acheck=$(grep -oP '(?<=acheck=\").*(?=\")' "${DC_tlt}/10.cfg")
        [ -z $repass ] && repass=0
        ( if [ -e "${DC_tlt}/err" ]; then
        sleep 2; include "$DS/ifs/mods/add"
        dlg_text_info_3 "$(cat "${DC_tlt}/err")"; fi ) &
        c=$((RANDOM%100000)); export KEY=$c
        export cnf1=$(mktemp "$DT/cnf1.XXXX")
        export cnf3=$(mktemp "$DT/cnf3.XXXX")
        export cnf4=$(mktemp "$DT/cnf4.XXXX")
        if [ ! -z "$dtei" ]; then export infolbl="$(gettext "Review ")$repass. $(gettext "Installed on") $dtei\n$(gettext "created by") $autr"
        elif [ ! -z "$dtec" ]; then export infolbl="$(gettext "Review ")$repass. $(gettext "Created on") $dtec"; fi
        export lbl1="<span font_desc='Free Sans 15' color='#505050'>${tpc}</span><small>\n$cfg4 $(gettext "Sentences") $cfg3 $(gettext "Words") \n$infolbl</small>"
    }
    
    apply() {
            note_mod="$(< "${cnf3}")"
            if [ "${note_mod}" != "$(< "${nt}")" ]; then
                if ! grep '^$' < <(sed -n '1p' "${cnf3}")
                then echo -e "\n${note_mod}" > "${nt}"
                else echo "${note_mod}" > "${nt}"; fi
            fi
            acheck_mod=$(cut -d '|' -f 3 < "${cnf4}")
            if [[ $acheck_mod != $acheck ]] && [ -n "$acheck_mod" ]; then
            sed -i "s/acheck=.*/acheck=\"$acheck_mod\"/g" "${DC_tlt}/10.cfg"; fi
            
            if [[ $acheck_mod = FALSE ]] && [[ $acheck != FALSE ]]; then
                "$DS/ifs/tls.sh" colorize 1; rm "${cnf1}"; fi

            if grep TRUE "${cnf1}"; then
                grep -Rl "|FALSE|" "${cnf1}" |while read tab1; do
                     sed '/|FALSE|/d' "${cnf1}" > "$DT/tmpf1"
                     mv "$DT/tmpf1" "$tab1"
                done
                
                sed -i 's/|TRUE|//;s/|//;s/<[^>]*>//g' "${cnf1}"
                cat "${cnf1}" >> "${ls2}"

                grep -Fxvf "${cnf1}" "${ls1}" > "$DT/ls1.x"
                mv -f "$DT/ls1.x" "${ls1}"
                if [ -n "$(< "${ls1}" |sort -n |uniq -dc)" ]; then
                    awk '!array_temp[$0]++' < "${ls1}" > "$DT/ls1.x"
                    sed '/^$/d' "$DT/ls1.x" > "${ls1}"
                fi
                "$DS/ifs/tls.sh" colorize 1
                source "$DS/ifs/stats.sh"
                save_topic_stats 0
            fi
            ntpc=$(cut -d '|' -f 1 < "${cnf4}")
            if [ "${tpc}" != "${ntpc}" -a -n "$ntpc" ]; then
            if [[ "${tpc}" != "$(sed -n 1p "$HOME/.config/idiomind/4.cfg")" ]]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n" dialog-information "$(gettext "Information")" & exit; fi
            "$DS/mngr.sh" rename_topic "${ntpc}" & exit; fi
        }
        
    if ((mode>=1 && mode<=10)); then
        
        readd
        
        if [ ${cfg0} -lt 1 ]; then
            
            notebook_1; ret=$?
                
                if [ $ret -eq 1 ]; then exit 1; fi
                if [ ! -e "$DT/ps_lk" ]; then apply; fi
                
                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

            cleanups "$cnf1" "$cnf3" "$cnf4"

        elif [ ${cfg1} -ge 1 ] || [ ${cfg1} -ge 0 -a ${cfg0} -lt 15 ]; then
        
            if [ -e "${DC_tlt}/9.cfg" -a -e "${DC_tlt}/7.cfg" ]; then
            
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

                pres="<u><b>$(gettext "Topic learnt")</b></u>  $(gettext "* however you have new notes") ($cfg1).\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
                notebook_2
            else
                notebook_1
            fi
                ret=$?
                if [ $ret -eq 1 ]; then exit 1; fi
                if [ ! -e "$DT/ps_lk" ]; then apply; fi

                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

                cleanups "$cnf1" "$cnf3" "$cnf4"

        elif [ ${cfg1} -eq 0 -a ${cfg0} -ge 15 ]; then
        
            if [ ! -e "${DC_tlt}/7.cfg" -o ! -e "${DC_tlt}/9.cfg" ]; then
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
            notebook_2; ret=$?
            
            if [ $ret -eq 1 ]; then exit 1; fi
            if [ ! -e "$DT/ps_lk" ]; then apply; fi
          
            cleanups "$cnf1" "$cnf3" "$cnf4" & exit
        fi
        cleanups "$cnf1" "$cnf3" "$cnf4"

    elif [[ ${mode} = 12 ]]; then
    
        readd

        if [ ${cfg0} -lt 1 ]; then
            
            notebook_1; ret=$?
                
                if [ $ret -eq 1 ]; then exit 1; fi
                if [ ! -e "$DT/ps_lk" ]; then apply; fi
                
                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

            cleanups "$cnf1" "$cnf3" "$cnf4"

        elif [ ${cfg1} -ge 1 ]; then
        
            if [ -e "${DC_tlt}/9.cfg" -a -e "${DC_tlt}/7.cfg" ]; then
                notebook_2
            else
                notebook_1
            fi
                ret=$?
                if [ $ret -eq 1 ]; then exit 1; fi
                if [ ! -e "$DT/ps_lk" ]; then apply; fi

                if [ $ret -eq 5 ]; then
                    "$DS/practice/strt.sh" &
                fi

                cleanups "$cnf1" "$cnf3" "$cnf4"

        elif [[ ${cfg1} -eq 0 ]]; then

            calculate_review "${tpc}"
            pres="<u><b>$(gettext "Topic learnt")</b></u>\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
            notebook_2; ret=$?
            
            if [ $ret -eq 1 ]; then exit 1; fi
          
            cleanups "$cnf1" "$cnf3" "$cnf4" & exit
        fi
        cleanups "$cnf1" "$cnf3" "$cnf4"
        
    elif [[ ${mode} = 14 ]]; then
    
        echo 1 > "${DC_tlt}/8.cfg" & exit 1

    else
        tpa="$(sed -n 1p "$DC_s/4.cfg")"
        source "$DS/ifs/mods/topic/${tpa}.sh"
        ${tpa} & exit 1
    fi
}

bground_session() {
    if [ ! -e "$DT/ps_lk" -a ! -d "$DT" ]; then
        sleep 20; new_session
    fi &
    if [[ $(grep -oP '(?<=itray=\").*(?=\")' "$DC_s/1.cfg") = TRUE ]] && \
    ! pgrep -f "$DS/ifs/tls.sh itray"; then
    idiomind_start; fi
}

ipanel() {
    set_geom(){
        sleep 1
        [ ! -e "$DC_s/5.cfg" ] && > "$DC_s/5.cfg"
        spost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
        echo -e "\"${spost}\"" > "$DC_s/5.cfg"
        for n in {1..10}; do
            sleep 1
            cpost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
            if [ -z ${cpost} ]; then break; return 1; fi
            if [ ${spost} != ${cpost} ]; then
                echo -e "\"${cpost}\"" > "$DC_s/5.cfg"; spost=${cpost}
            fi
        done
    } >/dev/null 2>&1
    
    if [ -e "$DC_s/5.cfg" ]; then
    geometry=$(grep -o \"[^\"]* "$DC_s/5.cfg" |grep -o '[^"]*$'); fi
    if [ -n "$geometry" ]; then
    geometry="--geometry=$geometry"
    else geometry="--mouse"; fi

    ( yad --fixed --form --title="Idiomind" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=idiomind \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --on-top --no-buttons --align=center \
    --width=140 --height=180 --borders=0 ${geometry} \
    --field="$(gettext "New")"!'document-new':btn "$DS/add.sh 'new_items'" \
    --field="$(gettext "Home")"!'go-home':btn "idiomind 'topic'" \
    --field="$(gettext "Index")"!'gtk-index':btn "$DS/chng.sh" \
    --field="$(gettext "Options")"!'gtk-preferences':btn "$DS/cnfg.sh"
    if [ $? != 0 ] && ! pgrep -f "$DS/ifs/tls.sh itray"; then \
    "$DS/stop.sh" 1 & fi; exit ) & set_geom
}

idiomind_start() {
    if [ ! -d "$DT" ]; then 
        new_session; cu=TRUE
    fi
    if [ ! -e "$DT/tpe" ]; then
        cu=TRUE; tpe="$(sed -n 1p "$DC_s/4.cfg")"
        if ! ls -1a "$DS/addons/" |grep -Fxo "${tpe}" >/dev/null 2>&1; then
            [ ! -L "$DM_tl/${tpe}" ] && echo "${tpe}" > "$DT/tpe"
        fi
    fi
    if [ "$(< "$DT/tpe")" != "${tpc}" ]; then
        if ! ls -1a "$DS/addons/" |grep -Fxo "${tpc}" >/dev/null 2>&1; then
            [ ! -L "$DM_tl/${tpe}" ] && echo "${tpc}" > "$DT/tpe"
        fi
    fi
    [ -e "$DC_s/10.cfg" ] && date=$(sed -n 1p "$DC_s/10.cfg")
    if [[ "$(date +%d)" != "$date" ]] || [ ! -e "$DC_s/10.cfg" ]; then
        new_session; cu=TRUE
    fi
    ( if [[ "${cu}" = TRUE ]]; then
    "$DS/ifs/tls.sh" a_check_updates; fi ) &
    
    if [[ $(grep -oP '(?<=clipw=\").*(?=\")' "$DC_s/1.cfg") = TRUE ]] && \
    [ ! -e $DT/clipw ]; then
        sed -i "s/clipw=.*/clipw=\"FALSE\"/g" "$DC_s/1.cfg"
    fi
    
    if [[ $(grep -oP '(?<=itray=\").*(?=\")' "$DC_s/1.cfg") = TRUE ]] && \
    ! pgrep -f "$DS/ifs/tls.sh itray"; then
        $DS/ifs/tls.sh itray &
    else
        ipanel
    fi
}

case "$1" in
    topic)
    topic ;;
    first_run)
    "$DS/ifs/tls.sh" "$@" ;;
    translate)
    "$DS/ifs/tls.sh" "$@" ;;
    -v|--version)
    source $DS/default/sets.cfg
    echo -n "$_version" ;;
    -s)
    new_session; idiomind ;;
    autostart)
    bground_session ;;
    --add)
   "$DS/add.sh" new_items "${dir}" 2 "${2}" ;;
    add)
    "$DS/add.sh" new_item "${@}" ;;
    feeds)
    "$DS/mngr.sh" edit_feeds "${tpc}" ;;
    panel)
    ipanel ;;
    stop)
    "$DS/stop.sh" 2 ;;
    *)
    idiomind_start ;;
esac
