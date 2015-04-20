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

check_source_1() {

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

    if [ "${name}" != "${3}" ] || [ $(wc -c <<<"${name}") -gt 100 ] || \
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

details() {
    cd "$2"
    dirs="$(find . -maxdepth 5 -type d)"
    files="$(find . -type f -exec file {} \; 2> /dev/null)"
    hfiles="$(ls -d ./.[^.]* | less)"
    exfiles="$(find . -maxdepth 5 -perm -111 -type f)"
    attchsdir="$(cd "./files/"; find . -maxdepth 5 -type f)"
    wcdirs=`sed '/^$/d' <<<"${dirs}" | wc -l`
    wcfiles=`sed '/^$/d' <<<"${files}" | wc -l`
    wchfiles=`sed '/^$/d' <<<"${hfiles}" | wc -l`
    wcexfiles=`sed '/^$/d' <<<"${exfiles}" | wc -l`
    SRFL1=$(cat "./12.cfg")
    SRFL2=$(cat "./10.cfg")
    SRFL3=$(cat "./4.cfg")
    SRFL4=$(cat "./3.cfg")
    SRFL5=$(cat "./0.cfg")
    
    echo -e "
SUMMARY
======================
$wcdirs directories
$wcfiles files
$wchfiles hidden files
$wcexfiles executables files



DIRECTORIES
======================
$dirs



FILES
======================
$files


./files

$attchsdir



HIDDEN FILES
======================
$hfiles



EXECUTABLES FILES
======================
$exfiles



TEXT FILES
======================

12.cfg content (configuration file)

$SRFL1




10.cfg content

$SRFL2




4.cfg content

$SRFL3




3.cfg content

$SRFL4




0.cfg content

$SRFL5" | yad --text-info --title="$(gettext "Installation details")" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" --center \
    --buttons-layout=edge --scroll --margins=10 \
    --width=550 --height=550 --borders=0 \
    --button="$(gettext "Open Folder")":"xdg-open '$2'" \
    --button="$(gettext "Close")":0
    
} >/dev/null 2>&1

check_index() {

    source /usr/share/idiomind/ifs/c.conf
    DC_tlt="$DM_tl/$2/.conf"
    DM_tlt="$DM_tl/$2"
    
    check() {

        n=0
        while [[ $n -le 4 ]]; do
            [ ! -f "$DC_tlt/$n.cfg" ] && touch "$DC_tlt/$n.cfg"
            check_index1 "$DC_tlt/$n.cfg"
            chk=$(wc -l < "$DC_tlt/$n.cfg")
            [ -z "$chk" ] && chk=0
            eval chk$n="$chk"
            ((n=n+1))
        done
        
        if [ ! -f "$DC_tlt/8.cfg" ]; then
        echo 1 > "$DC_tlt/8.cfg"; fi
        eval stts=$(sed -n 1p "$DC_tlt/8.cfg")

        eval mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | wc -l)"
    }
    
    
    fix() {
        
       rm "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" "$DC_tlt/2.cfg" \
       "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
       
       while read name; do
        
            md5sum="$(nmfile "$name")"

            if [[ ${#name} != 32 ]]; then
                [ -f "$DM_tlt/$name.mp3" ] && rm "$DM_tlt/$name.mp3"
                [ -f "$DM_tlt/words/$name.mp3" ] && rm "$DM_tlt/words/$name.mp3"
                continue

            elif [ -f "$DM_tlt/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/$name.mp3" && continue
                md5sum_2="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$md5sum_2" ] && \
                mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$md5sum_2.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
                
            elif [ -f "$DM_tlt/$md5sum.mp3" ]; then
                tgs=$(eyeD3 "$DM_tlt/$md5sum.mp3")
                trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
                [ -z "$trgt" ] && rm "$DM_tlt/$md5sum.mp3" && continue
                md5sum_2="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$md5sum" != "$md5sum_2" ] && \
                mv -f "$DM_tlt/$md5sum.mp3" "$DM_tlt/$md5sum_2.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
                
            elif [ -f "$DM_tlt/words/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$name.mp3" && continue
                md5sum_2="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$md5sum_2" ] && \
                mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$md5sum_2.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
                
            elif [ -f "$DM_tlt/words/$md5sum.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$md5sum.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$md5sum.mp3" && continue
                md5sum_2="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$md5sum" != "$md5sum_2" ] \
                && mv -f "$DM_tlt/words/$md5sum.mp3" "$DM_tlt/words/$md5sum_2.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
            fi
            
        done < "$index"

        [ -f "$DC_tlt/0.cfg.tmp" ] && mv -f "$DC_tlt/0.cfg.tmp" "$DC_tlt/0.cfg"
        [ -f "$DC_tlt/3.cfg.tmp" ] && mv -f "$DC_tlt/3.cfg.tmp" "$DC_tlt/3.cfg"
        [ -f "$DC_tlt/4.cfg.tmp" ] && mv -f "$DC_tlt/4.cfg.tmp" "$DC_tlt/4.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
        rm -r "$DC_tlt/practice"
        
        check_index1 "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" \
        "$DC_tlt/2.cfg" "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
        
        if [ $? -ne 0 ]; then
        
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        msg "$(gettext "File not found")\n" error & exit 1; fi
        
        if [ "$stts" = "13" ]; then
        
            if [ "$DC_tlt/8.cfg_" ]; then
            stts=$(sed -n 1p "$DC_tlt/8.cfg_")
            rm "$DC_tlt/8.cfg_"
            else stts=1; fi
            echo "$stts" > "$DC_tlt/8.cfg"
        fi
    }
        
    name_files() {
        
        cd "$DM_tlt/words/"
        for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
        find -name "* *" -type f | rename 's/ /_/g'
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"
        for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
        find -name "* *" -type f | rename 's/ /_/g'
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
        | sed s'|\.\/||'g | sed s'|\.mp3||'g > "$DT/index"
    }

    check

    if [ $((chk3+chk4)) != $chk0 ]  || [ $((chk1+chk2)) != $chk0 ] \
    || [ $mp3s != $chk0 ] || [ $stts = 13 ]; then
    
        (sleep 1
        notify-send -i idiomind "$(gettext "Index Error")" "$(gettext "Fixing...")" -t 3000) &
        > "$DT/ps_lk"
        [ ! -d "$DM_tlt/.conf" ] && mkdir "$DM_tlt/.conf"
        DC_tlt="$DM_tlt/.conf"
        
        name_files

        index="$DT/index"
        
        fix

    check
    
    if [ $((chk3+chk4)) != $chk0 ]  || [ $((chk1+chk2)) != $chk0 ] \
    || [ $mp3s != $chk0 ] || [ $stts = 13 ]; then

        name_files
        
        index="$DT/index"; rm "$DC_tlt/.11.cfg"
        
        fix
    fi
    
    n=0
    while [[ $n -le 4 ]]; do
        touch "$DC_tlt/$n.cfg"
        ((n=n+1))
    done
    #rm -f "$DT/index"
    "$DS/mngr.sh" mkmn & exit 1
    
    else
    exit
    fi
}

function add_audio() {

    cd "$HOME"
    AU=$(yad --file --title="$(gettext "Add Audio")" \
    --text=" $(gettext "Browse to and select the audio file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --file-filter="*.mp3" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=620 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)

    ret=$?
    audio=$(cut -d "|" -f1 <<<"$AU")

    DT="$2"; cd "$DT"
    if [[ $ret -eq 0 ]]; then
        if  [ -f "$audio" ]; then
        cp -f "$audio" "$DT/audtm.mp3"
        #eyeD3 -P itunes-podcast --remove $DT/audtm.mp3
        eyeD3 --remove-all "$DT/audtm.mp3" & exit
        fi
    fi
} >/dev/null 2>&1

function edit_audio() {

    cmd="$(sed -n 16p $DC_s/1.cfg)"
    (cd "$3"; "$cmd" "$2") & exit
}

function text() {

    yad --form --title="$(gettext "Info")" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --scroll --fixed --center --on-top \
    --width=300 --height=250 --borders=5 \
    --field="$(< "$2")":lbl \
    --button="$(gettext "Close")":0
     
} >/dev/null 2>&1

function add_file() {

    cd "$HOME"
    FL=$(yad --file --title="$(gettext "Add File")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --name=Idiomind --class=Idiomind \
    --file-filter="*.mp3 *.ogg *.mp4 *.m4v *.jpg *.jpeg *.png *.txt *.pdf *.gif" \
    --add-preview --multiple \
    --window-icon="$DS/images/icon.png" --on-top --center \
    --width=680 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)
    ret=$?

    if [[ $ret -eq 0 ]]; then
    
        while read -r file; do
        [ -f "$file" ] && cp -f "$file" "$DM_tlt/files"
        done <<<"$(tr '|' '\n' <<<"$FL")"
    fi

} >/dev/null

function videourl() {

    n=$(ls *.url "$DM_tlt/files/" | wc -l)
    url=$(yad --form --title=" " \
    --name=Idiomind --class=Idiomind \
    --separator="" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=480 --height=100 --borders=5 \
    --field="$(gettext "YouTube URL")" \
    --button="$(gettext "Cancel")":1 \
    --button=gtk-ok:0)

    [ ${#url} -gt 40 ] && \
    echo "$url" > "$DM_tlt/files/video$n.url"

}

function attatchments() {
    
    mkindex() {

echo "<link rel=\"stylesheet\" \
href=\"/usr/share/idiomind/default/attch.css\">\
<body><div class=\"summary\">" \
> "$DC_tlt/att.html"

        while read -r file; do
    
if grep ".mp3" <<<"$file"; then
name="$(sed s'/\.mp3//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><audio controls>
<source src=\"../files/$file\" type=\"audio/mpeg\">
Your browser does not support the audio tag.
</audio><br><br>" >> "$DC_tlt/att.html"
elif grep ".ogg" <<<"$file"; then
name="$(sed s'/\.ogg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><audio controls>
<source src=\"../files/$file\" type=\"audio/mpeg\">
Your browser does not support the audio tag.
</audio><br><br>" >> "$DC_tlt/att.html"
elif grep ".mp4" <<<"$file"; then
name="$(sed s'/\.mp4//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><video width=450 height=280 controls>
<source src=\"../files/$file\" type=\"video/mp4\">
Your browser does not support the video tag.
</video><br><br>" >> "$DC_tlt/att.html"
elif grep ".m4v" <<<"$file"; then
name="$(sed s'/\.m4v//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><video width=450 height=280 controls>
<source src=\"../files/$file\" type=\"video/mp4\">
Your browser does not support the video tag.
</video><br><br>" >> "$DC_tlt/att.html"
elif grep ".jpg" <<<"$file"; then
name="$(sed s'/\.jpg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".jpeg" <<<"$file"; then
name="$(sed s'/\.jpeg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".png" <<<"$file"; then
name="$(sed s'/\.png//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".txt" <<<"$file"; then
txto=$(cat "$DM_tlt/files/$file")
echo "<br><br><div class=\"summary\">$txto \
<br><br></div>" \
>> "$DC_tlt/att.html"
elif grep ".url" <<<"$file"; then
url=$(tr -d '=' < "$DM_tlt/files/$file" \
| sed 's|watch?v|v\/|;s|https|http|g')
echo "<br><br><div class=\"summary\">
<iframe width=\"420\" height=\"315\" src=\"$url\" \
frameborder=\"0\" allowfullscreen></iframe>
</div><br><br>" >> "$DC_tlt/att.html"
elif grep ".gif" <<<"$file"; then
name="$(sed s'/\.gif//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../files/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
fi
        done <<<"$(ls "$DM_tlt/files")"
    
echo "<br><br></div>
</body>" >> "$DC_tlt/att.html"
            
    } >/dev/null 2>&1
    
    [ ! -d "$DM_tlt/files" ] && mkdir "$DM_tlt/files"
    ch1="$(ls -A "$DM_tlt/files")"
    
    if [ "$(ls -A "$DM_tlt/files")" ]; then
        [ ! -f "$DC_tlt/att.html" ] && mkindex >/dev/null 2>&1
        yad --html --title="$(gettext "Attached Files")" \
        --name=Idiomind --class=Idiomind \
        --uri="$DC_tlt/att.html" --browser \
        --window-icon="$DS/images/icon.png" --center \
        --width=650 --height=580 --borders=10 \
        --button="$(gettext "Folder")":"xdg-open '$DM_tlt/files'" \
        --button="$(gettext "Video")":"$DS/ifs/tls.sh 'videourl'" \
        --button="$(gettext "File")":"$DS/ifs/tls.sh 'add_file'" \
        --button="$(gettext "Close")":"1"

        if [ "$ch1" != "$(ls -A "$DM_tlt/files")" ]; then
            mkindex
        fi
        
    else
        yad --form --title="$(gettext "Attached Files")" \
        --text="$(gettext "Save files related to topic.")" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --center \
        --width=350 --height=180 --borders=5 \
        --field="$(gettext "Add File")":FBTN "$DS/ifs/tls.sh 'add_file'" \
        --field="$(gettext "YouTube video URL")":FBTN "$DS/ifs/tls.sh 'videourl'" \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0
        ret=$?
        if [ "$ch1" != "$(ls -A "$DM_tlt/files")" ] && [ $ret = 0 ]; then
            mkindex
        fi
    fi

} >/dev/null 2>&1

function help() {

    internet
    web="http://idiomind.sourceforge.net/doc/help.html"
    yad --html --title="$(gettext "Help")" \
    --name=Idiomind --class=Idiomind \
    --uri="$web" --browser \
    --window-icon="$DS/images/icon.png" --fixed \
    --width=700 --height=600 \
    --button="$(gettext "OK")":0
     
} >/dev/null 2>&1
    
function definition() {

    web="http://glosbe.com/$lgt/$lgs/${2,,}"
    xdg-open "$web"
}

function web() {

    web=http://idiomind.sourceforge.net
    xdg-open "$web/$lgs/${lgtl,,}" >/dev/null 2>&1
}

function fback() {
    
    internet
    web="http://idiomind.sourceforge.net/doc/msg.html"
    yad --html --title="$(gettext "Feedback")" \
    --name=Idiomind --class=Idiomind \
    --browser --uri="$web" \
    --window-icon="$DS/images/icon.png" \
    --no-buttons --fixed \
    --width=500 --height=455
     
} >/dev/null 2>&1

function check_updates() {

    cd "$DT"; internet
    [ -f release ] && rm -f release
    rversion="$(curl http://idiomind.sourceforge.net/doc/release | sed -n 1p)"
    pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
    
    if [ "$rversion" != "$(idiomind -v)" ]; then
    
        msg_2 "<b> $(gettext "A new version of Idiomind available") </b>\n\n" \
        info "$(gettext "Download")" "$(gettext "Cancel")" $(gettext "Updates")
        
        if [[ $ret -eq 0 ]]; then
        
            xdg-open "$pkg";
            
        elif [[ $ret -eq 1 ]]; then
        
            echo `date +%d` > "$DC_s/9.cfg";
        fi
        
    else
        msg " $(gettext "No updates available.") \n" info $(gettext "Updates")
    fi

    exit 0
}

function a_check_updates() {

    [ ! -f "$DC_s/9.cfg" ] && echo `date +%d` > "$DC_s/9.cfg" && exit
    
    d1=$(< "$DC_s/9.cfg"); d2=$(date +%d)
    if [ "$(sed -n 1p "$DC_s/9.cfg")" = 28 ] \
    && [ "$(wc -l < "$DC_s/9.cfg")" -ge 2 ]; then
    rm -f "$DC_s/9.cfg"; fi

    if [ "$d1" != "$d2" ]; then

        echo "$d2" > "$DC_s/9.cfg"
        cd "$DT"; internet; [ -f release ] && rm -f release
        curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        rversion="$(curl http://idiomind.sourceforge.net/doc/release | sed -n 1p)"
        pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
        
        if [ "$rversion" != "$(idiomind -v)" ]; then
            
            msg_2 "<b>$(gettext "A new version of Idiomind available")\n</b>\n$(gettext "Do you want to download it now?")\n" info "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Updates")" "$(gettext "Ignore this update")"
            ret=$(echo $?)
            
            if [[ $ret -eq 0 ]]; then
            
            xdg-open "$pkg";
            
            elif [[ $ret -eq 2 ]]; then
            
            echo `date +%d` >> "$DC_s/9.cfg";
            
            elif [[ $ret -eq 1 ]]; then
            
            echo `date +%d` > "$DC_s/9.cfg";
            
            fi
        fi
    fi
    exit 0
}

function about() {

python << END
import gtk
import os
app_logo = os.path.join('/usr/share/idiomind/images/idiomind.png')
app_name = 'Idiomind'
app_version = 'v2.2-beta'
app_comments = 'Vocabulary learning tool'
app_copyright = 'Copyright (c) 2015 Robin Palatnik'
app_website = 'http://idiomind.sourceforge.net/'
app_license = (('This program is free software: you can redistribute it and/or modify\n'+
'it under the terms of the GNU General Public License as published by\n'+
'the Free Software Foundation, either version 3 of the License, or\n'+
'(at your option) any later version.\n'+
'\n'+
'This program is distributed in the hope that it will be useful,\n'+
'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'+
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n'+
'GNU General Public License for more details.\n'+
'\n'+
'You should have received a copy of the GNU General Public License\n'+
'along with this program.  If not, see <http://www.gnu.org/licenses/>.'))
app_authors = ['Robin Palatnik <patapatass@hotmail.com>']
app_artists = [' ']

class AboutDialog:
    def __init__(self):
        about = gtk.AboutDialog()
        about.set_logo(gtk.gdk.pixbuf_new_from_file(app_logo))
        about.set_wmclass('Idiomind', 'Idiomind')
        about.set_name(app_name)
        about.set_program_name(app_name)
        about.set_version(app_version)
        about.set_comments(app_comments)
        about.set_copyright(app_copyright)
        about.set_license(app_license)
        about.set_website(app_website)
        about.set_website_label('Homepage')
        about.set_authors(app_authors)
        about.set_artists(app_artists)
        about.run()
        about.destroy()

if __name__ == "__main__":
    AboutDialog = AboutDialog()
    main()
END
}

function set_image() {

    cd "$DT"
    if [ "$3" = word ]; then
    item=$(eyeD3 "$2" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
    elif [ "$3" = sentence ]; then
    item=$(eyeD3 "$2" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    fi
    search="$(sed "s/'//g" <<<"$item")"
    file="$2"
    fname="$(nmfile "$item")"

    echo -e "<html><head>
    <meta http-equiv=\"Refresh\" content=\"0;url=https://www.google.com/search?q="$search"&tbm=isch\">
    </head><body><p>Search images for \"$search\"...</p></body></html>" > search.html
    btn1="--button="$(gettext "Image")":3"

    if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
    image="--image=$DM_tlt/words/images/$fname.jpg"
    btn1="--button="$(gettext "Change")":3"
    btn2="--button="$(gettext "Delete")":2"
    else label="--text=\t<small><a href='file://$DT/search.html'>"$(gettext "Search image related")"</a></small>"; fi

    if [ "$3" = word ]; then
        
        yad --form --title=$(gettext "Image") "$image" "$label" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" \
        --skip-taskbar --image-on-top \
        --align=center --center --on-top \
        --width=380 --height=280 --borders=5 \
        "$btn1" "$btn2" --button=$(gettext "Close"):1
        ret=$?
            
            if [[ $ret -eq 3 ]]; then
            
            rm -f *.l
            scrot -s --quality 80 "$fname.temp.jpeg"
            /usr/bin/convert "$fname.temp.jpeg" -interlace Plane -thumbnail 100x90^ \
            -gravity center -extent 100x90 -quality 90% "$item"_temp.jpeg
            /usr/bin/convert "$fname.temp.jpeg" -interlace Plane -thumbnail 360x240^ \
            -gravity center -extent 360x240 -quality 90% "$DM_tlt/words/images/$fname.jpg"
            eyeD3 --remove-images "$file"
            eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file"
            wait
            "$DS/ifs/tls.sh" set_image "$file" word & exit
                
            elif [[ $ret -eq 2 ]]; then
            
            eyeD3 --remove-image "$file"
            rm -f "$DM_tlt/words/images/$fname.jpg"
            
            fi
            
    elif [ "$3" = sentence ]; then
    
        yad --form --title=$(gettext "Image") "$image" "$label" \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" \
        --skip-taskbar --image-on-top --center --on-top \
        --width=470 --height=270 --borders=5 \
        "$btn1" "$btn2" --button=$(gettext "Close"):1
        ret=$?
                
            if [[ $ret -eq 3 ]]; then
            
            rm -f *.l
            scrot -s --quality 80 "$fname.temp.jpeg"
            /usr/bin/convert "$fname.temp.jpeg" -interlace Plane -thumbnail 100x90^ \
            -gravity center -extent 100x90 -quality 90% "$item"_temp.jpeg
            /usr/bin/convert "$fname.temp.jpeg" -interlace Plane -thumbnail 490x260^ \
            -gravity center -extent 490x260 -quality 90% "$DM_tlt/words/images/$fname.jpg"
            eyeD3 --remove-images "$file"
            eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file"
            wait
            "$DS/ifs/tls.sh" set_image "$file" sentence & exit
                
            elif [[ $ret -eq 2 ]]; then
            
            eyeD3 --remove-image "$file"
            rm -f "$DM_tlt/words/images/$fname.jpg"
            
            fi  
    fi
    
    rm -f search.html *.jpeg & exit

}  >/dev/null 2>&1

function pdfdoc() {

    cd $HOME
    pdf=$(yad --file --save --title="Export" \
    --name=Idiomind --class=Idiomind \
    --filename="$HOME/$tpc.pdf" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=600 --height=500 --borders=5 \
    --button=gtk-ok:0)
    ret=$?

    if [ "$ret" -eq 0 ]; then
    
        dte=$(date "+%d %B %Y")
        mkdir "$DT/mkhtml"
        mkdir "$DT/mkhtml/images"
        nts="$(sed ':a;N;$!ba;s/\n/<br>/g' < "$DC_tlt/10.cfg" \
        | sed 's/\"/\&quot;/;s/\&/&amp;/g')"

        cd "$DT/mkhtml"
        cp -f "$DC_tlt/3.cfg" "3.cfg"
        cp -f "$DC_tlt/4.cfg" "4.cfg"

        n="$(wc -l < "3.cfg" | awk '{print ($1)}')"
        while [[ $n -ge 1 ]]; do
            wnm=$(sed -n "$n"p "3.cfg")
            fname="$(nmfile "$wnm")"
            if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
            convert "$DM_tlt/words/images/$fname.jpg" -alpha set -virtual-pixel transparent \
            -channel A -blur 0x10 -level 50%,100% +channel "$DT/mkhtml/images/$wnm.png"
            fi
            let n--
        done

        n="$(wc -l < "4.cfg" | awk '{print ($1)}')"
        while [[ $n -ge 1 ]]; do
            wnm=$(sed -n "$n"p "4.cfg")
            fname="$(nmfile "$wnm")"
            tgs=$(eyeD3 "$DM_tlt/$fname.mp3")
            wt=$(grep -o -P "(?<=ISI1I0I).*(?=ISI1I0I)" <<<"$tgs")
            ws=$(grep -o -P "(?<=ISI2I0I).*(?=ISI2I0I)" <<<"$tgs")
            echo "$wt" >> S.gprt.x
            echo "$ws" >> S.gprs.x
            let n--
        done
        echo -e "<head>
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
        <title>$tpc</title><head>
        <link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/pdf.css\">
        </head>
        <body>
        <div><p></p>
        </div>
        <div>
        <p>&nbsp;</p>
        <h3>$tpc</h3>
        <p>&nbsp;</p>
        <hr>
        <table width=\"80%\" align=\"left\" border=\"0\" class=\"ifont\">
        <tr>
        <td>
        <br>" > pdf_doc
        printf "$nts" >> pdf_doc
        echo -e "<p>&nbsp;</p>
        <p>&nbsp;</p>
        </td>
        </tr>
        </table>" >> pdf_doc

        cd "$DM_tlt/words/images"
        cnt=`ls -1 *.jpg 2>/dev/null | wc -l`
        if [ $cnt != 0 ]; then
            cd $DT/mkhtml/images/
            ls *.png | sed 's/\.png//g' > "$DT/mkhtml/nimg"
            cd $DT/mkhtml
            echo -e "<table width=\"90%\" align=\"center\" border=\"0\" class=\"images\">" >> pdf_doc
            n="$(wc -l < nimg)"
            while [ $n -ge 1 ]; do
                    if [ -f nnn ]; then
                    n=$(< nnn)
                    fi
                    nn=$((n+1))
                    nnn=$((n+2))
                    d1m=$(sed -n "$n","$nn"p < nimg | sed -n 1p)
                    d2m=$(sed -n "$n","$nn"p < nimg | sed -n 2p)
                    if [ -n "$d1m" ]; then
                        echo -e "<tr>
                        <td align=\"center\"><img src=\"images/$d1m.png\" width=\"240\" height=\"220\"></td>" >> pdf_doc
                        if [ -n "$d2m" ]; then
                        echo -e "<td align=\"center\"><img src=\"images/$d2m.png\" width=\"240\" height=\"220\"></td></tr>" >> pdf_doc
                        else
                        echo '</tr>' >> pdf_doc
                        fi
                        echo -e "<tr>
                        <td align=\"center\" valign=\"top\"><p>$d1m</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p></td>" >> pdf_doc
                        if [ -n "$d2m" ]; then
                        echo -e "<td align=\"center\" valign=\"top\"><p>$d2m</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p></td>
                        </tr>" >> pdf_doc
                        else
                        echo '</tr>' >> pdf_doc
                        fi
                    else
                        break
                    fi
                    echo $nnn > nnn
                let n--
            done
            echo -e "</table>
            <p>&nbsp;</p>
            <p>&nbsp;</p>" >> pdf_doc
        fi

        cd "$DT/mkhtml"
        n="$(wc -l < "3.cfg")"
        while [ $n -ge 1 ]; do
            wnm=$(sed -n "$n"p "3.cfg")
            fname="$(nmfile "$wnm")"
            tgs=$(eyeD3 "$DM_tlt/words/$fname.mp3")
            wt=$(grep -o -P "(?<=IWI1I0I).*(?=IWI1I0I)" <<<"$tgs")
            ws=$(grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)" <<<"$tgs")
            inf=$(grep -o -P "(?<=IWI3I0I).*(?=IWI3I0I)" <<<"$tgs" | tr '_' '\n')
            hlgt="${wt,,}"
            exm1=$(echo "$inf" | sed -n 1p | sed 's/\\n/ /g')
            dftn=$(echo "$inf" | sed -n 2p | sed 's/\\n/ /g')
            exmp1=$(echo "$exm1" \
            | sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
            echo "$wt" >> W.lizt.x
            echo "$ws" >> W.lizs.x
            if [ -n "$wt" ]; then
                echo -e "<table width=\"55%\" border=\"0\" align=\"left\" cellpadding=\"10\" cellspacing=\"5\">
                <tr>
                <td bgcolor=\"#F8D49F\" class=\"side\"></td>
                <td bgcolor=\"#F7EDDF\"><w1>$wt</w1></td>
                </tr>
                <tr>
                <td bgcolor=\"#EAE5A0\" class=\"side\"></td>
                <td bgcolor=\"#FAF9F4\"><w2>$ws</w2></td>
                </tr>
                </table>" >> pdf_doc
                echo -e "<table width=\"100%\" border=\"0\" align=\"center\" cellpadding=\"10\" class=\"efont\">
                <tr>
                <td width=\"10px\"></td>" >> pdf_doc
                if [ -z "$dftn" ] && [ -z "$exmp1" ]; then
                echo -e "<td width=\"466\" valign=\"top\" class=\"nfont\" >$ntes</td>
                <td width=\"389\"</td>
                </tr>
                </table>" >> pdf_doc
                else
                    echo -e "<td width=\"466\">" >> pdf_doc
                    if [ -n "$dftn" ]; then
                    echo -e "<dl>
                    <dd><dfn>$dftn</dfn></dd>
                    </dl>" >> pdf_doc
                    fi
                    if [ -n "$exmp1" ]; then
                    echo -e "<dl>
                    <dt> </dt>
                    <dd><cite>$exmp1</cite></dd>
                    </dl>" >> pdf_doc
                    fi 
                    echo -e "</td>
                    <td width=\"400\" valign=\"top\" class=\"nfont\">$ntes</td>
                    </tr>
                    </table>" >> pdf_doc
                fi
                echo -e "<p>&nbsp;</p>" >> pdf_doc
            fi
            let n--
        done

        n=1
        while [ $n -le "$(wc -l < "4.cfg")" ]; do
        
                st=$(sed -n "$n"p "S.gprt.x")

            while read -r mrk; do
            
                if grep -Fxo ${mrk^} < "3.cfg"; then
                trgsm=$(sed "s|$mrk|<mark>$mrk<\/mark>|g" <<<"$st")
                st="$trgsm"
                fi
                
            done <<<"$(tr ' ' '\n' <<<"$st")"

            if [ -n "$st" ]; then
                ss=$(sed -n "$n"p "S.gprs.x")
                fn=$(sed -n "$n"p "4.cfg")
                echo -e "<h1>&nbsp;</h1>
                <table width=\"100%\" border=\"0\" align=\"left\" cellpadding=\"10\" cellspacing=\"5\">
                <tr>
                <td bgcolor='#FAF9F4'><h1>$st</h1></td>
                </tr>" > Sgprt.tmp
                echo -e "<tr>
                <td ><h2>$ss</h2></td>
                </tr>
                </table>
                <h1>&nbsp;</h1>" > Sgprs.tmp
                cat Sgprt.tmp >> pdf_doc
                cat Sgprs.tmp >> pdf_doc
            fi
            let n++
        done

        echo -e "<p>&nbsp;</p>
        <p>&nbsp;</p>
        <h3>&nbsp;</h3>
        <p>&nbsp;</p>
        </div>
        </div>
        <span class=\"container\"></span>
        </body>
        </html>" >> pdf_doc
        mv -f pdf_doc pdf_doc.html
        wkhtmltopdf -s A4 -O Portrait pdf_doc.html tmp.pdf
        mv -f tmp.pdf "$pdf"
        rm -fr pdf_doc "$DT/mkhtml" "$DT"/*.x "$DT"/*.l

    else
        exit 0
    fi
}

if [ "$1" = play ]; then

    play "$2"
    wait
    
elif [ "$1" = listen_sntnc ]; then

    play "$DM_tlt/$2.mp3" >/dev/null 2>&1
    exit

elif [ "$1" = dclik ]; then

    play "$DM_tls/${2,,}".mp3 >/dev/null 2>&1
    exit

elif [ "$1" = play_temp ]; then

    nmt=$(sed -n 1p "/tmp/.idmtp1.$USER/dir$2/ls")
    dir="/tmp/.idmtp1.$USER/dir$2/$nmt"
    play "$dir/audio/${3,,}.mp3";
    exit

fi

case "$1" in
    details)
    details "$@" ;;
    check_source_1)
    check_source_1 "$@" ;;
    check_index)
    check_index "$@" ;;
    add_audio)
    add_audio "$@" ;;
    edit_audio)
    edit_audio "$@" ;;
    text)
    text "$@" ;;
    attachs)
    attatchments "$@" ;;
    add_file)
    add_file ;;
    videourl)
    videourl "$@" ;;
    help)
    help ;;
    definition)
    definition "$@" ;;
    check_updates)
    check_updates ;;
    a_check_updates)
    a_check_updates ;;
    check_index)
    check_index "$@" ;;
    set_image)
    set_image "$@" ;;
    pdfdoc)
    pdfdoc ;;
    fback)
    fback ;;
    about)
    about ;;
esac
