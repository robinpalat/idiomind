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
if ! file "${cfgdb}" |grep 'SQLite' >/dev/null 2>&1; then "$DS/ifs/mkdb.sh" config; fi
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
    sz=(400 480)
    kill_icon=0
    source "$DS/default/sets.cfg"
    
    if [ $(cdb "${cfgdb}" 5 opts |wc -l) != 13 ]; then
        rm "${cfgdb}"; "$DS/ifs/mkdb.sh" config
    fi

    for get in ${csets[@]}; do
        val="$(cdb "${cfgdb}" 1 opts $get)"
        declare "$get"="$val"
    done

    [ -z "$intrf" ] && intrf=Default
    interface_lang_list="$intrf"$(sed "s/\!$intrf//g" <<<"!Default!en!es!fr!it!pt")""
    if [ "$ntosd" != TRUE ]; then audio=TRUE; fi
    if [ "$trans" != TRUE ]; then ttrgt=FALSE; fi
    e='!'
    for val in "${!tlangs[@]}"; do
        declare clocal="$(gettext "${val}")"
        list1="${list1}${e}${clocal}"
    done
    list2=$(for i in "${!slangs[@]}"; do echo -n "!$i"; done)
    
    levels=( "$(gettext "Beginner")" "$(gettext "Intermediate-Advanced")" )
    Level="${levels[${level}]}"
    [ -z "$Level" ] && Level=" "
    levels_list="$Level"$(sed "s/\!$Level//g" <<< "!${levels[0]}!${levels[1]}")""

    c=$((RANDOM%100000)); KEY=$c
    yad --plug=$KEY --form --tabnum=1 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Use color to highlight grammar in sentences")":CHK "$gramr" \
    --field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
    --field="$(gettext "Download audio pronunciation")":CHK "$dlaud" \
    --field="$(gettext "Detect language of source text (inaccurate)")":CHK "$ttrgt" \
    --field="$(gettext "Use a system tray icon instead of the start panel")":CHK "$itray" \
    --field="$(gettext "Show notifications when notes are added")":CHK "$swind" \
    --field="$(gettext "Run at startup")":CHK "$stsks" \
    --field="$(gettext "Interface language")":CB "$interface_lang_list" \
    --field="$(gettext "I'm learning")":CB "$(gettext "${tlng}")$list1" \
    --field="$(gettext "My learning level")":CB "$levels_list" \
    --field="$(gettext "My language is")":CB "$(gettext "${slng}")$list2" > "$cnf1" &
    cat "$DS_a/menu_list" |yad --plug=$KEY --tabnum=2 --list \
    --text=" <small>$(gettext "Double-click to configure")</small> " --print-all \
    --dclick-action="$DS/ifs/dclik.sh" \
    --expand-column=2 --no-headers \
    --column=icon:IMG --column=Action &
    yad --notebook --key=$KEY --title="$(gettext "Settings")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png \
    --tab-borders=5 --sticky --center \
    --tab="$(gettext "Preferences")" \
    --tab="$(gettext "Addons")" \
    --width=${sz[0]} --height=${sz[1]} \
    --borders=9 --tab-borders=0 \
    --button="$(gettext "     About     ")"!gtk-about:"$DS/ifs/tls.sh 'about'" \
    --button="$(gettext "Save")"!gtk-save:0 \
    --button="$(gettext "Close")"!gtk-close:1
    ret=$?
    
    if [ $ret -eq 0 ]; then
        n=1
        while [ ${n} -le 10 ]; do
            val=$(cut -d "|" -f${n} < "$cnf1")
            cdb "${cfgdb}" 3 opts "${csets[$((n-1))]}" "${val}"
           let n++
        done
        
        # Interface Language
        val=$(cut -d "|" -f8 < "$cnf1")
        if [[ "$val" != "$intrf" ]]; then
            msg_2 "$(gettext "Are you sure you want to change the interface language?")\n" \
            dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Idiomind")"
            if [ $? -eq 0 ]; then 
                cdb "${cfgdb}" 3 opts intrf "${val}"
                export intrf=$val
                idiomind tasks wait
                
                 if pgrep -f "$DS/ifs/tls.sh itray"; then
					kill -9 $(cat $DT/tray.pid)
					kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
					rm -f "$DT/tray.pid"
				fi
				if  pgrep -f "yad --title="Idiomind" --list"; then
           			kill -9 $(pgrep -f "yad --title="Idiomind" --list")
           		fi
            else
                cdb "${cfgdb}" 3 opts intrf "${intrf}"
            fi
        fi
        
        # Icon tray
        if [[ "$(cdb ${cfgdb} 1 opts itray)"  = TRUE ]] && [[ ! -f "$DT/tray.pid" ]]; then
			show_icon=1
            if ! echo $DESKTOP_SESSION  | grep -E "xfce|xfce"; then # TODO
                msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
                show_icon=0; kill_icon=1
            fi
        elif [[ "$(cdb ${cfgdb} 1 opts itray)"  = FALSE ]] && [[ -f "$DT/tray.pid" ]]; then
            kill_icon=1
        fi
        
        # Autostart
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

        # Language target 
        ntlang=$(cut -d "|" -f9 < "$cnf1")
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
            fi
        fi
        
        # learning level
        nlevel=$(cut -d "|" -f10 < "$cnf1")
        ind=-1
		for i in "${!levels[@]}"; do
			if [ "${levels[$i]}" = "$nlevel" ]; then
				ind="$i"
				break
			fi
		done
        if [[ $(gettext ${level}) != ${nlevel} ]]; then
			cdb "${cfgdb}" 3 opts level "${ind}"
        fi
        
        # Language source 
        nslang=$(cut -d "|" -f11 < "$cnf1")
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
			kill -9 $(pgrep -f "yad --title="Idiomind" --list")
            $DS/ifs/tls.sh itray &
            ( sleep 4; if ! pgrep -f "$DS/ifs/tls.sh itray"; then
				msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
				if ! ps -A |pgrep -f "yad --title=Idiomind --list"; then
				idiomind panel; fi
			fi )
        else 
			if ! ps -A |pgrep -f "yad --title=Idiomind --list"; then
			idiomind panel; fi
        fi
        
    fi
    cleanups "$cnf1" "$DT/.langc"

    exit

}  

config_dlg >/dev/null 2>&1

