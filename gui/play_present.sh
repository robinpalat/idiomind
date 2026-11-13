#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Presentación fullscreen de Play con YAD (Bash/Shell).
#
# Interfaz visual del motor Play:
#   play_present_open                 abre una única ventana YAD fullscreen
#   play_present_update TRGT SRCE IMG actualiza TARGET/SOURCE/imagen
#   play_present_close               cierra la ventana y libera recursos
#
# El motor Play sigue gestionando playlists, audio, avance y pausas; este
# archivo sólo pinta. La composición visual es un único lienzo PNG de
# dimensiones constantes generado con ImageMagick + Pango (cairo), que se
# muestra en la columna IMG de `yad --list --listen`.
#
# Estructura del lienzo:
#   - con imagen: imagen a la izquierda, TARGET y SOURCE a la derecha,
#     con el mismo eje izquierdo e imagen centrada verticalmente.
#   - sin imagen: TARGET y SOURCE centrados en pantalla (sin hueco lateral).
#   - oraciones largas: reducción de fuente y ajuste de línea.
#
# El color de TARGET reproduce exactamente la regla de `colorize`
# (log3 #AE3259, log2 #C15F27, log1 sin color por defecto).
#
# Requisitos: yad, xdotool, ImageMagick (convert/identify), fc-match.

if [ -n "${__GUI_PLAY_PRESENT_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_PLAY_PRESENT_SH=1

# ----------------------------------------------------------------------------
# Configuración visual
# ----------------------------------------------------------------------------
PP_BG="${PP_BG:-#0d0d12}"                         # fondo uniforme oscuro
PP_FG_SOURCE="${PP_FG_SOURCE:-#9a9a9a}"           # SOURCE: atenuado
PP_SOURCE_DELAY="${PP_SOURCE_DELAY:-2}"            # s tras TARGET en las palabras
PP_FONT_TARGET_MAX="${PP_FONT_TARGET_MAX:-58}"     # tamaño máximo de TARGET
PP_FONT_SOURCE_RATIO="${PP_FONT_SOURCE_RATIO:-50}" # SOURCE como % de TARGET
PP_FC_TARGET="${PP_FC_TARGET:-Sans:bold}"         # fuente para medir TARGET
PP_FC_SOURCE="${PP_FC_SOURCE:-Sans}"              # fuente para medir SOURCE
PP_IMG_W_PCT="${PP_IMG_W_PCT:-40}"                # ancho máx. de imagen (% pantalla)
PP_IMG_H_PCT="${PP_IMG_H_PCT:-32}"                # alto máx. de imagen (% pantalla)
PP_CANVAS_H="${PP_CANVAS_H:-200}"                 # alto del lienzo (minimo; crece con el bloque)
PP_SPACER_H="${PP_SPACER_H:-15}"                  # alto real de una fila vacía
PP_MARGIN_PCT="${PP_MARGIN_PCT:-8}"               # margen lateral (% del ancho de pantalla)
PP_CANVAS_H_MIN="${PP_CANVAS_H_MIN:-200}"         # alto minimo del lienzo
PP_CANVAS_VPAD="${PP_CANVAS_VPAD:-24}"            # relleno vertical alrededor del bloque
PP_MAX_LINES="${PP_MAX_LINES:-3}"                 # objetivo de lineas para TARGET
PP_FONT_MIN="${PP_FONT_MIN:-16}"                  # tamaño minimo de fuente
PP_GAP_TEXT_IMG="${PP_GAP_TEXT_IMG:-40}"          # separacion imagen-texto
PP_IMG_MAX_W="${PP_IMG_MAX_W:-400}"              # ancho maximo de la caja de imagen
PP_TEXT_MIN_W="${PP_TEXT_MIN_W:-600}"             # ancho minimo del bloque de texto

# Colores semánticos (idénticos a colorize)
PP_C_NARANJA="#C15F27"
PP_C_ROJO="#AE3259"
PP_C_DEFECTO="#f4f4f4"

# Estado de sesión derivado de $DT (idéntico en todos los procesos).
PP_DT="${DT:-/tmp/.idiomind-$USER}"
PP_DIR="$PP_DT/present_yad"
PP_FIFO="$PP_DT/play_present.fifo"
PP_BLANK="$PP_DIR/blank.png"
PP_PID_FILE="$PP_DT/play_present.pid"
PP_ACTIVE_FLAG="$PP_DIR/active"

# Variables sólo necesarias en el proceso que abre la ventana.
PP_PID=""
PP_MONITOR=""
PP_XID=""
PP_SOURCE_PID=""
PP_SCREEN_W=1920
PP_SCREEN_H=1080
PP_CANVAS_W=1920
PP_N_LEAD=0
PP_N_TRAIL=0

# Tema GTK privado: iguala el fondo del árbol vacío a PP_BG y evita el
# destello que produce el FormFeed. Solo se aplica al proceso YAD.
PP_THEME_NAME="${PP_THEME_NAME:-IdiomindPresent}"
PP_THEME_DATA="${PP_THEME_DATA:-${DS:-/usr/share/idiomind}/gui/present_theme/share}"

declare -A PP_FONTFILE=()

# ----------------------------------------------------------------------------
# Utilidades
# ----------------------------------------------------------------------------

pp_is_active() {
    [ -f "$PP_ACTIVE_FLAG" ]
}

# Filas vacías para centrar verticalmente el lienzo, según su altura real.
pp_compute_spacers() {
    local avail=$(( PP_SCREEN_H - PP_CANVAS_H ))
    [ "$avail" -lt 0 ] && avail=0
    PP_N_LEAD=$(( avail / 2 / PP_SPACER_H ))
    PP_N_TRAIL=$(( avail / PP_SPACER_H - PP_N_LEAD ))
    [ "$PP_N_TRAIL" -lt 0 ] && PP_N_TRAIL=0
}

pp_screen_size() {
    local g w h
    g="$(xdotool getdisplaygeometry 2>/dev/null)"
    w="$(awk '{print $1}' <<< "$g")"
    h="$(awk '{print $2}' <<< "$g")"
    case "$w" in ''|*[!0-9]*) w=1920 ;; esac
    case "$h" in ''|*[!0-9]*) h=1080 ;; esac
    PP_SCREEN_W="$w"
    PP_SCREEN_H="$h"
    PP_CANVAS_W="$w"
    # El lienzo nunca baja del minimo ni supera la pantalla.
    [ "$PP_CANVAS_H" -lt "$PP_CANVAS_H_MIN" ] && PP_CANVAS_H="$PP_CANVAS_H_MIN"
    if [ "$PP_CANVAS_H" -gt "$PP_SCREEN_H" ]; then
        PP_CANVAS_H=$(( PP_SCREEN_H - 20 ))
        [ "$PP_CANVAS_H" -lt "$PP_CANVAS_H_MIN" ] && PP_CANVAS_H="$PP_CANVAS_H_MIN"
    fi
    pp_compute_spacers
}

