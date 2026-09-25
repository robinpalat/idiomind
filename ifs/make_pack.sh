#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# =============================================================================
# Idiomind — Language Pack Generator v2 (prototipo FASE 3)
# =============================================================================
# Genera UN Language Pack v2 para UN topic y UN source language.
#
# Uso:
#   make_pack.sh --topic NAME --source it --out pack.json
#                (--pairs-file F | --srce-json J [--wrds-json J] | --engine auto)
#                [--topic-name N] [--topic-version V] [--pack-version N]
#                [--target EN] [--no-self-test]
#
# Fuentes de traduccion (mutuamente excluyentes):
#   --pairs-file F   TSV en orden del data:  srce<TAB>wrds  (wrds puede ir vacio)
#   --srce-json J    JSON array de srce en orden (+ --wrds-json opcional)
#   --engine auto    motor existente: translate() + sentence_p() de
#                    ifs/extensions/add/add.sh (requiere entorno Idiomind + red)
#
# Politica de versionado (FASE 3):
#   topic_id    = ilnk (identidad). Sin ilnk no hay pack.
#   topic_hash  = identidad del contenido (sha256 trgt en orden, via lp_topic_hash).
#   format      = version del esquema (../2). Cambio de esquema -> ../3.
#   pack_version= iteracion del contenido LINGUISTICO para el mismo
#                 (topic_id, source). NO representa cambios del topic:
#                 si cambia una oracion, pack_version queda igual y topic_hash
#                 cambia (el cliente rechaza el pack viejo automaticamente).
#   topic_version = metadata INFORMATIVA opcional. Nunca se valida, nunca se
#                 genera automaticamente (seria anti-reproducible). Solo aparece
#                 con --topic-version explicito.
#
# El topic original es el maestro; el pack es delta linguistico (srce+wrds).
# No genera grmr (depende solo del target), no copia trgt ni otros campos.
# =============================================================================
set -u

SELF="${BASH_SOURCE[0]:-$0}"
SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"
: "${DS:=$SELF_DIR/..}"
# Reutilizacion unica: hash + validacion del cliente (sin duplicar algoritmos).
# 100 % Bash (como lfetch.sh): sin interpretes externos, solo sqlite3/awk/sed.
# shellcheck disable=SC1091
source "$SELF_DIR/lfetch.sh"

mp_log() { printf 'make-pack: %s\n' "$*" >&2; }
mp_fail() { mp_log "ERROR: $*"; exit 1; }

TOPIC=""; SOURCE=""; TARGET=""; OUT=""
PAIRS_FILE=""; SRCE_JSON=""; WRDS_JSON=""; ENGINE=""
TOPIC_NAME=""; TOPIC_VERSION=""; PACK_VERSION="1"; SELF_TEST="1"

while [ $# -gt 0 ]; do
    case "$1" in
        --topic) TOPIC="${2:-}"; shift 2 ;;
        --source) SOURCE="${2:-}"; shift 2 ;;
        --target) TARGET="${2:-}"; shift 2 ;;
        --out) OUT="${2:-}"; shift 2 ;;
        --pairs-file) PAIRS_FILE="${2:-}"; shift 2 ;;
        --srce-json) SRCE_JSON="${2:-}"; shift 2 ;;
        --wrds-json) WRDS_JSON="${2:-}"; shift 2 ;;
        --engine) ENGINE="${2:-}"; shift 2 ;;
        --topic-name) TOPIC_NAME="${2:-}"; shift 2 ;;
        --topic-version) TOPIC_VERSION="${2:-}"; shift 2 ;;
        --pack-version) PACK_VERSION="${2:-}"; shift 2 ;;
        --no-self-test) SELF_TEST="0"; shift ;;
        -h|--help) sed -n '2,40p' "$SELF"; exit 0 ;;
        *) mp_fail "arg desconocido: $1" ;;
    esac
done

[ -n "$TOPIC" ] || mp_fail "falta --topic"
[ -n "$SOURCE" ] || mp_fail "falta --source"
[ -n "$OUT" ] || mp_fail "falta --out"
_nsrc=0
[ -n "$PAIRS_FILE" ] && _nsrc=$((_nsrc+1))
[ -n "$SRCE_JSON" ] && _nsrc=$((_nsrc+1))
[ -n "$ENGINE" ] && _nsrc=$((_nsrc+1))
[ "$_nsrc" -eq 1 ] || mp_fail "exactamente una fuente: --pairs-file, --srce-json o --engine"

