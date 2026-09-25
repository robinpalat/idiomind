#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# =============================================================================
# Idiomind — lfetch (Language Fetcher, cliente de Language Packs)
# =============================================================================
# Proposito:
#   Cuando el source language del topic (slngtopic) != source configurado por
#   el usuario (slng), intentar obtener un Language Pack remoto estatico por
#   HTTPS antes de recurrir al fallback existente (tls.sh translate_to ->
#   Google Translate). El pack es SOLO datos (JSON), nunca se ejecuta.
#
#   localizar / descargar / validar / cachear / instalar / fallback.
#
# Contrato:
#   lp_try <topic_name> <tlng_display_ou_code> <slng_usuario> <slng_topic>
#     return 0 si el pack se instalo correctamente.
#     return != 0 en CUALQUIER otro caso -> el llamador DEBE usar el fallback
#     actual sin bloquear el topic. Nunca hace exit del proceso llamador
#     con codigo fatal; solo retorna.
#
#   Caso A (slng_usuario == slng_topic): retorna 2 (nada que hacer, sin red).
#
# 100 % Bash: ningun interprete externo de scripting. El parsing JSON se hace
# con el parser JSON1 de sqlite3 (dependencia declarada de Idiomind); jq u
# otras herramientas NO son dependencias y no se utilizan. Si sqlite3 (o su
# JSON1) no esta disponible, toda validacion falla y se usa el fallback.
#
# No contiene logica pedagogica ni de traduccion. No modifica el formato
# .idmnd ni el algoritmo de traduccion existente.
# =============================================================================

# --- configuracion -----------------------------------------------------------
: "${IDMND_LP_BASE:=https://idiomind.sourceforge.io/share/language-packs}"
: "${IDMND_LP_TIMEOUT:=15}"
: "${IDMND_LP_MAXBYTES:=524288}"
: "${IDMND_LP_MAXITEMS:=500}"
# Solo para tests locales: permite http:// o file:// como base.
: "${IDMND_LP_ALLOW_INSECURE:=0}"

# Formatos comprendidos por este cliente. Un formato desconocido se rechaza
# y el llamador usa el fallback existente.
LP_FORMAT_V1="idiomind-language-pack/1"
LP_FORMAT_V2="idiomind-language-pack/2"

lp_log() { printf 'language-pack: %s\n' "$*" >&2; }

# Notificacion de escritorio al instalar un pack descargado de la red
# (no en cache: eso no es una descarga). Silenciosa si no hay notify-send
# o si IDMND_LP_NOTIFY=0 (tests headless). Nunca bloquea ni falla el flujo.
lp_notify() {
    [ "${IDMND_LP_NOTIFY:-1}" = "0" ] && return 0
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send -i idiomind "Idiomind" "$1" -t 8000 2>/dev/null &
}

# --- normalizacion de idiomas ------------------------------------------------
# Acepta nombre visible ("Español", "Italiano", "English") o codigo ("es").
# Devuelve codigo ISO en minusculas (es, it, en, pt, fr, de, ja, zh-cn, ru...).
lp_lang_code() {
    local raw="$1"
    local low
    low="$(printf '%s' "$raw" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')"
    case "$low" in
        es|espanol|español) printf 'es' ;;
        it|italiano) printf 'it' ;;
        en|english|ingles|inglés) printf 'en' ;;
        pt|portugues|portugués|portuguese) printf 'pt' ;;
        fr|frances|francés|french|français) printf 'fr' ;;
        de|aleman|alemán|german|deutsch) printf 'de' ;;
        ja|japones|japonés|japanese) printf 'ja' ;;
        zh-cn|zh_cn|chinese|chino) printf 'zh-cn' ;;
        ru|ruso|russian) printf 'ru' ;;
        vi|vietnamita|vietnamese) printf 'vi' ;;
        *) printf '%s' "$low" ;;
    esac
}

# Nombre visible canonico para almacenar en translations/active y DB.
lp_lang_name() {
    case "$(lp_lang_code "$1")" in
        es) printf 'Español' ;;
        it) printf 'Italiano' ;;
        en) printf 'English' ;;
        pt) printf 'Português' ;;
        fr) printf 'Français' ;;
        de) printf 'Deutsch' ;;
        *) printf '%s' "$1" ;;
    esac
}

