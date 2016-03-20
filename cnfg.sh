#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
[ ! -d "$DC" ] && "$DS/ifs/1u.sh" && exit
info2="$(gettext "Switch Language")?"
cd "$DS/addons"
cnf1=$(mktemp "$DT/cnf1.XXXX")
source $DS/default/sets.cfg
lang1="${!tlangs[@]}"; lt=( $lang1 )
lang2="${!slangs[@]}"; ls=( $lang2 )
if [[ $(egrep -cv '#|^$' "$DC_s/1.cfg") = ${#csets[*]} ]]; then
cfg=1; else > "$DC_s/1.cfg"; fi

desktopfile="[Desktop Entry]
Name=Idiomind
GenericName=Learning Tool
Comment=Vocabulary learning tool
Exec=idiomind autostart
Terminal=false
Type=Application
Icon=idiomind
StartupWMClass=Idiomind"

confirm() {
    yad --form --title="$(gettext "Confirm")" \
    --name=Idiomind --class=Idiomind \
    --image="dialog-question" --text="$1\n" \
    --window-icon=idiomind \
    --skip-taskbar --center --on-top \
    --width=380 --height=120 --borders=5 \
    --button="   $(gettext "Cancel")   ":1 \
    --button="$(gettext "Yes")":0
}

set_lang() {
    language="$1"
    source "$DS/ifs/cmns.sh"
    check_dir "$DM_t/$language/.share/images" "$DM_t/$language/.share/audio"
    echo -e "$language\n$slng" > "$DC_s/6.cfg"
    "$DS/stop.sh" 4
    source $DS/default/c.conf
    last="$(cd "$DM_tl"/; ls -tNd */ |cut -f1 -d'/' |head -n1)"
    if [ -d "$DM_tl/${last}" ]; then
        mode="$(< "$DM_tl/${last}/.conf/8.cfg")"
        if [[ ${mode} =~ $numer ]]; then
            "$DS/default/tpc.sh" "${last}" ${mode} 1 &
        fi
    else
        > "$DT/tpe"; > "$DC_s/4.cfg"
    fi
    
    check_list > "$DM_tl/.share/2.cfg"
    
    if [ ! -d "$DM_tl/.share/data" ]; then
        mkdir -p "$DM_tls/data"
        cdb="$DM_tls/data/${tlng}.db"
        echo -n "create table if not exists Words \
        (Word TEXT, ${slng^} TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${cdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${cdb}
    fi
    "$DS/mngr.sh" mkmn 1 &
}

config_dlg() {
    if [ ${cfg} = 1 ]; then
        for get in ${csets[@]}; do
            val=$(grep -o "$get"=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')
            declare "$get"="$val"
        done
    else
        n=0; > "$DC_s/1.cfg"
        for _set in ${csets[@]}; do
            echo -e "$_set=\"\"" >> "$DC_s/1.cfg"
        done
    fi

    if [ -z "$intrf" ]; then intrf=Default; fi
    lst="$intrf"$(sed "s/\!$intrf//g" <<<"!Default!en!es!fr!it!pt")""
    if [ "$ntosd" != TRUE ]; then audio=TRUE; fi
    if [ "$trans" != TRUE ]; then ttrgt=FALSE; fi
    
    emrk='!'
    for val in "${!tlangs[@]}"; do
        declare clocal="$(gettext "${val}")"
        list1="${list1}${emrk}${clocal}"
    done
    unset clocal
    for val in "${!slangs[@]}"; do
        declare clocal="$(gettext "${val}")"
        list2="${list2}${emrk}${clocal}"
    done

    c=$((RANDOM%100000)); KEY=$c
    yad --plug=$KEY --form --tabnum=1 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "General Options")\t":lbl " " \
    --field=":LBL" " " \
    --field="$(gettext "Use color to highlight grammar")":CHK "$gramr" \
    --field="$(gettext "List words after adding a sentence")":CHK "$wlist" \
    --field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
    --field="$(gettext "Download audio pronunciation")":CHK "$dlaud" \
    --field="$(gettext "Detect language of source text (slower)")":CHK "$ttrgt" \
    --field="$(gettext "Clipboard watcher")":CHK "$clipw" \
    --field="$(gettext "Show icon in the notification area")":CHK "$itray" \
    --field="$(gettext "Perform tasks at startup")":CHK "$stsks" \
    --field=" :LBL" " " \
    --field="$(gettext "Languages")\t":LBL " " \
    --field=":LBL" " " \
    --field="$(gettext "I'm learning")":CB "$(gettext ${tlng})$list1" \
    --field="$(gettext "My language is")":CB "$(gettext ${slng})$list2" \
    --field=" :LBL" " " \
    --field=":LBL" " " \
    --field="<small>$(gettext "Use this speech synthesizer instead eSpeak")</small>" "$synth" \
    --field="<small>$(gettext "Program to convert text to WAV file")</small>" "$txaud" \
    --field="$(gettext "Display in")":CB "$lst" \
    --field=" :LBL" " " \
    --field="$(gettext "Help")":BTN "$DS/ifs/tls.sh help" \
    --field="$(gettext "Report a problem")":BTN "$DS/ifs/tls.sh fback" \
    --field="$(gettext "Check for updates")":BTN "$DS/ifs/tls.sh 'check_updates'" \
    --field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" > "$cnf1" &
    cat "$DS_a/menu_list" |yad --plug=$KEY --tabnum=2 --list \
    --text=" $(gettext "Double-click to set") " \
    --print-all --dclick-action="$DS/ifs/dclik.sh" \
    --expand-column=2 --no-headers \
    --column=icon:IMG --column=Action &
    yad --notebook --key=$KEY --title="$(gettext "Settings")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --tab-borders=5 --sticky --center \
    --tab="$(gettext "Preferences")" \
    --tab="$(gettext "Extensions")" \
    --width=470 --height=330 --borders=2 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0
    ret=$?

    if [ $ret -eq 0 ]; then
        n=1; v=0
        while [ ${n} -le 17 ]; do
            val=$(cut -d "|" -f$n < "$cnf1")
            if [ -n "$val" ]; then
                sed -i "s/${csets[$v]}=.*/${csets[$v]}=\"$val\"/g" "$DC_s/1.cfg"
                ((v=v+1))
            fi
            ((n=n+1))
        done
        val=$(cut -d "|" -f18 < "$cnf1")
        [[ "$val" != "$synth" ]] && \
        sed -i "s/${csets[10]}=.*/${csets[10]}=\"$(sed 's|/|\\/|g' <<< "$val")\"/g" "$DC_s/1.cfg"
        val=$(cut -d "|" -f19 < "$cnf1")
        [[ "$val" != "$txaud" ]] && \
        sed -i "s/${csets[11]}=.*/${csets[11]}=\"$(sed 's|/|\\/|g' <<< "$val")\"/g" "$DC_s/1.cfg"
        val=$(cut -d "|" -f20 < "$cnf1")
        [[ "$val" != "$intrf" ]] && \
        sed -i "s/${csets[12]}=.*/${csets[12]}=\"$val\"/g" "$DC_s/1.cfg"
        
        if [[ $(grep -oP '(?<=clipw=\").*(?=\")' "$DC_s/1.cfg") = TRUE ]] && [ ! -e $DT/clipw ]; then
            "$DS/ifs/clipw.sh" &
        else 
            if [ -e $DT/clipw ]; then kill $(cat $DT/clipw); rm -f $DT/clipw; fi
        fi

        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        if cut -d "|" -f10 < "$cnf1" | grep "TRUE"; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
            echo "$desktopfile" > "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
            rm "$config_dir/idiomind.desktop"
            fi
        fi

        ntlang=$(cut -d "|" -f14 < "$cnf1")
        if [[ $(gettext ${tlng}) != ${ntlang} ]]; then
            for val in "${lt[@]}"; do
                if [[ ${ntlang} = $(gettext ${val}) ]]; then
                    export tlng=$val
                fi
            done
            if echo "$tlng$slng" |grep -oE 'Chinese|Japanese|Russian'; then
                info3="\n$(gettext "Some things are still not working for these languages:") Chinese, Japanese, Russian."
            fi
            confirm "$info2$info3" dialog-question ${tlng}
            [ $? -eq 0 ] && set_lang ${tlng}
        fi
        
        nslang=$(cut -d "|" -f15 < "$cnf1")
        if [[ $(gettext ${slng}) != ${nslang} ]]; then
            for val in "${ls[@]}"; do
                if [[ ${nslang} = $(gettext ${val}) ]]; then
                    export slng=$val
                fi
            done
            confirm "$info2" dialog-question ${slng}
            if [ $? -eq 0 ]; then
                echo ${tlng} > "$DC_s/6.cfg"
                echo ${slng} >> "$DC_s/6.cfg"
                cdb="$DM_tls/data/${tlng}.db"
                if ! grep -q ${slng} <<<"$(sqlite3 ${cdb} "PRAGMA table_info(Words);")"; then
                    sqlite3 ${cdb} "alter table Words add column ${slng} TEXT;"
                fi
            fi
        fi
    fi
    rm -f "$cnf1" "$DT/.lc"
     >/dev/null 2>&1
    exit

}  >/dev/null 2>&1

config_dlg
