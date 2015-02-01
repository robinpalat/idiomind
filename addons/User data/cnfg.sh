#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/t_bd.conf
DS_ppd="$DS/addons/Practice/default"
user=$(echo "$(whoami)")
D_cps=$(sed -n 2p $DC_s/cfg.12)
udt=$(cat "$D_cps/.udt")
dte=$(date +%F)

#dialog user data
if [ -z "$1" ]; then

	du -b -h $DM | tail -1 | awk '{print ($1)}' > $DT/.sz

	sz=$(cat $DT/.sz)
	D=$($yad --list --title="$user_data" \
	--center --on-top --radiolist --expand-column=2 \
	--text=" $size: $sz \\n" --width=440 --height=340 \
	--skip-taskbar --image=folder --separator=" " \
	--borders=15 --print-all --window-icon=idiomind \
	--button=Backup:2 --button=Ok:0 --image-on-top --column="" \
	--column=Options "FALSE" "$import" "FALSE" \
	"$export"  \
	--buttons-layout=end --always-print-result)
	
	ret=$?

	if [ "$ret" -eq 0 ]; then

		in=$(echo "$D" | sed -n 1p)
		ex=$(echo "$D" | sed -n 2p)
		
		# export
		if echo "$ex" | grep "TRUE $export"; then
			
			cd $HOME &&
			exp=$($yad --save --center --borders=10 \
			--on-top --filename="$user"_idiomind_data.tar.gz \
			--window-icon=idiomind --skip-taskbar --title="$export " \
			--file --width=600 --height=500 --button=Ok:0 )
			ret=$?
				
			if [ "$ret" -eq 0 ]; then
				(sleep 1 && notify-send -i idiomind "$t_export_data" "$t_wait") &
				(
				echo "# $t_copying..." ; sleep 0.1
				mkdir "$DM/cnf/"
				cp -r "$DC/topics/" "$DM/cnf/"
				cd "$DM/cnf/"
				shopt -s globstar
				rm ./**/*Practice*/.*
				cd "$DM"
				tar cvzf backup.tar.gz *
				mv -f backup.tar.gz $DT/"$user"_idiomind_data.tar.gz
				rm -r "$DM/cnf/"
				mv -f $DT/"$user"_idiomind_data.tar.gz "$exp"
				echo "# $finished" ; sleep 1
				) | yad --center --on-top --fixed --progress \
				--width=200 --height=20 --geometry=200x20-2-2 \
				--pulsate --percentage="5" --auto-close \
				--sticky --on-top --undecorated --skip-taskbar --no-buttons
				
				yad --fixed --name=idiomind --center --class=idiomind \
				--image=info --sticky --text="$t_export_ok \\n" \
				--image-on-top --fixed --width=360 --height=140 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=Ok:0 && exit 1
			else
				exit 1
			fi

		# import
		elif echo "$in" | grep "TRUE $import"; then
			cd $HOME &&
			add=$($yad --center --on-top \
			--borders=10 --file-filter="*.gz" --button=Ok:0 \
			--window-icon=idiomind --skip-taskbar --title="$import" \
			--window-icon=$ICON --file --width=600 --height=500)
			
			if [ "$ret" -eq 0 ]; then
				if [[ -z "$add" || ! -d "$DM" ]]; then
					exit 1
				fi
				(
				rm -f $DT/*.XXXXXXXX
				echo "5"
				echo "# $t_copying..." ; sleep 0.1
				mkdir $DT/.imprt
				cp -f "$add" $DT/.imprt/.import.tar.gz
				cd $DT/.imprt
				tar -xzvf .import.tar.gz
				cd $DT/.imprt/topics
				list=$(ls * -d | sed 's/saved//g' | sed '/^$/d')
				lines=$(echo "$list" | wc -l)
				n=1
				while [ $n -le "$lines" ]; do
					lng=$(echo "$list" | sed -n "$n"p)
					mkdir "$DC/topics/$lng"
					mkdir "$DM_t/$lng"
					mkdir "$DM_t/$lng/.share"
					mv -f ./$lng/.share/* "$DM_t/$lng/.share/"
					echo $lng >> lenguages
					let n++
				done
						
				n=1
				while [ $n -le "$(cat $DT/.imprt/topics/lenguages | wc -l)" ]; do
					dlng=$(cat $DT/.imprt/topics/lenguages | sed -n "$n"p)
					cd $DT/.imprt/topics/$dlng/
					ls * -d | sed 's/Feeds//g' | sed '/^$/d' > \
					$DT/.imprt/topics/$dlng/.lista_topics
					lts=$DT/.imprt/topics/$dlng/.lista_topics
					echo "55"
					echo "# $setting_language $dlng " ; sleep 0.1
					echo "95"
					echo "# $setting_language $dlng " ; sleep 0.1
					
					(
					n=1
					while [ $n -le "$(cat $lts | wc -l)" ]; do
						topic=$(cat $lts | sed -n "$n"p)
						echo "5"
						echo "# $setting_topic ${topic:0:20} ... " ; sleep 0.1
						# mp3s
						mkdir "$DM_t/$dlng/$topic"
						cd "$DT/.imprt/topics/$dlng/$topic/"
						cp -f -r * "$DM_t/$dlng/$topic/"
						echo "25"
						echo "# $setting_topic ${topic:0:20} ... " ; sleep 0.2
						# index, setting
						mkdir "$DC/topics/$dlng/$topic"
						mkdir "$DC/topics/$dlng/$topic/Practice"
						tdirc="$DC/topics/$dlng/$topic"
						sdirc="$DT/.imprt/cnf/topics/$dlng/$topic/"
						echo "50"
						echo "# $copying_data ${topic:0:20} ... " ; sleep 0.3
						cd "$sdirc"
						echo "6" > "$tdirc/cfg.8"
						cp -f cfg.0 "$tdirc/cfg.0"
						cp -f cfg.0 "$tdirc/cfg.1"
						cp -f cfg.3 "$tdirc/cfg.3"
						cp -f cfg.4 "$tdirc/cfg.4"
						cp -f cfg.5 "$tdirc/cfg.5"
						cp -f cfg.12 "$tdirc/cfg.12"
						echo "$nt" > "$tdirc/nt"
						(cd "$DS_ppd"; cp -f .* \
						"$DC/topics/$dlng/$topic/Practice")
						echo $dte > cfg.12
						cp -f $DS/default/tpc.sh "$tdirc/tpc.sh"
						chmod +x "$tdirc/tpc.sh"
						echo "80"
						echo "# $copying_data ${topic:0:20} ... " ; sleep 0.1
						cd "$DT/.imprt/cnf/topics/$dlng"
						echo "90"
						echo "# $copying_data ${topic:0:20} ... " ; sleep 0.2
						echo "$topic" >> "$DC/topics/$dlng/.cfg.3"
						sed -i 's/'"$topic"'//g' "$DC/topics/$dlng/.cfg.2"
						sed '/^$/d' $DM_t/$dlng/.cfg.2 > $DM_t/$dlng/.cfg.2_
						mv -f $DM_t/$dlng/.cfg.2_ $DM_t/$dlng/.cfg.2
						cd $DT/.imprt/topics
						let n++
					done
					)
					
					let n++
				done
				
				echo "95"
				echo "# $finished" ; sleep 1
				echo "100"
				$DS/mngr.sh mkmn
				chmod -R +x "$DC"/topics/
				cp -f $DS/default/README.txt "$DM"/README.txt
				rm -f -r $DT/.imprt
				
				) | $yad --on-top --progress \
				--width=200 --height=20 --geometry=200x20-2-2 \
				--percentage="5" --auto-close \
				--sticky --on-top --undecorated --on-top \
				--skip-taskbar --center --no-buttons
				
				$yad --fixed --name=idiomind --center --class=idiomind \
				--image=info --sticky \
				--text=" $t_import_ok   \\n" \
				--image-on-top --fixed --width=360 --height=140 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=Ok:0 && exit 1
			else
				exit 1
			fi
		fi

	# backup
	elif [ "$ret" -eq 2 ]; then
		sttng=$(sed -n 1p $DC_s/cfg.12)
		D_cps=$(sed -n 2p $DC_s/cfg.12)
		
		if [ -z $sttng ]; then
			echo FALSE > $DC_s/cfg.12
			echo " " > $DC_s/cfg.12
		fi

		cd ~/
		CNFG=$($yad --center --form --on-top --window-icon=idiomind \
		--borders=15 --expand-column=3 --no-headers \
		--print-all --button=$restore:3 --always-print-result \
		--button=$close:0 --width=350 --height=250 \
		--title=Backup --columns=2 \
		--text="$text1\\n" \
		--field="$text2:CHK" $sttng \
		--field=" Folder Path::CDIR" "$D_cps" \
		--field=" :LBL" " " )
		
		ret=$?
		# backup config
		if [ "$ret" -eq 0 ]; then
			sttng=$(echo "$CNFG" | cut -d "|" -f1)
			dircy=$(echo "$CNFG" | cut -d "|" -f2)
			echo "$sttng" > $DC_s/cfg.12
			echo "$dircy" >> $DC_s/cfg.12

		elif [ "$ret" -eq 3 ]; then
		
			if [ ! -d "$D_cps" ]; then
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$dir_err " \
				--image-on-top --fixed --width=340 --height=130 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=Ok:0 & exit 1
				
			elif [ ! -f "$D_cps/idiomind.backup" ]; then
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$no_backup  \\n" \
				--image-on-top --fixed --width=340 --height=130 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=Ok:0 & exit 1
			else
				udt=$(cat "$D_cps/.udt")
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$restore_to $udt  \\n" \
				--image-on-top --fixed --width=340 --height=130 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button="$cancel":1 --button=Ok:0
					ret=$?
				
					if [ "$ret" -eq 0 ]; then
						(
						rm -f $DT/*.XXXXXXXX
						echo "#" ; sleep 0
						cp "$DC_s/cfg.12"  "$DT/.SC.bk"
						mv "$DC/" "$DT/.s2.bk"
						mv "$DM/" "$DT/.idm2.bk"
						mkdir "$DC/"
						mkdir "$DM/"
						mkdir "$DM_t"
						D_cps=$(sed -n 2p $DT/.SC.bk)
						mv -f "$D_cps/idiomind.backup" "$D_cps/backup.tar.gz"
						cd "$D_cps"
						tar -xzvf ./backup.tar.gz
						mv -f ./idiomind/* "$DC/"
						mv -f ./topics/* "$DM_t/"
						$DS/mngr mkmn
						chmod -R +x "$DC"
						rm -r  "$D_cps/idiomind"
						rm -r  "$D_cps/topics"
						mv -f "$D_cps/backup.tar.gz" "$D_cps/idiomind.backup"
						) | $yad --on-top \
						--width=200 --height=20 --geometry=200x20-2-2 \
						--pulsate --percentage="5" --auto-close \
						--sticky --on-top --undecorated --skip-taskbar \
						--center --no-buttons --fixed --progress
						
					elif [ "$ret" -eq 1 ]; then
						exit 1
					fi
			fi
		else
			sttng=$(echo "$CNFG" | cut -d "|" -f1)
			dircy=$(echo "$CNFG" | cut -d "|" -f2)
			echo "$sttng" > $DC_s/cfg.12
			echo "$dircy" >> $DC_s/cfg.12
		fi	
	else
		exit 1
	fi

elif ([ "$1" = C ] && [ "$dte" != "$udt" ]); then
	sleep 3
	while true; do
	idle=$(top -bn2 | grep "Cpu(s)" | tail -n 1 | sed 's/\%us,.*//' | sed 's/.*Cpu(s): //')
	echo "idle is $idle"
	if [[ $idle < 15 ]]; then
		break
	fi
	sleep 10
	done
	
	if [ ! -d "$D_cps" ]; then
		$yad --fixed --name=idiomind --center \
		--image=info --sticky --class=idiomind \
		--text="$dir_err2 " \
		--image-on-top --fixed --width=420 --height=130 --borders=3 \
		--skip-taskbar --window-icon=idiomind --buttons-layout=edge \
		--title=Idiomind --button="$configure":3 --button=Ok:0
		ret=$?
		
		if [ $ret -eq 0 ]; then
		exit 1
		elif [ $ret -eq 3 ]; then
		"/usr/share/idiomind/addons/User data/cnfg.sh"
		fi
	fi
	
	if [ -f "$D_cps/idiomind.backup" ]; then
		mv -f "$D_cps/idiomind.backup" "$D_cps/idiomind.bk"
	fi

	cp -r "$DC" "$DM"
	cd $DM
	tar cvzf backup.tar.gz *
	mv -f backup.tar.gz "$D_cps/idiomind.backup"
	exit=$?
	if [ $exit = 0 ] ; then
	echo "$dte" > "$D_cps/.udt"
	rm "$D_cps/idiomind.bk"
	else
	mv -f "$D_cps/idiomind.bk" "$D_cps/idiomind.backup"
	fi
	rm -r "$DM/idiomind"
	exit

fi
