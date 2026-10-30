#!/usr/bin/env bash
set -euo pipefail
PREFIX="${PREFIX:-$HOME/.local}"
rm -f "$PREFIX/bin/ccgo"
rm -rf "$PREFIX/share/ccgo"
echo "ccgo removed from $PREFIX"
