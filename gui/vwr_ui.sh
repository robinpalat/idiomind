#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Visor de palabras y oraciones en terminal (migración del visor YAD
# word_view/sentence_view). Se ejecuta dentro de una terminal abierta por
# vwr_term_open y recibe el contexto escrito por vwr_term_view.
#
# Acciones: escribe "<ctx>.res" con close|next|prev|edit|words y termina.
# El sonido usa el mecanismo existente (play.sh play_word / play_sentence);
# VWR_PLAY_CMD permite sustituirlo (solo pruebas).

[ -r "${1:-}" ] || exit 1
ctx="$1"
VWR_RES="${ctx}.res"
VWR_PLAYLOG="${ctx}.play"
VWR_DONE=0

vwr_cursor() {
    printf '%s' "$1" > /dev/tty 2>/dev/null || printf '%s' "$1"
}

vwr_finish() {
    vwr_cursor $'\033[?25h'
    [ "${VWR_DONE}" = 1 ] || printf 'close\n' > "${VWR_RES}"
}
trap 'vwr_finish' EXIT
trap 'exit 130' HUP INT TERM

vwr_cursor $'\033[?25l'

# shellcheck source=/dev/null
source "${ctx}"
# shellcheck source=/dev/null
source /usr/share/idiomind/default/c.conf
[ -r "$DS/ifs/cmns.sh" ] && source "$DS/ifs/cmns.sh"
[ -r "$DS/gui/vwr_term.sh" ] && source "$DS/gui/vwr_term.sh"

tpc="${VWR_TPC}"; tpcdb="${VWR_TPCDB}"; DC_tlt="${VWR_DC_TLT}"
export tpc tpcdb DC_tlt

POS="${VWR_POS}"; LIST="${VWR_LIST}"; KIND="${VWR_KIND}"; SEL=0
VIEW=sentence      # vista de oración (por defecto) o de lista de palabras
SCROLL=0           # compatibilidad con la navegación existente
HSCROLL=0          # primer bloque horizontal visible en la lista
LIST_TARGET=()     # palabras objetivo de la lista, nunca traducciones
TARGETS=()         # palabras objetivo de la oración actual
TRANSLATIONS=()    # traducciones emparejadas de wrds (misma posición que TARGETS)
VIEW_AVAIL=1       # filas de tabla visibles (las usa el auto-scroll de j/k)
re='^[0-9]+$'; [[ "${POS}" =~ ${re} ]] || POS=1

vwr_result() {
    printf '%s\n' "$1" > "${VWR_RES}"
    VWR_DONE=1
    exit 0
}

play_cmd() {
    printf '%s\n' "$1" >> "${VWR_PLAYLOG}"
    if [ -n "${VWR_PLAY_CMD:-}" ]; then
        eval "${VWR_PLAY_CMD}" >/dev/null 2>&1
    else
        eval "$1" >/dev/null 2>&1 &
    fi
}

E=$'\033'

# --- Color por estadisticas de practica (la misma regla que Play/colorize) ---
# log3 = rojo (dificil), log2 = naranja (en aprendizaje), log1 = verde (facil).
# Se cargan una sola vez por vista; la clasificacion no se vuelve a implementar.
declare -A VWR_C1=() VWR_C2=() VWR_C3=()
for _vwr_n in 1 2 3; do
    _vwr_f="${DC_tlt}/practice/log${_vwr_n}"
    [ -r "${_vwr_f}" ] || continue
    while IFS= read -r _vwr_w; do
        [ -n "${_vwr_w}" ] || continue
        _vwr_w="${_vwr_w,,}"
        case "${_vwr_n}" in
            1) VWR_C1["${_vwr_w}"]=1 ;;
            2) VWR_C2["${_vwr_w}"]=1 ;;
            3) VWR_C3["${_vwr_w}"]=1 ;;
        esac
    done < "${_vwr_f}"
done
unset _vwr_n _vwr_f _vwr_w

