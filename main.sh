#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# main.sh — punto de entrada principal de Idiomind
#
# Funciones principales:
#   - Detectar y delegar la primera ejecución.
#   - Cargar y validar la configuración.
#   - Crear/actualizar el estado de sesión.
#   - Ejecutar tareas auxiliares de inicio.
#   - Atender los distintos modos de ejecución mediante el despacho final.
#
# La inicialización de la sesión y varios servicios auxiliares se ejecutan
# de forma concurrente. Los scripts de inicio pueden volver a cargar c.conf,
# por lo que su ejecución forma parte del entorno de arranque concurrente.
#

#  Copyright 2015-2026 Robin Palatnik
#  Email patapatass@hotmail.com
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston
#  MA 02110-1301, USA.
##

# Primera ejecución: delega la configuración inicial a 1u.sh y finaliza
# este proceso. Las ejecuciones posteriores continúan con la configuración
# persistente ya creada.
if [ ! -d "$HOME/.idiomind" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
fi

# Carga la configuración persistente y establece las variables de entorno
# utilizadas por el resto del proceso.
source /usr/share/idiomind/default/c.conf

# Valida que los idiomas estén definidos. El archivo temporal .langc permite
# omitir esta validación durante una configuración transitoria.
if { [ -z "${tlng}" ] || [ -z "${slng}" ]; } && [ ! -f "$DT/.langc" ]; then
    source "$DS/ifs/cmns.sh"
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    msg "$(gettext "Please check the language settings in the preferences dialog.")
$(gettext "If necessary, close the program from the panel icon and start it again.")\n" \
    dialog-warning "$(gettext "Language settings")"
    "$DS/cnfg.sh"
    exit 1
fi

if [ -e "$DT/ps_lk" ] || [ -e "$DT/el_lk" ]; then
    source "$DS/ifs/cmns.sh"
    msg "$(gettext "Please wait until the current process is finished")...\n" dialog-information
    (sleep 50; cleanups "$DT/ps_lk" "$DT/el_lk") & exit 1
fi

# Crea o actualiza el estado de una nueva sesión de ejecución.
# Se utiliza tanto en el inicio normal como en autostart y en el modo -s.
function new_session() {
    source "$DS/ifs/cmns.sh"
    echo "-- new session"
    export -f cdb
    d=$(date +%d)
    cdb ${cfgdb} 3 sess date ${d}

    # Inicializa el directorio temporal de la sesión.
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    if [ $? -ne 0 ]; then
    msg "$(gettext "An error occurred while trying to write on '/tmp'")\n" \
    error "$(gettext "Error")" & exit 1
    fi
    
    f_lock 1 "$DT/ps_lk"
    
    # Actualiza y comprueba la lista de topics disponibles.
    check_list
    # 
    if ls "$DC_s"/*.p 1> /dev/null 2>&1; then
    cd ~ && cd "$DC_s"/; rename 's/\.p$//' *.p; fi; cd /
    # Asegura la existencia de la base de datos correspondiente al idioma.
    if [ ! -e ${tlngdb} ]; then
        [ ! -d "$DM_tls/data" ] && mkdir -p "$DM_tls/data" 
        echo -n "create table if not exists Words \
        (Word TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${tlngdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${tlngdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${tlngdb}
        sqlite3 ${tlngdb} "alter table Words add column '${slng}' TEXT;"
    fi
    # Mantiene acotado el registro de práctica cuando supera el tamaño previsto.
    if [ -f "$DC_s/log" ]; then
        if [[ "$(du -sb "$DC_s/log" |awk '{ print $1 }')" -gt 100000 ]]; then
        tail -n2000 < "$DC_s/log" > "$DT/log"
        mv -f "$DT/log" "$DC_s/log"; fi
    fi
    # Actualiza las estructuras de la base compartida y los estados de los topics.
    if [ ! -f "${shrdb}" ]; then
        "$DS/ifs/mkdb.sh" share
    else
        for n in {1..4} 7; do 
        cdb ${shrdb} 6 T${n}; done
    fi
    echo -e "\n--- checking topics..."
    tdate=$(date +%Y%m%d)
    
    while read -r line; do
        if [ -n "$line" ]; then
            unset stts
            dir="$DM_tl/${line}/.conf"
            dim="$DM_tl/${line}"
            [ ! -d "${dir}" ] && continue
            stts=$(sed -n 1p "${dir}/stts")
            ! [[ ${stts} =~ $numer ]] && stts=1
            [[ ${stts} = 0 ]] && continue

            if [ $stts = 3 ] || [ $stts = 4 ] || [ $stts = 7 ] || [ $stts = 8 ] || [ $stts = 9 ] || [ $stts = 10 ]; then

                calculate_review "${line}"
                
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${days_to_review_porcent} -ge 150 ] && [ ${stts} = 8 ]; then
                        echo 10 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T2 list "${line}"
                        
                    elif [ ${days_to_review_porcent} -ge 100 ] && [ ${stts} -lt 8 ]; then
                        echo 8 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T1 list "${line}"
                        
                    elif [ ${stts} = 8 ]; then
                        cdb ${shrdb} 2 T3 list "${line}"
                        
                    elif [ ${stts} = 10 ]; then
                        cdb ${shrdb} 2 T4 list "${line}"
                    fi
                    
                elif [[ $((stts%2)) = 1 ]]; then
                    if [ ${days_to_review_porcent} -ge 150 ] && [ ${stts} = 7 ]; then
                        echo 9 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T2 list "${line}"
                        
                    elif [ ${days_to_review_porcent} -ge 100 ] && [ ${stts} -lt 7 ]; then
                        echo 7 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T1 list "${line}"
                        
                    elif [ ${stts} = 7 ]; then
                        cdb ${shrdb} 2 T3 list "${line}"
                        
                    elif [ ${stts} = 9 ]; then
                        cdb ${shrdb} 2 T4 list "${line}"
                    fi
                fi
                
            elif [ ${stts} = 2 ]; then

				if [[ -z "$(sqlite3 ${shrdb} "select list from T10 where list is '${line}';")" ]]; then
					cdb ${shrdb} 2 T10 list "${line}"
				fi

            elif [[ $((stts+stts%2)) = 6 ]]; then
            
                datedir=$(stat -c %y "$dir" |cut -d ' ' -f1)
                cdate=$(date -d "${datedir} 12:00:00" +"%Y%m%d")
                if [ $((tdate-cdate)) -gt 20 ]; then
                    cdb ${shrdb} 2 T7 list "${line}"
                fi
            fi
        fi
    done < <(cd ~ && cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')
    rm -f "$DT/ps_lk"
    
    if ps -A |pgrep -f "yad --title=Idiomind --list"; then
    kill -9 $(pgrep -f "yad --title="Idiomind" --list") >/dev/null 2>&1 & fi
    
	$DS/ifs/mods/start/update_tasks.sh

    # run startups scripts
    for strt in "$DS/ifs/mods/start"/*; do
		if grep tasks <<<"$strt">/dev/null 2>&1; then :
		else
			( sleep 2 && "${strt}" )
		fi
	done &
    
    # make index
    "$DS/mngr.sh" mkmn 0 &
    echo -e "\ttopics ok\n"
    echo 0 > "$DT/playlck"
    
    # Calcula las estadísticas en segundo plano después de un breve retraso.
    ( source "$DS/ifs/stats.sh"; sleep 5; export val1=0 val2=0; pre_comp ) &
}

# View / istall tpc
if grep -o '.idmnd' <<<"${1: -6}" >/dev/null 2>&1; then
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    slngcurrent="$slng"; tlngcurrent="$tlng"
    source "$DS/ifs/cmns.sh"
    source "$DS/ifs/tls.sh"

    # A .idmnd portable package may be:
    #  - legacy JSON file (.idmnd plain 3-line JSON, no multimedia)
    #  - legacy directory (<topic>.idmnd/ with JSON + images/ + audio/ folders)
    #  - new portable ZIP (<topic>.idmnd single file containing topic.idmnd
    #    [+ images/ + audio/])
    # For the ZIP case we extract it to a temporary directory and reuse the
    # same import/preview/install flow used for the legacy directory.
    media_src=""
    file="${1}"
    tmpdir=""
    if [ -d "${1}" ]; then
        media_src="${1}"
        file="$(find "${1}" -maxdepth 1 -name '*.idmnd' -type f |head -n1)"
        [ -z "$file" ] && file="${1}/${1##*/}.idmnd"
    elif file "${1}" | grep -qi "zip archive"; then
		# Use the package filename as the temporary topic directory.
		# Example: "English Basics.idmnd" -> "$DT/English Basics"
		topic_tmp_name="$(basename "${1}")"
		topic_tmp_name="${topic_tmp_name%.idmnd}"
		tmpdir="$DT/$topic_tmp_name"

		check_dir "$tmpdir"
        if ! unzip -q "${1}" -d "$tmpdir"; then
            cleanups "$tmpdir"
            msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
        fi
        file="$(find "$tmpdir" -maxdepth 1 -name 'topic.idmnd' -type f |head -n1)"
        if [ -z "$file" ] || [ ! -f "$file" ]; then
            cleanups "$tmpdir"
            msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
        fi
        media_src="$tmpdir"
    fi

    check_format_1 "${file}"
    if [ $? != 19 ]; then
        cleanups "$tmpdir"
        msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
    fi
    c=$((RANDOM%100000)); export KEY=$c
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    level="${lv[${levl}]}"
    itxt="<span font_desc='Droid Sans Bold 12'>$name</span><small>\n$(gettext "Notes:")  $nwrd $(gettext "Words"),  \
$nsnt $(gettext "Sentences"),  $nimg $(gettext "Images")\n$(gettext "Level:") \
$level \n$(gettext "Language:") $(gettext "$tlng"),  $(gettext "Translation:") $(gettext "$slng")$otranslations</small>" 
    dclk="$DS/play.sh play_word"
    source "$DS/ifs/mods/main/items_list.sh"
	_lst() {
		while read -r line; do
			cut -d ':' -f1 <<< "${line}" | sed 's/\"*//;s/\"$//'
			cut -d ':' -f3 <<< "${line}" | sed 's/\"*//;s/\"$//;s/\",\"slch//'
		done < <(sed -n 2p "${file}" | sed 's/},/\n/g' | tr -d '\\' | sed '/^$/d')
	}

	_info() {
		json_get_string "$file" info
	}

	export -f _lst _info

	# For a portable package, use the extracted topic directory directly
	# as the multimedia root during preview. No audio files are copied
	# to the session root ($DT).
	if [ -n "$media_src" ]; then
			export IDMND_PREVIEW_MEDIA="$media_src"

			P_DATA="$media_src/topic_data"
			
			
			sed -n 2p "${file}" |tr -d '\\' > "$P_DATA"
			sed -i 's/},/}\n/g;s|","|}|g;s|":"|{|g;s|":{"|}|g;s/"}/}/g' "$P_DATA"
			sed -i 's/^\s*./trgt{/g' "$P_DATA"
			sed -i '/^$/d' "$P_DATA"
			export IDMND_PREVIEW_DATA="$P_DATA"
		fi

    tpc_view
    ret=$?
        if [ $ret -eq 0 ]; then
            if [ -f "$DT/in_lk" ]; then
                cleanups "$tmpdir"
                msg "$(gettext "Please wait until the current process is finished")...\n" dialog-information
                sleep 15; cleanups "$DT/in_lk"; exit 1
            fi

            if [[ "$tlng" != "$tlngcurrent" ]]; then
                msg_2 "$(gettext "Please note the language of this Topic is:") <b>$tlng</b>
$(gettext "It is recommended to change your language preferences before installing it")" dialog-warning "$(gettext "Ignore")" "$(gettext "OK")" 
                if [ $? -eq 1 ]; then
                    cleanups "$tmpdir" "$DT/in_lk"; exit 1
                fi
            fi
            
            f_lock 1 "$DT/in_lk"
            listt="$(cd ~ && cd "$DM_tl"; find ./ -maxdepth 1 -type d \
            ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"
            cn=0
            if [[ $(grep -Fxo "${name}" <<< "${listt}" |wc -l) -ge 1 ]]; then
                cn=1
                for i in {1..50}; do
                    chck=$(grep -Fxo "${name} ($i)" <<< "${listt}")
                    [ -z "$chck" ] && break
                done
                name="${name} ($i)"
            fi
            export tpc="${name}"
            check_dir "$DM_t/$tlng" "$DM_t/$tlng/.share/images" \
            "$DM_t/$tlng/.share/audio" "$DM_t/$tlng/.share/data" \
            "$DM_t/$tlng/${name}/.conf/practice"
            DM_tlt="$DM_t/$tlng/${name}"
            export DC_tlt="$DM_t/$tlng/${name}/.conf"
            export tpcdb="$DC_tlt/tpc"
            "$DS/ifs/mkdb.sh" tpc "${tpc}"
            tpc_db 9 id name "${name}"
            tpc_db 9 id slng "$slng"
            tpc_db 9 id tlng "$tlng"
            tpc_db 9 id autr "$autr"
            tpc_db 9 id ctgy "$ctgy"
            tpc_db 9 id ilnk "$ilnk"
            tpc_db 9 id orig "$orig"
            tpc_db 9 id dtec "$dtec"
            tpc_db 9 id dtei "$(date +%F)"
            tpc_db 9 id nwrd "$nwrd"
            tpc_db 9 id nsnt "$nsnt"
            tpc_db 9 id nimg "$nimg"
            tpc_db 9 id naud "$naud"
            tpc_db 9 id nsze "$nsze"
            tpc_db 9 id levl "$levl"
            check_file "${DC_tlt}/practice/log1" "${DC_tlt}/practice/log2" \
            "${DC_tlt}/practice/log3" "${DC_tlt}/note.md"
            # Materialize the canonical topic note from the root JSON "info" field.
			if ! json_get_string "${file}" "info" > "${DC_tlt}/note.md"; then
				cleanups "$tmpdir"
				msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
			fi
            
            sed -n 2p "${file}" |tr -d '\\' > "${DC_tlt}/data"
            sed -i 's/},/}\n/g;s|","|}|g;s|":"|{|g;s|":{"|}|g;s/"}/}/g' "${DC_tlt}/data"
            sed -i 's/^\s*./trgt{/g' "${DC_tlt}/data"
            sed -i '/^$/d' "${DC_tlt}/data"
            export data="${DC_tlt}/data"
            
			# Parse topic data and populate the SQLite database.
			
			parse_item() {
				local rest="$1"
				local name
				local value

				trgt=
				srce=
				exmp=
				defn=
				note=
				wrds=
				grmr=
				tags=
				mark=
				refr=
				imag=
				imgr=
				link=
				cdid=
				type=

				while [[ "$rest" == *"{"* ]]; do

					# Everything before the first '{' is the field name.
					name="${rest%%\{*}"

					[[ -n "$name" ]] || break

					# Remove field name and opening '{'.
					rest="${rest#*\{}"

					# capture until the first '}', or until the end of the
					# string when no closing '}' exists.
					if [[ "$rest" == *"}"* ]]; then
						value="${rest%%\}*}"
						rest="${rest#*\}}"
					else
						value="$rest"
						rest=""
					fi

					case "$name" in
						trgt) trgt="$value" ;;
						srce) srce="$value" ;;
						exmp) exmp="$value" ;;
						defn) defn="$value" ;;
						note) note="$value" ;;
						wrds) wrds="$value" ;;
						grmr) grmr="$value" ;;
						tags) tags="$value" ;;
						mark) mark="$value" ;;
						refr) refr="$value" ;;
						imag) imag="$value" ;;
						imgr) imgr="$value" ;;
						link) link="$value" ;;
						cdid) cdid="$value" ;;
						type) type="$value" ;;
					esac
				done
			}


			{
				printf 'BEGIN TRANSACTION;\n'

				while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do

	
					item="$raw_line"

					# Remove leading whitespace.
					while [[ "$item" == [[:space:]]* ]]; do
						item="${item:1}"
					done

					# Remove trailing whitespace.
					while [[ "$item" == *[[:space:]] ]]; do
						item="${item::-1}"
					done

					[[ -z "$item" ]] && continue

					parse_item "$item"

					# values for logical comparisons.
					is_word=false
					is_sentence=false
					is_mark=false

					[[ "$type" == "1" ]] && is_word=true
					[[ "$type" == "2" ]] && is_sentence=true
					[[ "$mark" == "TRUE" ]] && is_mark=true

					# Escape SQL literals in-place.
					#
					# SQLite represents a single quote inside a string by
					# doubling it: ' -> ''.
					#
					# This is done directly in Bash, without command substitution
					# and therefore without creating a subshell.
					trgt="${trgt//\'/\'\'}"
					srce="${srce//\'/\'\'}"
					exmp="${exmp//\'/\'\'}"
					defn="${defn//\'/\'\'}"
					note="${note//\'/\'\'}"
					wrds="${wrds//\'/\'\'}"
					grmr="${grmr//\'/\'\'}"
					tags="${tags//\'/\'\'}"
					mark="${mark//\'/\'\'}"
					refr="${refr//\'/\'\'}"
					imag="${imag//\'/\'\'}"
					link="${link//\'/\'\'}"
					cdid="${cdid//\'/\'\'}"
					type="${type//\'/\'\'}"

					if "$is_word"; then
						printf "INSERT INTO words (list) VALUES ('%s');\n" "$trgt"
					elif "$is_sentence"; then
						printf "INSERT INTO sentences (list) VALUES ('%s');\n" "$trgt"
					fi

					if "$is_mark"; then
						printf "INSERT INTO marks (list) VALUES ('%s');\n" "$trgt"
					fi

					printf "INSERT INTO learning (list) VALUES ('%s');\n" "$trgt"

					printf "INSERT INTO Data \
			(trgt,srce,exmp,defn,note,wrds,grmr,tags,mark,refr,imag,link,cdid,type) \
			VALUES ('%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s');\n" \
						"$trgt" \
						"$srce" \
						"$exmp" \
						"$defn" \
						"$note" \
						"$wrds" \
						"$grmr" \
						"$tags" \
						"$mark" \
						"$refr" \
						"$imag" \
						"$link" \
						"$cdid" \
						"$type"

				done < "$data"

				printf 'COMMIT;\n'

			} | sqlite3 "$tpcdb"

            "$DS/ifs/tls.sh" colorize 1
            f_lock 3 "$DT/in_lk"

            # restore multimedia when importing an exported .idmnd folder
            if [ -n "$media_src" ] && [ -d "$media_src/images" ]; then
                check_dir "$DM_tlt/images" "$DM_tls/images" "$DM_tls/audio"
                for img in "$media_src"/images/*.jpg; do
                    [ -e "$img" ] || continue
                    base="$(basename "$img")"
                    case "$base" in
                        *-2.jpg)
                            cp -f "$img" "$DM_tlt/images/${base%-2.jpg}.jpg" ;;
                        *-1.jpg)
                            cp -f "$img" "$DM_tls/images/${base%-1.jpg}-1.jpg" ;;
                    esac
                done
            fi
            if [ -n "$media_src" ] && [ -d "$media_src/audio/topic" ]; then
                check_dir "$DM_tlt"
                for mp3 in "$media_src"/audio/topic/*.mp3; do
                    [ -e "$mp3" ] || continue
                    cp -f "$mp3" "$DM_tlt/$(basename "$mp3")"
                done
            fi
            if [ -n "$media_src" ] && [ -d "$media_src/audio/shared" ]; then
                check_dir "$DM_tls/audio"
                for mp3 in "$media_src"/audio/shared/*.mp3; do
                    [ -e "$mp3" ] || continue
                    cp -f "$mp3" "$DM_tls/audio/$(basename "$mp3")"
                done
            fi
            
            slngtopic="$slng"; slng="$slngcurrent"
            cdb "${cfgdb}" 3 lang tlng "${tlng}"
            cdb "${cfgdb}" 3 lang slng "${slng}"
            if [[ "$slngtopic" != "$slng" ]]; then
                mkdir "${DC_tlt}/translations/"
                echo "$slngtopic" > "${DC_tlt}/translations/active"
                touch "${DC_tlt}/slng_err"
            fi
            if [[ "$tlng" != "$tlngcurrent" ]]; then
                if [[ -f "$DT/tray.pid" ]]; then
                    kill -9 $(cat $DT/tray.pid)
                    kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
                    rm -f "$DT/tray.pid"
                    $DS/ifs/tls.sh itray &
                fi
            fi
            echo 1 > "${DC_tlt}/stts"
            cleanups "$DC_s/topics_first_run"
            source /usr/share/idiomind/default/c.conf
            "$DS/mngr.sh" mkmn 1
            "$DS/ifs/tpc.sh" "${name}" 1 &
        fi
    # stop any audio still playing from the preview when the viewer closes
    "$DS/stop.sh" 2
    cleanups "$tmpdir"
    exit 0
fi

function topic() {
    source "$DS/ifs/cmns.sh"
    f_lock 0 "$DT/tpc_lk"
    export -f tpc_db msg
    [ -f "${DC_tlt}/stts" ] && stts=$(sed -n 1p "${DC_tlt}/stts")

    if ! [[ ${stts} =~ $numer ]]; then return 1; fi

    readd(){
        [ -z "${tpc}" ] && return 1
        source "$DS/ifs/mods/main/items_list.sh"
        n=1; tas=('learning' 'learnt' 'words' 'sentences')
        for ta in "${tas[@]}"; do
            export ls${n}="$(tpc_db 5 "$ta")"; cnt="ls${n}"
            let n++
        done
        cfg0=$(wc -l < "${DC_tlt}/data")
        export cfg1="$(grep -c '[^[:space:]]' <<< "$ls1")"
        export cfg2="$(grep -c '[^[:space:]]' <<< "$ls2")"
        export cfg3="$(grep -c '[^[:space:]]' <<< "$ls3")"
        export cfg4="$(grep -c '[^[:space:]]' <<< "$ls4")"
        note="${DC_tlt}/note.md"
        autr=$(tpc_db 1 id autr)
        dtec=$(tpc_db 1 id dtec)
        dtei=$(tpc_db 1 id dtei)
        count_date_reviews="$(tpc_db 5 reviews |grep -c '[^[:space:]]')"
        acheck=$(tpc_db 1 config acheck)

		[ -z ${count_date_reviews} ] && count_date_reviews=0
		
        if [ ${count_date_reviews} -ge 9  ]; then 
			echo 2 > "${DC_tlt}/stts"
			export stts=2; count_date_reviews=9
			"$DS/mngr.sh" mkmn 1
        fi
        
        export count_date_reviews acheck stts
        
        if [ $((stts)) -lt 10 ]; then 
			( sleep 2 && "$DS/ifs/tls.sh" promp_topic_info ) & fi
        c=$((RANDOM%100000)); export KEY=$c
        export cnf1=$(mktemp "$DT/cnf1.XXXXXX")
        export cnf3=$(mktemp "$DT/cnf3.XXXXXX")
        export cnf4=$(mktemp "$DT/cnf4.XXXXXX")

        labels_level=( "$(gettext "Fresh Topic")" "$(gettext "Fresh Topic")" "$(gettext "Fresh Topic")" "$(gettext "Fresh Topic")" "$(gettext "Familiar Topic")" "$(gettext "Familiar Topic")" "$(gettext "Familiar Topic")" "$(gettext "Familiar Topic")" "$(gettext "Familiar Topic")" "$(gettext "Mastered Topic")" )

        if [ ${stts} -eq 1 ]; then
			labels_status=("$(gettext "Learning.")" "$(gettext "Reviewing for the first time.")" "$(gettext "Reviewing for the second time.")" "$(gettext "Reviewing for the third time.")" "$(gettext "Reviewing for the fourth time.")" "$(gettext "Reviewing for the fifth time.")" "$(gettext "Reviewing for the sixth time.")" "$(gettext "Reviewing for the seventh time.")" "$(gettext "Reviewing, final review")" "$(gettext "Reviewing, final review")")
			[ ${count_date_reviews} -gt 0 ] && btn_review="$(gettext "Finalize Review")" || btn_review="$(gettext "Mark as Learnt")"
			
		elif [ ${stts} -eq 3 ] || [ ${stts} -eq 4 ] ; then
			
			labels_status=( " " "$(gettext "Waiting to review for the first time")" "$(gettext "Waiting to review for the second time")" "$(gettext "Waiting to review for the third time")" "$(gettext "Waiting to review for the fourth time")" "$(gettext "Waiting to review for the fifth time")" "$(gettext "Waiting to review for the sixth time")" "$(gettext "Waiting to review for the seventh time")" "$(gettext "Waiting to review for the eighth time")" "$(gettext "Waiting to review for the ninth time")" "$(gettext "Second reminder to review")")
			[ ${count_date_reviews} -gt 0 ] && btn_review="$(gettext "Back to Review")" || btn_review="$(gettext "Review")"
			
		elif [ ${stts} = 5 ] || [ ${stts} = 6 ]; then
		
			labels_status=("$(gettext "Learning.")" "$(gettext "Reviewing for the first time.")" "$(gettext "Reviewing for the second time.")" "$(gettext "Reviewing for the third time.")" "$(gettext "Reviewing for the fourth time.")" "$(gettext "Reviewing for the fifth time.")" "$(gettext "Reviewing for the sixth time.")" "$(gettext "Reviewing for the seventh time.")" "$(gettext "Reviewing, final review")" "$(gettext "Reviewing, final review")")
			btn_review="$(gettext "Finalize Review")"

		elif [ ${stts} -gt 6 ] && [ ${stts} -lt 11 ]; then
			
			labels_status=( " " "$(gettext "Ready for the first review")" "$(gettext "Ready for the second review")" "$(gettext "Ready for the third review")" "$(gettext "Ready for the fourth review")" "$(gettext "Ready for the fifth review")" "$(gettext "Ready for the sixth review")" "$(gettext "Ready for the seventh review")" "$(gettext "Ready for the Eighth review")" "$(gettext "Ready for the final review")" "$(gettext "Second reminder to review")")
			btn_review="$(gettext "Back to Review")"
        fi

		export label_level="${labels_level[${count_date_reviews}]}"
		[ ${stts} -eq 2 ] && label_level="$(gettext "Mastered Topic")"
		label_review="${labels_status[${count_date_reviews}]}"
		[ ${stts} -eq 2 ] && label_review=""
		export label_review

        if [ -n "$dtei" ]; then 
            export infolbl5="<small>$(gettext "Installed on") $dtei, $(gettext "Created by") $autr</small>"
        else 
            export infolbl5="<small>$(gettext "Created on") $dtec</small>"
        fi
        if  [[ ${stts} = 2 ]]; then
        	lbl1="<span font_desc='Free Sans Bold 12'>${tpc}</span>\n<small><i><span color='#844DB1'>$label_level</span></i></small>\n<small>$(gettext "Notes:") $cfg4 $(gettext "Sentences"), $cfg3 $(gettext "Words")</small>\n$infolbl5\n"
        elif [[ $((stts%2)) = 0 ]]; then
        	lbl1="<span font_desc='Free Sans Bold 12'>${tpc}</span>\n<small><i><span color='#A36A53'>$label_level</span></i></small>\n<small>$(gettext "Notes:") $cfg4 $(gettext "Sentences"), $cfg3 $(gettext "Words")</small>\n$infolbl5\n"
        else
			lbl1="<span font_desc='Free Sans Bold 12'>${tpc}</span>\n<small><i><span color='#84DCE7E7'>$label_level</span></i></small>\n<small>$(gettext "Notes:") $cfg4 $(gettext "Sentences"), $cfg3 $(gettext "Words")</small>\n$infolbl5\n"
        fi
        
        if [ ${count_date_reviews} -eq 0 ]; then
			label_serie=""
		elif [ ${count_date_reviews} = 1 ]; then label_serie="<u><b>4</b></u> <span color='#888888'>| 7 | 7 | 10 | 15 | 15 | 20 | 30</span>"
		elif [ ${count_date_reviews} = 2 ]; then label_serie="<span color='#888888'>4 |</span> <u><b>7</b></u> <span color='#888888'>| 7 | 10 | 15 | 15 | 20 | 30</span>"
		elif [ ${count_date_reviews} = 3 ]; then label_serie="<span color='#888888'>4 | 7 |</span> <u><b>7</b></u> <span color='#888888'>| 10 | 15 | 15 | 20 | 30</span>"
		elif [ ${count_date_reviews} = 4 ]; then label_serie="<span color='#888888'>4 | 7 | 7 |</span> <u><b>10</b></u> <span color='#888888'>| 15 | 15 | 20 | 30</span>"
		elif [ ${count_date_reviews} = 5 ]; then label_serie="<span color='#888888'>4 | 7 | 7 | 10 |</span> <u><b>15</b></u> <span color='#888888'>| 15 | 20 | 30</span>"
		elif [ ${count_date_reviews} = 6 ]; then label_serie="<span color='#888888'>4 | 7 | 7 | 10 | 15 |</span> <u><b>15</b></u> <span color='#888888'>| 20 | 30</span>"
		elif [ ${count_date_reviews} = 7 ]; then label_serie="<span color='#888888'>4 | 7 | 7 | 10 | 15 | 15 |</span> <u><b>20</b></u> <span color='#888888'>| 30</span>"
		elif [ ${count_date_reviews} = 8 ]; then label_serie="<span color='#888888'>4 | 7 | 7 | 10 | 15 | 15 | 20 |</span> <u><b>30</b></u> <span color='#888888'>| 60</span>"
		elif [ ${count_date_reviews} -ge 9 ]; then label_serie="<span color='#888888'>4 | 7 | 7 | 10 | 15 | 15 | 20 | 30 |</span> <u><b>60</b></u>"
		fi

        export lbl1 label_serie
    }
    
    oclean() { cleanups "$cnf1" "$cnf3" "$cnf4" "$DT/tpc_lk"; }
    
    apply() {
            note_mod="$(< "${cnf3}")"
            if [ "${note_mod}" != "$(< "${note}")" ]; then
                if ! grep '^$' < <(sed -n '1p' "${cnf3}")
                then echo -e "\n${note_mod}" > "${note}"
                else echo "${note_mod}" > "${note}"; fi
            fi
            acheck_mod=$(cut -d '|' -f 4 < "${cnf4}")
            if [[ $acheck_mod != $acheck ]] && [ -n "$acheck_mod" ]; then
                tpc_db 3 config acheck "$acheck_mod"
            fi
            if [[ $acheck_mod = FALSE ]] && [[ $acheck != FALSE ]]; then
                "$DS/ifs/tls.sh" colorize 1; rm "${cnf1}"
            fi
            if grep TRUE "${cnf1}" >/dev/null 2>&1; then
                f_lock 1 "$DT/tpc_lk"
                export cnf1 tpcdb
                
                (
                    set -euo pipefail

                    : "${cnf1:?Falta la variable de entorno 'cnf1'}"
                    : "${tpcdb:?Falta la variable de entorno 'tpcdb'}"

                    [[ -f "$cnf1" ]] || {
                        echo "No existe el archivo cnf1: $cnf1" >&2
                        exit 1
                    }

                    [[ -f "$tpcdb" ]] || {
                        echo "No existe la base tpcdb: $tpcdb" >&2
                        exit 1
                    }

                    sql_escape() {
                        printf '%s' "${1//\'/\'\'}"
                    }

                    {
                        printf 'BEGIN TRANSACTION;\n'

                        while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do

                            # Equivalente a line.strip()
                            item="$(printf '%s' "$raw_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

                            # Solo procesar entradas confirmadas.
                            [[ "$item" == *"|TRUE|"* ]] || continue

                            # Equivalente a item.replace("|TRUE|", "")
                            trgt="${item//|TRUE|/}"

                            # Equivalente a re.sub(r'<[^>]+>', '', trgt)
                            trgt="$(printf '%s' "$trgt" | sed -E 's/<[^>]+>//g')"

                            trgt_e="$(sql_escape "$trgt")"

                            printf "INSERT INTO learnt (list) VALUES ('%s');\n" "$trgt_e"
                            printf "DELETE FROM learning WHERE list='%s';\n" "$trgt_e"

                        done < "$cnf1"

                        printf 'COMMIT;\n'

                    } | sqlite3 -bail "$tpcdb"
                ) || {
                    echo "Error al convertir las notas a aprendidas." >&2
                    return 1
                }

                echo "Migración completada." >&2

                "$DS/ifs/tls.sh" colorize 1
                f_lock 3 "$DT/tpc_lk"
                source "$DS/ifs/stats.sh"
                coll_tpc_stats 0
            fi
            
            ntpc=$(cut -d '|' -f 3 < "${cnf4}")
            if [ "${tpc}" != "${ntpc}" ] && [ -n "$ntpc" ]; then
            if [[ "${tpc}" != "$(sed -n 1p "$HOME/.config/idiomind/tpc")" ]]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n" \
            dialog-information "$(gettext "Information")"
            else "$DS/mngr.sh" rename_topic "${ntpc}"; fi; fi
        }
        
    
    # Re-render the topic in this same process whenever a review action
    # (mark_as_learned / mark_to_learn) persists a new status. This keeps the
    # in-memory model, the persisted status and the UI synchronized immediately,
    # without having to close and reopen the application.
    stts_orig=${stts}
    while :; do
        # Re-read the persisted status on every pass so the re-render uses the
        # state that a review action just wrote, keeping memory and disk aligned.
        if [ -f "${DC_tlt}/stts" ]; then
            stts=$(sed -n 1p "${DC_tlt}/stts")
            ! [[ ${stts} =~ $numer ]] && stts=${stts_orig}
        fi
        if [ -f "${DC_tlt}/tpc-journal" ]; then 
    		exit 1
    	else readd; fi
        
    if ((stts==2)); then # If mastered learning topic
    
    notebook_3; ret=$?
    
        if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
        if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi
       
    elif ((stts>=1 && stts<=10)); then # If standar status topic

        if [ ${cfg0} -lt 1 ]; then  # empty topic
            echo "Empty topic N1 / ${cfg0} / ${cfg1} / ${cfg2}"
            
            notebook_1; ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -gt 0 ]; then # if have content to learn
       
            if [ ${stts} = 3 ] || [ ${stts} = 4 ] || [ ${stts} = 7 ] || [ ${stts} = 8 ] || [ ${stts} = 9 ] || [ ${stts} = 10 ]; then # If there is new content to learn, even if the topic has already been learned or is waiting for review.
            
                calculate_review "${tpc}"; 

                if [[ ${days_to_review_porcent} -ge 100 ]]; then

                    days_to_review_porcent=100
                    dialog_1; ret=$?
                    
                    if [ $ret -eq 2 ]; then
                    
                        "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                        
                        idiomind topic & oclean; return 1
                        
                    elif [ $ret -eq 3 ]; then
                    
                       oclean & return 1
                    fi
                fi
                
                [[ ${days_to_review_porcent} -ge 100 ]] && info5="$(gettext "(completado)")"

                pres="<big><b>$(gettext "Topic learnt")</b></big>  <sup>$(gettext "* however you have new notes").</sup>\n   <small>$label_review</small>\n\n<sub>$(gettext "Waiting Days:")  $days_to_review</sub>\n<sub>$(gettext "Spacing Intervals for Review:") $label_serie</sub>"
                echo "N2 / ${cfg0} / ${cfg1} / ${cfg2}"
                
                notebook_2

            else
                echo "N1 / ${cfg0} / ${cfg1} / ${cfg2}"
                
                notebook_1
            fi
                ret=$?
                
                if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 ] || [ $ret -eq 3 ]; then apply; fi
                
                if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -eq 0 ] && [ ${cfg0} -ge 1 ]; then # if not content to learn
        
        
            if [ ${stts} = 1 ] || [ ${stts} = 2 ] || [ ${stts} = 5 ] || [ ${stts} = 6 ]; then
                stts_prev=${stts}
                "$DS/mngr.sh" mark_as_learned "${tpc}" 0
                # mark_as_learned just persisted a new status (e.g. 1 -> 3).
                # Re-sync the in-memory status and go around the loop so readd()
                # recomputes cfg/labels with the fresh status before we draw, so
                # this very render shows "Waiting to review for the first time"
                # instead of the stale "Learning...".
                stts_new=$(sed -n 1p "${DC_tlt}/stts")
                ! [[ ${stts_new} =~ $numer ]] && stts_new=${stts_prev}
                if [ "${stts_new}" != "${stts_prev}" ]; then
                    stts=${stts_new}; stts_orig=${stts_new}
                    continue
                fi
                stts=${stts_new}
			fi
			
            calculate_review "${tpc}"
            
            if [[ ${days_to_review_porcent} -ge 100 ]]; then
            
                days_to_review_porcent=100; dialog_1; ret=$?
                
                if [ $ret -eq 2 ]; then
                
                    "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                    
                    idiomind topic & oclean; return 1
                    
                elif [ $ret -eq 3 ]; then
                
                    oclean & return 1
                fi 
            fi
            
            [ ${days_to_review_porcent} -ge 100 ] && info5="$(gettext "(completado)")"
			pres="<big><b>$(gettext "Topic learnt")</b></big>\n   <small>$label_review</small>\n\n<sub>$(gettext "Waiting Days:")  $days_to_review</sub>\n<sub>$(gettext "Spacing Intervals for Review:") $label_serie</sub>"
            
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            
            notebook_2; ret=$?
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 ]; then 
				apply
            fi

        fi

    elif [[ ${stts} = 0 ]]; then
    
        if [ -f "${DC_tlt}/tpc-journal" ]; then exit 1; else readd; fi
        
        if [ ${cfg0} -lt 1 ]; then
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            
            notebook_1; ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -ge 1 ]; then
        
            if [ ${stts} = 3 ] || [ ${stts} = 4 ] || [ ${stts} = 7 ] || [ ${stts} = 8 ] || [ ${stts} = 9 ] || [ ${stts} = 10 ]; then
                echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
                
                notebook_2
            else
                echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
                
                notebook_1
            fi
            ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi
            
        elif [[ ${cfg1} -eq 0 ]]; then
        
            calculate_review "${tpc}"
            
            pres="<big><b>$(gettext "Topic learnt")</b></big>\n   <small>$label_review</small>\n\n<sub>$(gettext "Waiting Days:")  $days_to_review</sub>\n<sub>$(gettext "Spacing Intervals for Review:") $label_serie</sub>"
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            
            notebook_2; ret=$?
        fi
        
    else
        tpa="$(sed -n 1p "$DC_s/tpc")"
        if [ -f "$DS/ifs/mods/main/${tpa}.sh" ] ; then
            source "$DS/ifs/mods/main/${tpa}.sh"; ${tpa} &
        else
            echo 13 > "${DC_tlt}/stts"
            > "$DC_s/tpc"
            "$DS/mngr.sh" mkmn 1
        fi
    fi
    
        # If a review action changed the persisted status while this dialog was
        # open, re-render immediately with the fresh state instead of waiting for
        # an application restart.
        new_stts=$(sed -n 1p "${DC_tlt}/stts")
        if ! [[ ${new_stts} =~ $numer ]]; then new_stts=${stts}; fi
        if [ "${new_stts}" != "${stts_orig}" ]; then
            stts_orig=${new_stts}
            continue
        fi
        break
    done
    
    oclean & return 0
}

# Inicio en segundo plano, utilizado por el modo autostart.
# Retrasa la creación de la sesión para dejar finalizar la inicialización
# del entorno de escritorio.
bground_session() {
    source "$DS/ifs/cmns.sh"
    sleep 5
    if [ ! -e "$DT/ps_lk" ] && [ ! -d "$DT" ]; then
         new_session
    fi
    if [[ $(cdb ${cfgdb} 1 opts itray) = TRUE ]] && \
    ! pgrep -f "$DS/ifs/tls.sh itray"; then
    export cu=TRUE
    _start 0; fi
}

ipanel() {
    source "$DS/ifs/mods/main/items_list.sh"
    source "$DS/ifs/cmns.sh"
    set_geom(){
        sleep 1
        spost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
        cdb ${cfgdb} 3 geom vals ${cpost}
        for n in {1..10}; do
            sleep 1
            cpost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
            if [ -z ${cpost} ]; then break; return 1; fi
            if [ ${spost} != ${cpost} ]; then
                spost=${cpost}
                cdb ${cfgdb} 3 geom vals ${cpost}
            fi
        done
    } >/dev/null 2>&1
    
    geometry=$(cdb ${cfgdb} 1 geom vals)
    if [ -n "$geometry" ]; then
    geometry="--geometry=$geometry"
    else geometry="--mouse"; fi
    (panelini; if [ $? != 0 ] && ! pgrep -f "$DS/ifs/tls.sh itray"; then \
    "$DS/stop.sh" 1 & fi; exit ) & set_geom
}

# Punto de entrada del inicio normal. Determina si debe crearse una nueva
# sesión y prepara la interfaz/panel.
_start() {
    source "$DS/ifs/cmns.sh"
    if [ ! -d "$DT" ] && [[ -z "$1" ]]; then 
        new_session
    fi
    if [ ! -f "$DT/tpe" ]; then
        cu=TRUE; touch "$DT/tpe"
    fi
    if [ "$(< "$DT/tpe")" != "${tpc}" ]; then
        touch "$DT/tpe"
    fi
    date=$(cdb ${cfgdb} 1 sess date)
    if [[ "$(date +%d)" != "$date" ]] && [[ -z "$1" ]]; then
        new_session; cu=TRUE
    fi
    ( if [[ "${cu}" = TRUE ]]; then
    "$DS/ifs/tls.sh" a_check_updates & fi ) &

    if [[ $(cdb ${cfgdb} 1 opts itray) = TRUE ]]; then
        if ! pgrep -f "$DS/ifs/tls.sh itray"; then
            $DS/ifs/tls.sh itray &
             ( sleep 4; if ! pgrep -f "$DS/ifs/tls.sh itray"; then
				msg "$(gettext "Sorry, your System not support icon tray")" dialog-warning
				idiomind panel
			 fi )
        fi
    else
        if ! pgrep -f "yad --title="Idiomind" --list"; then
            idiomind panel &
        fi
    fi
}

# Despacho principal de operaciones. main.sh actúa como punto de entrada
# común para configuración, inicio normal, autostart y comandos específicos.
case "$1" in
    -v|--version)
    source $DS/default/sets.cfg
    echo -n "$_version" ;;
    -s)
    # Fuerza la creación de una nueva sesión y abre la interfaz principal.
    new_session; idiomind ;;
    topic)
    topic ;;
    first_run)
    "$DS/ifs/tls.sh" "$@" ;;
    index)
    "$DS/mngr.sh" mkmn 0 ;;
    autostart)
    # Inicio automático: la sesión se crea mediante bground_session().
    bground_session ;;
    --add)
   "$DS/add.sh" new_items "${dir}" 2 "${2}" ;;
    add)
    "$DS/add.sh" new_item '__cmd__' "$(sed -n 1p "$DC_s/tpc")" "${2}" "${3}" ;;
    new_topic)
    "$DS/add.sh" new_topic "" "" "$2" ;;
    tasks)
    "$DS/ifs/mods/start/update_tasks.sh" ;;
    panel)
    ipanel ;;
    stop)
    "$DS/stop.sh" 2 ;;
    update_addons)
    "$DS/ifs/tls.sh" update_addons ;;
    restart_topic)
    "$DS/mngr.sh" restartTopic ;;
    update_resources)
    "$DS_a/Resources/cnfg.sh" updt_scripts ;;
    *)
    # Check if command is provided by an addon
    _addon_cmd_found=0
    if [ -n "$1" ]; then
        for addon_dir in "$DS"/addons/*/; do
            [ -d "$addon_dir" ] || continue
            commands_file="${addon_dir}commands.sh"
            if [ -f "$commands_file" ]; then
                while IFS='|' read -r cmd_name cmd_desc cmd_script; do
                    # Skip comments and empty lines
                    [[ "$cmd_name" =~ ^[[:space:]]*# ]] && continue
                    [ -z "$cmd_name" ] && continue
                    if [ "$1" = "$cmd_name" ]; then
                        _addon_script="${addon_dir}${cmd_script}"
                        if [ -f "$_addon_script" ]; then
                            shift
                            bash "$_addon_script" "$@"
                            _addon_cmd_found=1
                            break 2
                        fi
                    fi
                done < "$commands_file"
            fi
        done
    fi
    # If no addon command found, run default startup
    if [ $_addon_cmd_found -eq 0 ]; then
        _start
    fi ;;
esac
