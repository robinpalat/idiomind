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

    dir="${2}"
    file="${dir}/12.cfg"
    nu='^[0-9]+$'
    
    dirs="$(find "${dir}"/ -maxdepth 5 -type d | sed '/^$/d' | wc -l)"
    name="$(sed -n 1p < "${file}" | grep -o 'name="[^"]*' | grep -o '[^"]*$')"
    language_source=$(sed -n 2p < "${file}" | grep -o 'language_source="[^"]*' | grep -o '[^"]*$')
    language_target=$(sed -n 3p < "${file}" | grep -o 'language_target="[^"]*' | grep -o '[^"]*$')
    author="$(sed -n 4p < "${file}" | grep -o 'author="[^"]*' | grep -o '[^"]*$')"
    contact=$(sed -n 5p < "${file}" | grep -o 'contact="[^"]*' | grep -o '[^"]*$')
    category=$(sed -n 6p < "${file}" | grep -o 'category="[^"]*' | grep -o '[^"]*$')
    link=$(sed -n 7p < "${file}" | grep -o 'link="[^"]*' | grep -o '[^"]*$')
    date_c=$(sed -n 8p < "${file}" | grep -o 'date_c="[^"]*' | grep -o '[^"]*$' | tr -d '-')
    date_u=$(sed -n 9p < "${file}" | grep -o 'date_u="[^"]*' | grep -o '[^"]*$' | tr -d '-')
    nwords=$(sed -n 10p < "${file}" | grep -o 'nwords="[^"]*' | grep -o '[^"]*$')
    nsentences=$(sed -n 11p < "${file}" | grep -o 'nsentences="[^"]*' | grep -o '[^"]*$')
    nimages=$(sed -n 12p < "${file}" | grep -o 'nimages="[^"]*' | grep -o '[^"]*$')
    level=$(sed -n 13p < "${file}" | grep -o 'level="[^"]*' | grep -o '[^"]*$')

    if [ "${name}" != "${3}" ] || [ $(wc -c <<<"${name}") -gt 80 ] || \
    [ `grep -o -E '\*|\/|\@|$|\)|\(|=|-' <<<"${name}"` ]; then
    msg "$(gettext "File is corrupted.") E1\n" error & exit 1
    elif ! grep -Fox "${language_source}" <<<"${LANGUAGES}"; then
    msg "$(gettext "File is corrupted.") E2\n" error && exit 1
    elif ! grep -Fox "${language_target}" <<<"${LANGUAGES}"; then
    msg "$(gettext "File is corrupted.") E3\n" error & exit 1
    elif [ $(wc -c <<<"${author}") -gt 20 ] || \
    [ `grep -o -E '\.|\*|\/|\@|$|\)|\(|=|-' <<<"${author}"` ]; then
    msg "$(gettext "File is corrupted.") E4\n" error & exit 1
    elif [ $(wc -c <<<"${contact}") -gt 30 ] || \
    [ `grep -o -E '\*|\/|$|\)|\(|=' <<<"${contact}"` ]; then
    msg "$(gettext "File is corrupted.") E5\n" error & exit 1
    elif ! grep -Fox "${category}" <<<"${CATEGORIES}"; then
    msg "$(gettext "File is corrupted.") E6\n" error & exit 1
    elif ! [[ 1 =~ $nu ]] || [ $(wc -c <<<"${link}") -gt 400 ]; then # TODO
    msg "$(gettext "File is corrupted.") E7\n" error & exit 1
    elif ! [[ $date_c =~ $nu ]] || [ $(wc -c <<<"${date_c}") -gt 12 ] && \
    [ -n "${date_c}" ]; then
    msg "$(gettext "File is corrupted.") E8\n" error & exit 1
    elif ! [[ $date_u =~ $nu ]] || [ $(wc -c <<<"${date_u}") -gt 12 ] && \
    [ -n "${date_u}" ]; then
    msg "$(gettext "File is corrupted.") E9\n" error & exit 1
    elif ! [[ $nwords =~ $nu ]] || [ "${nwords}" -gt 200 ]; then
    msg "$(gettext "File is corrupted.") E10\n" error & exit 1
    elif ! [[ $nsentences =~ $nu ]] || [ "${nsentences}" -gt 200 ]; then
    msg "$(gettext "File is corrupted.") E11\n" error & exit 1
    elif ! [[ $nimages =~ $nu ]] || [ "${nimages}" -gt 200 ]; then
    msg "$(gettext "File is corrupted.") E12\n" error & exit 1
    elif ! [[ $level =~ $nu ]] || [ $(wc -c <<<"$level") -gt 2 ]; then
    msg "$(gettext "File is corrupted.") E13\n" error & exit 1
    elif grep "invalid" <<<"$chckf"; then
    msg "$(gettext "File is corrupted.") E14\n" error & exit 1
    elif [[ $dirs -gt 5 ]] ; then
    msg "$(gettext "File is corrupted.") E15\n" error & exit 1
    else
    head -n14 < "${file}" > "$DT/$name.cfg"
    fi
}

