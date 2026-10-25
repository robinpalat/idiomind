#!/bin/bash
# -*- ENCODING: UTF-8 -*-

tp_event=""
tp_space=0
TP_BTN=""
tp_phase=""
tp_pid=""
tp_exercise_ended="quit"

function _tp_plain() {
    sed -e 's/<[^>]*>//g' -e 's/\\n/\n/g' <<< "${1}"
}

TP_B=$'\033[1m'
TP_I=$'\033[3m'
TP_D=$'\033[2;90m'
TP_RST=$'\033[0m'

function _tp_cols() {
    local c
    c="$(stty size < /dev/tty 2>/dev/null | awk '{print $2}')"
    if [ -z "${c}" ] || [ "${c}" -lt 20 ] 2>/dev/null; then
        c=80
    fi
    printf '%s' "${c}"
}

function _tp_rows() {
    local r
    r="$(stty size < /dev/tty 2>/dev/null | awk '{print $1}')"
    if [ -z "${r}" ] || [ "${r}" -lt 8 ] 2>/dev/null; then
        r=24
    fi
    printf '%s' "${r}"
}

function _tp_vlen() {
    local t="${1}"
    t="$(sed $'s/\033\\[[0-9;?]*[A-Za-z]//g' <<< "${t}")"
    printf '%s' "${#t}"
}

function _tp_vcount() {
    local w="${1}" lv
    lv="$(_tp_vlen "${2}")"
    if [ "${lv}" -le "${w}" ]; then
        printf '1'
    else
        printf '%s' $(( (lv + w - 1) / w ))
    fi
}

function _tp_trim() {
    local t="${1}"
    t="${t#"${t%%[![:space:]]*}"}"
    t="${t%"${t##*[![:space:]]}"}"
    printf '%s' "${t}"
}

function _tp_step_attr() {
    case "${step:-1}" in
        2) printf '%s' $'\033[1;33m' ;;
        3) printf '%s' $'\033[1;91m' ;;
        *) printf '%s' $'\033[1m' ;;
    esac
}

function _tp_wrap() {
    local w="${1}" text="${2}" line cur lw word rest
    local -a words split
    while IFS= read -r line || [ -n "${line}" ]; do
        read -ra words <<< "${line}"
        split=()
        for word in "${words[@]}"; do
            lw="$(_tp_vlen "${word}")"
            if [ "${lw}" -gt "${w}" ]; then
                case "${word}" in
                    *$'\033'*)
                        split+=("${word}") ;;
                    *)
                        rest="${word}"
                        while [ "$(_tp_vlen "${rest}")" -gt "${w}" ]; do
                            split+=("${rest:0:w}")
                            rest="${rest:w}"
                        done
                        split+=("${rest}") ;;
                esac
            else
                split+=("${word}")
            fi
        done
        words=("${split[@]}")
        cur=""
        for word in "${words[@]}"; do
            lw="$(_tp_vlen "${word}")"
            if [ -z "${cur}" ]; then
                cur="${word}"
            elif [ "$(( $(_tp_vlen "${cur}") + 1 + lw ))" -le "${w}" ]; then
                cur="${cur} ${word}"
            else
                printf '%s\n' "${cur}"
                cur="${word}"
            fi
        done
        if [ -n "${cur}" ]; then
            printf '%s\n' "${cur}"
        elif [ ${#words[@]} -eq 0 ]; then
            printf '\n'
        fi
    done <<< "${text}"
}

function _tp_center() {
    local w="${1}" pre="${2}" post="${3}" text line lw pad
    text="$(_tp_trim "${4}")"
    [ -z "${text}" ] && return 0
    while IFS= read -r line; do
        lw="$(_tp_vlen "${line}")"
        if [ "${lw}" -lt "${w}" ]; then
            pad=$(( (w - lw) / 2 ))
        else
            pad=0
        fi
        printf '%*s%s%s%s\n' "${pad}" "" "${pre}" "${line}" "${post}"
    done < <(_tp_wrap $((w - 4)) "${text}")
}

function _tp_bold_keys() {
    local s="${1}" out="" key
    while [[ "${s}" =~ (\[[^][]*\]) ]]; do
        key="${BASH_REMATCH[1]}"
        out="${out}${s%%"${key}"*}${TP_B}${key}${TP_D}"
        s="${s#*"${key}"}"
    done
    out="${out}${s}"
    printf '%s' "${out}"
}

TP_FOOTER=()
TP_START=1

TP_FSEGS=()

function _tp_footer_reset() {
    TP_FOOTER=()
    TP_FSEGS=()
}

function _tp_footer_add() {
    local w="${1}" seg
    shift
    for seg in "$@"; do
        if [ "${w}" -lt 70 ]; then
            case "${seg}" in
                *mouse*) continue ;;
            esac
        fi
        TP_FSEGS+=("${seg}")
    done
    _tp_footer_fit "${w}"
    return 0
}

