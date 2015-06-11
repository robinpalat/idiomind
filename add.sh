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
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#  2015/02/27

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)
list=$(sed -n 2p "$DC_s/1.cfg" \
| grep -o list=\"[^\"]* | grep -o '[^"]*$')
trans=$(sed -n 4p "$DC_s/1.cfg" \
| grep -o trans=\"[^\"]* | grep -o '[^"]*$')
trd_trgt=$(sed -n 5p "$DC_s/1.cfg" \
| grep -o trd_trgt=\"[^\"]* | grep -o '[^"]*$')

new_topic() {

    if [ $(wc -l < "$DM_tl/.1.cfg") -ge 80 ]; then
    msg "$(gettext "Sorry, you have reached the maximum number of topics")" info Info &&
    killall add.sh & exit 1; fi

    jlbi=$(dlg_form_0 "$2")
    ret="$?"
    jlb="$(clean_2 "$jlbi")"
    
    if [[ ${#jlb} -gt 55 ]]; then
    msg "$(gettext "Sorry, name too long.")\n" info
    "$DS/add.sh" new_topic "$jlb" & exit 1; fi
    
    if grep -Fxo "$jlb" < <(ls "$DS/addons/"); then jlb="$jlb."; fi
    chck=$(grep -Fxo "$jlb" "$DM_tl/.1.cfg" | wc -l)
    
    if [ "$chck" -ge 1 ]; then
        
        for i in {1..50}; do
        chck=$(grep -Fxo "$jlb ($i)" "$DM_t/$language_target/.1.cfg")
        [ -z "$chck" ] && break; done
        jlb="$jlb ($i)"
        msg_2 "$(gettext "Another topic with the same name already exist.")\n$(gettext "The name for the newest will be\:")\n<b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        [[ $ret -eq 1 ]] && exit 10
        
    else
        jlb="$jlb"
    fi
    
    if [ -n "$jlb" ]; then
    
        mkdir "$DM_tl/$jlb"
        list_inadd > "$DM_tl/.2.cfg"
        "$DS/default/tpc.sh" "$jlb" 1
        "$DS/mngr.sh" mkmn
    fi
    exit
}


new_items() {

    if [ ! -d "$DT" ]; then new_session; fi
    [ ! "$DT/tpe" ] && echo "${tpc}" > "$DT/tpe"
    
    if [ "$(grep -vFx 'Podcasts' "$DM_tl/.1.cfg" | wc -l)" -lt 1 ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    "$DS/chng.sh" "$(gettext "To start adding notes you need to have a topic.
Create one using the button below. ")" & exit 1; fi

    [ -z "$4" ] && txt="$(xclip -selection primary -o)" || txt="$4"
    txt="$(clean_4 "${txt}")"
    
    if [ "$3" = 2 ]; then
    DT_r="$2"; cd "$DT_r"
    [ -n "$5" ] && srce="$5" || srce=""; else
    DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"; fi
    
    [ -f "$DT_r/ico.jpg" ] && img="$DT_r/ico.jpg" \
    || img="$DS/images/nw.png"
    
    tpcs=$(grep -vFx "${tpe}" "$DM_tl/.2.cfg" \
    | tr "\\n" '!' | sed 's/\!*$//g')
    [ -n "$tpcs" ] && e='!'; [ -z "${tpe}" ] && tpe=' '

    if [ "$trans" = TRUE ]; then lzgpr="$(dlg_form_1)"; \
    else lzgpr="$(dlg_form_2)"; fi

    ret=$(echo "$?")
    trgt=$(echo "$lzgpr" | head -n -1 | sed -n 1p | sed 's/^\s*./\U&\E/g')
    srce=$(echo "$lzgpr" | sed -n 2p | sed 's/^\s*./\U&\E/g')
    chk=$(echo "$lzgpr" | tail -1)
    tpe=$(grep -Fxo "$chk" "$DM_tl/.1.cfg")

        if [[ $ret -eq 3 ]]; then
        
            cd "$DT_r"; set_image_1
            echo "${tpe}" > "$DT/tpe"
            "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
        elif [[ $ret -eq 2 ]]; then
        
            echo "${tpe}" > "$DT/tpe"
            "$DS/ifs/tls.sh" add_audio "$DT_r"
            "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
        elif [[ $ret -eq 0 ]]; then
        
            if [ -z "$chk" ]; then [ "$DT_r" ] && rm -fr "$DT_r";
            msg "$(gettext "No topic is active")\n" info & exit 1; fi
        
            if [ -z "${trgt}" ]; then
            [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi

            if [[ "$chk" = "$(gettext "New") *" ]]; then
            "$DS/add.sh" new_topic
            else echo "${tpe}" > "$DT/tpe"; fi
            
            if [[ "${trgt}" = Ocr ]] || [[ "${trgt}" = I ]]; then
                "$DS/add.sh" process image "$DT_r" & exit 1

            elif [[ ${#trgt} = 1 ]]; then
                "$DS/add.sh" process ${trgt:0:2} "$DT_r" & exit 1

            elif [[ ${trgt:0:4} = 'Http' ]]; then
                "$DS/add.sh" process "${trgt}" "$DT_r" & exit 1
            
            elif [[ ${#trgt} -gt 150 ]]; then
                "$DS/add.sh" process "${trgt}" "$DT_r" & exit 1
                
            elif [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
            
                if [ "$trans" = FALSE ] && ([ -z "${srce}" ] || [ -z "${trgt}" ]); then
                [ "$DT_r" ] && rm -fr "$DT_r"
                msg "$(gettext "You need to fill text fields.")\n" info " " & exit 1; fi

                srce=$(translate "${trgt}" auto $lgs)
                
                if [[ "$(wc -w <<<"${srce}")" = 1 ]]; then
                    "$DS/add.sh" new_word "${trgt}" "$DT_r" "${srce}" & exit 1
                    
                elif [ "$(wc -w <<<"${srce}")" -ge 1 -a ${#srce} -le 180 ]; then
                    "$DS/add.sh" new_sentence "${trgt}" "$DT_r" "${srce}" & exit 1
                fi
                
            elif [ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]; then
            
                if [ "$trans" = FALSE ]; then
                    if [ -z "${srce}" ] || [ -z "${trgt}" ]; then [ "$DT_r" ] && rm -fr "$DT_r"
                    msg "$(gettext "You need to fill text fields.")\n" info " " & exit 1; fi
                fi

                if [[ "$(wc -w <<<"${trgt}")" = 1 ]]; then
                    "$DS/add.sh" new_word "${trgt}" "$DT_r" "${srce}" & exit 1
                    
                elif [ "$(wc -w <<<"${trgt}")" -ge 1 -a ${#trgt} -le 180 ]; then
                    "$DS/add.sh" new_sentence "${trgt}" "$DT_r" "${srce}" & exit 1
                fi
            fi
        else
            [ "$DT_r" ] && rm -fr "$DT_r"
            exit 1
        fi
}


new_sentence() {

    DT_r="$3"
    source "$DS/default/dicts/$lgt"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    trgt=$(clean_1 "${2}")
    srce=$(clean_1 "${4}")

    if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "Maximum number of notes has been exceeded for this topic. Max allowed (200)")" info " " & exit; fi
    
    if [ -z "${tpe}" ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    
    if [ "$trans" = TRUE ]; then
    
        internet
        cd "$DT_r"
        if [ "$trd_trgt" = TRUE ]; then
        trgt="$(translate "${trgt}" auto "$lgt")"
        trgt=$(clean_1 "${trgt}")
        fi
        srce="$(translate "${trgt}" $lgt $lgs)"
        srce="$(clean_1 "${srce}")"
        fname="$(nmfile "${trgt}")"

        if [ ! -f "$DT_r/audtm.mp3" ]; then
        
            tts "${trgt}" "$lgt" "$DT_r" "${DM_tlt}/$fname.mp3"
            
                [ ! -f "${DM_tlt}/$fname.mp3" ] && \
                voice "${trgt}" "$DT_r" "${DM_tlt}/$fname.mp3"
            
        else
            cp -f "$DT_r/audtm.mp3" "${DM_tlt}/$fname.mp3"
        fi
    
    else 
        if [ -z "$4" ] || [ -z "$2" ]; then
        [ "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" info " " & exit; fi

        fname="$(nmfile "${trgt}")"
        
        if [ -f "$DT_r/audtm.mp3" ]; then
        
            mv -f "$DT_r/audtm.mp3" "${DM_tlt}/$fname.mp3"
            
        else
            voice "${trgt}" "$DT_r" "${DM_tlt}/$fname.mp3"
        fi
    fi
    
    cd "$DT_r"
    r=$((RANDOM%1000))
    clean_3 "$DT_r" "$r"
    translate "$(sed '/^$/d' "$aw")" auto $lg | sed 's/,//g' \
    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
    check_grammar_1 "$DT_r" "$r"
    list_words "$DT_r" "$r"

    mksure "${DM_tlt}/$fname.mp3" "${trgt}" "${srce}" \
    "${grmrk}" "${lwrds}" "${pwrds}"
    
    if [ $? = 1 ]; then
        rm "${DM_tlt}/$fname.mp3"
        msg "$(gettext "An error has occurred while saving the note.")\n" dialog-warning
        [ "$DT_r" ] && rm -fr "$DT_r" & exit 1
    
    else
        tags_1 S "${trgt}" "${srce}" "${DM_tlt}/$fname.mp3"

        if [ -f "$DT_r/img.jpg" ]; then
        set_image_2 "${DM_tlt}/$fname.mp3" "${DM_tlt}/words/images/$fname.jpg"; fi

        tags_3 W "${lwrds}" "${pwrds}" "${grmrk}" "${DM_tlt}/$fname.mp3"
        notify-send "${trgt}" "${srce}\\n(${tpe})" -t 10000
        index sentence "${trgt}" "${tpe}"

        (if [ "$list" = TRUE ]; then
        "$DS/add.sh" list_words_sentence "${DM_tlt}/$fname.mp3" "${trgt}" "${tpe}"
        fi) &

        fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
        
        [ "$DT_r" ] && rm -fr "$DT_r"
        echo -e ".adi.1.adi." >> "$DC_s/8.cfg"
        exit 1
    fi
}


new_word() {

    trgt="$(clean_0 "${2}")"
    srce="$(clean_0 "${4}")"
    DT_r="$3"; cd "$DT_r"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    source "$DS/default/dicts/$lgt"

    if [[ `wc -l < "${DC_tlt}/0.cfg"` -ge 200 ]] && [[ "$5" != 0 ]]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "Maximum number of notes has been exceeded for this topic. Max allowed (200)")" info " " & exit 1; fi
    
    if [ -z "${tpe}" ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    
    if [ "$trans" = TRUE ]; then
    
        internet
        if [ "$trd_trgt" = TRUE ] && [ "$5" != 0 ]; then
        trgt="$(translate "${trgt}" auto "$lgt")"
        fi
        srce="$(translate "${trgt}" $lgt $lgs)"
        srce="$(clean_0 "${srce}")"
        fname="$(nmfile "${trgt^}")"
        audio="${trgt,,}"
        
        if [ -f "$DM_tls/$audio.mp3" ]; then
        
            cp -f "$DM_tls/$audio.mp3" "$DT_r/$audio.mp3"
            
        else
            dictt "$audio" "$DT_r"
        fi
        
        if [ -f "$DT_r/$audio.mp3" ]; then

            cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
            
        else
            voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
        fi

    else
        if [ -z "$4" ] || [ -z "$2" ]; then
        [ "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" info " " & exit 1; fi
        
        fname="$(nmfile "${trgt^}")"
        audio="${trgt,,}"
        
        if [ -f "$DT_r/audtm.mp3" ]; then
        
            mv -f "$DT_r/audtm.mp3" "${DM_tlt}/words/$fname.mp3"
            
        else
            if [ -f "$DM_tls/$audio.mp3" ]; then
            
                cp -f "$DM_tls/$audio.mp3" "$DT_r/$audio.mp3"
                
            else
                dictt "$audio" "$DT_r"
            fi
            
            if [ -f "$DT_r/$audio.mp3" ]; then

                cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
                
            else
                voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
            fi
        fi
    fi

    if [ -f "$DT_r/img.jpg" ]; then
        set_image_3 "${DM_tlt}/words/$fname.mp3" "${DM_tlt}/words/images/$fname.jpg"
    fi
    
    mksure "${DM_tlt}/words/$fname.mp3" "${trgt}" "${srce}"
    
    if [ $? = 0 ]; then
        tags_1 W "${trgt}" "${srce}" "${DM_tlt}/words/$fname.mp3"
        [[ "$5" != 0 ]] && notify-send "${trgt}" "${srce}\\n(${tpe})" -t 5000
        index word "${trgt}" "${tpe}"
        printf ".adi.1.adi." >> "$DC_s/8.cfg"
    
    else
        [ -f "${DM_tlt}/words/$fname.mp3" ] && rm "${DM_tlt}/words/$fname.mp3"
        msg "$(gettext "An error has occurred while saving the note.")\n" dialog-warning & exit 1; fi

    [ "$DT_r" ] && rm -fr "$DT_r"
    exit 1
}

list_words_edit() {

    c="$4"
    if [ "$3" = "F" ]; then

        tpe="${tpc}"
        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
        [ "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "Maximum number of notes has been exceeded for this topic. Max allowed (200)")" info " " & exit; fi
            
        if [ -z "${tpe}" ]; then
        [ "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1; fi
        
        info=" -$((200-$(wc -l < "${DC_tlt}/0.cfg")))"

        mkdir "$DT/$c"; cd "$DT/$c"

        list_words_2 "$2"
        slt=$(mktemp "$DT/slt.XXXX.x")
        
        dlg_checklist_1 ./idlst "$info" "$slt"

            if [[ $? -eq 0 ]]; then
                
                while read chkst; do
                sed 's/TRUE//g' <<<"${chkst}" >> "$DT/$c/slts"
                done <<<"$(sed 's/|//g' < "${slt}")"
                rm -f "$slt"
            fi
        
    elif [ "$3" = "S" ]; then
    
        sname="$5"
        DT_r="$DT/$c"; cd "$DT_r"
        
        n=1
        while [ $n -le "$(wc -l < "$DT_r/slts")" ]; do

                trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
                fname="$(nmfile "${trgt}")"
                audio="${trgt,,}"
                
            if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                printf "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> ./logw
            
            else
                translate "${trgt}" auto $lgs > "tr.$c"
                srce=$(< tr."$c")
                srce="$(clean_0 "${srce}")"
                
                if [ -f "$DM_tls/$audio.mp3" ]; then
                
                    cp -f "$DM_tls/$audio.mp3" "$DT_r/$audio.mp3"
                
                else
                    dictt "$audio" "$DT_r"
                fi
                
                if [ -f "$DT_r/$audio.mp3" ]; then

                    cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
                
                else
                    voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
                fi
                
                mksure "${DM_tlt}/words/$fname.mp3" "${trgt}" "${srce}"
                if [ $? = 0 ]; then
                    tags_2 W "${trgt}" "${srce}" "${5}" "${DM_tlt}/words/$fname.mp3" >/dev/null 2>&1
                    index word "${trgt}" "${tpc}" "${sname}"
                
                else
                    printf "\n\n#$n $trgt" >> ./logw
                    [ -f "${DM_tlt}/words/$fname.mp3" ] && rm "${DM_tlt}/words/$fname.mp3"; fi
            fi
            let n++
        done

        printf ".adi.$lns.adi." >> "$DC_s/8.cfg"

        if [ -f "$DT_r/logw" ]; then
        sleep 1
        dlg_info_1 "$(gettext "Some items could not be added to your list:")"; fi
        
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        rm -f logw "$DT"/*.$c & exit 1
    fi
}

list_words_sentence() {

    DM_tlt="$DM_tl/$4"
    DC_tlt="$DM_tl/$4/.conf"
    c=$((RANDOM%100))
    DT_r=$(mktemp -d "$DT/XXXXXX")
    cd "$DT_r"
    
    if [ -z "$4" ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi

    info="-$((200-$(wc -l < "${DC_tlt}/0.cfg")))"

    list_words_2 "$2"
    
    slt=$(mktemp "$DT/slt.XXXX.x")
    dlg_checklist_1 ./idlst "$info" "$slt"
    ret=$(echo "$?")
        
        if [[ $ret -eq 0 ]]; then
            
            while read chkst; do
            sed 's/TRUE//g' <<<"${chkst}"  >> ./slts
            done <<<"$(sed 's/|//g' < "${slt}")"
            rm -f "$slt"

        elif [[ $ret -eq 1 ]]; then
        
            rm -f "$DT"/*."$c"
            [ "$DT_r" ] && rm -fr "$DT_r"
            exit 1
        fi

    n=1
    while [[ $n -le "$(wc -l < ./slts | head -200)" ]]; do
    
        trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        fname="$(nmfile "${trgt}")"
        audio="${trgt,,}"
        
        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
            echo "${trgt}" >> logw
        else
            translate "${trgt}" auto "$lgs" > tr."$c"
            srce=$(< ./tr."$c")
            srce="$(clean_0 "${srce}")"

            if [ -f "$DM_tls/$audio.mp3" ]; then
            
                cp -f "$DM_tls/$audio.mp3" "$DT_r/$audio.mp3"
                
            else
                dictt "$audio" "$DT_r"
            fi
            
            if [ -f "$DT_r/$audio.mp3" ]; then

                cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
                
            else
                voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
            fi
            
            mksure "${DM_tlt}/words/$fname.mp3" "${trgt}" "${srce}"
            if [ $? = 0 ]; then
                tags_2 W "${trgt}" "${srce}" "${3}" "${DM_tlt}/words/$fname.mp3" >/dev/null 2>&1
                index word "${trgt}" "${4}"
            
            else
                printf "\n\n#$n $trgt" >> ./logw
                [ -f "${DM_tlt}/words/$fname.mp3" ] && rm "${DM_tlt}/words/$fname.mp3"
            fi
        fi
        let n++
    done

    printf ".adi.$lns.adi." >> "$DC_s/8.cfg" &

    if [ -f "$DT_r/logw" ]; then
    sleep 1
    logs="$(< "$DT_r/logw")"
    dlg_text_info_3 "$(gettext "Some items could not be added to your list:")" "$logs"; fi

    rm -f "$DT"/*."$c" 
    [ "$DT_r" ] && rm -fr "$DT_r"
    exit 1
}

list_words_dclik() {

    tpe="$(sed -n 2p "$DT/.n_s_pr")"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    DT_r=$(sed -n 1p "$DT/.n_s_pr")
    cd "$DT_r"
    echo "$3" > "$DT_r/lstws"
    
    if [ -z "${tpe}" ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    
    if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
    [ "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "Maximum number of notes has been exceeded for this topic. Max allowed (200)")" info " " & exit; fi

    info="-$((200 - $(wc -l < "${DC_tlt}/0.cfg")))"
    
    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
        (
        echo "1"
        echo "# $(gettext "Processing")..." ;
        srce="$(translate "$(cat lstws)" $lgtl $lgsl)"
        cd "$DT_r"
        r=$((RANDOM%1000))
        clean_3 "$DT_r" "$r"
        translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
        | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
        list_words "$DT_r" "$r"
        echo "$pwrds"
        list_words_3 "$DT_r/lstws" "$pwrds"
        ) | dlg_progress_1
    
    else
        list_words_3 ./lstws
    fi

    sname="$(< ./lstws)"
    slt=$(mktemp "$DT/slt.XXXX.x")
    dlg_checklist_1 ./lst "$info" "$slt"
    ret=$(echo $?)
    
    if [[ $ret -eq 0 ]]; then
    
        while read chkst; do
        sed 's/TRUE//g' <<<"${chkst}" >> "$DT_r/wrds"
        echo "$sname" >> "$DT_r/wrdsls"
        done <<<"$(sed 's/|//g' < "${slt}")"
        rm -f "$slt"
    fi
    exit 1
    
} >/dev/null 2>&1


process() {
    
    ns=$(wc -l < "${DC_tlt}/0.cfg")
    source "$DS/default/dicts/$lgt"
    if [ -f "$DT/.n_s_pr" ]; then
    tpe="$(sed -n 2p "$DT/.n_s_pr")"; fi
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    DT_r="$3"; cd "$DT_r"
    lckpr="$DT/.n_s_pr"

    if [ -z "${tpe}" ]; then
    [ -d "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
        
    if [[ $ns -ge 200 ]]; then
    [ -d "$DT_r" ] && rm -fr "$DT_r"
    msg "$(gettext "Maximum number of notes has been exceeded for this topic. Max allowed (200)")" info " "
    rm -f ./ls "$lckpr" & exit 1; fi

    if [ -f "$lckpr" ] && [ ${#@} -lt 4 ]; then
    
        msg_2 "$(gettext "Wait until it finishes a previous process")\n" info OK gtk-stop "$(gettext "Warning")"
        ret=$(echo "$?")

        if [[ $ret -eq 1 ]]; then
        rm=$(sed -n 1p "$DT/.n_s_pr")
        rm -fr "$rm" "$DT/.n_s_pr"
        "$DS/stop.sh" 5
        fi
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        exit 1
    fi
    
    if [ -n "$2" ]; then
    
        [ -d "$DT_r" ] && echo "$DT_r" > "$DT/.n_s_pr"
        [ -n "${tpe}" ] && echo "${tpe}" >> "$DT/.n_s_pr"
        lckpr="$DT/.n_s_pr"
        conten="${2}"
    fi
    include "$DS/ifs/mods/add"
    include "$DS/ifs/mods/add_process"
    
    if [ ${2:0:4} = 'Http' ]; then
        (echo "1"
        internet
        echo "# $(gettext "Processing")..." ;
        lynx -dump -nolist "${2}"  | sed -n -e '1x;1!H;${x;s-\n- -gp}' \
        | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
        | sed '/^$/d' |  sed 's/ \+/ /;s/\://;s/"//g' \
        | sed 's/^[ \t]*//;s/[ \t]*$//;s/^ *//; s/ *$//g' \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' | grep -v '^..$' \
        | grep -v '^.$' | sed 's/<[^>]\+>//;s/\://g' \
        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
        | sed 's/ — /\n/g' \
        | sed 's/[<>£§]//; s/&amp;/\&/g' | sed 's/ *<[^>]\+> */ /g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' \
        | sed 's/__/\n/g' > ./sntsls_
        ) | dlg_progress_1

    elif [ "$2" = "image" ]; then
        
        pars=`mktemp`
        trap rm "$pars*" EXIT
        scrot -s "$pars.png"
        (echo "1"
        echo "# $(gettext "Processing")..." ;
        mogrify -modulate 100,0 -resize 400% "$pars.png"
        tesseract "$pars.png" "$pars" &> /dev/null # -l $lgt
        cat "$pars.txt" | sed 's/\\n/./g' \
        | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
        |sed 's/ — /\n/g' \
        | sed 's/ \+/ /;s/\://;s/\&quot;/\"/;s/^ *//;s/ *$//g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' > ./sntsls_
        rm "$pars.png"
        ) | dlg_progress_1

    else
        if [[ ${#conten} = 1 ]]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        rm -f ./ls "$lckpr"; exit 1; fi
        (echo "1"
        echo "# $(gettext "Processing")..." ;
        if [ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]; then
        echo "${conten}" \
        | sed 's/^ *//;s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
        | sed 's/ \+/ /;s/\://;s/"//g' \
        | sed '/^$/d' | sed 's/ — /\n/g' \
        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
        | sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
        | sed 's/,/\n/g' | sed 's/。/\n/g' \
        | sed 's/__/\n/g' > ./sntsls_
        else
        echo "${conten}" \
        | sed 's/\[ \.\.\. \]//g' \
        | sed 's/^ *//;s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
        | sed 's/ \+/ /;s/\://;s/"//g' \
        | sed '/^$/d' | sed 's/ — /\n/g' \
        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
        | sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' \
        | sed 's/__/\n/g' > ./sntsls_
        fi
        ) | dlg_progress_1
    fi

    [[ -f ./sntsls ]] && rm -f ./sntsls

    lenght() {
        if [ $(wc -c <<<"${1}") -le 150 ]; then
        echo -e "${1}" >> ./sntsls
        else echo -e "[ ... ]  ${1}" >> ./sntsls; fi
        }
    
    while read l; do
    
        if [ $(wc -c <<<"${l}") -gt 150 ]; then
            if grep -o -E '\,|\;' <<<"${l}"; then

                while read -r split; do

                    if [ $(wc -c <<<"${split}") -le 150 ]; then
                        lenght "${split}"
                    else
                        while read -r split2; do
                            lenght "${split2}"
                        done < <(tr -s ';' '\n' <<<"${split}")
                    fi
                    
                done < <(sed 's/,/\n/g' <<<"${l}")
                
            else
                lenght "${l}"
            fi
            
        else
            lenght "${l}"
        fi
    done < ./sntsls_

    sed -i '/^$/d' ./sntsls
    tpe="$(sed -n 2p "$lckpr")"
    info="-$((200-ns))"

    if [ -z "$(< ./sntsls)" ]; then
    
        msg " $(gettext "Failed to get text.")\n" info

        [ -d "$DT_r" ] && rm -fr "$DT_r"
        rm -f "$lckpr" "$slt" & exit 1
    
    else
        tpe="$(sed -n 2p "$lckpr")"
        dlg_checklist_3 ./sntsls "${tpe}"
        ret=$(echo "$?")
    fi
            if [[ $ret -eq 2 ]]; then
                rm -f "$slt" &
                
                dlg_text_info_1 ./sntsls "${tpe}"
                ret=$(echo "$?")
                    
                    if [[ $ret -eq 0 ]]; then
                        "$DS/add.sh" process "$(< ./sort)" \
                        "$DT_r" "$(sed -n 2p "$lckpr")" &
                        exit 1
                    else
                        [ -d "$DT_r" ] && rm -fr "$DT_r"
                        rm -f "$lckpr" "$slt" & exit 1; fi
            
            elif [[ $ret -eq 0 ]]; then
                
                sleep 1
                tpe=$(sed -n 2p "$lckpr")
                DM_tlt="$DM_tl/${tpe}"
                DC_tlt="$DM_tl/${tpe}/.conf"
                touch slts

                if [ ! -d "${DM_tlt}" ]; then
                msg " $(gettext "An error occurred.")\n" dialog-warning
                rm -fr "$DT_r" "$lckpr" "$slt" & exit 1; fi
            
                while read chkst; do
                    sed 's/TRUE//g' <<<"${chkst}"  >> ./slts
                done <<<"$(tac "${slt}" | sed 's/|//g')"
                rm -f "$slt"
                
                cd "$DT_r"
                touch ./wlog ./slog
                {
                echo "5"
                echo "# $(gettext "Processing")... " ;
                internet
                [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ] && c=c || c=w
                
                lns="$(cat ./slts ./wrds | wc -l)"
                # ----------------------------
                n=1
                while [[ $n -le "$(wc -l < slts | head -200)" ]]; do
                
                    sntc=$(sed -n "$n"p ./slts)
                    trgt="$(clean_1 "${sntc}")"
                    if [ "$trd_trgt" = TRUE ]; then
                    trgt="$(translate "${trgt}" auto $lgt)"
                    trgt="$(clean_1 "${trgt}")"; fi
                    srce="$(translate "${trgt}" $lgt $lgs)"
                    srce="$(clean_1 "${srce}")"
                    fname=$(nmfile "${trgt}")
                
                    if [ "$(wc -$c <<<"${sntc}")" = 1 ]; then
                        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                            printf "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $sntc" >> ./wlog
                    
                        else
                            trgt="$(clean_0 "$trgt")"
                            fname=$(nmfile "$trgt")
                            srce="$(clean_0 "$srce")"
                            audio="${trgt,,}"
                            
                            dictt "$audio" "$DT_r"
                            if [ -f "$DT_r/$audio.mp3" ]; then
                                cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
                            else
                                voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
                            fi

                            mksure "${DM_tlt}/words/$fname.mp3" "${trgt}" "${srce}"
                            if [ $? = 0 ]; then
                                tags_1 W "${trgt}" "${srce}" "${DM_tlt}/words/$fname.mp3"
                                echo "${trgt}" >> addw
                                index word "${trgt}" "${tpe}"

                            else
                                printf "\n\n#$n $trgt" >> ./wlog
                                [ -f "${DM_tlt}/words/$fname.mp3" ] && rm "${DM_tlt}/words/$fname.mp3"
                            fi
                        fi

                    elif [ "$(wc -$c <<<"$sntc")" -ge 1 ]; then
                        
                        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                            printf "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $sntc" >> ./slog
                    
                        else
                            if [ ${#sntc} -ge 150 ]; then
                                printf "\n\n#$n [$(gettext "Sentence too long")] $sntc" >> ./slog
                        
                            else
                                if [ "$trans" = TRUE ]; then
                                
                                    tts "${trgt}" $lgt "$DT_r" "${DM_tlt}/$fname.mp3"
                                        [ ! -f "${DM_tlt}/$fname.mp3" ] && \
                                        voice "${trgt}" "$DT_r" "${DM_tlt}/$fname.mp3"
                                    
                                else
                                    voice "${trgt}" "${DT_r}" "${DM_tlt}/$fname.mp3"
                                fi

                                cd "$DT_r"
                                (
                                r=$((RANDOM%10000))
                                clean_3 "$DT_r" "$r"
                                translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
                                | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                                check_grammar_1 "$DT_r" "$r"
                                list_words "$DT_r" "$r"

                                mksure "${DM_tlt}/$fname.mp3" "${trgt}" "${tpe}" \
                                "${lwrds}" "${pwrds}" "${grmrk}"
                                if [ $? = 0 ]; then
                                    echo "$fname" >> adds
                                    index sentence "${trgt}" "${tpe}"
                                    tags_1 S "${trgt}" "${srce}" "${DM_tlt}/$fname.mp3"
                                    tags_3 W "${lwrds}" "${pwrds}" "${grmrk}" "${DM_tlt}/$fname.mp3"
                                    fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"

                                else
                                    printf "\n\n#$n $trgt" >> ./slog
                                    [ -f "${DM_tlt}/$fname.mp3" ] && rm "${DM_tlt}/$fname.mp3"
                                fi
                                
                                echo "__" >> x
                                rm -f "$DT"/*.$r "$aw" "$bw"
                                )
                            fi
                        fi
                    fi
                    
                    prg=$((100*n/lns-1))
                    echo "$prg"
                    echo "# ${trgt:0:35}... " ;
                    
                    let n++
                done
                
                #words
                n=1; touch wrds
                while [[ $n -le "$(wc -l < ./wrds | head -200)" ]]; do
                
                    sname=$(sed -n "$n"p wrdsls | sed 's/\[ \.\.\. \]//g')
                    trgt=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
                    fname="$(nmfile "${trgt}")"
                    audio="${trgt,,}"

                    if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                        printf "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> ./wlog
                
                    else
                        srce="$(translate "${trgt}" auto $lgs)"
                        
                        if [ -f "$DM_tls/$audio.mp3" ]; then

                            cp -f "$DM_tls/$audio.mp3" "$DT_r/$audio.mp3"
                            
                        else
                            dictt "$audio" "$DT_r"
                        fi
                        
                        if [ -f "$DT_r/$audio.mp3" ]; then

                            cp -f "$DT_r/$audio.mp3" "${DM_tlt}/words/$fname.mp3"
                            
                        else
                            voice "${trgt}" "$DT_r" "${DM_tlt}/words/$fname.mp3"
                        fi

                        mksure "${DM_tlt}/words/$fname.mp3" "${trgt}" "${srce}"
                        if [ $? = 0 ]; then
                            tags_2 W "${trgt}" "${srce}" "${sname}" "${DM_tlt}/words/$fname.mp3"
                            index word "${trgt}" "${tpe}" "${sname}"
                            echo "${trgt}" >> addw
                            
                        else
                            printf "\n\n#$n $trgt" >> ./wlog
                            [ -f "${DM_tlt}/words/$fname.mp3" ] && rm "${DM_tlt}/words/$fname.mp3"
                        fi
                    fi
                    
                    nn=$((n+$(wc -l < ./slts)-1))
                    prg=$((100*nn/lns))
                    echo "$prg"
                    echo "# ${trgt:0:35}... " ;
                    
                    let n++
                done
                } | dlg_progress_2

                cd "$DT_r"
                
                if [ -f ./wlog ]; then
                    wadds=" $(($(wc -l < ./addw) - $(sed '/^$/d' < ./wlog | wc -l)))"
                    W=" $(gettext "Words")"
                    if [ "$wadds" = 1 ]; then
                    W=" $(gettext "Word")"; fi
                else
                    wadds=" $(wc -l < ./addw)"
                    W=" $(gettext "Words")"
                    if [ "$wadds" = 1 ]; then
                    wadds=" $(wc -l < ./addw)"
                    W=" $(gettext "Word")"; fi
                fi
                if [ -f ./slog ]; then
                    sadds=" $(($( wc -l < ./adds) - $(sed '/^$/d' < ./slog | wc -l)))"
                    S=" $(gettext "sentences")"
                    if [ "$sadds" = 1 ]; then
                    S=" $(gettext "sentence")"; fi
                else
                    sadds=" $(wc -l < ./adds)"
                    S=" $(gettext "sentences")"
                    if [ "$sadds" = 1 ]; then
                    S=" $(gettext "sentence")"; fi
                fi
                
                logs=$(cat ./slog ./wlog)
                adds=$(cat ./adds ./addw | wc -l)
                
                if [[ $adds -ge 1 ]]; then
                    notify-send -i idiomind "${tpe}" \
                    "$(gettext "Have been added:")\n$sadds$S$wadds$W" -t 2000 &
                    printf ".adi.$adds.adi." >> "$DC_s/8.cfg"
                fi
                
                if [ "$(cat ./slog ./wlog | wc -l)" -ge 1 ]; then
                sleep 1
                dlg_text_info_3 "$(gettext "Some items could not be added to your list:")" "$logs" >/dev/null 2>&1
                fi
                
                [ -d "$DT_r" ] && rm -fr "$DT_r"
                rm -f "$lckpr"
                
            else
                cp -f "${DC_tlt}/0.cfg" "${DC_tlt}/.11.cfg"
                [ -d "$DT_r" ] && rm -fr "$DT_r"
                 rm -f "$lckpr" "$slt" & exit 1
            fi
}

case "$1" in
    new_topic)
    new_topic "$@" ;;
    new_items)
    new_items "$@" ;;
    new_sentence)
    new_sentence "$@" ;;
    new_word)
    new_word "$@" ;;
    list_words_edit)
    list_words_edit "$@" ;;
    list_words_dclik)
    list_words_dclik "$@" ;;
    list_words_sentence)
    list_words_sentence "$@" ;;
    process)
    process "$@" ;;
esac