pp_xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    printf '%s' "$s"
}

# Color semántico de TARGET: misma regla y colores que colorize.
pp_target_color() {
    local trgt="$1"
    if grep -Fxq -- "$trgt" "${DC_tlt}/practice/log3" 2>/dev/null; then
        printf '%s' "$PP_C_ROJO"
    elif grep -Fxq -- "$trgt" "${DC_tlt}/practice/log2" 2>/dev/null; then
        printf '%s' "$PP_C_NARANJA"
    else
        printf '%s' "$PP_C_DEFECTO"
    fi
}

# Medición de texto con Pango (formato pango:), sin escribir fichero.
# Con $2 (ancho) usa '-size ANCHOx' y Pango envuelve el texto en ese ancho.
pp_pango_measure() {  # $1 markup [$2 ancho]
    if [ -n "${2:-}" ]; then
        convert -size "$2x" -background none pango:"$1" -format "%w %h" info: 2>/dev/null
    else
        convert -background none pango:"$1" -format "%w %h" info: 2>/dev/null
    fi
}

# Escala proporcional de una imagen a una caja (dimensiones resultantes).
pp_scale_dims() {  # $1 w $2 h $3 maxw $4 maxh
    local w=$1 h=$2 mw=$3 mh=$4 sw sh s
    sw=$(( mw * 1000 / w ))
    sh=$(( mh * 1000 / h ))
    s=$(( sw < sh ? sw : sh ))
    echo "$(( w * s / 1000 )) $(( h * s / 1000 ))"
}

