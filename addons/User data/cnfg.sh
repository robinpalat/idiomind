#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/mods/cmns.sh"

if [ ! -f "$DC_a/user_data.cfg" ]; then
echo -e "backup=\"FALSE\"
path=\"$HOME\"
size=\"0\"
others=\" \"" > "$DC_a/user_data.cfg"
fi

dte=$(date +%F)
path="$(grep -o path=\"[^\"]* "$DC_a/user_data.cfg"| grep -o '[^"]*$')"
size="$(grep -o size=\"[^\"]* "$DC_a/user_data.cfg"| grep -o '[^"]*$')"
others="$(grep -o others=\"[^\"]* "$DC_a/user_data.cfg"| grep -o '[^"]*$')"

D=$(yad --list --radiolist --title="$(gettext "User Data")" \
--name=Idiomind --class=Idiomind \
--text="$(gettext "Total size:") $size" \
--always-print-result --print-all --separator=" " \
--window-icon=idiomind \
--center --on-top --expand-column=2 --image-on-top \
--skip-taskbar --image=folder \
--width=450 --height=280 --borders=10 \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "OK")":0 \
--column="" \
--column="$(gettext "Options")" \
"FALSE" "$(gettext "Import")" "FALSE" "$(gettext "Export")")
ret=$?
if [[ $ret -eq 0 ]]; then
    in=$(sed -n 1p <<<"$D")
    ex=$(sed -n 2p <<<"$D")

    if grep "TRUE $(gettext "Export")" <<<"$ex"; then
        set -e
        cd "$HOME"
        exp=$(yad --file --save --title="$(gettext "Export")" \
        --filename="idiomind_data.tar.gz" \
        --window-icon=idiomind \
        --skip-taskbar --center --mouse --on-top \
        --width=600 --height=500 --borders=10 \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0)
        ret=$?
        if [[ $ret -eq 0 ]]; then
            sleep 1; notify-send -i idiomind \
            "$(gettext "Copying")..." \
            "$(gettext "It Might take some time")" 
            if [ -d "${DM}" ]; then
                cd "${DM}"
            else
                msg "$(gettext "An error occurred while copying files.")\n" error && exit 1
            fi
            
            find -L . -name .CACHEDIR |sed -e 's/[/]\.CACHEDIR$//g' > "$DT/excludes"
            tar --ignore-command-error --ignore-failed-read \
            -icvzf "$DT/backup.tar.gz" --exclude-from="$DT/excludes" .
            mv -f "$DT/backup.tar.gz" "${exp}"
            echo "# $(gettext "Completing")" ; sleep 1
            
            if [ -f "${exp}" ]; then
                msg "$(gettext "Data exported successfully.")\n" dialog-information
            else
                [ -f "$DT/backup.tar.gz" ] && rm -f "$DT/backup.tar.gz"
                msg "$(gettext "An error occurred while copying files.")\n" error
            fi
        fi

    elif grep "TRUE $(gettext "Import")" <<<"$in"; then
        set -e
        cd "$HOME"
        add=$(yad --file --title="$(gettext "Import")" \
        --file-filter="*.gz" \
        --window-icon=idiomind \
        --skip-taskbar --center --on-top \
        --width=600 --height=500 --borders=10 \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0)
        
        if [[ $ret -eq 0 ]]; then
            if [ -z "${add}" -o ! -d "${DM}" ]; then
                exit 1
            fi
            [ ! -d "$DM/backup" ] && mkdir "$DM/backup"

            sleep 1; notify-send -i idiomind \
            "$(gettext "Copying...")" \
            "$(gettext "It Might take some time")"
            
            [ -d "$DT/import" ] && rm -fr "$DT/import"
            rm -f "$DT/*.XXXXXXXX"

            mkdir "$DT/import"
            cp -f "${add}" "$DT/import/import.tar.gz"
            cd "$DT/import"
            tar -xzvf import.tar.gz
            if [ -d "$DT/import/backup/" ]; then
            cp -f "$DT/import/backup"/* "$DM/backup"/; fi
            cd "$DT/import/topics/"
            list="$(ls * -d |sed '/^$/d')"

            while read -r lng; do
                if [ ! -d "$DM_t/$lng" ]; then
                    mkdir "$DM_t/$lng"; fi
                if [ ! -d "$DM_t/$lng/.share" ]; then
                    mkdir -p "$DM_t/$lng/.share/data"
                    mkdir -p "$DM_t/$lng/.share/images"
                    mkdir -p "$DM_t/$lng/.share/audio"; fi
                if [ "$(ls -A "./$lng/.share/audio")" ]; then
                    mv -f "./$lng/.share/audio"/* "$DM_t/$lng/.share/audio"/
                fi
                if [ "$(ls -A "./$lng/.share/images")" ]; then
                    mv -f "./$lng/.share/images"/* "$DM_t/$lng/.share/images"/
                fi
                #if [ "$(ls -A "./$lng/.share/data")" ]; then
                    #mv -f "./$lng/.share/data"/* "$DM_t/$lng/.share/data"/
                #fi
                echo "$lng" >> ./languages
            done <<<"${list}"

            while read -r language; do
                if [ -d "$DT/import/topics/$language/" ] &&  \
                [ "$(ls -A "$DT/import/topics/$language/")" ] ; then
                    cd "$DT/import/topics/$language/"
                else
                    continue
                fi
                ls * -d |sed 's/Podcasts//g' |sed '/^$/d' > \
                "$DT/import/topics/$language/.topics"
                
                while read topic; do
                    if [ -d "$DM_t/$language/${topic}" ]; then continue; fi
                    if [ -d "$DT/import/topics/$language/${topic}" ]; then
                        cp -fr "$DT/import/topics/$language/${topic}" "$DM_t/$language/${topic}"
                    else
                        continue
                    fi
                    if [ ! -d "$DM_t/$language/${topic}/.conf" ]; then
                        mkdir "$DM_t/$language/${topic}/.conf"; fi
                    if [ ! -f "$DM_t/$language/${topic}/.conf/8.cfg" ]; then
                        echo 1 > "$DM_t/$language/${topic}/.conf/8.cfg"; fi
                    if [ -d "$DT/import/topics/$language/${topic}" ]; then
                        echo "${topic}" >> "$DM_t/$language/.share/3.cfg"; fi
                    cd "$DT/import/topics"
                done < "$DT/import/topics/$language/.topics"
                
                if [ -d "$DT/import/topics/$language/Podcasts" ]; then
                    cp -r "$DT/import/topics/$language/Podcasts" "$DM_t/$language/Podcasts"; fi
            done < "$DT/import/topics/languages"

            "$DS/mngr.sh" mkmn 1; rm -fr "$DT/import"
            msg "$(gettext "Data imported successfully.")\n" dialog-information
        fi
    fi
fi
exit
