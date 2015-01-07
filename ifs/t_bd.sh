#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/t_bd.conf
DS_ppd="$DS/addons/Practice/default"
user=$(echo "$(whoami)")
D_cps=$(sed -n 2p $DC_s/cnfg12)
udt=$(cat "$D_cps/.udt")
dte=$(date +%F)

# dialogo "user data"
if [ -z "$1" ]; then
	(echo "#"; sleep 0
	du -b -h $DM | tail -1 | awk '{print ($1)}' > $DT/.sz
	) | $yad --center --on-top --fixed --progress \
	--width=35 --height=20 --geometry=20x20-2-2 \
	--pulsate --percentage=5 --auto-close --no-buttons \
	--sticky --on-top --undecorated --skip-taskbar

	sz=$(cat $DT/.sz)
	D=$($yad --list --title="$user_data" \
	--center --on-top --radiolist --expand-column=2 \
	--text=" $size: $sz \\n" --width=380 --height=250 \
	--skip-taskbar --image=folder --separator=" " \
	--borders=10 --print-all --window-icon=idiomind \
	--button=Backup:2 --button=Ok:0 --image-on-top --column="" \
	--column=Options "FALSE" "$import" "FALSE" \
	"$export"  \
	--buttons-layout=end --always-print-result)
	
	ret=$?

	if [ "$ret" -eq 0 ]; then

		in=$(echo "$D" | sed -n 1p)
		ex=$(echo "$D" | sed -n 2p)
		
		# exportar datos
		if echo "$ex" | grep "TRUE $export"; then
			
			cd $HOME &&
			exp=$($yad --save --center --borders=10 \
			--on-top --filename="$user"_idiomind_data.tar.gz \
			--window-icon=idiomind --skip-taskbar --title="$export " \
			--file --width=600 --height=500 --button=gtk-ok:0 )
			ret=$?
				
			if [ "$ret" -eq 0 ]; then
			
				(
				echo "#"; sleep 0
				mkdir "$DM/cnf/"
				cp -r "$DC/topics/" "$DM/cnf/"
				cd "$DM/cnf/"
				find . -type f \( -name "indpe" -o -name "indpa" \
				-o -name "inds" -o -name "indsa" -o -name "indse" \
				-o -name "indw" -o -name "indwa" -o -name "indwe" \
				-o -name "indf" -o -name "indfa" -o -name "indfe" \) -exec rm {} \;
				shopt -s globstar
				rm ./**/*Practice*/.*
				cd ..
				tar cvzf backup.tar.gz *
				mv -f backup.tar.gz $DT/"$user"_idiomind_data.tar.gz
				
				) | $yad --center --on-top --fixed --progress \
				--width=30 --height=20 --geometry=20x20-2-2 \
				--pulsate --percentage="5" --auto-close \
				--sticky --on-top --undecorated --skip-taskbar --no-buttons
				mv -f $DT/"$user"_idiomind_data.tar.gz "$exp"
				$yad --fixed --name=idiomind --center --class=idiomind \
				--image=info --sticky \
				--text=" $export_ok  \\n" \
				--image-on-top --fixed --width=240 --height=80 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=gtk-ok:0 && exit 1
			else
				exit 1
			fi

		# importar datos 
		elif echo "$in" | grep "TRUE $import"; then
			cd $HOME &&
			add=$($yad --center --on-top \
			--borders=10 --file-filter="*.gz" --button=gtk-ok:0 \
			--window-icon=idiomind --skip-taskbar --title="$import" \
			--window-icon=$ICON --file --width=600 --height=500)
			
			if [ "$ret" -eq 0 ]; then
				if [[ -z "$add" || ! -d "$DM" ]]; then
					exit 1
				fi
					
				(
				rm -f $DT/*.XXXXXXXX
				echo "5"
				echo "# $coping..." ; sleep 2
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
					echo "# $setting_language $dlng " ; sleep 1
					echo "95"
					echo "# $setting_language $dlng " ; sleep 1
					
					(
					n=1
					while [ $n -le "$(cat $lts | wc -l)" ]; do
						topic=$(cat $lts | sed -n "$n"p)
						echo "5"
						echo "# $setting_topic ${topic:0:20} ... " ; sleep 1
						# mp3's
						mkdir "$DM_t/$dlng/$topic"
						cd "$DT/.imprt/topics/$dlng/$topic/"
						cp -f -r * "$DM_t/$dlng/$topic/"
						echo "25"
						echo "# $setting_topic ${topic:0:20} ... " ; sleep 1
						# indices, configuraciones
						mkdir "$DC/topics/$dlng/$topic"
						mkdir "$DC/topics/$dlng/$topic/Practice"
						tdirc="$DC/topics/$dlng/$topic"
						sdirc="$DT/.imprt/cnf/topics/$dlng/$topic/"
						echo "50"
						echo "# $coping_data ${topic:0:20} ... " ; sleep 1
						cd "$sdirc"
						echo "6" > "$tdirc/cnfg8"
						cp -f cnfg0 "$tdirc/cnfg0"
						cp -f cnfg0 "$tdirc/cnfg1"
						cp -f cnfg3 "$tdirc/cnfg3"
						cp -f cnfg4 "$tdirc/cnfg4"
						cp -f cnfg5 "$tdirc/cnfg5"
						cp -f cnfg13 "$tdirc/cnfg13"
						echo "$nt" > "$tdirc/nt"
						(cd "$DS_ppd"; cp -f .* \
						"$DC/topics/$dlng/$topic/Practice")
						echo $dte > cnfg12
						cp -f $DS/default/tpc.sh "$tdirc/tpc.sh"
						chmod +x "$tdirc/tpc.sh"
						echo "80"
						echo "# $coping_data ${topic:0:20} ... " ; sleep 1
						cd "$DT/.imprt/cnf/topics/$dlng"
						echo "90"
						echo "# $coping_data ${topic:0:20} ... " ; sleep 1
						echo "$topic" >> "$DC/topics/$dlng/.cnfg3"
						sed -i 's/'"$topic"'//g' "$DC/topics/$dlng/.cnfg2"
						sed '/^$/d' $DM_t/$dlng/.cnfg2 > $DM_t/$dlng/.cnfg2_
						mv -f $DM_t/$dlng/.cnfg2_ $DM_t/$dlng/.cnfg2
						cd $DT/.imprt/topics
						let n++
					done
					)
					
					let n++
				done
				
				echo "95"
				echo "# $finished." ; sleep 2
				echo "100"
				$DS/mngr mkmn
				chmod -R +x "$DC"/topics/
				cp -f $DS/default/README.txt "$DM"/README.txt
				rm -f -r $DT/.imprt
				
				) | $yad --on-top --progress \
				--width=300 --height=20 --geometry=300x40-2-2 \
				--percentage="5" --auto-close \
				--sticky --on-top --undecorated --on-top \
				--skip-taskbar --center --no-buttons
				
				$yad --fixed --name=idiomind --center --class=idiomind \
				--image=info --sticky \
				--text=" $import_ok   \\n" \
				--image-on-top --fixed --width=240 --height=80 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=gtk-ok:0 && exit 1
			else
				exit 1
			fi
		fi

	# se ha elegido " backup" 
	elif [ "$ret" -eq 2 ]; then
		sttng=$(sed -n 1p $DC_s/cnfg12)
		D_cps=$(sed -n 2p $DC_s/cnfg12)
		
		if [ -z $sttng ]; then
			echo FALSE > $DC_s/cnfg12
			echo " " > $DC_s/cnfg12
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
		# seconfigurado para el backup" 
		if [ "$ret" -eq 0 ]; then
			sttng=$(echo "$CNFG" | cut -d "|" -f1)
			dircy=$(echo "$CNFG" | cut -d "|" -f2)
			echo "$sttng" > $DC_s/cnfg12
			echo "$dircy" >> $DC_s/cnfg12

		elif [ "$ret" -eq 3 ]; then
		
			if [ ! -d "$D_cps" ]; then
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$dir_err " \
				--image-on-top --fixed --width=240 --height=140 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=gtk-ok:0 & exit 1
				
			elif [ ! -f "$D_cps/idiomind.backup" ]; then
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$no_backup  \\n" \
				--image-on-top --fixed --width=240 --height=140 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button=gtk-ok:0 & exit 1
				
			else
				udt=$(cat "$D_cps/.udt")
				$yad --fixed --name=idiomind --center \
				--image=info --sticky --class=idiomind \
				--text="$restore_to $udt  \\n" \
				--image-on-top --fixed --width=280 --height=160 --borders=3 \
				--skip-taskbar --window-icon=idiomind \
				--title=Idiomind --button="$cancel":1 --button=gtk-ok:0
					ret=$?
				
					if [ "$ret" -eq 0 ]; then
						(
						rm -f $DT/*.XXXXXXXX
						echo "#" ; sleep 0
						cp "$DC_s/cnfg12"  "$DT/.SC.bk"
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
						--width=200 --height=20 --geometry=200x40-2-2 \
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
			echo "$sttng" > $DC_s/cnfg12
			echo "$dircy" >> $DC_s/cnfg12
		fi	
	else
		exit 1
	fi

# copia de seguridad cada 7 dias 
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
		--image-on-top --fixed --width=280 --height=130 --borders=3 \
		--skip-taskbar --window-icon=idiomind --buttons-layout=edge \
		--title=Idiomind --button="$configure":3 --button=gtk-ok:0
		ret=$?
		
		if [ "$ret" -eq 0 ]; then
		exit 1
		elif [ "$ret" -eq 3 ]; then
		/usr/share/idiomind/ifs/t_bd.sh
		fi
	fi
	
	if [ -f "$D_cps/idiomind.backup" ]; then
		rm "$D_cps/idiomind.backup"
	fi

	notify-send -i idiomind "$starting_backup"
	cp -r "$DC" "$DM"
	cd $DM
	tar cvzf backup.tar.gz *
	mv -f backup.tar.gz "$D_cps/idiomind.backup"
	echo "$dte" > "$D_cps/.udt"
	rm -r "$DM/idiomind"
	exit

fi
