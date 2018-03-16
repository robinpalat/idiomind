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
    yad --form --title="$(gettext "Confirm")" \
    --name=Idiomind --class=Idiomind \
    --image="dialog-question" --text="$1\n" \
    --window-icon=idiomind \
    --skip-taskbar --center --on-top \
    --width=380 --height=100 --borders=5 \
    --button="   $(gettext "Cancel")   ":1 \
    --button="$(gettext "Yes")":0
}

set_lang() {
    language="$1"
    check_dir "$DM_t/$language/.share/images" \
    "$DM_t/$language/.share/audio"
    cdb "${cfgdb}" 3 lang tlng "${language}"
    cdb "${cfgdb}" 3 lang slng "${slng}"
    "$DS/stop.sh" 4
    source "$DS/default/c.conf"
    source "$DS/default/sets.cfg"
    lgt=${tlangs[$tlng]}
    ln -sf "$DS/images/flags/${lgt}.png" "$DT/icon"
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
    sz=(510 350); [[ ${swind} = TRUE ]] && sz=(460 320)
    show_icon=0; kill_icon=0
    opts="$(cdb "${cfgdb}" 5 opts)"
    csets=( 'gramr' 'trans' 'dlaud' 'ttrgt' \
    'itray' 'swind' 'stsks' 'tlang' 'slang' )
    v=1; for get in ${csets[@]}; do
        val=$(sed -n ${v}p <<< "$opts")
        declare "$get"="$val"; let v++
    done
    synth="$(cdb "${cfgdb}" 1 opts synth)"
    txaud="$(cdb "${cfgdb}" 1 opts txaud)"
    intrf="$(cdb "${cfgdb}" 1 opts intrf)"
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
    lk="https://poeditor.com/join/project/Y4OXR1mTmU"

    c=$((RANDOM%100000)); KEY=$c
    yad --plug=$KEY --form --tabnum=1 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field=":LBL" " " \
    --field="$(gettext "Use color to highlight grammar")":CHK "$gramr" \
    --field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
    --field="$(gettext "Download audio pronunciation")":CHK "$dlaud" \
    --field="$(gettext "Detect language of source text (slower)")":CHK "$ttrgt" \
    --field="$(gettext "Show icon in the notification area")":CHK "$itray" \
    --field="$(gettext "Adjust windows size to small screens")":CHK "$swind" \
    --field="$(gettext "Run at startup")":CHK "$stsks" \
    --field=" :LBL" " " --field=":LBL" " " \
    --field="$(gettext "I'm learning")":CB "$(gettext "${tlng}")$list1" \
    --field="$(gettext "My language is")":CB "$(gettext "${slng}")$list2" \
    --field=" :LBL" " " --field=":LBL" " " \
    --field="<small>$(gettext "Use this speech synthesizer instead eSpeak")</small>" "$synth" \
    --field="$(gettext "Pinned Tasks")":BTN "$txaud" \
    --field="$(gettext "Interface language")":CB "$lst" \
    --field=" :LBL" " " --field=":LBL" " " \
    --field="$(gettext "Getting started")":BTN "$DS/ifs/tls.sh help" \
    --field="$(gettext "Report a problem")":BTN "$DS/ifs/tls.sh fback" \
    --field="$(gettext "Check for updates")":BTN "$DS/ifs/tls.sh 'check_updates'" \
    --field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" > "$cnf1" &
    cat "$DS_a/menu_list" |yad --plug=$KEY --tabnum=2 --list \
    --text=" $(gettext "Double-click to configure") " --print-all \
    --dclick-action="$DS/ifs/dclik.sh" \
    --expand-column=2 --no-headers \
    --column=icon:IMG --column=Action &
    yad --notebook --key=$KEY --title="$(gettext "Settings")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --tab-borders=5 --sticky --center \
    --tab="$(gettext "Preferences")" \
    --tab="$(gettext "More")" \
    --width=${sz[0]} --height=${sz[1]} --borders=5 --tab-borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0
    ret=$?

    if [ $ret -eq 0 ]; then
        n=1; v=0
        while [ ${n} -le 12 ]; do
            val=$(cut -d "|" -f${n} < "$cnf1")
            if [ "$val" = TRUE -o "$val" = FALSE ]; then
                cdb "${cfgdb}" 3 opts "${csets[$v]}" "${val}"; ((v=v+1))
            fi
            ((n=n+1))
        done
        
        val=$(cut -d "|" -f15 < "$cnf1")
        [[ "$val" != "$synth" ]] && cdb "${cfgdb}" 3 opts synth "${val}"
        
        val=$(cut -d "|" -f16 < "$cnf1")
        [[ "$val" != "$txaud" ]] && cdb "${cfgdb}" 3 opts txaud "${val}"

        val=$(cut -d "|" -f17 < "$cnf1")
        if [[ "$val" != "$intrf" ]]; then
            cdb "${cfgdb}" 3 opts intrf ${val}
            kill_icon=1; show_icon=1; export intrf=$val
            idiomind tasks &
        fi

        if [[ $(cdb ${cfgdb} 1 opts itray)  = TRUE ]] && [[ ! -f "$DT/tray.pid" ]]; then
            show_icon=1
        elif [[ $(cdb ${cfgdb} 1 opts itray)  = FALSE ]] && [[ -f "$DT/tray.pid" ]]; then
            kill_icon=1
        fi
        if [ $kill_icon = 1 ]; then
            kill -9 $(cat $DT/tray.pid)
            kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
            rm -f "$DT/tray.pid"
        fi
        if [ $show_icon = 1 ]; then
            $DS/ifs/tls.sh itray &
        fi
        
        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        if cut -d "|" -f8 < "$cnf1" |grep "TRUE"; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
                echo "$desktopfile" > "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
                rm "$config_dir/idiomind.desktop"
            fi
        fi
        ntlang=$(cut -d "|" -f11 < "$cnf1")
        if [[ $(gettext ${tlng}) != ${ntlang} ]]; then
            for val in "${lt[@]}"; do
                if [[ ${ntlang} = $(gettext ${val}) ]]; then
                    export tlng=$val
                fi
            done
            if echo "$tlng$slng" |grep -oE 'Chinese|Japanese|Russian'; then
                info3="\n$(gettext "Note that these languages may present some text display errors:") Chinese, Japanese, Russian."
            fi
            confirm "$info2$info3" dialog-question ${tlng}
            [ $? -eq 0 ] && set_lang ${tlng}
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
    fi
    rm -f "$cnf1" "$DT/.lc"

    exit

}  >/dev/null 2>&1

config_dlg

