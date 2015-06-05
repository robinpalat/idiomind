#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function dlg_checklist_5() {
    
    cmd_edit_="$DS/ifs/mods/add_process/a_.sh 'item_for_edit'"
    cmd_newtopic="$DS/add.sh 'new_topic'"
    slt=$(mktemp "$DT/slt.XXXX.x")
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$2" \
    --text="<small>$info</small> " \
    --name=Idiomind --class=Idiomind \
    --dclick-action="$cmd_edit_" \
    --window-icon="$DS/images/icon.png" \
    --text-align=right --center --sticky \
    --width=600 --height=550 --borders=3 \
    --column="$(wc -l < "$1")" \
    --column="$(gettext "Items")" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "New Topic")":"cmd_newtopic" \
    --button=gtk-add:0 > "$slt"
}

function dlg_text_info_5() {
    
    echo "$1" | yad --text-info --title=" " \
    --name=Idiomind --class=Idiomind \
    --editable \
    --window-icon="$DS/images/icon.png" \
    --margins=5 --wrap \
    --center --sticky \
    --width=520 --height=150 --borders=5 \
    --button=Ok:0 > "$1.txt"
}

function dlg_text_info_4() {
    
    echo "$1" | yad --text-info --title=Idiomind \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --text=" " \
    --margins=8 --wrap \
    --center --sticky \
    --width=600 --height=550 --borders=5 \
    --button=Ok:0
}

function audio_recog() {
    
    echo "$(wget -q -U -T 200 "Mozilla/5.0" --post-file "$1" \
    --header="Content-Type: audio/x-flac; rate=16000" \
    -O - "https://www.google.com/speech-api/v2/recognize?&lang="$2"-"$3"&key=$4")"
}

function dlg_file_1() {
    
    yad --file --title="Speech recognize" \
    --name=Idiomind --class=Idiomind \
    --file-filter="*.mp3 *.tar *.zip" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --on-top --center \
    --width=600 --height=450 --borders=0
}

function dlg_file_2() {
    
    yad --file --save --title="Save" \
    --name=Idiomind --class=Idiomind \
    --filename="$(date +%m-%d-%Y)"_audio.tar.gz \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=600 --height=500 --borders=10 \
    --button=gtk-ok:0
}

