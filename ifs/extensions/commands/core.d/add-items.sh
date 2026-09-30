#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# core wrapper: add-items ("$1" es el antiguo "$2"; ${dir} llegaba vacio
# al case porque solo se define dentro de new_session: se preserva "").
exec "$DS/add.sh" new_items "" 2 "$1"
