#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
echo "$tpc"
tlng="$DC_tlt/cnfg1"
winx="$DC_tlt/cnfg3"
sinx="$DC_tlt/cnfg4"
[ -z "$tpc" ] && exit 1
if [ "$(cat "$sinx" | wc -l)" -gt 0 ]; then
indw=$(grep -F -x -v -f "$sinx" "$tlng")
else
indw=$(cat "$tlng")
fi
if [ "$(cat "$winx" | wc -l)" -gt 0 ]; then
inds=$(grep -F -x -v -f "$winx" "$tlng")
else
inds=$(cat "$tlng")
fi
indm=$(cat "$DC_tlt/cnfg6")
cd "$DC_tlt/Practice"
indp=$(cat fin.tmp mcin.tmp \
lwin.tmp | sed '/^$/d' | sort | uniq)
indf=$(cat $DC_tl/Feeds/cnfg0)
u=$(echo "$(whoami)")
infs=$(echo "$snts Sentences" | wc -l)
infw=$(echo "$wrds Words" | wc -l)

if [[ "$1" = d ]]; then
	u=$(echo "$(whoami)")
	pst=$(sed -n 1p $DC_s/cnfg17)
	slt=$(mktemp $DT/slt.XXX.s)
	cd $DT/.$u/
	
	if echo "$2" | grep "Notification"; then
		cnf1=$(mktemp $DT/cnf1.XXXX.s)
		cnf2=$(mktemp $DT/cnf2.XXXX.s)
		bcl=$(sed -n 1p $DC_s/cnfg2)
		KEY=12342
		
		if [[ -z "$bcl" ]]; then
			echo 8 > $DC_s/cnfg2
			echo $pst >> $DC_s/cnfg2
			bcl=$(sed -n 1p $DC_s/cnfg2)
		fi
		pst2=$(sed -n 2p $DC_s/cnfg2)
		
			$yad --fixed --plug=$KEY --tabnum=1 \
			--mark="8 s":8 --mark="60 s":60 --mark="120 s":120 \
			--borders=20 --button=Ok:0 --scale  \
			--min-value=2 --max-value=128 --value="$bcl" --step 2 > $cnf1 &
			$yad --fixed --plug=$KEY --tabnum=2 \
			--mark="200":200 --mark="400":400 --mark="600":600 --mark="800":800 \
			--mark="1000":1000 --mark="1200":1200 --mark="1400":1400  \
			--borders=0 --scale --vertical --geometry=0-0-0-0 \
			--min-value=2 --max-value=1600 --value="$pst2" --step=2 > $cnf2 &
			$yad --notebook --center --key=$KEY --name=idiomind --on-top \
			--fixed --sticky --skip-taskbar --window-icon=idiomind \
			--tab="  Time  " --tab="  Position  " --borders=10 \
		    --title=" " --width=400 --height=280 --buttons-layout=right \
		    --button="	Ok    ":0
		
			if [[ "$?" -eq 0 ]]; then
				a=$(cat "$cnf1")
				b=$(cat "$cnf2")
				if [[ "$b" -gt "$pst" ]]; then
					b="$pst"
				fi
				sed -i "1s/.*/$a/" $DC_s/cnfg2
				sed -i "2s/.*/$b/" $DC_s/cnfg2
				"$?">/dev/null 2>&1
				fi
				rm -f $cnf1 $cnf2 $cnf3
			[ "$?" -eq 1 ] & rm -f $cnf1 $cnf2 $cnf3 & exit 1
				"$?">/dev/null 2>&1
			exit 1
	fi
fi

if [ ! -d $DT/.$u ]; then
	mkdir $DT/.$u
	cd $DT/.$u
		echo "$indw" > ./indw
		echo "$inds" > ./inds
		echo "$indm" > ./indm
		echo "$indp" > ./indp
		echo "$indf" > ./indf
fi

if [ -z "$indw" ]; then
img1=$DS/images/addi.png
else
img1=$DS/images/add.png
fi
if [ -z "$inds" ]; then
img2=$DS/images/addi.png
else
img2=$DS/images/add.png
fi
if [ -z "$indm" ]; then
img3=$DS/images/addi.png
else
img3=$DS/images/add.png
fi
if [ -z "$indp" ]; then
img4=$DS/images/addi.png
else
img4=$DS/images/add.png
fi
if [ -z "$indf" ]; then
img5=$DS/images/addi.png
else
img5=$DS/images/add.png
fi
img6=$DS/images/set-26.png

if [ ! -f $DC_s/cnfg5 ]; then
	cp $DS/default/cnfg5 $DC_s/cnfg5
fi

st1=$(cat $DC_s/cnfg5 | sed -n 1p)
st2=$(cat $DC_s/cnfg5 | sed -n 2p)
st3=$(cat $DC_s/cnfg5 | sed -n 3p)
st4=$(cat $DC_s/cnfg5 | sed -n 4p)
st5=$(cat $DC_s/cnfg5 | sed -n 5p)
st6=$(cat $DC_s/cnfg5 | sed -n 6p)
st7=$(cat $DC_s/cnfg5 | sed -n 7p)
st8=$(cat $DC_s/cnfg5 | sed -n 8p)
st9=$(cat $DC_s/cnfg5 | sed -n 9p)
st10=$(cat $DC_s/cnfg5 | sed -n 10p)
slct=$(mktemp $DT/slct.XXXX)

