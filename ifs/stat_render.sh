#!/usr/bin/env bash
# Idiomind Shell — terminal statistics renderer
# Source this file after stats.sh has initialized $data and generated data1/data2.
# This module only renders statistics; it does not read/write SQLite or alter logs.
#
# i18n: every visible string goes through gettext (domain: idiomind).
# TEXTDOMAIN/TEXTDOMAINDIR/LANGUAGE come from default/c.conf; this file
# does not set or override any locale environment variable.

# ANSI palette: subdued blue/green/amber/purple/gray.
_ST_RESET=$'\033[0m'
_ST_BOLD=$'\033[1m'
_ST_DIM=$'\033[2m'
_ST_BLUE=$'\033[38;5;110m'
_ST_GREEN=$'\033[38;5;108m'
_ST_AMBER=$'\033[38;5;179m'
_ST_PURPLE=$'\033[38;5;140m'
_ST_GRAY=$'\033[38;5;245m'
_ST_CYAN=$'\033[38;5;109m'

_st_plain() { printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g'; }
_st_cols() { local n; n=$(tput cols 2>/dev/null); [[ "$n" =~ ^[0-9]+$ ]] && ((n >= 50)) && printf '%s' "$n" || printf '80'; }
_st_rule() { printf '%s' "${_ST_GRAY}"; printf '%*s' "$(_st_cols)" '' | sed 's/ /─/g'; printf '%s\n' "${_ST_RESET}"; }
_st_header() {
    local number="$1" title="$2" period="$3"
    printf '\n%s%s IDIOMIND %s/ %s %s/ %02d%s\n' "$_ST_DIM" "$_ST_BLUE" "$_ST_GRAY" "$_ST_BLUE" "$(gettext "Statistics")" "$number" "$_ST_RESET"
    printf '\n%s%s%s\n' "$_ST_BOLD" "$title" "$_ST_RESET"
    printf '%s%s%s\n' "$_ST_DIM" "$period" "$_ST_RESET"
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

# Interfaz de terminal (sustituye las pestañas YAD).
# Requiere que stats.sh haya inicializado $data con data1/data2.
# El idioma lo determina gettext con el LANGUAGE que exporta c.conf.
stats_terminal_dlg() {
    local l1 l2 i cur y m yy idx shown key

    if [[ ! -s "${data:-}" ]]; then
        printf '\n%s\n\n' "${ST_INSUFFICIENT:-$(gettext "Insufficient data")}"
        read -r -p "$(gettext "Press Enter to return...") " _ || true
        return
    fi
    l1=$(grep -m1 '^data1=' "$data")
    l2=$(grep -m1 '^data2=' "$data")
    local p1 p1desc p2 p2desc p3 p3desc p3passed p3activity
    local p1_now p1_trend p1_note p_period_m p_period_w p_unit_topics
    local nav_topics nav_words nav_activity nav_quit
    local -a p1labels p2labels t0 t1 t2 t3 t4 wk w0 w1 w2 w3 w4 w5 w6

    p1="$(gettext "Topics status")"
    p1desc="$(gettext "Each bar shows how many topics are in each state. Monthly comparison shows how your learning library changes.")"
    p1labels=("$(gettext "Learning")" "$(gettext "Learned")" "$(gettext "Reviewing")" \
              "$(gettext "Review reminder")" "$(gettext "Inactive")")
    p1_now="$(gettext "Current month distribution")"
    p1_trend="$(gettext "Monthly total trend")"
    p1_note="$(gettext "the monthly total is the sum of the five recorded states.")"
    p_period_m="$(gettext "Monthly register · last 5 months")"
    p_unit_topics="$(gettext "topics")"

    p2="$(gettext "Word activity")"
    p2desc="$(gettext "Values count word records in each category for that week. They describe recorded activity, not a direct measure of mastery.")"
    p2labels=("$(gettext "New")" "$(gettext "Learned")" "$(gettext "Learning")" \
              "$(gettext "Reviewed")" "$(gettext "Passed")" "$(gettext "Forgotten")" \
              "$(gettext "Difficult")")
    p_period_w="$(gettext "Weekly report · last 5 weeks")"

    p3="$(gettext "Practice activity")"
    p3desc="$(gettext "Compares passed tests with total recorded activity each week. Activity alone is not a measure of language mastery.")"
    p3passed="$(gettext "Tests passed")"
    p3activity="$(gettext "Total activity")"

    nav_topics="$(gettext "Topics")"
    nav_words="$(gettext "Words")"
    nav_activity="$(gettext "Activity")"
    nav_quit="$(gettext "Quit")"

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

    # Navigation loop. Redraw only on explicit screen change.
    key=1
    while :; do
      clear 2>/dev/null || printf '\n\n'
      case "$key" in
        1)
          _st_header 1 "$p1" "$p_period_m"
          printf '  %s\n\n' "$p1desc"
          cur=$(date +%m); y=$(date +%Y); local -a vals names month_totals; local max=1
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
            case "$i" in 0) c=$_ST_BLUE;; 1) c=$_ST_GREEN;; 2) c=$_ST_AMBER;; 3) c=$_ST_PURPLE;; *) c=$_ST_GRAY;; esac
            _st_bar "${p1labels[i]}" "${now[i]}" "$max" "$c" "$p_unit_topics"
          done
          local totals_max=1 total
          for i in 0 1 2 3 4; do
            IFS=, read -r a b c d e <<< "${vals[i]}"
            total=$(( ${a:-0}+${b:-0}+${c:-0}+${d:-0}+${e:-0} ))
            month_totals[i]=$total
            ((total>totals_max)) && totals_max=$total
          done
          printf '\n%s%s%s\n' "$_ST_BOLD" "$p1_trend" "$_ST_RESET"
          for i in 0 1 2 3 4; do
            _st_bar "${names[i]}" "${month_totals[i]}" "$totals_max" "$_ST_BLUE" "$p_unit_topics"
          done
          printf '\n%s%s %s%s\n' "$_ST_DIM" "$(gettext "Note:")" "$p1_note" "$_ST_RESET"
          ;;
        2)
          _st_header 2 "$p2" "$p_period_w"
          printf '  %s\n\n' "$p2desc"
          local -a latest=(); shown=0
          for ((i=${#wk[@]}-1; i>=0 && shown<5; i--)); do [[ -z "${wk[i]// /}" ]] && continue; latest+=("$i"); ((shown++)); done
          local -a colors=("$_ST_BLUE" "$_ST_GREEN" "$_ST_CYAN" "$_ST_AMBER" "$_ST_GREEN" "$_ST_PURPLE" "$_ST_GRAY")
          for i in "${latest[@]}"; do
            printf '\n%s%s%s\n' "$_ST_BOLD" "$(_st_week_label "${wk[i]}")" "$_ST_RESET"
            local j v max=1
            for j in 0 1 2 3 4 5 6; do
              case "$j" in 0) v=${w0[i]:-0};; 1) v=${w1[i]:-0};; 2) v=${w2[i]:-0};; 3) v=${w3[i]:-0};; 4) v=${w4[i]:-0};; 5) v=${w5[i]:-0};; 6) v=${w6[i]:-0};; esac
              [[ "$v" =~ ^[0-9]+$ ]] || v=0; ((v>max)) && max=$v
            done
            for j in 0 1 2 3 4 5 6; do
              case "$j" in 0) v=${w0[i]:-0};; 1) v=${w1[i]:-0};; 2) v=${w2[i]:-0};; 3) v=${w3[i]:-0};; 4) v=${w4[i]:-0};; 5) v=${w5[i]:-0};; 6) v=${w6[i]:-0};; esac
              _st_bar "${p2labels[j]}" "$v" "$max" "${colors[j]}"
            done
          done
          ;;
        3)
          _st_header 3 "$p3" "$p_period_w"
          printf '  %s\n\n' "$p3desc"
          shown=0
          for ((i=${#wk[@]}-1; i>=0 && shown<5; i--)); do
            [[ -z "${wk[i]// /}" ]] && continue
            printf '\n%s%s%s\n' "$_ST_BOLD" "$(_st_week_label "${wk[i]}")" "$_ST_RESET"
            local a=${w5[i]:-0} b=${w6[i]:-0} mx
            mx=$(_st_max "$a" "$b")
            _st_bar "$p3passed" "$a" "$mx" "$_ST_GREEN"
            _st_bar "$p3activity" "$b" "$mx" "$_ST_BLUE"
            ((shown++))
          done
          ;;
      esac
      _st_rule
      printf '  [1] %s   [2] %s   [3] %s   [q] %s\n' \
        "$nav_topics" "$nav_words" "$nav_activity" "$nav_quit"
      read -r -n 1 -s -p '  > ' key || { printf '\n'; break; }
      case "$key" in 1|2|3) ;; q|Q) printf '\n'; break;; *) key=1;; esac
    done
}