# Lienzo completo con imagen + TARGET + SOURCE.
# Pango envuelve el texto en 'text_maxw' (-size ANCHOx). El bloque se mide de
# verdad (TARGET y SOURCE por separado) y el lienzo crece para centrarlo.
pp_compose() {  # $1 target $2 source $3 color $4 imagen(o "") $5 salida [$6 color source]
    local tgt="$1" src="$2" color="$3" img="$4" out="$5"
    local src_color="${6:-$PP_FG_SOURCE}"
    [ -f "$PP_DIR/bg.png" ] || convert -size "${PP_SCREEN_W}x${PP_SCREEN_H}" xc:"$PP_BG" "$PP_DIR/bg.png" 2>/dev/null
    local w=$PP_CANVAS_W
    local margin=$(( w * PP_MARGIN_PCT / 100 ))
    local avail=$(( w - 2 * margin ))
    local iw=0 ih=0 img_w=0 img_h=0 box_w=0 gap=$PP_GAP_TEXT_IMG
    local text_maxw=$avail

    if [ -n "$img" ] && [ -f "$img" ]; then
        read -r iw ih <<< "$(identify -format '%w %h' "$img")"
        box_w=$PP_IMG_MAX_W
        if [ $(( avail - box_w - gap )) -lt "$PP_TEXT_MIN_W" ]; then
            box_w=$(( avail - gap - PP_TEXT_MIN_W ))
        fi
        [ "$box_w" -lt 1 ] && box_w=0
        text_maxw=$(( avail - box_w - gap ))
    fi
    [ "$text_maxw" -gt "$avail" ] && text_maxw=$avail
    [ "$text_maxw" -lt "$PP_TEXT_MIN_W" ] && text_maxw=$PP_TEXT_MIN_W

    # Lienzo a altura completa: el bloque se centra dentro de el y no hace
    # falta limpiar el modelo (ni filas de separacion) en cada actualizacion.
    local canvas_max=$PP_SCREEN_H

    local ft=$PP_FONT_TARGET_MAX fs target_h=0 source_h=0 line_h=1 lines=1
    local target_w=0 source_w=0 iter=0 nf _lw
    while [ "$iter" -lt 4 ]; do
        iter=$(( iter + 1 ))
        fs=$(( ft * PP_FONT_SOURCE_RATIO / 100 ))
        [ "$fs" -lt 1 ] && fs=1
        read -r _lw line_h <<< "$(pp_pango_measure "<span font=\"Sans Bold $ft\">Xg</span>")"
        [ "$line_h" -lt 1 ] && line_h=1
        read -r target_w target_h <<< "$(pp_pango_measure "<span font=\"Sans Bold $ft\">$(pp_xml_escape "$tgt")</span>" "$text_maxw")"
        read -r source_w source_h <<< "$(pp_pango_measure "<span font=\"Sans $fs\">$(pp_xml_escape "$src")</span>" "$text_maxw")"
        lines=$(( (target_h + line_h - 1) / line_h ))
        [ "$lines" -lt 1 ] && lines=1
        if [ "$lines" -le "$PP_MAX_LINES" ] && \
           [ $(( target_h + source_h + 2 * PP_CANVAS_VPAD )) -le "$canvas_max" ]; then
            break
        fi
        [ "$ft" -le "$PP_FONT_MIN" ] && break
        nf=$(( ft * PP_MAX_LINES / lines ))
        # Si el conjunto no cabe en el lienzo, reducir tambien por altura.
        local max_text_h=$(( canvas_max - 2 * PP_CANVAS_VPAD ))
        if [ $(( target_h + source_h )) -gt "$max_text_h" ]; then
            local nf2=$(( ft * max_text_h / (target_h + source_h) ))
            [ "$nf2" -lt "$nf" ] && nf=$nf2
        fi
        [ "$nf" -lt "$PP_FONT_MIN" ] && nf=$PP_FONT_MIN
        [ "$nf" -ge "$ft" ] && break
        ft=$nf
    done

    # Render final del bloque combinado (Pango envuelve en text_maxw).
    local markup
    markup="<span font=\"Sans Bold $ft\" color=\"$color\">$(pp_xml_escape "$tgt")</span>"
    markup+="&#10;<span font=\"Sans $fs\" color=\"$src_color\">$(pp_xml_escape "$src")</span>"
    convert -size ${text_maxw}x -background none pango:"$markup" "$PP_DIR/bloque.png" 2>/dev/null
    # Bounding box real del texto dentro del bloque (WxH+X+Y), sin escribir recorte.
    local bbox block_w=1 block_h=1 bbox_x=0 bbox_y=0
    bbox="$(convert "$PP_DIR/bloque.png" -format "%@" info: 2>/dev/null)"
    read -r block_w block_h bbox_x bbox_y <<< "$(awk -F'[x+]' '{print $1" "$2" "$3" "$4}' <<< "$bbox")"
    case "$block_w" in ''|*[!0-9]*) block_w=1 ;; esac
    case "$block_h" in ''|*[!0-9]*) block_h=1 ;; esac
    case "$bbox_x" in ''|*[!0-9]*) bbox_x=0 ;; esac
    case "$bbox_y" in ''|*[!0-9]*) bbox_y=0 ;; esac
    [ "$block_w" -lt 1 ] && block_w=1
    [ "$block_h" -lt 1 ] && block_h=1

    # Altura total del conjunto (TARGET + SOURCE medidos por separado).
    local text_h=$(( target_h + source_h ))
    [ "$text_h" -lt "$block_h" ] && text_h="$block_h"

    # Lienzo a altura completa: el bloque se centra verticalmente en pantalla.
    local canvas_h=$PP_SCREEN_H
    PP_CANVAS_H=$canvas_h

    # Si el bloque supera el lienzo (contingencia), se centra con desbordamiento
    # simetrico: se prefiere ver el contenido aun saliendo por los bordes antes
    # que recortarlo en silencio.
    local target_y=$(( (canvas_h - block_h) / 2 ))

    local img_x=0 img_y=0 text_x=0 group_w=0
    if [ "$box_w" -gt 0 ] && [ "$iw" -gt 0 ]; then
        read -r img_w img_h <<< "$(pp_scale_dims "$iw" "$ih" "$box_w" "$block_h")"
        # No ampliar: las dimensiones efectivas nunca superan el original.
        [ "$img_w" -gt "$iw" ] && img_w=$iw
        [ "$img_h" -gt "$ih" ] && img_h=$ih
        [ "$img_w" -lt 1 ] && img_w=1
        [ "$img_h" -lt 1 ] && img_h=1
        group_w=$(( img_w + gap + block_w ))
        img_x=$(( (w - group_w) / 2 ))
        [ "$img_x" -lt 0 ] && img_x=0
        text_x=$(( img_x + img_w + gap ))
        img_y=$(( target_y + (block_h - img_h) / 2 ))
    else
        text_x=$(( (w - block_w) / 2 ))
        [ "$text_x" -lt 0 ] && text_x=0
    fi

    # El bloque original se compone con el offset de su bounding box para que
    # el texto quede donde se ha calculado (el bloque es mas ancho que el texto).
    local text_bx=$(( text_x - bbox_x ))
    local text_by=$(( target_y - bbox_y ))

    if [ "$box_w" -gt 0 ] && [ "$iw" -gt 0 ]; then
        convert "$PP_DIR/bg.png" \
            \( "$img" -resize "${img_w}x${img_h}>" \) -geometry +${img_x}+${img_y} -composite \
            "$PP_DIR/bloque.png" -geometry +${text_bx}+${text_by} -composite \
            -define png:compression-level=1 -define png:exclude-chunk=all "$out"
    else
        convert "$PP_DIR/bg.png" \
            "$PP_DIR/bloque.png" -geometry +${text_bx}+${text_by} -composite \
            -define png:compression-level=1 -define png:exclude-chunk=all "$out"
    fi
}

