#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
wth=$(sed -n 5p $DC_s/.rd)
eht=$(sed -n 6p $DC_s/.rd)
if [ -f $DT/.lc ]; then
	echo "--loock"
	exit 1
fi
> $DT/.lc

text="
Idiomind it's specifically designed for people learning one or more foreign languages. It helps you learn foreign language vocabulary. You can create and manage word lists and share them online.
supports 4 types of exercises, including grammar and pronunciation tests.


Send comments or suggestions to improve the program.
https://sourceforge.net/p/idiomind/tickets

if you think it is useful, please consider making a donation.
https://sourceforge.net/projects/idiomind/support

Check out the code:
https://github.com/robinsato/idiomind

Licencia:
GPLv3

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details."

ICON=$DS/images/icon.png
cd $DS/addons

if [ ! -d "$DC" ]; then
	$DS/ifs/1u
	cp $DS/default/cnfg1 \
	"$DC_s/cnfg1"
	sleep 1
	$DS/cnfg & exit
fi

c=$(echo $(($RANDOM%100000)))
KEY=$c
cnf1=$(mktemp $DT/cnf1.XXXX)
cnf3=$(mktemp $DT/cnf3.XXXX)
sttng3=$(sed -n 3p $DC_s/cnfg1) #Use colors for grammar (experimental)
sttng4=$(sed -n 4p $DC_s/cnfg1) #Show dialog word Selector
sttng5=$(sed -n 5p $DC_s/cnfg1) #Listen pronounce
sttng6=$(sed -n 6p $DC_s/cnfg1) #Start with System
sttng7=$(sed -n 7p $DC_s/cnfg1) #tools
sttng8=$(sed -n 8p $DC_s/cnfg1) 
sttng9=$(sed -n 9p $DC_s/cnfg1) #Voice Syntetizer\n(Defaul espeak)
sttng10=$(sed -n 10p $DC_s/cnfg1) #Use this program\nto record audio
sttng11=$(sed -n 11p $DC_s/cnfg1)
img1=$DS/images/gts.png
img2=$DS/images/lwn.png
img3=applications-other
img4=applications-other
img5=applications-other
img6=applications-other

$yad --plug=$KEY --tabnum=1 --borders=15 --scroll \
	--separator="\\n" --form --no-headers \
	--field="General Options:lbl" "#1" \
	--field=":lbl" "#2"\
	--field="Use colors for grammar (experimental):CHK" $sttng3 \
	--field="Show dialog word Selector:CHK" $sttng4 \
	--field="Listen pronounce:CHK" $sttng5 \
	--field="Start with System:CHK" $sttng6 \
	--field=" :lbl" "#7"\
	--field="<small>Voice Syntetizer\n(Defaul espeak)</small>:CB5" "$sttng8" \
	--field="<small>Use this program\nto record audio</small>:CB5" "$sttng9" \
	--field=" :lbl" "#10"\
	--field="languages:CB" "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
	--field=" :lbl" "#12" > "$cnf1" &
$yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
	--text="<small>  Double click for configure</small>" \
	--no-headers --dclick-action="./plgcnf" --print-all \
	--column=icon:IMG --column=Action \
	"$img1" "Google translation service" "$img2" "Learning with News" "$img4" "Dictionarys" "$img5" "Weekly Report" &
echo "$text" | $yad --plug=$KEY --tabnum=3 --text-info \
	--text="\\n<big><big><big><b>Idiomind 1.0 alpha</b></big></big></big>\\n<sup>Vocabulary learning tool\\n<a href='https://sourceforge.net/projects/idiomind/'>Homepage</a> © 2013-2014 Robin Palat</sup>" \
	--show-uri --fontname=Arial --margins=10 --wrap --text-align=center &
