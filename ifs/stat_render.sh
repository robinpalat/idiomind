#!/usr/bin/env bash
# Idiomind Shell — terminal statistics renderer

# ANSI palette: subdued blue/aqua/green/amber/orange/purple/gray.
_ST_RESET=$'\033[0m'
_ST_BOLD=$'\033[1m'
_ST_DIM=$'\033[2m'
_ST_BLUE=$'\033[38;5;110m'
_ST_GREEN=$'\033[38;5;108m'
_ST_AMBER=$'\033[38;5;179m'
_ST_PURPLE=$'\033[38;5;140m'
_ST_GRAY=$'\033[38;5;245m'
_ST_CYAN=$'\033[38;5;109m'
_ST_AQUA=$'\033[38;5;152m'
_ST_ORANGE=$'\033[38;5;173m'
_ST_GRAY_DK=$'\033[38;5;242m'

_st_plain() { printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g'; }
_st_cols() { local n; n=$(tput cols 2>/dev/null); [[ "$n" =~ ^[0-9]+$ ]] && ((n >= 50)) && printf '%s' "$n" || printf '80'; }
_st_rule() { printf '%s' "${_ST_GRAY}"; printf '%*s' "$(_st_cols)" '' | sed 's/ /─/g'; printf '%s\n' "${_ST_RESET}"; }
# Description wrapped to the terminal width: every physical line is one line
# of the view buffer, so the scroll logic counts real rows.
_st_desc() {
    printf '%s\n' "$1" | fold -s -w "$(( $(_st_cols) - 4 ))" | sed 's/^/  /'
    printf '\n'
}
# Alternate screen buffer: no scrollback is kept, so previous views never pile up
# when the mouse wheel is used. Mode 1007 makes the wheel send ↑/↓ keys, which
# the viewer below uses to scroll. Normal tracking (1000) + SGR (1006) enable
# clicks; the cursor is hidden while the viewer owns the screen and restored
# by _st_leave (normal exit and the INT/TERM/HUP trap).
_st_enter() { printf '\033[?1049h\033[?1007h\033[?1000h\033[?1006h\033[?25l'; }
_st_leave() { printf '\033[?1006l\033[?1000l\033[?1007l\033[?1049l\033[?25h'; }
_st_header() {
    local number="$1" title="$2" period="$3"
    printf '\n%s%s%s %s— %s%s\n' "$_ST_BOLD" "$title" "$_ST_RESET" "$_ST_DIM" "$period" "$_ST_RESET"
    _st_rule
}
_st_bar() {
    # label, value, max, color, optional unit; integer-safe scaling.
    local label="$1" value="$2" max="$3" color="$4" unit="${5:-}"
    local width=24 filled=0 empty pct label_width=21 len
    [[ "$value" =~ ^[0-9]+$ ]] || value=0
    [[ "$max" =~ ^[0-9]+$ ]] || max=0
    ((max > 0)) && filled=$((value * width / max))
    ((filled > width)) && filled=$width
    empty=$((width-filled)); pct=0
    ((max > 0)) && pct=$((value * 100 / max))
    # Pad by display characters, not bytes: keeps bars aligned when the
    # translated label contains accented/multibyte letters. C.UTF-8 is used
    # only to measure width; it does not change the UI language.
    printf '  %s' "$label"
    len=$(printf '%s' "$label" | LC_ALL=C.UTF-8 wc -m)
    (( len < label_width )) && printf '%*s' $(( label_width - len )) ''
    printf ' '
    printf '%s' "$color"
    printf '%*s' "$filled" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY"
    printf '%*s' "$empty" '' | sed 's/ /░/g'
    printf '%s' "$_ST_RESET"
    printf ' %5s' "$value"
    [[ -n "$unit" ]] && printf ' %s' "$unit"
    printf '  %3d%%\n' "$pct"
}
_st_max() {
    local v max=0
    for v in "$@"; do [[ "$v" =~ ^[0-9]+$ ]] || v=0; ((v>max)) && max=$v; done
    ((max==0)) && max=1
    printf '%s' "$max"
}
# Stacked bar: green represents Learned, celeste represents Reviewing.
_st_stacked_bar() {
    local label="$1" learned="$2" reviewing="$3" max="$4" unit="${5:-}"
    local width=24 total filled learned_fill reviewing_fill empty pct label_width=21 len
    [[ "$learned" =~ ^[0-9]+$ ]] || learned=0
    [[ "$reviewing" =~ ^[0-9]+$ ]] || reviewing=0
    [[ "$max" =~ ^[0-9]+$ ]] || max=0
    total=$((learned + reviewing))
    filled=0; learned_fill=0; reviewing_fill=0; pct=0
    if ((max > 0)); then
        filled=$((total * width / max))
        pct=$((total * 100 / max))
    fi
    ((filled > width)) && filled=$width
    if ((total > 0)); then
        learned_fill=$((filled * learned / total))
        reviewing_fill=$((filled - learned_fill))
    fi
    empty=$((width - filled))
    printf '  %s' "$label"
    len=$(printf '%s' "$label" | LC_ALL=C.UTF-8 wc -m)
    (( len < label_width )) && printf '%*s' $(( label_width - len )) ''
    printf ' '
    printf '%s' "$_ST_GREEN"
    printf '%*s' "$learned_fill" '' | sed 's/ /█/g'
    printf '%s' "$_ST_BLUE"
    printf '%*s' "$reviewing_fill" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY"
    printf '%*s' "$empty" '' | sed 's/ /░/g'
    printf '%s' "$_ST_RESET"
    printf ' %5s' "$total"
    [[ -n "$unit" ]] && printf ' %s' "$unit"
    printf '  %3d%%\n' "$pct"
}
_st_arr() { sed -n "s/.*\"$2\":\[\([^]]*\)\].*/\1/p" <<< "$1" | head -n1 | tr -d '"'; }
# Month abbreviation: always extract the English form (stable gettext
# msgid), then translate it through the idiomind catalog.
_st_month_label() {
    local y="$1" m="$2" lbl
    lbl="$(LC_TIME=C date -d "${y}-$(printf '%02d' "$m")-01" +%b 2>/dev/null)"
    [[ -n "$lbl" ]] && gettext "$lbl" || printf '%02d' "$m"
}
# Week label stored in the log DB as e.g. "Jun15" (English %b + day).
# Translate the month part; keep the numeric day as-is.
_st_week_label() {
    local s="$1"
    if [[ "$s" =~ ^([A-Za-z]{3})([0-9]{2})$ ]]; then
        printf '%s%s' "$(gettext "${BASH_REMATCH[1]}")" "${BASH_REMATCH[2]}"
    else
        printf '%s' "$s"
    fi
}
# Display a stored Monday label (e.g. Oct05) as a localized Monday–Sunday range.
_st_week_range() {
    local s="$1" mon day year start end end_mon start_day end_day start_label end_label
    [[ "$s" =~ ^([A-Za-z]{3})([0-9]{2})$ ]] || { printf '%s' "$(_st_week_label "$s")"; return; }
    mon="${BASH_REMATCH[1]}"
    day="${BASH_REMATCH[2]}"
    year=$(date +%Y)
    start=$(LC_TIME=C date -d "$mon $day $year" +%F 2>/dev/null) || {
        printf '%s' "$(_st_week_label "$s")"
        return
    }
    # Labels from late December may refer to the previous year when viewed in January.
    if [[ "$start" > "$(date -d '+7 days' +%F)" ]]; then
        year=$((year - 1))
        start=$(LC_TIME=C date -d "$mon $day $year" +%F 2>/dev/null) || {
            printf '%s' "$(_st_week_label "$s")"
            return
        }
    fi
    end=$(date -d "$start +6 days" +%F)
    start_day=$(date -d "$start" +%-d)
    end_day=$(date -d "$end" +%-d)
    start_label="$(_st_month_label "$(date -d "$start" +%Y)" "$(date -d "$start" +%-m)")"
    end_label="$(_st_month_label "$(date -d "$end" +%Y)" "$(date -d "$end" +%-m)")"
    # Always include the month beside both day numbers so every weekly
    # label has the same structure and occupies a predictable width.
    printf '%s %s – %s %s' "$start_day" "$start_label" "$end_day" "$end_label"
}

# Stacked weekly bar for the activity screen: one bar per week, green for
# tests passed and dark gray for the tests practiced that were not passed;
# the total length is the number of tests practiced. The two rows use half
# blocks so the bar keeps the combined height of the two single bars it
# replaces, and each number line sits on the row of its segment.
_st_week_stacked_bar() {
    local week_label="$1" passed="$2" practiced="$3" max="$4"
    local width=30 filled=0 gfill=0 rest=0 empty=0 label_len
    [[ "$passed" =~ ^[0-9]+$ ]] || passed=0
    [[ "$practiced" =~ ^[0-9]+$ ]] || practiced=0
    ((passed > practiced)) && passed=$practiced
    [[ "$max" =~ ^[0-9]+$ ]] || max=0

    if ((max > 0 && practiced > 0)); then
        filled=$((practiced * width / max))
        ((filled == 0)) && filled=1
    fi
    ((filled > width)) && filled=$width
    if ((practiced > 0)); then
        gfill=$((filled * passed / practiced))
        ((passed > 0 && gfill == 0)) && gfill=1
    fi
    ((gfill > filled)) && gfill=$filled
    rest=$((filled - gfill))
    empty=$((width - filled))

    label_len=$(printf '%s' "$week_label" | LC_ALL=C.UTF-8 wc -m)
    printf '  %s' "$week_label"
    (( label_len < 20 )) && printf '%*s' "$((20 - label_len))" ''
    printf '  '

    # Two rows of full blocks form one continuous, thicker stacked bar.
    # Green = passed; dark gray = practiced but not passed; hatch = no activity.
    printf '%s' "$_ST_GREEN"
    printf '%*s' "$gfill" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY_DK"
    printf '%*s' "$rest" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY"
    printf '%*s' "$empty" '' | sed 's/ /░/g'
    printf '%s' "$_ST_RESET"
    printf '  %s%d%s\n' "$_ST_GREEN" "$passed" "$_ST_RESET"

    printf '%24s' ''
    printf '%s' "$_ST_GREEN"
    printf '%*s' "$gfill" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY_DK"
    printf '%*s' "$rest" '' | sed 's/ /█/g'
    printf '%s' "$_ST_GRAY"
    printf '%*s' "$empty" '' | sed 's/ /░/g'
    printf '%s' "$_ST_RESET"
    printf '  %d\n' "$practiced"
}

stats_terminal_dlg() {
    local l1 l2 i cur y m yy idx shown key
    local seq ch mb mx my x navline pre2 pre3 preq c2 c3 cq q_end rows_click

    if [[ ! -s "${data:-}" ]]; then
        printf '\n%s\n\n' "${ST_INSUFFICIENT:-$(gettext "Insufficient data")}"
        read -r -p "$(gettext "Press Enter to return...") " _ || true
        return
    fi
    l1=$(grep -m1 '^data1=' "$data")
    l2=$(grep -m1 '^data2=' "$data")
    local p1 p1desc p2 p2desc p3 p3desc p3passed p3activity
    local p1_now p1_trend p_period_m p_period_w p_unit_topics
    local nav_topics nav_words nav_activity nav_quit nav_scroll
    local -a p1labels p2labels t0 t1 t2 t3 t4 wk w0 w1 w2 w3 w4 w5 w6

    p1="$(gettext "Topics status")"
    p1desc="$(gettext "Each bar shows how many topics are in each state. Monthly comparison shows how your learning library changes.")"
    p1labels=("$(gettext "Learning")" "$(gettext "Learned")" "$(gettext "Reviewing")" \
              "$(gettext "Review reminder")" "$(gettext "Inactive")")
    p1_now="$(gettext "Current month distribution")"
    p1_trend="  $(gettext "Learned") + $(gettext "Reviewing")"
    p_period_m="$(gettext "Monthly register · last 5 months")"
    p_unit_topics="$(gettext "topics")"

    p2="$(gettext "Word activity")"
    p2desc="$(gettext "Values count word records in each category for that week. They describe recorded activity, not a direct measure of mastery.")"

    p2labels=("$(gettext "New")" "$(gettext "Learning")" "$(gettext "Forgotten")" \
              "$(gettext "Difficult")" "$(gettext "Reviewed")")
    p_period_w="$(gettext "Weekly report · last 5 weeks")"

    p3="$(gettext "Practice activity")"
    p3desc="$(gettext "Compares tests passed with tests practiced each week. The number of tests practiced alone does not indicate language mastery.")"
    p3passed="$(gettext "Tests passed")"
    p3activity="$(gettext "Tests practiced")"

    nav_topics="$(gettext "Topics")"
    nav_words="$(gettext "Words")"
    nav_activity="$(gettext "Activity")"
    nav_quit="$(gettext "Quit")"
    nav_scroll="$(gettext "Scroll")"

    IFS=',' read -r -a t0 <<< "$(_st_arr "$l1" f0)"
    IFS=',' read -r -a t1 <<< "$(_st_arr "$l1" f1)"
    IFS=',' read -r -a t2 <<< "$(_st_arr "$l1" f2)"
    IFS=',' read -r -a t3 <<< "$(_st_arr "$l1" f3)"
    IFS=',' read -r -a t4 <<< "$(_st_arr "$l1" f4)"
    IFS=',' read -r -a wk <<< "$(_st_arr "$l2" wk)"
    IFS=',' read -r -a w0 <<< "$(_st_arr "$l2" f0)"
    IFS=',' read -r -a w1 <<< "$(_st_arr "$l2" f1)"
    IFS=',' read -r -a w2 <<< "$(_st_arr "$l2" f2)"
    IFS=',' read -r -a w3 <<< "$(_st_arr "$l2" f3)"
    IFS=',' read -r -a w4 <<< "$(_st_arr "$l2" f4)"
    IFS=',' read -r -a w5 <<< "$(_st_arr "$l2" f5)"
    IFS=',' read -r -a w6 <<< "$(_st_arr "$l2" f6)"

    local tmp off rows view_h total max_off k rest quit=0
    local -a lines
    tmp=$(mktemp 2>/dev/null) || tmp="/tmp/.idiomind_stats_view.$$"
    trap '_st_leave; rm -f "$tmp"; exit 130' INT TERM HUP
    _st_enter

    # Navigation loop. Each view is rendered into a buffer first, then shown
    # through a viewport that always starts at the top (header visible).
    key=1
    while :; do
      {
      case "$key" in
        1)
          _st_header 1 "$p1" "$p_period_m"
          _st_desc "${p1desc//. /.$'\n'}"
          cur=$(date +%m); y=$(date +%Y); local -a vals names month_totals month_learned month_reviewing; local max=1
          for i in 0 1 2 3 4; do
            m=$((10#$cur - (4-i))); yy=$y
            if ((m<=0)); then m=$((m+12)); yy=$((yy-1)); fi
            idx=$((m-1)); names[i]="$(_st_month_label "$yy" "$m")"
            vals[i]="${t0[idx]:-0},${t1[idx]:-0},${t2[idx]:-0},${t3[idx]:-0},${t4[idx]:-0}"
          done
          # Show current month distribution, then a compact monthly total trend.
          idx=$((10#$cur - 1)); local -a now=("${t0[idx]:-0}" "${t1[idx]:-0}" "${t2[idx]:-0}" "${t3[idx]:-0}" "${t4[idx]:-0}")
          max=$(_st_max "${now[@]}")
          printf '%s%s  %s%s\n\n' "$_ST_BOLD" "$_ST_CYAN" "$p1_now" "$_ST_RESET"
          for i in 0 1 2 3 4; do
            case "$i" in 0) c=$_ST_AQUA;; 1) c=$_ST_GREEN;; 2) c=$_ST_BLUE;; 3) c=$_ST_ORANGE;; *) c=$_ST_GRAY;; esac
            _st_bar "${p1labels[i]}" "${now[i]}" "$max" "$c" "$p_unit_topics"
          done
          local totals_max=1 total
          for i in 0 1 2 3 4; do
            IFS=, read -r a b c d e <<< "${vals[i]}"
            # The trend represents topics that are learned or being reviewed.
            month_learned[i]=${b:-0}
            month_reviewing[i]=${c:-0}
            total=$(( ${b:-0}+${c:-0} ))
            month_totals[i]=$total
            ((total>totals_max)) && totals_max=$total
          done
          printf '\n%s%s%s\n' "$_ST_BOLD" "$p1_trend" "$_ST_RESET"
          printf '  %s█%s %s   %s█%s %s\n' \
            "$_ST_GREEN" "$_ST_RESET" "$(gettext "Learned")" \
            "$_ST_BLUE" "$_ST_RESET" "$(gettext "Reviewing")"
          for i in 0 1 2 3 4; do
            _st_stacked_bar "${names[i]}" "${month_learned[i]}" "${month_reviewing[i]}" "$totals_max" "$p_unit_topics"
          done
          ;;
        2)
          _st_header 2 "$p2" "$p_period_w"
          _st_desc "$p2desc"
          local -a latest=(); shown=0
          for ((i=${#wk[@]}-1; i>=0 && shown<5; i--)); do [[ -z "${wk[i]// /}" ]] && continue; latest+=("$i"); ((shown++)); done
          # val0..val4 -> New, Learning, Forgotten, Difficult, Reviewed
          local -a colors=("$_ST_BLUE" "$_ST_AMBER" "$_ST_PURPLE" "$_ST_GRAY" "$_ST_GREEN")
          local j v gmax=1

          for i in "${latest[@]}"; do
            for j in 0 1 2 3 4; do
              case "$j" in 0) v=${w0[i]:-0};; 1) v=${w1[i]:-0};; 2) v=${w2[i]:-0};; 3) v=${w3[i]:-0};; 4) v=${w4[i]:-0};; esac
              [[ "$v" =~ ^[0-9]+$ ]] || v=0; ((v>gmax)) && gmax=$v
            done
          done
          for i in "${latest[@]}"; do
            printf '\n%s%s%s\n' "$_ST_BOLD" "$(_st_week_label "${wk[i]}")" "$_ST_RESET"
            for j in 0 1 2 3 4; do
              case "$j" in 0) v=${w0[i]:-0};; 1) v=${w1[i]:-0};; 2) v=${w2[i]:-0};; 3) v=${w3[i]:-0};; 4) v=${w4[i]:-0};; esac
              _st_bar "${p2labels[j]}" "$v" "$gmax" "${colors[j]}"
            done
          done
          ;;
        3)
          _st_header 3 "$p3" "$p_period_w"
          _st_desc "$p3desc"
          printf '  %s█%s %s   %s█%s %s\n\n' \
            "$_ST_GREEN" "$_ST_RESET" "$p3passed" \
            "$_ST_GRAY_DK" "$_ST_RESET" "$p3activity"
          shown=0
          local -a activity_weeks=()
          local activity_max=1 a b j
          for ((i=${#wk[@]}-1; i>=0 && shown<5; i--)); do
            [[ -z "${wk[i]// /}" ]] && continue
            activity_weeks+=("$i")
            b=${w6[i]:-0}
            [[ "$b" =~ ^[0-9]+$ ]] || b=0
            ((b > activity_max)) && activity_max=$b
            ((shown++))
          done
          for ((j=0; j<${#activity_weeks[@]}; j++)); do
            i=${activity_weeks[j]}
            a=${w5[i]:-0}; b=${w6[i]:-0}
            _st_week_stacked_bar "$(_st_week_range "${wk[i]}")" "$a" "$b" "$activity_max"
            printf '\n'
          done
          ;;
      esac
      } > "$tmp"
      mapfile -t lines < "$tmp"
      off=0

      while :; do
        rows=$(tput lines 2>/dev/null); [[ "$rows" =~ ^[0-9]+$ ]] || rows=24
        view_h=$((rows-3)); ((view_h<5)) && view_h=5   # reserve: rule + nav + prompt
        total=${#lines[@]}
        max_off=$((total-view_h)); ((max_off<0)) && max_off=0
        ((off>max_off)) && off=$max_off
        ((off<0)) && off=0

        printf '\033[H\033[2J'
        printf '%s\n' "${lines[@]:off:view_h}"
        _st_rule
        printf '  [1] %s   [2] %s   [3] %s   [q] %s' \
          "$nav_topics" "$nav_words" "$nav_activity" "$nav_quit"
        ((max_off>0)) && printf '   %s[↑↓] %s %d-%d/%d%s' "$_ST_DIM" "$nav_scroll" \
          $((off+1)) $((off+view_h>total ? total : off+view_h)) "$total" "$_ST_RESET"
        printf '\n'
        read -r -s -n 1 -p '  > ' k || { quit=1; break; }

        if [[ "$k" == $'\033' ]]; then
          read -r -s -n 2 -t 0.05 rest
          case "$rest" in
            '[A'|'OA') k=up;;
            '[B'|'OB') k=down;;
            '[5') read -r -s -n 1 -t 0.05 _; k=pgup;;
            '[6') read -r -s -n 1 -t 0.05 _; k=pgdn;;
            '[H') k=home;;
            '[F') k=end;;
            '[<') # ratón SGR (1006): ESC [ < botón ; x ; y M|m
              seq=''
              while IFS= read -r -n 1 -t 0.1 ch; do
                [[ "$ch" == [Mm] ]] && break
                seq+="$ch"
              done
              if [[ "$ch" == M ]]; then
                IFS=';' read -r mb mx my <<< "$seq"
                rows_click=$(tput lines 2>/dev/null); [[ "$rows_click" =~ ^[0-9]+$ ]] || rows_click=24
                # La línea de navegación vive en la fila rows-1 (regla en rows-2).
                if [[ "$mb" == 0 && "$my" == "$((rows_click - 1))" ]]; then
                  k=click:"${mx:-0}"
                else
                  k=''
                fi
              else
                k=''
              fi
              ;;
            *) k='';;
          esac
        fi
        case "$k" in
          1|2|3) key=$k; break;;
          q|Q) quit=1; break;;
          click:*)
            # Mismos destinos que las teclas1/2/3/q: se reutiliza el
            # mismo case de navegación, sin duplicar la lógica.
            x="${k#click:}"
            navline="  [1] ${nav_topics}   [2] ${nav_words}   [3] ${nav_activity}   [q] ${nav_quit}"
            pre2="${navline%%\[2\]*}"; pre3="${navline%%\[3\]*}"; preq="${navline%%\[q\]*}"
            c2=$(( ${#pre2} + 1 )); c3=$(( ${#pre3} + 1 )); cq=$(( ${#preq} + 1 ))
            q_end=$(( cq + 4 + $(printf '%s' "${nav_quit}" | LC_ALL=C.UTF-8 wc -m) ))
            if (( x >= c2 && x < c3 )); then
              key=2; break
            elif (( x >= c3 && x < cq )); then
              key=3; break
            elif (( x >= cq && x < q_end )); then
              quit=1; break
            elif (( x >= 3 && x < c2 )); then
              key=1; break
            fi
            # Fuera de las opciones (p. ej. la pista de scroll): ignorado.
            ;;
          up|k) off=$((off-1));;
          down|j) off=$((off+1));;
          pgup) off=$((off-view_h+1));;
          pgdn|' ') off=$((off+view_h-1));;
          home|g) off=0;;
          end|G) off=$max_off;;
        esac
      done
      ((quit)) && break
    done
    trap - INT TERM HUP
    _st_leave
    rm -f "$tmp"
}