# Placeholder transparente: imprescindible para no dejar celdas IMG vacías.
pp_blank_init() {
    [ -f "$PP_BLANK" ] && return 0
    convert -size 8x8 xc:none "$PP_BLANK" 2>/dev/null || rm -f "$PP_BLANK"
    [ -f "$PP_BLANK" ]
}

# ----------------------------------------------------------------------------
# Interfaz pública
# ----------------------------------------------------------------------------

play_present_open() {
    command -v yad >/dev/null 2>&1 || return 1
    pp_is_active && return 0

    pp_screen_size
    rm -rf "$PP_DIR" 2>/dev/null
    mkdir -p "$PP_DIR" 2>/dev/null || return 1
    pp_blank_init || return 1
    # Fondo a altura completa, precreado para no pagar el coste de `xc:` en
    # cada actualizacion (el lienzo es de la altura de la pantalla).
    convert -size "${PP_SCREEN_W}x${PP_SCREEN_H}" xc:"$PP_BG" "$PP_DIR/bg.png" 2>/dev/null || return 1

    rm -f "$PP_FIFO"
    mkfifo "$PP_FIFO" 2>/dev/null || return 1
    exec 9<>"$PP_FIFO" 2>/dev/null || return 1

    # Tema privado: debe existir index.theme y gtk-3.0/gtk.css. Si falta,
    # se registra el problema y se usa el tema por defecto (sin correccion
    # visual, pero la presentacion sigue funcionando).
    local theme_ok=0
    if [ -r "$PP_THEME_DATA/themes/$PP_THEME_NAME/index.theme" ] && \
       [ -r "$PP_THEME_DATA/themes/$PP_THEME_NAME/gtk-3.0/gtk.css" ]; then
        theme_ok=1
    else
        printf '%s\n' "AVISO: no se encuentra el tema '$PP_THEME_NAME' en '$PP_THEME_DATA'; se usa el tema GTK por defecto." >&2
    fi

    # --name/--class para reglas del WM; --width/--height garantizan la
    # cobertura si el WM no aplica --fullscreen. No se usan --posx/--posy:
    # YAD 0.40.0 falla el parseo cuando valen 0.
    #
    # Las variables de tema se aplican SOLO a este proceso YAD (prefijo de
    # comando), sin modificar el entorno global ni el tema de otras ventanas.
    if [ "$theme_ok" = 1 ]; then
        XDG_DATA_DIRS="$PP_THEME_DATA${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}" \
        GTK_THEME="$PP_THEME_NAME" \
            yad --list --listen \
            --no-headers --no-rules-hint --no-click --search-column=0 \
            --limit=1 \
            --column="IMG:IMG" \
            --name="IdiomindPlayPresent" --class="Idiomind" \
            --title="Idiomind · Play" \
            --width="$PP_SCREEN_W" --height="$PP_SCREEN_H" \
            --fullscreen --undecorated \
            --button="!media-playback-stop!Detener":1 \
            --print-xid="$PP_DIR/xid" \
            <&9 >"$PP_DIR/yad.out" 2>"$PP_DIR/yad.err" &
    else
        yad --list --listen \
            --no-headers --no-rules-hint --no-click --search-column=0 \
            --limit=1 \
            --column="IMG:IMG" \
            --name="IdiomindPlayPresent" --class="Idiomind" \
            --title="Idiomind · Play" \
            --width="$PP_SCREEN_W" --height="$PP_SCREEN_H" \
            --fullscreen --undecorated \
            --button="!media-playback-stop!Detener":1 \
            --print-xid="$PP_DIR/xid" \
            <&9 >"$PP_DIR/yad.out" 2>"$PP_DIR/yad.err" &
    fi
    PP_PID=$!
    echo "$PP_PID" > "$PP_PID_FILE"
    PP_XID=""
    for _ in $(seq 1 20); do
        if [ -s "$PP_DIR/xid" ]; then
            PP_XID="$(cat "$PP_DIR/xid" 2>/dev/null)"
            break
        fi
        sleep 0.1
    done
    : > "$PP_ACTIVE_FLAG"

    # Vigilante: si la ventana desaparece (STOP o cierre externo) se detiene
    # Play. Con el flag "active" se distingue el cierre explicito del accidental.
    (
        while kill -0 "$PP_PID" 2>/dev/null; do
            if [ -n "$PP_XID" ] && ! xwininfo -id "$PP_XID" >/dev/null 2>&1; then
                break
            fi
            sleep 0.4
        done
        if [ -f "$PP_ACTIVE_FLAG" ]; then
            rm -f "$PP_ACTIVE_FLAG"
            "${DS:-/usr/share/idiomind}/stop.sh" 2
        fi
    ) &
    PP_MONITOR=$!
    return 0
}

