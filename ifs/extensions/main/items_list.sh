#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
# Shim temporal de compatibilidad (Paso 2).
# La GUI principal de Topics vive ahora en gui/topic.sh.
# Este archivo solo reexporta para referencias externas antiguas.
# No añadir lógica aquí. Ver gui/topic.sh (canónico).
if [ -n "${DS:-}" ] && [ -r "$DS/gui/topic.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/topic.sh"
fi
