#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/settings.conf

wth=$(sed -n 5p $DC_s/cfg.18)
eht=$(sed -n 6p $DC_s/cfg.18)

ICON=$DS/images/icon.png
cd $DS/addons

if [ ! -d "$DC" ]; then
	$DS/ifs/1u.sh
	cp $DS/default/cfg.1 \
	"$DC_s/cfg.1"
	sleep 1
	$DS/cnfg.sh & exit
fi

function confirm() {
	$yad --form --center --borders=5 --image=dialog-warning \
	--title="$warning" --on-top --window-icon=idiomind \
	--skip-taskbar --button="cancel":1 --button=Ok:0 \
	--text "<b>  $warning</b>\n\n  $change_source_language" \
	--width=400 --height=180 
}

function set_lang() {
	
	if [ ! -d "$DM_t"/$1 ]; then
		mkdir "$DM_t"/$1
		mkdir "$DM_t"/$1/.share
		mkdir "$DC/topics"/$1
		mkdir "$DC_a/Learning with news"/$1
		mkdir "$DC_a/Learning with news"/$1/subscripts
		cp -f "$DS/addons/Learning with news/examples/$1" \
		"$DC_a/Learning with news/$1/subscripts/Example"
	fi
	echo "$2" > $DC_s/cfg.10
	echo "$1" >> $DC_s/cfg.10
	$DS/stop.sh L
	"$DS/addons/Learning with news/tls.sh stop"
	
	if [ -f "$DC/topics/$1/.cfg.8" ]; then
		LST=$(sed -n 1p "$DC/topics/$1/.cfg.8")
		"$DC/topics/$1/$LST/tpc.sh"
	else
		rm $DC_s/cfg.8 && touch $DC_s/cfg.8
	fi
	(sleep 2 && $DS/addons/Dics/cnfg.sh "" f "$select_dicts") &
	$DS/mngr.sh mkmn
}

c=$(echo $(($RANDOM%100000)))
KEY=$c
cnf1=$(mktemp $DT/cnf1.XXXX)
cnf3=$(mktemp $DT/cnf3.XXXX)
sttng3=$(sed -n 3p $DC_s/cfg.1)
[[ -z $sttng3 ]] && sttng3=FALSE
sttng4=$(sed -n 4p $DC_s/cfg.1)
[[ -z $sttng4 ]] && sttng4=FALSE
sttng5=$(sed -n 5p $DC_s/cfg.1)
[[ -z $sttng5 ]] && sttng5=FALSE
sttng9=$(sed -n 9p $DC_s/cfg.1)
[[ -z $sttng9 ]] && sttng9=FALSE
sttng10=$(sed -n 10p $DC_s/cfg.1)
[[ -z $sttng10 ]] && sttng10=""
sttng11=$(sed -n 11p $DC_s/cfg.1)
[[ -z $sttng11 ]] && sttng11=""

yad --plug=$KEY --tabnum=1 --borders=15 --scroll \
	--separator="\\n" --form --no-headers --align=right \
	--field="$general_options\t":lbl "#1" \
	--field=":lbl" "#2"\
	--field="$use_g_color:CHK" $sttng3 \
	--field="$dialog_word_Selector:CHK" $sttng4 \
	--field="$start_with_system:CHK" $sttng5 \
	--field=" :lbl" "#6"\
	--field="$audio\t":lbl "#7" \
	--field=":lbl" "#8" \
	--field="$auto_pronounce:CHK" $sttng9 \
	--field="<small>$voice_syntetizer</small>:CB5" "$sttng10" \
	--field="<small>$record_audio</small>:CB5" "$sttng11" \
	--field=" :lbl" "#12"\
	--field="$help\t":lbl "#13" \
	--field=":lbl" "#14" \
	--field="$search_updates:BTN" "/usr/share/idiomind/ifs/tls.sh updt" \
	--field="$quickstart:BTN" "/usr/share/idiomind/ifs/tls.sh help" \
	--field="$topics_saved:BTN" "/usr/share/idiomind/ifs/upld.sh vsd" \
	--field=" :lbl" "#18"\
	--field="$languages\t":lbl "#19" \
	--field=":lbl" "#20"\
	--field="$languages_learning:CB" "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
	--field="$your_language:CB" "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" > "$cnf1" &