play_present_update() {  # $1 target $2 source $3 icono [$4 "target" = oculta source]
    local trgt="$1" srce="$2" icon="${3:-}" mode="${4:-}"
    pp_is_active || return 1
    # chng.sh es un proceso independiente de bcle.sh: hay que recalcular la
    # geometria de pantalla aqui, o el lienzo queda con la anchura y los
    # spacers por defecto (arriba del todo).
    pp_screen_size

    local color canvas payload i src_color="$PP_FG_SOURCE"
    color="$(pp_target_color "$trgt")"
    canvas="$PP_DIR/canvas.png"
    [ "$mode" = "target" ] && src_color="$PP_BG"

    pp_compose "$trgt" "$srce" "$color" "$icon" "$canvas" "$src_color" || return 1

    # Sin FormFeed: el modelo no se vacia y TARGET no parpadea al aparecer
    # SOURCE. --limit=1 descarta la fila anterior al insertar la nueva.
    payload="$canvas"$'\n'
    pp_write_payload "$payload"
}

# Cancela la aparicion diferida de SOURCE y elimina su token. Se llama al
# cambiar de elemento, al cerrar la presentacion y al terminar chng.sh. El
# token evita que un temporizador antiguo pise al elemento siguiente.
play_present_cancel_staged() {
    if [ -n "${PP_SOURCE_PID:-}" ]; then
        kill "$PP_SOURCE_PID" 2>/dev/null
        wait "$PP_SOURCE_PID" 2>/dev/null
        PP_SOURCE_PID=""
    fi
    [ -n "${PP_DIR:-}" ] && rm -f "$PP_DIR/source_seq" 2>/dev/null
    return 0
}

