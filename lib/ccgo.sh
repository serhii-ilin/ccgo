
#!/usr/bin/env bash
#
# Claude Code + OpenCode Go
#
# Usage:
#   ccgo                  Default DeepSeek preset
#   ccgo deepseek         DeepSeek Pro + Flash
#   ccgo flash            DeepSeek Flash only
#   ccgo minimax          MiniMax M3 + M3.1 Flash
#   ccgo qwen             Qwen3.7 Plus
#   ccgo kimi             Kimi K3
#   ccgo haiku            Claude Haiku 5.5
#   ccgo custom           Interactive model selection
#   ccgo list             Show presets
#   ccgo --version        Print the version
#   ccgo models           List models live from the OpenCode Go API
#   ccgo glm-5.3          Use any model id from that list
#
# Pass additional arguments directly to Claude:
#   ccgo deepseek -p "Explain this project"
#   ccgo minimax --continue
#
# Install with install.sh or Homebrew (see README), or source this file from
# ~/.zshrc / ~/.bashrc to use ccgo as a shell function.
# The API key is read from OPENCODE_API_KEY (or prompted for); never hardcode it.

CCGO_VERSION="0.1.3"

# Live model catalog from the OpenCode Go API (public, no key needed).
# Cached for an hour; override with CCGO_MODELS_URL / CCGO_MODELS_TTL.
ccgo_models_json() {
    local url="${CCGO_MODELS_URL:-https://opencode.ai/inference/go/v1/models}"
    local ttl="${CCGO_MODELS_TTL:-3600}"
    local dir="${XDG_CACHE_HOME:-$HOME/.cache}/ccgo"
    local file="$dir/models.json"
    local now mtime tmp
    now=$(date +%s)
    mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo 0)
    if [ -s "$file" ] && [ $((now - mtime)) -lt "$ttl" ]; then
        cat "$file"
        return 0
    fi
    mkdir -p "$dir" 2>/dev/null
    tmp="$file.$$"
    if curl -fsS -m 8 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
        mv "$tmp" "$file"
        cat "$file"
        return 0
    fi
    rm -f "$tmp"
    # Fall back to a stale cache if the network is down.
    [ -s "$file" ] && { cat "$file"; return 0; }
    return 1
}

# Prints one line per chat model: id<TAB>context<TAB>tools(yes|no)<TAB>name
ccgo_models_tsv() {
    local json
    json=$(ccgo_models_json) || return 1
    if command -v jq >/dev/null 2>&1; then
        printf '%s' "$json" | jq -r '.data[] | select((.type // "chat") == "chat")
            | [.id, (.limit.context // 0), (if .capabilities.tools.supported then "yes" else "no" end), (.name // .id)] | @tsv'
    elif command -v python3 >/dev/null 2>&1; then
        printf '%s' "$json" | python3 -c '
import json, sys
for m in json.load(sys.stdin)["data"]:
    if m.get("type", "chat") != "chat":
        continue
    tools = "yes" if m.get("capabilities", {}).get("tools", {}).get("supported") else "no"
    print("\t".join([m["id"], str(m.get("limit", {}).get("context", 0)), tools, m.get("name", m["id"])]))'
    else
        return 1
    fi
}

ccgo_models() {
    local rows
    rows=$(ccgo_models_tsv) || { echo "Could not fetch model list from OpenCode Go." >&2; return 1; }
    printf '%-30s %10s  %-5s %s\n' ID CONTEXT TOOLS NAME
    printf '%s\n' "$rows" | awk -F'\t' '{ printf "%-30s %10s  %-5s %s\n", $1, $2, $3, $4 }'
}

# True if $1 is a model id in the live catalog.
ccgo_model_exists() {
    ccgo_models_tsv 2>/dev/null | awk -F'\t' -v m="$1" '$1 == m { found = 1 } END { exit !found }'
}

# Context window for a model: live value first, static fallback second.
ccgo_context() {
    local live
    live=$(ccgo_models_tsv 2>/dev/null | awk -F'\t' -v m="$1" '$1 == m { print $2; exit }')
    if [ -n "$live" ] && [ "$live" -gt 0 ] 2>/dev/null; then
        echo "$live"
        return 0
    fi
    case "$1" in
        deepseek-v4-pro|deepseek-v4.1-flash|minimax-m3|qwen3.7-plus) echo 1000000 ;;
        kimi-k3)             echo 1048576 ;;
        *)                   echo 200000 ;;
    esac
}