cat $DC_s/cfg.21 | yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
	--text="<sub>  $double_click_for_configure </sub>" \
	--no-headers --dclick-action="/usr/share/idiomind/ifs/dclik.sh" --print-all \
	--column=icon:IMG --column=Action &
echo "$text" | yad --plug=$KEY --tabnum=3 --text-info \
	--text="\\n<big><big><big><b>Idiomind v2.1-alpha</b></big></big></big>\\n<sup>$vocabulary_learning_tool\\n<a href='https://sourceforge.net/projects/idiomind/'>Homepage</a> © 2013-2014 Robin Palat</sup>\\n" \
	--show-uri --fontname=Arial --margins=10 --wrap --text-align=center &
yad --notebook --key=$KEY --name=idiomind --class=idiomind --skip-taskbar \
	--sticky --center --window-icon=$ICON --window-icon=idiomind \
	--tab="$preferences" --tab="  $addons  " --borders=5 \
	--tab="  $about  " \
	--width=450 --height=340 --title="$settings" --button=$close:0
	
	ret=$?
	
	if [ $ret -eq 0 ]; then
		rm -f $DT/.lc
		cp -f "$cnf1" $DC_s/cfg.1
		
		[ ! -d  $HOME/.config/autostart ] && mkdir $HOME/.config/autostart
		config_dir=$HOME/.config/autostart
		if [[ "$(sed -n 6p $DC_s/cfg.1)" = "TRUE" ]]; then
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
		
		ln=$(cat "$cnf1" | sed -n 21p)
		ls=$(cat "$cnf1" | sed -n 22p)
		
		if echo $ln | grep "English" && [ English != $lgtl ] ; then
			set_lang English en
		fi
		if echo $ln | grep "Spanish" && [ Spanish != $lgtl ] ; then
			set_lang Spanish es
		fi
		if echo $ln | grep "Italian" && [ Italian != $lgtl ] ; then
			set_lang Italian it
		fi
		if echo $ln | grep "Portuguese" && [ Portuguese != $lgtl ] ; then
			set_lang Portuguese pt
		fi
		if echo $ln | grep "German" && [ German != $lgtl ] ; then
			set_lang German de
		fi
		if echo $ln | grep "Japanese" && [ Japanese != $lgtl ] ; then
			set_lang Japanese ja
		fi
		if echo $ln | grep "French" && [ French != $lgtl ] ; then
			set_lang French fr
		fi
		if echo $ln | grep "Vietnamese" && [ Vietnamese != $lgtl ] ; then
			set_lang Vietnamese vi
		fi
		if echo $ln | grep "Chinese" && [ Chinese != $lgtl ] ; then
			set_lang Chinese "zh-cn"
		fi
		if echo $ln | grep "Russian" && [ Russian != $lgtl ] ; then
			set_lang Russian ru
		fi

		if echo $ls | grep "English" && [ English != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "en" > $DC_s/cfg.9
				echo "english" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "French" && [ French != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "fr" > $DC_s/cfg.9
				echo "french" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "German" && [ German != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "de" > $DC_s/cfg.9
				echo "german" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Italian" && [ Italian != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "it" > $DC_s/s/cfg.9
				echo "italian" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Japanese" && [ Japanese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "ja" > $DC_s/cfg.9
				echo "japanese" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Portuguese" && [ Portuguese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "pt" > $DC_s/cfg.9
				echo "portuguese" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Spanish" && [ Spanish != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "es" > $DC_s/cfg.9
				echo "spanish" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Vietnamese" && [ Vietnamese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "vi" > $DC_s/cfg.9
				echo "vietnamese" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Chinese" && [ Chinese != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "zh-cn" > $DC_s/cfg.9
				echo "chinese" >> $DC_s/cfg.9
			fi
		fi
		if echo $ls | grep "Russian" && [ Russian != $lgsl ] ; then
			confirm
			if [ $? -eq 0 ]; then
				echo "ru" > $DC_s/cfg.9
				echo "russian" >> $DC_s/cfg.9
			fi
		fi

		rm -f $cnf1 $cnf2 $cnf3 & exit 1
		
	elif [ $ret -eq 1 ]; then
		rm -f $cnf1 $cnf2 $cnf3 & exit 1
		
	else
		rm -f $cnf1 $cnf2 $cnf3 & exit 1
	fi
exit 0