# --- resolver topic ----------------------------------------------------------
if [ -n "${DC_tlt:-}" ] && [ -d "$DC_tlt" ]; then
    CONF_DIR="$DC_tlt"
elif [ -n "${DM_tl:-}" ] && [ -d "$DM_tl/$TOPIC/.conf" ]; then
    CONF_DIR="$DM_tl/$TOPIC/.conf"
else
    mp_fail "topic no encontrado: $TOPIC (exporte DC_tlt o DM_tl)"
fi
DATA="$CONF_DIR/data"
TPCDB="$CONF_DIR/tpc"
[ -f "$DATA" ] || mp_fail "sin data: $DATA"
[ -f "$TPCDB" ] || mp_fail "sin tpc db: $TPCDB"

TOPIC_ID="$(sqlite3 "$TPCDB" "select ilnk from id;" 2>/dev/null | head -n1)"
[ -n "$TOPIC_ID" ] || mp_fail "topic sin ilnk: no se genera pack"
DB_TLNG="$(sqlite3 "$TPCDB" "select tlng from id;" 2>/dev/null | head -n1)"
[ -n "$TARGET" ] || TARGET="$DB_TLNG"
[ -n "$TARGET" ] || TARGET="${tlng:-}"
[ -n "$TARGET" ] || mp_fail "target desconocido"
[ -z "$TOPIC_NAME" ] && TOPIC_NAME="$(sqlite3 "$TPCDB" "select name from id;" 2>/dev/null | head -n1)"
[ -z "$TOPIC_NAME" ] && TOPIC_NAME="$TOPIC"

TLNG="$(lp_lang_code "$TARGET")"
SLNG="$(lp_lang_code "$SOURCE")"
[ -n "$TLNG" ] || mp_fail "target invalido: $TARGET"
[ -n "$SLNG" ] || mp_fail "source invalido: $SOURCE"
[[ "$PACK_VERSION" =~ ^[0-9]+$ ]] && [ "$PACK_VERSION" -ge 1 ] && [ "$PACK_VERSION" -le 9999 ] \
    || mp_fail "pack-version invalido: $PACK_VERSION"

# --- leer items locales (orden canonico) -------------------------------------
# Formato propio trgt{}/type{} (no JSON; valores saneados sin llaves, asi que
# hasta-primer-'}' equivale a [^}]*). Columnas: trgt<TAB>type. La primera
# ocurrencia manda (igual que re.search); sin tabuladores en campos.
ITEMS_TMP="$(mktemp "${TMPDIR:-/tmp}/mp_items.XXXXXX")" || exit 1
_mp_get() { # $1=linea $2=clave -> valor; rc=1 si ausente o sin cierre
    local L="$1" K="$2" tmp
    case "$L" in *"$K{"*) ;; *) return 1 ;; esac
    tmp="${L#*"$K{"}"
    case "$tmp" in *"}"*) ;; *) return 1 ;; esac
    printf '%s' "${tmp%%\}*}"
}
_mp_nlines=0
while IFS= read -r _ln || [ -n "$_ln" ]; do
    _bl="${_ln//[[:space:]]/}"
    [ -z "$_bl" ] && continue
    _t="$(_mp_get "$_ln" trgt)" && [ -n "$_t" ] || mp_fail "data sin items validos"
    _y="$(_mp_get "$_ln" type)" || _y=""
    case "$_t$_y" in *$"	"*) mp_fail "data con tabuladores" ;; esac
    printf '%s\t%s\n' "$_t" "$_y" >>"$ITEMS_TMP"
    _mp_nlines=$((_mp_nlines+1))
done <"$DATA"
[ "$_mp_nlines" -ge 1 ] || mp_fail "data sin items validos"
COUNT="$_mp_nlines"
[ "$COUNT" -ge 1 ] && [ "$COUNT" -le "$IDMND_LP_MAXITEMS" ] \
    || mp_fail "count fuera de rango: $COUNT"

# Hash canonico con LA implementacion del cliente (sin duplicar algoritmo).
HASH_OUT="$(bash "$SELF_DIR/lfetch.sh" hash "$DATA" 2>/dev/null)" \
    || mp_fail "no se pudo calcular topic_hash"
