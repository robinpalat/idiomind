#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
rword=$(grep -oP '(?<=rword=\").*(?=\")' "${DC_tlt}/10.cfg")
autr=$(grep -oP '(?<=autr=\").*(?=\")' "$DC/3.cfg")
mkdir -p "$DT/export_audio/a"
dire="$DT/export_audio"
s1="$DS/addons/Save as Audio/si1.mp3"
s2="$DS/addons/Save as Audio/si2.mp3"
so1="$DS/addons/Save as Audio/si0_1.mp3"
so2="$DS/addons/Save as Audio/si0_2.mp3"
s4="$DS/addons/Save as Audio/si4.mp3"
img="$DS/addons/Save as Audio/$tlng.png"
cd "${dire}"/

extchk () {
	msg "$(gettext "Something Unexpected Happened, exiting.")\n(Item: $trg)" \
	error "$(gettext "Information")" 
	cleanups "$DT/export_audio" & exit 1
}

n=1; a=1
while read -r _item; do
    [ ! -d "$DT/export_audio" ] && break
    unset cdid trgt ; get_item "${_item}"
    
	if [ -n "${trgt}" -a -n "${cdid}" ]; then
    
		echo -n "${trgt}" >> "${dire}/text"
        
        if [ "${type}" = 2 ]; then
        
			if [ -f "${DM_tlt}/$cdid.mp3" ]; then
			
				sox "${DM_tlt}/$cdid.mp3" -r 44100 -C 128 "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
				
				if [ "$rword" = 2 ]; then 
				
					cp "$so2" "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					sox "${DM_tlt}/$cdid.mp3" -r 44100 -C 128 "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
				fi
				
				cp "$s2" "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
				
				cp "$s4" "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
			fi

        elif [ "${type}" = 1 ]; then
        
			if [ -f "$DM_tls/audio/${trgt,,}.mp3" ]; then
			
				sox "$DM_tls/audio/${trgt,,}.mp3" -r 44100 -C 128 "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
				
				if [ "$rword" = 1 ]; then
					sox "$DM_tls/audio/${trgt,,}.mp3" -r 44100 -C 128 "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					cp "$so1" "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					sox "$DM_tls/audio/${trgt,,}.mp3" -r 44100 -C 128 "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
				fi
					cp "$s1" "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					cp "$s4" "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi

			elif [ -f "${DM_tlt}/$cdid.mp3" ]; then
			
				sox "${DM_tlt}/$cdid.mp3" -r 44100 -C 128 "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
				
				if [ "$rword" = 1 ]; then 
					sox "${DM_tlt}/$cdid.mp3" -r 44100 -C 128 "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					cp "$so1" "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
					
					sox "${DM_tlt}/$cdid.mp3" -r 44100 -C 128 "$dire/$n.mp3"
					if [ $? != 0 ]; then extchk; else let n++; fi
				fi
			
				cp "$s1" "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
					
				cp "$s4" "$dire/$n.mp3"
				if [ $? != 0 ]; then extchk; else let n++; fi
			fi
        fi
    fi
    
    mp3wrap ./a/${a}album.mp3 $(ls -v ./*.mp3)
    if [ $? != 0 ]; then extchk; fi
    rm ./*.mp3; let a++; n=1
    
done < "${DC_tlt}/0.cfg"

#sox --combine sequence $(ls ./*.mp3) album_MP3WRAP.mp3
mp3wrap ./album.mp3 $(ls -v ./a/*.mp3)
if [ $? != 0 ]; then extchk; fi

[ -z "$autr" ] && autr="User"
eyeD3 --lyrics=eng:LYRICS_FILE:"$dire/text" ./"album_MP3WRAP.mp3"
eyeD3 -t "$tpc" -a "$autr" -A "Idiomind" -n "1" ./"album_MP3WRAP.mp3" 
eyeD3 --add-image "$img":ILLUSTRATION ./"album_MP3WRAP.mp3" --remove-all-comments

if [ -e ./"album_MP3WRAP.mp3" ]; then 
	mv -f ./"album_MP3WRAP.mp3" "${1}.mp3"
else
	extchk
fi
cleanups "$DT/export_audio"

exit 1


