#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/settings.conf
wth=$(sed -n 5p $DC_s/cnfg18)
eht=$(sed -n 6p $DC_s/cnfg18)

ICON=$DS/images/icon.png
cd $DS/addons

if [ ! -d "$DC" ]; then
	$DS/ifs/1u
	cp $DS/default/cnfg1 \
	"$DC_s/cnfg1"
	sleep 1
	$DS/cnfg & exit
fi

function confirm() {
	$yad --form --center --borders=5 --image=dialog-warning \
	--title="$warning" --on-top --window-icon=idiomind \
	--skip-taskbar --button="cancel":1 --button=Ok:0 \
	--text "<b>$change_source_language</b>" \
	--width=450 --height=180 
}

c=$(echo $(($RANDOM%100000)))
KEY=$c
cnf1=$(mktemp $DT/cnf1.XXXX)
cnf3=$(mktemp $DT/cnf3.XXXX)
sttng3=$(sed -n 3p $DC_s/cnfg1)
sttng4=$(sed -n 4p $DC_s/cnfg1)
sttng5=$(sed -n 5p $DC_s/cnfg1)
sttng6=$(sed -n 6p $DC_s/cnfg1)
sttng7=$(sed -n 7p $DC_s/cnfg1)
sttng8=$(sed -n 8p $DC_s/cnfg1) 
sttng9=$(sed -n 9p $DC_s/cnfg1)
sttng10=$(sed -n 10p $DC_s/cnfg1)
sttng11=$(sed -n 11p $DC_s/cnfg1)
img1=$DS/addons/Google_translation_service/icon.png
img2=$DS/addons/Learning_with_news/img/icon.png
img3=applications-other
img4=applications-other
img5=applications-other
img6=applications-other

$yad --plug=$KEY --tabnum=1 --borders=15 --scroll \
	--separator="\\n" --form --no-headers --align=right \
	--field="$general_options\t":lbl "#1" \
	--field=":lbl" "#2"\
	--field="$use_g_color:CHK" $sttng3 \
	--field="$dialog_word_Selector:CHK" $sttng4 \
	--field="$auto_pronounce:CHK" $sttng5 \
	--field="$start_with_system:CHK" $sttng6 \
	--field=" :lbl" "#7"\
	--field="<small>$voice_syntetizer</small>:CB5" "$sttng8" \
	--field="<small>$record_audio</small>:CB5" "$sttng9" \
	--field=" :lbl" "#10"\
	--field="$languages\t":lbl "#11" \
	--field=":lbl" "#12"\
	--field="$languages_learning:CB" "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
	--field="$your_language:CB" "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" > "$cnf1" &
$yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
	--text="<sub>  $double_click_for_configure </sub>" \
	--no-headers --dclick-action="./plgcnf.sh" --print-all \
	--column=icon:IMG --column=Action \
	"$img1" "Google translation service" "$img2" "Learning with News" "$img4" "Dictionarys" "$img5" "Weekly Report" "$img5" "User data" &
echo "$text" | $yad --plug=$KEY --tabnum=3 --text-info \
	--text="\\n<big><big><big><b>Idiomind v2.1-alpha</b></big></big></big>\\n<sup>$vocabulary_learning_tool\\n<a href='https://sourceforge.net/projects/idiomind/'>Homepage</a> © 2013-2014 Robin Palat</sup>\\n" \
	--show-uri --fontname=Arial --margins=10 --wrap --text-align=center &
