#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts
[[ ! -f $DC/addons/dict/.lng ]] && echo $lgtl > $DC/addons/dict/.lng
if [ "$(cat $DC/addons/dict/.lng)" != $lgtl ]; then
source $DS/ifs/trans/$lgs/topics_lists.conf
$DS/addons/Dics/cnfg.sh "" f "$no_dictionary2"
echo $lgtl > $DC/addons/dict/.lng; fi
if  [ -z "$(cat $DC/addons/dict/.dicts)" ]; then
source $DS/ifs/trans/$lgs/topics_lists.conf
$DS/addons/Dics/cnfg.sh "" f "$no_dictionary"; fi


function dictt() {
	
	wrd="$1"
	Wrd="${wrd^}"
	DT_r="$2"
	dir="$DC/addons/dict/"

	if [ "$3" = swrd ]; then

		cd $DT_r
		if [ -f "$DM_tl/.share/$Wrd.mp3" ]; then
				cp -f "$DM_tl/.share/$Wrd.mp3" "$DT_r/$Wrd.mp3"
		else
			n=1
			while [ $n -le $(cat "$dir/.dicts" | wc -l) ]; do
				sh "$(sed -n "$n"p $dir/.dicts)" "$wrd" "$DT_r"
				if [ -f "$DT_r/$wrd.mp3" ]; then
					[[ "$wrd" != "$Wrd" ]] && \
					mv "$DT_r/$wrd.mp3" "$DT_r/$Wrd.mp3"
					break
				fi
				let n++
			done
		fi

	else

		cd $DT_r
		if [ -f "$DM_tl/.share/$Wrd.mp3" ]; then
			echo "$Wrd.mp3" >> "$DC_tlt/cfg.5"
		else
			n=1
			while [ $n -le $(cat $dir/.dicts | wc -l) ]; do
				sh "$(sed -n "$n"p $dir/.dicts)" "$wrd" "$DT_r"
				if [ -f "$DT_r/$wrd.mp3" ]; then
					mv "$DT_r/$wrd.mp3" "$DM_tl/.share/$Wrd.mp3"
					echo "$Wrd.mp3" >> "$DC_tlt/cfg.5"
					break
				fi
				let n++
			done
		fi
	fi

}
