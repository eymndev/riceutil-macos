#!/usr/bin/env bash
# riceutil komutunu kurar; Swift varsa Riceutil GUI'sini de derleyip ~/Applications içine kurar.
#   --no-gui  yalnızca komut satırı aracını kur
# shellcheck disable=SC2016,SC2088  # PATH talimatları kullanıcıya olduğu gibi basılır

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_PREFIX="${RICEUTIL_PREFIX:-$HOME/.local}"
INSTALL_DIR="$INSTALL_PREFIX/bin"
INSTALL_PATH="$INSTALL_DIR/riceutil"
GUI_DIR="${RICEUTIL_GUI_DIR:-$HOME/Applications}"
WITH_GUI=1

for arg in "$@"; do
  case "$arg" in
    --no-gui) WITH_GUI=0 ;;
    *) printf 'bilinmeyen seçenek: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

mkdir -p "$INSTALL_DIR"
install -m 0755 "$SCRIPT_DIR/riceutil" "$INSTALL_PATH"

printf 'riceutil kuruldu: %s\n' "$INSTALL_PATH"

if [ "$WITH_GUI" -eq 1 ]; then
  if command -v swift >/dev/null 2>&1; then
    printf '\nRiceutil GUI derleniyor...\n'
    "$SCRIPT_DIR/scripts/build-gui.sh"
    mkdir -p "$GUI_DIR"
    rm -rf "$GUI_DIR/Riceutil.app"
    cp -R "$SCRIPT_DIR/build/Riceutil.app" "$GUI_DIR/Riceutil.app"
    printf 'GUI kuruldu: %s (açmak için: riceutil gui)\n' "$GUI_DIR/Riceutil.app"
  else
    printf '\nSwift bulunamadığı için GUI kurulmadı. GUI için önce: xcode-select --install\n'
  fi
fi

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
