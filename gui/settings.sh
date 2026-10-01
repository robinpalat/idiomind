#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# gui/settings.sh — GUI de Preferences (extracción conservadora de
# cnfg.sh:config_dlg, Paso 5D-A).
#
# Única función: gui_prefs_dialog (notebook Preferences/Addons).
# NO incluye: 1u.sh (bootstrap), chng.sh (selector), set_lang,
# start_mode/start_mode_live (procesos), ni persistencia alguna.
#
# Contrato (preparado por cnfg.sh:config_dlg):
#   KEY no — lo crea aquí (RANDOM); lee gramr/trans/dlaud/ttrgt/itray/
#   swind/stsks/interface_lang_list/tlng/list1/level/levels_list/slng/list2,
#   acheck no, cnf1, sz, DS, DS_a. Escribe cnf1 (plug --form) y setea ret
#   (código del notebook). Termina en YAD -> cnf1 + ret; el apply
#   (cut/cdb/autostart/idiomas) permanece en cnfg.sh.

# Guarda contra doble source (patrón resto de módulos gui/).
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
