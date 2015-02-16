#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf
source $DS/ifs/mods/cmns.sh
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"


function dict_list() {

	cd "$enables/"
	find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
	-exec mv --target-directory="$disables/" {} +
	
	ls * > .dicts
	while read dict; do
		echo 'TRUE'
		echo "$dict" | sed 's/\./\n/g'
	done < .dicts
	
	cd "$disables/"; ls * > .dicts
	while read dict; do
		echo 'FALSE'
		echo "$dict" | sed 's/\./\n/g'
	done < .dicts
}


if [ "$1" = edit_dlg ]; then
	
	[ -z "$2" ] && code="#!/bin/bash" || code="$2"
	
	ss=$(mktemp $DT/D.XXXX)
	yad --form --width=420 --height=450 --on-top --print-all \
	--buttons-layout=end --center --window-icon=idiomind \
	--borders=0 --skip-taskbar --align=right --always-print-result \
	--button=Cancel:1 --button=Test:4 --button=Save:5 --title="script"\
	--field="<small>Argument 1: \"\$1\" = \"word\"</small>":TXT "$code" \
	--field="<small>Name</small>" "$name" \
	--field="<small>Language</small>:CB" "!en!es!pt!it!fr!de!ru" > "$ss"
	rt=$?
	code=$(cat "$ss" | cut -d "|" -f1)
	name=$(cat "$ss" | cut -d "|" -f2 | sed s'/ /_/'g)
	lang=$(cat "$ss" | cut -d "|" -f3)
	[ -z "$name" ] && name="d_$(($RANDOM%10))"
	[ -z "$lang" ] && lang="$lgt"
	
	if [ "$rt" -eq 5 ]; then

		printf "${code}" > "$disables/$name.$lang"
		$DS_a/Dics/cnfg.sh
		
	elif [ "$rt" -eq 4 ]; then
	
		printf "$code" > /tmp/test.sh
		chmod +x /tmp/test.sh
		cd /tmp; sh /tmp/test.sh yes
		[ -f /tmp/yes.mp3 ] && play /tmp/yes.mp3 || msg Fail info
		rm -f /tmp/yes.mp3 /tmp/test.sh
		$DS_a/Dics/cnfg.sh edit_dlg "$code"
		r=$(echo $?)
		[ $r -eq 0 ] && echo "${code}" > "$disables/$name.$lang"
		
	else
	
		$DS_a/Dics/cnfg.sh
	fi


elif [ "$1" = dlck ]; then

	[ "$2" = TRUE ] && stts=enables || stts=disables
	code="$(cat $dir/$stts/$3.$lgt)"
	name="$3"
	lang="$lgt"
	
	ss=$(mktemp $DT/D.XXXX)
	yad --form --width=420 --height=450 --on-top --print-all \
	--buttons-layout=end --center --window-icon=idiomind \
	--borders=0 --skip-taskbar --align=right --always-print-result \
	--button=Cancel:1 --button=Remove:2 --button=Test:4 \
	--button=Save:0 --title="script"\
	--field="<small>Argument 1: \"\$1\" = \"word\"</small>":TXT "$code" \
	--field="<small>Name</small>":RO "$name" \
	--field="<small>Language</small>":RO "$lgt" > "$ss"
	ret=$?
	
	code=$(cat "$ss" | cut -d "|" -f1)
	name=$(cat "$ss" | cut -d "|" -f2 | sed s'/ /_/'g)
	lang=$(cat "$ss" | cut -d "|" -f3)
	[ -z "$name" ] && name="dict_$(($RANDOM%100))"
	[ -z "$lang" ] && lang="$lgt"
	
	if [ $ret -eq 2 ]; then
	
		msg_2 " Confirm removal\n $3.$lgt\n" dialog-question yes no
		rt=$(echo $?)
		[ $rt -eq 0 ] && rm "$dir/$stts/$3.$lgt" & exit 1
			
	elif [ $ret -eq 0 ]; then
		
		[ -z "$name" ] && name="d_$(($RANDOM%10))"
		[ -z "$lang" ] && lang="$lgt"
		printf "${code}" > "$dir/$stts/$name.$lang" & exit 1
		
	elif [ $ret -eq 4 ]; then
	
		printf "${code}" > "/tmp/test.sh"
		chmod +x "/tmp/test.sh"
		cd /tmp; sh "/tmp/test.sh" yes
		[ -f "/tmp/yes.mp3" ]] && play "/tmp/yes.mp3" || msg 'Fail\n' info
		rm -f "/tmp/yes.mp3" "/tmp/test.sh"
		$DS_a/Dics/cnfg.sh dlck TRUE "$name" "$name"
		r=$(echo $?)
		[ $r -eq 0 ] && echo "${code}" > "$dir/$stts/$name.$lang" & exit 1
		
	else
		exit 1
	fi

	
elif [ -z "$1" ]; then

	if [ ! -d "$DC_a/dict/" ]; then
		mkdir -p "$enables"
		mkdir -p "$disables"
		cp -f $DS/addons/Dics/disables/* "$disables/"
	fi
	
	if [ "$2" = f ]; then
		tex="<small>$3\n</small>"
		align="--text-align=left"
	else
		tex=" "
		align="--text-align=right"
	fi
	
	D=$(mktemp $DT/D.XXXX)
	dict_list | $yad --list --title="Idiomind - $dictionaries" \
	--center --on-top --expand-column=2 --text="$tex" $align \
	--width=420 --height=300 --skip-taskbar --separator=" " \
	--borders=15 --button="$add":2 --print-all --button=Ok:0 \
	--column=" ":CHK --column="$availables":TEXT \
	--column="$languages":TEXT --window-icon=idiomind \
	--buttons-layout=edge --always-print-result \
	--dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh dlck' > "$D"
	ret=$?
	
		if [ "$ret" -eq 2 ]; then
		
				$DS_a/Dics/cnfg.sh edit_dlg
		
		elif [ "$ret" -eq 0 ]; then
		
			n=1
			while [ $n -le "$(cat "$D" | wc -l)" ]; do
			
				dict=$(sed -n "$n"p "$D")
				d=$(echo "$dict" | awk '{print ($2)}')
				
				if echo "$dict" | grep FALSE; then
					if [ ! -f "$disables/$d.$lgt" ]; then
						[ -f "$enables/$d.$lgt" ] \
						&& mv -f "$enables/$d.$lgt" "$disables/$d.$lgt"
					fi
					if [ ! -f "$disables/$d.auto" ]; then
						[ -f "$enables/$d.auto" ] \
						&& mv -f "$enables/$d.auto" "$disables/$d.auto"
					fi
				fi
				if echo "$dict" | grep TRUE; then
					if [ ! -f "$enables/$d.$lgt" ]; then
						[ -f "$disables/$d.$lgt" ] \
						&& mv -f "$disables/$d.$lgt" "$enables/$d.$lgt"
					fi
					if [ ! -f "$enables/$d.auto" ]; then
						[ -f "$disables/$d.auto" ] \
						&& mv -f "$disables/$d.auto" "$enables/$d.auto"
					fi
				fi
				let n++
			done
			
			cd "$enables/"
			#[ -f *.$lgt ] && ls -d -1 $PWD/*.$lgt > "$dir/.dicts"
			#[ -f *.auto ] && ls -d -1 $PWD/*.auto >> "$dir/.dicts"
			ls -d -1 $PWD/*.$lgt > "$dir/.dicts"
			ls -d -1 $PWD/*.auto >> "$dir/.dicts"
		
		fi
		
		rm -f "$D" & exit 1
fi