function _tp_footer_fit() {
    local w="${1}" seg line i n total half acc k v1 v2 l1 l2
    n=${#TP_FSEGS[@]}
    if [ ${n} -ge 2 ]; then
        total=0
        for seg in "${TP_FSEGS[@]}"; do
            total=$((total + ${#seg}))
        done
        total=$((total + 3 * (n - 1)))
        half=$(( (total + 1) / 2 ))
        acc="${#TP_FSEGS[0]}"
        k=0
        for (( i=1; i<n; i++ )); do
            if [ $((acc + 3 + ${#TP_FSEGS[i]})) -gt ${half} ]; then
                k=${i}
                break
            fi
            acc=$((acc + 3 + ${#TP_FSEGS[i]}))
        done
        if [ ${k} -eq 0 ]; then
            k=$((n - 1))
        fi
        line=""
        for (( i=0; i<k; i++ )); do
            if [ -z "${line}" ]; then
                line="${TP_FSEGS[i]}"
            else
                line="${line} · ${TP_FSEGS[i]}"
            fi
        done
        v1="$(_tp_vlen "${line}")"
        l1="$(_tp_bold_keys "${line}")"
        line=""
        for (( i=k; i<n; i++ )); do
            if [ -z "${line}" ]; then
                line="${TP_FSEGS[i]}"
            else
                line="${line} · ${TP_FSEGS[i]}"
            fi
        done
        v2="$(_tp_vlen "${line}")"
        l2="$(_tp_bold_keys "${line}")"
        if [ ${v1} -le ${w} ] && [ ${v2} -le ${w} ]; then
            TP_FOOTER=("${l1}" "${l2}")
            return 0
        fi
    fi
    local -a segs lines
    while :; do
        segs=("${TP_FSEGS[@]}")
        lines=()
        line=""
        for seg in "${segs[@]}"; do
            if [ -z "${line}" ]; then
                line="${seg}"
            elif [ $(( 2 + ${#line} + 3 + ${#seg} )) -le "${w}" ]; then
                line="${line} · ${seg}"
            else
                lines+=("$(_tp_bold_keys "${line}")")
                line="${seg}"
            fi
        done
        [ -n "${line}" ] && lines+=("$(_tp_bold_keys "${line}")")
        if [ ${#lines[@]} -le 2 ] || [ ${#TP_FSEGS[@]} -eq 0 ]; then
            break
        fi
        TP_FSEGS=("${TP_FSEGS[@]:0:${#TP_FSEGS[@]}-1}")
    done
    TP_FOOTER=("${lines[@]}")
    while [ ${#TP_FOOTER[@]} -lt 2 ]; do
        TP_FOOTER+=("")
    done
    if [ ${#TP_FOOTER[@]} -gt 2 ]; then
        TP_FOOTER=("${TP_FOOTER[0]}" "${TP_FOOTER[1]}")
    fi
    return 0
}

function _tp_vcenter_top() {
    local rows="${1}" n="${2}" bar="${3}" zone top z
    TP_START=1
    zone=$((rows - bar))
    [ ${zone} -lt 1 ] && zone=1
    if [ ${zone} -ge ${n} ]; then
        top=$(( (zone - n) / 2 ))
    else
        top=0
    fi
    TP_START=$((top + 1))
    printf '\033[2J\033[H'
    for (( z=0; z<top; z++ )); do
        printf '\n'
    done
}

function _tp_progress_draw() {
    local w total green red g r gray i
    w="$(_tp_cols)"
    total=0
    if [ -n "${active_practice:-}" ] && [ -f "./${active_practice}.tmp" ]; then
        total="$(grep -Ecv '#|^$' "./${active_practice}.tmp" 2>/dev/null)"
    fi
    case "${total}" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "${total}" -le 0 ] && return 1
    green=$(( ${count_easy:-0} + ${count_learn:-0} ))
    red="${count_hard:-0}"
    case "${red}" in
        ''|*[!0-9]*) return 1 ;;
    esac
    if [ $((green + red)) -gt "${total}" ]; then
        return 1
    fi
    g=$(( green * w / total ))
    r=$(( red * w / total ))
    gray=$(( w - g - r ))
    [ ${gray} -lt 0 ] && gray=0
    for (( i=0; i<g; i++ )); do
        printf '\033[2;32m█'
    done
    for (( i=0; i<r; i++ )); do
        printf '\033[2;31m█'
    done
    if [ ${gray} -gt 0 ]; then
        printf '\033[2;90m'
        for (( i=0; i<gray; i++ )); do
            printf '█'
        done
    fi
    printf '\033[0m'
    return 0
}

function _tp_status_bar() {
    local rows="${1}" start="${2}" n="${3}" barl cur target seg
    barl=${#TP_FOOTER[@]}
    [ ${barl} -eq 0 ] && return 0
    cur=$((start + n))
    target=$((rows - barl + 1))
    if [ ${target} -gt ${cur} ] && [ ${target} -ge 2 ]; then
        printf '\033[%d;1H' "$((target - 1))"
        _tp_progress_draw
        printf '\033[%d;1H' "${target}"
    elif [ ${target} -gt ${cur} ]; then
        printf '\033[%d;1H' "${target}"
    else
        if _tp_progress_draw; then
            printf '\n'
        fi
    fi
    for seg in "${TP_FOOTER[@]}"; do
        barl=$((barl - 1))
        if [ ${barl} -gt 0 ]; then
            printf '  %s%s%s\n' "${TP_D}" "${seg}" "${TP_RST}"
        else
            printf '  %s%s%s' "${TP_D}" "${seg}" "${TP_RST}"
        fi
    done
    return 0
}

function _tp_card_help() {
    local w="${1}" rows="${2}" wl="${3}" wr="${4}" row lv_l lv_r colr
    row=$((rows - 3))
    if [ ${row} -lt 1 ]; then
        return 0
    fi
    lv_l="$(_tp_vlen "${wl}")"
    lv_r="$(_tp_vlen "${wr}")"
    printf '\033[%d;1H%s%s' "${row}" "${TP_D}" "${wl}"
    if [ $((lv_l + lv_r + 1)) -le "${w}" ]; then
        printf '%*s%s%s' "$((w - lv_l - lv_r))" "" "${wr}" "${TP_RST}"
    else
        colr=$((w - lv_r + 1))
        [ ${colr} -lt 1 ] && colr=1
        printf '%s\033[%d;%dH%s%s' "${TP_RST}" "${row}" "${colr}" "${wr}" "${TP_RST}"
    fi
    return 0
}

function _tp_card_help_center() {
    local w="${1}" rows="${2}" txt="${3}" row lv pad
    row=$((rows - 3))
    if [ ${row} -lt 1 ]; then
        return 0
    fi
    lv="$(_tp_vlen "${txt}")"
    if [ "${lv}" -lt "${w}" ]; then
        pad=$(( (w - lv) / 2 ))
    else
        pad=0
    fi
    printf '\033[%d;1H' "${row}"
    printf '%*s%s%s%s' "${pad}" "" "${TP_D}" "${txt}" "${TP_RST}"
    return 0
}

function _tp_mouse_button() {
    local _seq _b
    TP_BTN=""
    _seq="${1#mouse:<}"
    case "${_seq}" in
        *m) return 1 ;;
    esac
    _b="${_seq%%;*}"
    case "${_b}" in
        0) TP_BTN="left" ;;
        1) TP_BTN="middle" ;;
        2) TP_BTN="right" ;;
        *) return 1 ;;
    esac
    return 0
}

function _tp_read_event() {
    local k ch seq
    tp_event=""
    if ! IFS= read -rsn1 k < /dev/tty; then
        tp_event="eof"
        return 1
    fi
    case "$k" in
        $'\n'|$'\r'|'') tp_event="enter"; tp_space=0 ;;
        ' ') tp_event="enter"; tp_space=1 ;;
        'q'|'Q') tp_event="q" ;;
        's'|'S') tp_event="s" ;;
        'n'|'N') tp_event="n" ;;
        'y'|'Y') tp_event="y" ;;
        'm'|'M') tp_event="m" ;;
        'r'|'R') tp_event="r" ;;
        $'\033')
            if IFS= read -rsn1 -t 0.1 ch < /dev/tty; then
                if [ "$ch" = "[" ] || [ "$ch" = "O" ]; then
                    seq=""
                    while IFS= read -rsn1 -t 0.1 ch < /dev/tty; do
                        seq="${seq}${ch}"
                        case "$ch" in
                            M|m|[A-Za-z~]) break ;;
                        esac
                    done
                    case "$seq" in
                        '<'*) tp_event="mouse:${seq}" ;;
                        A) tp_event="up" ;;
                        B) tp_event="down" ;;
                        *) tp_event="other" ;;
                    esac
                else
                    tp_event="other"
                fi
            else
                tp_event="esc"
            fi ;;
        [1-9]) tp_event="num${k}" ;;
        *) tp_event="other" ;;
    esac
    return 0
}

