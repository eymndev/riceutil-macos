#!/usr/bin/env bash
# Riceutil GUI'sini derler: build/Riceutil.app (Xcode Command Line Tools gerekir)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/build/Riceutil.app"

cd "$ROOT/gui"
swift build -c release
BIN="$(swift build -c release --show-bin-path)/Riceutil"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/Riceutil"
cp "$ROOT/gui/Info.plist" "$APP/Contents/Info.plist"
# GUI her işi paketteki riceutil betiğiyle yapar
install -m 0755 "$ROOT/riceutil" "$APP/Contents/Resources/riceutil"

# Yerel imza (Apple geliştirici hesabı gerekmez)
codesign --force --deep --sign - "$APP"

echo "Hazır: $APP"
