#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/trans/es/others.conf
IMAGE=/usr/share/idiomind/ifs/1u.png

drtf="/usr/share/idiomind/addons/Learning with news/examples/"
user=$(echo "$(whoami)")
if [ "$1" = s ]; then
	ins="--field=<small><b> $no_language1</b></small>\\t\\t:lbl"
elif [ "$1" = t ]; then
	int="--field=<small><b> $no_language2</b></small>\\t\\t:lbl"
elif [ "$1" = n ]; then
	int="--field=<small><b> $no_language3</b></small>\\t\\t:lbl"
fi

function set_lang() {
	
	if echo "$source" | grep $1; then
		if [ ! -d "$DIR1"/$1 ]; then
			mkdir "$DIR1"/$1
			mkdir "$DIR1"/$1/.share
			mkdir "$DIR3"/$1
			mkdir "$DIR4"/$1
			mkdir "$DIR4"/$1/subscripts
			cp -f "$drtf"/$1 "$DIR4"/$1/subscripts/Example
		fi
		echo $2 > $DIR2/s/cnfg10
		echo $1 >> $DIR2/s/cnfg10
	fi
}

dialog=$(yad --center --width=520 --height=280 --fixed \
	--image-on-top --on-top --class=idiomind --name=idiomind \
	--window-icon=idiomind --buttons-layout=end --image=$IMAGE  \
	--title="Idiomind" --form --borders=10 --align=right --button=Ok:0 \
	--field="\\t\\t\\t\\t$language_target :CB" \
	!"English!French!German!Italian!Japanese!Portuguese!Spanish!Vietnamese!Chinese"\
	--field="\\t\\t\\t\\t$language_source :CB" \
	!"English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" \
	"$ins" "$int" --field=":lbl")

ret=$?

if [[ $ret -eq 1 ]]; then
	killall 1u & exit 1

elif [[ $ret -eq 0 ]]; then
	source=$(echo "$dialog" | cut -d "|" -f1)
	target=$(echo "$dialog" | cut -d "|" -f2)
	
	if [ -z "$dialog" ]; then
		/usr/share/idiomind/ifs/1u n & exit 1
	elif [ -z $source ]; then
		/usr/share/idiomind/ifs/1u s & exit 1
	elif [ -z $target ]; then
		/usr/share/idiomind/ifs/1u t & exit 1
	fi
	
	mkdir "$HOME"/.idiomind/
	
	if [ $? -ne 0 ]; then
		yad --name=idiomind \
		--image=error --button=gtk-ok:1\
		--text=" <b>$write_err /home/$user/</b>\\n" \
		--image-on-top --sticky --fixed \
		--width=320 --height=80 \
		--borders=2 --title=Idiomind \
		--skip-taskbar --center \
		--window-icon=idiomind & exit 1
	fi
	
	mkdir "$HOME"/.idiomind/topics
	mkdir "$HOME"/.idiomind/topics/saved
	DIR1="$HOME"/.idiomind/topics
	[ ! -d  "$HOME"/.config ] && mkdir "$HOME"/.config
	mkdir "$HOME"/.config/idiomind
	DIR2="$HOME"/.config/idiomind
	mkdir "$DIR2"/s
	mkdir "$DIR2"/addons
	mkdir "$DIR2"/addons/stats
	mkdir "$DIR2"/addons/dict
	mkdir "$DIR2"/addons/practice
	mkdir "$DIR2"/topics
	DIR3="$HOME"/.config/idiomind/topics
	mkdir "$HOME/.config/idiomind/addons/Learning with news"
	DIR4="$HOME/.config/idiomind/addons/Learning with news"
	cp -f -r /usr/share/idiomind/default/dicts/* $DIR2/addons/dict
	
	if echo "$target" | grep "English"; then
		echo "en" > $DIR2/s/cnfg9
		echo "english" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "French"; then
		echo "fr" > $DIR2/s/cnfg9
		echo "french" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "German"; then
		echo "de" > $DIR2/s/cnfg9
		echo "german" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Italian"; then
		echo "it" > $DIR2/s/s/cnfg9
		echo "italian" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Japanese"; then
		echo "ja" > $DIR2/s/cnfg9
		echo "japanese" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Portuguese"; then
		echo "pt" > $DIR2/s/cnfg9
		echo "portuguese" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Spanish"; then
		echo "es" > $DIR2/s/cnfg9
		echo "spanish" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Vietnamese"; then
		echo "vi" > $DIR2/s/cnfg9
		echo "vietnamese" >> $DIR2/s/cnfg9
	fi
	
	
	if echo "$target" | grep "Chinese"; then
		echo "zh-cn" > $DIR2/s/cnfg9
		echo "Chinese" >> $DIR2/s/cnfg9
	fi
	
	if echo "$target" | grep "Russian"; then
		echo "ru" > $DIR2/s/cnfg9
		echo "Russian" >> $DIR2/s/cnfg9
	fi
	
	if echo "$source" | grep "English"; then
		set_lang English en
	fi
	
	if echo "$source" | grep "French"; then
		set_lang French fr
	fi
	
	if echo "$source" | grep "German"; then
		set_lang German de
	fi
	
	if echo "$source" | grep "Italian"; then
		set_lang Italian it
	fi
	
	if echo "$source" | grep "Japanese"; then
		set_lang Japanese ja
	fi
	
	if echo "$source" | grep "Portuguese"; then
		set_lang Portuguese pt
	fi
	
	if echo "$source" | grep "Spanish"; then
		set_lang Spanish es
	fi
	
	if echo "$source" | grep "Chinese"; then
		set_lang Chinese "zh-cn"
	fi
	
	if echo "$source" | grep "Vietnamese"; then
		set_lang Vietnamese vi
	fi
	
	if echo "$source" | grep "Russian"; then
		set_lang Russian ru
	fi
	
	b=$(tr -dc a-z < /dev/urandom | head -c 1)
	c=$(echo $(($RANDOM%100)))
	echo $c$b > $DIR2/s/cnfg4
	cp /usr/share/idiomind/default/cnfg1 \
	"$HOME/.config/idiomind/s/cnfg1"
	touch $DIR2/s/cnfg8
	touch $DIR2/s/cnfg6
	touch "$DIR4/.cnf"
	touch $DIR2/addons/stats/cnf
	touch $DIR2/s/cnfg12
	#/usr/share/idiomind/mngr.sh mkmn
	exit 1
else
	killall 1u & exit 1
fi
