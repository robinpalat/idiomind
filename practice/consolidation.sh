#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -n "${DS:-}" ] && [ -r "$DS/default/sets.cfg" ]; then
    source "$DS/default/sets.cfg"
fi

function practice_sql_escape() {
    printf '%s' "${1//\'/\'\'}"
}

function practice_word_threshold() {
    local n="${consolidation_words:-3}"
    case "$n" in
        ''|*[!0-9]*) n=3 ;;
    esac
    [ "$n" -lt 1 ] && n=1
    printf '%s' "$n"
}

function practice_sentence_sessions() {
    local n="${consolidation_sentences:-2}"
    case "$n" in
        ''|*[!0-9]*) n=2 ;;
    esac
    [ "$n" -lt 1 ] && n=1
    printf '%s' "$n"
}

# Non-destructive schema migration. Existing rows keep their history; the
# active flag separates the current consolidation cycle from archived data.
function practice_schema_ensure() {
    local db="$1"
    [ -n "$db" ] || return 1
    sqlite3 "$db" "pragma busy_timeout=500;
    create table if not exists Practice_evidence (
        note text not null,
        modality text not null,
        easy_sessions integer not null default 0,
        last_result text not null default '',
        last_session text not null default '',
        updated text not null default '',
        active integer not null default 1,
        primary key (note, modality)
    );
    create table if not exists Learned_origin (
        note text primary key,
        origin text not null default 'auto',
        updated text not null default ''
    );
    create table if not exists Learned_pending (
        note text primary key,
        origin text not null default 'manual',
        updated text not null default ''
    );
    create table if not exists Meta (
        key text primary key,
        value text not null default ''
    );" >/dev/null 2>&1 || return 1
    sqlite3 "$db" "pragma busy_timeout=500;
    alter table Practice_evidence add column active integer not null default 1;" >/dev/null 2>&1 || :
    if [ "$(sqlite3 "$db" "select value from Meta where key='origin_backfilled';" 2>/dev/null)" != "1" ]; then
        if sqlite3 "$db" "select name from sqlite_master where type='table' and name='learnt';" 2>/dev/null | grep -qx learnt; then
            sqlite3 "$db" "pragma busy_timeout=500;
            insert or ignore into Learned_origin (note,origin,updated)
            select l.list,
                case when exists (
                    select 1 from Practice_evidence e
                    where e.note=l.list and e.active=1 and e.last_result='easy' and e.easy_sessions>0
                ) then 'auto' else 'manual' end,
                ''
            from learnt l
            where not exists (select 1 from Learned_origin o where o.note=l.list);" >/dev/null 2>&1 || :
        fi
        sqlite3 "$db" "pragma busy_timeout=500;
        insert or replace into Meta (key,value) values ('origin_backfilled','1');" >/dev/null 2>&1 || :
    fi
    return 0
}

function practice_origin_set() {
    local db="$1" note="$2" origin="$3" n d
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    d="$(date +%F)"
    sqlite3 "$db" "pragma busy_timeout=500;
    delete from Learned_pending where note='$n';
    insert or replace into Learned_origin (note,origin,updated) values ('$n','$origin','$d');" >/dev/null 2>&1
}

function practice_origin_get() {
    local db="$1" note="$2" n
    [ -n "$db" ] && [ -f "$db" ] || { printf ''; return; }
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "select origin from Learned_origin where note='$n';" 2>/dev/null
}

function practice_origin_delete() {
    local db="$1" note="$2" n
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "pragma busy_timeout=500;
    delete from Learned_origin where note='$n';
    delete from Learned_pending where note='$n';" >/dev/null 2>&1
}

function practice_pending_set() {
    local db="$1" note="$2" origin="$3" n d
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    d="$(date +%F)"
    sqlite3 "$db" "pragma busy_timeout=500;
    insert or replace into Learned_pending (note,origin,updated) values ('$n','$origin','$d');" >/dev/null 2>&1
}

function practice_pending_get() {
    local db="$1" note="$2" n
    [ -n "$db" ] && [ -f "$db" ] || { printf ''; return; }
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "select origin from Learned_pending where note='$n';" 2>/dev/null
}

