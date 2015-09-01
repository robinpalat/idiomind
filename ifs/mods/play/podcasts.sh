#!/bin/bash
# -*- ENCODING: UTF-8 -*-

file_cfg="${DM_tl}"/Podcasts/.conf/podcasts.cfg
if [[ -e "$file_cfg" ]]; then
if [ `grep -o enable=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'` = TRUE ]; then
declare -A items=( ['New episodes <i><small>Podcasts</small></i>']='nsepi' \
['Saved episodes <i><small>Podcasts</small></i>']='svepi' )
fi
fi