TOPIC_HASH="$(sed -n 1p <<< "$HASH_OUT")"
HASH_COUNT="$(sed -n 2p <<< "$HASH_OUT")"
[ "$HASH_COUNT" = "$COUNT" ] || mp_fail "hash/count inconsistente"

# --- obtener pares (srce, wrds) en orden -------------------------------------
PAIRS_TMP="$(mktemp "${TMPDIR:-/tmp}/mp_pairs.XXXXXX")" || exit 1
if [ -n "$PAIRS_FILE" ]; then
    [ -f "$PAIRS_FILE" ] || mp_fail "pairs-file inexistente"
    cp -f "$PAIRS_FILE" "$PAIRS_TMP"
elif [ -n "$SRCE_JSON" ]; then
    # Arrays JSON via sqlite3 (parser real, sin regex ingenuas). Valores sin
    # controles ni llaves para que el TSV posterior sea exacto.
    _mp_je() { printf '%s' "$1" | sed "s/'/''/g"; }
    _SJE="$(_mp_je "$SRCE_JSON")"
    [ "$(sqlite3 :memory: <<<"SELECT json_valid('$_SJE'), json_type('$_SJE'), json_array_length('$_SJE');" 2>/dev/null)" = "1|array|$COUNT" ] \
        || mp_fail "srce-json invalido o count incorrecto"
    [ "$(sqlite3 :memory: <<<"SELECT count(*) FROM json_each('$_SJE') WHERE type!='text';" 2>/dev/null)" = "0" ] \
        || mp_fail "srce-json con elementos no textuales"
    [ "$(sqlite3 :memory: <<<"SELECT count(*) FROM json_each('$_SJE') WHERE value LIKE '%'||char(10)||'%' OR value LIKE '%'||char(9)||'%' OR value LIKE '%'||char(13)||'%' OR value LIKE '%{%' OR value LIKE '%}%';" 2>/dev/null)" = "0" ] \
        || mp_fail "srce-json con caracteres invalidos"
    sqlite3 :memory: <<<"SELECT value FROM json_each('$_SJE');" >"$PAIRS_TMP.S" 2>/dev/null \
        || mp_fail "srce-json ilegible"
    if [ -n "$WRDS_JSON" ]; then
        _WJE="$(_mp_je "$WRDS_JSON")"
        [ "$(sqlite3 :memory: <<<"SELECT json_valid('$_WJE'), json_type('$_WJE'), json_array_length('$_WJE');" 2>/dev/null)" = "1|array|$COUNT" ] \
            || mp_fail "wrds-json invalido o count incorrecto"
        [ "$(sqlite3 :memory: <<<"SELECT count(*) FROM json_each('$_WJE') WHERE type!='text';" 2>/dev/null)" = "0" ] \
            || mp_fail "wrds-json con elementos no textuales"
        [ "$(sqlite3 :memory: <<<"SELECT count(*) FROM json_each('$_WJE') WHERE value LIKE '%'||char(10)||'%' OR value LIKE '%'||char(9)||'%' OR value LIKE '%'||char(13)||'%' OR value LIKE '%{%' OR value LIKE '%}%';" 2>/dev/null)" = "0" ] \
            || mp_fail "wrds-json con caracteres invalidos"
        sqlite3 :memory: <<<"SELECT value FROM json_each('$_WJE');" >"$PAIRS_TMP.W" 2>/dev/null \
            || mp_fail "wrds-json ilegible"
    else
        awk -v N="$COUNT" 'BEGIN{for(i=0;i<N;i++) print ""}' >"$PAIRS_TMP.W" </dev/null \
            || mp_fail "wrds vacios"
    fi
    paste -d'	' "$PAIRS_TMP.S" "$PAIRS_TMP.W" >"$PAIRS_TMP" || mp_fail "pares"
    rm -f "$PAIRS_TMP.S" "$PAIRS_TMP.W"