function practice_pending_delete() {
    local db="$1" note="$2" n
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "pragma busy_timeout=500; delete from Learned_pending where note='$n';" >/dev/null 2>&1
}

# Consume pending manual/auto intentions exactly once. The caller must ensure
# no other topic session is active (ps_lk absent).
function practice_pending_consume() {
    local db="$1" mode="${2:-manual}" note origin n o in_learning
    [ -n "$db" ] && [ -f "$db" ] || return 0
    if [ "$mode" = "all" ]; then
        local where=""
    else
        local where="where origin='manual'"
    fi
    while IFS=$'\t' read -r note origin; do
        [ -n "$note" ] || continue
        n="$(practice_sql_escape "$note")"
        in_learning="$(sqlite3 "$db" "select count(*) from learning where list='$n';" 2>/dev/null)"
        if [ "${in_learning:-0}" = "1" ]; then
            o="$(practice_sql_escape "$origin")"
            {
                printf 'begin;\n'
                printf "delete from Learned_pending where note='$n';\n"
                printf "insert or ignore into learnt (list) values ('$n');\n"
                printf "delete from learning where list='$n';\n"
                printf "insert or replace into Learned_origin (note,origin,updated) values ('$n','$o','$(date +%F)');\n"
                printf "update Practice_evidence set active=0 where note='$n';\n"
                printf 'commit;\n'
            } | sqlite3 -bail "$db" >/dev/null 2>&1 || :
        else
            sqlite3 "$db" "pragma busy_timeout=500; delete from Learned_pending where note='$n';" >/dev/null 2>&1 || :
        fi
    done < <(sqlite3 -separator $'\t' "$db" "select note,origin from Learned_pending $where;" 2>/dev/null)
}

function practice_evidence_ensure() {
    local db="$1" pdir="${2:-}" marker
    practice_schema_ensure "$db" || return 1
    if [ -n "$pdir" ] && [ -d "$pdir" ]; then
        marker="$pdir/.evidence_backfilled"
        if [ ! -f "$marker" ]; then
            practice_evidence_backfill "$db" "$pdir"
            : > "$marker" 2>/dev/null || :
        fi
    fi
    return 0
}

function practice_evidence_backfill() {
    local db="$1" pdir="$2" m f note n d tmpd data
    [ -n "$db" ] && [ -d "$pdir" ] || return 0
    d="$(date +%F)"
    tmpd="$pdir/.evidence.$$"
    mkdir -p "$tmpd" || return 1
    : > "$tmpd/hard"; : > "$tmpd/learn"
    for m in a b c d e; do
        [ -f "$pdir/$m.3" ] && sort -u "$pdir/$m.3" >> "$tmpd/hard"
        [ -f "$pdir/$m.2" ] && sort -u "$pdir/$m.2" >> "$tmpd/learn"
    done
    sort -u "$tmpd/hard" -o "$tmpd/hard"
    sort -u "$tmpd/learn" -o "$tmpd/learn"
    {
        printf 'begin;\n'
        for m in a b c d e; do
            f="$pdir/$m.1"
            [ -f "$f" ] || continue
            sort -u "$f" > "$tmpd/notes"
            comm -23 "$tmpd/notes" "$tmpd/hard" > "$tmpd/notes_ok"
            comm -23 "$tmpd/notes_ok" "$tmpd/learn" > "$tmpd/notes_ok2"
            while IFS= read -r note; do
                [ -n "$note" ] || continue
                n="$(practice_sql_escape "$note")"
                printf "insert or ignore into Practice_evidence (note,modality,easy_sessions,last_result,last_session,updated,active) values ('%s','%s',1,'easy','backfill','%s',1);\n" "$n" "$m" "$d"
            done < "$tmpd/notes_ok2"
        done
        printf 'commit;\n'
    } | sqlite3 -bail "$db" >/dev/null 2>&1 || :

    : > "$tmpd/word_mods"
    for m in a b c d; do
        [ -f "$pdir/$m.1" ] && awk -v mod="$m" '{print $0"\t"mod}' "$pdir/$m.1" >> "$tmpd/word_mods"
    done
    sort -u "$tmpd/word_mods" -o "$tmpd/word_mods"
    cut -f1 "$tmpd/word_mods" | sort | uniq -c | awk -v t="$(practice_word_threshold)" '$1>=t {print $2}' > "$tmpd/word_ok"
    if [ -f "$pdir/e.1" ]; then sort -u "$pdir/e.1" > "$tmpd/sent_ok"; else : > "$tmpd/sent_ok"; fi
    cat "$tmpd/word_ok" "$tmpd/sent_ok" | sort -u > "$tmpd/legacy_ok"
    comm -23 "$tmpd/legacy_ok" "$tmpd/hard" > "$tmpd/legacy_tmp"
    comm -23 "$tmpd/legacy_tmp" "$tmpd/learn" > "$tmpd/log1_notes"
    practice_log_add "$pdir/log1" "$tmpd/log1_notes"
    for m in a b c d e; do
        [ -f "$pdir/$m.2" ] && practice_log_add "$pdir/log2" "$pdir/$m.2"
        [ -f "$pdir/$m.3" ] && practice_log_add "$pdir/log3" "$pdir/$m.3"
    done
    practice_log_remove "$pdir/log2" "$pdir/log3"
    practice_log_remove "$pdir/log1" "$pdir/log2" "$pdir/log3"
    practice_logs_normalize "$pdir"

    data="$(dirname "$pdir")/data"
    if [ -f "$data" ]; then
        sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' "$data" | sort -u > "$tmpd/data_notes"
        practice_log_intersect "$pdir/log1" "$tmpd/data_notes"
        practice_log_intersect "$pdir/log2" "$tmpd/data_notes"
        practice_log_intersect "$pdir/log3" "$tmpd/data_notes"
        practice_logs_normalize "$pdir"
    fi
    rm -rf "$tmpd"
}