check_install() {

    chckf=""
    
    while read -r f; do
        if ! file "$f" | grep -o -E 'Audio|ASCII|UTF-8|empty|MPEG|JPEG|data'; then
        chckf="invalid"; fi
    done <<<"$(find "$dir" -maxdepth 5 -type f)"
}

text() {
    cd "$2"
    dirs="$(find . -maxdepth 5 -type d)"
    files="$(find . -maxdepth 5 -type f)"
    hfiles="$(ls -d ./.[^.]* | less)"
    exfiles="$(find . -maxdepth 5 -perm -111 -type f)"
    wordsdir="$(cd "./words/"; find . -maxdepth 1 -type f)"
    attchsdir="$(cd "./attchs/"; find . -maxdepth 5 -type f)"
    imagesdir="$(cd "./words/images/"; find . -maxdepth 1 -type f)"
    audiodir="$(cd "./audio/"; find . -maxdepth 1 -type f)"
    maindir="$(find . -maxdepth 1 -type f)"
    wcdirs=`sed '/^$/d' <<<"${dirs}" | wc -l`
    wcfiles=`sed '/^$/d' <<<"${files}" | wc -l`
    wchfiles=`sed '/^$/d' <<<"${hfiles}" | wc -l`
    wcexfiles=`sed '/^$/d' <<<"${exfiles}" | wc -l`
    SRFL1=$(cat "$2/12.cfg")
    SRFL2=$(cat "$2/10.cfg")
    SRFL3=$(cat "$2/4.cfg")
    SRFL4=$(cat "$2/3.cfg")
    SRFL5=$(cat "$2/0.cfg")
    
    echo -e "
SUMMARY
===========================
$wcdirs directories
$wcfiles files
$wchfiles hidden files
$wcexfiles executables files




DIRECTORIES
===========================
$dirs




FILES
===========================

./

$maindir



./words

$wordsdir



./words/images

$imagesdir



./attchs

$attchsdir



./audio

$audiodir




HIDDEN FILES
===========================
$hfiles




EXECUTABLES FILES
===========================
$exfiles




TEXT FILES
===========================

12.cfg content (configuration file)

$SRFL1




10.cfg content (note)

$SRFL2




4.cfg content (sentences list)

$SRFL3




3.cfg content (words list)

$SRFL4




0.cfg content (index list)

$SRFL5



" | yad --width=520 --height=450 --text-info --margins=10 \
    --name=Idiomind --class=Idiomind \
    --buttons-layout=edge --scroll \
    --window-icon="$DS/images/logo.png" --center --borders=0 \
    --button="$(gettext "Open Folder")":"xdg-open '$2'" \
    --button="$(gettext "Close")":0 \
    --title="$(gettext "Installation details")" >/dev/null 2>&1
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
            msg "$(gettext "File not found")\n" error & exit 1
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
