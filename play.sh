#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "$DS/default/sets.cfg"

# Dependencias explícitas (antes heredadas del padre):
# cmns.sh aporta msg/tpc_db/cleanups; gui/play.sh la GUI (con guarda).
if [ -n "${DS:-}" ] && [ -r "$DS/ifs/cmns.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/ifs/cmns.sh"
fi
if [ -n "${DS:-}" ] && [ -r "$DS/gui/play.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/play.sh"
fi


play_word() {

	w="$(sed 's/<[^>]*>//g' <<<"${2}")"
	echo "$w"
	# When previewing a portable .idmnd package before it is installed,
	# resolve the note's cdid from the package data instead of the
	# (not yet existing) installed topic data file.
	data_src="${IDMND_PREVIEW_DATA:-$DC_tlt/data}"
	item="$(grep -F -m 1 "trgt{${w}}" "$data_src" |sed 's/}/}\n/g')"
    type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
    cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
    
    if ps -A | pgrep -f 'play'; then killall 'play'; fi
	if ps -A | pgrep -f 'espeak'; then killall 'espeak'; fi
		
    
    # Portable .idmnd preview: use audio directly from the extracted package.
	# Only this preview-specific path is added; normal playback below is unchanged.
	if [ -n "$IDMND_PREVIEW_MEDIA" ]; then
		preview_pid_file="$DT/idmnd_preview_play.pid"

		# Detener solamente el audio anterior del preview.
		if [ -f "$preview_pid_file" ]; then
			preview_pid="$(cat "$preview_pid_file" 2>/dev/null)"
			if [ -n "$preview_pid" ] && kill -0 "$preview_pid" 2>/dev/null; then
				kill "$preview_pid" 2>/dev/null
			fi
			rm -f "$preview_pid_file"
		fi

		for audio_file in \
			"$IDMND_PREVIEW_MEDIA/audio/topic/${cdid}.mp3" \
			"$IDMND_PREVIEW_MEDIA/audio/shared/${cdid}.mp3" \
			"$IDMND_PREVIEW_MEDIA/audio/topic/${3}.mp3" \
			"$IDMND_PREVIEW_MEDIA/audio/shared/${3}.mp3" \
			"$IDMND_PREVIEW_MEDIA/audio/shared/${w,,}.mp3"; do
			if [ -f "$audio_file" ]; then
				play "$audio_file" &
				echo $! > "$preview_pid_file"
				exit
			fi
		done
	else
	   
	
		if [ -f "$DT/${cdid}.mp3" ]; then 
			play "$DT/${cdid}.mp3" &
		elif [ -f "${DM_tlt}/$cdid.mp3" ]; then
			play "${DM_tlt}/$cdid.mp3" &
		elif [ -f "$DT/${3}.mp3" ]; then 
			play "$DT/${3}.mp3" &
		elif [ -f "${DM_tlt}/$3.mp3" ]; then
			play "${DM_tlt}/$3.mp3" &
		elif [ -f "${DM_tls}/audio/${w,,}.mp3" ]; then
			play "${DM_tls}/audio/${w,,}.mp3" &
			
			
		elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
			for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
				Script="$DS_a/Resources/scripts/$(basename "${Script}")"
				[ -f "${Script}" ] && "${Script}" "${w}" "$DT/${3}.mp3"
				if [ -f "$DT/${3}.mp3" ]; then 
					break
				fi
			done
			if [ -f "$DT/${3}.mp3" ]; then 
				play "$DT/${3}.mp3" && rm -f "$DT/${3}.mp3"
			else
				# si hubo error al procesar tts offline se opta por espeak
				sed 's/<[^>]*>//g' <<< "${w}." |espeak -v ${tlangs[$tlng]} \
				-a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
				-g ${sWordgap} -b ${sEncoding} &
			fi
		else
			echo "${w}." |espeak -v ${tlangs[$tlng]} \
			-a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
			-g ${sWordgap} -b ${sEncoding} &
		fi
		
		exit
    fi
    
} >/dev/null 2>&1

play_sentence() {
	
    if ps -A | pgrep -f 'play'; then killall 'play'; fi
    if ps -A | pgrep -f 'espeak'; then killall 'espeak'; fi
    
    if [ -f "${DM_tlt}/$2.mp3" ]; then
        play "${DM_tlt}/$2.mp3" & 
    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${trgt}." "$DT/${trgt}.mp3"
			if [ -f "$DT/${trgt}.mp3" ]; then 
				break
			fi
		done
		if [ -f "$DT/${trgt}.mp3" ]; then
			play "$DT/${trgt}.mp3" && rm -f "$DT/${trgt}.mp3"
		else
			sed 's/<[^>]*>//g' <<< "${trgt}." |espeak -v ${tlangs[$tlng]} \
			-a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
			-g ${sWordgap} -b ${sEncoding} &
		fi
    else
        sed 's/<[^>]*>//g' <<< "${trgt}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
        -g ${sWordgap} -b ${sEncoding} &
    fi

    exit 
    
} >/dev/null 2>&1

play_file() {
    if [ -f "${2}" ]; then
        if [[ ${mime} = 0 ]]; then
            exit 1
        else
            mplayer "${2}" -novideo -noconsolecontrols -title "${3}"
        fi
    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${3}." "$DT/out.mp3"
			if [ -f "$DT/out.mp3" ]; then 
				play "$DT/out.mp3"
				rm -f "$DT/out.mp3"; break & exit
			fi
		done
    else
        sed 's/<[^>]*>//g' <<<"${3}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding}
    fi
} >/dev/null 2>&1

play_stop() {
	
    source "/usr/share/idiomind/default/c.conf"
    if [ -f "$DT/playlck" ]; then
        if [ "$(< $DT/playlck)" = '0' ]; then
            "$DS/bcle.sh" &
        else
            "$DS/stop.sh" 2 &
        fi
    else
        "$DS/bcle.sh" &
    fi
}

case "$1" in
    play_word)
    play_word "$@" ;;
    play_sentence)
    play_sentence "$@" ;;
    play_file)
    play_file "$@" ;;
    play_list2)
    play_list2 "$@" ;;
    play_list)
    gui_play_lists_options "$@" ;;
    playstop)
    play_stop "$@" ;;
esac
