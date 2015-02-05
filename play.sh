#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

if [[ "$1" = time ]]; then
	u=$(echo "$(whoami)")
	cd $DT/.$u/
	cnf1=$(mktemp $DT/cnf1.XXXX.s)
	bcl=$(cat $DC_s/cfg.2)

	if [[ -z "$bcl" ]]; then
		echo 8 > $DC_s/cfg.2
		bcl=$(sed -n 1p $DC_s/cfg.2)
	fi
		yad --mark="8 s":8 --mark="60 s":60 --fixed \
		--mark="120 s":120 --borders=20 --scale \
		--max-value=128 --value="$bcl" --step 2 \
		--name=idiomind --on-top --skip-taskbar \
		--window-icon=idiomind --borders=10 \
	    --title=" " --width=300 --height=140 \
	    --min-value=2 --button="Ok":0 > $cnf1
	
		if [[ "$?" -eq 0 ]]; then
			cat "$cnf1" > $DC_s/cfg.2
		fi
			rm -f $cnf1
		[[ "$?" -eq 1 ]] & rm -f $cnf1 & exit 1
		exit 1

elif [[ -z "$1" ]]; then

	echo "$tpc"
	tlng="$DC_tlt/cfg.1"
	winx="$DC_tlt/cfg.3"
	sinx="$DC_tlt/cfg.4"
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
	indm=$(cat "$DC_tlt/cfg.6")
	cd "$DC_tlt/practice"
	indp=$(cat fin3 mcin3 \
	lwin3 | sed '/^$/d' | sort | uniq)
	indf=$(cat $DC_tl/Feeds/cfg.0)
	nnews=$(cat $DC_tl/Feeds/cfg.1 | head -n 8)
	u=$(echo "$(whoami)")
	infs=$(echo "$snts Sentences" | wc -l)
	infw=$(echo "$wrds Words" | wc -l)

	if [ ! -d $DT/.$u ]; then
		mkdir $DT/.$u
		cd $DT/.$u
		echo "$indw" > ./indw
		echo "$inds" > ./inds
		echo "$indm" > ./indm
		echo "$indp" > ./indp
		echo "$indf" > ./indf
		echo "$nnews" >> ./indf
	fi
	[[ -z "$indw" ]] && img1=$DS/images/addi.png || img1=$DS/images/add.png
	[[ -z "$inds" ]] && img2=$DS/images/addi.png || img2=$DS/images/add.png
	[[ -z "$indm" ]] && img3=$DS/images/addi.png || img3=$DS/images/add.png
	[[ -z "$indp" ]] && img4=$DS/images/addi.png || img4=$DS/images/add.png
	[[ -z "$indf" ]] && img5=$DS/images/addi.png || img5=$DS/images/add.png
	img6=$DS/images/set-26.png

	if [[ ! -f $DC_s/cfg.5 ]]; then
	echo 'FALSE
