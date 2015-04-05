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
source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)
CATEGORIES="others
comics
culture
family
entertainment
grammar
history
documentary
in_the_city
movies
internet
music
nature
news
office
relations
sport
social_networks
shopping
technology
travel
article
science
interview
funny"
LANGUAGES="English
Chinese
French
German
Italian
Japanese
Portuguese
Russian
Spanish
Vietnamese"

check_source_1() {

    file="${2}"
    
    name="$(sed -n 1p < "${file}" | grep -o 'name="[^"]*' | grep -o '[^"]*$')"
    language_source=$(sed -n 2p < "${file}" | grep -o 'language_source="[^"]*' | grep -o '[^"]*$')
    language_target=$(sed -n 3p < "${file}" | grep -o 'language_target="[^"]*' | grep -o '[^"]*$')
    author="$(sed -n 4p < "${file}" | grep -o 'author="[^"]*' | grep -o '[^"]*$')"
    contact=$(sed -n 5p < "${file}" | grep -o 'contact="[^"]*' | grep -o '[^"]*$')
    category=$(sed -n 6p < "${file}" | grep -o 'category="[^"]*' | grep -o '[^"]*$')
    link=$(sed -n 7p < "${file}" | grep -o 'link="[^"]*' | grep -o '[^"]*$')
    date_c=$(sed -n 8p < "${file}" | grep -o 'date_c="[^"]*' | grep -o '[^"]*$')
    date_u=$(sed -n 9p < "${file}" | grep -o 'date_u="[^"]*' | grep -o '[^"]*$')
    nwords=$(sed -n 10p < "${file}" | grep -o 'nwords="[^"]*' | grep -o '[^"]*$')
    nsentences=$(sed -n 11p < "${file}" | grep -o 'nsentences="[^"]*' | grep -o '[^"]*$')
    nimages=$(sed -n 12p < "${file}" | grep -o 'nimages="[^"]*' | grep -o '[^"]*$')
    level=$(sed -n 13p < "${file}" | grep -o 'level="[^"]*' | grep -o '[^"]*$')

    if [ "${name}" != "${3}" ]; then
    msg "$(gettext "File is corrupted. E1")" error & exit 1
    
    elif ! grep -Fox "${language_source}" <<<"${LANGUAGES}"; then
    msg "$(gettext "File is corrupted. E2")" error && exit 1
    
    elif ! grep -Fox "${language_target}" <<<"${LANGUAGES}"; then
    msg "$(gettext "File is corrupted. E3")" error & exit 1
    
    elif [ $(wc -c <<<"${author}") -gt 20 ]; then
    msg "$(gettext "File is corrupted. E4")" error & exit 1
    
    elif [ $(wc -c <<<"${contact}") -gt 20 ]; then
    msg "$(gettext "File is corrupted. Error 5")" & exit 1
    
    elif ! grep -Fox "${category}" <<<"${CATEGORIES}"; then
    msg "$(gettext "File is corrupted. E6")" error & exit 1
    
    elif [ $(wc -c <<<"${link}") -gt 400 ]; then
    msg "$(gettext "File is corrupted. E7")" error & exit 1
    
    elif [ $(wc -c <<<"${date_c}") -gt 10 ]; then
    msg "$(gettext "File is corrupted. E8")" error & exit 1
    
    elif [ 1 -gt 10 ]; then
    msg "$(gettext "File is corrupted. E9")" error & exit 1
    
    elif [ "${nwords}" -gt 200 ]; then
    msg "$(gettext "File is corrupted. E10")" error & exit 1
    
    elif [ "${nsentences}" -gt 200 ]; then
    msg "$(gettext "File is corrupted. E11")" error & exit 1
    
    elif [ "${nimages}" -gt 200 ]; then
    msg "$(gettext "File is corrupted. E12")" error & exit 1
    
    elif [ $(wc -c <<<"$level") -gt 2 ]; then
    msg "$(gettext "File is corrupted. E13")" error & exit 1
    
    else
        head -n14 < "${file}" > "$DT/$name.cfg"
    fi
}

check_install() {

 echo >/dev/null 2>&1
}

text() {

    yad --width=300 --height=250 --form --field="$(< "$2")":lbl \
    --on-top --name=Idiomind --class=Idiomind --scroll --fixed \
    --window-icon="$DS/images/logo.png" --center --borders=5 \
    --button="$(gettext "Close")":0 \
    --title="$(gettext "Info")" >/dev/null 2>&1
}

