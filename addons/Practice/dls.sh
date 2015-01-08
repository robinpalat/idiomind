#!/bin/bash
# -*- ENCODING: UTF-8 -*-

tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/"
drtc="$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
drts="/usr/share/idiomind/addons/Practice/"
u=$(echo "$(whoami)")
DT=/tmp/.idmtp1.$u
cd "$drtc"
rm w.ok w.no
n=1
while [ $n -le $(cat lsin | wc -l) ]; do

	s1=$(sed -n "$n"p lsin)
	
	if [ -f "$drtt/$s1".mp3 ]; then
		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			rm -f "$DT/ILLUSTRATION".jpeg
		fi
		WEN=$(eyeD3 "$drtt/$s1".mp3 | \
		grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		eyeD3 --write-images=$DT "$drtt/$s1.mp3"
		echo "$WEN" | awk '{print tolower($0)}' > ./sentc

		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			IMAGE="$DT/ILLUSTRATION".jpeg
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$(yad --center --text-info --image="$IMAGE" \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " --image-on-top \
			--skip-taskbar --margins=8 --text-align=right --height=400 --width=460 \
			--align=left --window-icon=idiomind --fore=4A4A4A \
			--button=Hint:"/usr/share/idiomind/addons/Practice/hint.sh '$n'" \
			--button=Listen:"play '$drtt/$s1.mp3'" \
			--button=" Ok ":0)
		else
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$(yad --center --text-info --fore=4A4A4A \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " \
			--skip-taskbar --margins=8 --text-align=right --height=160 --width=460 \
			--align=left --window-icon=idiomind \
			--button=Hint:"/usr/share/idiomind/addons/Practice/hint.sh '$n'" \
			--button="Listen":"play '$drtt/$s1.mp3'" \
			--button=" Ok ":0)
		fi
		ret=$?
		
		if [[ $ret -eq 0 ]]; then
			killall play
			echo "$SE" | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > ing
			cat sentc | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > all
			(
				ff="$(cat ing | sed 's/ /\n/g')"
				n=1
				while [ $n -le $(echo "$ff" | wc -l) ]; do
					line="$(echo "$ff" | sed -n "$n"p )"
					
					if cat all | grep -o "$line"; then
						[[ -n "$line" ]] && echo "<span color='#3A9000'>$line</span>" >> wrds
						[[ -n "$line" ]] && echo "$line" >> w.ok
					else
						[[ -n "$line" ]] && echo "<span color='#9E3E18'>$line</span>" >> wrds
					fi
					let n++
				done
			)
			OK=$(cat wrds | tr '\n' ' ')
			
			cat sentc | sed 's/ /\n/g' > all
			porc=$((100*$(cat w.ok | wc -l)/$(cat all | wc -l)))
			if [ $porc -ge 70 ]; then
				play $drts/all.mp3 & sed -i 's/'"$s1"'//g' ./lsin.tmp
				echo "$s1" >> lsin.ok
				prc="$porc% <b>OK!</b>"
			else
				echo "$s1" >> lsin.no
				prc="$porc%"
			fi
			rm allc sentc
		else
			$drts/cls s && exit 1
		fi
	
		yad --form --center --name=idiomind \
		--width=470 --height=230 --on-top --skip-taskbar --scroll \
		--class=idiomind $aut --wrap --window-icon=idiomind \
		--buttons-layout=end --title="" \
		--text-align=left --borders=5 --selectable-labels \
		--button=Listen:"play '$drtt/$s1.mp3'" \
		--button="Next Sentence:2" \
		--field="<big>$WEN</big>\\n":lbl \
		--field="":lbl \
		--field="$OK\\n<sup>$prc</sup>\\n":lbl
		ret=$?
		if [[ $ret -eq 2 ]]; then
			rm -f w.ok wrds $DT/*.jpeg *.png &
			killall play &
		else
			rm -f w.ok wrds $DT/*.jpeg *.png
			$drts/cls s && exit
		fi
	fi
	let n++
done
