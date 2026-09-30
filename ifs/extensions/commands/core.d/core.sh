#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# Glue helpers for core commands that delegate to main.sh shell functions.
# Sourced by main.sh; called with no arguments, like the old hardcoded case.

_core_version() {
    source $DS/default/sets.cfg
    echo -n "$_version"
}

_core_s() {
    # Fuerza la creación de una nueva sesión y abre la interfaz principal.
    new_session; idiomind
}