# Palabra: TARGET inmediato (SOURCE oculto con el color de fondo para no
# alterar la geometria) y SOURCE a los PP_SOURCE_DELAY segundos. El audio no
# se toca ni se espera: NOTE_INTERVAL (loop) controla la nota siguiente.
play_present_update_staged() {
    local trgt="$1" srce="$2" icon="${3:-}" seq
    pp_is_active || return 1
    play_present_cancel_staged
    play_present_update "$trgt" "$srce" "$icon" target || return 1
    [ -n "$srce" ] || return 0

    seq="$(date +%s%N)-$$-$RANDOM"
    printf '%s\n' "$seq" > "$PP_DIR/source_seq" 2>/dev/null || return 0
    (
        # El hijo no hereda los traps de limpieza de chng.sh.
        trap - EXIT HUP INT TERM
        sleep "${PP_SOURCE_DELAY:-2}"
        [ "$(cat "$PP_DIR/source_seq" 2>/dev/null)" = "$seq" ] || exit 0
        [ "$(< "$PP_DT/playlck" 2>/dev/null)" != 0 ] || exit 0
        play_present_update "$trgt" "$srce" "$icon"
    ) &
    PP_SOURCE_PID=$!
    return 0
}

play_present_close() {
    pp_is_active || { pp_cleanup; return 0; }

    play_present_cancel_staged
    rm -f "$PP_ACTIVE_FLAG" 2>/dev/null
    exec 9>&- 2>/dev/null
    if [ -n "$PP_PID" ]; then
        kill "$PP_PID" 2>/dev/null
        wait "$PP_PID" 2>/dev/null
    fi
    if [ -n "$PP_MONITOR" ]; then
        kill "$PP_MONITOR" 2>/dev/null
        wait "$PP_MONITOR" 2>/dev/null
    fi
    pp_cleanup
    return 0
}

pp_ensure_screen() {
    [ "$PP_CANVAS_W" -gt 0 ] && [ "$PP_CANVAS_H" -gt 0 ] || pp_screen_size
}

# Escribe el payload en el FIFO de YAD en bloques inferiores a PIPE_BUF.
pp_write_payload() {
    local payload="$1" total=${#1} off=0
    local chunk="${PP_PIPE_CHUNK:-4000}"
    pp_yad_alive || return 1
    [ "$total" -eq 0 ] && return 0
    while [ "$off" -lt "$total" ]; do
        printf '%s' "${payload:$off:$chunk}" >&9 2>/dev/null || return 1
        off=$(( off + chunk ))
    done
    return 0
}

# Comprueba que el proceso YAD de la sesion sigue vivo.
pp_yad_alive() {
    local pid="${PP_PID:-}"
    [ -n "$pid" ] || pid="$(cat "$PP_PID_FILE" 2>/dev/null)"
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

pp_cleanup() {
    exec 9>&- 2>/dev/null
    if [ -n "${PP_PID:-}" ]; then
        kill "$PP_PID" 2>/dev/null
        wait "$PP_PID" 2>/dev/null
    fi
    if [ -n "${PP_MONITOR:-}" ]; then
        kill "$PP_MONITOR" 2>/dev/null
        wait "$PP_MONITOR" 2>/dev/null
    fi
    rm -f "$PP_PID_FILE" "$PP_FIFO" 2>/dev/null
    [ -n "${PP_DIR:-}" ] && rm -rf "$PP_DIR" 2>/dev/null
    PP_PID=""
    PP_MONITOR=""
    PP_XID=""
}
