#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
[ ! -d "$DC" ] && "$DS/ifs/1u.sh" && exit
info2="$(gettext "Switch Language")?"
check_dir "$DS/addons"; cd "$DS/addons"
cnf1=$(mktemp "$DT/cnf1.XXXXXX")
source $DS/default/sets.cfg
lang1="${!tlangs[@]}"; lt=( $lang1 )
lang2="${!slangs[@]}"; ls=( $lang2 )
if [ ! -f "${cfgdb}" ]; then "$DS/ifs/mkdb.sh" config; fi
if ! file "${cfgdb}" |grep 'SQLite'; then "$DS/ifs/mkdb.sh" config; fi
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
    yad --form --title="Idiomind" \
    --name=Idiomind --class=Idiomind \
    --image="$DS/images/trans.png" --text="$1\n" \
    --window-icon=idiomind \
    --skip-taskbar --center --on-top \
    --width=380 --height=100 --borders=5 \
    --button="   $(gettext "Cancel")   ":1 \
    --button="$(gettext "Yes")":0
}

set_lang() {
    language="$1"
    touch "$DT/.langc"
    check_dir "$DM_t/$language/.share/images" \
    "$DM_t/$language/.share/audio"
    cdb "${cfgdb}" 3 lang tlng "${language}"
    cdb "${cfgdb}" 3 lang slng "${slng}"
    "$DS/stop.sh" 4
    source "$DS/default/c.conf"
    source "$DS/default/sets.cfg"
    lgt=${tlangs[$tlng]}
    DM_tl="$DM_t/$language"
    last="$(cd "$DM_tl"/; ls -tNd */ |cut -f1 -d'/' |head -n1)"
    if [ -n "${last}" ]; then
        mode="$(< "$DM_tl/${last}/.conf/stts")"
        if [[ ${mode} =~ $numer ]]; then
            "$DS/ifs/tpc.sh" "${last}" ${mode} 1 &
        else
            > "$DT/tpe"; > "$DC_s/tpc"
        fi
    else
        > "$DT/tpe"; > "$DC_s/tpc"
    fi
    if [ ! -f "${shrdb}" ]; then "$DS/ifs/mkdb.sh" share; fi
    if ! file "${shrdb}" | grep 'SQLite'; then "$DS/ifs/mkdb.sh" share; fi
    
    check_list
    
    if [ ! -d "$DM_tl/.share/data" ]; then
        mkdir -p "$DM_tls/data"
        tlngdb="$DM_tls/data/${tlng}.db"
        echo -n "create table if not exists Words \
        (Word TEXT, '${slng^}' TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${tlngdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${tlngdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${tlngdb}
    fi
    idiomind tasks; "$DS/mngr.sh" mkmn 1 &
}

