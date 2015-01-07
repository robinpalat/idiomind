#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/"
drtc="$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
drts="/usr/share/idiomind/addons/Practice/"
u=$(echo "$(whoami)")
DT=/tmp/.idmtp1.$u
yad=yad

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
		| sed "s|[a-z]|._|g" | tr ".?!;," ' ')
		Hint="--button=Hint:$drts/hint '$prsw'"
		
		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			IMAGE="$DT/ILLUSTRATION".jpeg		
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$($yad --center --text-info --image="$IMAGE" \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " --image-on-top \
			--skip-taskbar --margins=8 --text-align=right --height=400 --width=460 \
			--align=left --window-icon=idiomind --fore=4A4A4A \
			--button=Listen:"play '$drtt/$s1.mp3'" \
			"$Hint" \
			--button=" Ok ":0)
		else
			(sleep 1.5 && play "$drtt/$s1".mp3) &
			SE=$($yad --center --text-info --fore=4A4A4A \
			--fontname="Verdana Black" --justify=fill --editable --wrap \
			--buttons-layout=end --borders=0 --title=" " \
			--skip-taskbar --margins=8 --text-align=right --height=160 --width=460 \
			--align=left --window-icon=idiomind \
			--button="  Listen  ":"play '$drtt/$s1.mp3'" "$Hint" \
			--button=" Ok ":0)
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
	
		$yad --form --center --name=idiomind \
		--width=470 --height=230 --on-top --skip-taskbar --scroll \
		--class=idiomind $aut --wrap --window-icon=idiomind \
		--buttons-layout=end --title="" \
		--text-align=left --borders=5 --selectable-labels \
		--button=Listen:"play '$drtt/$s1.mp3'" \
		--button="Next Sentence:2" \
		--field="<big>$WEN</big>\\n":lbl \
		--field="":lbl \
		--field="<span color='#3A9000'>$OK </span>\\n<sup>$prc</sup>\\n":lbl
		ret=$?
		if [[ $ret -eq 2 ]]; then
			rm -f $DT/*.jpeg *.png &
			killall play &
		else
			rm -f $DT/*.jpeg *.png
			$drts/cls s && exit
		fi
	fi
	let n++
done