# Codigo de color de una palabra (38;2;R;G;B) o vacio si no tiene estadistica.
vwr_word_color() {
    local w="$1" core c
    core="$(printf '%s' "$w" | sed -e 's/^[[:punct:]]*//' -e 's/[[:punct:]]*$//')"
    for c in "$w" "$core"; do
        [ -n "$c" ] || continue
        c="${c,,}"
        if [ -n "${VWR_C3[$c]:-}" ]; then printf '%s' '38;2;174;50;89'; return; fi
        if [ -n "${VWR_C2[$c]:-}" ]; then printf '%s' '38;2;193;95;39'; return; fi
        if [ -n "${VWR_C1[$c]:-}" ]; then printf '%s' '38;2;76;140;18'; return; fi
    done
}

# Pinta una palabra con su color; $2 = estilo base ("1;" = negrita).
vwr_paint_word() {
    local t="$1" st="${2:-}" c
    c="$(vwr_word_color "$t")"
    # Sin color, el prefijo "1;" daria "[1;m" = SGR 1 + SGR 0 (reset), perdiendo
    # la negrita; se recorta el ';' final. Con color se mantiene "1;38;2;...".
    if [ -z "$c" ]; then
        st="${st%;}"
    fi
    if [ -n "$c" ]; then
        printf '%s[%s%sm%s%s[0m' "$E" "$st" "$c" "$t" "$E"
    elif [ -n "$st" ]; then
        printf '%s[%sm%s%s[0m' "$E" "$st" "$t" "$E"
    else
        printf '%s' "$t"
    fi
}

# Pinta cada palabra de un texto (se conserva el estilo base indicado).
vwr_paint_words() {  # $1 texto $2 estilo base
    local text="$1" st="${2:-}" tok out=""
    local -a toks
    # read -ra separa por espacios SIN expansion de globs (un '*' no debe
    # convertirse en la lista del directorio de trabajo).
    read -ra toks <<< "$text"
    for tok in "${toks[@]}"; do
        out+="$(vwr_paint_word "$tok" "$st") "
    done
    printf '%s' "$out"
}

# Celda de palabra con color y relleno por ancho visible.
vwr_paint_pad() {  # $1 ancho $2 palabra $3 estilo base
    local w="$1" t="$2" st="${3:-}" c
    c="$(vwr_word_color "$t")"
    if [ -n "$c" ]; then
        printf '%s[%s%sm%-*s%s[0m' "$E" "$st" "$c" "$w" "$t" "$E"
    elif [ -n "$st" ]; then
        printf '%s[%sm%-*s%s[0m' "$E" "$st" "$w" "$t" "$E"
    else
        printf '%-*s' "$w" "$t"
    fi
}

# Par palabra-traduccion: solo la palabra lleva color estadistico.
vwr_pair() {  # $1 ancho palabra $2 palabra $3 ancho traduccion $4 traduccion
    printf '%s  %-*s' "$(vwr_paint_pad "$1" "$2" "")" "$3" "$4"
}

# Texto plano para plegar y medir: quita marcas HTML; los enlaces quedan URL.
plain() {
    local t="$1"
    t="$(printf '%s' "${t}" | sed \
        -e "s|<a href='\([^']*\)'>[^<]*</a>|\1|g" \
        -e 's|<[^>]*>||g')"
    printf '%s' "${t}"
}

term_cols() {
    local c
    c="$(tput cols 2>/dev/null)"
    [ -n "${c}" ] && [ "${c}" -gt 20 ] 2>/dev/null || c=80
    printf '%s' "${c}"
}

term_rows() {
    local r
    r="$(tput lines 2>/dev/null)"
    [ -n "${r}" ] && [ "${r}" -ge 8 ] 2>/dev/null || r=24
    printf '%s' "${r}"
}

# Ancho visible de una línea (sin secuencias ANSI).
vcw() {
    local s
    s="$(printf '%s' "$1" | sed -e $'s/\x1b\\[[0-9;]*m//g')"
    printf '%s' "${#s}"
}

# Emite la línea centrada en COLS.
emitc() {
    local p
    p=$(( (COLS - $(vcw "$1")) / 2 ))
    [ "${p}" -lt 0 ] && p=0
    printf '%*s%s\n' "${p}" "" "$1"
}

# Primera línea: contador a la izquierda y, si la nota está marcada,
# asterisco en el extremo derecho usando el ancho real de la terminal.
print_header() {
    local h="[${POS}/${ntotal}]"
    printf '%s%s%s\n' "${E}[2;90m" "${h}" "${E}[0m"
}