# --- identificacion del topic ------------------------------------------------
lp_sanitize_id() {
    printf '%s' "$1" \
        | iconv -c -f utf8 -t ascii 2>/dev/null \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9][^a-z0-9]*/-/g;s/^-//;s/-$//' \
        | cut -c1-80
}

# Prefiere el ilnk estable de la DB del topic; si no existe, deriva del nombre.
lp_topic_id() {
    local topic="$1" tid=""
    if [ -n "${DC_tlt:-}" ] && [ -f "${DC_tlt}/tpc" ]; then
        tid="$(sqlite3 "${DC_tlt}/tpc" "select ilnk from id;" 2>/dev/null | head -n1)"
    fi
    if [ -z "$tid" ] && [ -n "${DM_tl:-}" ] && [ -f "$DM_tl/$topic/.conf/tpc" ]; then
        tid="$(sqlite3 "$DM_tl/$topic/.conf/tpc" "select ilnk from id;" 2>/dev/null | head -n1)"
    fi
    if [ -n "$tid" ]; then
        printf '%s' "$tid"
    else
        lp_sanitize_id "$topic"
    fi
}

# --- rutas y URLs ------------------------------------------------------------
lp_base() {
    local b="${IDMND_LP_BASE}"
    b="${b%/}"
    printf '%s' "$b"
}

lp_cache_root() {
    if [ -n "${IDMND_LP_CACHE:-}" ]; then
        printf '%s' "$IDMND_LP_CACHE"
    elif [ -n "${DM_tls:-}" ]; then
        printf '%s/language-packs' "$DM_tls"
    elif [ -n "${DM_tl:-}" ]; then
        printf '%s/.share/language-packs' "$DM_tl"
    else
        printf '%s/.idiomind/language-packs' "${HOME:-/tmp}"
    fi
}

lp_pack_rel() { printf '%s/%s/%s.json' "$1" "$2" "$3"; }

lp_pack_url() {
    printf '%s/%s' "$(lp_base)" "$(lp_pack_rel "$1" "$2" "$3")"
}

lp_cache_file() {
    printf '%s/%s' "$(lp_cache_root)" "$(lp_pack_rel "$1" "$2" "$3")"
}