ccgo() {
    local preset="${1:-deepseek}"
    local main_model=""
    local fast_model=""
    local opus_model=""
    local sonnet_model=""
    local haiku_model=""
    local subagent_model=""
    local context_tokens=""
    local key=""

    case "$preset" in
        deepseek|default)
            main_model="deepseek-v4-pro"
            fast_model="deepseek-v4.1-flash"
            ;;
        flash)
            main_model="deepseek-v4.1-flash"
            fast_model="$main_model"
            ;;
        minimax)
            main_model="minimax-m3"
            fast_model="minimax-m3.1-flash"
            ;;
        qwen)
            main_model="qwen3.7-plus"
            fast_model="claude-haiku-5-5"
            ;;
        kimi)
            main_model="kimi-k3"
            fast_model="claude-haiku-5-5"
            ;;
        haiku)
            main_model="claude-haiku-5-5"
            fast_model="$main_model"
            ;;
        custom)
            local models
            if models=$(ccgo_models_tsv) && [ -n "$models" ]; then
                printf '%s\n' "$models" | awk -F'\t' '{ printf "  %-30s %10s ctx  tools:%s\n", $1, $2, $3 }'
                echo
            fi
            printf "Main model ID: "
            IFS= read -r main_model
            [ -n "$main_model" ] || return 1

            printf "Fast model ID [%s]: " "$main_model"
            IFS= read -r fast_model
            fast_model="${fast_model:-$main_model}"
            ;;
        version|--version|-V)
            echo "ccgo $CCGO_VERSION"
            return 0
            ;;
        models)
            ccgo_models
            return $?
            ;;
        list|help|-h|--help)
            cat <<'EOF'
OpenCode Go / Claude Code

PRESETS
  deepseek   DeepSeek Pro + Flash (default)
  flash      DeepSeek Flash only
  minimax    MiniMax M3 + M3.1 Flash
  qwen       Qwen3.7 Plus + Haiku
  kimi       Kimi K3 + Haiku
  haiku      Haiku only
  custom     Interactive selection from the live model list
  version    Print the ccgo version
  models     Show models available from the OpenCode Go API
  <model-id> Any model id from `ccgo models` (e.g. ccgo glm-5.3)

EXAMPLES
  ccgo
  ccgo flash
  ccgo minimax --continue
  ccgo deepseek -p "Review this project"

OVERRIDES
  CCGO_OPUS_MODEL
  CCGO_SONNET_MODEL
  CCGO_HAIKU_MODEL
  CCGO_SUBAGENT_MODEL
  CCGO_CONTEXT_TOKENS

  OPENCODE_API_KEY

TELEMETRY
  Disabled by default for launched Claude Code.