FALSE
FALSE
FALSE
FALSE
TRUE
TRUE
FALSE' > $DC_s/cfg.5; fi
	st1=$(cat $DC_s/cfg.5 | sed -n 1p)
	st2=$(cat $DC_s/cfg.5 | sed -n 2p)
	st3=$(cat $DC_s/cfg.5 | sed -n 3p)
	st4=$(cat $DC_s/cfg.5 | sed -n 4p)
	st5=$(cat $DC_s/cfg.5 | sed -n 5p)
	st6=$(cat $DC_s/cfg.5 | sed -n 6p)
	st7=$(cat $DC_s/cfg.5 | sed -n 7p)
	st8=$(cat $DC_s/cfg.5 | sed -n 8p)
	st9=$(cat $DC_s/cfg.5 | sed -n 9p)
	st10=$(cat $DC_s/cfg.5 | sed -n 10p)
	slct=$(mktemp $DT/slct.XXXX)
	if [ ! -f $DT/.p__$u ]; then
		btn="--button=Ok:0"
	else
		btn="--button=gtk-media-stop:2"
	fi
	$yad --list --on-top \
	--expand-column=3 --print-all --center \
	--width=280 --name=idiomind --class=idmnd \
	--height=240 --title="$tpc" --skip-taskbar \
	--window-icon=idiomind --no-headers \
	--button=Time:"$DS/play.sh 'time'" \
	--borders=0 $btn --hide-column=1 \
	--column=Action:TEXT --column=icon:IMG \
	--column=Action:TEXT --column=icon:CHK \
	"Words" "$img1" "$words" $st1 \
	"Sentences" "$img2" "$sentences" $st2 \
	"Marks" "$img3" "$marks" $st3 \
	"practice" "$img4" "$practice" $st4 \
	"Feeds" "$img5" "$news" $st5 \
	"Notification" "$img6" "$osd" $st6 \
	"Audio" "$img6" "$audio" $st7 \
	"Repeat" "$img6" "$repeat" $st8 > "$slct"
	ret=$?
	slt=$(cat "$slct")

	if  [[ "$ret" -eq 0 ]]; then
		cd $DT/.$u
		> ./indx
		if echo "$(echo "$slt" | sed -n 1p)" | grep TRUE; then
			sed -i "1s/.*/TRUE/" $DC_s/cfg.5
			cat ./indw >> ./indx
		else
			sed -i "1s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 2p)" | grep TRUE; then
			sed -i "2s/.*/TRUE/" $DC_s/cfg.5
			cat ./inds >> ./indx
		else
			sed -i "2s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 3p)" | grep TRUE; then
			sed -i "3s/.*/TRUE/" $DC_s/cfg.5
			cat ./indm >> ./indx
		else
			sed -i "3s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 4p)" | grep TRUE; then
			sed -i "4s/.*/TRUE/" $DC_s/cfg.5
			cat ./indp >> ./indx
		else
			sed -i "4s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 5p)" | grep TRUE; then
			sed -i "5s/.*/TRUE/" $DC_s/cfg.5
			cat ./indf >> ./indx
		else
			sed -i "5s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 6p)" | grep TRUE; then
			sed -i "6s/.*/TRUE/" $DC_s/cfg.5
		else
			sed -i "6s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 7p)" | grep TRUE; then
			sed -i "7s/.*/TRUE/" $DC_s/cfg.5
		else
			sed -i "7s/.*/FALSE/" $DC_s/cfg.5
		fi
		if echo "$(echo "$slt" | sed -n 8p)" | grep TRUE; then
			sed -i "8s/.*/TRUE/" $DC_s/cfg.5
		else
			sed -i "8s/.*/FALSE/" $DC_s/cfg.5
		fi
		rm -f "$slct"

	#-------------------------------------stop 
	elif [[ "$ret" -eq 2 ]]; then
		rm -f "$slct"
		[[ -d $DT/.$u ]] && rm -fr $DT/.$u
		[[ -f $DT/.p__$u ]] && rm -f $DT/.p__$u
		$DS/stop.sh P & exit
	else
		if  [ ! -f $DT/.p__$u ]; then
			[[ -d $DT/.$u ]] && rm -fr $DT/.$u
		fi
		rm -f "$slct"
		exit 1
	fi

	rm -f $slct
	$DS/stop.sh play

	w=$(sed -n 1p $DC_s/cfg.5)
	s=$(sed -n 2p $DC_s/cfg.5)
	m=$(sed -n 3p $DC_s/cfg.5)
	p=$(sed -n 4p $DC_s/cfg.5)
	f=$(sed -n 5p $DC_s/cfg.5)

	if ! [ "$(echo "$w""$s""$m""$f""$p" | grep -o "TRUE")" ]; then
		notify-send "$exiting" "$no_items" -i idiomind -t 3000 &&
		sleep 5
		$DS/stop.sh play
	fi

	if [[ -z "$(cat ./indx)" ]]; then
		notify-send -i idiomind "$exiting" "$no_items2" -t 3000 &
		rm -f $DT/.p__$u &
		$DS/stop.sh play & exit 1
	fi

	echo "$(date '+%Y %m %d %l %M') -plyrt $tpc -plyrt" >> \
	$DC/addons/stats/.log &
	sleep 1
	$DS/bcle.sh & exit
fi