check_index() {

    source /usr/share/idiomind/ifs/c.conf
    DC_tlt="$DM_tl/$2/.conf"
    DM_tlt="$DM_tl/$2"
    
    check() {

        n=0
        while [ $n -le 4 ]; do
            [ ! -f "$DC_tlt/$n.cfg" ] && touch "$DC_tlt/$n.cfg"
            check_index1 "$DC_tlt/$n.cfg"
            chk=$(wc -l < "$DC_tlt/$n.cfg")
            [ -z "$chk" ] && chk=0
            eval chk$n=$(echo $chk)
            ((n=n+1))
        done
        
        if [ ! -f "$DC_tlt/8.cfg" ]; then
            if grep -Fxo "$2" "$DM_tl/.3.cfg"; then
            echo '6' > "$DC_tlt/8.cfg"
            else echo '1' > "$DC_tlt/8.cfg"; fi
        fi
        eval stts=$(< "$DC_tlt/8.cfg")

        eval mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | wc -l)"
    }
    
    fix() {
       rm "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" "$DC_tlt/2.cfg" \
       "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
       
       while read name; do
        
            sfname="$(nmfile "$name")"

            if [ -f "$DM_tlt/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/$name.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
            elif [ -f "$DM_tlt/$sfname.mp3" ]; then
                tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
                trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
                [ -z "$trgt" ] && rm "$DM_tlt/$sfname.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$sfname" != "$xname" ] && \
                mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
            elif [ -f "$DM_tlt/words/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$name.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
            elif [ -f "$DM_tlt/words/$sfname.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$sfname.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$sfname.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$sfname" != "$xname" ] \
                && mv -f "$DM_tlt/words/$sfname.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
            fi
            
        done < "$index"

        [ -f "$DC_tlt/0.cfg.tmp" ] && mv -f "$DC_tlt/0.cfg.tmp" "$DC_tlt/0.cfg"
        [ -f "$DC_tlt/3.cfg.tmp" ] && mv -f "$DC_tlt/3.cfg.tmp" "$DC_tlt/3.cfg"
        [ -f "$DC_tlt/4.cfg.tmp" ] && mv -f "$DC_tlt/4.cfg.tmp" "$DC_tlt/4.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
        
        check_index1 "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" \
        "$DC_tlt/2.cfg" "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
        
        if [ $? -ne 0 ]; then
            [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
            msg " $(gettext "File not found")\n" error & exit 1
        fi
        
        if [ "$stts" = "13" ]; then
            if grep -Fxo "$topic" < "$DM_tl/.3.cfg"; then
                echo "6" > "$DC_tlt/8.cfg"
            elif grep -Fxo "$topic" < "$DM_tl/.2.cfg"; then
                echo "1" > "$DC_tlt/8.cfg"
            else
                echo "1" > "$DC_tlt/8.cfg"
            fi
        fi
    }
        
    files() {
        
        cd "$DM_tlt/words/"
        for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"
        for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
        | sed s'|\.\/||'g | sed s'|\.mp3||'g > "$DT/index"
    }

    check

    if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
    || $mp3s != $chk0 || $stts = 13 ]]; then
    
        (sleep 1
        notify-send -i idiomind "$(gettext "Index error")" "$(gettext "fixing...")" -t 3000) &
        > "$DT/ps_lk"
        [ ! -d "$DM_tlt/.conf" ] && mkdir "$DM_tlt/.conf"
        DC_tlt="$DM_tlt/.conf"
        
        files
        
        if ([ -f "$DC_tlt/.11.cfg" ] && \
        [ -n "$(< "$DC_tlt/.11.cfg")" ]); then
            index="$DC_tlt/.11.cfg"
        else
            index="$DT/index"
        fi
        
        fix
    fi

    check
    
    if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
    || $mp3s != $chk0 || $stts = 13 ]]; then

        files
        
        index="$DT/index"; rm "$DC_tlt/.11.cfg"

        fix
    fi
    
    n=0
    while [ $n -le 4 ]; do
        touch "$DC_tlt/$n.cfg"
        ((n=n+1))
    done
    rm -f "$DT/index" "$DM_tlt/.conf/9.cfg"
    "$DS/mngr.sh" mkmn & exit 1
}

case "$1" in
    text)
    text "$@" ;;
    check_source_1)
    check_source_1 "$@" ;;
    check_index)
    check_index "$@" ;;
esac
