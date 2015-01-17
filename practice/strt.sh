#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/practice.conf
DSP="$DS/practice"
wth=$(sed -n 13p $DC_s/cnfg18)
hgt=$(sed -n 14p $DC_s/cnfg18)
easys=$2
learning=$3
[[ $4 -lt 0 ]] && hards=0 || hards=$4
$DS/stop.sh &
[[ ! -d "$DC_tlt/practice" ]] \
&& mv "$DC_tlt/Practice" "$DC_tlt/practice"
cd "$DC_tlt/practice"

if [[ -n "$1" ]]; then

	if [ $1 = 1 ]; then
		info1="* "
		echo 21 > .iconf
	elif [ $1 = 2 ]; then
		info2="* "
		echo 21 > .iconmc
	elif [ $1 = 3 ]; then
		info3="* "
		echo 21 > .iconlw
	elif [ $1 = 4 ]; then
		info4="* "
		echo 21 > .iconls
	elif [ $1 = 5 ]; then
		learned=$(cat l_f)
		num=$(cat .iconf)
		info1="* "
		info="  <b><big>$learned </big></b><small>$s_learned</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$s_easy</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$s_learning</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$s_hard</small>  \\n"
	elif [ $1 = 6 ]; then
		learned=$(cat l_m)
		num=$(cat .iconmc)
		info2="* "
		info="  <b><big>$learned </big></b><small>$s_learned</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$s_easy</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$s_learning</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$s_hard</small>  \\n"
	elif [ $1 = 7 ]; then
		learned=$(cat l_w)
		num=$(cat .iconlw)
		info3="* "
		info="  <b><big>$learned </big></b><small>$s_learned</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$s_easy</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$s_learning</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$s_hard</small>  \\n"
	elif [ $1 = 8 ]; then
		learned=$(cat l_s)
		num=$(cat .iconls)
		info4="* "
		info="  <b><big>$learned </big></b><small>$s_learned</small>   <span color='#3AB451'><b><big>$easys </big></b></span><small>$s_easy</small>   <span color='#E78C1E'><b><big>$learning </big></b></span><small>$s_learning</small>   <span color='#D11B5D'><b><big>$hards </big></b></span><small>$s_hard</small>  \\n"
	fi
fi

iconf=$(cat .iconf)
iconmc=$(cat .iconmc)
iconlw=$(cat .iconlw)
iconls=$(cat .iconls)
img1=$DSP/icons_st/$iconf.png
img2=$DSP/icons_st/$iconmc.png
img3=$DSP/icons_st/$iconlw.png
img4=$DSP/icons_st/$iconls.png

#VAR=$(yad --ellipsize=NONE --list --text-align=center \
#--on-top --class=idiomind --name=idiomind \
#--center --window-icon=idiomind --skip-taskbar \
#--image-on-top --buttons-layout=edge $img \
#--borders=5 --expand-column=1 --print-column=1 \
#--width=$wth --height=$hgt --text="$info" \
#--no-headers --button=$restart:3 --button=$start:0 \
#--title="practice - $tpc" \
#--column="Action" --column="Pick":IMG \
#"  $info1 Flashcards" $img1 \
#"  $info2 Multiple Choisse" $img2 \
#"  $info3 Listening Words" $img3 \
#"  $info4 Listening Sentences" $img4 )
#ret=$?

VAR=$(yad --ellipsize=NONE --list \
--on-top --class=idiomind --name=idiomind \
--center --window-icon=idiomind --skip-taskbar \
--image-on-top --buttons-layout=edge $img \
--borders=5 --expand-column=1 --print-column=2 \
--width=$wth --height=$hgt --text="$info" \
--no-headers --button=$restart:3 --button=$start:0 \
--title="$practice - $tpc" --text-align=center \
--column="Pick":IMG --column="Action" \
$img1 "     $info1 Flashcards" \
$img2 "     $info2 Multiple Choice" \
$img3 "     $info3 Listening Words" \
$img4 "     $info4 Listening Sentences" )
ret=$?

if [ $ret -eq 0 ]; then
	echo "prct.shc.$tpc.prct.shc" >> \
	$DC/addons/stats/.log &
	if echo "$VAR" | grep "Flashcards"; then
		$DSP/prct.sh f & exit 1
	elif echo "$VAR" | grep "Multiple Choice"; then
		$DSP/prct.sh m & exit 1
	elif echo "$VAR" | grep "Listening Words"; then
		$DSP/prct.sh w & exit 1
	elif echo "$VAR" | grep "Listening Sentences"; then
		$DSP/prct.sh s & exit 1
	else
		yad --form --center --borders=5 \
		--title="Info" --on-top --window-icon=idiomind \
		--button=Ok:1 --skip-taskbar \
		--text="<span color='#797979'><b>  $no_choice</b></span>" \
		--width=360 --height=120
		$DSP/strt.sh & exit 1
	fi
elif [ $ret -eq 3 ]; then
	(
	echo "#" ;
	cd "$DC_tlt/practice"
	rm *
	cp -f $DS/practice/default/.* "$DC_tlt/practice"
	) | yad --progress \
	--width 50 --height 35 --center \
	--pulsate --auto-close --no-buttons \
	--sticky --undecorated --skip-taskbar
	$DS/practice/strt.sh & exit 1
else
	[[ -f fin1 ]] && rm fin1; [[ -f fin2 ]] && rm fin2;
	[[ -f mcin1 ]] && rm mcin1; [[ -f mcin2 ]] && rm mcin2;
	[[ -f lwin1 ]] && rm lwin1; [[ -f lwin2 ]] && rm lwin2;
	[[ -f lsin ]] && rm lsin; rm *.no *.ok
	kill -9 $(pgrep -f "yad --form ")
	exit 1
fi
