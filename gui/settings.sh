#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#

if [ -n "${__GUI_SETTINGS_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_SETTINGS_SH=1

# Primitivas comunes. Carga documental con guarda (este módulo usa yad
# directo; se mantiene por consistencia, igual que gui/play.sh).
if [ -z "${__GUI_COMMON_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/common.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/common.sh"
fi

function gui_prefs_dialog() {
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
--text=" <small>$(gettext "Double-click an addon to configure it.")</small> " --print-all \
--dclick-action="$DS/ifs/dclik.sh" \
--expand-column=2 --no-headers \
--column=icon:IMG --column=Action &
yad --notebook --key=$KEY --title="$(gettext "Settings")" \
--name=Idiomind --class=Idiomind \
--window-icon=$DS/images/logo.png \
--sticky --center \
--tab="$(gettext "Preferences")" \
--tab="$(gettext "Addons")" \
--width=${sz[0]} --height=${sz[1]} \
--borders=5 --tab-borders=15 \
--button="$(gettext "     About     ")"!help-about:"$DS/ifs/tls.sh 'about'" \
--button="$(gettext "Save")"!document-save:0 \
--button="$(gettext "Close")"!window-close:1
ret=$?
}
