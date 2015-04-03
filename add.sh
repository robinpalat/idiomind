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
source "$DC_s/1.cfg"

function new_topic() {

    if [ "$(wc -l < "$DM_tl/.1.cfg")" -ge 80 ]; then
    msg "$(gettext "Sorry, you have reached the maximum number of topics")" info Info &&
    killall add.sh & exit 1; fi
    
    jlbi=$(dlg_form_0 "$(gettext "New Topic")")
    ret=$(echo "$?")
    jlb="$(clean_2 "$jlbi")"
    sfname=$(cat "$DM_tl/.1.cfg" | grep -Fxo "$jlb" | wc -l)
    
    if [ "$sfname" -ge 1 ]; then
    jlb="$jlb $sfname"
    msg_2 " $(gettext "You already have a topic with the same name.") \n $(gettext "The new it was renamed to\:")\n  <b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
    ret=$(echo "$?")
    [ "$ret" -eq 1 ] && exit 1
    else
    jlb="$jlb"; fi
    
    if [ -z "$jlb" ]; then
        exit 1
    else
        mkdir "$DM_tl/$jlb"
        cp -f "$DS/default/tpc.sh" "$DM_tl/$jlb/tpc.sh"
        chmod +x "$DM_tl/$jlb/tpc.sh"
        echo "$jlb" >> "$DM_tl/.2.cfg"
        "$DM_tl/$jlb/tpc.sh" 1
        "$DS/mngr.sh" mkmn
    fi
    exit 1
}

