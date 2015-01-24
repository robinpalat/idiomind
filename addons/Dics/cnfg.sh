#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

dir="$DC/addons/dict/"
wrd=$(echo "$1" | awk '{print tolower($0)}')
Wrd="$1"
DT_r="$2"

if [ ! -f $DT_r/.topic ]; then
	[[ -f $DC_s/cfg.7 ]] && topic=$(sed -n 1p $DC_s/cfg.7) || topic=""
	[[ -f $DT_r/.topic ]] && echo "$topic" > $DT_r/.topic
fi
[[ -f $DT_r/.topic ]] && tpe=$(cat $DT_r/.topic)
DM_tlt="$DM_tl/$tpe"
DC_tlt="$DC_tl/$tpe"

if [ "$1" = dlck ]; then
	if [ "$2" = TRUE ]; then
		stts=enables
	else
		stts=disables
	fi
	edt=$(yad --text-info --width=450 --height=450 --title=Edit \
	--filename=$HOME/.config/idiomind/addons/dict/$stts/"$3".$lgt \
	--editable --show-uri --wrap --on-top --skip-taskbar --center \
	--window-icon=idiomind --button=Delete:2 --button=Save:0)
	ret=$?
		if [ $ret -eq 2 ]; then
			rm $dir/$stts/"$3".$lgt & exit 1
		elif [ $ret -eq 0 ]; then
			echo "$edt" > $dir/$stts/"$3".$lgt & exit 1
		fi
		
elif [ -z "$1" ]; then
	if [ ! -d "$dir" ]; then
		mkdir "$dir"
		mkdir "$dir/enables"
		mkdir "$dir/disables"
	fi
	
	if [ "$2" = f ]; then
		tex="<small>$3\n</small>"
		align="--text-align=left"
		img="--image=info"
	else
		tex="<a href='http://www.dicts.com'><sup>$more_dict</sup></a>  "
		align="--text-align=right"
	fi
	
	rm -f "$dir/.listdicts"
	cd "$dir/enables"
	find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
	-exec mv --target-directory="$dir/disables" {} +
	ls * > .dicts
	n=1
	while [ $n -le $(cat ".dicts" | wc -l) ]; do
		dict=$(sed -n "$n"p ".dicts")
		echo 'TRUE' >> "$dir/.listdicts"
		echo "$dict" | sed 's/\./\n/g' >> "$dir/.listdicts"
		let n++
	done
	cd "$dir/disables"
	ls * > .dicts
	n=1
	while [ $n -le $(cat ".dicts" | wc -l) ]; do
		dict=$(sed -n "$n"p ".dicts")
		if [ $(echo "$dict" | grep $lgt) ] \
		|| [ $(echo "$dict" | grep auto) ]; then
			echo 'FALSE' >> "$dir/.listdicts"
			echo "$dict" | sed 's/\./\n/g' >> "$dir/.listdicts"
		fi
		let n++
	done
	
	D=$(mktemp $DT/D.XXXX)
	cat "$dir/.listdicts" | $yad --list --title="Idiomind - $dictionaries" \
	--center --on-top --expand-column=2 $img --text="$tex" $align \
	--width=440 --height=340 --skip-taskbar --separator=" " --image-on-top \
	--borders=15 --button="$add":2 --print-all --button=Ok:0 \
	--column=" ":CHK --column="$availables":TEXT \
	--column="$languages":TEXT --window-icon=idiomind \
	--buttons-layout=edge --always-print-result \
	--dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh dlck' > "$D"
	ret=$?
	
		if [ "$ret" -eq 2 ]; then
			cd ~/
			add=$($yad --center --on-top --title=" " --borders=5 \
				--file-filter="*.en *.es *.de *.pt *.it *.fr *.ja" \
				--window-icon=idiomind --skip-taskbar --title=" " \
				--file --width=600 --height=500)
				
			if [ -z "$add" ];then
				exit 1
			else
				if [ $(sed -n 2p "$add" | wc -w) = 3 ]; then
					nm=$(sed -n 2p "$add" | sed 's/\.//g' | awk '{print ($2)}')
					lg=$(sed -n 2p "$add" | sed 's/\.//g' | awk '{print ($3)}')
					cp -f "$add" "$dir/disables/$nm.$lg"
				else
					yad --name=idiomind --center --title=" " \
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
					if [ ! -f "$dir/disables/$mvd.$lgt" ]; then
						mv "$dir/enables/$mvd.$lgt" "$dir/disables/$mvd.$lgt"
					fi
					if [ ! -f "$dir/disables/$mvd.auto" ]; then
						mv "$dir/enables/$mvd.auto" "$dir/disables/$mvd.auto"
					fi
				fi
				if echo "$dict" | grep TRUE; then
					if [ ! -f "$dir/enables/$mvd.$lgt" ]; then
						mv "$dir/disables/$mvd.$lgt" "$dir/enables/$mvd.$lgt"
					fi
					if [ ! -f "$dir/enables/$mvd.auto" ]; then
						mv "$dir/disables/$mvd.auto" "$dir/enables/$mvd.auto"
					fi
				fi
				let n++
			done
			
		fi
		
		cd "$dir/enables"
		ls -d -1 $PWD/*.$lgt > "$dir/.dicts"
		ls -d -1 $PWD/*.auto >> "$dir/.dicts"
		rm -f "$D" & exit 1

# word
elif [ "$3" = swrd ]; then
	cd $DT_r
	if [ -f "$DM_tl/.share/$wrd.mp3" ]; then
			cp -f "$DM_tl/.share/$wrd.mp3" "$Wrd.mp3" && exit 1
	else
		n=1
		while [ $n -le $(cat "$dir/.dicts" | wc -l) ]; do
			dict=$(sed -n "$n"p "$dir/.dicts")
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
		echo "$wrd.mp3" >> "$DC_tlt/cfg.5" && exit 1
	else
		n=1
		while [ $n -le $(cat "$dir/.dicts" | wc -l) ]; do
			dict=$(sed -n "$n"p "$dir/.dicts")
			"$dict" "$wrd"
			if [ -f "$wrd.mp3" ]; then
				mv "$wrd.mp3" "$DM_tl/.share/$wrd.mp3"
				echo "$wrd.mp3" >> "$DC_tlt/cfg.5" && break
			fi
			let n++
		done
	fi
fi