$yad --notebook --key=$KEY --name=idiomind --class=idiomind \
	--sticky --center --window-icon=$ICON --window-icon=idiomind \
	--tab="Preferences" --tab="  Addons  " \
	--tab="  About  " \
	--width=450 --height=340 --title="Settings" \
	--button=Tools:"$DS/ifs/tls.sh tls" --button=Close:0
	
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
			fi
		fi
		
		if cat "$cnf1" | grep "English" && [ English != $lgtl ] ; then
			if [ ! -d "$DM_t"/English ]; then
				mkdir "$DM_t"/English
				mkdir "$DM_t"/English/.share
				mkdir "$DC/topics"/English
				mkdir "$DC_a/Learning with news"/English
				mkdir "$DC_a/Learning with news"/English/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/English" \
				"$DC_a/Learning with news/English/subscripts/Example"
			fi
			echo "en" > $DC_s/lang
			echo "English" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/English/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/English/.lst")
				"$DC/topics/English/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Spanish" && [ Spanish != $lgtl ] ; then
			if [ ! -d "$DM_t"/Spanish ]; then
				mkdir "$DM_t"/Spanish
				mkdir "$DM_t"/Spanish/.share
				mkdir "$DC/topics"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish
				mkdir "$DC_a/Learning with news"/Spanish/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Spanish" \
				"$DC_a/Learning with news/Spanish/subscripts/Example"
			fi
			echo "es" > $DC_s/lang
			echo "Spanish" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Spanish/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Spanish/.lst")
				"$DC/topics/Spanish/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Italian" && [ Italian != $lgtl ] ; then
			if [ ! -d "$DM_t"/Italian ]; then
				mkdir "$DM_t"/Italian
				mkdir "$DM_t"/Italian/.share
				mkdir "$DC/topics"/Italian
				mkdir "$DC_a/Learning with news"/Italian
				mkdir "$DC_a/Learning with news"/Italian/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Italian" \
				"$DC_a/Learning with news/Italian/subscripts/Example"
			fi
			echo "it" > $DC_s/lang
			echo "Italian" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Italian/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Italian/.lst")
				"$DC/topics/Italian/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Portuguese" && [ Portuguese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Portuguese ]; then
				mkdir "$DM_t"/Portuguese
				mkdir "$DM_t"/Portuguese/.share
				mkdir "$DC/topics"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese
				mkdir "$DC_a/Learning with news"/Portuguese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Portuguese" \
				"$DC_a/Learning with news/Portuguese/subscripts/Example"
			fi
			echo "pt" > $DC_s/lang
			echo "Portuguese" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Portuguese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Portuguese/.lst")
				"$DC/topics/Portuguese/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "German" && [ German != $lgtl ] ; then
			if [ ! -d "$DM_t"/German ]; then
				mkdir "$DM_t"/German
				mkdir "$DM_t"/German/.share
				mkdir "$DC/topics"/German
				mkdir "$DC_a/Learning with news"/German
				mkdir "$DC_a/Learning with news"/German/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/German" \
				"$DC_a/Learning with news/German/subscripts/Example"
			fi
			echo "de" > $DC_s/lang
			echo "German" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/German/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/German/.lst")
				"$DC/topics/German/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Japanese" && [ Japanese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Japanese ]; then
				mkdir "$DM_t"/Japanese
				mkdir "$DM_t"/Japanese/.share
				mkdir "$DC/topics"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese
				mkdir "$DC_a/Learning with news"/Japanese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Japanese" \
				"$DC_a/Learning with news/Japanese/subscripts/Example"
			fi
			echo "ja" > $DC_s/lang
			echo "Japanese" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Japanese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Japanese/.lst")
				"$DC/topics/Japanese/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "French" && [ French != $lgtl ] ; then
			if [ ! -d "$DM_t"/French ]; then
				mkdir "$DM_t"/French
				mkdir "$DM_t"/French/.share
				mkdir "$DC/topics"/French
				mkdir "$DC_a/Learning with news"/French
				mkdir "$DC_a/Learning with news"/French/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/French" \
				"$DC_a/Learning with news/French/subscripts/Example"
			fi
			echo "fr" > $DC_s/lang
			echo "French" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/French/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/French/.lst")
				"$DC/topics/French/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Vietnamese" && [ Vietnamese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Vietnamese ]; then
				mkdir "$DM_t"/Vietnamese
				mkdir "$DM_t"/Vietnamese/.share
				mkdir "$DC/topics"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese
				mkdir "$DC_a/Learning with news"/Vietnamese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Vietnamese" \
				"$DC_a/Learning with news/Vietnamese/subscripts/Example"
			fi
			echo "vi" > $DC_s/lang
			echo "Vietnamese" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Vietnamese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Vietnamese/.lst")
				"$DC/topics/Vietnamese/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Chinese" && [ Chinese != $lgtl ] ; then
			if [ ! -d "$DM_t"/Chinese ]; then
				mkdir "$DM_t"/Chinese
				mkdir "$DM_t"/Chinese/.share
				mkdir "$DC/topics"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese
				mkdir "$DC_a/Learning with news"/Chinese/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Chinese" \
				"$DC_a/Learning with news/Chinese/subscripts/Example"
			fi
			echo "zh-cn" > $DC_s/lang
			echo "Chinese" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Chinese/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Chinese/.lst")
				"$DC/topics/Chinese/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		if cat "$cnf1" | grep "Russian" && [ Russian != $lgtl ] ; then
			if [ ! -d "$DM_t"/Russian ]; then
				mkdir "$DM_t"/Russian
				mkdir "$DM_t"/Russian/.share
				mkdir "$DC/topics"/Russian
				mkdir "$DC_a/Learning with news"/Russian
				mkdir "$DC_a/Learning with news"/Russian/subscripts
				cp -f "$DS/addons/Learning_with_news/examples/Russian" \
				"$DC_a/Learning with news/Russian/subscripts/Example"
			fi
			echo "ru" > $DC_s/lang
			echo "Russian" >> $DC_s/lang
			$DS/stop.sh L
			$DS/addons/Learning_with_news/stp.sh
			
			if [ -f "$DC/topics/Russian/.lst" ]; then
				LST=$(sed -n 1p "$DC/topics/Russian/.lst")
				"$DC/topics/Russian/$LST/tpc.sh"
			fi
			$DS/mngr.sh mkmn
		fi
		
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
		
	elif [ $ret -eq 1 ]; then
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
		
	else
		rm -f $cnf1 $cnf2 $cnf3 $DT/.lc & exit 1
	fi
exit 0
