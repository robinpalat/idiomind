#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

if [ -z $1 ]; then
	msj=$(sed -n 1p $DC_s/cnfg20)
	cn=$(sed -n 2p $DC_s/cnfg20)
	[[ -z "$cn" ]] && msj=" ( $no_defined )" || img="$cn"

	yad --center --align=center --text="  $recording: $msj" \
	---name=idiomind --geometry=0-0-0-0 --width=350 --height=120 \
	--on-top --skip-taskbar --center --window-icon=idiomind \
	--button="$change":2 --button=gtk-apply:3 --borders=10 --title=" "
	ret=$?

	if [[ $ret -eq 2 ]]; then
		$DS/audio/cnfg.sh chng
		$DS/audio/cnfg.sh
		exit 1
	fi
fi

if [ $1 = edt ]; then
	prm=$(sed -n 17p $DC_s/cnfg1)
	aud="$1"
	dir="$2"
	(cd "$aud"
	$edta "$aud") & exit 1
	
elif [ $1 = rec ]; then

	paud=$(sed -n 17p $DC_s/cnfg1)
	DT_r="$2"
	t="$3"
	killall play
	inf=$(sed -n 1p $DC_s/cnfg20)
	rm -f $DT_r/audtm.mp3
	$yad --align=center --timeout="$t" \
	--text=" $inf  $recording2...\n\n" \
	--timeout-indicator=bottom --geometry=0-0-0-0 \
	--image-on-top --width=350 --height=100 \
	--on-top --skip-taskbar --no-buttons --center \
	--window-icon=idiomind --center --borders=10 \
	--title=" " \
	--field="\\n\\n$NAME":lbl &
	sox -t alsa default $DT_r/audtm.mp3 \
	silence 1 0.1 5% 1 1.0 5% &
	sleep 10
	killall -9 sox
	killall sox & killall rec
	exit 1

elif [ $1 = add ]; then
	NM=$(cat $DT/.titl)
	cd ~/
	file=$(yad --center --borders=10 --file-filter="*.mp3" \
	--window-icon=idiomind --skip-taskbar --title="add_audio" \
	--on-top --title=" " --file --width=600 --height=500 )
		if [ -z "$file" ];then
			exit 1
		else
			cp -f "$file" $DT_r/audtm.mp3
		fi
elif [ $1 = chng ]; then

	cd $DS/audio/
	IFS=''
	grep_index="egrep '^[*\ ]*index:\ +[[:digit:]]+$' | egrep -o '[[:digit:]]+'"
	pacmd_set_default_command="pacmd set-default-source"
	pacmd_index_1="$(pacmd list-source-outputs | eval $grep_index)"
	pacmd_index_2="$(pacmd list-sources | eval $grep_index)"
	pacmd_move_command="pacmd move-source-output"
	pacmd_list_data=$(pacmd list-sources)
	message_base=" "
	IFS=$' \n'
	get_pacmd_section () {
		l1_section=$1
		l2_section=$2
		l3_section=$3
		is_l1_section=false
		is_l2_section=false; [[ -z $l2_section ]] && is_l2_section=true
		is_l3_section=false; [[ -z $l3_section ]] && is_l3_section=true
		echo "$pacmd_list_data" | while read line; do
			if [[ "$line" =~ ^[*\ ]*index:\ +([[:digit:]]+) ]]; then

				if [[ ${BASH_REMATCH[1]} == $l1_section ]]; then
					is_l1_section=true
				else
					is_l1_section=false
				fi
			fi
			if [[ -n $l2_section ]] && [[ "$line" =~ ^$'\t'{1}([[:alpha:] -]+): ]]; then

				if  [[ ${BASH_REMATCH[1]} == $l2_section ]]; then
					is_l2_section=true
				else
					is_l2_section=false
				fi
			fi
			if [[ -n $l3_section ]] && [[ "$line" =~ ^$'\t'{2}([[:alpha:] -]+): ]]; then

				if  [[ ${BASH_REMATCH[1]} == $l3_section ]]; then
					is_l3_section=true
				else
					is_l3_section=false
				fi
			fi
			if $is_l1_section && $is_l2_section && $is_l3_section; then
				echo $line
			fi
	done
	}

	if [[ "$0" =~ -([[:digit:]]+)\.sh$ ]]; then
		id=${BASH_REMATCH[1]}
	else

		default=$(echo "$pacmd_list_data" | egrep '^ *\* *index:')
		[[ "$default" =~ ^\ *\*\ *index:\ +([[:digit:]]+) ]] || exit 1
		default_id="${BASH_REMATCH[1]}"

		list=($pacmd_index_2)

		for ((x=0, max=${#list[@]}; x<$max; x++)); do
			while read line; do
				if [[ "$line" =~ ^$'\t'{2}device.class\ =\ \"(.*)\"$ ]]; then
					device_class=${BASH_REMATCH[1]}
			if [[ $device_class != "sound" ]]; then
						unset list[$x]
			fi
				fi
			done <<< "$(get_pacmd_section ${list[$x]} properties)"
		done

		if [[ -z ${list[@]} ]]; then
			echo "There are no any devices"
			exit 0
		fi

		list=($(echo ${list[@]}))

		list=(${list[@]} ${list[0]})
		for ((x=0, id=${list[0]}, max=${#list[@]}-1; x<$max; x++)); do
			if [[ ${list[$x]} == $default_id ]]; then
				id=${list[$x+1]}
				break
			fi
		done
	fi

	$pacmd_set_default_command $id > /dev/null
	for index in $pacmd_index_1; do
		$pacmd_move_command $index $id > /dev/null;
	done

	while read line; do
		if [[ "$line" =~ ^$'\t'{2}alsa.card_name\ =\ \"(.*)\"$ ]]; then
			alsa_card_name=${BASH_REMATCH[1]}
			message="$message_base $id - $alsa_card_name"
		fi
		if [[ "$line" =~ ^$'\t'{2}device.icon_name\ =\ \"(.*)\"$ ]]; then
			device_icon_name=${BASH_REMATCH[1]}
		fi
	done <<< "$(get_pacmd_section $id properties)"

	echo "$message" > $DC_s/cnfg20
	echo "$device_icon_name" >> $DC_s/cnfg20
	exit 1
fi
