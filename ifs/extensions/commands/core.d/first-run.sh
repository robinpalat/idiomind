#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# core wrapper: first-run (recibe "$@" SIN shift, igual que el case anterior).
exec "$DS/ifs/tls.sh" first-run "$@"
