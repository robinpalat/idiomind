#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# core wrapper: new-topic ("$1" es el antiguo "$2").
exec "$DS/add.sh" new-topic "" "" "$1"
