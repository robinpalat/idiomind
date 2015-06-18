#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

source /usr/share/idiomind/ifs/c.conf
[[ ! -d "$DC" ]] && "$DS/ifs/1u.sh" && exit
info2=" $(gettext "Are you sure you want to change the language set to learn?")  "
info1=" $(gettext "Are you sure you want to change the source language setting?")  "
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

lang=('English' 'Spanish' 'Italian' 'Portuguese' 'German' \
'Japanese' 'French' 'Vietnamese' 'Chinese' 'Russian')

sets=('gramr' 'wlist' 'trans' 'ttrgt' 'clipw' 'stsks' \
'rplay' 'audio' 'video' 'ntosd' 'loop' \
'langt' 'langs' 'synth' \
'words' 'sntcs' 'marks' 'wprct' 'nsepi' 'svepi')

c=$((RANDOM%100000)); KEY=$c

confirm() {

    yad --form --title="Idiomind" \
    --image=$2 --text="$1\n" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=500 --height=130 --borders=10 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Yes")":0
}

set_lang() {
    
    echo "$tpc" > "$DM_tl/.8.cfg"
    language="$1"
    if [ ! -d "$DM_t/$language/.share" ]; then
    mkdir -p "$DM_t/$language/.share"; fi
    echo "$language" > "$DC_s/6.cfg"
    echo "$lgsl" >> "$DC_s/6.cfg"
    "$DS/stop.sh" 4
    source /usr/share/idiomind/ifs/c.conf
    if [ -f "$DM/topics/$language/.8.cfg" ]; then
    lst=$(sed -n 1p "$DM/topics/$language/.8.cfg")
    "$DS/default/tpc.sh" "$lst" 1
    else rm "$DC_s/4.cfg" && > "$DC_s/4.cfg"; fi
    "$DS/mngr.sh" mkmn &
}

n=0
if [ "$cfg" = 1 ]; then
    while [[ $n -lt 15 ]]; do
        get="${sets[$n]}"
        val=$(grep -o "$get"=\"[^\"]* "$DC_s/1.cfg" | grep -o '[^"]*$')
        declare "${sets[$n]}"="$val"
        ((n=n+1))
    done
    
else
    n=0; > "$DC_s/1.cfg"
    while [[ $n -lt 20 ]]; do
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
    ((n=n+1))
    done
fi

if [ "$text" != TRUE ]; then audio=TRUE; fi
if [ "$trans" != TRUE ]; then trd_trgt=FALSE; fi
yad --plug=$KEY --form --tabnum=1 \
--align=right --scroll \
--separator='|' --always-print-result --print-all \
--field="$(gettext "General Options")\t":lbl " " \
--field=":LBL" " " \
--field="$(gettext "Use color to grammar")":CHK "$gramr" \
--field="$(gettext "List words after adding a sentence")":CHK "$wlist" \
--field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
--field="$(gettext "Detect language of source text (slower)")":CHK "$ttrgt" \
--field="$(gettext "Clipboard watcher")":CHK "$clipw" \
--field="$(gettext "Perform tasks at startup")":CHK "$stsks" \
--field=" :LBL" " " \
--field="$(gettext "Play Options")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Repeat")":CHK "$rplay" \
--field="$(gettext "Play audio")":CHK "$audio" \
--field="$(gettext "Only play videos")":CHK "$video" \
--field="$(gettext "Desktop notifications")":CHK "$ntosd" \
--field="$(gettext "Duration of pause between items:")":SCL "$loop" \
--field=" :LBL" " " \
--field="$(gettext "Languages")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "I'm learning")":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field="$(gettext "My language is")":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field=" :LBL" " " \
--field=":LBL" " " \
--field="<small>$(gettext "Speech Synthesizer (default espeak)")</small>" "$synth" \
--field=" :LBL" " " \
--field="$(gettext "Help")":BTN "$DS/ifs/tls.sh help" \
--field="$(gettext "Feedback")":BTN "$DS/ifs/tls.sh 'fback'" \
--field="$(gettext "Check for Updates")":BTN "$DS/ifs/tls.sh 'check_updates'" \
--field="$(gettext "Your Shared Topics")":BTN "$DS/ifs/upld.sh 'vsd'" \
--field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" > "$cnf1" &
cat "$DC_s/2.cfg" | yad --plug=$KEY --tabnum=2 --list \
--text="<sub>  $(gettext "Double click to set") </sub>" \
--print-all --dclick-action="$DS/ifs/dclik.sh" \
--expand-column=2 --no-headers \
--column=icon:IMG --column=Action &
yad --notebook --key=$KEY --title="$(gettext "Settings")" \
--name=Idiomind --class=Idiomind \
--window-icon="$DS/images/icon.png" \
--tab-borders=5 --sticky --center \
--tab="$(gettext "Preferences")" \
--tab="$(gettext "Addons")" \
--width=470 --height=350 --borders=2 \
--button="$(gettext "Apply")":0 \
--button="$(gettext "Cancel")":1
ret=$?

    if [[ $ret -eq 0 ]]; then
        n=1; v=0
        while [[ $n -le 22 ]]; do
            val=$(cut -d "|" -f$n < "$cnf1")
            if [ -n "$val" ]; then
            sed -i "s/${sets[$v]}=.*/${sets[$v]}=\"$val\"/g" "$DC_s/1.cfg"
            ((v=v+1)); fi
            ((n=n+1))
        done

        val=$(cut -d "|" -f24 < "$cnf1")
        sed -i "s/${sets[13]}=.*/${sets[13]}=\"$val\"/g" "$DC_s/1.cfg"
        
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
        while [[ $n -lt 10 ]]; do
            if cut -d "|" -f20 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgtl" ]; then
                lgtl="${lang[$n]}"
                if grep -o -E 'Chinese|Japanese|Russian|Vietnamese' <<< "$lgtl";
                then info3="\n$(gettext "Some features do not yet work with this language"). ($lgtl)"; fi
                confirm "$info2$info3" dialog-question "$lgtl"
                [ $? -eq 0 ] && set_lang "${lang[$n]}"
                break
            fi
            ((n=n+1))
        done
        
        n=0
        while [[ $n -lt 10 ]]; do
            if cut -d "|" -f21 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgsl" ]; then
                confirm "$info1" dialog-warning
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
    exit