# Resaltado del ejemplo: coincidencias COMPLETAS (límites de palabra),
# insensibles a mayúsculas, conservando la capitalización original.
# \</\> son límites de palabra de GNU sed: "beach" no resalta dentro de
# "beachside", pero sí en "Beach", "beach." o "beach's".
hl_field() {
    local t="$1" esc
    [ -n "${trgt_plain}" ] || { printf '%s' "$t"; return; }
    esc="${trgt_plain,,}"
    esc="${esc//\\/\\\\}"; esc="${esc//|/\\|}"; esc="${esc//./\\.}"
    esc="${esc//\[/\\[}"; esc="${esc//\]/\\]}"; esc="${esc//\*/\\*}"
    esc="${esc//\^/\\^}"; esc="${esc//\$/\\$}"
    printf '%s' "$t" | sed -e "s|\\<\\(${esc}\\)\\>|${E}[1;97m\\1${E}[0m|gI"
}

# Grilla compacta de pares palabra–traducción en columnas (sin bordes ni
# cajas): dos pares por fila cuando caben; si no, un par por fila; y en
# última instancia la traducción se pliega dentro de su columna (sin
# truncar). Separador discreto "│" entre pares; columnas alineadas por
# espaciado. La unidad de selección sigue siendo el PAR (SEL) y la tabla
# se alinea a la izquierda del área de contenido.
build_grid() {
    GRID=()
    PARLINE=()
    NWORDS=0
    local -a words=() trans=() tl
    local w rec i k mode o_w t_w t_w2 max_t fit seg seg1 seg2 o t pl
    while IFS= read -r w; do
        [ -n "${w}" ] && words+=("${w}")
    done <<< "$(tr '_' '\n' <<< "${wrds:-}")"
    [ ${#words[@]} -eq 0 ] && return 0
    NWORDS=${#words[@]}
    for w in "${words[@]}"; do
        rec="$(grep -F -m 1 "trgt{${w}}" "${DC_tlt}/data" 2>/dev/null | sed 's/}/}\n/g')"
        trans+=("$(grep -oP '(?<=srce{).*(?=})' <<< "${rec}")")
    done
    o_w=0; max_t=0
    for i in "${!words[@]}"; do
        [ ${#words[$i]} -gt "${o_w}" ] && o_w=${#words[$i]}
        [ ${#trans[$i]} -gt "${max_t}" ] && max_t=${#trans[$i]}
    done
    t_w2=$(( max_t > 20 ? 20 : max_t ))
    fit=$(( o_w + 2 + t_w2 + 5 + o_w + 2 + t_w2 ))
    if [ "${fit}" -le "${FW}" ]; then
        mode=2; t_w=${t_w2}
    else
        mode=1
        t_w=${max_t}
        fit=$(( o_w + 2 + t_w ))
        if [ "${fit}" -gt "${FW}" ]; then
            t_w=$(( FW - o_w - 2 )); [ "${t_w}" -lt 4 ] && t_w=4
        fi
    fi
    i=0
    while [ "${i}" -lt "${#words[@]}" ]; do
        if [ "${mode}" = 2 ]; then
            seg1="$(vwr_pair "${o_w}" "${words[$i]}" "${t_w}" "${trans[$i]:-}")"
            [ "${i}" -eq "${SEL}" ] && seg1="${E}[7m${seg1}${E}[0m"
            pl=${#GRID[@]}
            if [ -n "${words[$((i+1))]:-}" ]; then
                seg2="$(vwr_pair "${o_w}" "${words[$((i+1))]}" "${t_w}" "${trans[$((i+1))]:-}")"
                [ "$((i+1))" -eq "${SEL}" ] && seg2="${E}[7m${seg2}${E}[0m"
                GRID+=("${seg1}  │  ${seg2}")
                PARLINE[$((i+1))]=${pl}
            else
                GRID+=("${seg1}")
            fi
            PARLINE[$i]=${pl}
            i=$((i+2))
        else
            o="${words[$i]}"; t="${trans[$i]:-}"
            pl=${#GRID[@]}
            if [ ${#t} -le "${t_w}" ]; then
                seg="$(vwr_pair "${o_w}" "${o}" "${t_w}" "${t}")"
                [ "${i}" -eq "${SEL}" ] && seg="${E}[7m${seg}${E}[0m"
                GRID+=("${seg}")
            else
                mapfile -t tl < <(fold -s -w "${t_w}" <<< "${t}")
                seg="$(vwr_paint_pad "${o_w}" "${o}" "")  ${tl[0]:-}"
                [ "${i}" -eq "${SEL}" ] && seg="${E}[7m${seg}${E}[0m"
                GRID+=("${seg}")
                for (( k=1; k<${#tl[@]}; k++ )); do
                    seg="$(printf '%*s%s' "$((o_w + 2))" '' "${tl[$k]}")"
                    [ "${i}" -eq "${SEL}" ] && seg="${E}[7m${seg}${E}[0m"
                    GRID+=("${seg}")
                done
            fi
            PARLINE[$i]=${pl}
            i=$((i+1))
        fi
    done
}

build_list() {
    LIST_LINES=()
    LIST_BLOCK=()
    LIST_ROW=()
    LIST_HEIGHT=()
    LIST_BSTART=()
    LIST_BEND=()
    LIST_NBLOCKS=0
    LIST_NFIT=1
    LIST_CELLW=1
    LIST_TARGET=("${TARGETS[@]}")
    local -a words=("${TARGETS[@]}") trans=("${TRANSLATIONS[@]}")
    local i cellw gap b cur_start cur_rows wtext ttext line maxw natural
    [ ${#words[@]} -eq 0 ] && return 0
    maxw=0
    for i in "${!words[@]}"; do
        natural=$(( ${#words[$i]} + 3 + ${#trans[$i]} ))
        [ "${natural}" -gt "${maxw}" ] && maxw=${natural}
    done
    cellw=${maxw}
    gap=4
    LIST_NFIT=$(( (LW + gap) / (cellw + gap) )); [ "${LIST_NFIT}" -lt 1 ] && LIST_NFIT=1
    LIST_CELLW=${cellw}
    b=0; cur_start=0; cur_rows=0
    for i in "${!words[@]}"; do
        if [ $(( cur_rows + 1 )) -gt "${vis}" ] && [ "${cur_rows}" -gt 0 ]; then
            LIST_BSTART+=("${cur_start}")
            LIST_BEND+=($(( ${#LIST_LINES[@]} - 1 )))
            LIST_NBLOCKS=$(( LIST_NBLOCKS + 1 ))
            b=${LIST_NBLOCKS}; cur_start=${#LIST_LINES[@]}; cur_rows=0
        fi
        LIST_BLOCK[$i]=${b}
        LIST_ROW[$i]=${cur_rows}
        LIST_HEIGHT[$i]=1
        wtext="${words[$i]}"
        ttext="${trans[$i]:-}"
        if [ "${i}" -eq "${SEL}" ]; then
            wcell="${E}[7m$(vwr_paint_word "${wtext}" "1;")${E}[0m"
        else
            wcell="$(vwr_paint_word "${wtext}" "1;")"
        fi
        natural=$(( ${#wtext} + 3 + ${#ttext} ))
        line="${wcell} ${E}[2;90m·${E}[0m ${E}[2;90m${ttext}${E}[0m"
        line+="$(printf '%*s' $(( cellw - natural )) '')"
        LIST_LINES+=("${line}")
        cur_rows=$(( cur_rows + 1 ))
    done
    if [ "${cur_rows}" -gt 0 ]; then
        LIST_BSTART+=("${cur_start}")
        LIST_BEND+=($(( ${#LIST_LINES[@]} - 1 )))
        LIST_NBLOCKS=$(( LIST_NBLOCKS + 1 ))
    fi
}

add_blank() {
    local n="${1:-1}"
    while [ "${n}" -gt 0 ]; do MA+=(""); n=$((n-1)); done
}

# Agrega una línea plegada (con resaltado opcional del ejemplo).
push_field() {
    local l
    mapfile -t _f < <(fold -s -w "${FW}" <<< "$1")
    for l in "${_f[@]}"; do
        [ "${2:-}" = hl ] && l="$(hl_field "${l}")"
        MA+=("${l}")
    done
}

# Bloque de oración alineado a la izquierda con un padding fijo por ancho.
# El margen depende solo de COLS, nunca de la longitud del texto, y es el
# mismo para la oración y su traducción. Las líneas se marcan con ¦ para que
# render las imprima sin recentrar.
push_left_block() {
    local style="$1" txt="$2" color="${3:-0}" l pad width maxpad
    local -a blines=()
    pad=$(( COLS / 10 )); [ "${pad}" -lt 2 ] && pad=2
    maxpad=$(( (COLS - 1) / 4 )); [ "${maxpad}" -lt 1 ] && maxpad=1
    [ "${pad}" -gt "${maxpad}" ] && pad=${maxpad}
    width=$(( COLS - 2 * pad )); [ "${width}" -lt 1 ] && width=1
    mapfile -t blines < <(fold -s -w "${width}" <<< "${txt}")
    for l in "${blines[@]}"; do
        if [ "${color}" = 1 ]; then
            l="$(vwr_paint_words "$l" "$style")"
            MA+=("¦$(printf '%*s' "${pad}" '')${l}${E}[0m")
        else
            MA+=("¦$(printf '%*s' "${pad}" '')${E}[${style}m${l}${E}[0m")
        fi
    done
}

# Bloque principal en vertical: original arriba y traducción debajo.
# El ejemplo y el resto de campos NO forman parte de este bloque: así su
# altura (y por tanto la posición del contenido principal) no depende de
# que exista un ejemplo ni de cuántas líneas ocupe.
# $1 = separación entre original y traducción (1..2 según espacio).
build_main() {
    local g="$1" l mp=""
    # El indicador de marcado va inmediatamente a la izquierda del TARGET.
    [ "${mark}" = TRUE ] && mp="* "
    MA=()
    if [ "${KIND}" = sentence ]; then
        # Oración: bloque alineado a la izquierda con margen fijo.
        push_left_block "1;" "$(printf '%s%s' "${mp}" "$(plain "${ORIG}")")" 1
    else
        mapfile -t _a < <(fold -s -w "${FW}" <<< "$(printf '%s%s' "${mp}" "$(plain "${ORIG}")")")
        for l in "${_a[@]}"; do
            MA+=("$(vwr_paint_words "$l" "1;")${E}[0m")
        done
    fi
    if [ -n "${srce}" ]; then
        add_blank "${g}"
        if [ "${KIND}" = sentence ]; then
            # Traducción: mismo margen izquierdo que la oración.
            push_left_block "3;2;" "$(plain "${srce}")" 0
        else
            mapfile -t _b < <(fold -s -w "${FW}" <<< "$(plain "${srce}")")
            for l in "${_b[@]}"; do
                MA+=("${E}[3;2m${l}${E}[0m")
            done
        fi
    fi
}

# Zona independiente para ejemplo, enlace y metadatos. Se dibuja después del
# bloque principal, en las filas que quedan libres antes del pie; su altura
# real nunca participa en el cálculo de pad_top.
det_blank() {
    local n="${1:-1}"
    while [ "${n}" -gt 0 ]; do DET+=(""); n=$((n-1)); done
}

push_detail() {
    local l
    mapfile -t _f < <(fold -s -w "${FW}" <<< "$1")
    for l in "${_f[@]}"; do
        [ "${2:-}" = hl ] && l="$(hl_field "${l}")"
        DET+=("${l}")
    done
}

build_details() {
    local g="$1" any=0
    DET=()
    if [ "${KIND}" = word ]; then
        [ -n "${link}" ] && DET+=("${E}[2m${link}${E}[0m")
        [ -n "${exmp}" ] && any=1
        [ -n "${defn}" ] && any=1
        [ -n "${note}" ] && any=1
        [ -n "${tags}" ] && any=1
        if [ "${any}" = 1 ]; then
            det_blank "${g}"
            [ -n "${exmp}" ] && push_detail "$(gettext "Example"): $(plain "${exmp}")" hl
            [ -n "${defn}" ] && push_detail "$(gettext "Definition"): $(plain "${defn}")"
            [ -n "${note}" ] && push_detail "$(gettext "Note"): $(plain "${note}")"
            [ -n "${tags}" ] && push_detail "$(gettext "Tags"): $(plain "${tags}")"
        fi
    else
        [ -n "${exmp}" ] && any=1
        [ -n "${note}" ] && any=1
        if [ "${any}" = 1 ]; then
            det_blank "${g}"
            [ -n "${exmp}" ] && push_detail "$(gettext "Example"): $(plain "${exmp}")"
            [ -n "${note}" ] && push_detail "$(gettext "Note"): $(plain "${note}")"
        fi
        # La lista de palabras vive en su propia vista (tecla l);
        # la vista de oración no la incluye.
    fi
}

# Composición: contador arriba a la izquierda, bloque principal en una
# posición fija, zona independiente para el ejemplo y pie anclado abajo.
render() {
    local COLS ROWS FW MARG LW ntotal keys_str header gap core_n slot spare
    local pad_top pad_bot footer_n avail i l SEP gl
    local -a MA DET KL
    COLS="$(term_cols)"; ROWS="$(term_rows)"
    FW=$((COLS - 6)); [ "${FW}" -lt 16 ] && FW=16
    MARG=$(( (COLS - FW) / 2 )); [ "${MARG}" -lt 1 ] && MARG=1
    trgt_plain="$(plain "${trgt_raw:-${trgt}}")"
    ntotal="$(grep -c '' <<< "${index}")"

    if [ "${KIND}" = word ]; then
        ORIG="${trgt}"
        keys_str="[Enter] $(gettext "play") · [Space/n] $(gettext "next") · [p] $(gettext "prev") · [m] $(gettext "Mark") · [e] $(gettext "edit") · [q] $(gettext "quit")"
        build_grid
    else
        ORIG="${trgt}"
        if [ "$(sqlite3 "${cfgdb}" "select gramr from opts;" 2>/dev/null)" = TRUE ]; then
            ORIG="${grmr}"
        fi

        # ---- Vista de lista de palabras (tecla l): cada pareja en una
        # línea, con pie fijo y paginación horizontal por bloques.
        if [ "${VIEW}" = list ]; then
            keys_str="[Enter] $(gettext "play word") · [j/k] $(gettext "select") · [r] $(gettext "play sentence") · [l] $(gettext "sentence") · [w] $(gettext "Edit") · [Space/n] $(gettext "next") · [p] $(gettext "prev") · [m] $(gettext "Mark") · [e] $(gettext "edit") · [q] $(gettext "quit")"
            mapfile -t KL < <(fold -s -w "${FW}" <<< "${keys_str}")
            while [ ${#KL[@]} -lt 2 ]; do KL+=(""); done
            footer_n=$(( 1 + ${#KL[@]} + 1 ))
            avail=$((ROWS - footer_n - 1))
            [ "${avail}" -lt 1 ] && avail=1
            local vis hdr lidx first last b r row line start end maxh
            vis=$((avail - 1))
            [ "${vis}" -lt 1 ] && vis=1
            LW=$((COLS - 2 * MARG))
            build_list
            scroll_into_view
            maxh=$(( LIST_NBLOCKS - LIST_NFIT )); [ "${maxh}" -lt 0 ] && maxh=0
            [ "${HSCROLL:-0}" -gt "${maxh}" ] && HSCROLL=${maxh}
            [ "${HSCROLL:-0}" -lt 0 ] && HSCROLL=0
            first=${HSCROLL:-0}
            last=$(( first + LIST_NFIT - 1 ))
            [ "${last}" -ge "${LIST_NBLOCKS}" ] && last=$(( LIST_NBLOCKS - 1 ))
            printf '\033[2J\033[H'
            print_header
            printf '\n'
            for (( lidx=0; lidx<vis; lidx++ )); do
                line=""
                for (( b=first; b<=last; b++ )); do
                    start=${LIST_BSTART[$b]}
                    end=${LIST_BEND[$b]}
                    if [ "${lidx}" -le $(( end - start )) ]; then
                        row="${LIST_LINES[$(( start + lidx ))]}"
                    else
                        row="$(printf '%*s' "${LIST_CELLW}" '')"
                    fi
                    [ -n "${line}" ] && line+="    "
                    line+="${row}"
                done
                printf '%*s%s\n' "${MARG}" "" "${line}"
            done
            printf -v SEP '%*s' "${FW}" ''
            SEP="${SEP// /─}"
            emitc "${E}[2;90m${SEP}${E}[0m"
            for l in "${KL[@]}"; do
                emitc "${E}[2;90m${l}${E}[0m"
            done
            return
        fi

        build_grid
        if [ ${#GRID[@]} -gt 0 ]; then
            keys_str="[Enter] $(gettext "play word") · [j/k] $(gettext "select") · [r] $(gettext "play sentence") · [l] $(gettext "Words") · [w] $(gettext "Edit") · [Space/n] $(gettext "next") · [p] $(gettext "prev") · [m] $(gettext "Mark") · [e] $(gettext "edit") · [q] $(gettext "quit")"
        else
            keys_str="[Enter] $(gettext "play sentence") · [Space/n] $(gettext "next") · [p] $(gettext "prev") · [m] $(gettext "Mark") · [e] $(gettext "edit") · [w] $(gettext "Edit") · [q] $(gettext "quit")"
        fi
    fi

    # La primera línea contiene solo el contador actual/total, a la izquierda.
    header="[${POS}/${ntotal}]"
    mapfile -t KL < <(fold -s -w "${FW}" <<< "${keys_str}")
    while [ ${#KL[@]} -lt 2 ]; do KL+=(""); done
    footer_n=$(( 1 + ${#KL[@]} + 1 ))
    avail=$((ROWS - footer_n - 1))
    [ ${avail} -lt 1 ] && avail=1

    # Altura del bloque principal sin ejemplo. El gap se decide solo con el
    # espacio disponible y el propio bloque, nunca con la zona de ejemplo.
    gap=1
    build_main 1
    core_n=${#MA[@]}
    if [ $((avail - core_n)) -ge 10 ]; then
        gap=2
        build_main 2
        core_n=${#MA[@]}
    fi

    # Misma referencia vertical para palabra y oración: el bloque principal
    # de Word debe empezar en la misma fila que el de Sentence. La posición
    # sigue sin depender de que exista ejemplo ni de cuántas líneas ocupe.
    slot=6
    [ ${core_n} -gt ${slot} ] && slot=${core_n}
    spare=$((avail - slot))
    if [ ${spare} -gt 0 ]; then
        pad_top=$((spare / 2 - 3)); [ ${pad_top} -lt 0 ] && pad_top=0
    else
        pad_top=0
    fi

    # En terminales extremadamente pequeñas se recorta el bloque principal
    # para que el pie nunca se superponga.
    if [ ${core_n} -gt $((avail - pad_top)) ]; then
        local -a CORE_FIT=("${MA[@]:0:$((avail - pad_top))}")
        MA=("${CORE_FIT[@]}")
        core_n=${#MA[@]}
    fi
    pad_bot=$((avail - core_n - pad_top)); [ ${pad_bot} -lt 0 ] && pad_bot=0

    # El ejemplo ocupa la zona libre bajo el bloque principal. Si no cabe,
    # se recorta aquí; nunca mueve el bloque principal ni el pie.
    build_details "${gap}"
    if [ ${#DET[@]} -gt ${pad_bot} ]; then
        local -a DET_FIT=("${DET[@]:0:${pad_bot}}")
        DET=("${DET_FIT[@]}")
    fi

    printf '\033[2J\033[H'
    print_header
    for (( i=0; i<pad_top; i++ )); do printf '\n'; done
    for l in "${MA[@]}"; do
        if [ "${l}" = "@@TABLE@@" ]; then
            # La tabla de pares se alinea a la izquierda del área de contenido.
            for gl in "${GRID[@]}"; do
                printf '%*s%s\n' "${MARG}" "" "${gl}"
            done
        elif [[ "${l}" = ¦* ]]; then
            # Línea de bloque ya posicionada con su margen izquierdo.
            printf '%s\n' "${l#¦}"
        elif [ -n "${l}" ]; then
            emitc "${l}"
        else
            printf '\n'
        fi
    done
    for l in "${DET[@]}"; do
        if [ -n "${l}" ]; then
            emitc "${l}"
        else
            printf '\n'
        fi
    done
    for (( i=${#DET[@]}; i<pad_bot; i++ )); do printf '\n'; done
    printf -v SEP '%*s' "${FW}" ''
    SEP="${SEP// /─}"
    emitc "${E}[2;90m${SEP}${E}[0m"
    for l in "${KL[@]}"; do
        emitc "${E}[2;90m${l}${E}[0m"
    done
}

# Ajusta HSCROLL para que la palabra SEL quede visible en la vista de lista.
scroll_into_view() {
    [ "${VIEW}" = list ] && [ "${KIND}" = sentence ] || return 0
    local b="${LIST_BLOCK[$SEL]:-0}"
    if [ "${b}" -lt "${HSCROLL:-0}" ]; then
        HSCROLL=${b}
    fi
    if [ "${b}" -ge $(( ${HSCROLL:-0} + ${LIST_NFIT:-1} )) ]; then
        HSCROLL=$(( b - ${LIST_NFIT:-1} + 1 ))
        [ "${HSCROLL}" -lt 0 ] && HSCROLL=0
    fi
    return 0
}

while :; do
    vwr_resolve "${LIST}" "" "${POS}" 2>/dev/null
    POS="${index_pos}"
    KIND="${vwr_kind}"
    [ "${KIND}" = sentence ] && [ -z "${wrds:-}" ] && VIEW=sentence
    TARGETS=(); TRANSLATIONS=()
    while IFS= read -r w; do
        [ -n "${w}" ] || continue
        IFS= read -r t || t=""
        TARGETS+=("${w}")
        TRANSLATIONS+=("${t}")
    done <<< "$(tr '_' '\n' <<< "${wrds:-}")"
    if [ "${SEL}" -ge "${#TARGETS[@]}" ] 2>/dev/null; then
        SEL=0
    fi
    render
    key=""
    if ! IFS= read -rsn1 key < /dev/tty; then
        key="q"
    fi
    case "${key}" in
        q|Q)
            vwr_result close ;;
        $'\e')
            c1=""; c2=""
            if IFS= read -rsn1 -t 0.1 c1 < /dev/tty; then
                if [ "${c1}" = "[" ]; then
                    IFS= read -rsn1 -t 0.1 c2 < /dev/tty
                    case "${c2}" in
                        A) [ "${SEL}" -gt 0 ] && { SEL=$((SEL-1)); scroll_into_view; } ;;
                        B) [ -n "${TARGETS[$((SEL+1))]:-}" ] && { SEL=$((SEL+1)); scroll_into_view; } ;;
                    esac
                fi
            else
                vwr_result close
            fi ;;
        n|N)
            POS=$((POS+1)); SEL=0; SCROLL=0; HSCROLL=0 ;;
        ' ')
            # Barra espaciadora: mismo efecto que avanzar (n).
            POS=$((POS+1)); SEL=0; SCROLL=0; HSCROLL=0 ;;
        r|R)
            play_cmd "${cmd_listen}" ;;
        p|P)
            if [ "${POS}" -gt 1 ]; then
                POS=$((POS-1)); SEL=0; SCROLL=0; HSCROLL=0
            fi ;;
        l|L)
            # Alterna vista de oración <-> lista de palabras (solo oraciones
            # con palabras; l no tiene otra función en este contexto).
            if [ "${KIND}" = sentence ] && [ -n "${wrds:-}" ]; then
                if [ "${VIEW}" = sentence ]; then
                    VIEW=list; HSCROLL=0
                else
                    VIEW=sentence
                fi
            fi ;;
        e|E)
            vwr_result edit ;;
        w|W)
            [ "${KIND}" = sentence ] && vwr_result words ;;
        m|M)
            # Marcar/desmarcar la nota actual con el toggle compartido del
            # diálogo de edición (cmns::toggle_note_mark). El siguiente
            # ciclo re-resuelve y repinta con el asterisco/negrita.
            [ -n "${trgt_raw:-}" ] && toggle_note_mark "${trgt_raw}" >/dev/null 2>&1 ;;
        j|J)
            if [ -n "${TARGETS[$((SEL+1))]:-}" ]; then
                SEL=$((SEL+1)); scroll_into_view
            fi ;;
        k|K)
            if [ "${SEL}" -gt 0 ]; then
                SEL=$((SEL-1)); scroll_into_view
            fi ;;
        $'\n'|$'\r'|'')
            if [ "${VIEW}" = list ] && [ "${KIND}" = sentence ]; then
                target="${LIST_TARGET[$SEL]:-}"
                [ -n "${target}" ] && play_cmd "$DS/play.sh play_word \"${target}\""
            elif [ "${KIND}" = sentence ] && [ -n "${TARGETS[$SEL]:-}" ]; then
                play_cmd "$DS/play.sh play_word \"${TARGETS[$SEL]}\""
            else
                play_cmd "${cmd_listen}"
            fi ;;
    esac
done