else
    # --- motor existente (sin duplicar algoritmo linguistico) ----------------
    # El motor (add.sh) espera el entorno de c.conf (tlng/slng/...), que en
    # produccion carga main.sh. Si falta (p. ej. invocacion directa), se
    # carga aqui en modo solo-lectura. Hallazgo FASE 4: sin esto, --engine
    # fallaba con "tlng: unbound variable" fuera del flujo normal.
    if [ -z "${tlng:-}" ] || [ -z "${slng:-}" ]; then
        if [ -f /usr/share/idiomind/default/c.conf ]; then
            # shellcheck disable=SC1091
            source /usr/share/idiomind/default/c.conf
        elif [ -f "$DS/default/c.conf" ]; then
            # shellcheck disable=SC1091
            source "$DS/default/c.conf"
        fi
        [ -n "${tlng:-}" ] && [ -n "${slng:-}" ] \
            || mp_fail "sin entorno de idiomas (tlng/slng)"
    fi
    # Aislamiento del lote: si el llamador exporta IDMND_ENGINE_TLNGDB, el
    # motor (sentence_p/translate) usa esa DB temporal en vez de la del
    # usuario (c.conf). Sin efecto en uso normal ni en tests.
    if [ -n "${IDMND_ENGINE_TLNGDB:-}" ]; then
        export tlngdb="$IDMND_ENGINE_TLNGDB"
    fi
    if ! declare -F translate >/dev/null 2>&1; then
        [ -f "$DS/ifs/extensions/add/add.sh" ] \
            || mp_fail "motor translate no disponible (ni funcion ni add.sh)"
        # shellcheck disable=SC1091
        source "$DS/ifs/extensions/add/add.sh" \
            || mp_fail "no se pudo cargar add.sh"
        declare -F translate >/dev/null 2>&1 \
            || mp_fail "motor translate no disponible tras cargar add.sh"
    fi
    if ! declare -F clean_1 >/dev/null 2>&1; then
        clean_1() { printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
        clean_2() { printf '%s' "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
    fi
    export lgt="$TLNG" lgs="$SLNG"
    export DT_r
    DT_r="$(mktemp -d "${TMPDIR:-/tmp}/mp_eng.XXXXXX")" || exit 1
    export db="$DS/default/dicts/$TLNG"
    _ln=0
    while IFS='	' read -r trgt _type; do
        _ln=$((_ln+1))
        _srce_new=""; _wrds_new=""
        if [ "$_type" = "1" ]; then
            _t="$(clean_1 "$trgt")"
            [ -n "$_t" ] || mp_fail "linea $_ln: trgt vacio tras limpieza"
            _s="$(translate "$_t" "$TLNG" "$SLNG")"
            _s="$(clean_1 "$_s")"
            [ -n "$_s" ] || mp_fail "linea $_ln: motor sin traduccion para '$_t'"
            _srce_new="$_s"
            # wrds de palabra: par unico Title_Title (igual que translate_to).
            _wrds_new="${_t^}_${_s^}"
        else
            _t="$(clean_2 "$trgt")"
            [ -n "$_t" ] || mp_fail "linea $_ln: trgt vacio tras limpieza"
            declare -F sentence_p >/dev/null 2>&1 \
                || mp_fail "motor sentence_p no disponible (linea $_ln)"
            trgt="$_t" srce=""
            _s="$(translate "$_t" "$TLNG" "$SLNG")"
            _s="$(clean_2 "$_s")"
            [ -n "$_s" ] || mp_fail "linea $_ln: motor sin traduccion"
            # sentence_p es el constructor de wrds/grmr del flujo de alta
            # (add.sh:new_sentence/process). Reutilizado, no reimplementado.
            trgt_p="$_t" srce_p="$_s" wrds="" grmr=""
            export trgt srce trgt_p srce_p wrds grmr
            sentence_p 1
            _srce_new="$_s"
            _wrds_new="$wrds"
        fi
        printf '%s\t%s\n' "$_srce_new" "$_wrds_new" >> "$PAIRS_TMP"
    done < "$ITEMS_TMP"
    rm -rf "$DT_r"
fi

# --- validaciones previas (§8) ------------------------------------------------
# Validacion exacta con awk sobre PAIRS_TMP (cubra pairs-file, json y motor):
# dos columnas como maximo, srce no vacio, longitudes, sin llaves (protegen
# el formato trgt{}/srce{}/wrds{}) y sin controles C0. length() cuenta
# caracteres bajo locale UTF-8; en su defecto bytes (mas estricto: fail closed).
_mp_sep="$(printf '\001')"
awk -v N="$COUNT" '
BEGIN{ FS="\t"; CC=""; for(i=1;i<32;i++) CC=CC sprintf("%c",i); bad=0; n=0 }
{
    n++
    if (NF>2) bad=1
    s=$1; w=(NF>1 ? $2 : "")
    if (s=="" || length(s)>500 || length(w)>2000) bad=1
    if (index(s,"{")||index(s,"}")||index(w,"{")||index(w,"}")) bad=1
    for(i=1;i<=31;i++){ c=substr(CC,i,1); if(index(s,c)||index(w,c)){bad=1;break} }
}
END{ exit(bad||n!=N?1:0) }' "$PAIRS_TMP" 2>/dev/null \
    || mp_fail "pares invalidos (srce vacio, wrds invalido o count incorrecto)"

# --- escribir pack (plantilla canonica v2) ------------------------------------
# Escape JSON minimo: los pares ya excluyen controles C0 y llaves; solo
# quedan backslash y comillas. Salida byte-identica a tests/mkpack.py
# (json.dumps indent=2): lo verifica el cross-check T9.
mp_jesc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
mkdir -p "$(dirname "$OUT")" || mp_fail "no se pudo crear $(dirname "$OUT")"
OUT_TMP="$(mktemp "$(dirname "$OUT")/.lp_out.XXXXXX" 2>/dev/null || echo "${TMPDIR:-/tmp}/mp_out.XXXXXX")" || exit 1
{
printf '{\n'
printf '  "format": "%s",\n' "$LP_FORMAT_V2"
printf '  "topic_id": "%s",\n' "$(mp_jesc "$TOPIC_ID")"
printf '  "topic_name": "%s",\n' "$(mp_jesc "$TOPIC_NAME")"
printf '  "target_lang": "%s",\n' "$TLNG"
printf '  "source_lang": "%s",\n' "$SLNG"
printf '  "pack_version": %s,\n' "$PACK_VERSION"
[ -n "$TOPIC_VERSION" ] && printf '  "topic_version": "%s",\n' "$(mp_jesc "$TOPIC_VERSION")"
printf '  "count": %s,\n' "$COUNT"
printf '  "topic_hash": "%s",\n' "$TOPIC_HASH"
printf '  "items": [\n'
_mp_first=1
while IFS='	' read -r _s _w; do
    [ "$_mp_first" = "1" ] || printf ',\n'
    _mp_first=0
    printf '    {\n      "srce": "%s"' "$(mp_jesc "$_s")"
    [ -n "$_w" ] && printf ',\n      "wrds": "%s"' "$(mp_jesc "$_w")"
    printf '\n    }'
done <"$PAIRS_TMP"
printf '\n  ]\n}\n'
} >"$OUT_TMP" || mp_fail "no se pudo escribir el pack"
lp_validate "$OUT_TMP" "$TLNG" "$SLNG" "$TOPIC_ID" \
    || mp_fail "pack final rechazado por lp_validate"

# Self-test: el pack debe instalarse en una COPIA del topic sin tocarlo.
if [ "$SELF_TEST" = "1" ]; then
    ST="$(mktemp -d "${TMPDIR:-/tmp}/mp_self.XXXXXX")" || exit 1
    cp -f "$DATA" "$ST/data" && cp -f "$TPCDB" "$ST/tpc" || { rm -rf "$ST"; mp_fail "self-test: copia"; }
    mkdir -p "$ST/translations"
    [ -f "$CONF_DIR/translations/active" ] && cp -f "$CONF_DIR/translations/active" "$ST/translations/active"
    ( DC_tlt="$ST" lp_install "$OUT_TMP" "$TOPIC" "$(lp_lang_name "$SOURCE")" ) 2>/dev/null \
        || { rm -rf "$ST" "$OUT_TMP"; mp_fail "self-test: lp_install rechazo el pack"; }
    rm -rf "$ST"
fi

mv -f "$OUT_TMP" "$OUT"
[ -f "$OUT" ] || mp_fail "no se pudo escribir $OUT"
rm -f "$ITEMS_TMP" "$PAIRS_TMP"
SZ="$(wc -c < "$OUT")"
mp_log "pack ok: $OUT (topic=$TOPIC_ID count=$COUNT hash=${TOPIC_HASH:0:12}... bytes=$SZ)"
