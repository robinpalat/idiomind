#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/practice"
easys="$3"
learning="$4"
[[ "$5" -lt 0 ]] && hards=0 || hards="$5"
[ ! -d "${DC_tlt}/practice" ] \
&& mkdir "${DC_tlt}/practice"
cd "${DC_tlt}/practice"
[ ! -f ./.1 ] && echo 1 > .1
[ ! -f ./.2 ] && echo 1 > .2
[ ! -f ./.3 ] && echo 1 > .3
[ ! -f ./.4 ] && echo 1 > .4
[ ! -f ./.5 ] && echo 1 > .5

if [[ -n "$1" ]]; then

    if [ ${1} = 1 ]; then
    info1="* "; info6="<b>$(gettext "Test completed!")</b>"; echo 21 > .1
    elif [ ${1} = 2 ]; then
    info2="* "; info7="<b>$(gettext "Test completed!")</b>"; echo 21 > .2
    elif [ ${1} = 3 ]; then
    info3="* "; info8="<b>$(gettext "Test completed!")</b>"; echo 21 > .3
    elif [ ${1} = 4 ]; then
    info4="* "; info9="<b>$(gettext "Test completed!")</b>"; echo 21 > .4
    elif [ ${1} = 5 ]; then
    info5="* "; info10="<b>$(gettext "Test completed!")</b>"; echo 21 > .5
    elif [ ${1} = 6 ]; then
    learned=$(< ./a.l); info1="* "
    info="<small>$(gettext "Learned")</small> <span color='#6E6E6E'><b><big>$learned </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easys </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$learning </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hards </big></b></span>\n"
    elif [ ${1} = 7 ]; then
    learned=$(< ./b.l); info2="* "
    info="<small>$(gettext "Learned")</small> <span color='#6E6E6E'><b><big>$learned </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easys </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$learning </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hards </big></b></span>\n"
    elif [ ${1} = 8 ]; then
    learned=$(< ./c.l); info3="* "
    info="<small>$(gettext "Learned")</small> <span color='#6E6E6E'><b><big>$learned </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easys </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$learning </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hards </big></b></span>\n"
    elif [ ${1} = 9 ]; then
    learned=$(< ./d.l); info4="* "
    info="<small>$(gettext "Learned")</small> <span color='#6E6E6E'><b><big>$learned </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easys </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$learning </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hards </big></b></span> \n"
    elif [ ${1} = 10 ]; then
    learned=$(< ./e.l); info5="* "
    info="  <small>$(gettext "Learned")</small> <span color='#6E6E6E'><b><big>$learned </big></b></span>   <small>$(gettext "Easy")</small> <span color='#6E6E6E'><b><big>$easys </big></b></span>   <small>$(gettext "Learning")</small> <span color='#6E6E6E'><b><big>$learning </big></b></span>   <small>$(gettext "Difficult")</small> <span color='#6E6E6E'><b><big>$hards </big></b></span>\n"
    fi
fi

VAR="$(yad --list --title="$(gettext "Practice ")- $tpc" \
$img --text="$info$hw" \
--class=Idiomind --name=Idiomind \
--print-column=1 --separator="" \
--window-icon="$DS/images/icon.png" \
--buttons-layout=edge --image-on-top --center --on-top --text-align=center \
--ellipsize=NONE --no-headers --expand-column=2 --hide-column=1 \
--width=500 --height=460 --borders=10 \
--column="Action" --column="Pick":IMG --column="Label" \
1 "$DSP/images/`< ./.1`.png" "    $info1 $info6   $(gettext "Flashcards")" \
2 "$DSP/images/`< ./.2`.png" "    $info2 $info7   $(gettext "Multiple Choice")" \
3 "$DSP/images/`< ./.3`.png" "    $info3 $info8   $(gettext "Recognizing Words")" \
4 "$DSP/images/`< ./.4`.png" "    $info4 $info9   $(gettext "Images")" \
5 "$DSP/images/`< ./.5`.png" "    $info5 $info10   $(gettext "Writing Sentences")" \
--button="$(gettext "Restart")":3 \
--button="$(gettext "Start")":0)"
ret=$?
source "$DS/ifs/mods/cmns.sh"

if [ $ret -eq 0 ]; then

    if [ -z "$VAR" ]; then
    msg " $(gettext "You must choose a practice.")\n" info
    "$DSP/strt.sh" & exit 1
    else
    echo -e "prct.$tpc.prct" >> "$DC_s/log" &
    "$DSP/prct.sh" "$VAR" & exit 1
    fi

elif [ $ret -eq 3 ]; then

    if [ -d "${DC_tlt}/practice" ]; then
    cd "${DC_tlt}/practice"; rm .*; rm *
    touch ./log1 ./log2 ./log3; fi
    "$DS/practice/strt.sh" & exit
else
    cd "${DC_tlt}/practice"
    rm *.tmp; f_lock "$DT/ps_lk"
    rm "${DC_tlt}/5.cfg"
    cfg5="${DC_tlt}/5.cfg"
    cfg6="$(< "${DC_tlt}/6.cfg")"
    img1='/usr/share/idiomind/images/1.png'
    img2='/usr/share/idiomind/images/2.png'
    img3='/usr/share/idiomind/images/3.png'
    img0='/usr/share/idiomind/images/0.png'
    log3="$(cat ./log3 ./e.3)"
    log2="$(cat ./log2 ./e.2)"
    log1="$(cat ./log1 ./e.1)"
    
    while read -r item; do
    if grep -Fxo "${item}" <<<"${cfg6}"; then
    i="<b><big>${item}</big></b>";else i="${item}"; fi
    if grep -Fxo "${item}" <<<"${log3}"; then
        echo -e "FALSE\n${i}\n$img3" >> "$cfg5"
    elif grep -Fxo "${item}" <<<"${log1}"; then
        echo -e "FALSE\n${i}\n$img1" >> "$cfg5"
    elif grep -Fxo "${item}" <<<"${log2}"; then
        echo -e "FALSE\n${i}\n$img2" >> "$cfg5"
    else
        echo -e "FALSE\n${i}\n$img0" >> "$cfg5"
    fi
    done < "${DC_tlt}/1.cfg"
    rm -f "$DT/ps_lk"

    exit
fi
