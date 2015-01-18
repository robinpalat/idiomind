#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf

if [ $1 = tls ]; then
$yad --form --height=190 --borders=5 --width=350 \
	--title=" " --skip-taskbar --columns=1 \
	--window-icon=idiomind \
	--field="$topics_saved:BTN" "$DS/ifs/upld.sh vsd" \
	--field="$play_time:BTN" "$DS/play.sh time" \
	--field="$audio_imput:BTN" "/usr/share/idiomind/audio/cnfg.sh" \
	--field="$search_updates:BTN" "$DS/ifs/tls.sh updt" \
	--field="$help:BTN" "$DS/ifs/tls.sh help" \
	--button=Close:0 & exit 1
fi

if [ $1 = help ]; then

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
	--width=340 --height=120 --borders=5 \
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
			echo `date +%d` > $DC_s/cnfg13 & exit
		elif [ "$ret" -eq 1 ]; then
			echo `date +%d` > $DC_s/cnfg14
			echo "$(sed -n 2p ./release)" >> $DC_s/cnfg14 & exit
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

	[[ ! -f $DC_s/cnfg13 ]] && echo `date +%d` > $DC_s/cnfg13

	d1=$(cat $DC_s/cnfg13)
	d2=`date +%d`

	[[ $(cat $DC_s/cnfg13) = 28 ]] && rm -f $DC_s/cnfg14

	[[ -f $DC_s/cnfg14 ]] && exit 1

	if [[ $(cat $DC_s/cnfg13) -ne $(date +%d) ]]; then
	
		sleep 1
		echo "$d2" > $DC_s/cnfg13
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
			--width=400 --height=150
			ret=$?
			if [ "$ret" -eq 0 ]; then
				xdg-open $pkg & exit
			elif [ "$ret" -eq 2 ]; then
				echo `date +%d` > $DC_s/cnfg13 & exit
			elif [ "$ret" -eq 1 ]; then
				echo `date +%d` > $DC_s/cnfg14 & exit
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
		nts=$(cat -e "$DC_tlt/nt" | sed 's/\$/<br>/g')
		cd $DT/mkhtml
		cp -f "$DC_tlt/cnfg3" w.inx.l
		cp -f "$DC_tlt/cnfg4" s.inx.l
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
		h1 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #696F79;
			font-size: 18px;
			font-weight: bold;
			font-family: Verdana, Geneva, sans-serif;
		}
		h2 {
			margin-top: 0;
			padding-right: 5px;
			padding-left: 5px;
			color: #7A7B7A;
			font-size: 18px;
			font-weight: normal;
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
			width: 5px;
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
		<table width="80%" align="left" border="0" class="ifont">
		<tr>
		<td>
		'$nts'
		<p>&nbsp;</p>
		<p>&nbsp;</p>
		<p>&nbsp;</p>
		</td>
		</tr>
		</table>' > pdf
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
			ntes=$(echo "$inf" | sed -n 3p | sed 's/\\n/ /g')
			exmp1=$(echo "$exm1" \
			| sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
			echo "$wt" >> W.lizt.x
			echo "$ws" >> W.lizs.x
			if [ -n "$wt" ]; then
				echo '<table width="55%" border="0" align="left" cellpadding="10" cellspacing="5">
				<tr>
				<td bgcolor="#B7C9E9" class="side"></td>
				<td bgcolor="#E7EFFD"><h1>'$wt'</h1></td>
				</tr>
				<tr>
				<td bgcolor="#C6E3A8" class="side"></td>
				<td bgcolor="#F4FFE9"><h2>'$ws'</h2></td>
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
						<dt>Definition:</dt>
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
					echo '<table width="100%" border="0" align="left" cellpadding="10" cellspacing="5">
					<tr>
					<td bgcolor="#9FBFF8" class="side">&nbsp;</td>
					<td bgcolor="#E7EFFD"><h1>'$st'</h1></td>
					</tr>' > Sgprt.tmp
					echo '<tr>
					<td bgcolor="#B5DA8F" class="side">&nbsp;</td>
					<td bgcolor="#F4FFE9"><h2>'$ss'</h2></td>
					</tr>
					</table>' > Sgprs.tmp
					echo '<div class="wrds">
					<table width="40%" align="left" cellpadding="5" class="wrdstable">
					<tbody>' > Wgprs.tmp
					eyeD3 "$DM_tlt/$fn.mp3" > tgs
					> wt
					> ws
					(
					n=1
					while [ $n -le "$(echo "$st" | sed 's/ /\n/g' \
					| grep -v '^.$' | grep -v '^..$' | wc -l)" ]; do
						cat tgs | grep -o -P '(?<=ISTI'$n'I0I).*(?=ISTI'$n'I0I)' >> wt
						cat tgs | grep -o -P '(?<=ISSI'$n'I0I).*(?=ISSI'$n'I0I)' >> ws
						let n++
					done
					)
			
					(
					n=1
					while [ $n -le "$(cat wt | wc -l)" ]; do
						wt=$(sed -n "$n"p wt)
						ws=$(sed -n "$n"p ws)
						wt2=$(sed -n "$n"p wt)
						
						if cat W.lizt.x | grep "$wt2"; then
							echo '<tr>
							<td><ma>'$wt'</ma></td>
							<td><ma>'$ws'</ma></td>
							</tr>' >> ./Wgprs.tmp
						else
							echo '<tr>
							<td>'$wt'</td>
							<td>'$ws'</td>
							</tr>' >> ./Wgprs.tmp
						fi
						
						let n++
					done
					)
					echo '</tbody>
					</table>
					</div>
					<p>&nbsp;</p>
					<p>&nbsp;</p>
					<h1>&nbsp;</h1>' >> Wgprs.tmp
					#echo '</tbody>
					#</table>
					    #<table width="40%" border="0" align="right">
						#<tr align="center" valign="top">
						#<td><p>   <img src="./images/Until.png" width="360" height="240" align="middle"></p></td>
						#</tr>
					#</table>
					#</div>
					#<p>&nbsp;</p>
					#<p>&nbsp;</p>
					#<h1>&nbsp;</h1>' >> Wgprs.tmp
					cat Sgprt.tmp >> pdf
					cat Sgprs.tmp >> pdf
					cat Wgprs.tmp >> pdf
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
