#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
# GUI de Preferences (Paso 5D-A): gui_prefs_dialog; el apply queda aquí.
if [ -n "${DS:-}" ] && [ -r "$DS/gui/settings.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/settings.sh"
fi
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
    gui_confirm "$@"
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
    mkdir -p "$DM_tls/data"
    tlngdb="$DM_tls/data/${tlng}.db"
    if [ ! -f "${tlngdb}" ]; then
        echo -n "create table if not exists Words \
        (Word TEXT, '${slng^}' TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${tlngdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${tlngdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${tlngdb}
    fi
    if [ ! -f "${shrdb}" ]; then "$DS/ifs/mkdb.sh" share; fi
    if ! file "${shrdb}" | grep 'SQLite'; then "$DS/ifs/mkdb.sh" share; fi

    check_list

    # On target switch the incoming language must not inherit a stale
    # "Update Topics from Feeds" reference: drop it now so that
    # idiomind tasks has no obsolete file, then let the Feeds addon
    # itself refresh (recreates only if this language has feed topics).
    rm -f "$DC_a/Feeds${tlng}_tsk"
    "$DS/ifs/extensions/start/update_feeds.sh" >/dev/null 2>&1 &
    idiomind tasks; "$DS/mngr.sh" mkmn 1 &
}

config_dlg() {
    sz=(470 550)
    kill_icon=0
    source "$DS/default/sets.cfg"
    
    start_mode() {
		if [ "$1" = panel ]; then
            if ! ps -A |pgrep -f "yad --title=Idiomind --list"; then
				idiomind panel
			fi
			(if ps -A |pgrep -f "$DS/ifs/tls.sh itray"; then
				sleep 0.5
				kill -9 $(< $DT/tray.pid)
				kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
				rm -f "$DT/tray.pid"
            fi) &
		elif [ "$1" = icon ]; then
			if ps -A |pgrep -f "yad --title=Idiomind --list"; then
				kill -9 $(pgrep -f "yad --title="Idiomind" --list")
            fi
            if ! ps -A |pgrep -f "$DS/ifs/tls.sh itray"; then
				$DS/ifs/tls.sh itray &
				( sleep 2
				if ! pgrep -f "$DS/ifs/tls.sh itray"; then
					msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
					if ! ps -A |pgrep -f "yad --title=Idiomind --list"; then
						idiomind panel
					fi
				fi
				)
			fi
		fi
        }

    start_mode_live() {
        local tray_pid tray_launcher

        tray_ready() {
            [ -s "$DT/tray.pid" ] || return 1
            tray_pid="$(< "$DT/tray.pid")"
            [[ "$tray_pid" =~ ^[0-9]+$ ]] || return 1
            kill -0 "$tray_pid" 2>/dev/null
        }

        stop_tray() {
            if [ -s "$DT/tray.pid" ]; then
                tray_pid="$(< "$DT/tray.pid")"
                [[ "$tray_pid" =~ ^[0-9]+$ ]] && kill -9 "$tray_pid" 2>/dev/null
            fi
            pkill -9 -f "$DS/ifs/tls.sh itray" 2>/dev/null || :
            cleanups "$DT/tray.pid"
        }

        start_tray() {
            if tray_ready; then return 0; fi
            if pgrep -f "$DS/ifs/tls.sh itray" >/dev/null 2>&1; then
                for _ in {1..40}; do
                    tray_ready && return 0
                    sleep 0.1
                done
                return 1
            fi
            cleanups "$DT/tray.pid"
            "$DS/ifs/tls.sh" itray &
            tray_launcher=$!
            for _ in {1..40}; do
                tray_ready && return 0
                kill -0 "$tray_launcher" 2>/dev/null || break
                sleep 0.1
            done
            return 1
        }

        if [ "$1" = panel ]; then
            if ! pgrep -f "yad --title=Idiomind --list" >/dev/null 2>&1; then
                idiomind panel
            fi
            stop_tray &
        elif [ "$1" = icon ]; then
            if start_tray; then
                pkill -9 -f "yad --title=Idiomind --list" 2>/dev/null || :
            else
                msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
                if ! pgrep -f "yad --title=Idiomind --list" >/dev/null 2>&1; then
                    idiomind panel
                fi
            fi
        fi
    }

    if [ $(cdb "${cfgdb}" 5 opts |wc -l) != 13 ]; then
        rm "${cfgdb}"; "$DS/ifs/mkdb.sh" config
    fi

    for get in "${csets[@]}"; do
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

    # Diálogo en gui/settings.sh (termina en YAD -> cnf1 + ret).
    gui_prefs_dialog
    
    if [ $ret -eq 0 ]; then
        n=1
        while [ ${n} -le 10 ]; do
            val=$(cut -d "|" -f${n} < "$cnf1")
            cdb "${cfgdb}" 3 opts "${csets[$((n-1))]}" "${val}"
           let n++
        done
        
        # Interface Language
        val=$(cut -d "|" -f8 < "$cnf1")
        restart=FALSE
        if [[ "$val" != "$intrf" ]]; then
			restart=TRUE
            msg_2 "$(gettext "Are you sure you want to change the interface language?")\n" \
            dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Idiomind")"
            if [ $? -eq 0 ]; then 
                cdb "${cfgdb}" 3 opts intrf "${val}"
                export intrf=$val
                idiomind tasks &&
				( sleep 1
                 if ps -A |pgrep -f "$DS/ifs/tls.sh itray"; then
					kill -9 $(cat $DT/tray.pid)
					kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
					rm -f "$DT/tray.pid"
				fi
				if  ps -A |pgrep -f "yad --title=Idiomind --list"; then
           			kill -9 $(pgrep -f "yad --title="Idiomind" --list")
           		fi
           		)
            else
                cdb "${cfgdb}" 3 opts intrf "${intrf}"
            fi
        fi
        
        # Icon tray
        show_icon="$(cdb ${cfgdb} 1 opts itray)"
        
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

        if [ $show_icon = TRUE ]; then
            start_mode_live icon $restart
        else
            start_mode_live panel $restart
        fi
        
    fi
    cleanups "$cnf1" "$DT/.langc"

    exit

}  

config_dlg >/dev/null 2>&1
