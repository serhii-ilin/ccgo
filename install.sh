#!/usr/bin/env bash
# Install ccgo.
#   Local checkout:  ./install.sh
#   Remote:          curl -fsSL https://raw.githubusercontent.com/serhii-ilin/ccgo/main/install.sh | bash
# Env: PREFIX (default ~/.local), CCGO_REF (git ref for remote install, default main)
set -euo pipefail

REPO="serhii-ilin/ccgo"
REF="${CCGO_REF:-main}"
PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"

src=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "$(dirname "${BASH_SOURCE[0]}")/bin/ccgo" ]; then
  src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" | tar -xz -C "$tmp" --strip-components=1
  src="$tmp"
fi

mkdir -p "$BIN"
install -m 0755 "$src/bin/ccgo" "$BIN/ccgo"

echo "Installed ccgo to $BIN/ccgo"
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "Add $BIN to your PATH:  export PATH=\"$BIN:\$PATH\"" ;;
esac
command -v claude >/dev/null || echo "Note: Claude Code CLI ('claude') not found; install it first."
echo "Set your key with:  export OPENCODE_API_KEY=...   (never commit it)"
echo "Run:  ccgo list"
