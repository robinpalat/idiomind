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
wlist=$(grep -o wlist=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')
trans=$(grep -o trans=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')
ttrgt=$(grep -o ttrgt=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')

new_topic() {
    
    if [[ $(wc -l < "$DM_tl/.1.cfg") -ge 120 ]]; then
    msg "$(gettext "Sorry, you have reached the maximum number of topics")" info Info &
    exit 1; fi

    jlbi=$(dlg_form_0 "${2}")
    ret="$?"
    jlb="$(clean_3 "${jlbi}")"
    
    if [[ ${#jlb} -gt 55 ]]; then
    msg "$(gettext "Sorry, name too long.")\n" info
    "$DS/add.sh" new_topic "${jlb}" & exit 1; fi
    
    if grep -Fxo "${jlb}" < <(ls "$DS/addons/"); then jlb="${jlb} (1)"; fi
    chck=$(grep -Fxo "${jlb}" "$DM_tl/.1.cfg" | wc -l)
    
    if [[ ${chck} -ge 1 ]]; then
        
        for i in {1..50}; do
        chck=$(grep -Fxo "${jlb} ($i)" "$DM_t/$language_target/.1.cfg")
        [ -z "${chck}" ] && break; done
        jlb="${jlb} ($i)"
        msg_2 "$(gettext "Another topic with the same name already exist.")\n$(gettext "The name for the newest will be\:")\n<b>${jlb}</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        [[ $ret -eq 1 ]] && exit 10
        
    else jlb="${jlb}"; fi
    
    if [ -n "${jlb}" ]; then
    
        mkdir "$DM_tl/${jlb}"
        list_inadd > "$DM_tl/.2.cfg"
        "$DS/default/tpc.sh" "${jlb}" 1
        "$DS/mngr.sh" mkmn
    fi
    exit
}


new_items() {

    if [ ! -d "$DT" ]; then new_session; fi
    [ ! "$DT/tpe" ] && echo "${tpc}" > "$DT/tpe"
    
    if [ "$(grep -vFx 'Podcasts' "$DM_tl/.1.cfg" | wc -l)" -lt 1 ]; then
    cleanups "$DT_r"
    "$DS/chng.sh" "$(gettext "To start adding notes you need to have a topic.
Create one using the button below. ")" & exit 1; fi

    [ -z "${4}" ] && txt="$(xclip -selection primary -o)" || txt="${4}"
    txt="$(clean_4 "${txt}")"
    
    [ -d "${2}" ] && DT_r="${2}"
    [ -n "${5}" ] && srce="${5}" || srce=""

    [ -f "$DT_r/ico.jpg" ] && img="$DT_r/ico.jpg" \
    || img="$DS/images/nw.png"
    
    tpcs=$(grep -vFx "${tpe}" "$DM_tl/.2.cfg" \
    | tr "\\n" '!' | sed 's/\!*$//g')
    [ -n "$tpcs" ] && e='!'; [ -z "${tpe}" ] && tpe=' '

    if [[ "$3" != 3 ]]; then
    
        if [ "$trans" = TRUE ]; then lzgpr="$(dlg_form_1)"; \
        else lzgpr="$(dlg_form_2)"; fi
        
        ret="$?"
        trgt=$(echo "${lzgpr}" | head -n -1 | sed -n 1p)
        srce=$(echo "${lzgpr}" | sed -n 2p)
        chk=$(echo "${lzgpr}" | tail -1)
        tpe=$(grep -Fxo "${chk}" "$DM_tl/.1.cfg")
    else
        trgt="${4}"
        srce="${5}"
    fi

        if [[ $ret -eq 3 ]]; then
        
            [ -d "$2" ] && DT_r="$2" || DT_r=$(mktemp -d "$DT/XXXXXX")
            echo "${tpe}" > "$DT/tpe"
            cd "$DT_r"; set_image_1
            "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
        elif [[ $ret -eq 2 ]]; then
        
            [ -d "$2" ] && DT_r="$2" || DT_r=$(mktemp -d "$DT/XXXXXX")
            echo "${tpe}" > "$DT/tpe"
            "$DS/ifs/tls.sh" add_audio "$DT_r"
            "$DS/add.sh" new_items "$DT_r" 2 "${trgt}" "${srce}" && exit
        
        elif [[ $ret -eq 0 ]]; then

            if [ "$3" = 2 ]; then
            [ -d "$2" ] && DT_r="$2" || DT_r=$(mktemp -d "$DT/XXXXXX")
            else DT_r=$(mktemp -d "$DT/XXXXXX"); fi
            xclip -i /dev/null; cd "$DT_r"
        
            if [ -z "${chk}" ] && [[ "$3" != 3 ]]; then cleanups "$DT_r"
            msg "$(gettext "No topic is active")\n" info & exit 1; fi

            if [ -z "${trgt}" ]; then
            cleanups "$DT_r"; exit 1; fi

            if [[ "${chk}" = "$(gettext "New") *" ]]; then
            "$DS/add.sh" new_topic
            else echo "${tpe}" > "$DT/tpe"; fi
            
            if [[ "${trgt}" = Ocr ]] || [[ ${trgt^} = I ]]; then
                "$DS/add.sh" process image "$DT_r" & exit 1

            elif [[ ${#trgt} = 1 ]]; then
                "$DS/add.sh" process ${trgt:0:2} "$DT_r" & exit 1

            elif [[ ${trgt:0:4} = 'Http' ]]; then
                "$DS/add.sh" process "${trgt}" "$DT_r" & exit 1
            
            elif [[ ${#trgt} -gt 150 ]]; then
                "$DS/add.sh" process "${trgt}" "$DT_r" & exit 1
                
            elif [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
            
                if [ "$trans" = FALSE ] && ([ -z "${srce}" ] || [ -z "${trgt}" ]); then
                cleanups "$DT_r"
                msg "$(gettext "You need to fill text fields.")\n" info " " & exit 1; fi

                srce=$(translate "${trgt}" auto $lgs)
                
                if [[ "$(wc -w <<<"${srce}")" = 1 ]]; then
                    "$DS/add.sh" new_word "${trgt}" "$DT_r" "${srce}" & exit 1
                    
                elif [ "$(wc -w <<<"${srce}")" -ge 1 -a ${#srce} -le 180 ]; then
                    "$DS/add.sh" new_sentence "${trgt}" "$DT_r" "${srce}" & exit 1
                fi
                
            elif [ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]; then
            
                if [ "$trans" = FALSE ]; then
                    if [ -z "${srce}" ] || [ -z "${trgt}" ]; then cleanups "$DT_r"
                    msg "$(gettext "You need to fill text fields.")\n" info " " & exit 1; fi
                fi

                if [[ "$(wc -w <<<"${trgt}")" = 1 ]]; then
                    "$DS/add.sh" new_word "${trgt}" "$DT_r" "${srce}" & exit 1
                    
                elif [ "$(wc -w <<<"${trgt}")" -ge 1 -a ${#trgt} -le 180 ]; then
                    "$DS/add.sh" new_sentence "${trgt}" "$DT_r" "${srce}" & exit 1
                fi
            fi
        else
            cleanups "$DT_r"
            exit 1
        fi
}


new_sentence() {

    DT_r="$3"
    source "$DS/default/dicts/$lgt"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    trgt="$(clean_2 "${2}")"
    srce="$(clean_2 "${4}")"
    check_s "${tpe}"
    
    if [ "$trans" = TRUE ]; then
    
        internet
        cd "$DT_r"
        if [ "$ttrgt" = TRUE ]; then
        trgt="$(translate "${trgt}" auto "$lgt")"
        trgt=$(clean_2 "${trgt}"); fi
        srce="$(translate "${trgt}" $lgt $lgs)"
        srce="$(clean_2 "${srce}")"
        
    else 
        if [ -z "${4}" ] || [ -z "${2}" ]; then
        cleanups "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" info " " & exit; fi
    fi
    
    sentence_p "$DT_r" 1
    mksure "${trgt}" "${srce}" "${grmr}" "${wrds}"
    id="$(set_name_file 1 "${trgt}" "${srce}" "" "" "" "${wrds}" "${grmr}")"
    
    
    if [ $? = 1 ]; then
        msg "$(gettext "An error has occurred while saving the note.")\n" dialog-warning
        cleanups "$DT_r" & exit 1
    
    else
        index 2 "${tpe}" "${trgt}" "${srce}" "" "" "${wrds}" "${grmr}" "$id"
        if [ -f "$DT_r/img.jpg" ]; then
        mv -f  "$DT_r/img.jpg" "${DM_tlt}/images/$id.jpg"; fi

        if [ ! -f "$DT_r/audtm.mp3" ]; then
        
             if [ "$trans" = TRUE ]; then
             
                tts "${trgt}" "$lgt" "$DT_r" "${DM_tlt}/$id.mp3"
                    [ ! -f "${DM_tlt}/$id.mp3" ] && \
                    voice "${trgt}" "$DT_r" "${DM_tlt}/$id.mp3"
                
            else
                voice "${trgt}" "$DT_r" "${DM_tlt}/$id.mp3"
            fi
            
        else
            mv -f "$DT_r/audtm.mp3" "${DM_tlt}/$id.mp3"
        fi

        notify-send "${trgt}" "${srce}\\n(${tpe})" -t 10000

        (if [ "$wlist" = TRUE ] && [ -n "${wrds}" ]; then
        "$DS/add.sh" list_words_sentence "${wrds}" "${trgt}" "${tpe}"
        fi) &

        fetch_audio "$aw" "$bw"
        
        cleanups "$DT_r"
        echo -e ".adi.1.adi." >> "$DC_s/log"
        exit 1
    fi
}


new_word() {

    trgt="$(clean_1 "${2}")"
    srce="$(clean_1 "${4}")"
    DT_r="$3"; cd "$DT_r"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    source "$DS/default/dicts/$lgt"
    check_s "${tpe}"

    if [ "$trans" = TRUE ]; then
    
        internet
        if [ "$ttrgt" = TRUE ] && [[ "${5}" != 0 ]]; then
        trgt="$(translate "${trgt}" auto "$lgt")"
        trgt="$(clean_1 "${trgt}")"; fi
        srce="$(translate "${trgt}" $lgt $lgs)"
        srce="$(clean_1 "${srce}")"
        
    else 
        if [ -z "${4}" ] || [ -z "${2}" ]; then
        cleanups "$DT_r"
        msg "$(gettext "You need to fill text fields.")\n" info " " & exit; fi
    fi
    
    audio="${trgt,,}"
    mksure "${trgt}" "${srce}"
    id="$(set_name_file 1 "${trgt}" "${srce}" "${exmp_}" "" "" "" "")"
    
    if [ $? = 1 ]; then
        cleanups "$DT_r"
        msg "$(gettext "An error has occurred while saving the note.")\n" dialog-warning
        exit 1
    
    else
        index 1 "${tpe}" "${trgt}" "${srce}" "${exmp_}" "" "" "" "${id}"

        if [ -f "$DT_r/img.jpg" ]; then
        set_image_2 "$DT_r/img.jpg" "${DM_tlt}/images/$id.jpg"; fi

        if [ ! -f "$DT_r/audtm.mp3" ]; then
        
            if [ ! -f "${DM_tls}/$audio.mp3" ]; then

                dictt "$audio" "${DM_tls}"
            fi
            
        else
            mv -f "$DT_r/audtm.mp3" "${DM_tls}/$audio.mp3"
        fi

        notify-send "${trgt}" "${srce}\\n(${tpe})" -t 10000

        cleanups "${DT_r}"
        echo -e ".adi.1.adi." >> "$DC_s/log"
        exit
    fi
}


list_words_edit() {

    c="${4}"
    if [[ ${3} = 1 ]]; then

        tpe="${tpc}"
        check_s "${tpe}"
        info=" -$((200-$(wc -l < "${DC_tlt}/0.cfg")))"
        mkdir "$DT/$c"; cd "$DT/$c"

        list_words_2 "${2}"
        
        slt=$(mktemp "$DT/slt.XXXX.x")
        dlg_checklist_1 "$DT/$c/idlst" "$info" "$slt"

            if [[ $? -eq 0 ]]; then
                
                while read chkst; do
                sed 's/TRUE//g' <<<"${chkst}" >> "$DT/$c/slts"
                done <<<"$(sed 's/|//g' < "${slt}")"
                rm -f "$slt"
            fi
        
    elif [[ $3 = 2 ]]; then
    
        exmp_="${5}"
        DT_r="$DT/$c"; cd "$DT_r"
        
        n=1
        while [[ ${n} -le "$(wc -l < "$DT_r/slts")" ]]; do

            if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                echo -e "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> ./logw
            
            else
                trgt="$(clean_1 "$(sed -n ${n}p "$DT_r/slts")")"
                audio="${trgt,,}"
                translate "${trgt}" auto $lgs > "$DT_r/tr.$c"
                srce=$(< "$DT_r/tr.$c")
                srce="$(clean_1 "${srce}")"
                id="$(set_name_file 1 "${trgt}" "${srce}" "${exmp_}" "" "" "" "")"
                mksure "${trgt}" "${srce}"

                if [ $? = 0 ]; then
                
                    index 1 "${tpe}" "${trgt}" "${srce}" "${exmp_}" "" "" "" "${id}"
                    if [ ! -f "$DM_tls/$audio.mp3" ]; then
                    dictt "$audio" "$DM_tls"; fi
                
                else
                    echo -e "\n\n#$n $trgt" >> "$DT_r/logw"
                    cleanups "${DM_tlt}/$id.mp3"; fi
            fi
            let n++
        done

        if [ -f "$DT_r/logw" ]; then
        dlg_text_info_3 "$(gettext "Some items could not be added to your list"):"; fi
        echo -e ".adi.$lns.adi." >> "$DC_s/log"
    fi
    cleanups "${DT_r}" "$slt"; exit
}

list_words_sentence() {

    DM_tlt="$DM_tl/${4}"
    DC_tlt="$DM_tl/${4}/.conf"
    exmp_="${3}"
    c=$((RANDOM%100))
    DT_r=$(mktemp -d "$DT/XXXXXX")
    cd "$DT_r"
    check_s "${tpe}"
    info="-$((200-$(wc -l < "${DC_tlt}/0.cfg")))"

    list_words_2 "${2}"
    
    slt=$(mktemp "$DT/slt.XXXX.x")
    dlg_checklist_1 "$DT_r/idlst" "${info}" "$slt"
    ret="$?"
        
        if [[ $ret -eq 0 ]]; then
            
            while read chkst; do
            sed 's/TRUE//g' <<<"${chkst}"  >> "$DT_r/slts"
            done <<<"$(sed 's/|//g' < "${slt}")"
            rm -f "$slt"

        elif [[ $ret -eq 1 ]]; then
        
            rm -f "$DT"/*."$c"
            cleanups "$DT_r"
            exit 1
        fi

    n=1
    while [[ ${n} -le "$(wc -l < "$DT_r/slts" | head -200)" ]]; do
    
        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
            echo "${trgt}" >> "$DT_r/logw"
        else
            trgt="$(clean_1 "$(sed -n ${n}p "$DT_r/slts")")"
            audio="${trgt,,}"
            translate "${trgt}" auto $lgs > "$DT_r/tr.$c"
            srce=$(< "$DT_r/tr.$c")
            srce="$(clean_1 "${srce}")"
            mksure "${trgt}" "${srce}"
            id="$(set_name_file 1 "${trgt}" "${srce}" "${exmp_}" "" "" "" "")"
            
            if [ $? = 0 ]; then

                index 1 "${tpe}" "${trgt}" "${srce}" "${exmp_}" "" "" "" "${id}"
                if [ ! -f "$DM_tls/$audio.mp3" ]; then
                dictt "$audio" "$DM_tls"; fi
            
            else
                echo -e "\n\n#$n $trgt" >> "$DT_r/logw"
            fi
        fi
        let n++
    done

    if [ -f "$DT_r/logw" ]; then
    logs="$(< "$DT_r/logw")"
    dlg_text_info_3 "$(gettext "Some items could not be added to your list"):" "$logs"; fi
    cleanups "$DT_r"
    echo -e ".adi.$lns.adi." >> "$DC_s/log"
    exit
}

list_words_dclik() {

    tpe="$(sed -n 2p "$DT/.n_s_pr")"
    DM_tlt="$DM_tl/${tpe}"
    DC_tlt="$DM_tl/${tpe}/.conf"
    DT_r=$(sed -n 1p "$DT/.n_s_pr")
    cd "$DT_r"
    echo "${3}" > "$DT_r/lstws"
    check_s "${tpe}"
    info="-$((200 - $(wc -l < "${DC_tlt}/0.cfg")))"
    
    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
        (
        echo "1"
        echo "# $(gettext "Processing")..." ;
        srce="$(translate "$(cat "$DT_r/lstws")" $lgtl $lgsl)"
        cd "$DT_r"
        sentence_p "$DT_r" 1
        echo "$wrds"
        list_words_3 "$DT_r/lstws" "${wrds}"
        ) | dlg_progress_1
    
    else
        list_words_3 "$DT_r/lstws"
    fi

    sname="$(< "$DT_r/lstws")"
    slt=$(mktemp "$DT/slt.XXXX.x")
    dlg_checklist_1 "$DT_r/lst" "${info}" "$slt"
    ret="$?"
    
    if [[ $ret -eq 0 ]]; then
    
        while read chkst; do
        sed 's/TRUE//g' <<<"${chkst}" >> "$DT_r/wrds"
        echo "$sname" >> "$DT_r/wrdsls"
        done <<<"$(sed 's/|//g' < "${slt}")"
        cleanups "$slt"
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
    check_s "${tpe}"

    if [ -f "$lckpr" ] && [ ${#@} -lt 4 ]; then
    
        msg_2 "$(gettext "Wait until it finishes a previous process")\n" info OK gtk-stop "$(gettext "Warning")"
        ret="$?"

        if [[ $ret -eq 1 ]]; then
        rm=$(sed -n 1p "$DT/.n_s_pr")
        cleanups "${rm}" "$DT/.n_s_pr"
        "$DS/stop.sh" 5
        fi
        cleanups "$DT_r"
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
    
    if [[ ${2:0:4} = Http ]]; then
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
        | sed 's/__/\n/g' > "$DT_r/sntsls_"
        ) | dlg_progress_1

    elif [[ $2 = image ]]; then
        
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
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' > "$DT_r/sntsls_"
        rm "$pars.png"
        ) | dlg_progress_1

    else
        if [[ ${#conten} = 1 ]]; then
        cleanups "$DT_r" "$lckpr"; exit 1; fi
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
        | sed 's/__/\n/g' > "$DT_r/sntsls_"
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
        | sed 's/__/\n/g' > "$DT_r/sntsls_"
        fi
        ) | dlg_progress_1
    fi

    [ -f "$DT_r/sntsls" ] && rm -f "$DT_r/sntsls"

    lenght() {
        if [ $(wc -c <<<"${1}") -le 150 ]; then
        echo -e "${1}" >> "$DT_r/sntsls"
        else echo -e "[ ... ]  ${1}" >> "$DT_r/sntsls"; fi
        }
        
    if [ ${#@} -lt 4 ]; then
    
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
        done < "$DT_r/sntsls_"

    else mv "$DT_r/sntsls_" "$DT_r/sntsls"; fi
    
    sed -i '/^$/d' "$DT_r/sntsls"
    tpe="$(sed -n 2p "$lckpr")"
    info="-$((200-ns))"

    if [ -z "$(< "$DT_r/sntsls")" ]; then
    
        msg " $(gettext "Failed to get text.")\n" info
        cleanups "$DT_r" "$lckpr" "$slt" & exit 1
    
    else
        tpe="$(sed -n 2p "$lckpr")"
        dlg_checklist_3 "$DT_r/sntsls" "${tpe}"
        ret="$?"
    fi
            if [[ $ret -eq 2 ]]; then
                cleanups "$slt"
                
                dlg_text_info_1 "$DT_r/sntsls" "${tpe}"
                ret="$?"
                    
                    if [[ $ret -eq 0 ]]; then
                        "$DS/add.sh" process "$(< "$DT_r/sort")" \
                        "$DT_r" "$(sed -n 2p "$lckpr")" &
                        exit 1
                    else
                        cleanups "$DT_r" "$lckpr" "$slt" & exit 1; fi
            
            elif [[ $ret -eq 0 ]]; then
                
                sleep 1
                tpe=$(sed -n 2p "$lckpr")
                DM_tlt="$DM_tl/${tpe}"
                DC_tlt="$DM_tl/${tpe}/.conf"
                touch "$DT_r/slts"

                if [ ! -d "${DM_tlt}" ]; then
                msg " $(gettext "An error occurred.")\n" dialog-warning
                cleanups "$DT_r" "$lckpr" "$slt" & exit 1; fi
            
                while read chkst; do
                    sed 's/TRUE//g' <<<"${chkst}"  >> "$DT_r/slts"
                done <<<"$(tac "${slt}" |sed '/^$/d' |sed 's/|//g')"
                cleanups "$slt"

                touch "$DT_r/wlog" "$DT_r/slog" "$DT_r/adds" \
                "$DT_r/addw" "$DT_r/wrds"
               
                {
                echo "5"
                echo "# $(gettext "Processing")... " ;
                internet
                [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ] && c=c || c=w
                
                lns="$(cat "$DT_r/slts" "$DT_r/wrds" |sed '/^$/d' |wc -l)"
                # ----------------------------
                n=1
                while [[ ${n} -le $(wc -l < "$DT_r/slts" | head -200) ]]; do
                
                    sntc="$(sed -n ${n}p "$DT_r/slts")"
                    trgt="$(clean_2 "${sntc}")"
                    if [ "$ttrgt" = TRUE ]; then
                    trgt="$(translate "${trgt}" auto $lgt)"
                    trgt="$(clean_2 "${trgt}")"; fi
                    srce="$(translate "${trgt}" $lgt $lgs)"
                    srce="$(clean_2 "${srce}")"
                    id="$(set_name_file 2 "${trgt}" "${srce}" "" "" "" "" "")"

                    if [[ $(wc -$c <<<"${sntc}") = 1 ]]; then
                        if [ "$(wc -l < "${DC_tlt}/0.cfg")" -ge 200 ]; then
                            echo -e "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] ${sntc}" >> "$DT_r/wlog"
                    
                        else
                            trgt="$(clean_1 "${trgt}")"
                            srce="$(clean_1 "${srce}")"
                            id="$(set_name_file 1 "${trgt}" "${srce}" "" "" "" "" "")"
                            audio="${trgt,,}"
                            mksure "${trgt}" "${srce}"
                            
                            if [ $? = 0 ]; then

                                index 1 "${tpe}" "${trgt}" "${srce}" "" "" "" "" "${id}"
                                if [ ! -f "$DM_tls/$audio.mp3" ]; then
                                dictt "$audio" "$DM_tls/$audio.mp3"; fi
                                echo "${trgt}" >> "$DT_r/addw"

                            else
                                echo -e "\n\n#$n ${trgt}" >> "$DT_r/wlog"
                                rm "${DM_tlt}/$id.mp3"
                            fi
                        fi

                    elif [[ $(wc -$c <<<"${sntc}") -ge 1 ]]; then
                        
                        if [[ $(wc -l < "${DC_tlt}/0.cfg") -ge 200 ]]; then
                            echo -e "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $sntc" >> "$DT_r/slog"
                    
                        else
                            if [ ${#sntc} -ge 150 ]; then
                                echo -e "\n\n#$n [$(gettext "Sentence too long")] $sntc" >> "$DT_r/slog"
                        
                            else
                                cd "$DT_r"
                                (
                                sentence_p "$DT_r" 1
                                mksure "${trgt}" "${srce}" "${wrds}" "${grmr}"
                                id="$(set_name_file 1 "${trgt}" "${srce}" "" "" "" "${wrds}" "${grmr}")"
                                
                                if [ $? = 0 ]; then

                                    index 2 "${tpe}" "${trgt}" "${srce}" "" "" "${wrds}" "${grmr}" "${id}"
                                    if [ "$trans" = TRUE ]; then
                                    tts "${trgt}" $lgt "$DT_r" "${DM_tlt}/$id.mp3"
                                    [ ! -f "${DM_tlt}/$id.mp3" ] && voice "${trgt}" "$DT_r" "${DM_tlt}/$id.mp3"
                                    else voice "${trgt}" "${DT_r}" "${DM_tlt}/$id.mp3"; fi
                                    fetch_audio "$aw" "$bw"
                                    echo "${trgt}" >> "$DT_r/adds"
                                    ((adds=adds+1))

                                else
                                    echo -e "\n\n#$n $trgt" >> "$DT_r/slog"
                                    rm "${DM_tlt}/$id.mp3"
                                fi
                                rm -f "$aw" "$bw"
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
                if [ -n "$(< "$DT_r/wrds")" ]; then
                
                    n=1
                    while [[ ${n} -le $(wc -l < "$DT_r/wrds" | head -200) ]]; do
                    
                        exmp_=$(sed -n ${n}p "$DT_r/wrdsls" |sed 's/\[ \.\.\. \]//g')
                        trgt=$(sed -n ${n}p "$DT_r/wrds" | awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
                        audio="${trgt,,}"
                        
                        if [[ $(wc -l < "${DC_tlt}/0.cfg") -ge 200 ]]; then
                            echo -e "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] ${trgt}" >> "$DT_r/wlog"
                    
                        else
                            srce="$(translate "${trgt}" auto $lgs)"
                            mksure "${trgt}" "${srce}"
                            id="$(set_name_file 1 "${trgt}" "${srce}" "${exmp_}" "" "" "" "")"
                            
                            if [ $? = 0 ]; then

                                index 1 "${tpc}" "${trgt}" "${srce}" "${exmp_}" "" "" "" "${id}"
                                if [ ! -f "${DM_tls}/$audio.mp3" ]; then
                                dictt "$audio" "${DM_tls}"; fi
                                echo "${trgt}" >> "$DT_r/addw"

                            else
                                echo -e "\n\n#$n $trgt" >> "$DT_r/wlog"
                                cleanups "${DM_tlt}/$id.mp3"
                            fi
                        fi
                        
                        nn=$((n+$(wc -l < "$DT_r/slts")-1))
                        prg=$((100*nn/lns))
                        echo "$prg"
                        echo "# ${trgt:0:35}... " ;
                        
                        let n++
                    done
                fi
                
                } | dlg_progress_2
                
                wadds=" $(($(wc -l < "$DT_r/addw")-$(sed '/^$/d' < "$DT_r/wlog" | wc -l)))"
                W=" $(gettext "words")"
                if [ "$wadds" = 1 ]; then
                W=" $(gettext "word")"; fi
                sadds=" $(($( wc -l < "$DT_r/adds")-$(sed '/^$/d' < "$DT_r/slog" | wc -l)))"
                S=" $(gettext "sentences")"
                if [ "$sadds" = 1 ]; then
                S=" $(gettext "sentence")"; fi
                log=$(cat "$DT_r/slog" "$DT_r/wlog")
                adds=$(cat "$DT_r/adds" "$DT_r/addw" |sed '/^$/d' | wc -l)
                
                if [[ $adds -ge 1 ]]; then
                    notify-send -i idiomind "${tpe}" \
                    "$(gettext "Have been added:")\n$sadds$S$wadds$W" -t 2000 &
                    echo -e ".adi.$adds.adi." >> "$DC_s/log"
                fi
                
                if [ -n "$log" ]; then
                sleep 1
                dlg_text_info_3 "$(gettext "Some items could not be added to your list"):" "$log" >/dev/null 2>&1
                fi
                
                cleanups "$DT_r" "$lckpr"
                
            else
                cleanups "$DT_r" "$lckpr" & exit
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
