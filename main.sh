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

IFS=$'\n\t'
if [ ! -d "$HOME/.idiomind" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
fi

source /usr/share/idiomind/ifs/c.conf

if [ -f "$DT/ps_lk" ]; then
    sleep 5
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    exit 1
fi

function new_session() {
    
    #set -e
    echo "--new session"
    echo "$(date +%d)" > "$DC_s/10.cfg"
    if [ -f "$DT/notify" ]; then rm -f "$DT/notify"; fi
    source "$DS/ifs/mods/cmns.sh"
    
    # write in /tmp
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    if [ $? -ne 0 ]; then
    msg "$(gettext "Fail on try write in /tmp")\n" error & exit 1; fi
    
    touch "$DT/ps_lk"
    
    # start addons
    > "$DC_s/2.cfg"
    while read -r set; do

        if [[ -f "/usr/share/idiomind/addons/$set/icon.png" ]]; then 
        echo "/usr/share/idiomind/addons/$set/icon.png" >> "$DC_s/2.cfg"
        else echo "/usr/share/idiomind/images/thumb.png" >> "$DC_s/2.cfg"
        fi
        echo "$set" >> "$DC_s/2.cfg"

    done < <(cd "$DS/addons"; ls -d *)
    
    for strt in "$DS/ifs/mods/start"/*; do
    (sleep 20 && "$strt"); done &
    
    #
    list_inadd > "$DM_tl/.2.cfg"
    cd /
    
    s="$(xrandr | grep '*' | awk '{ print $1 }' \
    | sed 's/x/\n/')"
    sed -n 1p <<<"$s" >> "$DC_s/10.cfg"
    sed -n 2p <<<"$s" >> "$DC_s/10.cfg"
    echo "$DESKTOP_SESSION" >> "$DC_s/10.cfg"
    gconftool-2 --get /desktop/gnome/interface/font_name \
    | cut -d ' ' -f 2 >> "$DC_s/10.cfg"
    #
    [[ `wc -l < "$DC_s/1.cfg"` -lt 19 ]] && rm "$DC_s/1.cfg"
    
    # log file
    if [ -f "$DC_s/8.cfg" ]; then
    if [[ "$(du -sb "$DC_s/8.cfg" | awk '{ print $1 }')" -gt 100000 ]]; then
    tail -n2000 < "$DC_s/8.cfg" > "$DT/8.cfg"
    mv -f "$DT/8.cfg" "$DC_s/8.cfg"; fi
    fi
    
    # check for updates
    "$DS/ifs/tls.sh" a_check_updates &
    
    # status update
    [[ ! -f "$DM_tl/.1.cfg" ]] && touch "$DM_tl/.1.cfg"
    while read line; do
        
        DM_tlt="$DM_tl/${line}"
        stts=$(sed -n 1p "${DM_tlt}/.conf/8.cfg")
        if ([ $stts = 3 ] || [ $stts = 4 ] \
        || [ $stts = 7 ] || [ $stts = 8 ]) && \
        [[ -f "${DM_tlt}/.conf/9.cfg" ]]; then
            calculate_review "${line}"
            if [[ $((stts%2)) = 0 ]]; then
            if [[ "$RM" -ge 180 ]]; then
            echo 10 > "${DM_tlt}/.conf/8.cfg"
            elif [[ "$RM" -ge 100 ]]; then
            echo 8 > "${DM_tlt}/.conf/8.cfg"; fi
            else
            if [[ "$RM" -ge 180 ]]; then
            echo 9 > "${DM_tlt}/.conf/8.cfg"
            elif [[ "$RM" -ge 100 ]]; then
            echo 7 > "${DM_tlt}/.conf/8.cfg"; fi
            fi
        fi
    done < "$DM_tl/.1.cfg"
    
    if [ -f "$DM_tl/.5.cfg" ]; then
    tpd="$(< "$DM_tl/.5.cfg")"
    if grep -Fxq "${tpd}" "$DM_tl/.1.cfg"; then
    "$DS/default/tpc.sh" "$tpd" 2; fi
    fi
    
    # version ###############
    if ! grep 'ttrgt' < "$DC_s/1.cfg"; then
    rm "$DC_s/1.cfg"; fi
    
    if [ `cat "$DM_tl/Podcasts/.conf/8.cfg"` != 11 ]; then
    echo 11 > "$DM_tl/Podcasts/.conf/8.cfg"; fi
    ###############

    rm -f  "$DT/ps_lk"
    "$DS/mngr.sh" mkmn &
}


if grep -o '.idmnd' <<<"${1: -6}"; then

    c=$((RANDOM%1000))
    source "$DS/ifs/mods/cmns.sh"
    [ ! -d "$DT" ] && mkdir "$DT"
    mkdir "$DT/dir$c"
    cp "${1}" "$DT/import.tmp"
    mv "$DT/import.tmp" "$DT/import.tar.gz"
    cd "$DT/dir$c"
    tar -xzvf ../import.tar.gz
    ls -tdN * > "$DT/dir$c/folder"
    tpf=$(sed -n 1p "$DT/dir$c/folder")
    tmp="$DT/dir$c/${tpf}"
    source "$DS/ifs/tls.sh"
    check_source_1 "${tmp}" "${tpf}"
    if [ -f "$DT/${tpf}.cfg" ]; then
    cmd_infs="'$DS/ifs/tls.sh' 'details' "\"$tmp\"""
    [ $level = 1 ] && level="$(gettext "Beginner")"
    [ $level = 2 ] && level="$(gettext "Intermediate")"
    [ $level = 3 ] && level="$(gettext "Advanced")"

    cd "${tmp}"
    itxt="<span font_desc='Free Sans 14'>$tname</span><small>\n ${langs^}-$langt $nword $(gettext "Words") $nsent $(gettext "Sentences") $nimag $(gettext "Images")\n $(gettext "Level:") $level\n</small>"
    dclk="'$DS/default/vwr_tmp.sh' '$c'"

    tac "${tmp}/conf/1.cfg" | awk '{print $0""}' | \
    yad --list --title="Idiomind" \
    --text="$itxt" \
    --name=Idiomind --class=Idiomind \
    --print-all --dclick-action="$dclk" \
    --window-icon="$DS/images/icon.png" \
    --no-headers --ellipsize=END --fixed \
    --scroll --center --tooltip-column=1 \
    --width=650 --height=580 --borders=10 \
    --column=Items \
    --button="$(gettext "Info")":"$cmd_infs" \
    --button="$(gettext "Install")":0 \
    --button="$(gettext "Close")":1
    ret=$?
        
        if [[ $ret -eq 1 ]]; then
        
            [ -d "$DT/dir$c" ] && rm -fr "$DT/dir$c"
            rm -f "$DT/import.tar.gz" "$DT/${tpf}.cfg" & exit
            
        elif [[ $ret -eq 0 ]]; then

            if [[ $(wc -l < "$DM_t/$langt/.1.cfg") -ge 120 ]]; then
                
                msg "$(gettext "Sorry, you have reached the maximum number of topics")\n" info
                [ -d "$DT/dir$c" ] && rm -fr "$DT/dir$c"
                rm -f "$DT/import.tar.gz" & exit
            fi
            
            if [[ $(grep -Fxo "${tname}" "$DM_t/$langt/.1.cfg" | wc -l) -ge 1 ]]; then
            
                for i in {1..50}; do
                chck=$(grep -Fxo "${tname} ($i)" "$DM_t/$langt/.1.cfg")
                [ -z "$chck" ] && break; done
            
                tname="${tname} ($i)"
                msg_2 "$(gettext "Another topic with the same name already exist.")\n$(gettext "The name for the newest will be\:")\n<b>$tname</b>\n" info "$(gettext "OK")" "$(gettext "Cancel")"
                ret=$(echo $?)
                
                if [[ $ret != 0 ]]; then
                [ -d "$DT/dir$c" ] && rm -fr "$DT/dir$c"
                rm -f  "$DT/import.tar.gz" & exit 1; fi
            fi

            if [ ! -d "$DM_t/$langt" ]; then
            mkdir "$DM_t/$langt"
            mkdir "$DM_t/$langt/.share"; fi
            mkdir -p "$DM_t/$langt/${tname}/.conf/practice"
            DM_tlt="$DM_t/$langt/${tname}"
            DC_tlt="$DM_t/$langt/${tname}/.conf"
            
            for i in {1..6}; do > "$DC_tlt/${i}.cfg"; done
            for i in {1..3}; do > "$DC_tlt/practice/log.${i}"; done
            cp -f "${tmp}/conf/0.cfg" "$DC_tlt/0.cfg"
            cp -f "${tmp}/conf/id.cfg" "$DC_tlt/id.cfg"
            cp -f "${tmp}/conf/info" "$DC_tlt/info"
            sed -i "s/datei=.*/datei=\"$(date +%F)\"/g" "${DC_tlt}/id.cfg"
            while read item_; do
            item="$(sed 's/},/}\n/g' <<<"${item_}")"
            type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            if [ -n "${trgt}" ]; then
            if [[ ${type} = 1 ]]; then
            echo "${trgt}" >> "$DC_tlt/3.cfg"
            else echo "${trgt}" >> "$DC_tlt/4.cfg"; fi
            echo "${trgt}" >> "$DC_tlt/1.cfg"; fi
            done < "${tmp}/conf/0.cfg"

            cp -n "$tmp/share"/*.mp3 "$DM_t/$langt/.share"/
            rm -fr "$tmp/share" "${tmp}/conf" "$tmp/folder"
            cp -fr "${tmp}"/.* "${DM_tlt}/"
            
            "$DS/ifs/tls.sh" colorize
            echo -e "$langt\n$lgsl" > "$DC_s/6.cfg"
            echo 1 > "${DC_tlt}/8.cfg"
            echo "${tname}" >> "$DM_tl/.3.cfg"
            "$DS/mngr.sh" mkmn
            "$DS/default/tpc.sh" "${tname}" &
        fi
    fi
    [ -d "$DT/dir$c" ] && rm -fr "$DT/dir$c"
    rm -f "$DT/import.tar.gz" "$DT/${tpf}.cfg"
    exit 1
fi
    
function topic() {

    [[ -z "${tpc}" ]] && exit 1
    mode=$(sed -n 1p "$DC_s/5.cfg")
    source "$DS/ifs/mods/cmns.sh"
    source "$DS/ifs/mods/topic/items_list.sh"
    
    if [[ ${mode} = 2 ]]; then
        
        tpa="$(sed -n 1p "$DC_a/4.cfg")"
        "$DS/ifs/mods/topic/${tpa}.sh" & exit 1

    elif [[ ${mode} = 0 ]] || [[ ${mode} = 1 ]]; then
    
        n=0
        while [[ $n -le 4 ]]; do
        [ ! -f "${DC_tlt}/$n.cfg" ] && touch "${DC_tlt}/$n.cfg"
        declare ls$n="${DC_tlt}/$n.cfg"
        declare inx$n=$(wc -l < "${DC_tlt}/$n.cfg")
        export inx$n
        let n++
        done
        nt="${DC_tlt}/info"
        author="$(sed -n 4p "${DC_tlt}/id.cfg" \
        | grep -o 'authr="[^"]*' | grep -o '[^"]*$')"
        auto_mrk=$(sed -n 15p "${DC_tlt}/id.cfg" \
        | grep -o set_1=\"[^\"]* |grep -o '[^"]*$')
        c=$((RANDOM%100000)); KEY=$c
        cnf1=$(mktemp "$DT/cnf1.XXX.x")
        cnf3=$(mktemp "$DT/cnf3.XXX.x")
        cnf4=$(mktemp "$DT/cnf4.XXX.x")
        if [ -f "${DM_tlt}/images/img.jpg" ]; then
        img="--image=${DM_tlt}/images/img.jpg"
        sx=608; sy=580; else sx=620; sy=560; fi
        echo -e ".tpc.$tpc.tpc." >> "$DC_s/log"
        [ ! -z "$author" ] && author=" $(gettext "Created by") $author"

        label_info1="<span font_desc='Free Sans 15' color='#505050'>$tpc</span><small>\n $inx4 $(gettext "Sentences") $inx3 $(gettext "Words") \n$author</small>"

        apply() {

            note_mod="$(< "${cnf3}")"
            if [ "$note_mod" != "$(< "${nt}")" ]; then
            mv -f "${cnf3}" "${DC_tlt}/info"; fi
            
            auto_mrk_mod=$(cut -d '|' -f 3 < "${cnf4}")
            if [[ $auto_mrk_mod != $auto_mrk ]] && [ -n "$auto_mrk_mod" ]; then
            sed -i "s/set_1=.*/set_1=\"$auto_mrk_mod\"/g" "${DC_tlt}/id.cfg"; fi
            
            if [ -n "$(grep -o TRUE < "${cnf1}")" ]; then
                grep -Rl "|FALSE|" "${cnf1}" | while read tab1 ; do
                     sed '/|FALSE|/d' "${cnf1}" > "$DT/tmpf1"
                     mv "$DT/tmpf1" "$tab1"
                done
                
                sed -i 's/|TRUE|//;s/|//;s/<[^>]*>//g' "${cnf1}"
                cat "${cnf1}" >> "${ls2}"

                grep -Fxvf "$cnf1" "${ls1}" > "$DT/ls1.x"
                mv -f "$DT/ls1.x" "${ls1}"
                if [ -n "$(cat "${ls1}" | sort -n | uniq -dc)" ]; then
                    cat "$ls1" | awk '!array_temp[$0]++' > "$DT/ls1.x"
                    sed '/^$/d' "$DT/ls1.x" > "${ls1}"
                fi
                "$DS/ifs/tls.sh" colorize
                echo -e ".oki.$(wc -l < "$cnf1").oki." >> "$DC_s/log"
            fi
        
            ntpc=$(cut -d '|' -f 1 < "${cnf4}")
            if [ "${tpc}" != "${ntpc}" ] && [ -n "$ntpc" ]; then
            if [ "${tpc}" != "$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")" ]]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n" info & exit; fi
            "$DS/mngr.sh" rename_topic "${ntpc}" & exit; fi
        }
    
    if [[ ${inx0} -lt 1 ]]; then 
        
        notebook_1
     
        ret=$(echo $?)
                
            if [ ! -f "$DT/ps_lk" ]; then
                
                apply
            fi
            
            if [[ $ret -eq 5 ]]; then
            
                rm -f "$DT"/*.x
                "$DS/practice/strt.sh" &
            fi

        rm -f "$DT"/*.x

    elif [[ ${inx1} -ge 1 ]]; then
    
        if [ -f "${DC_tlt}/9.cfg" ] && [ -f "${DC_tlt}/7.cfg" ]; then
        
            calculate_review "$tpc"
            stts=$(sed -n 1p "${DC_tlt}/8.cfg")
            if [[ ${RM} -ge 100 ]]; then
            
                if [ $((stts%2)) = 0 ]; then
                echo 8 > "${DC_tlt}/8.cfg"; else
                echo 7 > "${DC_tlt}/8.cfg"; fi
                
                "$DS/mngr.sh" mkmn &
                
                RM=100
                dialog_1
                ret=$(echo $?)
                
                    if [[ $ret -eq 2 ]]; then
                    
                        "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                        idiomind topic & exit 1
                    
                    elif [[ $ret -eq 3 ]]; then
                    
                       exit 1
                    fi 
            fi

            pres="<u><b>$(gettext "Learned topic")</b></u>  $(gettext "* however you have new items") ($inx1).\\n$(gettext "Time set to review:") $tdays $(gettext "days")"

            notebook_2
            
        else
            notebook_1
            
        fi
            ret=$(echo $?)

            if [[ $ret -eq 5 ]]; then
            
                rm -f "$DT"/*.x
                "$DS/practice/strt.sh" &
                    
            else
                if [ ! -f "$DT/ps_lk" ]; then
                
                    apply
                fi
                
                rm -f $DT/*.x
            fi
    
    elif [[ ${inx1} -eq 0 ]]; then
    
        if [ ! -f "${DC_tlt}/7.cfg" ] || [ ! -f "${DC_tlt}/9.cfg" ]; then

            "$DS/mngr.sh" mark_as_learned "${tpc}" 0
        fi
        
        calculate_review "${tpc}"
        if [[ ${RM} -ge 100 ]]; then

            stts=$(sed -n 1p "${DC_tlt}/8.cfg")
            if [[ $((stts%2)) = 0 ]]; then
            echo 8 > "${DC_tlt}/8.cfg"; else
            echo 7 > "${DC_tlt}/8.cfg"; fi
            
            "$DS/mngr.sh" mkmn &
            
            RM=100
            dialog_1
            ret=$(echo $?)
                
                if [[ $ret -eq 2 ]]; then

                    "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                    idiomind topic & exit 1
                    
                elif [[ $ret -eq 3 ]]; then
                    
                       exit 1
                fi 
        fi
        
        pres="<u><b>$(gettext "Learned topic")</b></u>\\n$(gettext "Time set to review:") $tdays $(gettext "days")"

        notebook_2
        
        if [ ! -f "$DT/ps_lk" ]; then
                
            apply
        fi
      
        rm -f "$DT"/*.x & exit
    fi
    rm -f "$DT"/*.x
    
    else
        if [[ "$(wc -l < "$DM_tl/.1.cfg")" -ge 1 ]]; then
            exit 1
        fi
    fi
}

panel() {
    
    echo -e ".strt.1.strt." >> "$DC_s/log"
    if [ ! -d "$DT" ]; then new_session; fi
    [ ! -f "$DT/tpe" ] && echo "$(sed -n 1p "$DC_s/4.cfg")" > "$DT/tpe"
    [ "$(< "$DT/tpe")" != "${tpc}" ] && echo "$(sed -n 1p "$DC_s/4.cfg")" > "$DT/tpe"
    [ -f "$DC_s/10.cfg" ] && date=$(sed -n 1p "$DC_s/10.cfg")
    
    if [[ "$(date +%d)" != "$date" ]] || [ ! -f "$DC_s/10.cfg" ]; then
    new_session; fi
    
    if [[ -f "$DC_s/10.cfg" ]]; then
    nu='^[0-9]+$'
    x=$(($(sed -n 2p "$DC_s/10.cfg")/2))
    y=$(($(sed -n 3p "$DC_s/10.cfg")/2)); fi
    if ! [[ $x =~ $nu ]]; then x=100; fi
    if ! [[ $y =~ $nu ]]; then y=100; fi
    
    if [ `grep -oP '(?<=clipw=\").*(?=\")' "$DC_s/1.cfg"` = TRUE ] \
    && [ ! -f /tmp/.clipw ]; then "$DS/ifs/mods/clipw.sh" & fi
    
    yad --title="Idiomind" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=idiomind \
    --form --fixed --on-top --no-buttons --align=center \
    --width=130 --height=185 --borders=0 --geometry=150x190-$x-$y \
    --field=gtk-new:btn "$DS/add.sh 'new_items'" \
    --field=gtk-home:btn "idiomind 'topic'" \
    --field=gtk-index:btn "$DS/chng.sh" \
    --field=gtk-preferences:btn "$DS/cnfg.sh"
    ret=$?
    [[ $ret != 0 ]] && "$DS/stop.sh" 1 &
    exit
}

version() {
    echo "2.2-beta"
}

session() {
    new_session
    idiomind &
}

autostart() {
    sleep 50
    [ ! -f "$DT/ps_lk" ] && new_session
    exit 0
}

add() {
    dir=$(mktemp -d "$DT/XXXXXX")
    "$DS/add.sh" new_items "$dir" 2 "${2}" & exit
}

case "$1" in
    topic)
    topic ;;
    -v)
    version;;
    -s)
    session;;
    autostart)
    autostart;;
    add)
    add "$@" ;;
    *)
    panel;;
esac
