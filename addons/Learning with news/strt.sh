#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add
DSF="$DS/addons/Learning with news"
DCF="$DC/addons/Learning with news"

[[ -f $DT/.uptf ]] && STT=$(cat $DT/.uptf) || STT=""
[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts

if [[ -z "$(cat $DC/addons/dict/.dicts)" ]]; then
	source $DS/ifs/trans/$lgs/topics_lists.conf
	$DS/addons/Dics/cnfg.sh "" f "$no_dictionary"
	if  [[ -z "$(cat $DC/addons/dict/.dicts)" ]]; then
		exit 1
	fi
fi


if ( [ -f $DT/.uptf ] && [ -z "$1" ] ); then
	yad --image=info --width=420 --height=150 \
	--window-icon=idiomind \
	--title=Info --center --borders=5 \
	--on-top --skip-taskbar --button="$cancel":2 \
	--button=Ok:1 --text="$updating_pros"
	ret=$?
		if [ $ret -eq 1 ]; then
			exit 1
		elif [ $ret -eq 2 ]; then
			$DS/stop.sh feed
		fi
	exit 1
elif ( [ -f $DT/.uptf ] && [ "$1" = A ] ); then
	exit
fi
sleep 1

#dct="$DS/addons/Dics/cnfg.sh"
feed=$(sed -n 1p "$DCF/$lgtl/link")
rsrc=$(cat "$DCF/$lgtl/.rss")
icon=$DS/images/cnn.png
date=$(date "+%a %d %B")
c=$(echo $(($RANDOM%1000)))

if [ ! -d $DM_tl/Feeds ]; then

	mkdir $DM_tl/Feeds
	mkdir $DM_tl/Feeds/conten
	mkdir $DM_tl/Feeds/kept
	mkdir $DM_tl/Feeds/kept/.audio
	mkdir $DM_tl/Feeds/kept/words
	mkdir $DC_tl/Feeds/
	mkdir "$DC_a/Learning with news"
	mkdir "$DC_a/Learning with news/$lgtl/rss"
	cp -f "$DSF/examples/$lgtl" "$DCF/rss/$lgtl"
fi
	
if [ ! -f $DC_tl/Feeds/tpc.sh ]; then

	echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/cfg.4)
FEED=$(cat "$DC/addons/Learning with news/$lgtl/.rss")
[ ! -f $DC_tl/Feeds/cfg.8 ] && echo "11" > $DC_tl/Feeds/cfg.8
[ ! -f $DC_tl/Feeds/cfg.0 ] && touch $DC_tl/Feeds/cfg.0
[ ! -f $DC_tl/Feeds/cfg.1 ] && touch $DC_tl/Feeds/cfg.1
[ ! -f $DC_tl/Feeds/cfg.3 ] && touch $DC_tl/Feeds/cfg.3
[ ! -f $DC_tl/Feeds/cfg.4 ] && touch $DC_tl/Feeds/cfg.4
sleep 1
echo "$tpc" > $DC_s/cfg.8
echo fd >> $DC_s/cfg.8
notify-send -i idiomind "Feed Mode" " $FEED" -t 3000
exit 1' > $DC_tl/Feeds/tpc.sh
	chmod +x $DC_tl/Feeds/tpc.sh
	echo "11" > $DC_tl/Feeds/cfg.8
	cd $DC_tl/Feeds
	touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
	$DS/mngr.sh mkmn
fi

