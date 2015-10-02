#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
[ ! -d "$DC" ] && "$DS/ifs/1u.sh" && exit
info2="<b>$(gettext "Switch language")</b>"
cd "$DS/addons"
[[ -n "$(< "$DC_s/1.cfg")" ]] && cfg=1 || > "$DC_s/1.cfg"
cnf1=$(mktemp "$DT/cnf1.XXXX")

desktopfile="[Desktop Entry]
Name=Idiomind
GenericName=Learning Tool
Comment=Vocabulary learning tool
Exec=idiomind autostart
Terminal=false
Type=Application
Icon=idiomind
StartupWMClass=Idiomind"

lang=( 'English' 'Spanish' 'Italian' 'Portuguese' 'German' \
'Japanese' 'French' 'Vietnamese' 'Chinese' 'Russian' )
sets=( 'gramr' 'wlist' 'trans' 'ttrgt' 'clipw' 'stsks' \
'langt' 'langs' 'synth' 'txaud' 'intrf' )

confirm() {
    yad --form --title="$(gettext "Confirm")" \
    --image=$2 --text="$1\n" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=340 --height=120 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Yes")":0
}

set_lang() {
    language="$1"
    if [ ! -d "$DM_t/$language/.share/images" ]; then
        mkdir -p "$DM_t/$language/.share/images"; fi
    echo -e "$language\n$lgsl" > "$DC_s/6.cfg"
    "$DS/stop.sh" 4
    source /usr/share/idiomind/ifs/c.conf
    last="$(cd "$DM_tl"/; ls -tNd */ |cut -f1 -d'/' |head -n1)"
    if [ -d "$DM_tl/$last" ]; then
        "$DS/default/tpc.sh" "${last}" 1
    else
        rm > "$DC_s/4.cfg"
    fi
    source "$DS/ifs/mods/cmns.sh"
    list_inadd > "$DM_tl/.2.cfg"
    "$DS/mngr.sh" mkmn &
     if [ ! -d "$DM_tl/.share/Dictionary/.conf" ]; then
        mkdir -p "$DM_tls/Dictionary/.conf"
	echo 0 > "$DM_tls/Dictionary/.conf/8.cfg"
	cdb="$DM_tls/Dictionary/${lgtl}.db"
	echo -n "create table if not exists Words (Word TEXT);" |sqlite3 ${cdb}
    echo -n "create table if not exists Config (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
	ln -fs "$DM_tls/Dictionary" "$DM_tl/$(gettext "New Words")"
    fi
}

