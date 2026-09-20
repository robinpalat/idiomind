# Resource Addon — Developer Guide

## Purpose

The Resource addon provides a pluggable provider system for external services
that supply audio, translations, definitions, and images to Idiomind.

Users enable/disable individual providers through the GUI. The addon manages
API keys, tests provider availability, and handles automatic fallback.

## Architecture

```
Resource addon
├── common.sh              Shared utilities (error handling, config reading)
├── cnfg.sh                GUI for enabling/disabling providers
├── test.sh                Tests provider availability
├── provider_template.sh   Starting point for new providers
├── DEVELOPMENT.md         This file
└── scripts/               Provider implementations
    ├── Name.Type.Task.Language    (file naming convention)
    └── ...
```

Each provider script is self-contained. It declares metadata variables and
implements the logic for one specific service. The addon infrastructure
(cnfg.sh, test.sh, add.sh) reads these variables and invokes the scripts
through well-defined contracts.

## Resource Types and Consumption Patterns

Resource providers follow one of five consumption patterns. A new provider
must match exactly one pattern. The pattern determines how the script is
invoked and what it must export.

### Pattern A — Direct Execution

**Used by:** TTS Convert (OpenAI, Baidu, Festival, gttscli, SpanishDict),
Translator (Google translate), Image download (Openverse, Wiki commons)

**How it works:**
The script is executed directly with arguments. The caller checks the exit
status and the output file.

```
Caller executes:  "$script" "$input" "$output"
Script returns:   0 on success, non-zero on failure
Script creates:   Audio/image file at $output
```

**Variables read after execution:** None (all communication is through
arguments, exit status, and side effects).

**Reference:** `OpenAI.TTS online.Convert text to audio.various`

### Pattern B — Source + Exported Variables (URL-based)

**Used by:** TTS Download (Cambridge, Gstaticcom, Macmillandictionary,
Merriamwebster, Oxforddictionaries, SpanishDict Download, Vocabolaudio,
Vocabulix, Yandex Search)

**How it works:**
The script is sourced (not executed). It exports variables that the caller
uses to perform a wget download.

```
Caller sources:   source "$script"
Script exports:   URL (download URL), EX (extension), TESTURL (test URL)
Caller does:      wget -O "$output.$EX" "$URL"
```

**Variables the caller reads:** `URL`, `EX`, `TESTURL`, `EXECUT`

**Reference:** `Gstaticcom.TTS online.Download audio.en`

### Pattern C — Source + Internal Config + URL Export

**Used by:** TTS Convert/Download (Voicerss, Ispeech)

**How it works:**
Same as Pattern B, but the script internally reads its own .cfg file,
validates credentials, and constructs URLs with embedded API keys.

```
Caller sources:   source "$script"
Script does:      Reads FILECONF, validates key, exports URL with key embedded
Caller does:      wget -O "$output.$EX" "$URL"
```

**Variables the caller reads:** `URL`, `EX`, `TESTURL`, `EXECUT`

**Reference:** `Ispeech.TTS online.Convert text to audio.various`

### Pattern D — Source + EXECUT Export + Execution

**Used by:** TTS Convert/Download (Yandex)

**How it works:**
The script is sourced. It exports EXECUT as a string containing a full
command. The caller either executes this command or runs the script directly.

```
Caller sources:   source "$script"
Script exports:   EXECUT="curl -s -o \"\$2\" -X POST ..."
Caller does:      Executes the script with $1=text $2=output
                  The script's elif branch handles the actual request.
```

**Variables the caller reads:** `EXECUT`, `EX`, `TESTURL`

**Reference:** `Yandex translator.TTS online.Convert text to audio.various`

### Pattern E — Link Template + eval

**Used by:** Dictionary links (6 providers)

**How it works:**
The file is not a script. It contains a URL template with shell variable
interpolation. The caller reads the file and evaluates it with `eval`.

```
File contains:    http://glosbe.com/$lgt/$lgs/${query,,}
Caller does:      eval _url="$(< "$script_file")"
Available vars:   $query, $lgt, $lgs
```

