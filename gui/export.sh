#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# gui/export.sh — GUI de exportación (extracción conservadora de
# ifs/upld.sh, Paso 5C).
#
# Correspondencia:
#   dlg_export -> gui_export_dialog       (--form 6 campos, Export:2/Close:4)
#   fdlg       -> gui_export_file_dialog  (--file+--form plug, --paned)
#
# Contrato (preparado por upld.sh:export_topic/_export):
#   text_export, autr, _Categories, _levels, note, _formats, include_media,
#   sz, tpc, HOME, DS. stdout 6 líneas / path en última línea; ret 2/4, 0/1.
# Sin shims (cero importadores externos; dispatch por case en upld.sh).

# Guarda contra doble source (patrón resto de módulos gui/).
if [ -n "${__GUI_EXPORT_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_EXPORT_SH=1

# Primitivas comunes. Carga documental con guarda (este módulo usa yad
# directo; se mantiene por consistencia, igual que gui/play.sh).
if [ -z "${__GUI_COMMON_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/common.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/common.sh"
fi

function gui_export_dialog() {
    yad --form --title="$(gettext "Export topic")" \
    --text="$text_export" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=$DS/images/logo.png --buttons-layout=end \
    --align=right --center \
    --width=${sz[0]} --height=${sz[1]} --borders=18 \
    --field="$(gettext "Author")" "$autr" \
    --field="$(gettext "Category"):CBE" "$_Categories" \
    --field="$(gettext "Skill Level"):CB" "$_levels" \
    --field="\n$(gettext "Description/Notes"):TXT" "${note}" \
    --field="$(gettext "Format"):CB" "$_formats" \
    --field="$(gettext "Include images and audio"):CHK" "$include_media" \
    --button="$(gettext "Export")":2 \
    --button="$(gettext "Close")":4
}

function gui_export_file_dialog() {
    module="$1"
    key=$((RANDOM%100000)); cd "$HOME"
    yad --file --save --filename="$HOME/$tpc" --tabnum=1 --plug="$key" &
    yad --form --tabnum=2 --plug="$key" \
    --separator="" --align=right \
    --field="\t\t\t\t$(gettext "Export to"):CB" "$module" &
    yad --paned --key="$key" --title="$(gettext "Export")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png --center --on-top \
    --width=650 --height=480 --borders=8 --splitter=370 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}
