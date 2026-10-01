#!/bin/bash
# -*- ENCODING: UTF-8 -*-



if [ -z "${tlng}" ] || [ -z "${slng}" ]; then
        msg "$(gettext "Please check the language settings in the preferences dialog.")
$(gettext "If necessary, close the program from the panel icon and start it again.")\n" \
    dialog-warning "$(gettext "Language settings")"
    exit 1
fi

if [ -n "${DS:-}" ] && [ -r "$DS/gui/add.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/add.sh"
fi

function check_s() {
    gui_add_select_topic "$@"
}

function mksure() {
    e=0; shopt -s extglob
    for str in "${@}"; do
    if [ -z "${str##+([[:space:]])}" ]; then
    e=1; break; fi
    if grep -o "nullnull" <<< "${str}" >/dev/null 2>&1; then
    msg "$(gettext "Something Unexpected Happened.\nPlease add manually the note"): \"$str\"\n" \
    info "$(gettext "Information")"
    e=1; break; fi
    done
    return $e
}

# Pushes a row to the open topic dialog's live list (if any).
# The dialog (notebook_1 in ifs/extensions/main/items_list.sh) feeds its
# yad --list --listen from $DT/list_<md5(tpc)>.fifo; the fifo exists only
# while that topic's dialog is open, and only for the open topic, so notes
# added to other topics are never pushed. The O_RDWR open never blocks even
# with no reader (crash residue): a 4-line row always fits in the pipe buffer.
function live_list_push() {
    local _trgt="$1" _srce="$2" _lf _pos
    _lf="$DT/list_$(printf '%s' "${tpe}" | md5sum | cut -c1-12).fifo"
    [ -p "$_lf" ] || return 0
    _pos=$(tpc_db 5 learning | grep -Fxon -m1 -e "${_trgt}" | cut -d: -f1)
    [ -n "$_pos" ] || return 0
    exec 9<>"$_lf" 2>/dev/null || return 0
    printf '%s\n%s\n%s\n%s\n' "${_trgt}" "${_pos}" "FALSE" "${_srce}" >&9 2>/dev/null || true
    exec 9>&- 2>/dev/null || true
}

function index() {
	
	lockfile="$DT/i_lk"
	exec 9>"$lockfile"
	flock -x 9

    if [[ ${1} = edit ]]; then
        DC_tlt="$DM_tl/${2}/.conf"
        sust(){
            if grep -Fxo "${trgt}" "${1}" >/dev/null 2>&1; then
                sed -i "s|^${trgt}$|${trgt_mod}|" "${1}"
            fi
        }
        tas=('learning' 'learnt' 'words' 'sentences' 'marks')
        for ta in "${tas[@]}"; do
            tpc_db 7 "$ta" "${trgt_mod}" "${trgt}"
        done

        if [ -d "${DC_tlt}/practice" ]; then
            cd ~ && cd "${DC_tlt}/practice"
            while read -r file_pr; do
                sust "${file_pr}"
            done < <(ls ./*)
            cd ~
        fi
    else
        DC_tlt="${DM_tl}/${tpe}/.conf"; type=${1}
        if [ ! -n "${trgt}" ]; then return 1; fi
        if [ ! -d "${DC_tlt}" ]; then return 1; fi
        #
        if [ ! -z "${trgt}" ]; then
            if ! grep -Fo "trgt{${trgt}}" \
            < "${DC_tlt}/data" >/dev/null 2>&1; then
				type="$1"
                if [[ ${type} = 1 ]]; then
                    unset wrds grmr link defn
                    tpc_db 2 learning list "${trgt}"
                    tpc_db 2 words list "${trgt}"
                    data_insert "${trgt}" "${srce}" "${exmp}" "${defn}" "${note}" \
                    "${wrds}" "${grmr}" "${tags}" "${mark}" "${refr}" \
                    "${imag}" "${link}" "${cdid}" "${type}"
                    echo -e "${trgt}\nFALSE\n${srce}" >> "${DC_tlt}/index"
                    live_list_push "${trgt}" "${srce}"
                    eval newline="$(sed -n 2p $DS/default/vars)"
                    echo "${newline}" >> "${DC_tlt}/data"
                
                elif [[ ${type} = 2 ]]; then
                    unset defn
                    tpc_db 2 learning list "${trgt}"
                    tpc_db 2 sentences list "${trgt}"
                    data_insert "${trgt}" "${srce}" "${exmp}" "${defn}" "${note}" \
                    "${wrds}" "${grmr}" "${tags}" "${mark}" "${refr}" \
                    "${imag}" "${link}" "${cdid}" "${type}"
                    echo -e "${trgt}\nFALSE\n${srce}" >> "${DC_tlt}/index"
                    live_list_push "${trgt}" "${srce}"
                    eval newline="$(sed -n 2p $DS/default/vars)"
                   echo "${newline}" >> "${DC_tlt}/data"
                fi
            fi
        fi
    fi
	flock -u 9
}

load_grammar_sets() {

    declare -gA PRONOUNS=()
    declare -gA NOUNS_ADJ=()
    declare -gA NOUNS_VERBS=()
    declare -gA CONJUNCTIONS=()
    declare -gA PREPOSITIONS=()
    declare -gA ADVERBS=()
    declare -gA ADJECTIVES=()
    declare -gA VERBS=()

    while IFS=$'\t' read -r category word; do
        [[ -z "$word" ]] && continue

        case "$category" in
            pronouns)
                PRONOUNS["$word"]=1 ;;
            nouns_adjetives)
                NOUNS_ADJ["$word"]=1 ;;
            nouns_verbs)
                NOUNS_VERBS["$word"]=1 ;;
            conjunctions)
                CONJUNCTIONS["$word"]=1 ;;
            prepositions)
                PREPOSITIONS["$word"]=1 ;;
            adverbs)
                ADVERBS["$word"]=1 ;;
            adjetives)
                ADJECTIVES["$word"]=1 ;;
            verbs)
                VERBS["$word"]=1 ;;
        esac

    done < <(
        sqlite3 -separator $'\t' "$db" '
            SELECT "pronouns", items FROM pronouns
            UNION ALL
            SELECT "nouns_adjetives", items FROM nouns_adjetives
            UNION ALL
            SELECT "nouns_verbs", items FROM nouns_verbs
            UNION ALL
            SELECT "conjunctions", items FROM conjunctions
            UNION ALL
            SELECT "prepositions", items FROM prepositions
            UNION ALL
            SELECT "adverbs", items FROM adverbs
            UNION ALL
            SELECT "adjetives", items FROM adjetives
            UNION ALL
            SELECT "verbs", items FROM verbs;
        '
    )
}

function sentence_p() {
    if [ ${1} = 1 ]; then 
        trgt_p="${trgt}"
        srce_p="${srce}"
    elif [ ${1} = 2 ]; then
        trgt_p="${trgt_mod}"
        srce_p="${srce_mod}"
    fi
    table="T`date +%m%y`"
    echo -n "create table if not exists ${table} \
    (Word TEXT, "${slng^}" TEXT);" |sqlite3 ${tlngdb}
    if ! grep -q "${slng^}" <<< "$(sqlite3 ${tlngdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${tlngdb} "alter table ${table} add column '${slng^}' TEXT;"
    fi
    r=$((RANDOM%10000))
    touch "$DT_r/swrd.$r" "$DT_r/twrd.$r"
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
        vrbl="${srce_p}"; lg=$lgt; aw="$DT_r/swrd.$r"; bw="$DT_r/twrd.$r"
    else
        vrbl="${trgt_p}"; lg=$lgs; aw="$DT_r/twrd.$r"; bw="$DT_r/swrd.$r"
    fi
    # sed 's/\s+/\n/g'
    echo "${vrbl}" |sed 's/ ./\U&/g' \
    |tr -s '[:space:]' '\n' \
    |LC_ALL=C sort -u \
    |tr -d '.' |sed 's/\.//g' \
    |tr -d '*)(,;"“”:' |tr -s '_&|{}[]' ' ' \
    |sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
    |sed 's/\]//;s/\[//;s/<[^>]*>//g' |sed "s/'$//;s/^'//" \
    |sed 's/  / /;s/ /\. /;s/-$//;s/^-//;s/"//g' \
    |sed 's/^ *//; s/ *$//; /^$/d' |sed 's|\/|\n|g' \
    |sed 's/ \+/ /g' |sed -e ':a;N;$!ba;s/\n/\n/g' \
    |sed -e 's/ /\. /g' |sed -e 's/\.\./\./g'|sed 's/\b\w\b \?//g' > "${aw}.1"
    
    translate "$(sed '/^$/d' "${aw}.1")" auto "$lg" | sed 's/\./\n/g' |tr -d '!?¿,;.' \
    |sed -e 's/ \+/ /g' |sed -e 's/.*\]\[\"//g' |sed -e 's/ *$//; /^$/d' > "${bw}"
    
    cat "${aw}.1" | sed 's/\./\n/g' |tr -d '!?¿,;.' | sed 's/^ *//g' \
    |sed -e 's/ \+/ /g' |sed -e 's/.*\]\[\"//g' |sed -e 's/ *$//; /^$/d' > "${aw}"

	load_grammar_sets
	
	while IFS= read -r wrd; do

		w="${wrd,,}"
		w="$(printf '%s' "$w" | tr -d '\.,;“”"')"

		if [[ -n "${PRONOUNS[$w]+x}" ]]; then
			printf "<span color='#3E539A'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${NOUNS_ADJ[$w]+x}" ]]; then
			printf "<span color='#496E60'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${NOUNS_VERBS[$w]+x}" ]]; then
			printf "<span color='#62426A'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${CONJUNCTIONS[$w]+x}" ]]; then
			printf "<span color='#90B33B'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${PREPOSITIONS[$w]+x}" ]]; then
			printf "<span color='#D67B2D'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${ADVERBS[$w]+x}" ]]; then
			printf "<span color='#9C68BD'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${ADJECTIVES[$w]+x}" ]]; then
			printf "<span color='#3E8A3B'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		elif [[ -n "${VERBS[$w]+x}" ]]; then
			printf "<span color='#CF387F'>%s</span>\n" "$wrd" >> "$DT_r/g.$r"

		else
			printf "%s\n" "$wrd" >> "$DT_r/g.$r"
		fi

	done < <(sed 's/ /\n/g' <<< "${trgt_p}")
    
    touch "$DT_r/A.$r" "$DT_r/B.$r" "$DT_r/g.$r"; bcle=1
    trgt_q="$(sed "s|'|''|g" <<< "${trgt}")"
    
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        s=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        t=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "${t}_${s}" >> "$DT_r/B.$r"
        t="$(sed "s|'|''|g" <<< "${t}")"
        s="$(sed "s|'|''|g" <<< "${s}")"
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if [[ -z "$(sqlite3 ${tlngdb} "select Word from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "insert into Words (Word,'${slng^}',Example) values ('${t}','${s}','${trgt_q}');"
                sqlite3 ${tlngdb} "insert into ${table} (Word,'${slng^}') values ('${t}','${s}');"
            elif [[ -z "$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "update Words set '${slng^}'='${s}' where Word='${t}';"
            elif [[ -z "$(sqlite3 ${tlngdb} "select Example from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "update Words set Example='${trgt_q}' where Word='${t}';"
            fi
        fi
        let bcle++
        done
    else
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        t=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        s=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "${t}_${s}" >> "$DT_r/B.$r"
        t="$(sed "s|'|''|g" <<< "${t}")"
        s="$(sed "s|'|''|g" <<< "${s}")"
        
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if [[ -z "$(sqlite3 ${tlngdb} "select Word from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "insert into Words (Word,'${slng^}',Example) values ('${t}','${s}','${trgt_q}');" 
                sqlite3 ${tlngdb} "insert into ${table} (Word,'${slng^}') values ('${t}','${s}');"
            elif [[ -z "$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "update Words set '${slng^}'='${s}' where Word='${t}';"
            elif [[ -z "$(sqlite3 ${tlngdb} "select Example from Words where Word is '${t}';")" ]]; then
                sqlite3 ${tlngdb} "update Words set Example='${trgt_q}' where Word='${t}';"
            fi
        fi
        let bcle++
        done
    fi
    if [ ${1} = 1 ]; then
        export grmr="$(sed ':a;N;$!ba;s/\n/ /g' "$DT_r/g.$r")"
        export wrds="$(tr '\n' '_' < "$DT_r/B.$r")"
    elif [ ${1} = 2 ]; then
        export grmr_mod="$(sed ':a;N;$!ba;s/\n/ /g' "$DT_r/g.$r")"
        export wrds_mod="$(tr '\n' '_' < "$DT_r/B.$r")"
    fi
}

function word_p() {
	
    table="T`date +%m%y`"
    trgt_q="$(sed "s|'|''|g" <<< "${trgt}")"
    srce_q="$(sed "s|'|''|g" <<< "${srce}")"
    echo -n "create table if not exists ${table} \
    (Word TEXT, "${slng^}" TEXT);" |sqlite3 ${tlngdb}
    if ! grep -q "${slng^}" <<< "$(sqlite3 ${tlngdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${tlngdb} "alter table ${table} add column '${slng^}' TEXT;"
    fi
    if ! [[ "${trgt}" =~ [0-9] ]] && [ -n "${trgt}" ] && [ -n "${srce}" ]; then
        if [[ -z "$(sqlite3 ${tlngdb} "select Word from Words where Word is '${trgt}';")" ]]; then
            sqlite3 ${tlngdb} "insert into ${table} (Word,'${slng^}') values ('${trgt_q}','${srce_q}');"
            sqlite3 ${tlngdb} "insert into Words (Word,'${slng^}') values ('${trgt_q}','${srce_q}');"
          
        elif [[ -z "$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${trgt}';")" ]]; then
            sqlite3 ${tlngdb} "update Words set '${slng^}'='${srce_q}' where Word='${trgt}';"
        fi

        if [ -n "${exmp}" ]; then
            exmp_q="$(sed "s|'|''|g" <<< "${exmp}")"
            sqlite3 ${tlngdb} "update Words set Example='${exmp_q}' where Word='${trgt}';"
        fi
        if [ -n "${defn}" ]; then
            defn_q="$(sed "s|'|''|g" <<< "${defn}")"
            sqlite3 ${tlngdb} "update Words set Definition='${defn_q}' where Word='${trgt}';"
        fi
    fi
}

function clean_0() {
    echo "${1}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" | sed "s/^-\(.*\)/\1/" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -d ':*|;!¿?[]&:<>+'  |sed 's/\¡//g' \
    |sed 's/<[^>]*>//g; s/ \+/ /; s|/|-|g'
}

function clean_1() {
    echo "${1}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" | sed "s/^-\(.*\)/\1/" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -d '*|",;!¿?()[]&:.<>+'  |sed 's/\¡//g' \
    |sed 's/<[^>]*>//g; s/ \+/ /g; s|/|-|g'
}

function clean_2() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1 ; then
		echo "${1}" |sed 's/\\n/ /;s/	/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
		|sed "s/’/'/g" |sed 's/quot\;/"/g' \
		|tr -d '*' |tr -s '&|{}[]<>+' ' ' \
		|sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
		|sed 's/^ *//;s/ *$//g;s/<[^>]*>//g;s/^\s*./\U&\E/g'
    else
		echo "${1}" |sed 's/\\n/ /;s/	/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
		|sed "s/’/'/g" |sed 's/quot\;/"/g' \
		|tr -s '*&|{}[]<>+' ' ' \
		|sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
		|sed 's/^ *//;s/ *$//g; s/^\s*./\U&\E/g' \
		|sed 's/<[^>]*>//g;s/^\s*./\U&\E/g'
    fi
}

function clean_3() {
    echo "${1}" |cut -d "|" -f1 |sed 's/!//;s/&//;s/\://g' \
    |sed "s/^[ \t]*//;s/[ \t]*$//;s/‘/'/g" |sed -e 's|/|\\/|g' \
    |sed 's/^\s*./\U&\E/g' \
    |sed 's/\：//g;s/<[^>]*>//g' \
    |tr -d '?.*{}[]' |tr -s '&:|<>+' ' ' |sed 's/ \+/ /g'
}  

function clean_4() {
    if [ $(wc -c <<< "${1}") -le ${sentence_chars} ] && \
    [ $(echo -e "${1}" |wc -l) -gt ${sentence_lines} ]; then
    echo "${1}" |sed "s/^-\(.*\)/\1/" | tr -d '*' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — / - /;s/--/ /g; /^$/d;s/ \+/ /g;s/ʺͶ//;s/	/ /g'
    elif [ $(wc -c <<< "${1}") -le ${sentence_chars} ]; then
    echo "${1}" |sed "s/^-\(.*\)/\1/" |sed ':a;N;$!ba;s/\n/ /;s/	/ /g' \
    |tr -d '*' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — / - /;s/--/ /g; /^$/d; s/ \+/ /g;s/ʺͶ//g'
    else
    echo "${1}" |sed "s/^-\(.*\)/\1/" |sed ':a;N;$!ba;s/\n/\__/;s/	/ /g' \
    |tr -d '*' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — /__/;s/--/ /g; /^$/d; s/ \+/ /g;s/ʺͶ//g'
    fi
}


function clean_5() {
    sed -n -e '1x;1!H;${x;s-\n- -gp}' \
    |sed 's/<[^>]*>//g' |sed 's/ \+/ /g' \
    |sed '/^$/d' |sed 's/ \+/ /g' \
    |sed 's/^[ \t]*//;s/[ \t]*$//;s/^ *//; s/ *$//g' \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' |sed 's/<[^>]\+>//g' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ — /\n/g' \
    |sed 's/[<>£§]//; s/&amp;/\&/g' |sed 's/ *<[^>]\+> */ /g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g; s/\. //g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g; s/\? //g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g; s/\! //g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g; s/\… //g' \
    |sed 's/__/\n/g;s/ʺͶ//g'
}

function clean_6() {
    sed 's/\\n/./g' \
    |sed '/^$/d' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ — /\n/g;s/ʺͶ//g' \
    |sed 's/ \+/ /;s/\&quot;/\"/;s/^ *//;s/ *$//g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g; s/\. //g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g; s/\? //g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g; s/\! //g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g; s/\… //g'
}

function clean_7() {
    sed 's/^ *//;s/ *$//g' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ \+/ /;s/	/ /g' \
    |sed '/^$/d' |sed 's/ — /\n/g' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    |sed 's/,/\n/g;s/。/\n/g;s/__/\n/g' |sed 's/ \+/ /g'
}

function clean_8() {
    sed 's/\[ \.\.\. \]//;s/	/ /g' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ \+/ /g' \
    |sed '/^$/d' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' |sed 's/\. / /g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' |sed 's/\? / /g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' |sed 's/\! / /g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' |sed 's/\… / /g' \
    |sed 's/__/ \n/g;s/ \+/ /g' |sed 's/ \+/ /g'
}

function clean_9() {
    echo "${1%%[,.-]*}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -d '*|[]&<>+' \
    |sed 's/<[^>]*>//g; s/ \+/ /g'
}

function set_image_1() {
    /usr/bin/import "$DT_r/img.jpg"
    #gnome-screenshot -a --file="$DT_r/img.jpg"
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 110x90^ \
    -gravity center -extent 110x90 -quality 90% "$DT_r/ico.jpg"
}

function set_image_2() {
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 405x275^ \
    -gravity center -extent 400x270 -quality 90% "$DT_r/imgs.jpg"
    mv -f "$DT_r/imgs.jpg" "${2}"
}

function translate() {
    stop=0; t="$(sed "s|'|''|g" <<< "${1}")"
    if [[ $(wc -w <<< ${1}) = 1 ]] && [[ "${ttrgt}" != TRUE ]] && \
    [[ -n "$(sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${t}';")" ]]; then
        sqlite3 ${tlngdb} "select "${slng^}" from Words where Word is '${t}' limit 1;"
    else
        if ! ls "$DC_d"/*."Traslator online.Translate".* 1> /dev/null 2>&1; then
            "$DS_a/Resources/cnfg.sh" 2
        fi
        for trans in "$DC_d"/*."Traslator online.Translate".*; do
            trans="$DS_a/Resources/scripts/$(basename "${trans}")"
            if [ -f "${trans}" ]; then "${trans}" "$@" && break; fi
        done
    fi
}

dwld1() {
    URL=""; source "$1/scripts/$(basename "${dict}")"
    if [ -n "${URL}" ] && [ ! -f "$audio_file" ]; then
        wget -T 51 -q -U "$useragent" -O "$audio_dwld.$EX" "${URL}"
        
        if [[ ${EX} != 'mp3' ]]; then
			sox -t wav -c 1 "$audio_dwld.$EX" "$audio_dwld.mp3"
        fi
    fi
    if [ -f "$audio_file" ]; then
        if file -b --mime-type "$audio_file" |grep -E 'audio|mpeg|mp3' >/dev/null 2>&1 \
        && [[ $(du -b "$audio_file" |cut -f1) -gt 120 ]]; then
            return 5
        else
            cleanups "$audio_file"
        fi
    fi
}

dwld2() {
    URL=""; source "$1/scripts/$(basename "${dict}")"
    if [ -n "${URL}" ] && [ ! -f "${audio_file}" ]; then
        wget -T 51 -q -U "$useragent" -O "$DT_r/audio.mp3" "${URL}"
    fi
    if [ -f "$DT_r/audio.mp3" ]; then
        if file -b --mime-type "$DT_r/audio.mp3" |grep -E 'audio|mpeg|mp3'>/dev/null 2>&1; then
			if [[ $(du -b "$DT_r/audio.mp3" |cut -f1) -gt 120 ]]; then
				mv -f "$DT_r/audio.mp3" "${audio_file}"; return 5
			else 
				cleanups "$DT_r/audio.mp3"
            fi
         else
			cleanups "$DT_r/audio.mp3"
        fi
    fi
}

export -f translate dwld1 dwld2

function tts_sentence() {

    word="${1}"; DT_r="$2"; audio_file="${3}"
    audio_dwld="${audio_file%.mp3}"

    if ls "$DC_d"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1; then
		for dict in "$DC_d"/*."TTS online.Convert text to audio".*; do
			unset EXECUT URL EX
			source "$DS_a/Resources/scripts/$(basename "${dict}")"
			if [ -n "${EXECUT##+([[:space:]])}" ]; then
				"$DS_a/Resources/scripts/$(basename "${dict}")" "${word}" "${audio_file}"
			else
				dwld1 "$DS_a/Resources"
			fi

			if [ -f "$audio_file" ]; then
				if file -b --mime-type "$audio_file" |grep -E 'audio|mpeg|mp3|ogg|wav' >/dev/null 2>&1 \
				&& [[ $(du -b "$audio_file" |cut -f1) -gt 120 ]]; then
					break
				else
					cleanups "$audio_file" "$audio_dwld.$EX"
				fi
			fi
		done

    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
		for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${1}" "${3}"
			if [ -f "${3}" ]; then break; fi
		done

	else
		"$DS_a/Resources/cnfg.sh" 1
	fi
}

function tts_word() {
	
    word="${1,,}"; audio_file="${2}/$word.mp3"; audio_dwld="${2}/$word"

	if ! ls "$DC_d"/*."TTS online.Download audio".$lgt 1> /dev/null 2>&1 &&\
	! ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1 &&\
	! ls "$DC_d"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1 &&\
	! ls "$DC_d"/*."TTS online.Download audio".various 1> /dev/null 2>&1;
	  then
		"$DS_a/Resources/cnfg.sh"
	else
	
		if ls "$DC_d"/*."TTS online.Download audio".$lgt 1> /dev/null 2>&1; then
			for dict in $DC_d/*."TTS online.Download audio".$lgt; do
				dwld1 "$DS_a/Resources"; [ $? = 5 ] && break
			done
		fi
		if [ ! -f "${audio_file}" ]; then
			if ls "$DC_d"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1; then
				for Script in "$DC_d"/*."TTS online.Convert text to audio".*; do
					Script="$DS_a/Resources/scripts/$(basename "${Script}")"
					[ -f "${Script}" ] && "${Script}" "${word}" "${audio_file}"
					if [ -f "${audio_file}" ]; then break; fi
				done
			fi
		fi
		if [ ! -f "${audio_file}" ]; then
			if ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
				for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
					Script="$DS_a/Resources/scripts/$(basename "${Script}")"
					[ -f "${Script}" ] && "${Script}" "${word}" "${audio_file}"
					if [ -f "${audio_file}" ]; then break; fi
				done
			fi
		fi
		if [ ! -f "${audio_file}" ]; then
			if ls "$DC_d"/*."TTS online.Download audio".various 1> /dev/null 2>&1; then
				for dict in $DC_d/*."TTS online.Download audio".various; do
					dwld1 "$DS_a/Resources"; [ $? = 5 ] && break
				done
			fi
		fi
    fi
}

function fetch_audio() {

    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1 ; then 
    words_list="${2}"; else words_list="${1}"; fi
    
    while read -r Word; do
        word="${Word,,}"; export audio_file="$DM_tls/audio/$word.mp3"
        audio_dwld="$DM_tls/audio/$word"
        if [ ! -f "$audio_file" ]; then
            if ls "$DC_d"/*."TTS online.Download audio".$lgt 1> /dev/null 2>&1; then
                for dict in "$DC_d"/*."TTS online.Download audio".$lgt; do
                    dwld1 "$DS_a/Resources"; [ $? = 5 ] && break
                done
            fi
            if [ ! -f "$audio_file" ]; then
                if ls "$DC_d"/*."TTS online.Download audio".various 1> /dev/null 2>&1; then
                    for dict in "$DC_d"/*."TTS online.Download audio".various; do
                        dwld1 "$DS_a/Resources"; [ $? = 5 ] && break
                    done
                fi
            fi
        fi
    done < "${words_list}"
}

function img_word() {
    if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
        if [ ! -e "${DM_tls}/images/${1,,}-1.jpg" ] && [ ! -f "${DM_tlt}/images/${1,,}.jpg" ]; then
            touch "$DT/${1}.img"
            for Script in "$DC_d"/*."Script.Download image".*; do
                Script="$DS_a/Resources/scripts/$(basename "${Script}")"
                [ -f "${Script}" ] && "${Script}" "${1}"
                if [ -f "$DT/${1}.jpg" ]; then
                
					if file -b --mime-type "$DT/${1}.jpg" \
					|grep 'image'>/dev/null 2>&1; then
					
                        break
                    else 
                        rm -f "$DT/${1}.jpg"
                    fi
                fi
            done
            if [ ! -e "$DT/${1}.jpg" ]; then
                for Script in "$DC_d"/*."Script.Download image".*; do
                    Script="$DS_a/Resources/scripts/$(basename "${Script}")"
                    [ -f "${Script}" ] && "${Script}" "${2}"
                    if [ -f "$DT/${2}.jpg" ]; then
                        if file -b --mime-type "$DT/${2}.jpg" \
						|grep 'image'>/dev/null 2>&1; then
                            break
                        else 
                            rm -f "$DT/${2}.jpg"
                        fi
                    fi
                done
            fi
            if [ -f "$DT/${1}.jpg" ] || [ -f "$DT/${2}.jpg" ]; then
                [[ $(wc -w <<< ${1}) -gt 1 ]] && sf="${DM_tlt}/images/${1,,}.jpg" || sf="${DM_tls}/images/${1,,}-1.jpg"
                [ -f "$DT/${1}.jpg" ] && img_file="${1}.jpg" || img_file="${2}.jpg"
                local size="$(/usr/bin/identify -ping -format '%w %h' "$DT/${img_file}")"
                w="$(echo $size |cut -f1 -d ' ')"
                e="$(echo $size |cut -f2 -d ' ')"
                if [[ $((e*100/w)) -gt 80 ]]; then
                    /usr/bin/convert "$DT/${img_file}" -resize 400x270^ "$DT/${img_file}.pre"
                    [ -f "$DT/${img_file}" ] && rm -f "$DT/${img_file}"
                    /usr/bin/convert "$DT/${img_file}.pre" -gravity center \
                    -background white -compress jpeg -extent 400x270 "$DT/${img_file}"
                fi
                /usr/bin/convert "$DT/${img_file}" -interlace Plane -thumbnail 405x275^ \
                -gravity center -extent 400x270 -quality 90% "${sf}"
                cleanups "$DT/${img_file}"
            fi
            cleanups "$DT/${1}.img" "$DT/${img_file}.pre"
        fi
    fi
}

function list_words_2() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
        echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
        |tr -d '*/“”"' |tr '_' '\n' |sed -n 1~2p |sed '/^$/d'
    else
        echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
        |tr -d '*/“”"' |tr '_' '\n' |sed -n 1~2p |sed '/^$/d'
    fi
}

function list_words_3() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt} >/dev/null 2>&1; then
    echo "${2}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    |sed 's/\[ \.\.\. ] //g' |sed 's/\.//g' \
    |tr '_' '\n' |tr -d ',;:' |sed -n 1~2p |sed '/^$/d' > "$DT_r/lst"
    else
    echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    |sed 's/\[ \.\.\. ] //g' |sed 's/\.//g' \
    |tr -s "[:blank:]" '\n' |tr -d ':,;()' \
    |sed '/^$/d' |sed '/"("/d' \
    |sed 's/[^ ]\+/\L\u&/g' \
    |sed '11,$ d; s/"//g' |egrep -v "FALSE" |egrep -v "TRUE" > "$DT_r/lst"
    fi
    
} >/dev/null 2>&1

function dlg_form_0() {
    gui_add_new_topic "$@"
}

function dlg_form_1() {
    gui_add_note_simple "$@"
}


function dlg_form_2() {
    gui_add_note_with_srce "$@"
}

function dlg_checklist_3() {
    gui_add_checklist_batch "$@"
}

function dlg_checklist_1() {
    gui_add_checklist_words "$@"
}

function dlg_checklist_2() {
    gui_add_checklist_opts "$@"
}

function dlg_text_info_1() {
    gui_add_edit_text "$@"
}

function msg_3() {
    gui_add_confirm_play "$@"
}

function dlg_text_info_3() {
    gui_add_unadded_notes "$@"
}

function dlg_form_3() {
    gui_add_image "$@"
}

function dlg_progress_1() {
    gui_add_progress "$@"
}

function cleanups() {
    for fl in "$@"; do
        if [ -d "${fl}" ]; then
            rm -fr "${fl}"
        elif [ -f "${fl}" ]; then
            rm -f "${fl}"
        fi
    done
}
