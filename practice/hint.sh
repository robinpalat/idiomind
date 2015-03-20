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
echo "$1" | awk '{print tolower($0)}' | sed "s/\'//g" | sed "s/\b\(.\)/\u\1/g" \
| sed "s|\.||; s|\,||; s|\;||g" | sed "s|[a-z]|"\."|g" | sed "s| |\t|g" \
| sed "s|\.|\ .|g" | tr "[:upper:]" "[:lower:]" | sed 's/^\s*./\U&\E/g' | \
yad --center --text-info --skip-taskbar \
--justify=left --margins=15 --fontname="Free Sans 15"  \
--buttons-layout=end --borders=0 --wrap --title=" " \
--text-align=center --height=150 --width=460 \
--on-top --align=center --window-icon=idiomind \
--no-buttons & exit