function practice_evidence_sql_easy() {
    local note n mod m sid s d
    note="$1"; mod="$2"; sid="$3"; d="$(date +%F)"
    n="$(practice_sql_escape "$note")"
    m="$(practice_sql_escape "$mod")"
    s="$(practice_sql_escape "$sid")"
    printf "insert into Practice_evidence (note,modality,easy_sessions,last_result,last_session,updated,active) values ('%s','%s',1,'easy','%s','%s',1) on conflict(note,modality) do update set easy_sessions=case when Practice_evidence.active=0 or Practice_evidence.easy_sessions=0 then 1 when Practice_evidence.last_session=excluded.last_session then Practice_evidence.easy_sessions else Practice_evidence.easy_sessions+1 end,last_result='easy',last_session=excluded.last_session,updated=excluded.updated,active=1;\n" "$n" "$m" "$s" "$d"
}

function practice_evidence_sql_learning() {
    local note n mod m sid s d
    note="$1"; mod="$2"; sid="$3"; d="$(date +%F)"
    n="$(practice_sql_escape "$note")"
    m="$(practice_sql_escape "$mod")"
    s="$(practice_sql_escape "$sid")"
    printf "insert into Practice_evidence (note,modality,easy_sessions,last_result,last_session,updated,active) values ('%s','%s',0,'learning','%s','%s',1) on conflict(note,modality) do update set easy_sessions=0,last_result='learning',last_session=excluded.last_session,updated=excluded.updated,active=1;\n" "$n" "$m" "$s" "$d"
}

function practice_evidence_sql_difficult() {
    local note n mod m sid s d
    note="$1"; mod="$2"; sid="$3"; d="$(date +%F)"
    n="$(practice_sql_escape "$note")"
    m="$(practice_sql_escape "$mod")"
    s="$(practice_sql_escape "$sid")"
    printf "insert into Practice_evidence (note,modality,easy_sessions,last_result,last_session,updated,active) values ('%s','%s',0,'difficult','%s','%s',1) on conflict(note,modality) do update set easy_sessions=0,last_result='difficult',last_session=excluded.last_session,updated=excluded.updated,active=1;\n" "$n" "$m" "$s" "$d"
}