# --- red ---------------------------------------------------------------------
lp_is_https() { case "$1" in https://*) return 0 ;; *) return 1 ;; esac; }

lp_download() {
    local url="$1" dest="$2"
    if ! lp_is_https "$url" && [ "$IDMND_LP_ALLOW_INSECURE" != "1" ]; then
        lp_log "rechazado (no HTTPS): $url"
        return 1
    fi
    # Soporte file:// solo para tests locales con ALLOW_INSECURE=1.
    case "$url" in
        file://*)
            [ "$IDMND_LP_ALLOW_INSECURE" = "1" ] || return 1
            local src="${url#file://}"
            [ -f "$src" ] || return 1
            local sz
            sz="$(wc -c < "$src" 2>/dev/null)" || return 1
            if [ "$sz" -gt "$IDMND_LP_MAXBYTES" ] || [ "$sz" -lt 10 ]; then
                return 1
            fi
            cp -f "$src" "$dest" || return 1
            return 0
            ;;
    esac
    if ! command -v curl >/dev/null 2>&1; then
        lp_log "curl no disponible"
        return 1
    fi
    local extra=()
    if lp_is_https "$url"; then
        extra+=(--proto "=https" --tlsv1.2)
    fi
    if ! curl -fsSL "${extra[@]}" \
        --max-time "$IDMND_LP_TIMEOUT" \
        --max-filesize "$IDMND_LP_MAXBYTES" \
        -o "$dest" "$url"; then
        return 1
    fi
    # Defensa en profundidad: re-verificar tamaño real.
    local sz
    sz="$(wc -c < "$dest" 2>/dev/null)" || return 1
    if [ "$sz" -gt "$IDMND_LP_MAXBYTES" ] || [ "$sz" -lt 10 ]; then
        return 1
    fi
    return 0
}

# --- JSON via sqlite3 (sin Python) --------------------------------------------
# sqlite3 es dependencia declarada de Idiomind e incluye el parser JSON1
# (json_valid, json_type, json_tree, json_each, json_extract). TODO el
# parsing JSON del cliente pasa por aqui; jq NO es dependencia y no se usa.
# Cualquier error de sqlite3 -> validacion fallida -> fallback (fail closed).
#
# El contenido del pack se incrusta en el SQL con ' duplicado (estilo cdb) y
# se entrega por stdin (herestring): asi no aplica el limite MAX_ARG_STRLEN
# (128 KiB por argumento argv) y packs de hasta IDMND_LP_MAXBYTES pasan
# intactos. NO se usan regex ingenuas sobre el JSON crudo: la estructura la
# valida el parser (rutas exactas) y los valores se extraen ya decodificados
# (comillas escapadas, backslashes y Unicode los resuelve JSON1).

_lp_have_json() {
    command -v sqlite3 >/dev/null 2>&1 || return 1
    [ "$(sqlite3 :memory: "SELECT json_valid('{\"a\":1}');" 2>/dev/null)" = "1" ] || return 1
}

# Escapa un valor para literal SQL '...'.
_lp_sq() { printf '%s' "$1" | sed "s/'/''/g"; }

# --- validacion (solo datos, nunca exec) -------------------------------------
# Acepta formato v1 (items con trgt) y v2 (posicional + topic_hash).
# v2 exige ADEMAS en instalacion: count == lineas locales y
# topic_hash == hash local (ver lp_install). Aqui se valida estructura.
lp_validate() {
    local pack="$1" want_tlng="$2" want_slng="$3" want_topic="$4"
    [ -f "$pack" ] || return 1
    local size
    size="$(wc -c <"$pack" 2>/dev/null)" || return 1
    [ "$size" -ge 10 ] && [ "$size" -le "$IDMND_LP_MAXBYTES" ] || return 1
    _lp_have_json || return 1
    local C SEP
    C="$(_lp_sq "$(cat "$pack")")" || return 1
    SEP="$(printf '\001')"

    # Q0: JSON valido y raiz objeto.
    local root
    root="$(sqlite3 :memory: <<<"SELECT json_valid('$C'), json_type('$C');" 2>/dev/null)" || return 1
    [ "$root" = "1|object" ] || return 1

    # Q1: scan de caracteres peligrosos en valores textuales y en claves.
    # Valores: sin controles ni llaves (asi el separado \x01 posterior es
    # seguro y el parser trgt{}/srce{}/wrds{} del instalador tambien).
    # Claves: solo [A-Za-z_][A-Za-z0-9_]* (cualquier otra clave -> rechazo).
    local dang
    dang="$(sqlite3 :memory: <<<"SELECT count(*) FROM json_tree('$C') WHERE (type='text' AND (value LIKE '%'||char(10)||'%' OR value LIKE '%'||char(9)||'%' OR value LIKE '%'||char(13)||'%' OR value LIKE '%'||char(1)||'%' OR value LIKE '%{%' OR value LIKE '%}%')) OR (typeof(key)='text' AND key NOT GLOB '[A-Za-z_][A-Za-z0-9_]*');" 2>/dev/null)" || return 1
    [ "$dang" = "0" ] || return 1

    # Q2: escalares top-level en una sola consulta. Los tipos se verifican
    # contra el arbol (Q3); aqui solo valores, separados con \x01 (ausente
    # en valores por Q1 y no es IFS-whitespace: read conserva los vacios).
    local top fmt tid tl sl pv cnt th
    top="$(sqlite3 -separator "$SEP" :memory: <<<"SELECT json_extract('$C','\$.format'), json_extract('$C','\$.topic_id'), json_extract('$C','\$.target_lang'), json_extract('$C','\$.source_lang'), json_extract('$C','\$.pack_version'), json_extract('$C','\$.count'), json_extract('$C','\$.topic_hash');" 2>/dev/null)" || return 1
    IFS="$SEP" read -r fmt tid tl sl pv cnt th <<<"$top"
    { [ "$fmt" = "$LP_FORMAT_V1" ] || [ "$fmt" = "$LP_FORMAT_V2" ]; } || return 1
    [ "$(printf '%s' "$tl" | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$want_tlng" | tr '[:upper:]' '[:lower:]')" ] || return 1
    [ "$(printf '%s' "$sl" | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$want_slng" | tr '[:upper:]' '[:lower:]')" ] || return 1
    # topic_id flexible: acepta ilnk exacto o nombre saneado (retrocompat).
    [ "$tid" = "$want_topic" ] || return 1
    [[ "$pv" =~ ^[0-9]+$ ]] && [ "$pv" -ge 1 ] && [ "$pv" -le 9999 ] || return 1

    # Q3: estructura exacta del arbol. Las comillas de fullkey se quitan
    # (las claves ya estan restringidas por Q1, asi que no hay ambiguedad
    # salvo colision deliberada, que se rechaza como ruta duplicada).
    local tree fk ty
    tree="$(sqlite3 -separator "$SEP" :memory: <<<"SELECT fullkey, type FROM json_tree('$C');" 2>/dev/null)" || return 1
    tree="$(tr -d '"' <<<"$tree")" || return 1
    local -A _topseen=() _pathseen=() _ikeys=()
    local is_v2=0 n_obj=0
    [ "$fmt" = "$LP_FORMAT_V2" ] && is_v2=1
    while IFS="$SEP" read -r fk ty; do
        [ -n "$fk" ] || return 1
        if [ -n "${_pathseen[$fk]:-}" ]; then return 1; fi  # ruta duplicada
        _pathseen[$fk]=1
        case "$fk" in
            '$') [ "$ty" = "object" ] || return 1 ;;
            '$.format'|'$.topic_id'|'$.target_lang'|'$.source_lang')
                [ "$ty" = "text" ] || return 1
                _topseen["$fk"]=1 ;;
            '$.pack_version')
                [ "$ty" = "integer" ] || return 1
                _topseen["$fk"]=1 ;;
            '$.topic_name'|'$.topic_version')
                [ "$ty" = "text" ] || return 1
                _topseen["$fk"]=1 ;;
            '$.count'|'$.topic_hash')
                [ "$is_v2" = 1 ] || return 1
                if [ "$fk" = '$.count' ]; then [ "$ty" = "integer" ] || return 1
                else [ "$ty" = "text" ] || return 1; fi
                _topseen["$fk"]=1 ;;
            '$.items')
                [ "$ty" = "array" ] || return 1
                _topseen["$fk"]=1 ;;
            '$.items['*']')
                local idx="${fk#\$.items[}"; idx="${idx%\]}"
                [[ "$idx" =~ ^[0-9]+$ ]] || return 1
                [ "$ty" = "object" ] || return 1
                _ikeys["$idx"]=1
                n_obj=$((n_obj+1)) ;;
            '$.items['*']'.*)
                local rest="${fk#\$.items[}"
                local idx="${rest%%\]*}"
                local kn="${rest#*\].}"
                [[ "$idx" =~ ^[0-9]+$ ]] || return 1
                case "$kn" in srce|wrds|trgt) ;; *) return 1 ;; esac
                if [ "$is_v2" = 1 ] && [ "$kn" = "trgt" ]; then return 1; fi
                [ "$ty" = "text" ] || return 1
                _ikeys["$idx"]=1 ;;
            *) return 1 ;;
        esac
    done <<<"$tree"
    for k in format topic_id target_lang source_lang pack_version items; do
        [ -n "${_topseen[\$.$k]:-}" ] || return 1
    done
    if [ "$is_v2" = 1 ]; then
        for k in count topic_hash; do
            [ -n "${_topseen[\$.$k]:-}" ] || return 1
        done
        [[ "$cnt" =~ ^[0-9]+$ ]] && [ "$cnt" -ge 1 ] && [ "$cnt" -le "$IDMND_LP_MAXITEMS" ] || return 1
        [[ "$th" =~ ^[0-9a-f]{64}$ ]] || return 1
    fi
    # Indices contiguos 0..n-1 (n = objetos items[i] vistos).
    local n="$n_obj" i
    [ "$n" -ge 1 ] && [ "$n" -le "$IDMND_LP_MAXITEMS" ] || return 1
    if [ "$is_v2" = 1 ]; then
        [ "$n" = "$cnt" ] || return 1
    fi
    for ((i=0; i<n; i++)); do
        [ -n "${_ikeys[$i]:-}" ] || return 1
    done
    # Claves requeridas por item: v1=trgt, v2=srce.
    local p
    if [ "$is_v2" = 1 ]; then p="srce"; else p="trgt"; fi
    for ((i=0; i<n; i++)); do
        [ -n "${_pathseen[\$.items[$i].$p]:-}" ] || return 1
    done

    # Q4: valores de items ordenados (separador \x01; un sqlite por pack).
    local items t s w wt rown
    items="$(sqlite3 -separator "$SEP" :memory: <<<"SELECT json_extract('$C','\$.items['||key||'].trgt'), json_extract('$C','\$.items['||key||'].srce'), json_extract('$C','\$.items['||key||'].wrds'), typeof(json_extract('$C','\$.items['||key||'].wrds')) FROM json_each('$C','\$.items') ORDER BY key+0;" 2>/dev/null)" || return 1
    rown="$(grep -c . <<<"$items")" || return 1
    [ "$rown" = "$n" ] || return 1
    while IFS="$SEP" read -r t s w wt; do
        if [ "$is_v2" = 1 ]; then
            [ -z "$t" ] || return 1
        else
            [ -n "$t" ] || return 1
            [ "${#t}" -le 500 ] || return 1
        fi
        [ "${#s}" -le 500 ] || return 1
        [ "${#w}" -le 2000 ] || return 1
        { [ "$wt" = "text" ] || [ "$wt" = "null" ] || [ -z "$wt" ]; } || return 1
    done <<<"$items"
    # Sin caracteres de control C0 restantes en los valores volcados.
    if LC_ALL=C grep -q "$(printf '[\002-\010\013\014\016-\037]')" <<<"$top"$'\n'"$items" 2>/dev/null; then
        return 1
    fi
    return 0
}

