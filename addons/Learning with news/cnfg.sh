#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf

dir2="$DC/addons/Learning with news"
DIR3="$DS/addons/Learning with news"
FEED=$(sed -n 1p "$dir2/$lgtl/.rss")
if [[ -z "$1" ]]; then

	[[ -z "$FEED" ]] && FEED=" "
	cd "$dir2/$lgtl/subscripts"
	DIR1="$DC/addons/Learning with news"
	st2=$(sed -n 1p "$DIR1/.cnf")
	if [ -z $st2 ]; then
		echo FALSE > "$DIR1/.cnf"
		st2=$(sed -n 1p "$DIR1/.cnf")
	fi

	scrp=$(cd "$dir2/$lgtl/subscripts"; ls * | egrep -v "$FEED" \
	| tr "\\n" '!' | sed 's/!\+$//g')

	CNFG=$($yad --on-top --form --center \
		--text="$feeds$lgtl\n\n" --borders=15 \
		--window-icon=idiomind --skip-taskbar \
		--width=440 --height=340 --always-print-result \
		--title="Feeds - $lgtl " \
		--button="$delete:2" \
		--button="gtk-add:5" \
		--button="$update:4" \
		--field="  $current_subcription:CB" "$FEED!$scrp" \
		--field="$update_at_start:CHK" $st2)
		ret=$?
		
		st1="$(echo "$CNFG" | cut -d "|" -f1)"
		st2="$(echo "$CNFG" | cut -d "|" -f2)"
		
		if [[ $ret -eq 1 ]]; then
			sed -i "1s/.*/$st2/" "$DIR1/.cnf" & exit 1

		elif [[ $ret -eq 2 ]]; then
			if echo "$st1" | grep "Sample subscription"; then
				$yad --title="Info" \
				--center --on-top --window-icon=idiomind \
				--width=380 --height=140 --image=info --skip-taskbar \
				--text="  Sample subscription\\n  $delete_no." \
				--borders=5 --button=OK:1
				"$DIR3/cnfg.sh" & exit
			elif echo "$st1" | grep "Example"; then
				$yad --title="Info" --center --on-top --window-icon=idiomind \
				--width=380 --height=140 --image=info --skip-taskbar \
				--text="  Sample subscription\\n  $delete_no" \
				--borders=5 --button=OK:1
				"$DIR3/cnfg.sh" & exit
			else
				$yad --center \
				--title=Confirm --window-icon=idiomind \
				--on-top --width=380 --height=140 --image=dialog-question \
				--skip-taskbar --text="   <b>$delete_subcription</b>  \n\n\t$st1 " \
				--borders=5 --button="$delete":0 --button="$cancel":1
					ret=$?
					
					if [[ $ret -eq 1 ]]; then
						"$DIR3/cnfg.sh" & exit
					
					elif [[ $ret -eq 0 ]]; then
						if [[ "$(cat "$dir2/$lgtl/.rss")" = "$st1" ]]; then
							rm "$dir2/$lgtl/.rss" "$dir2/$lgtl/link"
						fi
						rm "$dir2/$lgtl/subscripts/$st1"
						"$DIR3/cnfg.sh" & exit
					fi
			fi
					
		elif [[ $ret -eq 5 ]]; then
			dirs="$dir2/$lgtl/subscripts"
			nwfd=$($yad --width=480 --height=100 \
				--center --on-top --window-icon=idiomind --align=right \
				--skip-taskbar --button=$cancel:1 --button=Ok:0 \
				--form --title=" $new_subcription" --borders=5 \
				--field="$name:: " "" \
				--field="$url:: " "" \ )
			
				if [[ -z "$(echo "$nwfd" | cut -d "|" -f1)" ]]; then
					"$DIR3/cnfg.sh" & exit
				elif [[ -z "$(echo "$nwfd" | cut -d "|" -f2)" ]]; then
					"$DIR3/cnfg.sh" & exit
				fi
			
				if [ "$?" -eq 0 ]; then
					name=$(echo "$nwfd" | cut -d "|" -f1)
					link=$(echo "$nwfd" | cut -d "|" -f2)
					
					if [[ "$(echo "$name" | wc -c)" -gt 40 ]]; then
						nme="${name:0:37}..."
					else
						nme="$name"
					fi
					echo '#!/bin/bash
					source /usr/share/idiomind/ifs/c.conf
					cd "$DC_a/Learning with news/$lgtl/subscripts"
					echo "'$nme'" > ../.rss
					echo '$link' > ../link
					exit' > "$dirs/$nme"
					chmod +x  "$dirs/$nme"
					"$DIR3/cnfg.sh" & exit
					
				elif [ "$?" -eq 1 ]; then
					"$DIR3/cnfg.sh" & exit
				fi
		
		elif [[ $ret -eq 4 ]]; then
			sh "$dir2/$lgtl/subscripts/$st1"
			"$DIR3/strt" & exit 1
		else
			sed -i "1s/.*/$st2/" "$DIR1/.cnf"
			exit 1
		fi
		
elif [ "$1" = NS ]; then

	yad --window-icon=idiomind --name=idiomind \
	--image=info --on-top --text="$no_url" \
	--image-on-top --center --sticky \
	--width=380 --height=150 --borders=5 \
	--skip-taskbar --title=idiomind \
	--button="  Ok  ":0

elif [[ $1 = edit ]]; then
	drtc="$DC_tl/Feeds/"
	slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$drtc/cnfg0" | wc -l)" -ge 4 ]]; then
dd="$DIR3/img/save.png
$create_topic
$DIR3/img/del.png
$delete_news
$DIR3/img/del.png
$delete_saved
$DIR3/img/rss.png
$subcriptions"
else
dd="$DIR3/img/del.png
$delete_news
$DIR3/img/del.png
$delete_saved
$DIR3/img/rss.png
$subcriptions"
fi

	echo "$dd" | yad --list --on-top \
	--expand-column=2 --center \
	--width=240 --name=idiomind --class=idiomind \
	--height=240 --title="Edit" --skip-taskbar \
	--window-icon=idiomind --no-headers \
	--buttons-layout=end --borders=0 --button=Ok:0 \
	--column=icon:IMG --column=Action:TEXT > "$slct"
	ret=$?
	slt=$(cat "$slct")
	if  [[ "$ret" -eq 0 ]]; then
		if echo "$slt" | grep -o "$create_topic"; then
			"$DIR3/add" n_t
		elif echo "$slt" | grep -o "$delete_news"; then
			"$DIR3/del" dlns
		elif echo "$slt" | grep -o "$delete_saved"; then
			"$DIR3/del" dlkt
		elif echo "$slt" | grep -o "$subcriptions"; then
			"$DIR3/cnfg.sh"
		fi
		rm -f "$slct"

	elif [[ "$ret" -eq 1 ]]; then
		exit 1
	fi
fi
