#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Panel Play: ejecuta el mecanismo existente de Play sobre el topic activo.
#
# Lee el topic activo y su stts en CADA invocación (c.conf los toma de
# ~/.config/idiomind/tpc y de la base de configuración), de modo que nunca
# se reutiliza un TPC residual de una ejecución anterior. No altera la
# lógica interna de Play: sólo prepara sus parámetros de entrada.

source "/usr/share/idiomind/default/c.conf"

if [ -f "${DC_tlt}/stts" ]; then
    stts="$(sed -n 1p "${DC_tlt}/stts")"
    export stts
fi

exec "$DS/play.sh" play_list "" "$tpc"
