#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
user=$(echo "$(whoami)")
if [ ! -f "$DC_a/1.cfg" ]; then
    echo -e "backup=FALSE" > "$DC_a/1.cfg"
    echo -e "path=\"$HOME\"" >> "$DC_a/1.cfg"
    echo -e "size=0" >> "$DC_a/1.cfg"
    source "$DC_a/1.cfg"
fi
source "$DC_a/1.cfg"

[ -f "$D_cps/.udt" ] && udt=$(cat "$D_cps/.udt") || udt=" "
dte=$(date +%F)

#dialog
if [ -z "$1" ]; then
    
    D=$(yad --list --title="$(gettext "User Data")" \
    --center --on-top --radiolist --expand-column=2 \
    --name=Idiomind --class=Idiomind \
    --text=" $(gettext "Size"): $size \\n" \
    --width=480 --height=350 --always-print-result \
    --skip-taskbar --image=folder --separator=" " \
    --borders=15 --print-all --window-icon=idiomind \
    --button=Backup:2 --button=Ok:0 --image-on-top --column="" \
    --column=Options "FALSE" "$(gettext "Import")" "FALSE" \
    "$(gettext "Export")" --buttons-layout=edge)
    
    ret=$?

    if [ "$ret" -eq 0 ]; then

        in=$(echo "$D" | sed -n 1p)
        ex=$(echo "$D" | sed -n 2p)
        
        # export
        if echo "$ex" | grep "TRUE $(gettext "Export")"; then
            
            cd $HOME &&
            exp=$(yad --save --center --borders=10 \
            --on-top --filename="$user"_idiomind_data.tar.gz \
            --window-icon=idiomind --skip-taskbar \
            --title="$(gettext "Export")" \
            --file --width=600 --height=500 --button=Ok:0 )
            ret=$?
                
            if [ "$ret" -eq 0 ]; then
                
                (
                echo "# $(gettext "Copying...")" ; sleep 0.1

                cd "$DM"
                tar cvzf backup.tar.gz *
                mv -f backup.tar.gz $DT/"$user"_idiomind_data.tar.gz

                mv -f $DT/"$user"_idiomind_data.tar.gz "$exp"
                echo "# $(gettext "Completing")" ; sleep 1
                
                ) | yad --center --on-top --progress \
                --width=200 --height=20 --geometry=200x20-2-2 \
                --pulsate --percentage="5" --auto-close \
                --sticky --undecorated --skip-taskbar --no-buttons
                
                yad --fixed --name=idiomind --center \
                --image=info --sticky --class=idiomind \
                --text="$(gettext "Data exported successfully")\n" \
                --image-on-top --fixed --width=360 --height=140 --borders=3 \
                --skip-taskbar --window-icon=idiomind \
                --title=Idiomind --button=Ok:0 && exit 1
            else
                exit 1
            fi

        # import
        elif echo "$in" | grep "TRUE $(gettext "Import")"; then
        
            cd $HOME &&
            
            add=$(yad --center --on-top \
            --borders=10 --file-filter="*.gz" --button=Ok:0 \
            --window-icon=idiomind --skip-taskbar \
            --title="$(gettext "Import")" \
            --window-icon=$ICON --file --width=600 --height=500)
            
            if [ "$ret" -eq 0 ]; then
            
                if [[ -z "$add" || ! -d "$DM" ]]; then
                    exit 1
                fi
                
                (
                rm -f $DT/*.XXXXXXXX
                echo "5"
                echo "# $(gettext "Copying...")" ; sleep 0.1
                mkdir $DT/import
                cp -f "$add" $DT/import/import.tar.gz
                cd $DT/import
                tar -xzvf import.tar.gz
                cd $DT/import/topics/
                list=$(ls * -d | sed 's/saved//g' | sed '/^$/d')

                while read -r lng; do
                    mkdir "$DM_t/$lng"
                    mkdir "$DM_t/$lng/.share"
                    mv -f ./$lng/.share/* "$DM_t/$lng/.share/"
                    echo $lng >> ./.languages
                done <<< "$list"

                while read language; do

                    cd $DT/import/topics/$language/
                    ls * -d | sed 's/Feeds//g' | sed '/^$/d' > $DT/import/topics/$language/.topics

                    echo "50"
                    echo "# $(gettext "Setting up languages") $language " ; sleep 0.1
                    echo "90"
                    echo "# $(gettext "Setting up languages") $language " ; sleep 0.1
                    
                    while read topic; do
                    
                        echo "5"
                        echo "# $(gettext "Setting up") ${topic:0:20} ... " ; sleep 0.1
                        echo "20"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2
                        
                        cp -fr "$DT/import/topics/$language/$topic/" \
                        "$DM_t/$language/$topic/"
                        
                        rm "$DM_t/$language/$topic/tpc.sh"
                        rm "$DM_t/$language/$topic/.conf/1.cfg"
                        rm "$DM_t/$language/$topic/.conf/2.cfg"
                        rm -rf "$DM_t/$language/$topic/.conf/practice/"
                        cp -f "$DM_t/$language/$topic/.conf/0.cfg" \
                        "$DM_t/$language/$topic/.conf/1.cfg"
                        echo "6" > "$DM_t/$language/$topic/.conf/8.cfg"
                        
                        echo "50"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2
                        echo "80"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.1
                        
                        echo "$topic" >> "$DM_t/$language/.3.cfg"
                        sed -i 's/'"$topic"'//g' "$DM_t/$language/.2.cfg"
                        sed '/^$/d' $DM_t/$language/.2.cfg > $DM_t/$language/.2.cfg_
                        mv -f $DM_t/$language/.2.cfg_ $DM_t/$language/.2.cfg
                        cd $DT/import/topics
                        echo "90"
                        echo "# $(gettext "Copying") ${topic:0:20} ... " ; sleep 0.2

                    done < $DT/import/topics/$language/.topics
                    

                done < $DT/import/topics/.languages
                
                echo "95"
                echo "# $(gettext "Completing")" ; sleep 1
                echo "100"
                $DS/mngr.sh mkmn
                rm -f -r $DT/import
                
                ) | yad --on-top --progress \
                --width=200 --height=20 --geometry=200x20-2-2 \
                --percentage="5" --auto-close \
                --sticky --on-top --undecorated --on-top \
                --skip-taskbar --center --no-buttons
                
                yad --fixed --name=idiomind --center \
                --image=info --sticky --class=idiomind \
                --text=" $(gettext "Data imported successfully")   \\n" \
                --image-on-top --fixed --width=360 --height=140 --borders=3 \
                --skip-taskbar --window-icon=idiomind \
                --title=Idiomind --button=Ok:0 && exit 1
            else
                exit 1
            fi
        fi

    # backup
    elif [ "$ret" -eq 2 ]; then

        if [ ! -f "$DC_a/1.cfg" ]; then
            echo -e "backup=FALSE" > "$DC_a/1.cfg"
            echo -e "path=\"$HOME\"" >> "$DC_a/1.cfg"
            echo -e "size=0" >> "$DC_a/1.cfg"
        fi
        source "$DC_a/1.cfg"

        cd $HOME
        CNFG=$(yad --center --form --on-top --window-icon=idiomind \
        --borders=15 --expand-column=3 --no-headers \
        --print-all --button="$(gettext "Restore")":3 --always-print-result \
        --button="$(gettext "Close")":0 --width=420 --height=300 \
        --title=Backup --columns=2 \
        --field="$(gettext "Backing up periodically.")":CHK $backup \
        --field="$(gettext "Path to save")":"":CDIR "$path" \
        --field=" :LBL" " " )
        
        ret=$?
        # backup config
        if [ "$ret" -eq 0 ]; then
            st1=$(echo "$CNFG" | cut -d "|" -f1)
            st2=$(echo "$CNFG" | cut -d "|" -f2 | sed 's|\/|\\/|g')
            
            sed -i "1s/backup=.*/backup=\"$st1\"/" "$DC_a/1.cfg"
            sed -i "2s/path=.*/path=\"$st2\"/" "$DC_a/1.cfg"

        elif [ "$ret" -eq 3 ]; then
        
            if [ ! -d "$D_cps" ]; then
                yad --fixed --name=Idiomind --center \
                --image=info --sticky --class=Idiomind \
                --text="$(gettext "Not defined directory\nfor Backups")" \
                --image-on-top --fixed --width=340 --height=130 --borders=3 \
                --skip-taskbar --window-icon=idiomind \
                --title=Idiomind --button=Ok:0 & exit 1
                
            elif [ ! -f "$D_cps/idiomind.backup" ]; then
                yad --fixed --name=Idiomind --center \
                --image=info --sticky --class=Idiomind \
                --text="$(gettext "No Backup")\n" \
                --image-on-top --fixed --width=340 --height=130 --borders=3 \
                --skip-taskbar --window-icon=idiomind \
                --title=Idiomind --button=Ok:0 & exit 1
            else
                udt=$(cat "$D_cps/.udt")
                yad --fixed --name=Idiomind --center \
                --image=info --sticky --class=Idiomind \
                --text="$(gettext "Data will be restored to") $udt \n" \
                --image-on-top --fixed --width=340 --height=130 --borders=3 \
                --skip-taskbar --window-icon=idiomind \
                --title=Idiomind --button="$(gettext "Cancel")":1 --button=Ok:0
                    ret=$?
                
                    if [ "$ret" -eq 0 ]; then
                        set -e
                        (
                        rm -f $DT/*.XXXXXXXX
                        echo "#" ; sleep 0
                        cp "$DC_s/12.cfg"  "$DT/.SC.bk"
                        mv "$DC/" "$DT/.s2.bk"
                        mv "$DM/" "$DT/.idm2.bk"
                        mkdir "$DC/"
                        mkdir "$DM/"
                        mkdir "$DM_t"
                        D_cps=$(sed -n 2p $DT/.SC.bk)
                        mv -f "$D_cps/idiomind.backup" "$D_cps/backup.tar.gz"
                        cd "$D_cps"
                        tar -xzvf ./backup.tar.gz
                        mv -f ./idiomind/* "$DC/"
                        mv -f ./topics/* "$DM_t/"
                        $DS/mngr mkmn
                        chmod -R +x "$DC"
                        rm -r  "$D_cps/idiomind"
                        rm -r  "$D_cps/topics"
                        mv -f "$D_cps/backup.tar.gz" "$D_cps/idiomind.backup"
                        
                        ) | yad --on-top \
                        --width=200 --height=20 --geometry=200x20-2-2 \
                        --pulsate --percentage="5" --auto-close \
                        --sticky --on-top --undecorated --skip-taskbar \
                        --center --no-buttons --fixed --progress
                        
                        exit=$?
                        
                        if [[ $exit = 0 ]] ; then
                        
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

elif ([ "$1" = C ] && [ "$dte" != "$udt" ]); then
    sleep 3
    while true; do
    idle=$(top -bn2 | grep "Cpu(s)" | tail -n 1 \
    | sed 's/\%us,.*//' | sed 's/.*Cpu(s): //')
    echo "idle is $idle"
    if [[ $idle < 15 ]]; then
        break
    fi
    sleep 10
    done
    
    if [ ! -d "$D_cps" ]; then
        yad --fixed --name=Idiomind --center \
        --image=info --sticky --class=Idiomind \
        --text="$(gettext "Can not find the directory\nestablished for backups")" \
        --image-on-top --fixed --width=420 --height=130 --borders=3 \
        --skip-taskbar --window-icon=idiomind \
        --title=Idiomind --button=Ok:0
        exit 1
    fi
    
    if [ -f "$D_cps/idiomind.backup" ]; then
        mv -f "$D_cps/idiomind.backup" "$D_cps/idiomind.bk"
    fi

    cp -r "$DC" "$DM"
    cd $DM
    tar cvzf backup.tar.gz *
    mv -f backup.tar.gz "$D_cps/idiomind.backup"
    exit=$?
    if [ $exit = 0 ] ; then
    echo "$dte" > "$D_cps/.udt"
    rm "$D_cps/idiomind.bk"
    else
    mv -f "$D_cps/idiomind.bk" "$D_cps/idiomind.backup"
    fi
    rm -r "$DM/idiomind"
    exit

fi