if [ -n "$feed" ]; then
	
	internet
	
	echo "Feeds Mode updating... " > $DT/.uptf
	
	if [ "$1" != A ]; then
		echo "$tpc" > $DC_s/cfg.8
		echo fd >> $DC_s/cfg.8
		echo "11" > $DC_tl/Feeds/cfg.8
		notify-send -i idiomind "$rsrc" "$updating" -t 3000 &
	fi
	
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r
	echo "$rsrc" > $DT/.rss
	rsstail -NHPl -n 8 -1 -u "$feed" > rss.txt
	cat rss.txt | sed -n 2~2p | sed 's/^ *//g' | sed 's/\&/\\/g' > lnk
	cat rss.txt | sed -n 1~2p | sed 's/://g' | sed 's/\&//g' | sed 's/"//g' \
	| sed "s/'//g" | sed 's/^ *//g' | sed 's/-/ /g' \
	| sed 's/^[ \t]*//;s/[ \t]*$//g' > rss
	
	if [ $(cat rss | wc -l) = 0 ]; then
	
		msg "<b>$link_err</b>" info &
		rm -fr $DT_r .rss & exit 1
	fi
	
	n=1
	while [ $n -le $(cat rss | wc -l) ]; do
			
			trgt=$(sed -n "$n"p rss)
			lnk=$(sed -n "$n"p lnk)
		
			if [[ "$trgt" != "$(grep "$trgt" $DC_tl/Feeds/.updt.lst)" ]]; then

				nme="$(nmfile "$trgt")"
				mkdir "$nme"
				srce="$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')"
				
				if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
				
					echo "$trgt" > ./trgt
					tts ./trgt $lgt $DT_r "./$nme.mp3"
					
				else
					voice "$trgt" $DT_r "$nme.mp3"
				fi

				if ( [ -f "./$nme.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
						add_tags_1 S "$trgt" "$srce" "./$nme.mp3"
				fi

				(

				r=$(echo $(($RANDOM%1000)))
				clean_3 $DT_r $r
				translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
				| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
				check_grammar_1 $DT_r $r
				list_words $DT_r $r
				grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
				lwrds=$(cat A.$r)
				pwrds=$(cat B.$r | tr '\n' '_')
				
				if ( [ ! -f "./$nme.mp3" ] || [ -z "$lwrds" ] || [ -z "$pwrds" ] ); then
					[ -f "./$nme.mp3" ] && rm "./$nme.mp3"
					[ -d "./$nme" ] && rm -r "./$nme"
				else
					add_tags_9 W "$lwrds" "$pwrds" "./$nme.mp3"
					echo "$trgt" >> "$DC_tl/Feeds/cfg.1"
					
					fetch_audio_2 $aw $bw

					cp -fr "./$nme" "$DM_tl/Feeds/conten/$nme"
					mv -f "$nme.mp3" "$DM_tl/Feeds/conten/$nme.mp3"
					echo "$lnk" > "$DM_tl/Feeds/conten/$nme.lnk"
					notify-send -i idiomind "$trgt" "$srce" -t 12000 &
				fi

				echo "__" >> x
				rm -f $aw $bw 
				)
				
				echo "$date" > $DC_tl/Feeds/.dt
			fi
			let n++
	done

	mv -f $DT_r/rss "$DC_tl/Feeds/.updt.lst"
	rm -fr $DT_r $DT/.uptf $DT/.rss
	cd "$DM_tl/Feeds/conten"
	find *.mp3 -mtime +5 -exec ls > ls {} \;
	n=1
	while [ $n -le $(cat ls | wc -l) ]; do
		nmfile=$(sed -n "$n"p ./ls)
		tgs=$(eyeD3 "$DM_tl/Feeds/conten/$nmfile")
		trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		grep -v -x -v "$trg" "$DC_tl/Feeds/cfg.1" > "$DC_tl/Feeds/cfg.1.tmp"
		sed '/^$/d' "$DC_tl/Feeds/cfg.1.tmp" > "$DC_tl/Feeds/cfg.1"
		let n++
	done
	rm "$DC_tl/Feeds/*.tmp"
	
	if [[ -d "$DM_tl/Feeds/conten" ]]; then
	cd "$DM_tl/Feeds/conten"
	find ./* -mtime +5 -exec rm -r {} \; &
	fi

	if [ "$1" != A ]; then
		notify-send -i idiomind "$rsrc" " $updateok" -t 3000
	fi
	
	exit
else
	exit 0
fi