function new_items() {

    if [ "$(grep -v 'Feeds' < $DM_tl/.1.cfg | wc -l)" -lt 1 ]; then
    [ -d "$DT_r" ] && rm -fr "$DT_r"
    "$DS/chng.sh" "$(gettext "To start adding notes you need have a topic.
Create one using the button below. ")" & exit 1; fi

    [ -z "$4" ] && txt="$(xclip -selection primary -o \
    | sed ':a;N;$!ba;s/\n/ /g' | sed '/^$/d')" || txt="$4"
    
    if [ "$3" = 2 ]; then
    DT_r="$2"; cd "$DT_r"
    [ -n "$5" ] && srce="$5" || srce=""; else
    DT_r=$(mktemp -d $DT/XXXXXX); cd "$DT_r"; fi
    
    [ -f "$DT_r/ico.jpg" ] && img="$DT_r/ico.jpg" \
    || img="$DS/images/nw.png"

    if [ -z "$tpe" ]; then
    tpcs=$(sed -n '1!G;h;$p' < "$DM_tl/.2.cfg" | cut -c 1-40  \
    | tr "\\n" '!' | sed 's/\!*$//g'); else
    tpcs=$(sed -n '1!G;h;$p' < "$DM_tl/.2.cfg" \
    | egrep -v "$tpe" | cut -c 1-40 \
    | tr "\\n" '!' | sed 's/\!*$//g'); fi
    
    [ -n "$tpcs" ] && e='!'; [ -z "$tpe" ] && tpe=' '
    ltopic="${tpe:0:50}"
    [ "$tpe" != "$tpc" ] && \
    atopic="<small><b><i>$(gettext "Topic")</i></b></small>" || \
    atopic="<small>$(gettext "Topic")</small>"

    if [ "$trans" = TRUE ]; then lzgpr="$(dlg_form_1)"; \
    else lzgpr="$(dlg_form_2)"; fi

    ret=$(echo "$?")
    trgt=$(echo "$lzgpr" | head -n -1 | sed -n 1p | sed 's/^\s*./\U&\E/g')
    srce=$(echo "$lzgpr" | sed -n 2p | sed 's/^\s*./\U&\E/g')
    chk=$(echo "$lzgpr" | tail -1)
    tpe=$(cat "$DM_tl/.1.cfg" | grep "$chk")
    
        if [ $ret -eq 3 ]; then
        
            cd "$DT_r"; set_image_1
            "$DS/add.sh" new_items "$DT_r" 2 "$trgt" "$srce" && exit
        
        elif [ $ret -eq 2 ]; then
        
            "$DS/ifs/tls.sh" add_audio "$DT_r"
            "$DS/add.sh" new_items "$DT_r" 2 "$trgt" "$srce" && exit
        
        elif [ $ret -eq 0 ]; then
        
            if [ -z "$chk" ]; then
                [ -d "$DT_r" ] && rm -fr "$DT_r"
                msg "$(gettext "No topic is active")\n" info & exit 1
            fi
        
            if [ -z "$trgt" ]; then
                [ -d "$DT_r" ] && rm -fr "$DT_r"
                exit 1
            fi

            if [ $(echo "$tpe" | wc -l) -ge 2 ]; then
                
                if [[ $(echo "$tpe" | sed -n 1p | wc -w) \
                = $(echo "$chk" | wc -w) ]]; then
                    slt=$(echo "$tpe" | sed -n 1p)
                    tpe="$slt"
                elif [[ $(echo "$tpe" | sed -n 2p | wc -w) \
                = $(echo "$chk" | wc -w) ]]; then
                    slt=$(echo "$tpe" | sed -n 2p)
                    tpe="$slt"
                else
                    slt=$(dlg_radiolist_1 "$tpe")
                    
                    if [ -z "$(echo "$slt" | sed -n 2p)" ]; then
                        killall add.sh & exit 1
                    fi
                    tpe=$(echo "$slt" | sed -n 2p)
                fi
            fi
            if [[ "$chk" = "$(gettext "New topic") *" ]]; then
                "$DS/add.sh" new_topic
            else
                echo "$tpe" > "$DT/tpe"
            fi
            
            if [ "$(echo "$trgt")" = I ]; then
                "$DS/add.sh" process image "$DT_r" & exit 1

            elif [[ $(printf "$trgt" | wc -c) = 1 ]]; then
                "$DS/add.sh" process "${trgt:0:2}" "$DT_r" & exit 1

            elif [[ "$(echo ${trgt:0:4})" = 'Http' ]]; then
                "$DS/add.sh" process "$trgt" "$DT_r" & exit 1
            
            elif [ $(echo "$trgt" | wc -c) -gt 150 ]; then
                "$DS/add.sh" process "$trgt" "$DT_r" & exit 1

            elif [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
            
                if [ "$trans" = FALSE ]; then
                    if [ -z "$srce" ] || [ -z "$trgt" ]; then
                        [ -d "$DT_r" ] && rm -fr "$DT_r"
                        msg "$(gettext "You need to fill text fields.") $lgsl." info & exit 1; fi
                fi

                srce=$(translate "$trgt" auto $lgs)
                
                if [ $(echo "$srce" | wc -w) = 1 ]; then
                    "$DS/add.sh" new_word "$trgt" "$DT_r" "$srce" & exit 1
                    
                elif [ $(echo "$srce" | wc -w) -ge 1 -a $(echo "$srce" | wc -c) -le 180 ]; then
                    "$DS/add.sh" new_sentence "$trgt" "$DT_r" "$srce" & exit 1
                fi
            elif [ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]; then
            
                if [ "$trans" = FALSE ]; then
                    if [ -z "$srce" ] || [ -z "$trgt" ]; then
                        [ -d "$DT_r" ] && rm -fr "$DT_r"
                        msg "$(gettext "You need to fill text fields.") $lgsl." info & exit 1; fi
                fi
            
                if [ $(echo "$trgt" | wc -w) = 1 ]; then
                    "$DS/add.sh" new_word "$trgt" "$DT_r" "$srce" & exit 1
                    
                elif [ $(echo "$trgt" | wc -w) -ge 1 -a $(echo "$trgt" | wc -c) -le 180 ]; then
                    "$DS/add.sh" new_sentence "$trgt" "$DT_r" "$srce" & exit 1
                    
                fi
            fi
        else
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            exit 1
        fi
}

function new_sentence() {
        
    DT_r="$3"
    source "$DS/default/dicts/$lgt"
    source "$DC_s/1.cfg"
    DM_tlt="$DM_tl/$tpe"
    DC_tlt="$DM_tl/$tpe/.conf"
    icnn=idiomind

    if [ $(wc -l < "$DC_tlt/0.cfg") -ge 200 ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You have reached the maximum number of items.")" info Info & exit
    fi
    if [ -z "$tpe" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1
    fi
    
    if [ "$trans" = TRUE ]; then
    
        internet
        cd "$DT_r"
        trgt=$(translate "$(clean_1 "$2")" auto $lgt | sed ':a;N;$!ba;s/\n/ /g')
        srce=$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
        fname="$(nmfile "$trgt")"
        
        if [ ! -f "$DT_r/audtm.mp3" ]; then
        
            tts "$trgt" $lgt "$DT_r" "$DM_tlt/$fname.mp3"
            
        else
            cp -f "$DT_r/audtm.mp3" "$DM_tlt/$fname.mp3"
        fi
    
    else 
        if [ -z "$4" ] || [ -z "$2" ]; then
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            msg "$(gettext "You need to fill text fields.") $lgsl." info & exit; fi
        
        trgt=$(echo "$(clean_1 "$2")" | sed ':a;N;$!ba;s/\n/ /g')
        srce=$(echo "$(clean_1 "$4")" | sed ':a;N;$!ba;s/\n/ /g')
        fname="$(nmfile "$trgt")"
        
        if [ -f "$DT_r/audtm.mp3" ]; then
        
            mv -f "$DT_r/audtm.mp3" "$DM_tlt/$fname.mp3"
            
        else
            voice "$trgt" "$DT_r" "$DM_tlt/$fname.mp3"
        fi
    fi
    
    if [ -z $(file -ib "$DM_tlt/$fname.mp3" | grep -o 'binary') ] \
    || [ ! -f "$DM_tlt/$fname.mp3" ] || [ -z "$trgt" ] || [ -z "$srce" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg " $(gettext "Something unexpected has occurred while saving the note.")\n" dialog-warning & exit 1; fi
    
    add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3"

    if [ -f img.jpg ]; then
        set_image_2 "$DM_tlt/$fname.mp3" "$DM_tlt/words/images/$fname.jpg"
        icnn=img.jpg
    fi
    
    cd "$DT_r"
    r=$(echo $(($RANDOM%1000)))
    clean_3 "$DT_r" "$r"
    translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
    check_grammar_1 "$DT_r" "$r"
    list_words "$DT_r" "$r"
    grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < g.$r)
    lwrds=$(< A.$r)
    pwrds=$(tr '\n' '_' < B.$r)
    
    if [ -z "$grmrk" ] || [ -z "$lwrds" ] || [ -z "$pwrds" ]; then
        rm "$DM_tlt/$fname.mp3"
        msg " $(gettext "Something unexpected has occurred while saving the note.")\n" dialog-warning 
        [ -d "$DT_r" ] && rm -fr "$DT_r" & exit 1; fi
    
    add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3"
    notify-send -i "$icnn" "$trgt" "$srce\\n($tpe)" -t 10000
    index sentence "$trgt" "$tpe"
    
    (if [ "$list" = TRUE ]; then
    "$DS/add.sh" sentence_list_words "$DM_tlt/$fname.mp3" "$trgt" "$tpe"
    fi) &

    fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
    
    [ -d "$DT_r" ] && rm -fr "$DT_r"
    printf "aitm.1.aitm\n" >> "$DC_s/8.cfg"
    exit 1
}

function new_word() {

    trgt="$(sed s'\|\\'g <<<"$2")"
    srce="$4"
    icnn=idiomind
    DT_r="$3"
    cd "$DT_r"
    DM_tlt="$DM_tl/$tpe"
    DC_tlt="$DM_tl/$tpe/.conf"
    
    if [ $(wc -l < "$DC_tlt/1.cfg") -ge 200 ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You have reached the maximum number of items.")" info Info & exit 0; fi
    if [ -z "$tpe" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1
    fi
    
    internet

    if [ "$trans" = TRUE ]; then

        trgt="$(translate "$trgt" auto $lgt)"
        srce="$(translate "$trgt" $lgt $lgs)"
        fname="$(nmfile "${trgt^}")"
        
        if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
        
            cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
            
        else
            dictt "${trgt,,}" "$DT_r"
        fi
        
        if [ -f "$DT_r/${trgt,,}.mp3" ]; then

            cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
            
        else
            voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
        fi

    else
        if [ -z "$4" ] || [ -z "$2" ]; then
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            msg "$(gettext "You need to fill text fields.") $lgsl." info & exit 1; fi
        
        trgt="$2"
        srce="$4"
        fname="$(nmfile "${trgt^}")"
        
        if [ -f audtm.mp3 ]; then
        
            mv -f audtm.mp3 "$DM_tlt/words/$fname.mp3"
            
        else
            if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
            
                cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
                
            else
                dictt "${trgt,,}" "$DT_r"
            fi
            
            if [ -f "$DT_r/${trgt,,}.mp3" ]; then

                cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
                
            else
                voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
            fi
        fi
    fi

    if [ -f img.jpg ]; then
        set_image_3 "$DM_tlt/words/$fname.mp3" "$DM_tlt/words/images/$fname.jpg"
        icnn=img.jpg
    fi
    
    if [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
    && [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ]; then
    
        add_tags_1 W "$trgt" "$srce" "$DM_tlt/words/$fname.mp3"
        nt="$(echo "_$(check_grammar_2 "$trgt")" | tr '\n' '_')"
        eyeD3 --set-encoding=utf8 -A IWI3I0I"$nt"IWI3I0I "$DM_tlt/words/$fname.mp3"
        notify-send -i "$icnn" "$trgt" "$srce\\n($tpe)" -t 5000
        index word "$trgt" "$tpe"
        printf "aitm.1.aitm\n" >> "$DC_s/8.cfg"
    
    else
        [ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
        msg " $(gettext "Something unexpected has occurred while saving the note.")\n" dialog-warning & exit 1; fi

    [ -d "$DT_r" ] && rm -fr "$DT_r"
    rm -f *.jpg
    exit 1
}

function edit_list_words() {

    c="$4"
    if [ "$3" = "F" ]; then

        tpe="$tpc"
        if [ $(wc -l < "$DC_tlt/0.cfg") -ge 200 ]; then
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            msg "$(gettext "You have reached the maximum number of items.")" info Info & exit; fi
        if [ -z "$tpe" ]; then
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            msg "$(gettext "No topic is active")\n" info & exit 1
        fi
        
        nw=$(wc -l < "$DC_tlt/3.cfg")
        left=$((200 - $nw))
        info="$(gettext "You can add") $left $(gettext "Words")"
        if [ $nw -ge 195 ]; then
            info="$(gettext "You can add") $left $(gettext "Words")"
        elif [ $nw -ge 199 ]; then
            info="$(gettext "You can add") $left $(gettext "Word")"
        fi

        mkdir "$DT/$c"; cd "$DT/$c";

        list_words_2 "$2"
        slt=$(mktemp $DT/slt.XXXX.x)
        
        dlg_checklist_1 ./idlst "$info" "$slt"

            if [ $? -eq 0 ]; then
                
                while read chkst; do
                    sed 's/TRUE//g' <<<"$chkst" >> "$DT/$c/slts"
                done <<<"$(sed 's/|//g' < "$slt")"
                rm -f "$slt"
            fi
        
    elif [ "$3" = "S" ]; then
    
        sname="$5"
        DT_r="$DT/$c"
        cd "$DT_r"
        
        n=1
        while [ $n -le $(wc -l < "$DT_r/slts") ]; do

                trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
                fname="$(nmfile "$trgt")"
                
            if [ $(wc -l < "$DC_tlt/0.cfg") -ge 200 ]; then
                printf "\n- $trgt" >> ./logw
            
            else
                translate "$trgt" auto $lgs > "tr.$c"
                srce=$(< tr."$c")
                
                if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
                
                    cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
                
                else
                    dictt "${trgt,,}" "$DT_r"
                fi
                
                if [ -f "$DT_r/${trgt,,}.mp3" ]; then

                    cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
                
                else
                    voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
                fi
                
                if [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
                && [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ]; then
                
                    add_tags_2 W "$trgt" "$srce" "$5" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                    index word "$trgt" "$tpc" "$sname"
                
                else
                    printf "\n- $sntc" >> ./logw
                    [ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"; fi
            fi
            let n++
        done

        printf "aitm.$lns.aitm\n" >> "$DC_s/8.cfg"

            if [ -f "$DT_r/logw" ]; then
                dlg_info_1 " $(gettext "Some items could not be added to your list.")"; fi
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            rm -f logw "$DT"/*.$c & exit 1
    fi
}

function dclik_list_words() {

    tpe=$(sed -n 2p $DT/.n_s_pr)
    DM_tlt="$DM_tl/$tpe"
    DC_tlt="$DM_tl/$tpe/.conf"
    DT_r=$(sed -n 1p $DT/.n_s_pr)
    tpe=$(sed -n 2p $DT/.n_s_pr)
    cd "$DT_r"
    echo "$3" > ./lstws
    
    if [ -z "$tpe" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1
    fi
    
    nw=$(wc -l < "$DC_tlt/3.cfg")
    
    if [ $(cat "$DC_tlt/0.cfg" | wc -l) -ge 200 ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You have reached the maximum number of items.")" info Info & exit; fi

    left=$((200 - $nw))
    info="$(gettext "You can add") $left $(gettext "Words")"
    if [ $nw -ge 195 ]; then
        info="$(gettext "You can add") $left $(gettext "Words")"
    elif [ $nw -ge 199 ]; then
        info="$(gettext "You can add") $left $(gettext "Word")"
    fi
    
    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
        (
            echo "1"
            echo "# $(gettext "Processing")..." ;
            srce="$(translate "$(cat lstws)" $lgtl $lgsl)"
            cd "$DT_r"
            r=$(echo $(($RANDOM%1000)))
            clean_3 "$DT_r" "$r"
            translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
            | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
            list_words "$DT_r" "$r"
            pwrds=$(tr '\n' '_' < "B.$r")
            echo "$pwrds"
            list_words_3 ./lstws "$pwrds"
        ) | dlg_progress_1
    
    else
        list_words_3 ./lstws
    fi

    sname="$(cat lstws)"
    slt=$(mktemp $DT/slt.XXXX.x)
    dlg_checklist_1 ./lst " " "$slt"
    
    if [ $? -eq 0 ]; then
    
            while read chkst; do
                sed 's/TRUE//g' <<<"$chkst" >> ./wrds
                echo "$sname" >> wrdsls
            done <<<"$(sed 's/|//g' < "$slt")"
            rm -f "$slt"

        elif [ "$ret" -eq 1 ]; then
        
        rm -f "$DT"/*."$c"
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        exit
        fi
        
    "$?" >/dev/null 2>&1
    exit 1
}

function sentence_list_words() {

    DM_tlt="$DM_tl/$4"
    DC_tlt="$DM_tl/$4/.conf"
    c=$(echo $(($RANDOM%100)))
    DT_r=$(mktemp -d $DT/XXXXXX)
    cd "$DT_r"
    
    if [ -z "$4" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1; fi
    
    nw=$(wc -l < "$DC_tlt/3.cfg")
    left=$((200 - $nw))
    if [ "$left" = 0 ]; then
        exit 1
    elif [ $nw -ge 195 ]; then
        info="$(gettext "You can add") $left $(gettext "Words")"
    elif [ $nw -ge 199 ]; then
        info="$(gettext "You can add") $left $(gettext "Word")"; fi
    
    list_words_2 "$2"
    
    slt=$(mktemp $DT/slt.XXXX.x)
    dlg_checklist_1 ./idlst "$info" "$slt"
    ret=$(echo "$?")
        
        if [ $ret -eq 0 ]; then
            
            while read chkst; do
                sed 's/TRUE//g' <<<"$chkst"  >> ./slts
            done <<<"$(sed 's/|//g' < "$slt")"
            rm -f "$slt"

        elif [ "$ret" -eq 1 ]; then
        
            rm -f "$DT"/*."$c"
            [ -d "$DT_r" ] && rm -fr "$DT_r"
            exit 1
        fi

    n=1
    while [ $n -le $(wc -l < ./slts | head -200) ]; do
    
        trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        fname="$(nmfile "$trgt")"
        
        if [ $(cat "$DC_tlt/0.cfg" | wc -l) -ge 200 ]; then
            echo "$trgt" >> logw
        else
            translate "$trgt" auto $lgs > tr."$c"
            srce=$(cat ./tr."$c")

            if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
            
                cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
                
            else
                dictt "${trgt,,}" "$DT_r"
            fi
            
            if [ -f "$DT_r/${trgt,,}.mp3" ]; then

                cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
                
            else
                voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
            fi
            
            if [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
            && [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ]; then
                
                add_tags_2 W "$trgt" "$srce" "$3" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                index word "$trgt" "$4"
            
            else
                printf "\n- $sntc" >> ./logw
                [ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
            fi
        fi
        let n++
    done

    printf "aitm.$lns.aitm\n" >> "$DC_s/8.cfg" &

    if [ -f  "$DT_r/logw" ]; then
        logs="$(< $DT_r/logw)"
        text_r1=" $(gettext "Some items could not be added to your list.")\n\n$logs "
        dlg_text_info_3 "$text_r1"; fi

    rm -f "$DT"/*."$c" 
    [ -d "$DT_r" ] && rm -fr "$DT_r"
    exit 1
}

function process() {
    
    wth=$(($(sed -n 2p $DC_s/10.cfg)-50))
    eht=$(($(sed -n 3p $DC_s/10.cfg)-50))
    ns=$(wc -l < "$DC_tlt/0.cfg")
    source "$DS/default/dicts/$lgt"
    if [ -f "$DT/.n_s_pr" ]; then
    tpe="$(sed -n 2p "$DT/.n_s_pr")"; fi
    DM_tlt="$DM_tl/$tpe"
    DC_tlt="$DM_tl/$tpe/.conf"
    DT_r="$3"; cd "$DT_r"
    lckpr="$DT/.n_s_pr"

    if [ -z "$tpe" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1; fi
        
    if [ $ns -ge 200 ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You have reached the maximum number of items.")" info Info
        rm -f ls "$lckpr" & exit 1; fi

    if [ -f "$lckpr" ] && [ -z "$4" ]; then
    
        msg_2 "$(gettext "Wait till it finishes a previous process")\n" info OK gtk-stop "$(gettext "Warning")"
        ret=$(echo "$?")

        if [ $ret -eq "1" ]; then
            rm=$(sed -n 1p "$DT/.n_s_pr")
            rm fr "$rm" "$DT/.n_s_pr"
            index R && killall add.sh; fi
        exit 1
    fi
    
    if [ -n "$2" ]; then
        [ -d "$DT_r" ] && echo "$DT_r" > "$DT/.n_s_pr"
        [ -n "$tpe" ] && echo "$tpe" >> "$DT/.n_s_pr"
        lckpr="$DT/.n_s_pr"
        prdt="$2"
    fi
    include "$DS/ifs/mods/add"
    include "$DS/ifs/mods/add_process"
    
    if [ "$(echo ${2:0:4})" = 'Http' ]; then
    
        internet
        
        (
        echo "1"
        echo "# $(gettext "Processing")..." ;
        lynx -dump -nolist "$2"  | sed -n -e '1x;1!H;${x;s-\n- -gp}' \
        | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
        | sed '/^$/d' |  sed 's/ \+/ /;s/\://;s/"//g' \
        | sed 's/^[ \t]*//;s/[ \t]*$//;s/^ *//; s/ *$//g' \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' | grep -v '^..$' \
        | grep -v '^.$' | sed 's/<[^>]\+>//;s/\://g' \
        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
        | sed 's/[<>£§]//; s/&amp;/\&/g' | sed 's/ *<[^>]\+> */ /g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' > ./sntsls_
        #iconv -c -f utf8 -t ascii
        ) | dlg_progress_1

    elif echo "$2" | grep -o "image"; then
        
        SCR_IMG=`mktemp`
        trap "rm $SCR_IMG*" EXIT
        scrot -s $SCR_IMG.png
        
        (
        echo "1"
        echo "# $(gettext "Processing")..." ;
        mogrify -modulate 100,0 -resize 400% $SCR_IMG.png
        tesseract $SCR_IMG.png $SCR_IMG &> /dev/null # -l $lgt
        cat $SCR_IMG.txt | sed 's/\\n/./g' \
        | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
        | sed 's/ \+/ /;s/\://;s/"//;s/^ *//;s/ *$//g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' > ./sntsls_> ./sntsls_
        
        ) | dlg_progress_1

    else
        (
        echo "1"
        echo "# $(gettext "Processing")..." ;
        echo "$prdt" \
        | sed 's/^ *//;s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
        | sed 's/ \+/ /;s/\://;s/"//g' \
        | sed '/^$/d' | iconv -c -f utf8 -t ascii \
        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
        | sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' > ./sntsls_

        ) | dlg_progress_1
    fi
    
        [[ -f ./sntsls ]] && rm -f ./sntsls
        
        sed -i '/^$/d' ./sntsls_
        tpe="$(sed -n 2p "$lckpr")"
        [[ $(echo "$tpe" | wc -c) -gt 60 ]] \
        && tcnm="${tpe:0:60}..." || tcnm="$tpe"
        
        left=$((200 - $ns))
        info="$(gettext "You can add") $left $(gettext "items")"
        if [ $ns -ge 195 ]; then
            info="$(gettext "You can add") $left $(gettext "items")"
        elif [ $ns -ge 199 ]; then
            info="$(gettext "You can add") $left $(gettext "items")"; fi

        if [ -z "$(< ./sntsls_)" ]; then
        
            msg " $(gettext "Failed to get text.")\n" info

            [ -d "$DT_r" ] && rm -fr "$DT_r"
            rm -f "$lckpr" "$slt" & exit 1
        
        else
            tpe="$(sed -n 2p "$lckpr")"
            dlg_checklist_3 ./sntsls_ "$tpe"
            ret=$(echo "$?")
            
        fi
                if [ $ret -eq 2 ]; then
                    rm -f "$slt" &
                    
                    dlg_text_info_1 ./sntsls_ "$tpe"
                    ret=$(echo "$?")
                        
                        if [ $ret -eq 0 ]; then
                            "$DS/add.sh" process "$(cat ./sort)" \
                            $DT_r "$(sed -n 2p "$lckpr")" &
                            exit 1
                        else
                            [ -d "$DT_r" ] && rm -fr "$DT_r"
                            rm -f "$slt" & exit 1; fi
                
                elif [ $ret -eq 0 ]; then
                
                    tpe=$(sed -n 2p "$lckpr")
                    DM_tlt="$DM_tl/$tpe"
                    DC_tlt="$DM_tl/$tpe/.conf"

                    if [ ! -d "$DM_tlt" ]; then
                        msg " $(gettext "An error occurred.")\n" dialog-warning
                        rm -fr "$DT_r" "$lckpr" "$slt" & exit 1; fi
                
                    while read chkst; do
                        sed 's/TRUE//g' <<<"$chkst"  >> ./slts
                    done <<<"$(tac "$slt" | sed 's/|//g')"
                    rm -f "$slt"

                    internet
                    cd "$DT_r"
                    touch ./wlog ./slog
                    
                    {
                    echo "5"
                    echo "# $(gettext "Processing")... " ;
                    [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ] && c=c || c=w
                    
                    lns=$(cat ./slts ./wrds | wc -l)

                    n=1
                    while [ $n -le $(wc -l < slts | head -200) ]; do
                    
                        sntc=$(sed -n "$n"p slts)
                        trgt=$(translate "$(clean_1 "$sntc")" auto $lgt | sed ':a;N;$!ba;s/\n/ /g')
                        srce=$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                        fname="$(nmfile "$trgt")"
                    
                        # words
                        if [ $(wc -$c <<<"$sntc") = 1 ]; then
                            if [ $(wc -l < "$DC_tlt"/0.cfg) -ge 200 ]; then
                                printf "\n- $sntc" >> ./wlog
                        
                            else
                                if [ "$trans" = TRUE ]; then
            
                                    tts "$trgt" $lgt "$DT_r" "$DM_tlt/words/$fname.mp3"
                                    
                                else
                                    voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
                                fi

                                if [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
                                && [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ]; then
                                
                                    add_tags_1 W "$trgt" "$srce" "$DM_tlt/words/$fname.mp3"
                                    echo "$trgt" >> addw
                                    index word "$trgt" "$tpe"

                                else
                                    printf "\n- $sntc" >> ./wlog
                                    [ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
                                fi
                            fi
                        
                        #sentences 
                        elif [ $(wc -$c <<<"$sntc") -ge 1 ]; then
                            
                            if [ $(wc -l < "$DC_tlt/0.cfg") -ge 200 ]; then
                                printf "\n- $sntc" >> ./slog
                        
                            else
                                if [ $(wc -c <<<"$sntc") -ge 150 ]; then
                                    printf "\n- $sntc" >> ./slog
                            
                                else
                                    if [ "$trans" = TRUE ]; then
                                    
                                        tts "$trgt" $lgt "$DT_r" "$DM_tlt/$fname.mp3"
                                        
                                    else
                                        voice "$trgt" "$DT_r" "$DM_tlt/$fname.mp3"
                                        
                                    fi
                                    
                                    add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3"
                                    
                                    (
                                    cd "$DT_r"
                                    r=$(echo $(($RANDOM%1000)))
                                    clean_3 "$DT_r" "$r"
                                    translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
                                    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                                    check_grammar_1 "$DT_r" "$r"
                                    list_words "$DT_r" "$r"
                                    grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < "g.$r" )
                                    lwrds=$(< "A.$r")
                                    pwrds=$(tr '\n' '_' < "B.$r")
                                    
                                    if [ -n $(file -ib "$DM_tlt/$fname.mp3" | grep -o 'binary') ] \
                                    && [ -f "$DM_tlt/$fname.mp3" ] && [ -n "$lwrds" ] && [ -n "$pwrds" ] && [ -n "$grmrk" ]; then
                                    
                                        echo "$fname" >> adds
                                        index sentence "$trgt" "$tpe"
                                        add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3"
                                        fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"

                                    else
                                        printf "\n- $sntc" >> ./slog
                                        [ -f "$DM_tlt/$fname.mp3" ] && rm "$DM_tlt/$fname.mp3"
                                    fi
                                    
                                    echo "__" >> x
                                    rm -f "$DT"/*.$r "$aw" "$bw"
                                    
                                    ) &
                                    
                                    rm -f "$fname.mp3"
                                fi
                            fi
                        fi
                        
                        prg=$((100*$n/$lns-1))
                        echo "$prg"
                        echo "# ${trgt:0:35}... " ;
                        
                        let n++
                    done
                    
                    #words
                    n=1; touch wrds
                    while [ $n -le $(wc -l < wrds | head -200) ]; do
                    
                        sname=$(sed -n "$n"p wrdsls)
                        trgt=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
                        fname="$(nmfile "$trgt")"

                        if [ $(wc -l < "$DC_tlt/0.cfg") -ge 200 ]; then
                            printf "\n- $trgt" >> ./wlog
                    
                        else
                            srce="$(translate "$trgt" auto $lgs)"
                            
                            if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
    
                                cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
                                
                            else
                                dictt "${trgt,,}" "$DT_r"
                            fi
                            
                            if [ -f "$DT_r/${trgt,,}.mp3" ]; then

                                cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
                                
                            else
                                voice "$trgt" "$DT_r" "$DM_tlt/words/$fname.mp3"
                            fi


                            if [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
                            && [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ]; then
                                add_tags_2 W "$trgt" "$srce" "$sname" "$DM_tlt/words/$fname.mp3"
                                index word "$trgt" "$tpe" "$sname"
                                echo "$trgt" >> addw
                            else
                                printf "\n- $sntc" >> ./wlog
                                [ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
                            fi
                        fi
                        
                        nn=$(($n+$(wc -l < ./slts)-1))
                        prg=$((100*$nn/$lns))
                        echo "$prg"
                        echo "# ${trgt:0:35}... " ;
                        
                        let n++
                    done
                    } | dlg_progress_2

                    cd $DT_r
                    
                    if [ -f ./wlog ]; then
                        wadds=" $(($(wc -l < ./addw) - $(sed '/^$/d' < ./wlog | wc -l)))"
                        W=" $(gettext "Words")"
                        if [ $(echo $wadds) = 1 ]; then
                            W=" $(gettext "Word")"
                        fi
                    else
                        wadds=" $(wc -l < ./addw)"
                        W=" $(gettext "Words")"
                        if [ $(echo $wadds) = 1 ]; then
                            wadds=" $(wc -l < ./addw)"
                            W=" $(gettext "Word")"
                        fi
                    fi
                    if [ -f ./slog ]; then
                        sadds=" $(($( wc -l < ./adds) - $(sed '/^$/d' < ./slog | wc -l)))"
                        S=" $(gettext "sentences")"
                        if [ $(echo $sadds) = 1 ]; then
                            S=" $(gettext "sentence")"
                        fi
                    else
                        sadds=" $(wc -l < ./adds)"
                        S=" $(gettext "sentences")"
                        if [ $(echo $sadds) = 1 ]; then
                            S=" $(gettext "sentence")"
                        fi
                    fi
                    
                    logs=$(cat ./slog ./wlog)
                    adds=$(cat ./adds ./addw | wc -l)
                    
                    if [ $adds -ge 1 ]; then
                        notify-send -i idiomind "$tpe" \
                        "$(gettext "Have been added:")\n$sadds$S$wadds$W" -t 2000 &
                        printf "aitm.$adds.aitm\n" >> "$DC_s/8.cfg"
                    fi
                    
                    if [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
                        
                        dlg_text_info_3 " $(gettext "Some items could not be added to your list.")\n\n$logs " >/dev/null 2>&1
                    fi
                    if  [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
                        rm=$(($(cat ./addw ./adds | wc -l) - $(cat ./slog ./wlog | sed '/^$/d' | wc -l)))
                    else
                        rm=$(cat ./addw ./adds | wc -l)
                    fi
                    
                    n=1
                    while [ $n -le 20 ]; do
                         sleep 5
                         if [ $(wc -l < ./x) -eq "$rm" ] || [ $n = 20 ]; then
                            [ -d "$DT_r" ] && rm -fr "$DT_r"
                            cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
                            rm -f "$lckpr" & break; exit 1
                         fi
                        let n++
                    done
                    
                else
                    cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
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
    edit_list_words)
    edit_list_words "$@" ;;
    dclik_list_words)
    dclik_list_words "$@" ;;
    sentence_list_words)
    sentence_list_words "$@" ;;
    process)
    process "$@" ;;
esac