$yad --notebook --key=$KEY --name=idiomind --class=idiomind --skip-taskbar \
	--sticky --center --window-icon=$ICON --window-icon=idiomind \
	--tab="$preferences" --tab="  $addons  " --borders=5 \
	--tab="  $about  " \
	--width=450 --height=340 --title="$settings" \
	--button=$tools:"$DS/ifs/tls.sh tls" --button=$close:0
	
	ret=$?
	
	if [ $ret -eq 0 ]; then
		rm -f $DT/.lc
		cp -f "$cnf1" $DC_s/cnfg1
		
		[ ! -d  $HOME/.config/autostart ] && mkdir $HOME/.config/autostart
		config_dir=$HOME/.config/autostart
		if [[ "$(sed -n 6p $DC_s/cnfg1)" = "TRUE" ]]; then
			if [ ! -f $config_dir/idiomind.desktop ]; then
			
				if [ ! -d "$HOME/.config/autostart" ]; then
					mkdir "$HOME/.config/autostart"
				fi
				echo '[Desktop Entry]' > $config_dir/idiomind.desktop
				echo 'Version=1.0
				Name=idiomind
				GenericName=idiomind
				Comment=Learning languages
				Exec=idiomind
				Terminal=false
				Type=Application
				Categories=languages;Education;
				Icon=idiomind
				MimeType=application/x-idmnd;
				StartupNotify=true
				Encoding=UTF-8' >> $config_dir/idiomind.desktop
				chmod +x $config_dir/idiomind.desktop
			fi
		else
			if [ -f $config_dir/idiomind.desktop ]; then
				rm $config_dir/idiomind.desktop
			else
				> $DC_s/cnfg8
			fi
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "English" && [ English != $lgtl ] ; then
			if [ ! -d "$DM_t"/English ]; then
				mkdir "$DM_t"/English
				mkdir "$DM_t"/English/.share
				mkdir "$DC/topics"/English
				mkdir "$DC_a/Learning with news"/English
				mkdir "$DC_a/Learning with news"/English/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/English" \
				"$DC_a/Learning with news/English/subscripts/Example"
			fi
			echo "en" > $DC_s/cnfg10
			echo "English" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/English/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/English/.cnfg8")
				"$DC/topics/English/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Spanish" && [ Spanish != $lgtl ] ; then
			if [ ! -d "$DM_t"/Spanish ]; then
				mkdir "$DM_t"/Spanish
				mkdir "$DM_t"/Spanish/.share
				mkdir "$DC/topics"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Spanish" \
				"$DC_a/Learning with news/Spanish/subscripts/Example"
			fi
			echo "es" > $DC_s/cnfg10
			echo "Spanish" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Spanish/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Spanish/.cnfg8")
				"$DC/topics/Spanish/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Italian" && [ Italian != $lgtl ] ; then
			if [ ! -d "$DM_t"/Italian ]; then
				mkdir "$DM_t"/Italian
				mkdir "$DM_t"/Italian/.share
				mkdir "$DC/topics"/Italian
				mkdir "$DC_a/Learning with news"/Italian
				mkdir "$DC_a/Learning with news"/Italian/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Italian" \
				"$DC_a/Learning with news/Italian/subscripts/Example"
			fi
			echo "it" > $DC_s/cnfg10
			echo "Italian" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Italian/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Italian/.cnfg8")
				"$DC/topics/Italian/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Portuguese" && [ Portuguese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Portuguese ]; then
				mkdir "$DM_t"/Portuguese
				mkdir "$DM_t"/Portuguese/.share
				mkdir "$DC/topics"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Portuguese" \
				"$DC_a/Learning with news/Portuguese/subscripts/Example"
			fi
			echo "pt" > $DC_s/cnfg10
			echo "Portuguese" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Portuguese/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Portuguese/.cnfg8")
				"$DC/topics/Portuguese/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "German" && [ German != $lgtl ] ; then
			if [ ! -d "$DM_t"/German ]; then
				mkdir "$DM_t"/German
				mkdir "$DM_t"/German/.share
				mkdir "$DC/topics"/German
				mkdir "$DC_a/Learning with news"/German
				mkdir "$DC_a/Learning with news"/German/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/German" \
				"$DC_a/Learning with news/German/subscripts/Example"
			fi
			echo "de" > $DC_s/cnfg10
			echo "German" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/German/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/German/.cnfg8")
				"$DC/topics/German/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Japanese" && [ Japanese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Japanese ]; then
				mkdir "$DM_t"/Japanese
				mkdir "$DM_t"/Japanese/.share
				mkdir "$DC/topics"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Japanese" \
				"$DC_a/Learning with news/Japanese/subscripts/Example"
			fi
			echo "ja" > $DC_s/cnfg10
			echo "Japanese" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Japanese/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Japanese/.cnfg8")
				"$DC/topics/Japanese/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "French" && [ French != $lgtl ] ; then
			if [ ! -d "$DM_t"/French ]; then
				mkdir "$DM_t"/French
				mkdir "$DM_t"/French/.share
				mkdir "$DC/topics"/French
				mkdir "$DC_a/Learning with news"/French
				mkdir "$DC_a/Learning with news"/French/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/French" \
				"$DC_a/Learning with news/French/subscripts/Example"
			fi
			echo "fr" > $DC_s/cnfg10
			echo "French" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/French/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/French/.cnfg8")
				"$DC/topics/French/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Vietnamese" && [ Vietnamese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Vietnamese ]; then
				mkdir "$DM_t"/Vietnamese
				mkdir "$DM_t"/Vietnamese/.share
				mkdir "$DC/topics"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Vietnamese" \
				"$DC_a/Learning with news/Vietnamese/subscripts/Example"
			fi
			echo "vi" > $DC_s/cnfg10
			echo "Vietnamese" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Vietnamese/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Vietnamese/.cnfg8")
				"$DC/topics/Vietnamese/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Chinese" && [ Chinese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Chinese ]; then
				mkdir "$DM_t"/Chinese
				mkdir "$DM_t"/Chinese/.share
				mkdir "$DC/topics"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Chinese" \
				"$DC_a/Learning with news/Chinese/subscripts/Example"
			fi
			echo "zh-cn" > $DC_s/cnfg10
			echo "Chinese" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Chinese/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Chinese/.cnfg8")
				"$DC/topics/Chinese/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | sed -n 13p | grep "Russian" && [ Russian != $lgtl ] ; then
			if [ ! -d "$DM_t"/Russian ]; then
				mkdir "$DM_t"/Russian
				mkdir "$DM_t"/Russian/.share
				mkdir "$DC/topics"/Russian
				mkdir "$DC_a/Learning with news"/Russian
				mkdir "$DC_a/Learning with news"/Russian/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Russian" \
				"$DC_a/Learning with news/Russian/subscripts/Example"
			fi
			echo "ru" > $DC_s/cnfg10
			echo "Russian" >> $DC_s/cnfg10
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Russian/.cnfg8" ]; then
				LST=$(sed -n 1p "$DC/topics/Russian/.cnfg8")
				"$DC/topics/Russian/$LST/tpc.sh"
			else
				> $DC_s/cnfg8
			fi
			$DS/mngr.sh mkmn
		fi

		if cat "$cnf1" | sed -n 14p | grep "English" && [ English != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "en" > $DC_s/cnfg9
				echo "english" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "French" && [ French != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "fr" > $DC_s/cnfg9
				echo "french" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "German" && [ German != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "de" > $DC_s/cnfg9
				echo "german" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Italian" && [ Italian != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "it" > $DC_s/s/cnfg9
				echo "italian" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Japanese" && [ Japanese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "ja" > $DC_s/cnfg9
				echo "japanese" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Portuguese" && [ Portuguese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "pt" > $DC_s/cnfg9
				echo "portuguese" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Spanish" && [ Spanish != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "es" > $DC_s/cnfg9
				echo "spanish" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Vietnamese" && [ Vietnamese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "vi" > $DC_s/cnfg9
				echo "vietnamese" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Chinese" && [ Chinese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "zh-cn" > $DC_s/cnfg9
				echo "chinese" >> $DC_s/cnfg9
			fi
		fi
		if cat "$cnf1" | sed -n 14p | grep "Russian" && [ Russian != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "ru" > $DC_s/cnfg9
				echo "russian" >> $DC_s/cnfg9
			fi
		fi

		rm -f $cnf1 $cnf2 $cnf3 & exit 1
		
	elif [ $ret -eq 1 ]; then
		rm -f $cnf1 $cnf2 $cnf3 & exit 1
		
	else
		rm -f $cnf1 $cnf2 $cnf3 & exit 1
	fi
exit 0
