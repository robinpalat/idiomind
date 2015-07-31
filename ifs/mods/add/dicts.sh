#!/bin/bash
# -*- ENCODING: UTF-8 -*-
s=0
if [ ! -d "$DC_a/dict/enables" ]; then
mkdir -p "$DC_a/dict/enables"; mkdir -p "$DC_a/dict/disables"
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/; fi

[ ! -f "$DC_a/dict/.lng" ] && s=1

if  [[ -z "$(ls "$DC_d"/*."Traslator online.Translator".*)" ]]; then s=1
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please, select at least one resource for each task")"; fi

if  [[ -z "$(ls "$DC_d"/*."TTS online.Pronunciation".*)" ]]; then s=1
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please, select at least one resource for each task")"; fi

if  [[ -z "$(ls "$DC_d"/*."TTS online.Word pronunciation".*)" ]]; then s=1
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please, select at least one resource for each task")"; fi

if  [[ "$(sed -n 1p "$DC_a/dict/.lng")" != "$lgtl" ]] ; then s=1
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please, select at least one resource for each task")"; fi

[ $s = 1 ] && echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.lng"
