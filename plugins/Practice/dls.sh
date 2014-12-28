#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/topic.id)
lgtl=$(sed -n 2p ~/.config/idiomind/s/lang)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/"
drtc="$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
drts="/usr/share/idiomind/plugins/Practice/"
yad=/lib32/yad_idiomind
vws="#"
cd "$drtc"
rm w.ok w.no

if [ "$2" = l ]; then
	vws=$drts/vws
fi

n=1
while [ $n -le $(cat lsin | wc -l) ]; do

	$vws 1 1 "$n"	
	s1=$(sed -n "$n"p lsin)
	
	if [ -f "$drtt/$s1".mp3 ]; then
	
		WEN=$(eyeD3 "$drtt/$s1".mp3 | \
		grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		eyeD3 --write-images=/tmp/.idmtp1 "$drtt/$s1.mp3"
		echo "$WEN" | awk '{print tolower($0)}' > ./sentc
		sed -i '/^$/d' lsin.ok
		sed -i '/^$/d' lsin.no
		tw=$(cat lsin | wc -l)
		wrong=$(cat lsin.no | wc -l)
		good=$(cat lsin.ok | wc -l)
		
		# awk '{print tolower($0)}' convierte todo a minusculas
		# sed -e "s/\b\(.\)/\u\1/g" convierte la primera letra de cada palabra en mayuscula
		# sed -e 's/ /\n/g' en cada espacio hace un salto de linea
		# sed -e 's/[a-z]/. /g' convierte todas la letras en minusculas en puntos
		# awk '$1=$1' FS= OFS=" " despues de cada letra agrega un espacio (separa las letras)
		# sed 's/.*/\u&/' convierte la primera letra en mayuscula
		# tr [:upper:] [:lower:] convierte todo a minusculas
		
		prsw=$(eyeD3 "$drtt/$s1".mp3 | \
		grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
		| awk '{print tolower($0)}' \
		| sed "s/\b\(.\)/\u\1/g" \
		| sed "s|[a-z]| |g" | tr ".?!;," ' ')
		
		if [ -f "/tmp/.idmtp1/FRONT_COVER".jpeg ]; then
		
			IMAGE="/tmp/.idmtp1/FRONT_COVER".jpeg		
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$(echo "$prsw" | $yad --center --text-info --image="$IMAGE" \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " --image-on-top \
			--skip-taskbar --margins=8 --text-align=right --height=450 --width=460 \
			--on-top --align=left --window-icon=idiomind --fore=4A4A4A \
			--button=gtk-media-play:"play '$drtt/$s1.mp3'" \
			--button="Ok  ( $good ):0")
		
		else
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$(echo "$prsw" | $yad --center --text-info --fore=4A4A4A \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " \
			--skip-taskbar --margins=8 --text-align=right --height=150 --width=460 \
			--on-top --align=left --window-icon=idiomind \
			--button=gtk-media-play:"play '$drtt/$s1.mp3'" \
			--button=Hint:5 \
			--button="Ok  ( $good ):0")
		fi
		ret=$?
		
		if [[ $ret -eq 0 ]]; then	
			killall play	
			echo "$SE" | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > ing # poner todo a minusculas y despues de toda palabra un salto de linea
			cat sentc | awk '{print tolower($0)}' | sed 's/ /\n/g' | grep -v '^.$' > all # poner todo a minusculas y despues de toda palabra un salto de linea
			grep -f all ing | sed 's/ /\n/g' > w.ok # listar las coincidencias
			OK=$(cat w.ok | tr '\n' ' ')
			
			cat sentc | sed 's/ /\n/g' > all
			porc=$((100*$(cat w.ok | wc -l)/$(cat all | wc -l)))
			if [ $porc -ge 70 ]; then
				play $drts/all.mp3 & sed -i 's/'"$s1"'//g' ./lsin.tmp
				echo "$s1" >> lsin.ok
				prc="$porc% <b>PASSED!</b>"
			else
				echo "$s1" >> lsin.no
				prc="$porc%"
			fi
			
			rm allc sentc
		else
			$drts/cls s && exit 1
		fi
		
		if [ -f "/tmp/.idmtp1/FRONT_COVER".jpeg ]; then
		
			$yad --form --center --name=idiomind --image="$IMAGE" \
			--width=470 --height=450 --on-top --skip-taskbar --scroll \
			--class=idiomind $aut --wrap --window-icon=idiomind \
			--buttons-layout=end --title="" --image-on-top \
			--text-align=left --borders=10 --selectable-labels \
			--button="gtk-media-play:"$drts/plys.sh"" \
			--button="Next Sentence:2" \
			--field="<big>$WEN</big>\\n":lbl \
			--field="":lbl \
			--field="<span color='#3A9000'>$OK </span>\\n<sup>$prc</sup>\\n":lbl
		
		else
			$yad --form --center --name=idiomind \
			--width=470 --height=200 --on-top --skip-taskbar --scroll \
			--class=idiomind $aut --wrap --window-icon=idiomind \
			--buttons-layout=end --title="" \
			--text-align=left --borders=10 --selectable-labels \
			--button="gtk-media-play:"$drts/plys.sh"" \
			--button="Next Sentence:2" \
			--field="<big>$WEN</big>\\n":lbl \
			--field="":lbl \
			--field="<span color='#3A9000'>$OK </span>\\n<sup>$prc</sup>\\n":lbl
		fi
			
			ret=$?
			if [[ $ret -eq 2 ]]; then
				rm -f /tmp/.idmtp1/*.jpeg *.png &
				killall play &
			else
				rm -f /tmp/.idmtp1/*.jpeg *.png
				$drts/cls s && exit
			fi
	fi

	let n++
done
