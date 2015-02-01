#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

if [ $1 = play ]; then

play "$2" && sleep 0.5 & exit

elif [ $1 = info ]; then

	wth=$(sed -n 5p $DC_s/cfg.18)
	eht=$(sed -n 6p $DC_s/cfg.18)
	var2="$2"
	page=/tmp/$var2
	wget -O $page http://$lgt.wikipedia.org/wiki/$var2
	
	if [ -s "$page" ]; then
		echo $(grep -B 10 'div id="toc"' $page | sed '/<p.*p>/! {d};s/<[^>]*>//g') \
		| yad --text-info --on-top --skip-taskbar --title=" " \
		--center --window-icon=idiomin --width="$wth" --height="$eht" --wrap
	else
		echo -e "No Wikipedia page for\n$var2" | yad --title=" " --text-info --on-top \
		--skip-taskbar --center --window-icon=idiomin --geometry=450x150
	fi
	rm $page
	exit

elif [ $1 = cnfg ]; then

	msj=$(sed -n 1p $DC_s/cfg.20)
	cn=$(sed -n 2p $DC_s/cfg.20)
	[[ -z "$cn" ]] && msj=" ( $no_defined )" || img="$cn"

	yad --center --align=center --text="  $recording: $msj" \
	---name=idiomind --width=420 --height=150 \
	--on-top --skip-taskbar --center --window-icon=idiomind \
	--button="$change":2 --button=gtk-apply:3 --borders=10 --title=" "
	ret=$?

	if [[ $ret -eq 2 ]]; then
		/usr/share/idiomind/ifs/tls.sh chng
		/usr/share/idiomind/ifs/tls.sh cnfg
		exit
	fi


elif [ $1 = add_audio ]; then

cd $HOME
inp=/usr/share/idiomind/ifs/tls.sh cnfg
DT="$2"
ls="play $DT/audtm.mp3"
rec="--button=gtk-media-record:/usr/share/idiomind/ifs/tls.sh rec '$c' '$t'"
FLAS=$(yad --width=620 --height=400 --file --on-top --name=idiomind \
	--class=idiomind --window-icon=idiomind --center --file-filter="*.mp3" \
	--button=Ok:0 --borders=0 --title="$ttl" --skip-taskbar)
ret=$?
audio=$(echo "$FLAS" | cut -d "|" -f1)
cd $DT
if [[ $ret -eq 0 ]]; then
if  [[ -f "$audio" ]]; then
cp -f "$audio" $DT/audtm.mp3 >/dev/null 2>&1
eyeD3 -P itunes-podcast --remove $DT/audtm.mp3
eyeD3 --remove-all $DT/audtm.mp3 & exit
fi
fi

elif [ $1 = s ]; then

	if [[ "$(ps -A | grep -o "play")" = "play" ]]; then
		killall play
	fi
	
	play "$DM_tlt/$2.mp3" & sleep 0.2 && exit
	
elif [ $1 = dclik ]; then

	wdr=$(echo "$2" | awk '{print tolower($0)}')
	play "$DM_tl/.share/$wdr".mp3 & exit
	
elif [ $1 = edta ]; then

	prm=$(sed -n 11p $DC_s/cfg.1)
	(cd "$3"
	"$prm" "$2") & exit
	