btn1="--button=Ok:0"
btn2="--center"
if [ -f $DT/.p__$u ]; then
	btn1="--button=Ok:0"
	btn2="--button=gtk-media-stop:2"
fi

int="$(sed -n 17p $DS/ifs/trads/$lgs | sed 's/|/\n/g')"
$yad --list --on-top \
--expand-column=3 --print-all --center \
--width=190 --name=idiomind --class=idmnd \
--height=260 --title=" " --always-print-result \
--window-icon=idiomind --no-headers \
--buttons-layout=end --skip-taskbar \
--borders=0 $btn2 $btn1 --hide-column=1 \
--column=Action:TEXT --column=icon:IMG \
--column=Action:TEXT --column=icon:CHK \
"Words" "$img1" "$(echo "$int" | sed -n 1p)" $st1 \
"Sentences" "$img2" "$(echo "$int" | sed -n 2p)" $st2 \
"Marks" "$img3" "$(echo "$int" | sed -n 3p)" $st3 \
"Practice" "$img4" "$(echo "$int" | sed -n 4p)" $st4 \
"Feeds" "$img5" "$(echo "$int" | sed -n 5p)" $st5 \
"Notification" "$img6" "$(echo "$int" | sed -n 6p)" $st6 \
"Audio" "$img6" "$(echo "$int" | sed -n 7p)" $st7 \
"Repeat" "$img6" "$(echo "$int" | sed -n 8p)" $st8 > "$slct"
ret=$?
slt=$(cat "$slct")

if  [[ "$ret" -eq 0 ]]; then
	cd $DT/.$u
	> ./indx
	if echo "$(echo "$slt" | sed -n 1p)" | grep TRUE; then
		sed -i "1s/.*/TRUE/" $DC_s/cnfg5
		cat ./indw >> ./indx
	else
		sed -i "1s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 2p)" | grep TRUE; then
		sed -i "2s/.*/TRUE/" $DC_s/cnfg5
		cat ./inds >> ./indx
	else
		sed -i "2s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 3p)" | grep TRUE; then
		sed -i "3s/.*/TRUE/" $DC_s/cnfg5
		cat ./indm >> ./indx
	else
		sed -i "3s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 4p)" | grep TRUE; then
		sed -i "4s/.*/TRUE/" $DC_s/cnfg5
		cat ./indp >> ./indx
	else
		sed -i "4s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 5p)" | grep TRUE; then
		sed -i "5s/.*/TRUE/" $DC_s/cnfg5
		cat ./indf >> ./indx
	else
		sed -i "5s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 6p)" | grep TRUE; then
		sed -i "6s/.*/TRUE/" $DC_s/cnfg5
	else
		sed -i "6s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 7p)" | grep TRUE; then
		sed -i "7s/.*/TRUE/" $DC_s/cnfg5
	else
		sed -i "7s/.*/FALSE/" $DC_s/cnfg5
	fi
	if echo "$(echo "$slt" | sed -n 8p)" | grep TRUE; then
		sed -i "8s/.*/TRUE/" $DC_s/cnfg5
	else
		sed -i "8s/.*/FALSE/" $DC_s/cnfg5
	fi
	rm -f "$slct"

#-------------------------------------stop 
elif [[ "$ret" -eq 2 ]]; then
	rm -f "$slct"
	[[ -d $DT/.$u ]] && rm -fr $DT/.$u
	[[ -f $DT/.p__$u ]] && rm -f $DT/.p__$u
	$DS/stop.sh P & exit 1
else
	if  [ ! -f $DT/.p__$u ]; then
		rm -fr $DT/.$u
	fi
	rm -f "$slct"
	exit 1
fi

rm -f $slct
$DS/stop.sh P

w=$(sed -n 1p $DC_s/cnfg5)
s=$(sed -n 2p $DC_s/cnfg5)
m=$(sed -n 2p $DC_s/cnfg5)
p=$(sed -n 3p $DC_s/cnfg5)
f=$(sed -n 4p $DC_s/cnfg5)

if [ -z "$(echo "$w""$s""$m""$f""$p" | grep -o "TRUE")" ]; then
	int="$(sed -n 15p $DS/ifs/trads/$lgs | sed 's/|/\n/g')"
	T="$(echo "$int" | sed -n 1p)"
	D="$(echo "$int" | sed -n 2p)"
	notify-send "$T" "$D" -i idiomind -t 2000 &&
	sleep 5
	$DS/stop.sh
fi

if [[ "$(cat ./indx | wc -l)" -lt 1 ]]; then
	int="$(sed -n 16p $DS/ifs/trads/$lgs | sed 's/|/\n/g')"
	T="$(echo "$int" | sed -n 1p)"
	D="$(echo "$int" | sed -n 2p)"
	notify-send -i idiomind "$T" "$D" -t 9000 &
	rm -f $DT/.p__$u &
	$DS/stop.sh S & exit
fi

echo "$(date '+%Y %m %d %l %M') -plyrt $tpc -plyrt" >> \
$DC/addons/stats/.log &

$DS/bcle.sh & exit 1