**WARNING:** These templates are evaluated using `eval`. Do not introduce
new eval-based providers. Do not place arbitrary user-controlled shell
code in templates. The variables `$query`, `$lgt`, `$lgs` come from
internal Idiomind contexts, not from external network input.

**Reference:** `Glosbe.Link.Search definition.various`

## Common Interface Variables

Every provider script must declare these metadata variables. Their NAMES
must not change. Their VALUES are provider-specific.

| Variable | Purpose | Example |
|---|---|---|
| `TLANGS` | Supported language codes | `"en, es, it"` |
| `INFO` | Description for the resource list | `"Convert text to audio (online)"` |
| `LANGUAGES` | Human-readable language names | `"English, Spanish, Italian"` |
| `STATUS` | Initial status | `"Ok"` |
| `VOICES` | Available voices (display only) | `""` |
| `CONF` | Has configuration dialog? | `"TRUE"` or `"FALSE"` |
| `FILECONF` | Path to .cfg config file | `"$HOME/.config/idiomind/addons/resources/X.cfg"` |
| `CONFFIELDS` | Config form field names | `"key model voice"` |
| `CONFOPTS` | Dropdown options per field | `"model\|tts-1!tts-1-hd"` |
| `CONFKEY_HIDDEN` | Password-masked fields | `"key"` |
| `TESTSTRING` | Text for TTS testing | `"This is a test"` |
| `TESTWORD` | Word for image testing | `"cat"` |
| `EXECUT` | Required binary (empty = URL-based) | `"curl"` |
| `EX` | Output file extension | `"mp3"` |

These additional variables are exported by URL-based providers (Patterns B, C):

| Variable | Purpose |
|---|---|
| `URL` | Download URL (may contain `$word` for word-based providers) |
| `TESTURL` | URL used for testing |

## Configuration Files (.cfg)

Providers with `CONF="TRUE"` store their configuration in .cfg files.
The format is:

```
field="value"
```

For example, `OpenAI.cfg` might contain:

```
key="sk-abc123..."
model="tts-1"
voice="alloy"
```

**Reading config:** Use `resource_read_config` from common.sh:

```bash
source "$(dirname "$(readlink -f "$0")")/common.sh" 2>/dev/null
api_key=$(resource_read_config "$FILECONF" "key")
```

**Do NOT use `source "$FILECONF"`** — this executes the file as shell code,
which is a security risk if the file contains unexpected content.

**Writing config:** Handled by cnfg.sh (the GUI). Do not write to .cfg
files from provider scripts.

## Error Handling

### Error Message Format

Errors are stored as HTML in `~/.config/idiomind/addons/resources/msgs/`:

```bash
resource_write_error \
    "<span color='#C15F27'>Error description</span>" \
    "$_msgs_dir" "${0##*/}"
```

### Error Categories

For auto-disable to work correctly (in test.sh), error messages should
contain recognizable keywords:

| Category | Keywords in message | Auto-disable? |
|---|---|---|
| Key/credential error | `key`, `credential` | Yes |
| Quota exhausted | `quota`, `credit`, `expired`, `inactive` | Yes |
| Service error | `unavailable`, `error` | No (temporary) |
| Connection error | `connection`, `timeout` | No (temporary) |

### Exit Status

| Code | Meaning |
|---|---|
| `0` | Success |
| non-zero | Failure (error message written to msgs/) |

### Common Error Patterns

```bash
# Missing API key
resource_write_error \
    "<span color='#C15F27'>No key configuration</span>" \
    "$_msgs_dir" "${0##*/}"
exit 1

# HTTP error
case "$_http_code" in
    200) ;;
    401) resource_write_error \
            "<span color='#C15F27'>API key invalid or expired</span>" \
            "$_msgs_dir" "${0##*/}"
         exit 1 ;;
    *)   resource_write_error \
            "<span color='#C15F27'>Connection error (HTTP $_http_code)</span>" \
            "$_msgs_dir" "${0##*/}"
         exit 1 ;;
esac

# Clear previous error on success
resource_clear_error "$_msgs_dir" "${0##*/}"
```

## How to Add a New Provider: Step by Step

### Example: Adding Azure Text-to-Speech

Suppose you want to add Azure TTS alongside the existing OpenAI TTS.

#### Step 1: Determine the resource type