function practice_evidence_record() {
    local db="$1" note="$2" mod="$3" res="$4" sid="$5" sql
    [ -n "$db" ] || return 1
    case "$res" in
        easy) sql="$(practice_evidence_sql_easy "$note" "$mod" "$sid")" ;;
        learning) sql="$(practice_evidence_sql_learning "$note" "$mod" "$sid")" ;;
        difficult) sql="$(practice_evidence_sql_difficult "$note" "$mod" "$sid")" ;;
        *) return 1 ;;
    esac
    sqlite3 "$db" "pragma busy_timeout=500; $sql" >/dev/null 2>&1
}

function practice_evidence_archive() {
    local db="$1" note="$2" n
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "pragma busy_timeout=500; update Practice_evidence set active=0 where note='$n';" >/dev/null 2>&1
}

function practice_evidence_invalidate() {
    local db="$1" note="$2" n
    [ -n "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    sqlite3 "$db" "pragma busy_timeout=500; delete from Practice_evidence where note='$n';" >/dev/null 2>&1
}

function practice_evidence_eligible() {
    local db="$1" note="$2" type="$3" thr="${4:-}" n cnt sess
    [ -n "$db" ] && [ -f "$db" ] || return 1
    n="$(practice_sql_escape "$note")"
    if [ "$type" = "2" ]; then
        sess="$(sqlite3 "$db" "select coalesce(max(easy_sessions),0) from Practice_evidence where note='$n' and modality='e' and active=1 and last_result='easy';" 2>/dev/null)"
        [ "${sess:-0}" -ge "$(practice_sentence_sessions)" ]
    else
        [ -n "$thr" ] || thr="$(practice_word_threshold)"
        cnt="$(sqlite3 "$db" "select count(*) from Practice_evidence where note='$n' and active=1 and easy_sessions>0 and last_result='easy';" 2>/dev/null)"
        [ "${cnt:-0}" -ge "$thr" ]
    fi
}

function practice_evidence_easy_count() {
    local db="$1" mod="$2" m n
    [ -n "$db" ] && [ -f "$db" ] || { printf '0'; return; }
    m="$(practice_sql_escape "$mod")"
    n="$(sqlite3 "$db" "select count(*) from Practice_evidence where modality='$m' and active=1 and easy_sessions>0 and last_result='easy';" 2>/dev/null)"
    printf '%s' "${n:-0}"
}

function practice_session_new() {
    local pdir="$1" practice="$2"
    PD_SESSION_ID="$(date +%s%N)-${practice}"
    PD_SESSION_PRACTICE="$practice"
    export PD_SESSION_ID PD_SESSION_PRACTICE
    [ -d "$pdir" ] && : > "$pdir/.session_results"
}

function practice_mark_easy() {
    local note="$1" mod="${2:-${active_practice:-}}" pdir="${dir_practice:-$PWD}"
    [ -n "$note" ] || return 0
    [ -n "$mod" ] || return 0
    [ -n "${PD_SESSION_ID:-}" ] || practice_session_new "$pdir" "$mod"
    printf '%s\t%s\t%s\n' "$note" "$mod" "$PD_SESSION_ID" >> "$pdir/.session_results"
}

function practice_log_count() {
    local f="$1"
    [ -f "$f" ] || { printf '0'; return; }
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$f" 2>/dev/null | sed '/^[[:space:]]*$/d' | sort -u | wc -l | tr -d ' '
}

function practice_logs_normalize() {
    local pdir="$1" f
    [ -d "$pdir" ] || return 0
    for f in log1 log2 log3; do
        [ -f "$pdir/$f" ] || : > "$pdir/$f"
    done
    for f in log1 log2 log3; do
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$pdir/$f" | sed '/^[[:space:]]*$/d' | sort -u > "$pdir/.$f.tmp"
    done
    comm -23 "$pdir/.log1.tmp" "$pdir/.log2.tmp" > "$pdir/.n1.tmp"
    comm -23 "$pdir/.n1.tmp" "$pdir/.log3.tmp" > "$pdir/.log1.new"
    comm -23 "$pdir/.log2.tmp" "$pdir/.log3.tmp" > "$pdir/.log2.new"
    cp "$pdir/.log3.tmp" "$pdir/.log3.new"
    for f in log1 log2 log3; do
        if cmp -s "$pdir/$f" "$pdir/.$f.new"; then
            rm -f "$pdir/.$f.new"
        else
            mv -f "$pdir/.$f.new" "$pdir/$f"
        fi
    done
    rm -f "$pdir"/.log1.tmp "$pdir"/.log2.tmp "$pdir"/.log3.tmp "$pdir"/.n1.tmp
}

function practice_learnt_count() {
    local db="$1" n
    [ -n "$db" ] && [ -f "$db" ] || { printf '0'; return; }
    n="$(sqlite3 "$db" "select count(distinct list) from learnt where list is not null and trim(list) <> '';" 2>/dev/null)"
    printf '%s' "${n:-0}"
}

function practice_log_add() {
    local log="$1" add="$2"
    [ -s "$add" ] || return 0
    { cat "$log" 2>/dev/null; cat "$add"; } | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed '/^[[:space:]]*$/d' | sort -u > "$log.tmp" && mv -f "$log.tmp" "$log"
}

function practice_log_remove() {
    local log="$1"; shift
    local args=() f
    [ -f "$log" ] || return 0
    for f in "$@"; do
        [ -s "$f" ] && args+=(-f "$f")
    done
    [ ${#args[@]} -gt 0 ] || return 0
    grep -Fxv "${args[@]}" "$log" > "$log.tmp" 2>/dev/null || :
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$log.tmp" | sed '/^[[:space:]]*$/d' | sort -u > "$log" 2>/dev/null || :
    rm -f "$log.tmp"
}

function practice_log_intersect() {
    local log="$1" notes="$2"
    [ -f "$log" ] || return 0
    if [ ! -f "$notes" ]; then
        : > "$log"
        return 0
    fi
    comm -12 <(sort -u "$log") "$notes" > "$log.tmp"
    if [ -f "$log" ] && cmp -s "$log" "$log.tmp"; then
        rm -f "$log.tmp"
    else
        mv -f "$log.tmp" "$log"
    fi
}

function practice_update_logs() {
    local pdir="$1" data="$2" db="$3" sid="$4"
    local log1="$pdir/log1" log2="$pdir/log2" log3="$pdir/log3"
    local tmpd="$pdir/.evidence.$$" m note n mname s line
    local mode="new"
    [ -n "$db" ] && practice_schema_ensure "$db" >/dev/null 2>&1 || :
    mkdir -p "$tmpd" || return 1
    : > "$tmpd/hard"; : > "$tmpd/learn"; : > "$tmpd/easy_all"
    : > "$tmpd/easy_rows"; : > "$tmpd/evidence.sql"
    for m in a b c d e; do
        [ -f "$pdir/$m.3" ] && sort -u "$pdir/$m.3" >> "$tmpd/hard"
        [ -f "$pdir/$m.2" ] && sort -u "$pdir/$m.2" >> "$tmpd/learn"
    done
    sort -u "$tmpd/hard" -o "$tmpd/hard"
    sort -u "$tmpd/learn" -o "$tmpd/learn"
    comm -23 "$tmpd/learn" "$tmpd/hard" > "$tmpd/learn_only"

    if [ -f "$pdir/.session_results" ]; then
        cp -f "$pdir/.session_results" "$tmpd/easy_rows"
        awk -F '\t' 'NF>=3 {print $1}' "$tmpd/easy_rows" | sort -u > "$tmpd/easy_all"
    else
        mode="legacy"
        for m in a b c d e; do
            [ -f "$pdir/$m.1" ] || continue
            while IFS= read -r note; do
                [ -n "$note" ] || continue
                printf '%s\t%s\tlegacy\n' "$note" "$m" >> "$tmpd/easy_rows"
                printf '%s\n' "$note" >> "$tmpd/easy_all"
            done < <(sort -u "$pdir/$m.1")
        done
        sort -u "$tmpd/easy_all" -o "$tmpd/easy_all"
    fi

    if [ "$mode" = "legacy" ]; then
        awk -F '\t' '$2 != "e" {print $1"\t"$2}' "$tmpd/easy_rows" | sort -u > "$tmpd/word_mods"
        cut -f1 "$tmpd/word_mods" | sort | uniq -c | awk -v t="$(practice_word_threshold)" '$1>=t {print $2}' > "$tmpd/word_ok"
        if [ -f "$pdir/e.1" ]; then sort -u "$pdir/e.1" > "$tmpd/sent_ok"; else : > "$tmpd/sent_ok"; fi
        cat "$tmpd/word_ok" "$tmpd/sent_ok" | sort -u > "$tmpd/legacy_ok"
        comm -23 "$tmpd/legacy_ok" "$tmpd/hard" > "$tmpd/easy_class_tmp"
        comm -23 "$tmpd/easy_class_tmp" "$tmpd/learn_only" > "$tmpd/easy_class"
    else
        comm -23 "$tmpd/easy_all" "$tmpd/hard" > "$tmpd/easy_class_tmp"
        comm -23 "$tmpd/easy_class_tmp" "$tmpd/learn_only" > "$tmpd/easy_class"
    fi
    comm -23 "$tmpd/easy_all" "$tmpd/hard" > "$tmpd/easy_evidence"

    if [ -n "$db" ] && [ -f "$db" ]; then
        awk -F '\t' 'FILENAME==ARGV[1]{hard[$0]=1; next} !($1 in hard)' "$tmpd/hard" "$tmpd/easy_rows" > "$tmpd/easy_rows_ok"
        while IFS=$'\t' read -r note mname s; do
            [ -n "$note" ] || continue
            [ -n "$mname" ] || continue
            [ -n "$s" ] || s="$sid"
            if [ "$mode" = "legacy" ]; then
                n="$(practice_sql_escape "$note")"
                mname="$(practice_sql_escape "$mname")"
                s="$(practice_sql_escape "$s")"
                printf "insert or ignore into Practice_evidence (note,modality,easy_sessions,last_result,last_session,updated,active) values ('%s','%s',1,'easy','%s','%s',1);\n" "$n" "$mname" "$s" "$(date +%F)" >> "$tmpd/evidence.sql"
            else
                practice_evidence_sql_easy "$note" "$mname" "$s" >> "$tmpd/evidence.sql"
            fi
        done < "$tmpd/easy_rows_ok"
        for m in a b c d e; do
            [ -f "$pdir/$m.2" ] || continue
            while IFS= read -r note; do
                [ -n "$note" ] || continue
                grep -Fxq -- "$note" "$tmpd/hard" && continue
                practice_evidence_sql_learning "$note" "$m" "$sid" >> "$tmpd/evidence.sql"
            done < <(sort -u "$pdir/$m.2")
        done
        while IFS= read -r note; do
            [ -n "$note" ] || continue
            n="$(practice_sql_escape "$note")"
            printf "update Practice_evidence set active=0 where note='%s';\n" "$n" >> "$tmpd/evidence.sql"
        done < "$tmpd/hard"
        for m in a b c d e; do
            [ -f "$pdir/$m.3" ] || continue
            while IFS= read -r note; do
                [ -n "$note" ] || continue
                practice_evidence_sql_difficult "$note" "$m" "$sid" >> "$tmpd/evidence.sql"
            done < <(sort -u "$pdir/$m.3")
        done
        if [ -s "$tmpd/evidence.sql" ]; then
            { printf 'begin;\n'; cat "$tmpd/evidence.sql"; printf 'commit;\n'; } | sqlite3 -bail "$db" >/dev/null 2>&1 || :
        fi
    fi

    : >> "$log1"; : >> "$log2"; : >> "$log3"
    practice_log_remove "$log1" "$log2" "$log3"
    practice_log_remove "$log2" "$log3"
    practice_log_remove "$log1" "$tmpd/learn_only" "$tmpd/hard"
    practice_log_remove "$log2" "$tmpd/easy_class" "$tmpd/hard"
    practice_log_remove "$log3" "$tmpd/easy_class" "$tmpd/learn_only"
    practice_log_add "$log1" "$tmpd/easy_class"
    practice_log_add "$log2" "$tmpd/learn_only"
    practice_log_add "$log3" "$tmpd/hard"

    if [ -f "$data" ]; then
        sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' "$data" | sort -u > "$tmpd/notes"
        practice_log_intersect "$log1" "$tmpd/notes"
        practice_log_intersect "$log2" "$tmpd/notes"
        practice_log_intersect "$log3" "$tmpd/notes"
    fi
    practice_logs_normalize "$pdir"

    rm -rf "$tmpd"
    return 0
}
