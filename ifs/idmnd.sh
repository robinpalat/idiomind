#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# idmnd.sh — módulo responsable de los archivos .idmnd
#
# Funciones principales:
#   - Detectar el tipo de .idmnd.
#   - Validar el formato.
#   - Preparar el contenido para preview/standalone.
#   - Realizar la importación cuando el usuario confirma.
#
# Este archivo es solo definiciones: debe cargarse con "source" en el
# mismo shell del flujo existente, nunca ejecutarse como proceso
# separado, porque las funciones exportan variables que el flujo
# de importación utiliza después (name/slng/tlng/.../ilnk/note,
# otranslations, tsets[$n]).
#
# Primera extracción: check_format_1() (formato legacy), trasladada
# byte-idéntica desde ifs/tls.sh. main.sh la consume con:
#
#     source "$DS/ifs/idmnd.sh"
#     check_format_1 "${file}"   # éxito cuando retorna 19
#
# Dependencias reales de check_format_1():
#   - DM, DS, tlng, slng : entorno vía default/c.conf (ya cargado por
#     main.sh; la función re-sourcea c.conf solo si DM está vacío).
#   - tlangs, slangs, Categories, tsets : vía source de
#     default/sets.cfg DENTRO de la función (function-local, igual
#     que antes; no tocar).
#   - numer, msg : vía source de ifs/cmns.sh DENTRO de la función.
#   - python3, wc, sed, tr, cut, grep : utilidades del sistema.
#
# Tercera extracción (estructural, sin cambios de comportamiento):
# el flujo A–K vive en idmnd_import() como orquestador fino:
#   idmnd_prepare_source  (origen: archivo/directorio/ZIP)
#   idmnd_detect_validate (puerta v1/v2 + validación)
#   idmnd_prepare_preview (KEY/itxt/_lst/_info/IDMND_PREVIEW_*)
#   idmnd_confirm         (tpc_view/ret; 0=instalar, 1=cancelar)
#   idmnd_create_topic    (dedup/dirs/SQLite base/Data)
#   idmnd_populate_db     (parse_item + carga SQLite)
#   idmnd_finalize        (colorize/multimedia/LP/estado/menú/apertura)
# main.sh solo detecta el .idmnd y delega: idmnd_import "$1".
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



function idmnd_import() {
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    slngcurrent="$slng"; tlngcurrent="$tlng"
    source "$DS/ifs/cmns.sh"
    source "$DS/ifs/tls.sh"
    source "$DS/ifs/idmnd.sh"

    idmnd_prepare_source "$1"
    idmnd_detect_validate
    idmnd_prepare_preview
    if idmnd_confirm; then
        idmnd_create_topic
        idmnd_populate_db
        idmnd_finalize
    fi
    # stop any audio still playing from the preview when the viewer closes
    "$DS/stop.sh" 2
    cleanups "$tmpdir"
    exit 0
}


function idmnd_prepare_source() {
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
}


function idmnd_detect_validate() {
    # Puerta de formato: v2 (objeto único) vs legacy (3 líneas L1/L2/L3).
    # El camino legacy queda byte-idéntico.
    IDMND_V2=""; V2_PICK=""; V2_PICK_DISPLAY=""; V2_UCODE=""
    if jq -e '.format == "idiomind-topic/2"' "${file}" >/dev/null 2>&1; then
        check_format_2 "${file}" || {
            cleanups "$tmpdir"
            msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
        }
        # v2: idioma elegido = configurado si existe en src; si no, es (o 1º).
        # Los packs externos no participan en v2.
        # (sets.cfg aquí: slangs es function-local donde se sourcea.)
        source "$DS/default/sets.cfg"
        V2_UCODE="${slangs[$slngcurrent]:-}"
        if [ -n "$V2_UCODE" ] && jq -e --arg c "$V2_UCODE" \
            '.items | to_entries[0].value.src | has($c)' "${file}" >/dev/null 2>&1; then
            V2_PICK="$V2_UCODE"
        else
            V2_PICK="$(jq -r '.items | to_entries[0].value.src | keys | if index("es") then "es" else sort[0] end' "${file}")"
            V2_UCODE=""
        fi
        V2_PICK_DISPLAY="$(v2_display_name "$V2_PICK" 2>/dev/null)" || V2_PICK_DISPLAY="$V2_PICK"
        if [ -z "$V2_PICK_DISPLAY" ]; then V2_PICK_DISPLAY="$V2_PICK"; fi
    else
        cleanups "$tmpdir"
        msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1
    fi
}


