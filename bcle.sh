#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#  2015/02/27
[[ -z "$tpc" && -d "$DT" ]] && exit 1
source "$DC_s/1.cfg"
> "$DT/.p_"
cd "$DT"
n=1

if ([ -n "$(cat ./index)" ] && [ $(wc -l < ./index) -gt 0 ]); then
    if [ "$repeat" = "TRUE" ]; then
        while [ 1 ]; do
            while [ $n -le $(wc -l < ./index) ]; do
                "$DS/chng.sh" chngi "$n"
                let n++
            done
        done
        
    else
        while [ $n -le $(wc -l < ./index) ]; do
        "$DS/chng.sh" chngi "$n"
            let n++
        done
        rm -fr "$DT/.p_"
    fi
else
    exit 1
fi
