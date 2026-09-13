#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n--- checking lists..."

while read -r tpc; do
    dir="$DM_tl/${tpc}/.conf"; unset stts tpc
    stts=$(sed -n 1p "${dir}/stts")
    if [ ${stts} != 0 ]; then
        mv -f "${dir}/stts"  "${dir}/stts.bk"; echo 0 > "${dir}/stts"
    fi
done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime +80 -type d \
-not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')

[ ! -f "$DC_s/log" ] && exit 1 || log="$DC_s/log"
items=$(mktemp "$DT/w1.XXXX")
words=$(grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s1.).*(?=\.s1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
topics="$(cdb "${shrdb}" 5 topics|head -n30)"
dir="$DM_tl/"

for n in {1..100}; do
    if [[ $(sed -n ${n}p <<<"${words}" |awk '{print ($1)}') -ge 3 ]]; then
        fwk=$(sed -n ${n}p <<<"${words}" |awk '{print ($2)}')
        [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
    fi
    if [[ $(sed -n ${n}p <<<"${sentences}" |awk '{print ($1)}') -ge 1 ]]; then
        fwk=$(sed -n ${n}p <<<"${sentences}" |cut -c 4-)
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
       [ ! -f "$cnfg_dir/data" ] ||
       [ ! -f "$cnfg_dir/practice/log1" ] ||
       [ ! -f "$cnfg_dir/practice/log2" ] ||
       [ ! -f "$cnfg_dir/practice/log3" ]; then
        echo "err -> $tpc"
        continue
    fi

    #
    # Read topic state.
    #
    stts=$(<"$cnfg_dir/stts")

    auto_mrk=$(sqlite3 "$tpcdb" \
        'SELECT acheck FROM config LIMIT 1;')

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

    #
    # Determine whether the topic has practice activity.
    #
    log1_file="$cnfg_dir/practice/log1"
    log2_file="$cnfg_dir/practice/log2"
    log3_file="$cnfg_dir/practice/log3"

    log1_mtime=$(stat -c %Y "$log1_file")
    log2_mtime=$(stat -c %Y "$log2_file")
    log3_mtime=$(stat -c %Y "$log3_file")

    l1m=false
    l2m=false
    l3m=false

    [ "$log1_mtime" -lt "$days_ago" ] && l1m=true
    [ "$log2_mtime" -lt "$days_ago" ] && l2m=true
    [ "$log3_mtime" -lt "$days_ago" ] && l3m=true

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
    len_learnt=0

    if [ "$cont" = true ]; then

        index_file="$cnfg_dir/index"
        data_file="$cnfg_dir/data"

        # Build a temporary index first.
        # This prevents a partial index if something goes wrong.
        index_tmp=$(mktemp "$cnfg_dir/.index.XXXXXX") || {
            echo "err -> $tpc"
            unset learn_set marks_set log1_set log2_set log3_set
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
            # Automatic marking.
            #
            if [ "$auto_mrk" = "TRUE" ] &&
               [ "${lstp_set[$item]+_}" ]; then
                chk="TRUE"
            else
                chk="FALSE"
            fi

            #
            # Practice status has priority:
            # log3 -> log2 -> log1 -> normal.
            #
            if [ "${log3_set[$item]+_}" ]; then

                printf '<span color='\''#AE3259'\''>%s</span>\nFALSE\n%s\n' \
                    "$display_item" "$srce" >> "$index_tmp"

            elif [ "${log2_set[$item]+_}" ]; then

                printf '<span color='\''#C15F27'\''>%s</span>\nFALSE\n%s\n' \
                    "$display_item" "$srce" >> "$index_tmp"

            elif [ "${log1_set[$item]+_}" ]; then

                echo "$chk -> $item"

                printf '%s\n%s\n%s\n' \
                    "$display_item" "$chk" "$srce" >> "$index_tmp"

            else

                printf '%s\nFALSE\n%s\n' \
                    "$display_item" "$srce" >> "$index_tmp"
            fi

            if [ "$chk" = "TRUE" ]; then
                len_learnt=$((len_learnt + 1))
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

        #
        # If every learning note is automatically marked,
        # promote the topic to learned.
        #
        case "$stts" in
            1|2|5|6)

                learn_count=${#learn_set[@]}
                item_count=$(wc -l < "$data_file")

                if [ "$learn_count" -eq "$len_learnt" ] &&
                   [ "$item_count" -gt 0 ]; then

                    "$DS/mngr.sh" mark_as_learned_ok "$tpc" &

                    echo "mark_as_learnt -> $tpc"
                fi
                ;;
        esac
    fi

    unset learn_set
    unset marks_set
    unset log1_set
    unset log2_set
    unset log3_set

done <<< "$topics"

unset lstp_set

echo -e "\tlists ok"

[ $(date +%d) = 1 -o $(date +%d) = 14 ] && rm "$log"; touch "$log"
"$DS/mngr.sh" mkmn 1 &
cleanups "$items"
f_lock 3 "$DT/co_lk"

exit