config_dlg() {
    n=0
    if [ "$cfg" = 1 ]; then
        while [ ${n} -lt 11 ]; do
            get="${sets[$n]}"
            val=$(grep -o "$get"=\"[^\"]* "$DC_s/1.cfg" | grep -o '[^"]*$')
            declare "${sets[$n]}"="$val"
            ((n=n+1))
        done
    else
        n=0; > "$DC_s/1.cfg"
        while [ ${n} -lt 11 ]; do
        echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
        ((n=n+1))
        done
    fi

    if [ -z "$intrf" ]; then intrf=Default; fi
    lst="$intrf"$(sed "s/\!$intrf//g" <<<"!Default!en!es!fr!it!pt")""
    if [ "$ntosd" != TRUE ]; then audio=TRUE; fi
    if [ "$trans" != TRUE ]; then ttrgt=FALSE; fi

    c=$((RANDOM%100000)); KEY=$c
    yad --plug=$KEY --form --tabnum=1 \
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "General Options")\t":lbl " " \
    --field=":LBL" " " \
    --field="$(gettext "Use color to highlight grammar")":CHK "$gramr" \
    --field="$(gettext "List words after adding a sentence")":CHK "$wlist" \
    --field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
    --field="$(gettext "Detect language of source text (slower)")":CHK "$ttrgt" \
    --field="$(gettext "Clipboard watcher")":CHK "$clipw" \
    --field="$(gettext "Perform tasks at startup")":CHK "$stsks" \
    --field=" :LBL" " " \
    --field="$(gettext "Languages")\t":LBL " " \
    --field=":LBL" " " \
    --field="$(gettext "I'm learning")":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
    --field="$(gettext "My language is")":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
    --field=" :LBL" " " \
    --field=":LBL" " " \
    --field="<small>$(gettext "Use this speech synthesizer instead eSpeak")</small>" "$synth" \
    --field="<small>$(gettext "Program to convert text to WAV file")</small>" "$txaud" \
    --field="$(gettext "Display in")":CB "$lst" \
    --field=" :LBL" " " \
    --field="$(gettext "Help")":BTN "$DS/ifs/tls.sh help" \
    --field="$(gettext "Send Feedback")":BTN "$DS/ifs/tls.sh 'fback'" \
    --field="$(gettext "Check for Updates")":BTN "$DS/ifs/tls.sh 'check_updates'" \
    --field="$(gettext "Backups")":BTN "$DS/ifs/tls.sh 'dlg_backups'" \
    --field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" > "$cnf1" &
    cat "$DS_a/menu_list" | yad --plug=$KEY --tabnum=2 --list \
    --text=" $(gettext "Double-click to set") " \
    --print-all --dclick-action="$DS/ifs/dclik.sh" \
    --expand-column=2 --no-headers \
    --column=icon:IMG --column=Action &
    yad --notebook --key=$KEY --title="$(gettext "Settings")" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --tab-borders=5 --sticky --center \
    --tab="$(gettext "Preferences")" \
    --tab="$(gettext "Extensions")" \
    --width=460 --height=320 --borders=2 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0
    ret=$?

    if [ $ret -eq 0 ]; then
        n=1; v=0
        while [ ${n} -le 15 ]; do
            val=$(cut -d "|" -f$n < "$cnf1")
            if [ -n "$val" ]; then
            sed -i "s/${sets[$v]}=.*/${sets[$v]}=\"$val\"/g" "$DC_s/1.cfg"
            if [ ${v} = 4 ]; then [ "$val" = FALSE ] && CW=0 || CW=1; fi
            ((v=v+1)); fi
            ((n=n+1))
        done
        val=$(cut -d "|" -f16 < "$cnf1")
        [[ "$val" != "$synth" ]] && \
        sed -i "s/${sets[8]}=.*/${sets[8]}=\"$(sed 's|/|\\/|g' <<<"$val")\"/g" "$DC_s/1.cfg"
        val=$(cut -d "|" -f17 < "$cnf1")
        [[ "$val" != "$txaud" ]] && \
        sed -i "s/${sets[9]}=.*/${sets[9]}=\"$(sed 's|/|\\/|g' <<<"$val")\"/g" "$DC_s/1.cfg"
        val=$(cut -d "|" -f18 < "$cnf1")
        [[ "$val" != "$intrf" ]] && \
        sed -i "s/${sets[10]}=.*/${sets[10]}=\"$val\"/g" "$DC_s/1.cfg"
        
        if [ ${CW} = 0 -a -f /tmp/.clipw ]; then
        kill $(cat /tmp/.clipw); rm -f /tmp/.clipw
        elif [ ${CW} = 1 -a ! -f /tmp/.clipw ]; then
        "$DS/ifs/mods/clipw.sh" & fi

        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        
        if cut -d "|" -f8 < "$cnf1" | grep "TRUE"; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
            echo "$desktopfile" > "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
            rm "$config_dir/idiomind.desktop"
            fi
        fi
        n=0
        while [ ${n} -lt 10 ]; do
            if cut -d "|" -f12 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgtl" ]; then
                lgtl="${lang[$n]}"
                if grep -o -E 'Chinese|Japanese|Russian' <<< "$lgtl";
                then info3="\n$(gettext "Some things are still not working for these languages:") Chinese, Japanese, Russian."; fi
                confirm "$info2$info3" dialog-question "$lgtl"
                [ $? -eq 0 ] && set_lang "${lang[$n]}"
                break
            fi
            ((n=n+1))
        done
        n=0
        while [ ${n} -lt 10 ]; do
            if cut -d "|" -f13 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgsl" ]; then
                confirm "$info2" dialog-question
                if [ $? -eq 0 ]; then
                    echo "$lgtl" > "$DC_s/6.cfg"
                    echo "${lang[$n]}" >> "$DC_s/6.cfg"
                    break
                fi
            fi
            ((n=n+1))
        done
    fi
    rm -f "$cnf1" "$DT/.lc"
     >/dev/null 2>&1
    exit
    
}  >/dev/null 2>&1


config_dlg