if [[ "$conten" = A ]]; then

    cd "$DT_r"
    left=$((200 - $(wc -l < "$DC_tlt/4.cfg")))
    key="$(sed -n 2p "$HOME/.config/idiomind/addons/gts.cfg" \
    | grep -o key=\"[^\"]* | grep -o '[^"]*$')"
    test="$DS/addons/Google translator/test.flac"
    LNK='https://console.developers.google.com'
    source "$DS/ifs/mods/cmns.sh"
    
    if [ -z "$key" ]; then
    msg "$(gettext "For this feature you need to provide a key. Please get one from the:")   <a href='$LNK'>console.developers.google.com</a>\n" dialog-warning
    [ "$DT_r" ] && rm -fr "$DT_r"
    rm -f ls "$lckpr" & exit 1; fi
    
    cd "$HOME"; fl="$(dlg_file_1)"
    
    if [ -z "$fl" ];then
    [ "$DT_r" ] && rm -fr "$DT_r"
    rm -f "$lckpr" & exit 1
        
    else
        sleep 1
        if [ -z "$tpe" ]; then
        [ "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "No topic is active")\n" info & exit 1; fi
        
        (
        echo "2"
        echo "# $(gettext "Processing... Wait.")";
        cd "$DT_r"
        
        if grep ".mp3" <<<"${fl: -4}"; then
        
            cp -f "$fl" "$DT_r/rv.mp3"
            #eyeD3 -P itunes-podcast --remove "$DT_r"/rv.mp3
            eyeD3 --remove-all "$DT_r/rv.mp3"
            sox "$DT_r/rv.mp3" "$DT_r/c_rv.mp3" remix - highpass 100 norm \
            compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 \
            vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse \
            vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse norm -0.5
            rm -f "$DT_r/rv.mp3"
            mp3splt -s -o @n *.mp3
            c="$(ls [0-9]*.mp3 | wc -l)"
            if [[ $c -ge 1 ]]; then
            rename 's/^0*//' *.mp3
            elif [ $(du "$DT_r/c_rv.mp3" | cut -f1) -lt 400 ]; then
            mv -f "$DT_r/c_rv.mp3" "$DT_r/1.mp3"
            fi
            [ -f "$DT_r/c_rv.mp3" ] && rm -f "$DT_r/c_rv.mp3"
            
        elif grep ".tar" <<<"${fl: -4}"; then
        
            cp -f "$fl" "$DT_r/rv.tar"
            tar -xvf "$DT_r/rv.tar"
            
        elif grep ".zip" <<<"${fl: -4}"; then
        
            cp -f "$fl" "$DT_r/rv.zip"
            unzip "$DT_r/rv.zip"
        fi
        
        n=1; r=$c
        while [[ $n -le $c ]]; do
        mv -f ./$n.mp3 ./_$r.mp3
        ((n=n+1))
        ((r=r-1))
        done
        rename 's/^_*//' *.mp3
        
        internet
        echo "3"
        echo "# $(gettext "Checking key")..."; sleep 1
        data="$(audio_recog "$test" $lgt $lgt $key)"
        if [ -z "$data" ]; then
        key=$(sed -n 3p $DC_s/3.cfg)
        data="$(audio_recog "$test" $lgt $lgt $key)"; fi
        if [ -z "$data" ]; then
        key=$(sed -n 4p $DC_s/3.cfg)
        data="$(audio_recog "$test" $lgt $lgt $key)"; fi
        if [ -z "$data" ]; then
        msg "$(gettext "The key is invalid or has exceeded its quota of daily requests")" error
        [ "$DT_r" ] && rm -fr "$DT_r"
        rm -f "$lckpr" & exit 1; fi
        
        echo "# $(gettext "Processing")..." ; sleep 0.2
        cd "$DT_r"
        tpe=$(sed -n 2p "$DT/.n_s_pr")
        DM_tlt="$DM_tl/$tpe"
        DC_tlt="$DM_tl/$tpe/.conf"

        if [ ! -d "$DM_tlt" ]; then
        msg " $(gettext "An error occurred.")\n" dialog-warning
        rm -fr "$DT_r" "$lckpr" "$slt" & exit 1; fi
        
        cd "$DT_r"
        touch ./wrds ./addw

        echo "1"
        echo "# $(gettext "Processing")...";
        internet
        if [ $lgt = ja ] || [ $lgt = "zh-cn" ] || [ $lgt = ru ];
        then c=c; else c=w; fi
        # ---------------
        cd "$DT_r"
        lns="$(ls ./[0-9]*.mp3 | wc -l | head -200)"
        n=1
        while [[ $n -le $lns ]]; do

            if [ -f "./$n.mp3" ]; then
            
                sox "./$n.mp3" info.flac rate 16k
                data="$(audio_recog ./info.flac $lgt $lgt $key)"
                
                if [ -z "${data}" ]; then
                msg "$(gettext "The key is invalid or has exceeded its quota of daily requests")\n" error
                "$DS/stop.sh" 5
                [ "$DT_r" ] && rm -fr "$DT_r"
                rm -f ls "$lckpr" & break & exit 1; fi

                trgt="$(echo "${data}" | sed '1d' \
                | sed 's/.*transcript":"//' \
                | sed 's/"}],"final":true}],"result_index":0}//g' \
                | sed 's/.*transcript":"//g' \
                | sed 's/","confidence"://g' \
                | sed "s/[0-9].[0-9]//g" \
                | sed 's/}],"final":true}],"result_index":0}//g')"

                if [ ${#trgt} -ge 400 ]; then
                printf "\n\n#$n [$(gettext "Sentence too long")] $trgt" >> ./slog
                
                elif [ -z "$trgt" ]; then
                trgt="#$n [$(gettext "Text missing")]"
                index txt_missing "$trgt" "$tpe"
                fname=$(nmfile "$trgt")
                cp -f "$n.mp3" "$DM_tlt/$fname.mp3"
                printf "\n\n#$n [$(gettext "Text missing")]" >> ./slog
                
                elif [ "$(wc -l < "$DC_tlt"/0.cfg)" -ge 200 ]; then
                printf "\n\n#$n [$(gettext "Maximum number of notes has been exceeded")] $trgt" >> ./slog
                
                else
                    trgt=$(clean_1 "${trgt}")
                    srce="$(translate "${trgt}" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')"
                    srce="$(clean_1 "${srce}")"
                    fname=$(nmfile "${trgt}")
                    
                    if [ $(wc -$c <<<"${trgt}") -eq 1 ]; then
                    
                        trgt="$(clean_0 "${trgt}")"
                        fname=$(nmfile "${trgt}")
                        srce="$(clean_0 "${srce}")"
                        mv -f "$n.mp3" "$DM_tlt/words/$fname.mp3"
                        
                        mksure "$DM_tlt/words/$fname.mp3" "${trgt}" "${srce}"
                        if [ $? = 0 ]; then
                            tags_1 W "${trgt}" "${srce}" "$DM_tlt/words/$fname.mp3"
                            index word "${trgt}" "${tpe}"
                            echo "${trgt}" >> addw
                            
                        else
                            printf "\n\n#$n $trgt" >> ./wlog
                            if [ -f "$DM_tlt/words/$fname.mp3" ]; then
                            mv -f "$DM_tlt/words/$fname.mp3" ./"$n.mp3"; fi
                        fi
                            
                    elif [ $(wc -$c <<<"$trgt") -ge 1 ]; then
                    
                        mv -f "$n.mp3" "$DM_tlt/$fname.mp3"
                        (
                        r=$((RANDOM%10000))
                        clean_3 "$DT_r" "$r"
                        translate "$(sed '/^$/d' < "$aw")" auto $lg \
                        | sed 's/,//; s/\?//; s/\¿//; s/;//g' > "$bw"
                        check_grammar_1 "$DT_r" "$r"
                        list_words "$DT_r" "$r"
                        
                        mksure "$DM_tlt/$fname.mp3" "${trgt}" "${srce}" \
                        "${lwrds}" "${pwrds}" "${grmrk}"
                            if [ $? = 0 ]; then
                                echo "${trgt}" >> adds
                                index sentence "${trgt}" "${tpe}"
                                tags_1 S "${trgt}" "${srce}" "$DM_tlt/$fname.mp3"
                                tags_3 W "${lwrds}" "${pwrds}" "${grmrk}" "$DM_tlt/$fname.mp3"
                                fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                            else
                                printf "\n\n#$n $trgt" >> ./slog
                                if [ -f "$DM_tlt/$fname.mp3" ]; then
                                mv -f "$DM_tlt/$fname.mp3" ./"$n.mp3"; fi
                            fi
                        cd "$DT"
                        rm -f *.$r "$aw" "$bw"
                        )
                    fi
                fi
                rm -f ./info.flac ./info.ret
            else
                continue
            fi

            prg=$((100*n/lns-1))
            echo "$prg"
            echo "# ${trgt:0:35}..." ;
            
            let n++
        done

        ) | dlg_progress_2
        
        cd "$DT_r"
        if [ -f ./wlog ]; then
        wadds=" $(($(wc -l < ./addw) - $(sed '/^$/d' ./wlog | wc -l)))"
        W=" $(gettext "Words")"
        if [ $wadds = 1 ]; then
        W=" $(gettext "Word")"; fi
        else
        wadds=" $(wc -l < ./addw)"
        W=" $(gettext "Words")"
        if [ $wadds = 1 ]; then
        wadds=" $(wc -l < ./addw)"
        W=" $(gettext "Word")"; fi
        fi
        if [ -f ./slog ]; then
        sadds=" $(($(wc -l < ./adds) - $(sed '/^$/d' ./swlog | wc -l)))"
        S=" $(gettext "Sentences")"
        if [ $sadds = 1 ]; then
        S=" $(gettext "Sentence")"; fi
        else
        sadds=" $(wc -l < ./adds)"
        S=" $(gettext "Sentences")"
        if [ $sadds = 1 ]; then
        S=" $(gettext "Sentence")"; fi
        fi
        
        logs=$(cat ./slog ./wlog)
        adds=$(cat ./adds ./addw | wc -l)
        
        if [[ "$adds" -ge 1 ]]; then
        notify-send -i idiomind \
        "$tpe" \
        "$(gettext "Have been added:")\n$sadds$S$wadds$W" -t 2000 &
        echo "aitm.$adds.aitm" >> \
        $DC/addons/stats/.log; fi
        
        if [ -n "$logs" ] || [ "$(ls [0-9]* | wc -l)" -ge 1 ]; then
        
            if [ "$(ls [0-9]* | wc -l)" -ge 1 ]; then
            btn="--button="$(gettext "Save Audio")":0"; fi

            dlg_text_info_3 "$(gettext "Some items could not be added to your list:")" "$logs" "$btn" >/dev/null 2>&1
            ret=$(echo "$?")
            
                if  [[ "$ret" -eq 0 ]]; then
                    aud=`dlg_file_2`
                    ret=$(echo "$?")
                    
                        if [[ "$ret" -eq 0 ]]; then
                        mkdir ./rest
                        mv -f [0-9]*.mp3 ./rest/
                        cd ./rest/
                        tar cvzf ./audio.tar.gz ./*
                        mv -f ./audio.tar.gz "$aud"; fi
                fi
        fi
        
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        rm -f "$lckpr"
    fi
    exit
    
elif [ "$1" = item_for_edit ]; then

    DT_r=$(sed -n 1p "$DT/.n_s_pr"); cd "$DT_r"
    dlg_text_info_5 "$3"
    $? >/dev/null 2>&1
fi
