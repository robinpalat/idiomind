#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
wicon="$DS/images/logo.png"

if [ ! -f "$DC_a/1.cfg" ]; then

    echo -e "backup=FALSE
    path=\"$HOME\"
    size=0" > "$DC_a/1.cfg"
fi
source "$DC_a/1.cfg"

[ -f "$path/.udt" ] && udt=$(< "$path/.udt") || udt=" "
dte=$(date +%F)

#dialog --button=Backup:2
if [ -z "$1" ]; then
    
    D=$(yad --list --radiolist --title="$(gettext "User Data")" \
    --name=Idiomind --class=Idiomind --text=" $(gettext "Size"): $size\n" \
    --always-print-result --print-all --separator=" " \
    --center --on-top --expand-column=2 --image-on-top \
    --skip-taskbar --image=folder --window-icon=idiomind \
    --width=480 --height=330 --borders=15 \
    --button="$(gettext "Cancel")":1 \
    --button=Ok:0 \
    --column="" \
    --column=Options \
    "FALSE" "$(gettext "Import")" "FALSE" "$(gettext "Export")")
    
    ret=$?

    if [ "$ret" -eq 0 ]; then

        in=$(echo "$D" | sed -n 1p)
        ex=$(echo "$D" | sed -n 2p)
        
        # export
        if grep "TRUE $(gettext "Export")" <<<"$ex"; then
        
            set -e
            set u pipefail
            IFS=$'\n\t'
            
            cd "$HOME"
            exp=$(yad --file --save --title="$(gettext "Export")" \
            --filename="idiomind_data.tar.gz" \
            --window-icon="idiomind" --skip-taskbar --center --on-top \
            --width=600 --height=500 --borders=10 \
            --button="$(gettext "Cancel")":1 \
            --button=Ok:0)
            ret=$?
                
            if [ "$ret" -eq 0 ]; then
                
                (
                echo "# $(gettext "Copying")..." ; sleep 0.1

                cd "$DM"
                #chmod 777 -R "$DM"
                # TODO data addons 
                tar cvzf backup.tar.gz \
                --exclude='./topics/Italian/Feeds/cache' \
                --exclude='./topics/French/Feeds/cache' \
                --exclude='./topics/Portuguese/Feeds/cache' \
                --exclude='./topics/Russian/Feeds/cache' \
                --exclude='./topics/Spanish/Feeds/cache' \
                --exclude='./topics/German/Feeds/cache' \
                --exclude='./topics/Chinese/Feeds/cache' \
                --exclude='./topics/Japanese/Feeds/cache' \
                --exclude='./topics/Vietnamese/Feeds/cache' \
                ./topics

                mv -f backup.tar.gz "$DT/idiomind_data.tar.gz"
                mv -f "$DT/idiomind_data.tar.gz" "$exp"
                echo "# $(gettext "Completing")" ; sleep 1

                ) | yad --center --on-top --progress \
                --width=200 --height=20 --geometry=200x20-2-2 \
                --pulsate --percentage="5" --auto-close \
                --sticky --undecorated --skip-taskbar --no-buttons
                
                #if [ $exit1 = 0 ] && [ $exit2 = 0 ] && [ $exit3 = 0 ]; then
                msg "$(gettext "Data exported successfully")\n" info
                #;fi
                exit 1

            else
                exit 1
            fi

        # import
        elif grep "TRUE $(gettext "Import")" <<<"$in"; then
            
            set -e
            set u pipefail
            IFS=$'\n\t'
            
            cd "$HOME"
            add=$(yad --file --title="$(gettext "Import")" \
            --file-filter="*.gz" \
            --window-icon="idiomind" --skip-taskbar --center --on-top \
            --width=600 --height=500 --borders=10 \
            --button="$(gettext "Cancel")":1 \
            --button=Ok:0)
            
            if [ "$ret" -eq 0 ]; then
            
                if [ -z "$add" ] || [ ! -d "$DM" ]; then
                    exit 1
                fi
                
                (
                [ -d "$DT/import" ] && rm -fr "$DT/import"
                rm -f "$DT/*.XXXXXXXX"
                echo "5"
                echo "# $(gettext "Copying")..." ; sleep 0.1
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
                    
                    echo $lng >> ./.languages
                    
                done <<< "$list"

                while read language; do

                    if [ -d "$DT/import/topics/$language/" ] &&  \
                    [ "$(ls -A "$DT/import/topics/$language/")" ] ; then
                    cd "$DT/import/topics/$language/"; else continue; fi
                    
                    ls * -d | sed 's/Feeds//g' | sed '/^$/d' > \
                    "$DT/import/topics/$language/.topics"

                    echo "50"
                    echo "# $(gettext "Setting up languages") $language " ; sleep 0.1
                    echo "90"
                    echo "# $(gettext "Setting up languages") $language " ; sleep 0.1
                    
                    while read topic; do
                    
                        echo "5"
                        echo "# $(gettext "Setting up") ${topic:0:20} ... " ; sleep 0.1
                        echo "20"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2
                        
                         if [ -d "$DM_t/$language/$topic" ]; then continue; fi
                         
                        if [ -d "$DT/import/topics/$language/$topic" ]; then
                        cp -fr "$DT/import/topics/$language/$topic" "$DM_t/$language/$topic"
                        else continue; fi
                        
                        echo "50"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2
                        
                        [ -f "$DM_t/$language/$topic/tpc.sh" ] && \
                        rm "$DM_t/$language/$topic/tpc.sh"
                        [ -f "$DM_t/$language/$topic/.conf/att.html" ] && \
                        rm "$DM_t/$language/$topic/.conf/att.html"
                        [ -f "$DM_t/$language/$topic/.conf/1.cfg" ] && \
                        rm "$DM_t/$language/$topic/.conf/1.cfg"
                        [ -f "$DM_t/$language/$topic/.conf/2.cfg" ] && \
                        rm "$DM_t/$language/$topic/.conf/2.cfg"
                        [ -d "$DM_t/$language/$topic/.conf/practice" ] && \
                        rm -rf "$DM_t/$language/$topic/.conf/practice/"
                        [ -f "$DM_t/$language/$topic/.conf/0.cfg" ] && \
                        cp -f "$DM_t/$language/$topic/.conf/0.cfg" \
                        "$DM_t/$language/$topic/.conf/1.cfg"
                        [ -d "$DM_t/$language/$topic/.conf" ] && \
                        echo "6" > "$DM_t/$language/$topic/.conf/8.cfg"
                        
                        echo "80"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.1
                        
                        if [ -d "$DT/import/topics/$language/$topic" ]; then
                        echo "$topic" >> "$DM_t/$language/.3.cfg"; fi
                        
                        if [ -f "$DM_t/$language/.2.cfg" ]; then
                        sed -i 's/'"$topic"'//g' "$DM_t/$language/.2.cfg"
                        sed '/^$/d' "$DM_t/$language/.2.cfg" > "$DM_t/$language/.2.cfg_"
                        mv -f "$DM_t/$language/.2.cfg_" "$DM_t/$language/.2.cfg"; fi
                        
                        cd "$DT/import/topics"
                        echo "90"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2
                        
                    done < "$DT/import/topics/$language/.topics"
                    
                    if [ -d "$DT/import/topics/$language/Feeds" ]; then
                    cp -r "$DT/import/topics/$language/Feeds" "$DM_t/$language/Feeds"; fi
                
                done < "$DT/import/topics/.languages"
                
                echo "95"
                echo "# $(gettext "Completing")" ; sleep 1
                echo "100"
                "$DS/mngr.sh" mkmn
                rm -f -r "$DT/import"
                
                ) | yad --progress \
                    --percentage="5" --auto-close \
                    --sticky --on-top --undecorated --skip-taskbar --center --no-buttons \
                    --width=200 --height=20 --geometry=200x20-2-2

                msg " $(gettext "Data imported successfully") \n" info
                exit 1
            else
                exit 1
            fi
        fi

    # backup
    elif [ "$ret" -eq 2 ]; then

        if [ ! -f "$DC_a/1.cfg" ]; then
        
            echo -e "backup=FALSE
            path=\"$HOME\"
            size=0" > "$DC_a/1.cfg"
        fi
        source "$DC_a/1.cfg"

        cd "$HOME"
        CNFG=$(yad --form --title=Backup \
        --name=Idiomind --class=Idiomind \
        --print-all --always-print-result \
        --window-icon="idiomind" --center --on-top --expand-column=3 --no-headers --columns=2 \
        --width=420 --height=300 --borders=15 \
        --field="$(gettext "Backup regularly")":CHK $backup \
        --field="$(gettext "Path to save")":"":CDIR "$path" \
        --field=" :LBL" " " \
        --button="$(gettext "Restore")":3
        --button="$(gettext "Close")":0)
        
        ret=$?
        # backup config
        if [ "$ret" -eq 0 ]; then
            st1=$(echo "$CNFG" | cut -d "|" -f1)
            st2=$(echo "$CNFG" | cut -d "|" -f2 | sed 's|\/|\\/|g')
            
            sed -i "1s/backup=.*/backup=\"$st1\"/" "$DC_a/1.cfg"
            sed -i "2s/path=.*/path=\"$st2\"/" "$DC_a/1.cfg"

        elif [ "$ret" -eq 3 ]; then
            
            set -e

            if [ ! -d "$path" ]; then
            
                msg "$(gettext "Backup directory does not exist. \nPlease check the settings and try again.")\n" info & exit 1
                
            elif [ ! -f "$D_cps/idiomind.backup" ]; then
            
                msg "$(gettext "No Backup.")\n" info & exit 1
                
            else
                udt=$(< "$path/.udt")
                msg_2 "$(gettext "Data will be restored to") $udt \n" info
                ret=$(echo $?)
                
                    if [ "$ret" -eq 0 ]; then
                        set -e
                        (
                        rm -f "$DT/*.XXXXXXXX"
                        echo "#" ; sleep 0
                        
                        mv "$DC/" "$DT/DC.bk"
                        mv "$DM/" "$DT/DM.bk"
                        mkdir "$DC/"
                        mkdir "$DM/"
                        mkdir "$DM_t"
                        D_cps=$(sed -n 2p $DT/.SC.bk)
                        mv -f "$path/idiomind.backup" "$path/backup.tar.gz"
                        cd "$path"
                        tar -xzvf ./backup.tar.gz
                        mv -f ./idiomind/* "$DC/"
                        mv -f ./topics/* "$DM_t/"
                        "$DS/mngr" mkmn
                        chmod -R +x "$DC"
                        rm -r  "$path/idiomind"
                        rm -r  "$path/topics"
                        mv -f "$path/backup.tar.gz" "$path/idiomind.backup"
                        
                        ) | yad --progress \
                            --percentage="5" --auto-close \
                            --sticky --on-top --undecorated --skip-taskbar --center --no-buttons \
                            --width=200 --height=20 --geometry=200x20-2-2
                        
                        exit=$?
                        
                        if [ $exit = 0 ] ; then
                        
                            info=" Restore succefull\n"
                            image=dialog-ok
                        else
                            info=" Restore Error"
                            image=dialog-warning
                        fi

                    elif [ "$ret" -eq 1 ]; then
                        exit 1
                    fi
            fi
        fi  
    else
        exit 1
    fi

elif [ "$1" = C ] && [ "$dte" != "$udt" ]; then
    sleep 3
    #while true; do
    #idle=$(top -bn2 | grep "Cpu(s)" | tail -n 1 \
    #| sed 's/\%us,.*//' | sed 's/.*Cpu(s): //')
    #echo "idle is $idle"
    #if [[ $idle < 15 ]]; then
        #break
    #fi
    #sleep 10
    #done
    
    #set -e
    #set u pipefail
    #IFS=$'\n\t'
    #source "$DC_a/1.cfg"
    
    #if [ ! -d "$path" ]; then
    
        #msg "$(gettext "Backup directory does not exist.")" info
      
        #exit 1
    #fi
    
    #if [ -f "$path/idiomind.backup" ]; then
        #mv -f "$path/idiomind.backup" "$path/idiomind.bk"
    #fi

    #cp -r "$DC" "$DM"
    #cd "$DM"
    #tar cvzf backup.tar.gz *
    

   #cd "$DT"
    ##chmod 777 -R "$DM"
    ## TODO data addons
    #tar cvzf backup.tar.gz \
    #--exclude='./topics/Italian/Feeds/cache' \
    #--exclude='./topics/French/Feeds/cache' \
    #--exclude='./topics/Portuguese/Feeds/cache' \
    #--exclude='./topics/Russian/Feeds/cache' \
    #--exclude='./topics/Spanish/Feeds/cache' \
    #--exclude='./topics/German/Feeds/cache' \
    #--exclude='./topics/Chinese/Feeds/cache' \
    #--exclude='./topics/Japanese/Feeds/cache' \
    #--exclude='./topics/Vietnamese/Feeds/cache' \
    #"$DM"
    

    #mv -f backup.tar.gz "$path/idiomind.backup"
    
    #exit=$?
    #if [ $exit = 0 ] ; then
    #echo "$dte" > "$path/.udt"
    #rm "$path/idiomind.bk"
    #else
    #mv -f "$path/idiomind.bk" "$path/idiomind.backup"
    #fi
    ##rm -r "$DM/idiomind"
    #exit

fi