lp_sha256_ok() {
    local file="$1" expect="$2"
    [ -n "$expect" ] || return 0
    command -v sha256sum >/dev/null 2>&1 || return 1
    local got
    got="$(sha256sum "$file" | cut -d' ' -f1)" || return 1
    [ "$got" = "$expect" ]
}

# --- instalacion ---------------------------------------------------------------
# v1: reemplaza srce{}/wrds{} por clave trgt{} (el pack trae el texto).
# v2: mapeo posicional items[i] -> linea i del data, SOLO si
#     count == lineas locales y topic_hash == hash local de trgt.
# En ambos casos se preserva trgt, exmp, defn, grmr, etc. y se actualiza
# unicamente srce/wrds en el archivo data y en SQLite (datos, nunca codigo).
# grmr NO viaja en el pack: depende solo del target y se reutiliza el local.
lp_install() {
    local pack="$1" topic="$2" new_slng_name="$3"
    local conf_dir data_file tpcdb active_old
    if [ -n "${DC_tlt:-}" ] && [ -d "$DC_tlt" ]; then
        conf_dir="$DC_tlt"
    elif [ -n "${DM_tl:-}" ] && [ -d "$DM_tl/$topic/.conf" ]; then
        conf_dir="$DM_tl/$topic/.conf"
    else
        return 1
    fi
    data_file="$conf_dir/data"
    tpcdb="$conf_dir/tpc"
    [ -f "$data_file" ] && [ -f "$tpcdb" ] || return 1

    active_old=""
    [ -f "$conf_dir/translations/active" ] && active_old="$(sed -n 1p "$conf_dir/translations/active")"
    mkdir -p "$conf_dir/translations"

    # Defensa en profundidad: revalidar formato (el llamador ya valido).
    # Instalacion con awk (reemplazo 1:1 de la semantica anterior):
    #  - v1: mapa trgt->(srce,wrds); segmentos srce{}/wrds{} hasta el primer
    #    '}' (igual que [^}]*); wrds solo si presente y no vacio.
    #  - v2: posicional items[i] -> linea i (no vacia); exige count y hash.
    _lp_have_json || { rm -f "$data_file.lp_new"; return 1; }
    local C fmt SEP mapf sqlf
    SEP="$(printf '\001')"
    C="$(_lp_sq "$(cat "$pack")")" || { rm -f "$data_file.lp_new"; return 1; }
    fmt="$(sqlite3 :memory: <<<"SELECT json_extract('$C','\$.format');" 2>/dev/null)" \
        || { rm -f "$data_file.lp_new"; return 1; }
    { [ "$fmt" = "$LP_FORMAT_V1" ] || [ "$fmt" = "$LP_FORMAT_V2" ]; } \
        || { rm -f "$data_file.lp_new"; return 1; }
    mapf="$(mktemp "${TMPDIR:-/tmp}/lp_map.XXXXXX")" || return 1
    sqlf="$(mktemp "${TMPDIR:-/tmp}/lp_sql.XXXXXX")" || { rm -f "$mapf"; return 1; }
    # Limpieza autodestructiva: se dispara al retornar y se desarma sola para
    # no filtrarse a las funciones del llamador (p. ej. make_pack con set -u).
    trap 'rm -f "$mapf" "$sqlf"; trap - RETURN' RETURN
    local items_tsv n
    if [ "$fmt" = "$LP_FORMAT_V1" ]; then
        items_tsv="$(sqlite3 -separator "$SEP" :memory: <<<"SELECT json_extract('$C','\$.items['||key||'].trgt'), json_extract('$C','\$.items['||key||'].srce'), json_extract('$C','\$.items['||key||'].wrds'), typeof(json_extract('$C','\$.items['||key||'].wrds')) FROM json_each('$C','\$.items') ORDER BY key+0;" 2>/dev/null)" || return 1
        n="$(grep -c . <<<"$items_tsv")" || return 1
        [ "$n" -ge 1 ] || return 1
        printf '%s\n' "$items_tsv" >"$mapf"
        if ! awk -v FS="$SEP" '
NR==FNR { s[$1]=$2; w[$1]=$3; wt[$1]=$4; next }
{
  line=$0
  if (line ~ /^[ \t]*$/) { print line; next }
  ti=index(line,"trgt{"); if (ti==0) { print line; next }
  rest=substr(line,ti+5); tj=index(rest,"}")
  if (tj==0) { print line; next }
  t=substr(rest,1,tj-1)
  if (!(t in s)) { print line; next }
  matched++
  si=index(line,"srce{")
  if (si>0) {
    srest=substr(line,si+5); sj=index(srest,"}")
    if (sj>0) line=substr(line,1,si+4) s[t] substr(srest,sj)
  }
  if (wt[t]=="text" && w[t]!="") {
    wi=index(line,"wrds{")
    if (wi>0) {
      wrest=substr(line,wi+5); wj=index(wrest,"}")
      if (wj>0) line=substr(line,1,wi+4) w[t] substr(wrest,wj)
    } else line=line "wrds{" w[t] "}"
  }
  print line
}
END{ exit(matched>0?0:1) }' "$mapf" "$data_file" >"$data_file.lp_new" 2>/dev/null; then
            rm -f "$data_file.lp_new"; return 1
        fi
        { printf 'BEGIN;\n'
          while IFS="$SEP" read -r t s w wt; do
              if [ "$wt" = "text" ] && [ -n "$w" ]; then
                  printf "UPDATE Data SET srce='%s',wrds='%s' WHERE trgt='%s';\n" \
                      "$(_lp_sq "$s")" "$(_lp_sq "$w")" "$(_lp_sq "$t")"
              else
                  printf "UPDATE Data SET srce='%s' WHERE trgt='%s';\n" \
                      "$(_lp_sq "$s")" "$(_lp_sq "$t")"
              fi
          done <"$mapf"
          printf 'COMMIT;\n'; } >"$sqlf"
        sqlite3 "$tpcdb" <"$sqlf" >/dev/null 2>&1 \
            || { rm -f "$data_file.lp_new"; return 1; }
    else
        # v2: vinculacion de contenido estricta (count + hash + orden).
        local lh_out lh lc pack_cnt pack_th
        lh_out="$(lp_topic_hash "$data_file")" || { rm -f "$data_file.lp_new"; return 1; }
        lh="$(sed -n 1p <<<"$lh_out")"; lc="$(sed -n 2p <<<"$lh_out")"
        pack_cnt="$(sqlite3 :memory: <<<"SELECT json_extract('$C','\$.count');" 2>/dev/null)" \
            || { rm -f "$data_file.lp_new"; return 1; }
        pack_th="$(sqlite3 :memory: <<<"SELECT json_extract('$C','\$.topic_hash');" 2>/dev/null)" \
            || { rm -f "$data_file.lp_new"; return 1; }
        [ "$pack_cnt" = "$lc" ] || { rm -f "$data_file.lp_new"; return 1; }
        [ "$pack_th" = "$lh" ] || { rm -f "$data_file.lp_new"; return 1; }
        items_tsv="$(sqlite3 -separator "$SEP" :memory: <<<"SELECT json_extract('$C','\$.items['||key||'].srce'), json_extract('$C','\$.items['||key||'].wrds'), typeof(json_extract('$C','\$.items['||key||'].wrds')) FROM json_each('$C','\$.items') ORDER BY key+0;" 2>/dev/null)" || { rm -f "$data_file.lp_new"; return 1; }
        n="$(grep -c . <<<"$items_tsv")" || { rm -f "$data_file.lp_new"; return 1; }
        [ "$n" = "$lc" ] || { rm -f "$data_file.lp_new"; return 1; }
        printf '%s\n' "$items_tsv" >"$mapf"
        if ! awk -v FS="$SEP" '
NR==FNR { n++; s[n]=$1; w[n]=$2; wt[n]=$3; next }
{
  if ($0 ~ /^[ \t]*$/) next
  c++
  line=$0
  si=index(line,"srce{")
  if (si>0) {
    srest=substr(line,si+5); sj=index(srest,"}")
    if (sj>0) line=substr(line,1,si+4) s[c] substr(srest,sj)
  }
  if (wt[c]=="text" && w[c]!="") {
    wi=index(line,"wrds{")
    if (wi>0) {
      wrest=substr(line,wi+5); wj=index(wrest,"}")
      if (wj>0) line=substr(line,1,wi+4) w[c] substr(wrest,wj)
    } else line=line "wrds{" w[c] "}"
  }
  print line
}
END{ exit(c==n && c>0?0:1) }' "$mapf" "$data_file" >"$data_file.lp_new" 2>/dev/null; then
            rm -f "$data_file.lp_new"; return 1
        fi
        # DB y archivo deben coincidir (misma secuencia trgt); si divergen,
        # no instalar a medias (check_index repara).
        local dblist fllist rids
        dblist="$(sqlite3 "$tpcdb" "SELECT trgt FROM Data ORDER BY rowid;" 2>/dev/null)" \
            || { rm -f "$data_file.lp_new"; return 1; }
        fllist="$(sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' "$data_file" 2>/dev/null)" \
            || { rm -f "$data_file.lp_new"; return 1; }
        [ "$dblist" = "$fllist" ] || { rm -f "$data_file.lp_new"; return 1; }
        rids="$(sqlite3 "$tpcdb" "SELECT rowid FROM Data ORDER BY rowid;" 2>/dev/null)" \
            || { rm -f "$data_file.lp_new"; return 1; }
        [ "$(grep -c . <<<"$rids")" = "$n" ] || { rm -f "$data_file.lp_new"; return 1; }
        { printf 'BEGIN;\n'
          paste -d"$SEP" <(printf '%s\n' "$items_tsv") <(printf '%s\n' "$rids") \
          | while IFS="$SEP" read -r s w wt rid; do
              if [ "$wt" = "text" ] && [ -n "$w" ]; then
                  printf "UPDATE Data SET srce='%s',wrds='%s' WHERE rowid=%s;\n" \
                      "$(_lp_sq "$s")" "$(_lp_sq "$w")" "$rid"
              else
                  printf "UPDATE Data SET srce='%s' WHERE rowid=%s;\n" \
                      "$(_lp_sq "$s")" "$rid"
              fi
          done
          printf 'COMMIT;\n'; } >"$sqlf"
        sqlite3 "$tpcdb" <"$sqlf" >/dev/null 2>&1 \
            || { rm -f "$data_file.lp_new"; return 1; }
    fi
    [ -f "$data_file.lp_new" ] || return 1

    # Backup del data anterior estilo fallback (.bk) y activacion.
    if [ -n "$active_old" ]; then
        cp -f "$data_file" "$conf_dir/translations/$active_old.bk" 2>/dev/null || true
    fi
    mv -f "$data_file.lp_new" "$data_file"
    printf '%s\n' "$new_slng_name" > "$conf_dir/translations/active"
    rm -f "$conf_dir/slng_err" "$conf_dir/slng_err.bk"
    # Reconstruir indice de la vista (no-op si tls.sh no disponible en tests).
    if [ -n "${DS:-}" ] && [ -x "$DS/ifs/tls.sh" ]; then
        "$DS/ifs/tls.sh" colorize 1 >/dev/null 2>&1 || true
    fi
    return 0
}