elif [ $1 = chng ]; then

	cd $DS/ifs/audio/
	IFS=''
	grep_index="egrep '^[*\ ]*index:\ +[[:digit:]]+$' | egrep -o '[[:digit:]]+'"
	pacmd_set_default_command="pacmd set-default-source"
	pacmd_index_1="$(pacmd list-source-outputs | eval $grep_index)"
	pacmd_index_2="$(pacmd list-sources | eval $grep_index)"
	pacmd_move_command="pacmd move-source-output"
	pacmd_list_data=$(pacmd list-sources)
	message_base=" "
	IFS=$' \n'
	get_pacmd_section () {
		l1_section=$1
		l2_section=$2
		l3_section=$3
		is_l1_section=false
		is_l2_section=false; [[ -z $l2_section ]] && is_l2_section=true
		is_l3_section=false; [[ -z $l3_section ]] && is_l3_section=true
		echo "$pacmd_list_data" | while read line; do
			if [[ "$line" =~ ^[*\ ]*index:\ +([[:digit:]]+) ]]; then

				if [[ ${BASH_REMATCH[1]} == $l1_section ]]; then
					is_l1_section=true
				else
					is_l1_section=false
				fi
			fi
			if [[ -n $l2_section ]] && [[ "$line" =~ ^$'\t'{1}([[:alpha:] -]+): ]]; then

				if  [[ ${BASH_REMATCH[1]} == $l2_section ]]; then
					is_l2_section=true
				else
					is_l2_section=false
				fi
			fi
			if [[ -n $l3_section ]] && [[ "$line" =~ ^$'\t'{2}([[:alpha:] -]+): ]]; then

				if  [[ ${BASH_REMATCH[1]} == $l3_section ]]; then
					is_l3_section=true
				else
					is_l3_section=false
				fi
			fi
			if $is_l1_section && $is_l2_section && $is_l3_section; then
				echo $line
			fi
	done
	}

	if [[ "$0" =~ -([[:digit:]]+)\.sh$ ]]; then
		id=${BASH_REMATCH[1]}
	else

		default=$(echo "$pacmd_list_data" | egrep '^ *\* *index:')
		[[ "$default" =~ ^\ *\*\ *index:\ +([[:digit:]]+) ]] || exit 1
		default_id="${BASH_REMATCH[1]}"

		list=($pacmd_index_2)

		for ((x=0, max=${#list[@]}; x<$max; x++)); do
			while read line; do
				if [[ "$line" =~ ^$'\t'{2}device.class\ =\ \"(.*)\"$ ]]; then
					device_class=${BASH_REMATCH[1]}
			if [[ $device_class != "sound" ]]; then
						unset list[$x]
			fi
				fi
			done <<< "$(get_pacmd_section ${list[$x]} properties)"
		done

		if [[ -z ${list[@]} ]]; then
			echo "There are no any devices"
			exit 0
		fi

		list=($(echo ${list[@]}))

		list=(${list[@]} ${list[0]})
		for ((x=0, id=${list[0]}, max=${#list[@]}-1; x<$max; x++)); do
			if [[ ${list[$x]} == $default_id ]]; then
				id=${list[$x+1]}
				break
			fi
		done
	fi

	$pacmd_set_default_command $id > /dev/null
	for index in $pacmd_index_1; do
		$pacmd_move_command $index $id > /dev/null;
	done

	while read line; do
		if [[ "$line" =~ ^$'\t'{2}alsa.card_name\ =\ \"(.*)\"$ ]]; then
			alsa_card_name=${BASH_REMATCH[1]}
			message="$message_base $id - $alsa_card_name"
		fi
		if [[ "$line" =~ ^$'\t'{2}device.icon_name\ =\ \"(.*)\"$ ]]; then
			device_icon_name=${BASH_REMATCH[1]}
		fi
	done <<< "$(get_pacmd_section $id properties)"

	echo "$message" > $DC_s/cfg.20
	echo "$device_icon_name" >> $DC_s/cfg.20
	exit 1

elif [ $1 = rec ]; then

	paud=$(sed -n 17p $DC_s/cfg.1)
	DT_r="$2"
	t="$3"
	killall play
	inf=$(sed -n 1p $DC_s/cfg.20)
	rm -f $DT_r/audtm.mp3
	$yad --align=center --timeout="$t" \
	--text=" $inf  $recording2...\n\n" \
	--timeout-indicator=bottom --geometry=0-0-0-0 \
	--image-on-top --width=420 --height=150 \
	--on-top --skip-taskbar --no-buttons --center \
	--window-icon=idiomind --center --borders=10 \
	--title=" " \
	--field="\\n\\n$NAME":lbl &
	sox -t alsa default $DT_r/audtm.mp3 \
	silence 1 0.1 5% 1 1.0 5% &
	sleep 10
	killall -9 sox
	killall sox & killall rec
	exit 1

elif [ $1 = remove_items ]; then

	[[ -f $DT/rm ]] && sed -i 's/^$/d' $DT/rm
	n=1
	while [[ $n -le $(cat  $DT/rm | wc -l) ]]; do
		rm=$(sed -n "$n"p $DT/rm)
		$DS/mngr.sh dli "$rm" C
		let n++
	done
	notify-send -i info "Info" "a few bad items are removed" -t 3000
	rm $DT/rm

elif [ $1 = add ]; then
	NM=$(cat $DT/.titl)
	cd ~/
	file=$(yad --center --borders=10 --file-filter="*.mp3" \
	--window-icon=idiomind --skip-taskbar --title="add_audio" \
	--on-top --title=" " --file --width=600 --height=500 )
		if [ -z "$file" ];then
			exit 1
		else
			cp -f "$file" $DT_r/audtm.mp3
		fi
		
elif [ $1 = help ]; then

	xdg-open $DS/ifs/trans/$lgs/help.pdf & exit

elif [ $1 = web ]; then

	host=http://idiomind.sourceforge.net
	lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
	xdg-open $host/$lgs/$lgtl
	exit

elif [ $1 = updt ]; then

	cd $DT
	curl -v www.google.com 2>&1 | \
	grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
	$yad --window-icon=idiomind --on-top \
	--image="info" --name=idiomind \
	--text="<b>$conn_err  \\n  </b>" \
	--image-on-top --center --sticky \
	--width=420 --height=150 --borders=5 \
	--skip-taskbar --title=Idiomind \
	--button="  Ok  ":0
	 >&2; exit 1;}
	[[ -f release ]] && rm -f release
	wget http://idiomind.sourceforge.net/info/release
	
	if [ $(sed -n 1p ./release) ! = $(idiomind -v) ]; then
		yad --text="<big><b> $new_version </b></big>\n\n" \
		--image=info --title="Idiomind 2.1" --window-icon=idiomind \
		--on-top --skip-taskbar --sticky \
		--center --name=idiomind --borders=10 \
		--button="$cancel":1 \
		--button="$later":2 \
		--button="$download":0 \
		--width=420 --height=180
		ret=$?
		if [ "$ret" -eq 0 ]; then
			xdg-open https://sourceforge.net/projects/idiomind/files/idiomind.deb/download & exit
		elif [ "$ret" -eq 2 ]; then
			echo `date +%d` > $DC_s/cfg.13 & exit
		elif [ "$ret" -eq 1 ]; then
			echo `date +%d` > $DC_s/cfg.14
			echo "$(sed -n 2p ./release)" >> $DC_s/cfg.14 & exit
		fi
	else
		yad --text="<big><b> $nonew_version  </b></big>\n\n  $nonew_version2" \
		--image=info --title="Idiomind 2.1" --window-icon=idiomind \
		--on-top --skip-taskbar --sticky --width=420 --height=180 \
		--center --name=idiomind --borders=10 \
		--button="$close":1
	fi
	[[ -f release ]] && rm -f release

elif [ $1 = srch ]; then

	[[ ! -f $DC_s/cfg.13 ]] && echo `date +%d` > $DC_s/cfg.13

	d1=$(cat $DC_s/cfg.13)
	d2=`date +%d`

	[[ $(cat $DC_s/cfg.13) = 28 ]] && rm -f $DC_s/cfg.14

	[[ -f $DC_s/cfg.14 ]] && exit 1

	if [[ $(cat $DC_s/cfg.13) -ne $(date +%d) ]]; then
	
		sleep 1
		echo "$d2" > $DC_s/cfg.13
		cd $DT
		[[ -f release ]] && rm -f release
		curl -v www.google.com 2>&1 | \
		grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
		wget http://idiomind.sourceforge.net/info/release
		pkg=https://sourceforge.net/projects/idiomind/files/idiomind.deb/download
		
		if [ $(sed -n 1p ./release) ! = $(idiomind -v) ]; then
			yad --text="<big><b> $new_version  </b></big>\n\n" \
			--image=info --title="Idiomind 2.1" --window-icon=idiomind \
			--on-top --skip-taskbar --sticky \
			--center --name=idiomind --borders=10 \
			--button="$cancel":1 \
			--button="$later":2 \
			--button="$download":0 \
			--width=420 --height=150
			ret=$?
			if [ "$ret" -eq 0 ]; then
				xdg-open $pkg & exit
			elif [ "$ret" -eq 2 ]; then
				echo `date +%d` > $DC_s/cfg.13 & exit
			elif [ "$ret" -eq 1 ]; then
				echo `date +%d` > $DC_s/cfg.14 & exit
			fi
		else
			exit 0
		fi
		[[ -f release ]] && rm -f release
	fi
	
	
elif [ $1 = pdf ]; then
	cd $HOME &&

	pdf=$($yad --save --center --borders=10 \
	--on-top --filename="$HOME/$tpc.pdf" \
	--window-icon=idiomind --skip-taskbar --title="Export " \
	--file --width=600 --height=500 --button=gtk-ok:0 )
	ret=$?

	if [[ "$ret" -eq 0 ]]; then
		dte=$(date "+%d %B %Y")
		mkdir $DT/mkhtml
		mkdir $DT/mkhtml/images
		nts=$(cat "$DC_tlt/cfg.10" | sed 's/\./\.<br>/g')
		cd $DT/mkhtml
		cp -f "$DC_tlt/cfg.3" w.inx.l
		cp -f "$DC_tlt/cfg.4" s.inx.l
		iw=w.inx.l
		is=s.inx.l

		#images
		n=1
		while [[ $n -le "$(cat $iw | wc -l | awk '{print ($1)}')" ]]; do
			wnm=$(sed -n "$n"p $iw)
			if [ -f "$DM_tlt/words/images/$wnm.jpg" ]; then
				convert "$DM_tlt/words/images/$wnm.jpg" -alpha set -virtual-pixel transparent \
				-channel A -blur 0x10 -level 50%,100% +channel "$DT/mkhtml/images/$wnm.png"
			fi
			let n++
		done
		#sentences
		n=1
		while [[ $n -le "$(cat  $is | wc -l | awk '{print ($1)}')" ]]; do
			wnm=$(sed -n "$n"p $is)
			tgs=$(eyeD3 "$DM_tlt/$wnm.mp3")
			wt=$(echo "$tgs" | grep -o -P "(?<=ISI1I0I).*(?=ISI1I0I)")
			ws=$(echo "$tgs" | grep -o -P "(?<=ISI2I0I).*(?=ISI2I0I)")
			echo "$wt" >> S.gprt.x
			echo "$ws" >> S.gprs.x
			let n++
		done
		echo '<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>'$tpc'</title>
		<head>
		<style type="text/css">
		w1 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #5E5A54;
			font-size: 20px;
			font-weight: bold;
			font-family: Verdana, Geneva, sans-serif;
		}
		w2 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #61615B;
			font-size: 18px;
			font-style: normal;
			font-family: Verdana, Geneva, sans-serif;
		}
		h1 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #595754;
			font-size: 20px;
			font-weight: normal;
			font-family: Verdana, Geneva, sans-serif;
		}
		h2 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #61615B;
			font-size: 15px;
			font-weight: normal;
			font-style: normal;
			font-family: Verdana, Geneva, sans-serif;
		}
		
		h3 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #474747;
			font-size: 19px;
			font-weight: bold;
			font-family: Verdana, Geneva, sans-serif;
		}
		}
		mark {
			background-color: #B5DA8F
		}
		.examples {
			width: 80%;
			padding-left: 25px;
			padding-bottom: 10px;
			padding-top: 5px;
			padding-right: 0;
		}
		.ifont {
			color: #3E3E3E;
			font-family: Verdana, Geneva, sans-serif;
			font-size: 12px;
			text-align: left;
		}
		.efont {
			color: #6F6F6F;
			font-family: Verdana, Geneva, sans-serif;
			font-size: 14px;
			text-align: left;
		}
		.nfont {
			color: #6F6F6F;
			font-family: Verdana, Geneva, sans-serif;
			font-size: 10px;
			text-align: left;
		}
		.notasa {
			float: right;
			width: 50%;
			padding-right: 60px;
			font-size: 12px;
			color: #7B7B7B;
		}
		ma {
			margin-top: 0;
			color: #636363;
		}
		a img { 
			border: none;
		}
		.wrds {
			float: left;
			width: 95%;
			padding: 10px 0;
			padding-left: 25px;
			padding-bottom: 120px;
			font-family: Verdana, Geneva, sans-serif;
			font-size: 14px;
			font-weight: bolder;
			color: #666;
		}
		.wrdimg {
			font-family: Verdana, Geneva, sans-serif;
			font-size: 14px;
			font-weight: bold;
			color: #666;
		}
		.wrdstable {
			font-family: Verdana, Geneva, sans-serif;
			font-size: 13px;
			font-weight: bold;
			color: #666;
		}
		.side {
			width: 3px;
		}
		body {
			margin-left: 20px;
			margin-top: 10px;
			margin-right: 10px;
			margin-bottom: 10px;
		}
		</style>
		</head>
		<body>
		<div><p></p>
		</div>
		<div>
		<h3>'$tpc'</h3>
		<p>&nbsp;</p>
		<hr>
		<table width="80%" align="left" border="0" class="ifont">
		<tr>
		<td>
		<br>' > pdf
		printf "$nts" >> pdf
		echo '<p>&nbsp;</p>
		<p>&nbsp;</p>
		<p>&nbsp;</p>
		</td>
		</tr>
		</table>' >> pdf
		#images
		cd "$DM_tlt/words/images"
		cnt=`ls -1 *.jpg 2>/dev/null | wc -l`
		if [ $cnt != 0 ]; then
			cd $DT/mkhtml/images/
			ls *.png | sed 's/\.png//g' > $DT/mkhtml/nimg
			cd $DT/mkhtml
			echo '<table width="90%" align="center" border="0" class="wrdimg">' >> pdf
			n=1
			while [ $n -le "$(cat nimg | wc -l)" ]; do
					if [ -f nnn ]; then
					n=$(cat nnn)
					fi
					nn=$(($n + 1))
					nnn=$(($n + 2))
					d1m=$(cat nimg | sed -n "$n","$nn"p | sed -n 1p)
					d2m=$(cat nimg | sed -n "$n","$nn"p | sed -n 2p)
					if [ -n "$d1m" ]; then
						echo '<tr>
						<td align="center"><img src="images/'$d1m'.png" width="240" height="220"></td>' >> pdf
						if [ -n "$d2m" ]; then
							echo '<td align="center"><img src="images/'$d2m'.png" width="240" height="220"></td>
							</tr>' >> pdf
						else
							echo '</tr>' >> pdf
						fi
						echo '<tr>
						<td align="center" valign="top"><p>'$d1m'</p>
						<p>&nbsp;</p>
						<p>&nbsp;</p>
						<p>&nbsp;</p></td>' >> pdf
						if [ -n "$d2m" ]; then
							echo '<td align="center" valign="top"><p>'$d2m'</p>
							<p>&nbsp;</p>
							<p>&nbsp;</p>
							<p>&nbsp;</p></td>
							</tr>' >> pdf
						else
							echo '</tr>' >> pdf
						fi
					else
						break
					fi
					echo $nnn > nnn
				let n++
			done
			echo '</table>
			<p>&nbsp;</p>
			<p>&nbsp;</p>' >> pdf
		fi
		#words
		cd $DT/mkhtml
		n=1
		while [ $n -le "$(cat $iw | wc -l)" ]; do
			wnm=$(sed -n "$n"p $iw)
			tgs=$(eyeD3 "$DM_tlt/words/$wnm.mp3")
			wt=$(echo "$tgs" | grep -o -P "(?<=IWI1I0I).*(?=IWI1I0I)")
			ws=$(echo "$tgs" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")
			inf=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
			hlgt=$(echo $wt | awk '{print tolower($0)}')
			exm1=$(echo "$inf" | sed -n 1p | sed 's/\\n/ /g')
			dftn=$(echo "$inf" | sed -n 2p | sed 's/\\n/ /g')
			exmp1=$(echo "$exm1" \
			| sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
			echo "$wt" >> W.lizt.x
			echo "$ws" >> W.lizs.x
			if [ -n "$wt" ]; then
				echo '<table width="55%" border="0" align="left" cellpadding="10" cellspacing="5">
				<tr>
				<td bgcolor="#F8D49F" class="side"></td>
				<td bgcolor="#F7EDDF"><w1>'$wt'</w1></td>
				</tr>
				<tr>
				<td bgcolor="#EAE5A0" class="side"></td>
				<td bgcolor="#FAF9F4"><w2>'$ws'</w2></td>
				</tr>
				</table>' >> pdf
				echo '<table width="100%" border="0" align="center" cellpadding="10" class="efont">
				<tr>
				<td width="10px"></td>' >> pdf
				if ([ -z "$dftn" ] && [ -z "$exmp1" ]); then
				echo '<td width="466" valign="top" class="nfont" >'$ntes'</td>
				<td width="389"</td>
				</tr>
				</table>' >> pdf
				else
					echo '<td width="466">' >> pdf
					if [ -n "$dftn" ]; then
						echo '<dl>
						<dd><dfn>'$dftn'</dfn></dd>
						</dl>' >> pdf
					fi
					if [ -n "$exmp1" ]; then #Example: <dt> </dt>
						echo '<dl>
						<dt> </dt>
						<dd><cite>'$exmp1'</cite></dd>
						</dl>' >> pdf
					fi 
					echo '</td>
					<td width="389" valign="top" class="nfont">'$ntes'</td>
					</tr>
					</table>' >> pdf
				fi
				echo '<p>&nbsp;</p>
				<h1>&nbsp;</h1>' >> pdf
			fi
			let n++
		done
		#sentences
		n=1
		while [ $n -le "$(cat s.inx.l | wc -l)" ]; do
				st=$(sed -n "$n"p S.gprt.x)
				if [ -n "$st" ]; then
					ss=$(sed -n "$n"p S.gprs.x)
					fn=$(sed -n "$n"p s.inx.l)
					echo '<h1>&nbsp;</h1>
					<table width="100%" border="0" align="left" cellpadding="10" cellspacing="5">
					<tr>
					<td bgcolor="#FAF9F4"><h1>'$st'</h1></td>
					</tr>' > Sgprt.tmp
					echo '<tr>
					<td ><h2>'$ss'</h2></td>
					</tr>
					</table>
					<h1>&nbsp;</h1>' > Sgprs.tmp
					cat Sgprt.tmp >> pdf
					cat Sgprs.tmp >> pdf
				fi
			let n++
		done
		#html
		echo '<p>&nbsp;</p>
		<p>&nbsp;</p>
		<h3>&nbsp;</h3>
		<p>&nbsp;</p>
		</div>
		</div>
		<span class="container"></span>
		</body>
		</html>' >> pdf
		mv -f pdf pdf.html
		wkhtmltopdf -s A4 -O Portrait --ignore-load-errors pdf.html tmp.pdf
		mv -f tmp.pdf "$pdf"
		rm -fr pdf $DT/mkhtml $DT/*.x $DT/*.l

	else
		exit 1
	fi
fi