config_dlg() {
    sz=(520 480); [[ ${swind} = TRUE ]] && sz=(490 460)
    show_icon=0; kill_icon=0
    source "$DS/default/sets.cfg"
    
    if [ $(cdb "${cfgdb}" 5 opts |wc -l) != 12 ]; then
        rm "${cfgdb}"; "$DS/ifs/mkdb.sh" config
    fi

    for get in ${csets[@]}; do
        val="$(cdb "${cfgdb}" 1 opts $get)"
        declare "$get"="$val"
    done

    if [ -z "$intrf" ]; then intrf=Default; fi
    lst="$intrf"$(sed "s/\!$intrf//g" <<<"!Default!en!es!fr!it!pt")""
    if [ "$ntosd" != TRUE ]; then audio=TRUE; fi
    if [ "$trans" != TRUE ]; then ttrgt=FALSE; fi
    emrk='!'
    for val in "${!tlangs[@]}"; do
        declare clocal="$(gettext "${val}")"
        list1="${list1}${emrk}${clocal}"
    done
    list2=$(for i in "${!slangs[@]}"; do echo -n "!$i"; done)
    lnk1='https://idiomind.sourceforge.io/help.html'
    lnk2="https://idiomind.sourceforge.io/contact.html"
    lnk3="https://poeditor.com/join/project/oGBLVJULjK"

    c=$((RANDOM%100000)); KEY=$c
    yad --plug=$KEY --form --tabnum=1 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Use color to highlight grammar")":CHK "$gramr" \
    --field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
    --field="$(gettext "Download audio pronunciation")":CHK "$dlaud" \
    --field="$(gettext "Detect language of source text (inaccurate)")":CHK "$ttrgt" \
    --field="$(gettext "Show icon in the notification area")":CHK "$itray" \
    --field="$(gettext "Smaller windows")":CHK "$swind" \
    --field="$(gettext "Run at startup")":CHK "$stsks" \
    --field="$(gettext "Interface language")":CB "$lst" \
    --field="<small>$(gettext "Use this speech synthesizer")</small>" "$synth" \
    --field="<small>$(gettext "Program to convert text to audio")</small>" "$txaud" \
    --field="$(gettext "I'm learning")":CB "$(gettext "${tlng}")$list1" \
    --field="$(gettext "My language is")":CB "$(gettext "${slng}")$list2" > "$cnf1" &
    cat "$DS_a/menu_list" |yad --plug=$KEY --tabnum=2 --list \
    --text=" $(gettext "Double-click to configure") " --print-all \
    --dclick-action="$DS/ifs/dclik.sh" \
    --expand-column=2 --no-headers \
    --column=icon:IMG --column=Action &
     yad --plug=$KEY --form --tabnum=3 \
    --align=center --scroll \
    --field=" :LBL" " " --field=" :LBL" " " --field=" :LBL" " " \
    --field="<a href='$lnk1'>$(gettext "Getting started")</a>":LBL "$DS/ifs/tls.sh help" \
    --field="<a href='$lnk2'>$(gettext "Get in touch")</a>":LBL "$DS/ifs/tls.sh fback" \
    --field="<a href='$lnk3'>$(gettext "Translate this program")</a>":LBL "$DS/ifs/tls.sh fback" \
    --field="$(gettext "Program updates")":BTN "$DS/ifs/tls.sh 'check_updates'" \
    --field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" &
    yad --notebook --key=$KEY --title="$(gettext "Settings")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --tab-pos=left --tab-borders=5 --sticky --center \
    --tab="$(gettext "Preferences")" \
    --tab="$(gettext "More")" \
    --tab="$(gettext "Help")" \
    --width=${sz[0]} --height=${sz[1]} --borders=5 --tab-borders=0 \
    --button="$(gettext "Save")"!"gtk-apply":0 \
    --button="$(gettext "Close")":1
    ret=$?
    
    if [ $ret -eq 0 ]; then
        n=1
        while [ ${n} -le 9 ]; do
            val=$(cut -d "|" -f${n} < "$cnf1")
            cdb "${cfgdb}" 3 opts "${csets[$((n-1))]}" "${val}"
           let n++
        done
        
        ## Interface Language
        val=$(cut -d "|" -f8 < "$cnf1")
        if [[ "$val" != "$intrf" ]]; then
            msg_2 "$(gettext "Are you sure you want to change the interface language?")\n" \
            dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Idiomind")"
            if [ $? -eq 0 ]; then 
                cdb "${cfgdb}" 3 opts intrf "${val}"
                kill_icon=1; show_icon=1; export intrf=$val
                idiomind tasks &
            else
                cdb "${cfgdb}" 3 opts intrf "${intrf}"
            fi
        fi
        
        #Icon tray
        if [[ "$(cdb ${cfgdb} 1 opts itray)"  = TRUE ]] && [[ ! -f "$DT/tray.pid" ]]; then
            if lsb_release -i -c | grep juno; then
                msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
            fi
            show_icon=1
        elif [[ "$(cdb ${cfgdb} 1 opts itray)"  = FALSE ]] && [[ -f "$DT/tray.pid" ]]; then
            kill_icon=1
        fi
        
        #Autostart
        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        if cut -d "|" -f7 < "$cnf1" |grep "TRUE"; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
                echo "$desktopfile" > "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
                rm "$config_dir/idiomind.desktop"
            fi
        fi
        
        #Languages source and target 
        ntlang=$(cut -d "|" -f11 < "$cnf1")
        if [[ $(gettext ${tlng}) != ${ntlang} ]]; then
            for val in "${lt[@]}"; do
                if [[ ${ntlang} = $(gettext ${val}) ]]; then
                    export tlng=$val
                fi
            done
            if echo "$tlng$slng" |grep -oE 'Chinese|Japanese|Russian'; then
                info3="\n\n$(gettext "Note that these languages may present some text display errors:") Chinese, Japanese, Russian."
            fi
            confirm "$info2$info3" dialog-question ${tlng}
            if [ $? -eq 0 ]; then 
                set_lang ${tlng}; 
                # icon tray change
                if [ "$(cdb ${cfgdb} 1 opts itray)"  = TRUE ]; then
                    kill_icon=1; show_icon=1
                fi
            fi
        fi
        
        nslang=$(cut -d "|" -f12 < "$cnf1")
        if [[ "${slng}" != "${nslang}" ]]; then
            slng="${nslang}"
            confirm "$info2" dialog-question "${slng}"
            if [ $? -eq 0 ]; then
                cdb "${cfgdb}" 3 lang tlng "${tlng}"
                cdb "${cfgdb}" 3 lang slng "${slng}"
                tlngdb="$DM_tls/data/${tlng}.db"
                if ! grep -q "${slng}" <<<"$(sqlite3 ${tlngdb} "PRAGMA table_info(Words);")"; then
                    sqlite3 ${tlngdb} "alter table Words add column '${slng}' TEXT;"
                fi
            fi
        fi
        
        if [ $kill_icon = 1 ]; then
            kill -9 $(cat $DT/tray.pid)
            kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
            rm -f "$DT/tray.pid"
        fi
        if [ $show_icon = 1 ]; then
            $DS/ifs/tls.sh itray &
        fi
        
    fi
    cleanups "$cnf1" "$DT/.langc"

    exit

}  >/dev/null 2>&1

config_dlg

