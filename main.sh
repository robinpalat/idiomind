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
# Se considera no inicializado tanto si falta el directorio de datos como
# si falta la base de configuración (inicialización parcial).
if [ ! -d "$HOME/.idiomind" ] || [ ! -f "$HOME/.config/idiomind/config" ]; then
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
    
	$DS/ifs/extensions/start/update_tasks.sh


    for strt in "$DS/ifs/extensions/start"/*; do
		if grep tasks <<<"$strt">/dev/null 2>&1; then :
		else
			( export IDIOMIND_NONINTERACTIVE=1; sleep 2 && "${strt}" )
		fi
	done &
    
    # make index
    "$DS/mngr.sh" mkmn 0 &
    echo -e "\ttopics ok\n"
    echo 0 > "$DT/playlck"
    
    # Calcula las estadísticas en segundo plano después de un breve retraso.
    ( source "$DS/ifs/stats.sh"; sleep 5; export val1=0 val2=0; pre_comp ) &
}

# View / istall tpc (.idmnd import is owned by ifs/idmnd.sh)
if grep -o '.idmnd' <<<"${1: -6}" >/dev/null 2>&1; then
    source "$DS/ifs/idmnd.sh"
    idmnd_import "$1"
fi

function topic() {
    source "$DS/ifs/cmns.sh"
    f_lock 0 "$DT/tpc_lk"
    export -f tpc_db msg
    [ -f "${DC_tlt}/stts" ] && stts=$(sed -n 1p "${DC_tlt}/stts")

    if ! [[ ${stts} =~ $numer ]]; then return 1; fi

    readd(){
        [ -z "${tpc}" ] && return 1
        source "$DS/gui/topic.sh"
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
		labels_status=("$(gettext "Learning")" "$(gettext "Reviewing for the first time")" "$(gettext "Reviewing for the second time")" "$(gettext "Reviewing for the third time")" "$(gettext "Reviewing for the fourth time")" "$(gettext "Reviewing for the fifth time")" "$(gettext "Reviewing for the sixth time")" "$(gettext "Reviewing for the seventh time")" "$(gettext "Final review")" "$(gettext "Final review")")
		[ ${count_date_reviews} -gt 0 ] && btn_review="$(gettext "Finalize Review")" || btn_review="$(gettext "Mark as Learnt")"

	elif [ ${stts} -eq 3 ] || [ ${stts} -eq 4 ]; then

		labels_status=( " " "$(gettext "Waiting for the first review")" "$(gettext "Waiting for the second review")" "$(gettext "Waiting for the third review")" "$(gettext "Waiting for the fourth review")" "$(gettext "Waiting for the fifth review")" "$(gettext "Waiting for the sixth review")" "$(gettext "Waiting for the seventh review")" "$(gettext "Waiting for the eighth review")" "$(gettext "Waiting for the ninth review")" "$(gettext "Second reminder to review")")
		[ ${count_date_reviews} -gt 0 ] && btn_review="$(gettext "Back to Review")" || btn_review="$(gettext "Review")"

	elif [ ${stts} = 5 ] || [ ${stts} = 6 ]; then

		labels_status=("$(gettext "Learning")" "$(gettext "Reviewing for the first time")" "$(gettext "Reviewing for the second time")" "$(gettext "Reviewing for the third time")" "$(gettext "Reviewing for the fourth time")" "$(gettext "Reviewing for the fifth time")" "$(gettext "Reviewing for the sixth time")" "$(gettext "Reviewing for the seventh time")" "$(gettext "Final review")" "$(gettext "Final review")")
		btn_review="$(gettext "Finalize Review")"

	elif [ ${stts} -gt 6 ] && [ ${stts} -lt 11 ]; then

		labels_status=( " " "$(gettext "Ready for the first review")" "$(gettext "Ready for the second review")" "$(gettext "Ready for the third review")" "$(gettext "Ready for the fourth review")" "$(gettext "Ready for the fifth review")" "$(gettext "Ready for the sixth review")" "$(gettext "Ready for the seventh review")" "$(gettext "Ready for the eighth review")" "$(gettext "Ready for the final review")" "$(gettext "Second reminder to review")")
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
			days_until=""

		elif [ ${count_date_reviews} = 1 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<u><b>4</b></u> <span color='#84DCE7E7'>| 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until first review:") "

		elif [ ${count_date_reviews} = 2 ]; then
						label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 |</span> <u><b>7</b></u> <span color='#84DCE7E7'>| 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until second review:") "

		elif [ ${count_date_reviews} = 3 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4  | 7 |</span> <u><b>7</b></u> <span color='#84DCE7E7'>| 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"

			days_until="$(gettext "Days remaining until third review:") "

		elif [ ${count_date_reviews} = 4 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 |</span> <u><b>10</b></u> <span color='#84DCE7E7'>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"

			days_until="$(gettext "Days remaining until fourth review:") "

		elif [ ${count_date_reviews} = 5 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<u><b>15</b></u> <span color='#A36A53'>| 15 | 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until fifth review:") "

		elif [ ${count_date_reviews} = 6 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 |</span> <u><b>15</b></u> <span color='#A36A53'>| 20 | 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until sixth review:") "

		elif [ ${count_date_reviews} = 7 ]; then
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 |</span> <u><b>20</b></u> <span color='#A36A53'>| 30</span>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until seventh review:") "

		elif [ ${count_date_reviews} = 8 ]; then

			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 |</span> <u><b>30</b></u>\n		
<small>$(gettext "Mastered")</small>
<span color='#844DB1'>60</span>"
			
			days_until="$(gettext "Days remaining until eighth review:") "

		elif [ ${count_date_reviews} -ge 9 ]; then
			
			label_serie="
\n<small>$(gettext "Fresh")</small>
<span color='#84DCE7E7'>4 | 7 | 7 | 10</span>\n
<small>$(gettext "Familiar")</small>
<span color='#A36A53'>15 | 15 | 20 | 30 </span>\n		
<small>$(gettext "Mastered")</small>
<u><b>60</b></u>"
			
			days_until="$(gettext "Days remaining until final review:") "
		fi

        export lbl1 label_serie
    }
    
    oclean() { cleanups "$cnf1" "$cnf3" "$cnf4" "$DT/tpc_lk"; rm -f "$DT"/list_*.fifo 2>/dev/null; }
    
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
				
				info6="$days_until  $days_remaining / $days_to_review "
                pres="<big><b>$(gettext "Topic learnt")</b></big>  <sup>$(gettext "* however you have new notes").</sup>\n   <small>$label_review</small>\n\n<b>$(gettext "Spaced repetition schedule")</b>\n<sub>$(gettext "Current interval (days):")</sub>$label_serie"
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
            info6="$days_until  $days_remaining / $days_to_review "
			pres="<big><b>$(gettext "Topic learnt")</b></big>\n<small>$label_review</small>\n\n<b>$(gettext "Spaced repetition schedule")</b>\n<sub>$(gettext "Current interval (days):")</sub>$label_serie"
            
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
            info6="$days_until  $days_remaining / $days_to_review "
            pres="<big><b>$(gettext "Topic learnt")</b></big>\n<small>$label_review</small>\n\n<b>$(gettext "Spaced repetition schedule")</b>\n<sub>$(gettext "Current interval (days):")</sub>$label_serie"
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            
            notebook_2; ret=$?
        fi
        
    else
        tpa="$(sed -n 1p "$DC_s/tpc")"
        if [ -f "$DS/ifs/extensions/main/${tpa}.sh" ] ; then
            source "$DS/ifs/extensions/main/${tpa}.sh"; ${tpa} &
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
    source "$DS/gui/topic.sh"
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
# (inicialización ya realizada arriba) y como dispatcher de comandos:
# sabe cómo ejecutar comandos, pero el catálogo vive en
# $DS/ifs/extensions/commands/ (manifest `core` + addons).
source "$DS/ifs/extensions/commands/core.d/core.sh"

# Resuelve un nombre de comando en el registry (core + addons).
# Salida por variables: _cmd_provider ("" si no existe, "CONFLICT" si
# hay varios proveedores) y _cmd_target (objetivo del manifest).
# Los objetivos "@nombre" son funciones internas (sin argumentos,
# igual que el case anterior); el resto son rutas de script.
_resolve_command() {
    _cmd_provider=""; _cmd_target=""
    [ -n "$1" ] || return 0
    [ -d "$DS/ifs/extensions/commands" ] || return 0
    for _manifest in "$DS"/ifs/extensions/commands/*; do
        [ -f "$_manifest" ] || continue
        _cmd_provider_name="${_manifest##*/}"
        while IFS='|' read -r _cmd_name _cmd_desc _cmd_script; do
            [[ "$_cmd_name" =~ ^[[:space:]]*# ]] && continue
            [ -z "$_cmd_name" ] && continue
            [ "$1" = "$_cmd_name" ] || continue
            if [ -n "$_cmd_provider" ]; then
                echo "Command conflict: '$1'" >&2
                echo "  Provided by: $_cmd_provider" >&2
                echo "  Provided by: $_cmd_provider_name" >&2
                _cmd_provider="CONFLICT"; _cmd_target=""
                return 0
            fi
            _cmd_provider="$_cmd_provider_name"; _cmd_target="$_cmd_script"
        done < "$_manifest"
    done
}

if [ -n "$1" ]; then
    _resolve_command "$1"
    if [ "$_cmd_provider" = "CONFLICT" ]; then
        : ;# conflicto ya reportado: sin ejecución ni fallback, igual que antes
    elif [ "${_cmd_target#@}" != "$_cmd_target" ]; then
        # Función interna, sin argumentos (igual que el case anterior).
        "${_cmd_target#@}"
    elif [ -n "$_cmd_provider" ]; then
        if [ "$_cmd_provider" = "core" ]; then
            _resolved_script="$DS/ifs/extensions/commands/core.d/$_cmd_target"
            _cmd_kind="Core"
        else
            _resolved_script="$DS/addons/${_cmd_provider}/${_cmd_target}"
            _cmd_kind="Addon"
        fi
        if [ -f "$_resolved_script" ]; then
            shift
            if [ "$_cmd_provider" = "core" ]; then
                # Los comandos core propagan el exit, igual que el case nativo.
                bash "$_resolved_script" "$@"
            else
                bash "$_resolved_script" "$@"
                # El case anterior descartaba el exit del script addon
                # (terminaba en `if...fi` sin else -> 0); se preserva.
                :
            fi
        else
            echo "$_cmd_kind command '$1' registered but script not found:" >&2
            echo "  Expected: $_resolved_script" >&2
        fi
    else
        _start
    fi
else
    _start
fi
