#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# current process
function dlg_msg_3() {
    
        yad --fixed --center --on-top \
        --image=info --name=idiomind \
        --text=" $current_pros  " \
        --fixed --sticky --buttons-layout=edge \
        --width=360 --height=120 --borders=5 \
        --skip-taskbar --window-icon=idiomind \
        --title=Idiomind --button=gtk-cancel:3 --button=Ok:1
}


# s
function dlg_msg_2() {
    
        yad --name=idiomind --center --on-top --image=info \
        --text="$item_err\n" \
        --image-on-top --width=360 --height=120 --borders=3 \
        --skip-taskbar --window-icon=idiomind --sticky \
        --title=Idiomind --button="$delete":1 --button="$fix_item":0 
}


# same name - topic 
function dlg_msg_6() {
    
        yad --name=idiomind --center --on-top --image=info \
        --text=" $1" \
        --image-on-top --width=420 --height=120 --borders=3 \
        --skip-taskbar --window-icon=idiomind --sticky \
        --title=Idiomind --button="$cancel":1 --button=Ok:0
}


# new topic
function dlg_form_0() {
    
        yad --window-icon=idiomind --form --center \
        --field="$name_for_new_topic" "$2" --title="$1" \
        --width=440 --height=100 --name=idiomind --on-top \
        --skip-taskbar --borders=5 --button=gtk-ok:0
}


# imput text 
function dlg_form_1() {
    
        yad --form --center --always-print-result \
        --on-top --window-icon=idiomind --skip-taskbar \
        --separator="\n" --align=right $img \
        --name=idiomind --class=idiomind \
        --borders=0 --title=" " --width=420 --height=140 \
        --field=" <small><small>$lgtl</small></small>: " "$txt" \
        --field=" <small><small>$topic</small></small>:CB" \
        "$ttle!$new *$e$tpcs" \
        --button="<small>$image</small>":3 \
        --button="<small>Audio</small>":2 --button=gtk-ok:0
}


# imput text 
function dlg_form_2() {
    
        yad --form --center --always-print-result \
        --on-top --window-icon=idiomind --skip-taskbar \
        --separator="\n" --align=right $img \
        --name=idiomind --class=idiomind \
        --borders=0 --title=" " --width=420 --height=170 \
        --field=" <small><small>$lgtl</small></small>: " "$txt" \
        --field=" <small><small>${lgsl^}</small></small>: " "$srce" \
        --field=" <small><small>$topic</small></small>:CB" \
        "$ttle!$new *$e$tpcs" \
        --button="<small>$image</small>":3 \
        --button="<small>Audio</small>":2 --button=gtk-ok:0
}


# check_tpe
function dlg_radiolist_1() {
    
        echo "$1" | awk '{print "FALSE\n"$0}' | \
        yad --name=idiomind --class=idiomind --center \
        --list --radiolist --on-top --fixed --no-headers \
        --text="<b>$te</b> <small><small> --window-icon=idiomind \
        $info</small></small>" --sticky --skip-taskbar \
        --height=420 --width=150 --separator="\\n" \
        --button=Save:0 --title="selector" --borders=3 \
        --column=" " --column="Sentences"
}


#edit_word_list
function dlg_checklist_1() {
    
        cat "$1" | awk '{print "FALSE\n"$0}' | \
        yad --list --checklist --title="$word_selector" \
        --on-top --text="<small>$2</small>" \
        --center --sticky --no-headers \
        --buttons-layout=end --skip-taskbar --width=400 \
        --height=280 --borders=10 --window-icon=idiomind \
        --button=gtk-close:1 --button="$add":0 \
        --column="" --column="Select" > "$slt"
}


# process no audio
function dlg_checklist_3() {

        slt=$(mktemp $DT/slt.XXXX.x)
        cat "$1" | awk '{print "FALSE\n"$0}' | \
        yad --name=idiomind --window-icon=idiomind \
        --dclick-action='/usr/share/idiomind/add.sh dclik_list_words' \
        --list --checklist --class=idiomind --center --sticky \
        --text="<small>$info</small>" --title="$tpe" \
        --width=$wth --print-all --height=$eht --borders=3 \
        --button="$cancel":1 --button="$arrange":2 \
        --button="$to_new_topic":'/usr/share/idiomind/add.sh new_topic' \
        --button=gtk-save:0 \
        --column="$(cat "$1" | wc -l)" --column="$sentences" > $slt
}


# sort
function dlg_text_info_1() {
    
        cat "$1" | awk '{print "\n\n\n"$0}' | \
        yad --text-info --editable --window-icon=idiomind \
        --name=idiomind --wrap --margins=60 --class=idiomind \
        --sticky --fontname=vendana --on-top --center \
        --skip-taskbar --width=$wth \
        --height=$eht --borders=3 \
        --button=gtk-ok:0 --title="$tpe" > ./sort
}


# for log
function dlg_text_info_3() {

        printf "$1" | yad --text-info --center --wrap \
        --center --skip-taskbar --on-top --title=Idiomind \
        --width=420 --height=150 --on-top --margins=4 \
        --window-icon=idiomind --borders=0 --name=idiomind \
        "$2" --button=Ok:1
}


# no get text
function dlg_text_info_4() {
    
        echo "$1" | yad --text-info --center --wrap \
        --name=idiomind --class=idiomind --window-icon=idiomind \
        --text=" " --sticky --width=$wth --height=$eht \
        --margins=8 --borders=3 --button=Ok:0 \
        --title=Idiomind
}



function dlg_progress_1() {
    
        yad --progress --progress-text=" " \
        --width=200 --height=20 --geometry=200x20-2-2 \
        --pulsate --percentage="5" --on-top \
        --undecorated --auto-close \
        --skip-taskbar --no-buttons
}



function dlg_progress_2() {

        yad --progress --progress-text=" " \
        --width=200 --height=20 --geometry=200x20-2-2 \
        --undecorated --auto-close --on-top \
        --skip-taskbar --no-buttons
}


# load
function dlg_file_1() {
    
        echo "$(yad --borders=0 --name=idiomind --file-filter="*.mp3" \
        --skip-taskbar --on-top --title="Speech recognize" --center \
        --window-icon=idiomind --file --width=600 --height=450)"
}


# save
function dlg_file_2() {
    
        yad --save --center --borders=10 \
        --on-top --filename="$(date +%m-%d-%Y)"_audio.tar.gz \
        --window-icon=idiomind --skip-taskbar --title="Save" \
        --file --width=600 --height=500 --button=gtk-ok:0
}

                
