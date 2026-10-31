# ccgo

**Use [OpenCode Go](https://opencode.ai) with [Claude Code](https://claude.com/claude-code) easily.**
One command, `ccgo`, points Claude Code at OpenCode Go models (DeepSeek, MiniMax, Qwen, Kimi). Telemetry and non-essential traffic are disabled
for the launched session, and your shell environment is left untouched.

## Install

**Homebrew**

```sh
brew tap serhii-ilin/ccgo https://github.com/serhii-ilin/ccgo
brew trust serhii-ilin/ccgo   # newer Homebrew requires trusting third-party taps
brew install ccgo
```

**Script**

```sh
curl -fsSL https://raw.githubusercontent.com/serhii-ilin/ccgo/main/install.sh | bash
```

Or from a checkout: `./install.sh` (installs to `~/.local`; override with `PREFIX=`).

`ccgo` is a standalone command, so nothing needs to be sourced from `~/.zshrc` or `~/.bashrc`.
If you used an older version that was sourced as a shell function (`~/.ccgo.sh`), remove that
`source` line, otherwise the function shadows the installed command.

**Upgrade / uninstall**

```sh
brew upgrade ccgo      # or: brew uninstall ccgo
./uninstall.sh         # script install
```

## Usage

```sh
export OPENCODE_API_KEY=...   # or omit and ccgo will prompt (input hidden)

ccgo                  # DeepSeek Pro + Flash (default)
ccgo flash            # DeepSeek Flash only
ccgo minimax            # MiniMax M3 + M3.1 Flash
ccgo qwen             # Qwen3.7 Plus only
ccgo kimi
ccgo muse             # Muse Spark 1.3 Contributor only
ccgo free             # the free model on Go, used for all model types
ccgo haiku
ccgo --version        # print the ccgo version
ccgo models           # list models live from the OpenCode Go API
ccgo glm-5.3          # any model id from that list works as a preset
ccgo custom           # pick main/fast models from the live list
ccgo list             # show presets
ccgo deepseek -p "Review this project"   # extra args go to claude
```

Overrides: `CCGO_OPUS_MODEL`, `CCGO_FABLE_MODEL` (defaults to Opus), `CCGO_SONNET_MODEL`, `CCGO_HAIKU_MODEL`, `CCGO_SUBAGENT_MODEL`, `CCGO_CONTEXT_TOKENS`.

The model list and each model's context window come from the public OpenCode Go
`/v1/models` endpoint (no key needed), cached for an hour in `~/.cache/ccgo`
(`CCGO_MODELS_TTL` to change). If the API is unreachable, ccgo uses the cache or built-in defaults.

Requires the `claude` CLI, plus `curl` and `jq` or `python3` for the model list.

## Other providers (optional)

`ccgo env <name>` prints `export` lines that point Claude Code at another Anthropic-compatible
provider. Pass them through `eval` so they apply to your current shell, then run `claude`:

```sh
export ZAI_API_KEY=...
eval "$(ccgo env zai)"
claude
```

| Name | Provider | Key variable |
|---|---|---|
| `zai` | Z.ai (GLM-5.1) | `ZAI_API_KEY` |
| `nim` | NVIDIA NIM (GLM-5.1) | `NVIDIA_API_KEY` |
| `deepseek-or` | OpenRouter, DeepSeek V4 | `OPENROUTER_API_KEY` |
| `qwen-or` | OpenRouter, Qwen 3.6 | `OPENROUTER_API_KEY` |
| `minimax-m2` | MiniMax M2 | `MINIMAX_API_KEY` |

- If the key variable is unset, `ccgo env` prints an error and exports nothing.
- The variables last until the terminal is closed. To undo them in the same shell:
  `unset ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN`.
- Running `ccgo env zai` without `eval` prints the exports, including your key, so don't share that output.
- This is separate from plain `ccgo`, which uses OpenCode Go and leaves your shell untouched.

## Security

No keys are stored in this repo. Keep them in your environment or a password manager. `.env` files are
git-ignored and CI fails if something that looks like an API key is committed.

## License

MIT