EOF
            return 0
            ;;
        *)
            # Allow Claude arguments without an explicit preset.
            if [[ "$preset" == -* ]]; then
                main_model="deepseek-v4-pro"
                fast_model="deepseek-v4.1-flash"
            elif ccgo_model_exists "$preset"; then
                # Any model id from the live catalog works as a preset.
                main_model="$preset"
                fast_model="$preset"
            else
                echo "Unknown preset or model: $preset (try: ccgo models)" >&2
                return 1
            fi
            ;;
    esac

    # Shift only when the first argument was a preset.
    if [ "$#" -gt 0 ] && [[ "$1" != -* ]]; then
        shift
    fi

    if ! command -v claude >/dev/null 2>&1; then
        echo "Claude Code CLI not installed." >&2
        return 1
    fi

    # Authentication.
    key="${OPENCODE_API_KEY:-}"

    if [ -z "$key" ]; then
        printf "OpenCode API key: "
        IFS= read -rs key
        printf '\n'
    fi

    [ -n "$key" ] || {
        echo "Missing OpenCode API key." >&2
        return 1
    }

    # Model mappings.
    opus_model="${CCGO_OPUS_MODEL:-$main_model}"
    sonnet_model="${CCGO_SONNET_MODEL:-$main_model}"
    haiku_model="${CCGO_HAIKU_MODEL:-$fast_model}"

    subagent_model="${CCGO_SUBAGENT_MODEL:-$fast_model}"

    # Context metadata.
    context_tokens="${CCGO_CONTEXT_TOKENS:-$(ccgo_context "$main_model")}"

    case "$context_tokens" in
        ''|*[!0-9]*)
            echo "Invalid context token count." >&2
            return 1
            ;;
    esac

    printf '\n'
    printf 'Claude Code / OpenCode Go\n'
    printf '%s\n' '----------------------------'
    printf 'Preset:     %s\n' "$preset"
    printf 'Main:       %s\n' "$main_model"
    printf 'Opus:       %s\n' "$opus_model"
    printf 'Sonnet:     %s\n' "$sonnet_model"
    printf 'Haiku:      %s\n' "$haiku_model"
    printf 'Subagents:  %s\n' "$subagent_model"
    printf 'Context*:   %s tokens\n' "$context_tokens"
    printf 'Telemetry:  disabled\n'
    printf '\n'
    printf '* Declared to Claude Code via CLAUDE_CODE_MAX_CONTEXT_TOKENS.\n'
    printf '\n'

    # All configuration stays inside this subshell.
    (
        # Remove existing Anthropic configuration.
        unset ANTHROPIC_API_KEY
        unset ANTHROPIC_AUTH_TOKEN
        unset ANTHROPIC_BASE_URL
        unset ANTHROPIC_MODEL
        unset ANTHROPIC_SMALL_FAST_MODEL

        # OpenCode Go.
        export ANTHROPIC_BASE_URL="https://opencode.ai/inference/go/anthropic"
        export ANTHROPIC_AUTH_TOKEN="$key"

        # Model aliases.
        export ANTHROPIC_DEFAULT_OPUS_MODEL="$opus_model"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="$sonnet_model"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="$haiku_model"

        # Delegation.
        export CLAUDE_CODE_SUBAGENT_MODEL="$subagent_model"

        # Context window. Claude Code does not recognize third-party model
        # IDs, assumes a 200k window for them, and warns about it at startup.
        # Declaring the real window here silences that warning and lets
        # auto-compact use the true boundary. Ignored by Claude Code for
        # model IDs it already knows (e.g. claude-haiku-5-5).
        export CLAUDE_CODE_MAX_CONTEXT_TOKENS="$context_tokens"

        # Third-party model compatibility.
        export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1

        # ----------------------------------------
        # PRIVACY / TELEMETRY
        # ----------------------------------------

        # Disable Statsig telemetry.
        export DISABLE_TELEMETRY=1

        # Disable automatic error reporting.
        export DISABLE_ERROR_REPORTING=1

        # Disable optional model calls.
        export DISABLE_NON_ESSENTIAL_MODEL_CALLS=1

        # Disable feedback survey.
        export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1

        # Disable optional update checks.
        export DISABLE_AUTOUPDATER=1

        # Disable OpenTelemetry export.
        export CLAUDE_CODE_ENABLE_TELEMETRY=0
        export OTEL_SDK_DISABLED=true
        
        export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

        # Context metadata available to child processes.
        # Claude Code itself reads CLAUDE_CODE_MAX_CONTEXT_TOKENS above.
        export CCGO_ACTIVE_CONTEXT_TOKENS="$context_tokens"

        # Launch.
        command claude --model "$main_model" "$@"
    )
}
