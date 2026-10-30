
#!/usr/bin/env bash
#
# Claude Code + OpenCode Go
#
# Usage:
#   ccgo                  Default DeepSeek preset
#   ccgo deepseek         DeepSeek Pro + Flash
#   ccgo flash            DeepSeek Flash only
#   ccgo minimax          MiniMax M3
#   ccgo qwen             Qwen3.7 Plus
#   ccgo kimi             Kimi K3
#   ccgo haiku            Claude Haiku 5.5
#   ccgo custom           Interactive model selection
#   ccgo list             Show presets
#
# Pass additional arguments directly to Claude:
#   ccgo deepseek -p "Explain this project"
#   ccgo minimax --continue
#
# Install with install.sh or Homebrew (see README), or source this file from
# ~/.zshrc / ~/.bashrc to use ccgo as a shell function.
# The API key is read from OPENCODE_API_KEY (or prompted for); never hardcode it.

# Context metadata for supported presets.
# These are configurable planning values, not a gateway guarantee.
ccgo_context() {
    case "$1" in
        deepseek-v4-pro)      echo 1000000 ;;
        deepseek-v4.1-flash)  echo 1000000 ;;
        minimax-m3)          echo 204800 ;;
        qwen3.7-plus)        echo 1000000 ;;
        kimi-k3)             echo 262144 ;;
        claude-haiku-5-5)    echo 200000 ;;
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
            fast_model="$main_model"
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
            printf "Main model ID: "
            IFS= read -r main_model
            [ -n "$main_model" ] || return 1

            printf "Fast model ID [%s]: " "$main_model"
            IFS= read -r fast_model
            fast_model="${fast_model:-$main_model}"
            ;;
        list|help|-h|--help)
            cat <<'EOF'
OpenCode Go / Claude Code

PRESETS
  deepseek   DeepSeek Pro + Flash (default)
  flash      DeepSeek Flash only
  minimax    MiniMax M3
  qwen       Qwen3.7 Plus + Haiku
  kimi       Kimi K3 + Haiku
  haiku      Haiku only
  custom     Interactive selection

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
            else
                echo "Unknown preset: $preset" >&2
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