function idmnd_prepare_preview() {
    c=$((RANDOM%100000)); export KEY=$c
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    level="${lv[${levl}]}"
    itxt="<span font_desc='Droid Sans Bold 12'>$name</span><small>\n$(gettext "Notes:")  $nwrd $(gettext "Words"),  \
$nsnt $(gettext "Sentences"),  $nimg $(gettext "Images")\n$(gettext "Level:") \
$level \n$(gettext "Language:") $(gettext "$tlng"),  $(gettext "Translation:") $(gettext "$slng")$otranslations</small>" 
    dclk="$DS/play.sh play_word"
    source "$DS/gui/topic.sh"
	_lst() {
		# v2: la vista previa sale de las líneas ya materializadas
		# (forma legacy trgt{}/srce{}); el parser legacy sigue igual.
		if [ -n "${IDMND_V2:-}" ] && [ -n "${IDMND_PREVIEW_DATA:-}" ] \
		&& [ -f "$IDMND_PREVIEW_DATA" ]; then
			while IFS= read -r line || [[ -n "$line" ]]; do
				[ -z "${line//[[:space:]]/}" ] && continue
				_t="$(grep -oP '(?<=trgt\{)[^}]*' <<< "$line" | head -n1)"
				_s="$(grep -oP '(?<=srce\{)[^}]*' <<< "$line" | head -n1)"
				printf '%s\n%s\n' "$_t" "$_s"
			done < "$IDMND_PREVIEW_DATA"
			return 0
		fi
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

		if [ -n "${IDMND_V2:-}" ]; then
			v2_materialize "${file}" "$V2_PICK" "$P_DATA" \
			|| { cleanups "$tmpdir"; msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1; }
		fi
		export IDMND_PREVIEW_DATA="$P_DATA"
		fi
}


function idmnd_confirm() {
    tpc_view
    ret=$?
    [ $ret -eq 0 ] || return 1
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
    return 0
}


function idmnd_create_topic() {
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
            
            if [ -n "${IDMND_V2:-}" ]; then
                v2_materialize "${file}" "$V2_PICK" "${DC_tlt}/data" \
                || { cleanups "$tmpdir"; msg "$(gettext "File format corrupted")\n" dialog-error "$(gettext "Information")" & exit 1; }
            fi
            export data="${DC_tlt}/data"
}


function idmnd_populate_db() {
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
}


function idmnd_finalize() {
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
            
            slng="$slngcurrent"
            cdb "${cfgdb}" 3 lang tlng "${tlng}"
            cdb "${cfgdb}" 3 lang slng "${slng}"
            if [ -n "${IDMND_V2:-}" ]; then
                # v2: el source ya viene materializado del .idmnd.
                # Sin lfetch, sin Google, sin inventar idiomas.
                # slng_err = instalado pero el idioma del usuario no disponible:
                # contiene el codigo ISO del idioma que quedo activo.
                tpc_db 9 id slng "$V2_PICK_DISPLAY"
                if [ -n "$V2_UCODE" ] && [ "$V2_PICK" = "$V2_UCODE" ]; then
                    : # compatible: sin active ni slng_err (como legacy match)
                else
                    echo "$V2_PICK" > "${DC_tlt}/slng_err"
                fi
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
}
