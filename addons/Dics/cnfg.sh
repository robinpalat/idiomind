#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

DICT="$DC/addons/dict/"
wrd=$(echo "$1" | awk '{print tolower($0)}')
Wrd="$1"
DT_r="$2"

if [ ! -f $DT_r/.topic ]; then
	[[ -f $DC_s/cnfg7 ]] && topic=$(sed -n 1p $DC_s/cnfg7) || topic=""
	[[ -f $DT_r/.topic ]] && echo "$topic" > $DT_r/.topic
fi
[[ -f $DT_r/.topic ]] && tpe=$(cat $DT_r/.topic)
DM_tlt="$DM_tl/$tpe"
DC_tlt="$DC_tl/$tpe"

if [ "$1" = dlck ]; then
	if [ "$2" = TRUE ]; then
		stts=activos
	else
		stts=no_activos
	fi
	edt=$(yad --text-info --width=450 --height=450 \
	--filename=$HOME/.config/idiomind/addons/dict/$stts/"$3".$lgt \
	--editable --show-uri --wrap --on-top \
	--skip-taskbar --center \
	--title=Edit --window-icon=idiomind \
	--button=Delete:2 --button=Save:0)
	ret=$?
		if [ $ret -eq 2 ]; then
			rm $DICT/$stts/"$3".$lgt & exit 1
		elif [ $ret -eq 0 ]; then
			echo "$edt" > $DICT/$stts/"$3".$lgt & exit 1
		fi
		
elif [ -z "$1" ]; then
	if [ ! -d "$DICT" ]; then
		mkdir "$DICT"
		mkdir "$DICT/activos"
		mkdir "$DICT/no_activos"
	fi
	
	if [ "$2" = f ]; then
		tex="<small>$1\n</small>"
	else
		tex="<a href='http://www.dicts.com'><sup>$more_dict</sup></a>"
	fi
	
	rm -f "$DICT/.listdicts"
	cd "$DICT/activos"
	find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
	-exec mv --target-directory="$DICT/no_activos" {} +
	
	ls * > .dicts
	n=1
	while [ $n -le $(cat ".dicts" | wc -l) ]; do
		dict=$(sed -n "$n"p ".dicts")
		echo 'TRUE' >> "$DICT/.listdicts"
		echo "$dict" | \
		sed 's/\./\n/g' \
		>> "$DICT/.listdicts"
		let n++
	done
	
	cd "$DICT/no_activos"
	ls * > .dicts
	n=1
	while [ $n -le $(cat ".dicts" | wc -l) ]; do
		dict=$(sed -n "$n"p ".dicts")
		echo 'FALSE' >> "$DICT/.listdicts"
		echo "$dict" | \
		sed 's/\./\n/g' \
		>> "$DICT/.listdicts"
		let n++
	done
	
	D=$(mktemp $DT/D.XXXX)
	cat "$DICT/.listdicts" | $yad --list --title=" " \
	--center --on-top --expand-column=2 --text="$tex" --window-icon=idiomind \
	--width=440 --height=340 --skip-taskbar --separator=" " \
	--borders=15 --button="$add":2 --print-all --button=Ok:0 \
	--column=" ":CHK --column="$availables":TEXT \
	--column="$languages":TEXT \
	--buttons-layout=edge --always-print-result \
	--dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh dlck' \
	--title="Dictionarys" > "$D"
	ret=$?
	
		if [ "$ret" -eq 2 ]; then
			cd ~/
			add=$($yad --center --on-top --title=" " \
				--borders=5 --file-filter="*.en *.es *.de *.pt *.it *.fr *.ja" \
				--window-icon=idiomind --skip-taskbar --title=" " \
				--file --width=600 --height=500)
				
			if [ -z "$add" ];then
				exit 1
			else
				if [ $(sed -n 2p "$add" | wc -w) = 3 ]; then
					nm=$(sed -n 2p "$add" | sed 's/\.//g' | awk '{print ($2)}')
					lg=$(sed -n 2p "$add" | sed 's/\.//g' | awk '{print ($3)}')
					cp -f "$add" "$DICT/no_activos/$nm.$lg"
				else
					$yad --name=idiomind --center --title=" " \
					--text=" <b>$install_err </b>\\n" --image=info \
					--image-on-top --fixed --sticky --title="Info" --on-top \
					--width=230 --height=80 --borders=3 --button="gtk-ok:0" \
					--skip-taskbar --window-icon=idiomind
				fi
				$DS/addons/Dics/cnfg.sh 1 1 cnf & exit
			fi
		
		elif [ "$ret" -eq 0 ]; then
			lines=$(cat "$D" | wc -l)
			n=1
			while [ $n -le "$lines" ]; do
				dict=$(sed -n "$n"p "$D")
				mvd=$(echo "$dict" | awk '{print ($2)}')
				if echo "$dict" | grep FALSE; then
					if [ ! -f "$DICT/no_activos/$mvd.$lgt" ]; then
						mv "$DICT/activos/$mvd.$lgt" "$DICT/no_activos/$mvd.$lgt"
					fi
					if [ ! -f "$DICT/no_activos/$mvd.auto" ]; then
						mv "$DICT/activos/$mvd.auto" "$DICT/no_activos/$mvd.auto"
					fi
				fi
				if echo "$dict" | grep TRUE; then
					if [ ! -f "$DICT/activos/$mvd.$lgt" ]; then
						mv "$DICT/no_activos/$mvd.$lgt" "$DICT/activos/$mvd.$lgt"
					fi
					if [ ! -f "$DICT/activos/$mvd.auto" ]; then
						mv "$DICT/no_activos/$mvd.auto" "$DICT/activos/$mvd.auto"
					fi
				fi
				let n++
			done
			
		fi
		
		cd "$DICT/activos"
		ls -d -1 $PWD/*.$lgt > "$DICT/.dicts"
		ls -d -1 $PWD/*.auto >> "$DICT/.dicts"
		rm -f "$D" & exit 1
		
# word
elif [ "$3" = swrd ]; then
	cd $DT_r
	if [ -f "$DM_tl/.share/$wrd.mp3" ]; then
			cp -f "$DM_tl/.share/$wrd.mp3" "$Wrd.mp3" && exit 1
	else
		n=1
		while [ $n -le $(cat "$DICT/.dicts" | wc -l) ]; do
			dict=$(sed -n "$n"p "$DICT/.dicts")
			"$dict" "$wrd"
			if [ -f "$wrd.mp3" ]; then
				cp -f "$wrd.mp3" "$Wrd.mp3" && break
			fi
			let n++
		done
	fi
# words lists
else
	cd $DT_r
	if [ -f "$DM_tl/.share/$wrd.mp3" ]; then
		echo "$wrd.mp3" >> "$DC_tlt/cnfg5" && exit 1
	else
		n=1
		while [ $n -le $(cat "$DICT/.dicts" | wc -l) ]; do
			dict=$(sed -n "$n"p "$DICT/.dicts")
			"$dict" "$wrd"
			if [ -f "$wrd.mp3" ]; then
				mv "$wrd.mp3" "$DM_tl/.share/$wrd.mp3"
				echo "$wrd.mp3" >> "$DC_tlt/cnfg5" && break
			fi
			let n++
		done
	fi
fi