# Hash canonico del contenido target de un data file: sha256 de los trgt{}
# no vacios en orden de archivo, unidos por "\n" (UTF-8). Define la
# vinculacion de contenido del formato v2. Mismo algoritmo debe usar el
# generador de packs.
# Extraccion con sed hasta el primer '}' (igual que [^}]*); equivale al
# parser anterior porque los valores saneados de Idiomind nunca contienen
# '{' (los clean_* los eliminan), asi que solo hay un "trgt{" por linea.
lp_topic_hash() {
    local data="$1"
    [ -f "$data" ] || return 1
    command -v sha256sum >/dev/null 2>&1 || return 1
    local in_n out_n tmp h
    in_n="$(grep -c '[^[:space:]]' "$data" 2>/dev/null)" || return 1
    [ "$in_n" -ge 1 ] || return 1
    tmp="$(mktemp "${TMPDIR:-/tmp}/lp_hash.XXXXXX")" || return 1
    sed -n 's/.*trgt{\([^}]*\)}.*/\1/p' "$data" >"$tmp" 2>/dev/null \
        || { rm -f "$tmp"; return 1; }
    out_n="$(wc -l <"$tmp")" || { rm -f "$tmp"; return 1; }
    # Toda linea no vacia debe aportar un trgt{} (si no, topic corrupto).
    [ "$out_n" = "$in_n" ] || { rm -f "$tmp"; return 1; }
    h="$(awk 'NR>1{printf "\n"} {printf "%s",$0}' "$tmp" | sha256sum 2>/dev/null)" \
        || { rm -f "$tmp"; return 1; }
    h="$(cut -d' ' -f1 <<<"$h")"
    [ -n "$h" ] || { rm -f "$tmp"; return 1; }
    printf '%s\n%s\n' "$h" "$in_n"
    rm -f "$tmp"
}

