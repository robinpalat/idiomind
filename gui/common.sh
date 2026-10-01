#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# gui/common.sh — primitivas GUI YAD de la aplicación principal.
#
# Alcance:
#   Solo capa de presentación. Sin lógica de negocio:
#   sin SQLite, sin topics, sin traducción, sin reproducción,
#   sin filesystem específico de operaciones, sin addons,
#   sin practice, sin Podcasts.
#
# Uso:
#   source "$DS/gui/common.sh"
#
#   Las funciones aquí definidas no hacen source de otros módulos
#   y no tienen efectos laterales al cargarse. Usan únicamente
#   variables del entorno del llamador: DS, y para gui_about
#   además _version/_descrip/_website/_copyright (de default/sets.cfg).
#   gui_check_err requiere además la función cleanups() del llamador
#   (definida en ifs/cmns.sh); si no existe, el diálogo se muestra
#   igual y solo falla la limpieza final, igual que antes.
#
# Compatibilidad:
#   Los nombres originales (msg, msg_2, ...) se conservan como
#   wrappers finos en sus archivos de origen y delegan aquí.
#   No se normalizan códigos de salida de yad.
#

# Protección contra doble carga (parseo Bash innecesario).
if [ -n "${__GUI_COMMON_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_COMMON_SH=1

# Boilerplate realmente común a todas las primitivas.
# Solo --name/--class/--center (verificado en las 7 funciones).
# --on-top y --window-icon se mantienen inline por función porque
# varían (p.ej. about no usa --on-top; confirm usa --window-icon=idiomind).
GUI_BASE_OPTS=(--name=Idiomind --class=Idiomind --center)

function gui_msg() {
    [ -n "${3}" ] && title="${3}" || title=Idiomind
    [ -n "${4}" ] && btn="${4}" || btn="$(gettext "OK")"
    yad --title="${title}" --text="${1}" --image="${2}" \
    "${GUI_BASE_OPTS[@]}" \
    --window-icon=$DS/images/logo.png \
    --image-on-top --sticky --fixed --on-top \
    --width=450 --height=100 --borders=5 \
    --button="${btn}":0
}

function gui_msg_2() {
    [ -n "${5}" ] && title="${5}" || title=Idiomind
    [ -n "${6}" ] && btn3="--button=${6}:2" || btn3=""
    yad --title="${title}" --text="${1}" --image="${2}" \
    "${GUI_BASE_OPTS[@]}" \
    --always-print-result \
    --window-icon=$DS/images/logo.png \
    --image-on-top --sticky --fixed --on-top \
    --width=450 --height=100 --borders=5 \
    "${btn3}" --button="${4}":1 --button="${3}":0
}

function gui_msg_4() {
    [ -n "${5}" ] && title="${5}" || title=Idiomind
    ( echo "# "; while true; do
    sleep 1; echo "# "; [ ! -e "${6}" ] && break
    done )  | yad --progress --title="${title}" --text="${1}" \
    "${GUI_BASE_OPTS[@]}" \
    --pulsate --auto-close --always-print-result \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=edge --image-on-top \
    --fixed --on-top --sticky \
    --width=380 --height=110 --borders=3 \
    --button="${4}":1 --button="${3}":0
    #--image="$2"
}

function gui_progress() {
    yad --progress \
    "${GUI_BASE_OPTS[@]}" \
    --undecorated --${1} --auto-close \
    --skip-taskbar --on-top --no-buttons
}

function gui_yad_kill() {
    for X in "${@}"; do kill -9 $(pgrep -f "$X") & done
}

function gui_check_err() {
    for filerr in "$@"; do
        if [ -f "$filerr" ]; then
            if [ ${filerr: -4} == ".err" ]; then
                mtitle="$(gettext "Errors found")"
                mimage="dialog-warning"
            elif [ ${filerr: -4} == ".inf" ]; then
                mtitle="$(gettext "Information")"
                mimage="info"
            fi
            sleep 2; echo "$(< "$filerr")" |yad --text-info \
            --title="Idiomind - $mtitle" \
            "${GUI_BASE_OPTS[@]}" \
            --window-icon=$DS/images/logo.png \
            --wrap --margins=5 \
            --show-uri --uri-color="#6591AA" \
            --fontname='monospace 9' \
            --fixed --scroll --on-top \
            --width=500 --height=200 --borders=5 \
            --button="$(gettext "Close")":1
            cleanups "$filerr"
        fi
    done &
}

function gui_confirm() {
    yad --form --title="Idiomind" \
    "${GUI_BASE_OPTS[@]}" \
    --image="$DS/images/trans.png" --text="$1\n" \
    --window-icon=idiomind \
    --skip-taskbar --on-top \
    --width=380 --height=100 --borders=5 \
    --button="   $(gettext "Cancel")   ":1 \
    --button="$(gettext "Yes")":0
}

function gui_about() {
    lnk1='https://idiomind.sourceforge.io/help.html'
    lnk2="https://idiomind.sourceforge.io/contact.html"
    lnk3="https://idiomind.sourceforge.io/donate.html"
    lnk4="https://idiomind.sourceforge.io/license.html"
	yad --form --text-align=center --align=center --scroll \
	--image=$DS/images/about.png --center \
	--title="$(gettext "About")" --image-on-top \
	--width=350 --height=360 --borders=10 --image-on-top \
	--window-icon=$DS/images/logo.png \
	--name=Idiomind --class=Idiomind \
	--field="<b><big><big>Idiomind</big></big></b>":LBL "" \
	--field="$_version":LBL "" \
	--field="$_descrip":LBL "" \
	--field=" ":LBL "" \
	--field="<small><a href='$_website'>$(gettext "Website")</a></small>":LBL "" \
	--field="<small>$(gettext "Program updates")</small>":BTN "$DS/ifs/tls.sh 'check_updates'" \
	--field=" ":LBL "" \
	--field="<small>$_copyright</small>":LBL "" \
	--no-buttons
} >/dev/null 2>&1
