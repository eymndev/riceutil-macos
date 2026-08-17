#!/usr/bin/env bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_PREFIX="${RICEUTIL_PREFIX:-$HOME/.local}"
INSTALL_DIR="$INSTALL_PREFIX/bin"
INSTALL_PATH="$INSTALL_DIR/riceutil"

mkdir -p "$INSTALL_DIR"
install -m 0755 "$SCRIPT_DIR/riceutil" "$INSTALL_PATH"

printf 'riceutil kuruldu: %s\n' "$INSTALL_PATH"

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    printf 'Hazır. Denemek için: riceutil help\n'
    ;;
  *)
    printf '\n%s henüz PATH içinde değil.\n' "$INSTALL_DIR"
    case "${SHELL:-}" in
      */fish|fish)
        printf 'Fish için şu komutu bir kez çalıştır:\n'
        printf '  fish_add_path "%s"\n' "$INSTALL_DIR"
        ;;
      */zsh|zsh)
        printf '~/.zshrc dosyana şunu ekle:\n'
        printf '  export PATH="%s:$PATH"\n' "$INSTALL_DIR"
        printf 'Sonra yeni bir terminal aç veya: source ~/.zshrc\n'
        ;;
      */bash|bash)
        printf '~/.bashrc dosyana şunu ekle:\n'
        printf '  export PATH="%s:$PATH"\n' "$INSTALL_DIR"
        printf 'Sonra yeni bir terminal aç veya: source ~/.bashrc\n'
        ;;
      *)
        printf 'Shell başlangıç dosyana şu dizini PATH olarak ekle: %s\n' "$INSTALL_DIR"
        ;;
    esac
    ;;
esac
