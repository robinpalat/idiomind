#!/bin/bash
# -*- ENCODING: UTF-8 -*-
set -uo pipefail


shopt -s nullglob   # evita que "carpeta/*" se expanda literalmente si está vacía

CFG_DEFAULT="/usr/share/idiomind/default/c.conf"
if [ ! -r "$CFG_DEFAULT" ]; then
    echo "ERROR: no se puede leer $CFG_DEFAULT" >&2
    exit 1
fi
# shellcheck source=/dev/null
source "$CFG_DEFAULT"

: "${DS:?DS no definido tras cargar c.conf}"
: "${DT:?DT no definido tras cargar c.conf}"

for f in "$DS/ifs/cmns.sh" "$DS/default/sets.cfg"; do
    if [ ! -r "$f" ]; then
        echo "ERROR: no se puede leer $f" >&2
        exit 1
    fi
    # shellcheck source=/dev/null
    source "$f"
done

# Topic explicito ($2, p. ej. Play desde Tasks): tiene prioridad sobre
# el topic activo de c.conf sin modificarlo. $1 (flag) no se toca.
if [ -n "${2:-}" ]; then
    tpc="$2"
    DC_tlt="$DM_tl/${tpc}/.conf"
    DM_tlt="$DM_tl/${tpc}"
fi

rplay=$(tpc_db 1 config rplay) || rplay=""
ritem=0
stnrd=0

export tpc DC_tlt cfg f ritem stnrd numer
export word_rep sentence_rep pause_osd
export -f include msg tpc_db


ok=0
skip_extras=0

echo 0 > "$DT/playlck"
touch "${DM_tlt}"


if [ -z "${tpc:-}" ] || [ ! -d "${DC_tlt:-}" ]; then
    exit 1
fi

sleep 0.5


stts=0
if [ -f "${DC_tlt}/stts" ]; then
    stts=$(sed -n '1p' "${DC_tlt}/stts")
fi
export stts


if ! [[ "$stts" =~ ^[0-9]+$ ]]; then
    echo "ADVERTENCIA: stts='$stts' no es numérico, se usa 0" >&2
    stts=0
fi

is_basic_mode() {
    [[ "$stts" == 1 || "$stts" == 2 || "$stts" == 5 || "$stts" == 6 ]]
}

if is_basic_mode; then

    for key in words sntcs marks learn diffi; do
        val=$(tpc_db 1 config "$key") || val=""
        if [ "$val" = 'TRUE' ]; then
            ok=1
            break
        fi
    done
    [ "$ok" -eq 0 ] && skip_extras=1
fi

if [ "$stts" -gt 10 ]; then
    ext_dir="$DS/ifs/extensions/play"
    if [ -d "$ext_dir" ]; then
        for addon in "$ext_dir"/*; do
            [ -f "$addon" ] || continue
            # shellcheck source=/dev/null
            source "$addon"
            for item in "${!items[@]}"; do
     
                val=$(grep -o "${items[$item]}=\"[^\"]*" "${file_cfg}" | grep -o '[^"]*$')
                if [ "$val" = 'TRUE' ]; then
                    ok=1
                fi
            done
            unset items
        done
    fi
fi

if [ "$skip_extras" -eq 1 ] && [ "${1:-}" != "2" ]; then
    ok=0
fi

if [ "$ok" -eq 1 ]; then
    echo -e "${tpc}" > "$DT/playlck"
    if [ "$rplay" = "TRUE" ]; then
        while :; do
            "$DS/chng.sh" 0
            sleep "${pause_rep}"
            if [ "$(< "$DT/playlck")" = '0' ]; then
                "$DS/stop.sh" 2
                wait   # esperar a que stop.sh termine antes de salir del bucle
                break
            fi
        done
    else
        "$DS/chng.sh" 0
        echo 0 > "$DT/playlck"
        exit 0
    fi
else
    if is_basic_mode; then
        "$DS/play.sh" play_list 2
    else
        notify-send "$(gettext "Nothing to play")" "$(gettext "Exiting...")" -t 3000 &
    fi
fi
