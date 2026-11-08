#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Ventana YAD dinámica y persistente para la práctica D (imágenes).
#
# La práctica D solía abrir dos formularios YAD independientes (pregunta y
# respuesta). Este módulo mantiene UNA única ventana `yad --list --listen` y
# actualiza su fila con un lienzo PNG compuesto (imagen + texto) según el
# estado. Los botones son de tipo comando y escriben en una FIFO de control
# que el bucle principal lee con pd_ui_wait.
#
# Interfaz pública (se define al hacer source):
#   pd_ui_open                 abre la ventana y las FIFOs (fd 8 y 9)
#   pd_ui_update IMG TEXTO     compone el lienzo y actualiza la fila
#   pd_ui_wait                 lee el siguiente evento de la FIFO de control
#   pd_ui_close                cierra la ventana y libera recursos
#
# Uso como comando (botones de YAD):
#   practice_d_ui.sh reveal|yes|no|close FIFO
#
# Requisitos: yad, ImageMagick (convert/identify).

if [ -n "${__PRACTICE_D_UI_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__PRACTICE_D_UI_SH=1

PD_UI_DIR="${DT:-/tmp/.idiomind-$USER}/practice_d_ui"
PD_CTRL="$PD_UI_DIR/ctrl.fifo"
PD_YAD_IN="$PD_UI_DIR/yad.in.fifo"
PD_PID_FILE="$PD_UI_DIR/yad.pid"
PD_PID=""
PD_MONITOR=""

# Lienzo: el área de contenido del formulario actual es 386x338 (418 - 2*16).
# Se reserva el mismo ancho y 300 px de alto para imagen + texto.
PD_CANVAS_W=386
PD_CANVAS_H=300
PD_WIN_W=418
PD_WIN_H=370
PD_IMG_MAX_H=230
PD_TEXT_H=70
PD_FILL="${PD_FILL:-#f4f4f4}"

pd_ui_compose() {  # $1 imagen $2 markup de texto $3 salida
    local img="$1" text="$2" out="$3"
    local W=$PD_CANVAS_W H=$PD_CANVAS_H IMG_MAX_H=$PD_IMG_MAX_H TEXT_H=$PD_TEXT_H
    local tmp_img="$PD_UI_DIR/img.png" tmp_txt="$PD_UI_DIR/text.png"
    local iw=0 ih=0 tw=0 th=0 img_x=0 img_y=0 txt_x=0 txt_y=0

    if [ -f "$img" ]; then
        read -r iw ih <<< "$(identify -format '%w %h' "$img" 2>/dev/null)"
        case "$iw" in ''|*[!0-9]*) iw=0 ;; esac
        case "$ih" in ''|*[!0-9]*) ih=0 ;; esac
        if [ "$iw" -gt 0 ] && [ "$ih" -gt 0 ]; then
            convert "$img" -resize "${W}x${IMG_MAX_H}>" "$tmp_img" 2>/dev/null
            if [ -f "$tmp_img" ]; then
                read -r iw ih <<< "$(identify -format '%w %h' "$tmp_img" 2>/dev/null)"
                case "$iw" in ''|*[!0-9]*) iw=0 ;; esac
                case "$ih" in ''|*[!0-9]*) ih=0 ;; esac
            else
                iw=0; ih=0
            fi
        fi
    else
        rm -f "$tmp_img" 2>/dev/null
    fi

    text="${text%$'\n'}"
    text="${text//\\n/}"
    convert -fill "$PD_FILL" -background none pango:"$text" "$tmp_txt" 2>/dev/null
    if [ -f "$tmp_txt" ]; then
        read -r tw th <<< "$(identify -format '%w %h' "$tmp_txt" 2>/dev/null)"
        case "$tw" in ''|*[!0-9]*) tw=0 ;; esac
        case "$th" in ''|*[!0-9]*) th=0 ;; esac
    else
        tw=0; th=0
    fi

    if [ "$iw" -gt 0 ] && [ "$ih" -gt 0 ]; then
        img_x=$(( (W - iw) / 2 ))
        [ "$img_x" -lt 0 ] && img_x=0
        img_y=0
    fi
    if [ "$tw" -gt 0 ] && [ "$th" -gt 0 ]; then
        txt_x=$(( (W - tw) / 2 ))
        [ "$txt_x" -lt 0 ] && txt_x=0
        txt_y=$(( IMG_MAX_H + (TEXT_H - th) / 2 ))
        [ "$txt_y" -lt 0 ] && txt_y=$IMG_MAX_H
    else
        txt_y=$IMG_MAX_H
    fi

    if [ "$iw" -gt 0 ] && [ "$ih" -gt 0 ] && [ "$tw" -gt 0 ] && [ "$th" -gt 0 ]; then
        convert -size "${W}x${H}" xc:none \
            "$tmp_img" -geometry "+${img_x}+${img_y}" -composite \
            "$tmp_txt" -geometry "+${txt_x}+${txt_y}" -composite \
            "$out" 2>/dev/null
    elif [ "$iw" -gt 0 ] && [ "$ih" -gt 0 ]; then
        convert -size "${W}x${H}" xc:none \
            "$tmp_img" -geometry "+${img_x}+${img_y}" -composite \
            "$out" 2>/dev/null
    elif [ "$tw" -gt 0 ] && [ "$th" -gt 0 ]; then
        convert -size "${W}x${H}" xc:none \
            "$tmp_txt" -geometry "+${txt_x}+${txt_y}" -composite \
            "$out" 2>/dev/null
    else
        convert -size "${W}x${H}" xc:none "$out" 2>/dev/null
    fi
    [ -f "$out" ]
}