function ui_card_question() {
    local _txt _w _rows n n1 n2 gap zone barl _t2
    local -a ql tl
    _txt="$(_tp_plain "${1}")"
    _w="$(_tp_cols)"
    _rows="$(_tp_rows)"
    mapfile -t ql < <(_tp_wrap $((_w - 4)) "$(_tp_trim "${_txt}")")
    [ ${#ql[@]} -eq 0 ] && ql=("")
    n1=${#ql[@]}
    _t2="$(_tp_plain "${answer2:-}")"
    mapfile -t tl < <(_tp_wrap $((_w - 4)) "$(_tp_trim "${_t2}")")
    [ ${#tl[@]} -eq 0 ] && tl=("")
    n2=${#tl[@]}
    _tp_footer_reset
    _tp_footer_add "${_w}" "[Enter] show the answer" "[q] quit" \
        "mouse: left = show"
    barl=${#TP_FOOTER[@]}
    zone=$((_rows - barl))
    [ ${zone} -lt 1 ] && zone=1
    if [ $((zone - n1 - n2)) -ge 6 ]; then
        gap=3
    elif [ $((zone - n1 - n2)) -ge 3 ]; then
        gap=2
    else
        gap=1
    fi
    n=$((n1 + gap + n2))
    _tp_vcenter_top "${_rows}" "${n}" "${barl}"
    _tp_center "${_w}" "$(_tp_step_attr)" "${TP_RST}" "${_txt}"
    _tp_card_help_center "${_w}" "${_rows}" \
        "$(gettext "Mostrar respuesta: Espacio o clic izquierdo")"
    _tp_status_bar "${_rows}" "${TP_START}" "${n}"
    while :; do
        _tp_read_event || return 1
        case "${tp_event}" in
            enter) return 0 ;;
            q|esc|eof) return 1 ;;
            mouse:*)
                _tp_mouse_button "${tp_event}" || continue
                case "${TP_BTN}" in
                    left) return 0 ;;
                esac ;;
        esac
    done
}

function ui_card_answer() {
    local _t1 _t2 _w _rows n1 n2 gap zone barl i
    local -a l1 l2
    _t1="$(_tp_plain "${1}")"
    _t2="$(_tp_plain "${2}")"
    _w="$(_tp_cols)"
    _rows="$(_tp_rows)"
    mapfile -t l1 < <(_tp_wrap $((_w - 4)) "$(_tp_trim "${_t1}")")
    mapfile -t l2 < <(_tp_wrap $((_w - 4)) "$(_tp_trim "${_t2}")")
    [ ${#l1[@]} -eq 0 ] && l1=("")
    [ ${#l2[@]} -eq 0 ] && l2=("")
    n1=${#l1[@]}
    n2=${#l2[@]}
    _tp_footer_reset
    _tp_footer_add "${_w}" "[s] I knew it" "[n] I did not know it" \
        "mouse: left = knew, right = did not know"
    barl=${#TP_FOOTER[@]}
    zone=$((_rows - barl))
    [ ${zone} -lt 1 ] && zone=1
    if [ $((zone - n1 - n2)) -ge 6 ]; then
        gap=3
    elif [ $((zone - n1 - n2)) -ge 3 ]; then
        gap=2
    else
        gap=1
    fi
    n=$((n1 + gap + n2))
    _tp_vcenter_top "${_rows}" "${n}" "${barl}"
    _tp_center "${_w}" "$(_tp_step_attr)" "${TP_RST}" "${_t1}"
    for (( i=0; i<gap; i++ )); do
        printf '\n'
    done
    _tp_center "${_w}" "${TP_I}" "${TP_RST}" "${_t2}"
    _tp_card_help "${_w}" "${_rows}" \
        "$(gettext "Clic izquierdo: conozco la palabra")" \
        "$(gettext "Clic derecho: no conozco la palabra")"
    _tp_status_bar "${_rows}" "${TP_START}" "${n}"
    while :; do
        _tp_read_event || return 1
        case "${tp_event}" in
            s) return 2 ;;
            n|enter) return 3 ;;
            q|esc|eof) return 1 ;;
            mouse:*)
                _tp_mouse_button "${tp_event}" || continue
                case "${TP_BTN}" in
                    left) return 2 ;;
                    right) return 3 ;;
                esac ;;
        esac
    done
}

function ui_select_list() {
    local q col i idx w ww y acc st seg marker li q_lines rows gap zone sum line used
    local avail n r ry startx run x cw addw rstart found
    local -a arr ql wl row_sc row_ec row_used row_rl cell_cx cell_cw row_x
    q="$(_tp_trim "$(_tp_plain "${1}")")"
    arr=()
    while IFS= read -r line; do
        [ -n "${line}" ] && arr+=("${line}")
    done <<< "${2}"
    [ ${#arr[@]} -eq 0 ] && return 1
    col=1
    w="$(_tp_cols)"
    rows="$(_tp_rows)"
    ww=$((w - 4))
    [ ${ww} -lt 10 ] && ww=10
    mapfile -t ql < <(_tp_wrap "${ww}" "${q}")
    [ ${#ql[@]} -eq 0 ] && ql=("")
    q_lines=${#ql[@]}
    avail=$((w - 4))
    [ ${avail} -lt 10 ] && avail=10
    row_sc=()
    row_ec=()
    row_used=()
    row_rl=()
    row_x=()
    cell_cx=()
    cell_cw=()
    rstart=-1
    used=0
    for (( i=0; i<${#arr[@]}; i++ )); do
        cw=$((5 + $(_tp_vlen "${arr[i]}")))
        if [ ${cw} -gt ${avail} ]; then
            if [ ${rstart} -ge 0 ]; then
                row_sc+=("${rstart}")
                row_ec+=("$((i - 1))")
                row_used+=("${used}")
                row_rl+=(1)
                rstart=-1
                used=0
            fi
            mapfile -t wl < <(_tp_wrap $((avail - 5)) "${arr[i]}")
            [ ${#wl[@]} -eq 0 ] && wl=("${arr[i]}")
            row_sc+=("${i}")
            row_ec+=("${i}")
            row_used+=("${cw}")
            row_rl+=("${#wl[@]}")
        else
            addw=${cw}
            [ ${rstart} -ge 0 ] && addw=$((cw + 2))
            if [ ${rstart} -ge 0 ] && [ $((used + addw)) -gt ${avail} ]; then
                row_sc+=("${rstart}")
                row_ec+=("$((i - 1))")
                row_used+=("${used}")
                row_rl+=(1)
                rstart=${i}
                used=${cw}
            elif [ ${rstart} -lt 0 ]; then
                rstart=${i}
                used=${cw}
            else
                used=$((used + addw))
            fi
        fi
    done
    if [ ${rstart} -ge 0 ]; then
        row_sc+=("${rstart}")
        row_ec+=("$(( ${#arr[@]} - 1 ))")
        row_used+=("${used}")
        row_rl+=(1)
    fi
    for (( r=0; r<${#row_sc[@]}; r++ )); do
        startx=$(( (w - row_used[r]) / 2 + 1 ))
        [ ${startx} -lt 2 ] && startx=2
        row_x+=("${startx}")
        run=0
        for (( i=row_sc[r]; i<=row_ec[r]; i++ )); do
            cell_cx[i]=$((startx + run))
            cell_cw[i]=$((5 + $(_tp_vlen "${arr[i]}")))
            run=$((run + cell_cw[i] + 2))
        done
    done
    sum=0
    for (( r=0; r<${#row_sc[@]}; r++ )); do
        sum=$((sum + row_rl[r]))
    done
    _tp_footer_reset
    _tp_footer_add "${w}" "[Up/Down] move" "[Enter] choose" \
        "[1-9] direct choice" "[q] quit"
    zone=$((rows - ${#TP_FOOTER[@]}))
    [ ${zone} -lt 1 ] && zone=1
    if [ $((zone - q_lines - sum)) -ge 3 ]; then
        gap=2
    else
        gap=1
    fi
    n=$((q_lines + gap + sum))
    while :; do
        {
            _tp_vcenter_top "${rows}" "${n}" "${#TP_FOOTER[@]}"
            st="$(_tp_step_attr)"
            _tp_center "${w}" "${st}" "${TP_RST}" "$(printf '%s\n' "${ql[@]}")"
            for (( i=0; i<gap; i++ )); do
                printf '\n'
            done
            for (( r=0; r<${#row_sc[@]}; r++ )); do
                if [ "${row_rl[r]}" -eq 1 ]; then
                    line=""
                    for (( i=row_sc[r]; i<=row_ec[r]; i++ )); do
                        marker=" "
                        [ $((i + 1)) -eq ${col} ] && marker="▸"
                        seg="$(printf '%s%2d. %s' "${marker}" "$((i + 1))" "${arr[i]}")"
                        if [ $((i + 1)) -eq ${col} ]; then
                            seg=$'\033[7m'"${seg}"$'\033[0m'
                        fi
                        if [ -z "${line}" ]; then
                            line="${seg}"
                        else
                            line="${line}  ${seg}"
                        fi
                    done
                    printf '%*s%s\n' "$((row_x[r] - 1))" "" "${line}"
                else
                    i=${row_sc[r]}
                    marker=" "
                    [ $((i + 1)) -eq ${col} ] && marker="▸"
                    mapfile -t wl < <(_tp_wrap $((avail - 5)) "${arr[i]}")
                    for (( li=0; li<${row_rl[r]} && li<${#wl[@]}; li++ )); do
                        if [ ${li} -eq 0 ]; then
                            seg="$(printf '%s%2d. %s' "${marker}" "$((i + 1))" "${wl[li]}")"
                        else
                            seg="${wl[li]}"
                        fi
                        if [ $((i + 1)) -eq ${col} ]; then
                            printf '%*s%s%s%s\n' \
                                "$((row_x[r] - 1 + (li > 0 ? 5 : 0)))" "" \
                                $'\033[7m' "${seg}" $'\033[0m'
                        else
                            printf '%*s%s\n' \
                                "$((row_x[r] - 1 + (li > 0 ? 5 : 0)))" "" "${seg}"
                        fi
                    done
                fi
            done
            _tp_status_bar "${rows}" "${TP_START}" "${n}"
        } > /dev/tty
        _tp_read_event || return 1
        case "${tp_event}" in
            enter)
                printf '%s' "${arr[$((col-1))]}"
                return 0 ;;
            up)
                col=$((col - 1))
                [ ${col} -lt 1 ] && col=${#arr[@]} ;;
            down)
                col=$((col + 1))
                [ ${col} -gt ${#arr[@]} ] && col=1 ;;
            num[1-9])
                idx="${tp_event#num}"
                if [ ${idx} -le ${#arr[@]} ]; then
                    printf '%s' "${arr[$((idx-1))]}"
                    return 0
                fi ;;
            q|esc|eof) return 1 ;;
            mouse:*)
                _tp_mouse_button "${tp_event}" || continue
                case "${TP_BTN}" in
                    right) return 1 ;;
                    left)
                        y="$(sed -n 's/^mouse:<[0-9]*;[0-9]*;\([0-9]*\)[Mm]$/\1/p' <<< "${tp_event}")"
                        case "${y}" in
                            ''|*[!0-9]*) continue ;;
                        esac
                        acc=$((TP_START + q_lines + gap))
                        found=-1
                        ry=${acc}
                        for (( r=0; r<${#row_sc[@]}; r++ )); do
                            if [ "${y}" -ge "${ry}" ] && \
                                [ "${y}" -lt "$((ry + row_rl[r]))" ]; then
                                found=${r}
                                break
                            fi
                            ry=$((ry + row_rl[r]))
                        done
                        [ ${found} -lt 0 ] && continue
                        if [ "${row_rl[found]}" -gt 1 ]; then
                            idx=$((row_sc[found] + 1))
                        else
                            x="$(sed -n 's/^mouse:<[0-9]*;\([0-9]*\);[0-9]*[Mm]$/\1/p' <<< "${tp_event}")"
                            case "${x}" in
                                ''|*[!0-9]*) continue ;;
                            esac
                            idx=""
                            for (( i=row_sc[found]; i<=row_ec[found]; i++ )); do
                                if [ "${x}" -ge "${cell_cx[i]}" ] && \
                                    [ "${x}" -le "$((cell_cx[i] + cell_cw[i] - 1))" ]; then
                                    idx=$((i + 1))
                                    break
                                fi
                            done
                            [ -z "${idx}" ] && continue
                        fi
                        printf '%s' "${arr[$((idx - 1))]}"
                        return 0 ;;
                esac ;;
        esac
    done
}

function ui_recognize_card() {
    local txt="$1" w rows attr n hw zone avail pad word_top
    local -a wl
    shift
    txt="$(_tp_plain "${txt}")"
    w="$(_tp_cols)"
    rows="$(_tp_rows)"
    if [ "${lang_question:-0}" = 1 ]; then
        attr=$'\033[1;90m'
    else
        attr="$(_tp_step_attr)"
    fi
    hw="$(_tp_vcount "$((w - 2))" "$(gettext "Do you recognize this word?")")"
    mapfile -t wl < <(_tp_wrap $((w - 4)) "$(_tp_trim "${txt}")")
    [ ${#wl[@]} -eq 0 ] && wl=("")
    _tp_footer_reset
    _tp_footer_add "${w}" "[y] Yes" "[n] No"
    _tp_footer_add "${w}" "[r] repeat audio" "[q] quit"
    zone=$((rows - ${#TP_FOOTER[@]}))
    [ ${zone} -lt 1 ] && zone=1
    n=${#wl[@]}
    avail=$((zone - hw - n))
    if [ ${avail} -ge 2 ]; then
        pad=$((avail / 2))
    elif [ ${avail} -ge 1 ]; then
        pad=1
    else
        pad=0
    fi
    word_top=$((hw + pad))
    ( sleep 0.5 && "$@" ) >/dev/null 2>&1 &
    while :; do
        {
            printf '\033[2J\033[H'
            printf '  %s%s%s\n' "${TP_D}" \
                "$(gettext "Do you recognize this word?")" "${TP_RST}"
            for (( i=0; i<word_top - hw; i++ )); do
                printf '\n'
            done
            _tp_center "${w}" "${attr}" "${TP_RST}" "${txt}"
            _tp_card_help "${w}" "${rows}" \
                "$(gettext "Click izquierdo: conozco esta palabra")" \
                "$(gettext "Click derecho: no conozco esta palabra")"
            _tp_status_bar "${rows}" "${word_top}" "${n}"
        } > /dev/tty
        _tp_read_event || return 1
        case "${tp_event}" in
            y) return 2 ;;
            n|m) return 3 ;;
            enter)
                "$@" >/dev/null 2>&1 & ;;
            r)
                "$@" >/dev/null 2>&1 & ;;
            q|esc|eof) return 1 ;;
            mouse:*)
                _tp_mouse_button "${tp_event}" || continue
                case "${TP_BTN}" in
                    left) return 2 ;;
                    right) return 3 ;;
                    middle)
                        "$@" >/dev/null 2>&1 & ;;
                esac ;;
        esac
    done
}

TP_AUDIO_PIDFILE=""

function tp_audio_track() {
    if [ -n "${TP_AUDIO_PIDFILE}" ]; then
        printf '%s\n' "$1" >> "${TP_AUDIO_PIDFILE}"
    fi
    return 0
}

function tp_audio_stop() {
    local _f="${TP_AUDIO_PIDFILE}" _p
    if [ -z "${_f}" ] || [ ! -f "${_f}" ]; then
        return 0
    fi
    while read -r _p; do
        case "${_p}" in
            ''|*[!0-9]*) ;;
            *) kill "${_p}" 2>/dev/null ;;
        esac
    done < "${_f}"
    rm -f "${_f}"
    return 0
}

function _tp_check_colors() {
    local esc=$'\033'
    sed -e "s|<span color='#3A9000'><b>\([^<]*\)</b></span>|${esc}[1;32m\1${esc}[0m|g" \
        -e "s|<span color='#984245'><b>\([^<]*\)</b></span>|${esc}[1;31m\1${esc}[0m|g" \
        -e 's|<small>||g' -e 's|</small>||g' \
        -e "s|<b>|${esc}[1m|g" -e "s|</b>|${esc}[22m|g" \
        -e 's|<span[^>]*>||g' -e 's|</span>||g' \
        <<< "${1}"
}

function ui_write_sentence() {
    local txt="$1" buf="" k ch seq w rows header hint hn nh pn g2 pad avail nrest zone spare lv
    local prompt_row=0 pn_prev=-1 dirty=1 j
    local -a hl
    shift
    txt="$(_tp_trim "$(_tp_plain "${txt}")")"
    case "${txt}" in
        *$'\n\n'*)
            header="$(_tp_trim "${txt%%$'\n\n'*}")"
            hint="$(_tp_trim "${txt#*$'\n\n'}")" ;;
        *)
            header=""
            hint="${txt}" ;;
    esac
    w="$(_tp_cols)"
    rows="$(_tp_rows)"
    hn=0
    if [ -n "${header}" ]; then
        hn="$(_tp_vcount "$((w - 2))" "${header}")"
    fi
    mapfile -t hl < <(_tp_wrap $((w - 4)) "${hint}")
    [ ${#hl[@]} -eq 0 ] && hl=("")
    nh=${#hl[@]}
    _tp_footer_reset
    _tp_footer_add "${w}" "[Enter] send answer" "[Ctrl+R] repeat audio" \
        "[Esc] quit"
    while :; do
        if [ ${dirty} -eq 1 ]; then
            lv="$(_tp_vlen "${buf}")"
            if [ "${lv}" -le "$((w - 6))" ]; then
                pn=1
            else
                pn=$(( 1 + (lv - (w - 6) + (w - 2) - 1) / (w - 2) ))
            fi
            zone=$((rows - ${#TP_FOOTER[@]}))
            [ ${zone} -lt 1 ] && zone=1
            spare=$((zone - hn - nh - pn))
            g2=1
            if [ ${spare} -ge 5 ]; then
                g2=2
            fi
            avail=$((spare - g2))
            if [ ${avail} -ge 2 ]; then
                pad=$((avail / 2))
            elif [ ${avail} -ge 1 ]; then
                pad=1
            else
                pad=0
            fi
            nrest=$((nh + g2 + pn))
            if [ ${prompt_row} -eq 0 ] || [ ${pn} -ne ${pn_prev} ]; then
                {
                    printf '\033[2J\033[H'
                    if [ -n "${header}" ]; then
                        printf '  %s%s%s\n' "${TP_D}" "${header}" "${TP_RST}"
                    fi
                    for (( i=0; i<pad; i++ )); do
                        printf '\n'
                    done
                    _tp_center "${w}" $'\033[90m' "${TP_RST}" \
                        "$(printf '%s\n' "${hl[@]}")"
                    for (( i=0; i<g2; i++ )); do
                        printf '\n'
                    done
                    printf '  %s> %s\033[0m\033[K\n' "${TP_D}" "${buf}"
                    _tp_card_help "${w}" "${rows}" \
                        "$(gettext "Espacio: reproducir audio")" ""
                    _tp_status_bar "${rows}" "$((hn + pad))" "${nrest}"
                } > /dev/tty
                prompt_row=$((hn + pad + nh + g2 + 1))
                pn_prev=${pn}
            else
                {
                    printf '\033[%d;1H' "${prompt_row}"
                    printf '  %s> %s\033[0m\033[K' "${TP_D}" "${buf}"
                    for (( j=1; j<pn_prev; j++ )); do
                        printf '\033[%d;1H\033[K' "$((prompt_row + j))"
                    done
                } > /dev/tty
            fi
            dirty=0
        fi
        if ! IFS= read -rsn1 k < /dev/tty; then
            return 1
        fi
        case "$k" in
            ''|$'\n'|$'\r')
                printf '%s' "${buf}"
                return 0 ;;
            ' ')
                if [ -z "${buf}" ]; then
                    "$@" >/dev/null 2>&1 &
                else
                    buf="${buf} "
                    dirty=1
                fi ;;
            $'\033')
                if IFS= read -rsn1 -t 0.1 ch < /dev/tty; then
                    if [ "$ch" = "[" ] || [ "$ch" = "O" ]; then
                        seq=""
                        while IFS= read -rsn1 -t 0.1 ch < /dev/tty; do
                            seq="${seq}${ch}"
                            case "$ch" in
                                M|m|[A-Za-z~]) break ;;
                            esac
                        done
                        case "$seq" in
                            '<'*)
                                if _tp_mouse_button "mouse:${seq}"; then
                                    case "${TP_BTN}" in
                                        middle)
                                            "$@" >/dev/null 2>&1 &
                                            tp_audio_track "$!" ;;
                                    esac
                                fi ;;
                        esac
                    fi
                else
                    return 1
                fi ;;
            $'\022')
                "$@" >/dev/null 2>&1 &
                tp_audio_track "$!" ;;
            $'\177'|$'\010')
                buf="${buf%?}"
                dirty=1 ;;
            *)
                case "$k" in
                    [[:cntrl:]]) ;;
                    *) buf="${buf}${k}"
                       dirty=1 ;;
                esac ;;
        esac
    done
}

function ui_check_result() {
    local t gw ph w rows nt nw g1 g2 zone n
    local -a tl
    t="$(_tp_trim "$(_tp_plain "${1}")")"
    gw="$(_tp_check_colors "${2}")"
    ph="$(_tp_check_colors "${3}")"
    w="$(_tp_cols)"
    rows="$(_tp_rows)"
    mapfile -t tl < <(_tp_wrap $((w - 4)) "${t}")
    [ ${#tl[@]} -eq 0 ] && tl=("")
    nt=${#tl[@]}
    nw="$(_tp_vcount "$((w - 2))" "${gw}")"
    _tp_footer_reset
    _tp_footer_add "${w}" "[Enter] continue" "[r] repeat audio" "[q] quit"
    zone=$((rows - ${#TP_FOOTER[@]}))
    [ ${zone} -lt 1 ] && zone=1
    g1=1
    g2=1
    if [ $((zone - nt - nw - 6)) -ge 1 ]; then
        g2=2
    fi
    n=$((nt + nw + 5 + g2))
    shift 3
    while :; do
        {
            _tp_vcenter_top "${rows}" "${n}" "${#TP_FOOTER[@]}"
            printf '  %s%s%s\n' "${TP_D}" "$(gettext "Result:")" "${TP_RST}"
            for (( i=0; i<g1; i++ )); do
                printf '\n'
            done
            _tp_center "${w}" "${TP_D}" "${TP_RST}" "$(gettext "Correcta")"
            _tp_center "${w}" "${TP_B}" "${TP_RST}" "${t}"
            for (( i=0; i<g2; i++ )); do
                printf '\n'
            done
            printf '  %s%s%s\n' "${TP_D}" "$(gettext "Tu respuesta")" "${TP_RST}"
            printf '  %s\n' "${gw}"
            printf '  %s\n' "${ph}"
            _tp_card_help "${w}" "${rows}" \
                "$(gettext "Espacio: reproducir audio")" ""
            _tp_status_bar "${rows}" "${TP_START}" "${n}"
        } > /dev/tty
        _tp_read_event || return 1
        case "${tp_event}" in
            enter)
                if [ "${tp_space}" = 1 ]; then
                    "$@" >/dev/null 2>&1 &
                else
                    return 2
                fi ;;
            r)
                "$@" >/dev/null 2>&1 &
                tp_audio_track "$!" ;;
            q|esc|eof) return 1 ;;
            mouse:*)
                _tp_mouse_button "${tp_event}" || continue
                case "${TP_BTN}" in
                    left) return 2 ;;
                    right) return 1 ;;
                    middle)
                        "$@" >/dev/null 2>&1 &
                        tp_audio_track "$!" ;;
                esac ;;
        esac
    done
}

function tp_mouse_on() {
    printf '\033[?1000h\033[?1006h'
}

function tp_mouse_off() {
    printf '\033[?1006l\033[?1000l'
}

function tp_state_file() {
    echo "${dir_practice}/.${active_practice:-a}.exstate"
}

function tp_state_write() {
    local _f _tmp
    _f="$(tp_state_file)"
    _tmp="${_f}.$$"
    {
        printf 'phase=%s\n' "${1:-quit}"
        printf 'pid=%s\n' "$$"
        printf 'count_easy=%s\n' "${count_easy:-0}"
        printf 'count_hard=%s\n' "${count_hard:-0}"
        printf 'count_learn=%s\n' "${count_learn:-0}"
        printf 'step=%s\n' "${step:-1}"
    } > "${_tmp}" 2>/dev/null && mv -f "${_tmp}" "${_f}"
}

function tp_state_read() {
    local _f="${1}" k v
    tp_phase=""
    tp_pid=""
    count_easy=0
    count_hard=0
    count_learn=0
    step=1
    [ -f "${_f}" ] || return 1
    while IFS='=' read -r k v; do
        case "${k}" in
            phase) tp_phase="${v}" ;;
            pid) tp_pid="${v}" ;;
            count_easy|count_hard|count_learn)
                case "${v}" in
                    ''|*[!0-9]*) ;;
                    *) printf -v "${k}" '%s' "${v}" ;;
                esac ;;
            step)
                case "${v}" in
                    1|2|3) step="${v}" ;;
                esac ;;
        esac
    done < "${_f}"
    return 0
}

function tp_wait_state() {
    local _f="${1}" t=0 phase pid
    while [ ! -f "${_f}" ]; do
        t=$((t+1))
        [ ${t} -ge 100 ] && return 1
        sleep 0.1
    done
    while :; do
        phase="$(sed -n 's/^phase=//p' "${_f}" | head -n 1)"
        if [ -n "${phase}" ] && [ "${phase}" != "start" ]; then
            return 0
        fi
        pid="$(sed -n 's/^pid=//p' "${_f}" | head -n 1)"
        case "${pid}" in
            ''|*[!0-9]*) sleep 0.2 ;;
            *)
                if kill -0 "${pid}" 2>/dev/null; then
                    sleep 0.2
                else
                    sleep 0.3
                    return 0
                fi ;;
        esac
    done
}

function tp_practice_launch() {
    local letter="${1}" title="${2}" exstate
    exstate="$(tp_state_file)"
    rm -f "${exstate}"
    tp_open_terminal "${title}" \
        env HOME="${HOME}" bash "$DS/practice/strt.sh" "$tpc" exercise "${letter}" || return 1
    tp_wait_state "${exstate}" || return 1
    tp_state_read "${exstate}"
    export count_easy count_hard count_learn step
    if [ "${tp_phase}" = "done" ]; then
        export count_hard count_learn
        scoreschk
    else
        score && return
    fi
    return 0
}

function tp_open_terminal() {
    local wtitle="$1" term rc
    shift
    for term in gnome-terminal xfce4-terminal konsole tilix terminator \
                lxterminal alacritty kitty foot st xterm; do
        command -v "$term" >/dev/null 2>&1 || continue
        case "$term" in
            gnome-terminal)
                "$term" --title="$wtitle" -- "$@" >/dev/null 2>&1 ;;
            xfce4-terminal)
                "$term" --title="$wtitle" -x "$@" >/dev/null 2>&1 ;;
            konsole|tilix)
                "$term" --title "$wtitle" -e "$@" >/dev/null 2>&1 ;;
            lxterminal|terminator)
                "$term" --title="$wtitle" -e "$*" >/dev/null 2>&1 ;;
            alacritty)
                "$term" --title "$wtitle" -e "$@" >/dev/null 2>&1 ;;
            kitty|foot)
                "$term" --title "$wtitle" "$@" >/dev/null 2>&1 ;;
            st)
                "$term" -t "$wtitle" -e "$@" >/dev/null 2>&1 ;;
            xterm)
                "$term" -T "$wtitle" -e "$@" >/dev/null 2>&1 ;;
            *)
                "$term" -e "$@" >/dev/null 2>&1 ;;
        esac
        rc=$?
        [ ${rc} -eq 0 ] && return 0
    done
    return 1
}

function tp_exercise_on_signal() {
    if [ "${step:-1}" = "1" ]; then
        count_learn="${count_hard:-0}"
        count_hard=0
    fi
    tp_exercise_ended="quit"
    exit 130
}

function tp_exercise_on_exit() {
    stty echo echoctl < /dev/tty 2>/dev/null
    tp_mouse_off
    tp_state_write "${tp_exercise_ended:-quit}"
}

function tp_exercise_run() {
    local _fn="${1}"
    if ! [ -t 1 ]; then
        return 1
    fi
    tp_exercise_ended="quit"
    tp_state_write start
    trap 'tp_exercise_on_exit' EXIT
    trap 'tp_exercise_on_signal' HUP INT TERM
    stty -echo -echoctl < /dev/tty 2>/dev/null
    tp_mouse_on
    score() { tp_exercise_ended="quit"; exit 0; }
    scoreschk() { tp_exercise_ended="done"; exit 0; }
    "${_fn}"
    tp_exercise_ended="done"
    exit 0
}
