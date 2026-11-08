#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
[ -r "$DS/practice/consolidation.sh" ] && source "$DS/practice/consolidation.sh"
echo -e "\n--- checking lists..."

while read -r tpc; do
    dir="$DM_tl/${tpc}/.conf"; unset stts tpc
    stts=$(sed -n 1p "${dir}/stts")
    if [ ${stts} != 0 ]; then
        mv -f "${dir}/stts"  "${dir}/stts.bk"; echo 0 > "${dir}/stts"
    fi
done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime +80 -type d \
-not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')

log="$DC_s/log"
[ -f "$log" ] || touch "$log"
items=$(mktemp "$DT/w1.XXXX")
# Dependencias del auto-marcado histórico (Etapa 6, Alternativa A): fuente
# exclusiva = master log $DC_s/log, escrito por practice/strt.sh::_snap
# (w1/s1 con dedup intra-instantánea y append idempotente). Conteo por
# apariciones en instantáneas distintas: ≥3 (palabras) / ≥1 (oraciones),
# umbral sin cambios. Dedup por línea (instantánea) antes de contar y
# extracción completa de notas multi-palabra (sin truncar en el 2.º campo).
words=$(grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" \
|awk -F'|' '{delete u; for (i=1; i<=NF; i++) if ($i != "" && !u[$i]++) print $i}' \
|sort |uniq -c |sort -n -r |sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s1.).*(?=\.s1)' "${log}" \
|awk -F'|' '{delete u; for (i=1; i<=NF; i++) if ($i != "" && !u[$i]++) print $i}' \
|sort |uniq -c |sort -n -r |sed 's/ \+/ /g')
topics="$(cdb "${shrdb}" 5 topics|head -n30)"
dir="$DM_tl/"

for n in {1..100}; do
    if [[ $(sed -n ${n}p <<<"${words}" |awk '{print ($1)}') -ge 3 ]]; then
        fwk=$(sed -n ${n}p <<<"${words}" |sed -E 's/^ +[0-9]+ //')
        [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
    fi
    if [[ $(sed -n ${n}p <<<"${sentences}" |awk '{print ($1)}') -ge 1 ]]; then
        fwk=$(sed -n ${n}p <<<"${sentences}" |sed -E 's/^ +[0-9]+ //')
        [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
    fi
done

if grep '^$' "${items}"; then
    sed -i '/^$/d' "${items}"
fi

f_lock 1 "$DT/co_lk"

lstp="${items}"

declare -A lstp_set=()

while IFS= read -r value; do
    [ -n "$value" ] && lstp_set["$value"]=1
done < "$lstp"

export dir topics lstp shrdb

cleanups "$DM_tl/.share/index"

# Rebuild shared practice lists and topic indexes.
days_ago=$(date -d '10 days ago' +%s)
word_thr="$(practice_word_threshold)"
sent_thr="$(practice_sentence_sessions)"

{
    printf 'BEGIN TRANSACTION;\n'
    printf 'DELETE FROM T5;\n'
    printf 'DELETE FROM T6;\n'
    printf 'COMMIT;\n'
} | sqlite3 -bail "$shrdb"

while IFS= read -r tpc; do
    [ -n "$tpc" ] || continue

    cnfg_dir="$dir$tpc/.conf"
    tpcdb="$cnfg_dir/tpc"

    # A damaged/incomplete topic must not abort the whole update.
    if [ ! -f "$tpcdb" ] ||
       [ ! -f "$cnfg_dir/stts" ] ||
       [ ! -f "$cnfg_dir/data" ]; then
        echo "err -> $tpc"
        continue
    fi

    #
    # Read topic state.
    #
    stts=$(<"$cnfg_dir/stts")

    #
    # Load SQLite lists into associative arrays.
    # This avoids executing sqlite3 once per note.
    #
    declare -A learn_set=()
    declare -A marks_set=()

    while IFS= read -r value; do
        [ -n "$value" ] && learn_set["$value"]=1
    done < <(sqlite3 "$tpcdb" 'SELECT list FROM learning;')

    while IFS= read -r value; do
        [ -n "$value" ] && marks_set["$value"]=1
    done < <(sqlite3 "$tpcdb" 'SELECT list FROM marks;')

    practice_evidence_ensure "$tpcdb" "$cnfg_dir/practice" 2>/dev/null || :

    #
    # Determine whether the topic has practice activity.
    #
    log1_file="$cnfg_dir/practice/log1"
    log2_file="$cnfg_dir/practice/log2"
    log3_file="$cnfg_dir/practice/log3"
    [ -f "$log1_file" ] || : > "$log1_file"
    [ -f "$log2_file" ] || : > "$log2_file"
    [ -f "$log3_file" ] || : > "$log3_file"

    log1_mtime=$(stat -c %Y "$log1_file")
    log2_mtime=$(stat -c %Y "$log2_file")
    log3_mtime=$(stat -c %Y "$log3_file")

    l1m=false
    l2m=false
    l3m=false

    [ "$log1_mtime" -lt "$days_ago" ] && l1m=true
    [ "$log2_mtime" -lt "$days_ago" ] && l2m=true
    [ "$log3_mtime" -lt "$days_ago" ] && l3m=true

    practice_logs_normalize "$cnfg_dir/practice"

    #
    # The original Python used stripped, non-empty log entries.
    #
    log1=$(sed '/^[[:space:]]*$/d;s/^[[:space:]]*//;s/[[:space:]]*$//' \
        "$log1_file")

    log2=$(sed '/^[[:space:]]*$/d;s/^[[:space:]]*//;s/[[:space:]]*$//' \
        "$log2_file")

    log3=$(sed '/^[[:space:]]*$/d;s/^[[:space:]]*//;s/[[:space:]]*$//' \
        "$log3_file")

    #
    # Load practice logs into associative arrays too.
    #
    declare -A log1_set=()
    declare -A log2_set=()
    declare -A log3_set=()

    while IFS= read -r value; do
        [ -n "$value" ] && log1_set["$value"]=1
    done <<< "$log1"

    while IFS= read -r value; do
        [ -n "$value" ] && log2_set["$value"]=1
    done <<< "$log2"

    while IFS= read -r value; do
        [ -n "$value" ] && log3_set["$value"]=1
    done <<< "$log3"

    declare -A ev_mod_set=()
    declare -A ev_e_set=()
    declare -A origin_set=()
    declare -A pending_set=()
    declare -A manual_set=()

    while IFS=$'\t' read -r value mods easy; do
        [ -n "$value" ] || continue
        ev_mod_set["$value"]="$mods"
        ev_e_set["$value"]="$easy"
    done < <(sqlite3 -separator $'\t' "$tpcdb" \
        "select note,count(distinct modality),coalesce(max(case when modality='e' then easy_sessions end),0) from Practice_evidence where active=1 and easy_sessions>0 and last_result='easy' group by note;" 2>/dev/null)

    while IFS=$'\t' read -r value origin; do
        [ -n "$value" ] && origin_set["$value"]="${origin:-manual}"
    done < <(sqlite3 -separator $'\t' "$tpcdb" \
        "select note,origin from Learned_origin;" 2>/dev/null)

    while IFS=$'\t' read -r value origin; do
        [ -n "$value" ] && pending_set["$value"]="${origin:-manual}"
    done < <(sqlite3 -separator $'\t' "$tpcdb" \
        "select note,origin from Learned_pending;" 2>/dev/null)

    for value in "${!origin_set[@]}" "${!pending_set[@]}"; do
        if [ "${origin_set[$value]:-}" = "manual" ] || [ "${pending_set[$value]:-}" = "manual" ]; then
            manual_set["$value"]=1
        fi
    done

    declare -A eligible_set=()

    while IFS= read -r raw_item || [ -n "$raw_item" ]; do
        [ -n "$raw_item" ] || continue
        item=$(sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' <<< "$raw_item")
        [ -n "$item" ] || continue
        [ "${learn_set[$item]+_}" ] || continue

        item_type=$(sed -n 's/.*type{\([^}]*\)}.*/\1/p' <<< "$raw_item")
        eligible=false
        if [ "$item_type" = "2" ]; then
            if [ "${ev_e_set[$item]:-0}" -ge "$sent_thr" ]; then eligible=true; fi
        else
            if [ "${ev_mod_set[$item]:-0}" -ge "$word_thr" ]; then eligible=true; fi
        fi
        if [ "$eligible" = true ] &&
           [ "${log1_set[$item]+_}" ] &&
           [ -z "${log2_set[$item]+_}" ] &&
           [ -z "${log3_set[$item]+_}" ]; then
            eligible_set["$item"]=1
        fi
    done < "$cnfg_dir/data"

    #
    # Determine whether the topic should be processed.
    #
    cont=false

    case "$stts" in
        3|4|7|8|9|10)
            cont=true
            ;;
    esac

    [ -d "$cnfg_dir/practice" ] || cont=false

    #
    # Topics in states 5/6 may need to return to practice.
    #
    if [ "$stts" = "5" ] || [ "$stts" = "6" ]; then

        if [ -n "$log3" ] || [ -n "$log2" ]; then

            tpc_sql=${tpc//\'/\'\'}

            sqlite3 -bail "$shrdb" \
                "INSERT INTO T6 (list) VALUES ('$tpc_sql');"

            echo "- back to practice: $tpc"

        elif [ "$l3m" = true ] &&
             [ "$l2m" = true ] &&
             [ "$l1m" = true ]; then

            tpc_sql=${tpc//\'/\'\'}

            sqlite3 -bail "$shrdb" \
                "INSERT INTO T5 (list) VALUES ('$tpc_sql');"

            echo "- to practice: $tpc"
        fi
    fi

    #
    # Rebuild topic index.
    #
    if [ "$cont" = true ]; then

        index_file="$cnfg_dir/index"
        data_file="$cnfg_dir/data"

        # Build a temporary index first.
        # This prevents a partial index if something goes wrong.
        index_tmp=$(mktemp "$cnfg_dir/.index.XXXXXX") || {
            echo "err -> $tpc"
            unset learn_set marks_set log1_set log2_set log3_set
            unset eligible_set ev_mod_set ev_e_set
            continue
        }

        index_ok=true

        while IFS= read -r raw_item || [ -n "$raw_item" ]; do

            [ -n "$raw_item" ] || continue

            #
            # The data format stores trgt{} and srce{} in the same record.
            #
            item=$(sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' <<< "$raw_item")
            [ -n "$item" ] || continue

            #
            # Only learning items belong in the index.
            #
            [ "${learn_set[$item]+_}" ] || continue

            srce=$(sed -n 's/.*srce{\([^}]*\)}.*/\1/p' <<< "$raw_item")

            #
            # Marked notes are displayed in bold.
            #
            if [ "${marks_set[$item]+_}" ]; then
                display_item="<b><big>${item}</big></b>"
            else
                display_item="$item"
            fi

            #
            # Marking: manual intent has priority; automatic marking uses
            # only active evidence and requires log1 (not log2/log3).
            #
            chk="FALSE"
            if [ "${manual_set[$item]+_}" ]; then
                chk="TRUE"
            elif [ "${eligible_set[$item]+_}" ]; then
                chk="TRUE"
                if [ -z "${origin_set[$item]:-}" ] && [ -z "${pending_set[$item]:-}" ]; then
                    practice_pending_set "$tpcdb" "$item" auto >/dev/null 2>&1 || :
                fi
            fi

            #
            # Classification priority: log3 -> log2 -> log1.
            # log1: verde solo cuando la nota cumple el criterio para Learned.
            #
            if [ "${log3_set[$item]+_}" ]; then

                printf '<span color='\''#AE3259'\''>%s</span>\n%s\n%s\n' \
                    "$display_item" "$chk" "$srce" >> "$index_tmp"

            elif [ "${log2_set[$item]+_}" ]; then

                printf '<span color='\''#C15F27'\''>%s</span>\n%s\n%s\n' \
                    "$display_item" "$chk" "$srce" >> "$index_tmp"

            elif [ "${log1_set[$item]+_}" ]; then

                echo "$chk -> $item"

                if [ "${eligible_set[$item]+_}" ]; then
                    printf '<span color='\''#4C8C12'\''>%s</span>\n%s\n%s\n' \
                        "$display_item" "$chk" "$srce" >> "$index_tmp"
                else
                    printf '%s\n%s\n%s\n' \
                        "$display_item" "$chk" "$srce" >> "$index_tmp"
                fi

            else

                printf '%s\n%s\n%s\n' \
                    "$display_item" "$chk" "$srce" >> "$index_tmp"
            fi

        done < "$data_file"

        #
        # Only replace the real index after successful generation.
        #
        if [ "$index_ok" = true ]; then
            mv -f -- "$index_tmp" "$index_file"
        else
            rm -f -- "$index_tmp"
        fi
    fi

    #
    # Promoción a aprendido (Etapa 6): fuera del bloque cont — la
    # promoción aplica a stts 1/2/5/6, que no reconstruyen índice, y
    # antes estaba anidada en cont (3|4|7-10) junto al case 1|2|5|6:
    # intersección vacía, mark_as_learned_ok era código muerto.
    # chk=TRUE ⟺ evidencia suficiente ∧ en log1 ∧ ¬log2 ∧ ¬log3
    # (equivale al chk mostrado en el índice). Vacuidad preservada:
    # learn_count==len_auto ∧ item_count>0.
    case "$stts" in
        1|2|5|6)
            len_auto=0
            for item in "${!learn_set[@]}"; do
                [ "${manual_set[$item]+_}" ] && continue
                if [ "${eligible_set[$item]+_}" ]; then
                    len_auto=$((len_auto + 1))
                fi
            done

            learn_count=${#learn_set[@]}
            item_count=$(wc -l < "$cnfg_dir/data")

            if [ "$learn_count" -eq "$len_auto" ] &&
               [ "$item_count" -gt 0 ]; then

                "$DS/mngr.sh" mark_as_learned_ok "$tpc" &

                echo "mark_as_learnt -> $tpc"
            fi
            ;;
    esac

    unset learn_set
    unset marks_set
    unset log1_set
    unset log2_set
    unset log3_set
    unset eligible_set
    unset ev_mod_set
    unset ev_e_set
    unset origin_set
    unset pending_set
    unset manual_set

    if [ ! -e "$DT/ps_lk" ] && [ -n "$tpcdb" ] && [ -f "$tpcdb" ]; then
        practice_pending_consume "$tpcdb" manual >/dev/null 2>&1 || :
    fi

done <<< "$topics"

unset lstp_set

echo -e "\tlists ok"

# Etapa 6: sin rotación por fecha del master. _snap apendea de forma
# idempotente y main.sh acota el tamaño (tail -2000 al superar 100000 B);
# un rm aquí borraría el historial que alimenta el auto-marcado.
touch "$log"
"$DS/mngr.sh" mkmn 1 &
cleanups "$items"
f_lock 3 "$DT/co_lk"

exit