pd_ui_open() {
    command -v yad >/dev/null 2>&1 || return 1
    mkdir -p "$PD_UI_DIR" 2>/dev/null || return 1
    rm -f "$PD_CTRL" "$PD_YAD_IN" "$PD_PID_FILE" 2>/dev/null
    mkfifo "$PD_CTRL" "$PD_YAD_IN" 2>/dev/null || return 1
    exec 9<>"$PD_YAD_IN" 2>/dev/null || return 1
    exec 8<>"$PD_CTRL" 2>/dev/null || return 1

    # CSS privado solo para este proceso YAD: compacta los cuatro botones
    # (los dos de respuesta con texto) para que la ventana conserve el ancho
    # del formulario anterior (418 px) sin tocar el tema global.
    mkdir -p "$PD_UI_DIR/gtk-3.0" 2>/dev/null
    cat > "$PD_UI_DIR/gtk-3.0/gtk.css" <<'CSS'
buttonbox { spacing: 0px; -GtkButtonBox-child-min-width: 0; }
button { padding: 0px 0px; margin: 0px; min-width: 0px; min-height: 12px; font-size: 9px; }
button image { -gtk-icon-size: 12px; }
CSS

    local cb="$DS/practice/practice_d_ui.sh"
    XDG_CONFIG_HOME="$PD_UI_DIR" \
        yad --list --listen \
        --no-headers --no-rules-hint --no-click \
        --window-icon=$DS/images/logo.png \
        --column="IMG:IMG" \
        --title=" " \
        --width=$PD_WIN_W --height=$PD_WIN_H --borders=6 \
        --center --on-top --skip-taskbar \
        --buttons-layout=spread \
        --button="$(gettext "I did not know it")!$img_no":"\"$cb\" no \"$PD_CTRL\"" \
        --button="!media-seek-forward":"\"$cb\" reveal \"$PD_CTRL\"" \
        --button="$(gettext "I Knew it")!$img_yes":"\"$cb\" yes \"$PD_CTRL\"" \
        <&9 >"$PD_UI_DIR/yad.out" 2>"$PD_UI_DIR/yad.err" &
    PD_PID=$!
    echo "$PD_PID" > "$PD_PID_FILE"
    (
        while kill -0 "$PD_PID" 2>/dev/null; do
            sleep 0.4
        done
        printf 'close\n' >&8 2>/dev/null
    ) &
    PD_MONITOR=$!
    return 0
}

pd_ui_update() {  # $1 imagen $2 markup de texto
    local img="$1" text="$2" canvas="$PD_UI_DIR/canvas.png"
    pd_ui_compose "$img" "$text" "$canvas" || return 1
    printf '\f\n%s\n' "$canvas" >&9 2>/dev/null || return 1
    return 0
}

pd_ui_wait() {
    local ev=""
    IFS= read -r ev <&8 2>/dev/null || return 1
    printf '%s' "$ev"
}

pd_ui_close() {
    if [ -n "$PD_MONITOR" ]; then
        kill "$PD_MONITOR" 2>/dev/null
        wait "$PD_MONITOR" 2>/dev/null
        PD_MONITOR=""
    fi
    if [ -n "$PD_PID" ]; then
        kill "$PD_PID" 2>/dev/null
        wait "$PD_PID" 2>/dev/null
        PD_PID=""
    fi
    exec 9>&- 2>/dev/null
    exec 8>&- 2>/dev/null
    rm -rf "$PD_UI_DIR" 2>/dev/null
    return 0
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    case "$1" in
        reveal) printf 'reveal\n' > "$2" 2>/dev/null ;;
        yes)    printf 'yes\n' > "$2" 2>/dev/null ;;
        no)     printf 'no\n' > "$2" 2>/dev/null ;;
        close)  printf 'close\n' > "$2" 2>/dev/null ;;
    esac
fi
