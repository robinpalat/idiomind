#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf

DCF="$DC/addons/Learning with news"
DSF="$DS/addons/Learning with news"

if [ ! -d $DM_tl/Feeds ]; then

	mkdir $DM_tl/Feeds
	mkdir $DM_tl/Feeds/conten
	mkdir $DM_tl/Feeds/kept
	mkdir $DM_tl/Feeds/kept/.audio
	mkdir $DM_tl/Feeds/kept/words
	mkdir $DC_tl/Feeds/
	mkdir "$DC_a/Learning with news"
fi

if [ ! -d "$DC_a/Learning with news/$lgtl" ]; then
	mkdir "$DC_a/Learning with news/$lgtl"
	mkdir "$DC_a/Learning with news/$lgtl/rss"
	cp -f "$DSF/examples/$lgtl" "$DCF/$lgtl/rss/$sample"
fi


FEED=$(sed -n 1p "$DCF/$lgtl/.rss")
if [[ -z "$1" ]]; then

	[[ -z "$FEED" ]] && FEED=" "
	cd "$DCF/$lgtl/rss"
	DIR1="$DC/addons/Learning with news"
	st2=$(sed -n 1p "$DIR1/.cnf")
	if [ -z $st2 ]; then
		echo FALSE > "$DIR1/.cnf"
		st2=$(sed -n 1p "$DIR1/.cnf")
	fi

	scrp=$(cd "$DCF/$lgtl/rss"; ls * | egrep -v "$FEED" \
	| tr "\\n" '!' | sed 's/!\+$//g')

	CNFG=$($yad --on-top --form --center \
		--text="$feeds $lgtl\n" --borders=15 \
		--window-icon=idiomind --skip-taskbar \
		--width=420 --height=300 --always-print-result \
		--title="Feeds - $lgtl" \
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
			if echo "$st1" | grep -o "Sample"; then
				$yad --title="Info" \
				--center --on-top --window-icon=idiomind \
				--width=360 --height=120 --image=info --skip-taskbar \
				--text="  Sample subscription\\n  $delete_no." \
				--borders=5 --button=OK:1
				"$DSF/cnfg.sh" & exit
			elif echo "$st1" | grep -o "Sample"; then
				$yad --title="Info" --center --on-top --window-icon=idiomind \
				--width=360 --height=120 --image=info --skip-taskbar \
				--text="  Sample subscription\\n  $delete_no" \
				--borders=5 --button=OK:1
				"$DSF/cnfg.sh" & exit
			else
				$yad --center \
				--title="$confirm" --window-icon=idiomind \
				--on-top --width=360 --height=120 --image=dialog-question \
				--skip-taskbar --text="  $delete_subcription \n\n" \
				--borders=5 --button="$yes":0 --button="$no":1
					ret=$?
					
					if [[ $ret -eq 1 ]]; then
						"$DSF/cnfg.sh" & exit
					
					elif [[ $ret -eq 0 ]]; then
						if [[ "$(cat "$DCF/$lgtl/.rss")" = "$st1" ]]; then
							rm "$DCF/$lgtl/.rss" "$DCF/$lgtl/link"
						fi
						rm "$DCF/$lgtl/rss/$st1"
						"$DSF/cnfg.sh" & exit
					fi
			fi
					
		elif [[ $ret -eq 5 ]]; then
			dirs="$DCF/$lgtl/rss"
			nwfd=$($yad --width=480 --height=100 \
				--center --on-top --window-icon=idiomind --align=right \
				--skip-taskbar --button=$cancel:1 --button=Ok:0 \
				--form --title=" $new_subcription" --borders=5 \
				--field="$name:: " "" \
				--field="$url:: " "" \ )
			
				if [[ -z "$(echo "$nwfd" | cut -d "|" -f1)" ]]; then
					"$DSF/cnfg.sh" & exit
				elif [[ -z "$(echo "$nwfd" | cut -d "|" -f2)" ]]; then
					"$DSF/cnfg.sh" & exit
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
					cd "$DC_a/Learning with news/$lgtl/rss"
					echo "'$nme'" > ../.rss
					echo '$link' > ../link
					exit' > "$dirs/$nme"
					chmod +x  "$dirs/$nme"
					"$DSF/cnfg.sh" & exit
					
				elif [ "$?" -eq 1 ]; then
					"$DSF/cnfg.sh" & exit
				fi
		
		elif [[ $ret -eq 4 ]]; then
			sh "$DCF/$lgtl/rss/$st1"
			"$DSF/strt.sh" & exit 1
		else
			sed -i "1s/.*/$st2/" "$DIR1/.cnf"
			exit 1
		fi
		
elif [ "$1" = NS ]; then

	yad --window-icon=idiomind --name=idiomind \
	--image=info --on-top --text="$no_url" \
	--image-on-top --center --sticky \
	--width=360 --height=120 --borders=5 \
	--skip-taskbar --title=idiomind \
	--button="  Ok  ":0

elif [[ $1 = edit ]]; then
	drtc="$DC_tl/Feeds/"
	slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$drtc/cfg.0" | wc -l)" -ge 20 ]]; then
dd="$DSF/images/save.png
$create_topic
$DSF/images/del.png
$delete_news
$DSF/images/del.png
$delete_saved
$DSF/images/edit.png
$subcriptions"
else
dd="$DSF/images/del.png
$delete_news
$DSF/images/del.png
$delete_saved
$DSF/images/edit.png
$subcriptions"
fi

	echo "$dd" | yad --list --on-top \
	--expand-column=2 --center \
	--width=280 --name=idiomind --class=idiomind \
	--height=240 --title="Edit" --skip-taskbar \
	--window-icon=idiomind --no-headers \
	--buttons-layout=end --borders=0 --button=Ok:0 \
	--column=icon:IMG --column=Action:TEXT > "$slct"
	ret=$?
	slt=$(cat "$slct")
	if  [[ "$ret" -eq 0 ]]; then
		if echo "$slt" | grep -o "$create_topic"; then
			"$DSF/add.sh" n_t
		elif echo "$slt" | grep -o "$delete_news"; then
			"$DSF/mngr.sh" dlns
		elif echo "$slt" | grep -o "$delete_saved"; then
			"$DSF/mngr.sh" dlkt
		elif echo "$slt" | grep -o "$subcriptions"; then
			"$DSF/cnfg.sh"
		fi
		rm -f "$slct"

	elif [[ "$ret" -eq 1 ]]; then
		exit 1
	fi
fi
