#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"

if [[ $(wc -l < "$DC_tlt/3.cfg") -lt 2 ]]; then
msg "$(gettext "Words not found in the topic.")\n" error "$(gettext "Information")" & exit 1
fi

word_examen() {
    cat <<!EOF
<table width="100%" cellpadding="0" cellspacing="10"><tr>
<td width="50%"><tw1>${trgt1}</tw1></td><td width="50%"><tw1>${trgt}</tw1></td></tr><tr><td><table><tr>
<td><exmp>$_checkbox ${item1}</exmp></td><td><exmp>$_checkbox ${item2}</exmp></td>
<td><exmp>$_checkbox ${item3}</exmp></td></tr><tr>
<td><exmp>$_checkbox ${item4}</exmp></td><td><exmp>$_checkbox ${item5}</exmp></td>
<td><exmp>$_checkbox ${item6}</exmp></td></tr></table></td><td><table><tr>
<td><exmp>$_checkbox ${item7}</exmp></td><td><exmp>$_checkbox ${item8}</exmp></td>
<td><exmp>$_checkbox ${item9}</exmp></td></tr><tr>
<td><exmp>$_checkbox ${item10}</exmp></td><td><exmp>$_checkbox ${item11}</exmp></td>
<td><exmp>$_checkbox ${item12}</exmp></td></tr></table></td></tr></table>
!EOF
}

export _checkbox="<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3woDEzoH0hTl5gAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAA2SURBVDjL7dVBEQAwDAJB6FQh0RmNiYdO+XEC9nuUNDB0AaC7+ROtqjkwFThw4MCBA79F10wX13oIF8HVFq4AAAAASUVORK5CYII=\"/>"
export f=2
export -f word_examen

$(dirname "$0")/PDF.sh "$@"
