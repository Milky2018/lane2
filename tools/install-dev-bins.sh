#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
BIN_DIR="${MOON_BIN:-$HOME/.moon/bin}"
LIB_DIR="${LANE_LIB:-$HOME/.lane/lib}"

cd "$REPO_ROOT"

moon build --target native

mkdir -p "$BIN_DIR" "$LIB_DIR"

install -m 755 \
  "$REPO_ROOT/_build/native/debug/build/Milky2018/lane/lane.exe" \
  "$BIN_DIR/lane"

install -m 755 \
  "$REPO_ROOT/_build/native/debug/build/Milky2018/lane_lsp/lane_lsp.exe" \
  "$BIN_DIR/lane_lsp"

install -m 644 "$REPO_ROOT/lane-std/prelude.lane" "$LIB_DIR/prelude.lane"
install -m 644 "$REPO_ROOT/lane-std/README.md" "$LIB_DIR/README.md"

printf 'Installed Lane development binaries to %s\n' "$BIN_DIR"
printf '  %s\n' "$BIN_DIR/lane"
printf '  %s\n' "$BIN_DIR/lane_lsp"
printf 'Installed Lane standard library to %s\n' "$LIB_DIR"
printf '  %s\n' "$LIB_DIR/prelude.lane"
