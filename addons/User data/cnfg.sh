#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

if [ ! -f "$DC_a/1.cfg" ]; then

    echo -e "backup=FALSE
    path=\"$HOME\"
    size=0" > "$DC_a/1.cfg"
fi

path="$(sed -n 2p < "$DC_a/1.cfg" \
| grep -o path=\"[^\"]* | grep -o '[^"]*$')"
size="$(sed -n 3p < "$DC_a/1.cfg" \
| grep -o size=\"[^\"]* | grep -o '[^"]*$')"

[ -f "$path/.udt" ] && udt=$(< "$path/.udt") || udt=" "
dte=$(date +%F)

if [ -z "$1" ]; then
    
    D=$(yad --list --radiolist --title="$(gettext "User Data")" \
    --name=Idiomind --class=Idiomind --text=" $(gettext "Size"): $size\n" \
    --always-print-result --print-all --separator=" " \
    --center --on-top --expand-column=2 --image-on-top \
    --skip-taskbar --image=folder \
    --window-icon="$DS/images/icon.png" \
    --width=480 --height=330 --borders=15 \
    --button="$(gettext "Cancel")":1 \
    --button=Ok:0 \
    --column="" \
    --column=Options \
    "FALSE" "$(gettext "Import")" "FALSE" "$(gettext "Export")")
    
    ret=$?

    if [[ $ret -eq 0 ]]; then

        in=$(echo "$D" | sed -n 1p)
        ex=$(echo "$D" | sed -n 2p)
        
        # export
        if grep "TRUE $(gettext "Export")" <<<"$ex"; then
        
            set -e
            IFS=$'\n\t'
            
            cd "$HOME"
            exp=$(yad --file --save --title="$(gettext "Export")" \
            --filename="idiomind_data.tar.gz" \
            --window-icon="$DS/images/icon.png" \
            --skip-taskbar --center --on-top \
            --width=600 --height=500 --borders=10 \
            --button="$(gettext "Cancel")":1 \
            --button=Ok:0)
            ret=$?
                
            if [[ $ret -eq 0 ]]; then
                
                (
                echo "# $(gettext "Copying")..."

                cd "$DM"
                # TODO
                tar cvzf backup.tar.gz \
                --exclude='./topics/Italian/Podcasts' \
                --exclude='./topics/French/Podcasts' \
                --exclude='./topics/Portuguese/Podcasts' \
                --exclude='./topics/Russian/Podcasts' \
                --exclude='./topics/Spanish/Podcasts' \
                --exclude='./topics/German/Podcasts' \
                --exclude='./topics/Chinese/Podcasts' \
                --exclude='./topics/Japanese/Podcasts' \
                --exclude='./topics/Vietnamese/Podcasts' \
                ./topics

                mv -f backup.tar.gz "$DT/idiomind_data.tar.gz"
                mv -f "$DT/idiomind_data.tar.gz" "$exp"
                echo "# $(gettext "Completing")" ; sleep 1

                ) | yad --progress \
                --pulsate --percentage="5" --auto-close \
                --sticky --undecorated --no-buttons \
                --skip-taskbar --center --on-top \
                --width=200 --height=20 --geometry=200x20-2-2
                
                msg "$(gettext "Data exported successfully.")\n" info
            fi
            
        # import
        elif grep "TRUE $(gettext "Import")" <<<"$in"; then
            
            set -e
            set u pipefail
            IFS=$'\n\t'
            
            cd "$HOME"
            add=$(yad --file --title="$(gettext "Import")" \
            --file-filter="*.gz" \
            --window-icon="$DS/images/icon.png" \
            --skip-taskbar --center --on-top \
            --width=600 --height=500 --borders=10 \
            --button="$(gettext "Cancel")":1 \
            --button=Ok:0)
            
            if [[ $ret -eq 0 ]]; then
            
                if [ -z "$add" ] || [ ! -d "$DM" ]; then
                    exit 1
                fi
                
                (
                [ -d "$DT/import" ] && rm -fr "$DT/import"
                rm -f "$DT/*.XXXXXXXX"
              
                echo "# $(gettext "Copying")..."
                mkdir "$DT/import"
                cp -f "$add" "$DT/import/import.tar.gz"
                cd "$DT/import"
                tar -xzvf import.tar.gz
                cd "$DT/import/topics/"
                list="$(ls * -d | sed 's/saved//g' | sed '/^$/d')"

                while read -r lng; do
                
                    [ ! -d "$DM_t/$lng" ] && mkdir "$DM_t/$lng"
                    [ ! -d "$DM_t/$lng/.share" ] && mkdir "$DM_t/$lng/.share"
                    [ "$(ls -A "./$lng/.share")" ] && mv -f "./$lng/.share"/* "$DM_t/$lng/.share"/
                    
                    echo "$lng" >> ./.languages
                    
                done <<< "$list"

                while read language; do

                    if [ -d "$DT/import/topics/$language/" ] &&  \
                    [ "$(ls -A "$DT/import/topics/$language/")" ] ; then
                    cd "$DT/import/topics/$language/"; else continue; fi
                    
                    ls * -d | sed 's/Podcasts//g' | sed '/^$/d' > \
                    "$DT/import/topics/$language/.topics"
                    
                    while read topic; do
                        
                        if [ -d "$DM_t/$language/$topic" ]; then continue; fi
                         
                        if [ -d "$DT/import/topics/$language/$topic" ]; then
                        cp -fr "$DT/import/topics/$language/$topic" "$DM_t/$language/$topic"
                        else continue; fi

                        [ -f "$DM_t/$language/$topic/.conf/7.cfg" ] && \
                        rm "$DM_t/$language/$topic/.conf/7.cfg"
                        [ -f "$DM_t/$language/$topic/.conf/att.html" ] && \
                        rm "$DM_t/$language/$topic/.conf/att.html"
                        [ -f "$DM_t/$language/$topic/.conf/1.cfg" ] && \
                        rm "$DM_t/$language/$topic/.conf/1.cfg"
                        [ -f "$DM_t/$language/$topic/.conf/2.cfg" ] && \
                        rm "$DM_t/$language/$topic/.conf/2.cfg"
                        [ -d "$DM_t/$language/$topic/.conf/practice" ] && \
                        rm -r "$DM_t/$language/$topic/.conf/practice/"
                        [ -f "$DM_t/$language/$topic/.conf/0.cfg" ] && \
                        cp -f "$DM_t/$language/$topic/.conf/0.cfg" \
                        "$DM_t/$language/$topic/.conf/1.cfg"
                        [ -d "$DM_t/$language/$topic/.conf" ] && \
                        echo "1" > "$DM_t/$language/$topic/.conf/8.cfg"

                        if [ -d "$DT/import/topics/$language/$topic" ]; then
                        echo "$topic" >> "$DM_t/$language/.3.cfg"; fi
                        
                        if [ -f "$DM_t/$language/.2.cfg" ]; then
                        sed -i 's/'"$topic"'//g' "$DM_t/$language/.2.cfg"
                        sed '/^$/d' "$DM_t/$language/.2.cfg" > "$DM_t/$language/.2.cfg_"
                        mv -f "$DM_t/$language/.2.cfg_" "$DM_t/$language/.2.cfg"; fi
                        
                        cd "$DT/import/topics"

                    done < "$DT/import/topics/$language/.topics"
                    
                    if [ -d "$DT/import/topics/$language/Podcasts" ]; then
                    cp -r "$DT/import/topics/$language/Podcasts" "$DM_t/$language/Podcasts"; fi
                
                done < "$DT/import/topics/.languages"
                
                "$DS/mngr.sh" mkmn
                rm -f -r "$DT/import"
                
                ) | yad --progress \
                --pulsate --percentage="5" --auto-close \
                --sticky --undecorated --no-buttons \
                --skip-taskbar --center --on-top \
                --width=200 --height=20 --geometry=200x20-2-2
                
                msg "$(gettext "Data imported successfully.")\n" info
            fi
    
        fi
    fi
fi
exit