Azure TTS converts text to audio. The resource type is:
`TTS online.Convert text to audio`

The language is `various` (Azure supports many languages).

The filename will be:
`Azure.TTS online.Convert text to audio.various`

#### Step 2: Copy the template

```bash
cp provider_template.sh "scripts/Azure.TTS online.Convert text to audio.various"
```

#### Step 3: Set the metadata

Edit the new file and set:

```bash
TLANGS="en, es, it, pt, de, ja, fr, zh-cn, ru"
INFO="Convert text to audio (online)
https://learn.microsoft.com/azure/ai-services/speech-service/"
LANGUAGES="English, Spanish, Italian, Portuguese, German, Japanese, French, Chinese, Russian"
STATUS="Ok"
VOICES=""
CONF="TRUE"
FILECONF="$HOME/.config/idiomind/addons/resources/Azure.cfg"
CONFFIELDS="key region voice"
CONFOPTS="voice|en-US-JennyNeural!en-US-GuyNeural!es-ES-ElviraNeural"
CONFKEY_HIDDEN="key"
TESTSTRING="This is a test"
TESTWORD=""
EXECUT="curl"
EX="mp3"
```

#### Step 4: Implement provider-specific configuration

Replace the PROVIDER_ENDPOINT and add any Azure-specific variables:

```bash
PROVIDER_ENDPOINT="https://{region}.tts.speech.microsoft.com/cognitiveservices/v1"
```

#### Step 5: Implement authentication

Azure uses an `Ocp-Apim-Subscription-Key` header. Modify `build_request()`:

```bash
build_request()
{
    local _text="$1" _region="$2" _voice="$3"

    local _endpoint="https://${_region}.tts.speech.microsoft.com/cognitiveservices/v1"

    _request_url="$_endpoint"
    _request_headers=(
        -H "Content-Type: application/json"
        -H "Ocp-Apim-Subscription-Key: $api_key"
    )

    local _ssml="<speak version='1.0' xml:lang='en-US'>
        <voice name='$_voice'>$_text</voice></speak>"
    _request_body="$_ssml"
}
```

#### Step 6: Implement the request

Modify `execute_request()` if Azure's response format differs. The basic
curl pattern is the same, but error codes and response parsing may differ.

#### Step 7: Implement language-specific logic

If your provider maps language codes differently (like Ispeech maps `en`
to `ukenglishmale`), add a mapping function. This stays inside your script,
not in common.sh:

```bash
get_azure_voice()
{
    local _lang="$1" _voice_param="$2"
    [ -n "$_voice_param" ] && { echo "$_voice_param"; return; }
    case "$_lang" in
        en)  echo "en-US-JennyNeural" ;;
        es)  echo "es-ES-ElviraNeural" ;;
        *)   echo "en-US-JennyNeural" ;;
    esac
}
```

#### Step 8: Create the config file

The user will configure Azure through the Resource GUI (double-click).
The .cfg file is created automatically. No action needed.

#### Step 9: Test

1. Open Idiomind → Resources
2. Find "Azure" in the list → enable it
3. Double-click to configure (enter API key, region, voice)
4. Click "Test" to verify

#### Step 10: Verify error handling

- Test with empty key → should show "No key configuration"
- Test with invalid key → should show "API key invalid or expired"
- Test with valid key → should produce audio

## Security Notes

### API Keys

- Never print API keys in error messages
- Never log API keys to files
- Store keys only in .cfg files under the user's config directory
- Read keys using `resource_read_config`, never using `source`

### eval

The Link templates (Pattern E) use `eval` to expand URL variables.
This is an existing design decision that cannot be changed without
breaking compatibility.

**Do not introduce new eval-based providers.**

The variables available to Link templates (`$query`, `$lgt`, `$lgs`)
come from internal Idiomind contexts, not from external network input.

### URL Construction

When building URLs with user-provided text, ensure proper encoding:

```bash
# Safe: use --data-urlencode with curl
curl -G --data-urlencode "text=$word" "https://api.example.com/"

# Safe: use jq for JSON bodies
data=$(jq -cn --arg t "$text" '{text:$t}')
```

Avoid constructing URLs by simple string concatenation with unencoded input.
