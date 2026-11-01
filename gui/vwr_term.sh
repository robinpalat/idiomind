#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Módulo del visor principal de palabras y oraciones (migración a terminal).
#
# - vwr_resolve:        identidad y datos del elemento. Movida sin cambios de
#                       gui/topic.sh::vwr (posición de fila en la tabla
#                       learning/learnt + primer registro exacto por trgt{}).
# - vwr_term_view:      presentación en terminal; devuelve los mismos códigos
#                       que devolvían word_view/sentence_view (0 cerrar,
#                       2 siguiente, 4 editar) más 3 anterior y 5 palabras.
# - vwr_term_open:      apertura explícita de terminal; si falla informa con
#                       un diálogo general y retorna 1 (sin visor antiguo).
# - vwr_do_edit / vwr_spawn / vwr_words_edit: costuras de las acciones
#                       existentes de vwr() (editar, siguiente/anterior, palabras).

if [ -n "${__GUI_VWR_TERM_SH:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
__GUI_VWR_TERM_SH=1

# $1 = lista (1 learning | 2 learnt), $2 = nombre seleccionado,
# $3 = posición de fila (columna oculta @fore@ que yad adjunta al doble clic).
vwr_resolve() {

    if [ ${1} = 1 ]; then
        index="$(tpc_db 5 learning)"
        item_name="$(sed 's/<[^>]*>//g' <<< "${2}")"
    elif [ ${1} = 2 ]; then
        index="$(tpc_db 5 learnt)"
        item_name="$(sed 's/<[^>]*>//g' <<< "${2}")"
    fi
    re='^[0-9]+$'; index_pos="${3}"

    if ! [[ ${index_pos} =~ $re ]]; then
        index_pos="grep -Fxon -m 1 \"${item_name}\" <<< \"${index}\" |sed -n 's/^\([0-9]*\)[:].*/\1/p'"
        if ! [[ ${index_pos} =~ $re ]]; then
            index_pos="$(awk 'match($0,v){print NR; exit}' v="${item_name}" <<< "${index}")"
        fi
        nll=""
    fi
    _item="$(sed -n ${index_pos}p <<< "${index}")"
    if [ -z "${_item}" ]; then
        _item="$(sed -n 1p <<< "${index}")"; export index_pos=1
    fi
    item="$(grep -F -m 1 "trgt{${_item}}" "$DC_tlt/data" |sed 's/}/}\n/g')"
    type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
    export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
    export srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
    export exmp="$(grep -oP '(?<=exmp{).*(?=})' <<< "${item}" |sed -e 's/^ *//' -e 's/ *$//')"
    export defn="$(grep -oP '(?<=defn{).*(?=})' <<< "${item}")"
    export note="$(grep -oP '(?<=note{).*(?=})' <<< "${item}")"
    export grmr="$(grep -oP '(?<=grmr{).*(?=})' <<< "${item}")"
    export mark="$(grep -oP '(?<=mark{).*(?=})' <<< "${item}")"
    export link="$(grep -oP '(?<=link{).*(?=})' <<< "${item}")"
    export tags="$(grep -oP '(?<=tags{).*(?=})' <<< "${item}")"
    export wrds="$(grep -oP '(?<=wrds{).*(?=})' <<< "${item}")"
    export cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
    export trgt_raw="${trgt}"
    text_missing=0

    if [ ${type} = 1 ]; then
        export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
        [ "$mark" = TRUE ] && grmr="<b>$grmr</b>"
        vwr_kind=word
    elif [ ${type} = 2 ]; then
        export cmd_listen="$DS/play.sh play_sentence ${cdid}"
        [ "$mark" = TRUE ] && grmr="<b>$grmr</b>"
        vwr_kind=sentence
    else
        trgt="${_item} <small>[Text missing]</small>"
        grmr="${trgt}"
        if [[ $(wc -w <<< "${_item}") -lt 2 ]]; then
            export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
            text_missing=1
            vwr_kind=word
        else
            export cmd_listen="$DS/play.sh play_sentence ${cdid}"
            text_missing=2
            vwr_kind=sentence
        fi
    fi
}

# Presenta el elemento en una terminal y espera la acción elegida.
vwr_term_view() {
    local ctx="$DT/vwr.$$.ctx" action f u
    rm -f "${ctx}" "${ctx}.res" "${ctx}.play"
    {
        printf 'VWR_LIST=%q\n' "${1}"
        printf 'VWR_POS=%q\n' "${index_pos}"
        printf 'VWR_KIND=%q\n' "${vwr_kind}"
        printf 'VWR_TPC=%q\n' "${tpc}"
        printf 'VWR_TPCDB=%q\n' "${tpcdb}"
        printf 'VWR_DC_TLT=%q\n' "${DC_tlt}"
        printf 'VWR_TEXT_MISSING=%q\n' "${text_missing}"
        printf 'VWR_ITEM=%q\n' "${_item}"
        for f in trgt srce exmp defn note grmr mark link tags wrds cdid cmd_listen; do
            u="$(printf '%s' "${f}" | tr '[:lower:]' '[:upper:]')"
            printf 'VWR_%s=%q\n' "${u}" "${!f}"
        done
    } > "${ctx}" || return 1

    if ! vwr_term_open "${ctx}"; then
        rm -f "${ctx}"
        yad --title="Idiomind" --class=Idiomind --name=Idiomind \
        --text="$(gettext "Could not open a terminal to view the note.")\n" \
        --window-icon=$DS/images/logo.png --center --on-top --fixed \
        --width=420 --borders=12 \
        --button="$(gettext "Close")":0 >/dev/null 2>&1
        return 1
    fi
    while [ ! -f "${ctx}.res" ]; do sleep 0.5; done
    action="$(head -n1 "${ctx}.res" 2>/dev/null)"
    rm -f "${ctx}" "${ctx}.res" "${ctx}.play"
    case "${action}" in
        edit)  return 4 ;;
        next)  return 2 ;;
        prev)  return 3 ;;
        words) return 5 ;;
        *)     return 0 ;;
    esac
}

# Apertura explícita de terminal. Sin fallback al visor YAD antiguo.
vwr_term_open() {
    local ctx="$1" term rc
    for term in gnome-terminal xfce4-terminal konsole tilix terminator \
                lxterminal alacritty kitty foot st xterm; do
        command -v "${term}" >/dev/null 2>&1 || continue
        case "${term}" in
            gnome-terminal)
                "${term}" --title="Idiomind" -- \
                    bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
            xfce4-terminal)
                "${term}" --title="Idiomind" -x \
                    bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
            konsole|tilix)
                "${term}" --title "Idiomind" -e \
                    bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
            lxterminal|terminator)
                "${term}" -e "bash \"$DS/gui/vwr_ui.sh\" \"$ctx\"" >/dev/null 2>&1 ;;
            alacritty|kitty|foot)
                "${term}" -e bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
            st)
                "${term}" -t "Idiomind" -e bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
            xterm)
                "${term}" -T "Idiomind" -e bash "$DS/gui/vwr_ui.sh" "${ctx}" >/dev/null 2>&1 ;;
        esac
        rc=$?
        [ ${rc} -eq 0 ] && return 0
    done
    return 1
}

vwr_do_edit() { "$DS/mngr.sh" edit "$@"; }
vwr_spawn() { "$DS/vwr.sh" "$@"; }
vwr_words_edit() { "$DS/add.sh" list_words_edit "$@"; }
