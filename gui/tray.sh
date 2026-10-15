#!/usr/bin/env bash

source /usr/share/idiomind/default/c.conf

SELF=$(readlink -f "${BASH_SOURCE[0]}")


playlck="$DT/playlck"
tasks_file="$DT/tasks"
tpc_file="$DC_s/tpc"            

lbl1=${lbl1:-Add}
lbl2=${lbl2:-Play}
lbl3=${lbl3:-Stop}
lbl5=${lbl5:-Topics}
lbl8=${lbl8:-Quit}
lbl9=${lbl9:-Tasks}


RT="${XDG_RUNTIME_DIR:-/tmp}/idiomind-tray-$UID"

set_forced() {                 
    printf '%s' "$1" > "$RT.force"
    [[ -r $RT.pid ]] && kill -USR1 "$(<"$RT.pid")" 2>/dev/null
}


if [[ $1 == --do ]]; then
    case $2 in
        home)   idiomind topic >/dev/null 2>&1 & ;;
        add)    "$DS/add.sh" new_items >/dev/null 2>&1 & ;;
        topics) "$DS/chng.sh" >/dev/null 2>&1 & ;;
        play)   set_forced 0; "$DS/bcle.sh" >/dev/null 2>&1 & ;;
        stop)   set_forced 1; "$DS/stop.sh" 2 >/dev/null 2>&1 & ;;
        tasks)  # pseudo-submenú: lista emergente junto al puntero
                [[ -r $tasks_file ]] || exit 0
                sel=$(grep -v '^$' "$tasks_file" | GDK_BACKEND=x11 yad --list --no-headers \
                        --undecorated --mouse --close-on-unfocus --no-buttons \
                        --width=380 --height=320 --title="$lbl9" \
                        --column="$lbl9" --separator= 2>/dev/null)
                sel=${sel%|}
                [[ -n $sel ]] && "$DS/ifs/tasks.sh" "$sel" >/dev/null 2>&1 &
                ;;
        task)   
                t=$(printf '%s' "$3" | base64 -d 2>/dev/null)
                [[ -n $t ]] && "$DS/ifs/tasks.sh" "$t" >/dev/null 2>&1 & ;;
        quit)
            "$DS/stop.sh" 1 >/dev/null 2>&1 &
            [[ -r $RT.pid ]] && kill "$(<"$RT.pid")" 2>/dev/null
            [[ -r $DT/tray.pid ]] && kill "$(<"$DT/tray.pid")" 2>/dev/null
            ;;
    esac
    exit 0
fi


stts=1
forced=""     
force_sig=""  

playlck_sig() { cksum < "$playlck" 2>/dev/null || echo none; }

get_status() {
    stts=1
    if [[ -r $playlck ]]; then
        local line
        while IFS= read -r line || [[ -n $line ]]; do
            if [[ $line == 0 ]]; then
                stts=1
            elif [[ -n $line ]]; then
                stts=0
            fi
        done < "$playlck"
    fi


    if [[ -n $forced ]]; then
        if [[ $(playlck_sig) == "$force_sig" ]]; then
            stts=$forced
        else
            forced=""
        fi
    fi
}

on_usr1() {
    if [[ -r $RT.force ]]; then
        forced=$(<"$RT.force")
        rm -f "$RT.force"
        force_sig=$(playlck_sig)
    fi
}


MENU=""