# --- orquestador ---------------------------------------------------------------
lp_try() {
    local topic="${1:-}" tlng_raw="${2:-}" slng_user_raw="${3:-}" slng_topic_raw="${4:-}"
    [ -n "$topic" ] || return 1

    local tlng slng_user slng_topic topic_id new_name
    tlng="$(lp_lang_code "$tlng_raw")"
    slng_user="$(lp_lang_code "$slng_user_raw")"
    slng_topic="$(lp_lang_code "$slng_topic_raw")"
    [ -n "$tlng" ] && [ -n "$slng_user" ] && [ -n "$slng_topic" ] || return 1

    # Caso A: nada que hacer.
    if [ "$slng_user" = "$slng_topic" ]; then
        return 2
    fi

    topic_id="$(lp_topic_id "$topic")"
    [ -n "$topic_id" ] || return 1
    new_name="$(lp_lang_name "$slng_user_raw")"

    local url cache tmp
    url="$(lp_pack_url "$tlng" "$slng_user" "$topic_id")"
    cache="$(lp_cache_file "$tlng" "$slng_user" "$topic_id")"

    # Caso F: cache valida -> instalar sin red.
    if [ -f "$cache" ] && lp_validate "$cache" "$tlng" "$slng_user" "$topic_id"; then
        lp_log "cache hit $tlng/$slng_user/$topic_id"
        if lp_install "$cache" "$topic" "$new_name"; then
            return 0
        fi
        # Cache corrupta para instalacion: descartar y seguir a red/fallback.
        rm -f "$cache"
    fi

    tmp="$(mktemp "${TMPDIR:-/tmp}/lp.XXXXXX")" || return 1
    if ! lp_download "$url" "$tmp"; then
        rm -f "$tmp"
        return 1
    fi
    if ! lp_validate "$tmp" "$tlng" "$slng_user" "$topic_id"; then
        lp_log "pack invalido, se descarta"
        rm -f "$tmp"
        return 1
    fi
    mkdir -p "$(dirname "$cache")"
    cp -f "$tmp" "$cache"
    rm -f "$tmp"
    if ! lp_install "$cache" "$topic" "$new_name"; then
        return 1
    fi
    lp_log "pack instalado $tlng/$slng_user/$topic_id"
    lp_notify "Language pack instalado: ${topic} (${tlng} → ${new_name})"
    return 0
}

# Permite: bash lfetch.sh try <topic> <tlng> <slng_user> <slng_topic>
if [ "${0##*/}" = "lfetch.sh" ] && [ -n "$1" ]; then
    case "$1" in
        try) shift; lp_try "$@" ;;
        hash) shift; lp_topic_hash "$@" ;;
        code) shift; lp_lang_code "$@" ;;
        url) shift; lp_pack_url "$(lp_lang_code "${1:-}")" "$(lp_lang_code "${2:-}")" "${3:-}" ;;
        *) lp_log "uso: lfetch.sh try <topic> <tlng> <slng_user> <slng_topic>"; exit 1 ;;
    esac
fi
