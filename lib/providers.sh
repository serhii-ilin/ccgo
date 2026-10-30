#!/usr/bin/env bash
#
# Optional helpers that point Claude Code at other Anthropic-compatible
# providers. Source this file, then call e.g. `set_zai`, then run `claude`.
#
# API keys are NEVER stored here. Export the relevant variable first:
#   ZAI_API_KEY         set_zai
#   NVIDIA_API_KEY      set_zai_nim
#   OPENROUTER_API_KEY  set_ds_openrouter, set_qwen_openrouter
#   MINIMAX_API_KEY     set_minimax

_ccgo_require_key() {
  eval "[ -n \"\${$1:-}\" ]" || { echo "Set $1 first." >&2; return 1; }
}

_ccgo_show() {
  echo "Claude Code environment set for $1:"
  echo "  ANTHROPIC_BASE_URL=$ANTHROPIC_BASE_URL"
  echo "  ANTHROPIC_DEFAULT_OPUS_MODEL=${ANTHROPIC_DEFAULT_OPUS_MODEL:-}"
  echo "  ANTHROPIC_DEFAULT_SONNET_MODEL=${ANTHROPIC_DEFAULT_SONNET_MODEL:-}"
  echo "  ANTHROPIC_DEFAULT_HAIKU_MODEL=${ANTHROPIC_DEFAULT_HAIKU_MODEL:-}"
  echo "  ANTHROPIC_AUTH_TOKEN=<hidden>"
}

set_zai() {
  _ccgo_require_key ZAI_API_KEY || return 1
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  export API_TIMEOUT_MS="3000000"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="GLM-5.1"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="GLM-5.1"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="GLM-4.5-Air"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  _ccgo_show "Z.ai"
}

set_zai_nim() {
  _ccgo_require_key NVIDIA_API_KEY || return 1
  export ANTHROPIC_AUTH_TOKEN="$NVIDIA_API_KEY"
  export ANTHROPIC_BASE_URL="https://integrate.api.nvidia.com/v1"
  export API_TIMEOUT_MS="3000000"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="z-ai/glm-5.1"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="z-ai/glm-5.1"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="z-ai/glm-5.1"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  _ccgo_show "NVIDIA NIM (GLM)"
}

set_ds_openrouter() {
  _ccgo_require_key OPENROUTER_API_KEY || return 1
  export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
  export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
  export API_TIMEOUT_MS="3000000"
  export ANTHROPIC_MODEL="deepseek/deepseek-v4-pro"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek/deepseek-v4-pro"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek/deepseek-v4-pro"
  export CLAUDE_CODE_SUBAGENT_MODEL="deepseek/deepseek-v4-pro"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek/deepseek-v4-flash"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  _ccgo_show "OpenRouter (DeepSeek)"
}

set_qwen_openrouter() {
  _ccgo_require_key OPENROUTER_API_KEY || return 1
  export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
  export ANTHROPIC_BASE_URL="https://openrouter.ai/api"
  export API_TIMEOUT_MS="3000000"
  export ANTHROPIC_MODEL="qwen/qwen3.6-plus"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="qwen/qwen3.6-plus"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="qwen/qwen3.6-plus"
  export CLAUDE_CODE_SUBAGENT_MODEL="qwen/qwen3.6-plus"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen/qwen3.6-flash"
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  _ccgo_show "OpenRouter (Qwen)"
}

set_minimax() {
  _ccgo_require_key MINIMAX_API_KEY || return 1
  export ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic"
  export ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY"
  export API_TIMEOUT_MS=3000000
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  export ANTHROPIC_MODEL="MiniMax-M2"
  export ANTHROPIC_SMALL_FAST_MODEL="MiniMax-M2"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M2"
  _ccgo_show "MiniMax"
}
