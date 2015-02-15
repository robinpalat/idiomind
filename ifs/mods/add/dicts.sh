#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if [ ! -d "$DC_a/dict/" ]; then
mkdir -p $DC_a/dict/enables
mkdir -p $DC_a/dict/disables
cp -f $DS/addons/Dics/disables/* $DC_a/dict/disables/; fi
[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts
[[ ! -f $DC/addons/dict/.lng ]] && echo $lgtl > $DC/addons/dict/.lng
if  [ -z "$(cat $DC/addons/dict/.dicts)" ]; then
source $DS/ifs/trans/$lgs/topics_lists.conf
$DS/addons/Dics/cnfg.sh "" f "$no_dictionary"; fi
if [ "$(cat $DC/addons/dict/.lng)" != $lgtl ]; then
source $DS/ifs/trans/$lgs/topics_lists.conf
$DS/addons/Dics/cnfg.sh "" f "$no_dictionary2"
echo $lgtl > $DC/addons/dict/.lng; fi

function dictt() {
	
	w="$1"
	dird="$DC/addons/dict/"

	while read dict; do
	
		sh "$dict" "$w" "$2"
		
			if [ -f "$2/$w.mp3" ]; then
			break; fi
			
	done < $dird/.dicts
}