clean() {                       # '|' y '!' son delimitadores en yad
    local s=${1//|/ }
    printf '%s' "${s//!/ }"
}

sq() {                          # comillas simples seguras (yad no entiende $'...')
    local s=${1//\'/\'\\\'\'}
    printf "'%s'" "$s"
}

add_item() {                    # etiqueta, argumentos de --do, [icono], [argumento extra]
    local cmd
    cmd="$(sq "$SELF") --do $2"
    [[ -n $4 ]] && cmd+=" $(sq "$4")"
    MENU+="${MENU:+|}$(clean "$1")!${cmd}${3:+!$3}"
}

build_menu() {
    get_status
    MENU=""
    local line

    add_item "$lbl1" add

    if (( stts == 0 )); then
        add_item "$lbl3" stop
    else
        add_item "$lbl2" play
    fi

    # Topic activo: primera línea de ~/.config/idiomind/tpc, releída en cada refresco
    local topic=
    [[ -r $tpc_file ]] && IFS= read -r topic < "$tpc_file"
    [[ -n $topic ]] && add_item "$topic" home go-home


    if [[ -n $DT && -s $tasks_file ]]; then
        if [[ ${TASKS_MODE:-popup} == flat ]]; then
            while IFS= read -r line || [[ -n $line ]]; do
                [[ -z $line ]] && continue
                add_item "$lbl9: $line" task "" "$(printf '%s' "$line" | base64 -w0)"
            done < "$tasks_file"
        else
            add_item "$lbl9  ▸" tasks
        fi
    fi

    add_item "$lbl5" topics
    add_item "$lbl8" quit
}

# ---------------------------------------------------------------------------
# Espera de cambios en $DT (equivale al GFileMonitor)
# ---------------------------------------------------------------------------
wait_change() {
    if [[ -n $DT ]] && command -v inotifywait >/dev/null 2>&1; then
        inotifywait -qq -t 2 -e close_write,create,delete,moved_to "$DT" 2>/dev/null &
    else
        sleep 1 &
    fi
    wait $!             # una señal (USR1) lo interrumpe al instante
    kill $! 2>/dev/null
}

# ---------------------------------------------------------------------------
# Principal (equivale a tray_run)
# ---------------------------------------------------------------------------
command -v yad >/dev/null 2>&1 || { echo "Idiomind tray: yad no está instalado" >&2; exit 1; }


tray_manager_present() {
    [[ -n $DISPLAY ]] || return 1
    command -v python3 >/dev/null 2>&1 || return 0     
    python3 - <<'PY' 2>/dev/null
import ctypes, sys
x = ctypes.CDLL("libX11.so.6")
x.XOpenDisplay.restype = ctypes.c_void_p
x.XDefaultScreen.argtypes = [ctypes.c_void_p]
x.XInternAtom.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
x.XInternAtom.restype = ctypes.c_ulong
x.XGetSelectionOwner.argtypes = [ctypes.c_void_p, ctypes.c_ulong]
x.XGetSelectionOwner.restype = ctypes.c_ulong
d = x.XOpenDisplay(None)
if not d:
    sys.exit(1)
atom = x.XInternAtom(d, b"_NET_SYSTEM_TRAY_S%d" % x.XDefaultScreen(d), 0)
sys.exit(0 if x.XGetSelectionOwner(d, atom) else 1)
PY
}

# Reintenta unos segundos: en el autostart el panel puede tardar en arrancar.
# (cnfg.sh espera hasta ~4 s a que aparezca tray.pid)
if [[ -z $TRAY_FORCE ]]; then
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        tray_manager_present && break
        sleep 0.25
    done
    if ! tray_manager_present; then
        echo "Idiomind tray: no hay bandeja del sistema disponible" >&2
        exit 1
    fi
fi

if [[ -z $DT ]]; then
    echo "Idiomind tray: la variable 'DT' está vacía; no habrá tareas ni estado de reproducción" >&2
fi
FIFO=$(mktemp -u /tmp/idiomind-tray.XXXXXX)
mkfifo "$FIFO" || exit 1
exec 3<>"$FIFO"

YAD_PID=
cleanup() {
    [[ -n $YAD_PID ]] && kill "$YAD_PID" 2>/dev/null
    exec 3>&-
    rm -f "$FIFO" "$RT.pid" "$RT.force"
    if [[ -n $DT && -r $DT/tray.pid && $(<"$DT/tray.pid") == "$YAD_PID" ]]; then
        rm -f "$DT/tray.pid"
    fi
}
trap cleanup EXIT
trap 'exit 0' TERM INT
trap on_usr1 USR1
echo "$$" > "$RT.pid"

build_menu
[[ -n $TRAY_DEBUG ]] && { echo "DT=$DT" >&2; echo "$MENU" | tr '|' '\n' >&2; }


left_click_cmd=()
if command -v xdotool >/dev/null 2>&1; then
    left_click_cmd=(--command="sh -c 'sleep 0.15; xdotool click 3'")
fi

GDK_BACKEND=x11 yad --notification --listen \
    --image=idiomind \
    --text="Idiomind" \
    "${left_click_cmd[@]}" \
    --menu="$MENU" <&3 &
YAD_PID=$!


sleep 0.3
if ! kill -0 "$YAD_PID" 2>/dev/null; then
    echo "Idiomind tray: yad no pudo mostrar el icono" >&2
    YAD_PID=
    exit 1
fi

[[ -n $DT ]] && echo "$YAD_PID" > "$DT/tray.pid"

last=$MENU
while kill -0 "$YAD_PID" 2>/dev/null; do
    wait_change
    build_menu
    if [[ $MENU != "$last" ]]; then
        echo "menu:$MENU" >&3
        last=$MENU
        [[ -n $TRAY_DEBUG ]] && { echo "--- menú actualizado" >&2; echo "$MENU" | tr '|' '\n' >&2; }
    fi
done
