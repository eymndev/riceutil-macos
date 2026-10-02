#!/usr/bin/env bash
# riceutil komutlarını macOS araçları taklit edilerek dener (Linux'ta da çalışır):
# shellcheck disable=SC2016,SC2034  # komutlar check içinde eval ile çalışır
# defaults, pgrep, pkill, osascript, open ve mdfind sahte sürümlerle değiştirilir.
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export HOME="$WORK/home"
STUBS="$WORK/bin"
LOG="$WORK/log"
PREFS="$WORK/prefs"
mkdir -p "$HOME" "$STUBS" "$PREFS"
: >"$LOG"
export LOG PREFS

# defaults: her anahtar bir dosya
cat >"$STUBS/defaults" <<'STUB'
#!/usr/bin/env bash
case "$1" in
  read) [ -f "$PREFS/$3" ] && cat "$PREFS/$3" || exit 1 ;;
  write)
    value="$5"
    [ "$4" = "-bool" ] && { [ "$value" = true ] && value=1 || value=0; }
    printf '%s\n' "$value" >"$PREFS/$3"
    ;;
esac
STUB
# pgrep: RUNNING dosyası varsa uygulama çalışıyor
cat >"$STUBS/pgrep" <<'STUB'
#!/usr/bin/env bash
[ "${*: -1}" = AsciiWallpaper ] && [ -f "$PREFS/RUNNING" ]
STUB
cat >"$STUBS/pkill" <<'STUB'
#!/usr/bin/env bash
rm -f "$PREFS/RUNNING"; echo "pkill $*" >>"$LOG"
STUB
# osascript: bildirimin argümanlarını kaydeder ve uygulama gibi ayarı yazar
cat >"$STUBS/osascript" <<'STUB'
#!/usr/bin/env bash
shift 4
echo "notify $*" >>"$LOG"
[ "$1" = theme ] && printf '%s\n' "$2" >"$PREFS/theme"
exit 0
STUB
cat >"$STUBS/open" <<'STUB'
#!/usr/bin/env bash
echo "open $*" >>"$LOG"; touch "$PREFS/RUNNING"
STUB
printf '#!/bin/sh\nexit 0\n' >"$STUBS/mdfind"
printf '#!/bin/sh\nexit 0\n' >"$STUBS/sleep"
chmod +x "$STUBS"/*
export PATH="$STUBS:$PATH"

R="$ROOT/riceutil"
fails=0
check() {
  if eval "$2"; then printf 'ok   %s\n' "$1"; else printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); fi
}

check "kurulu değilken durum bunu söyler" '"$R" wallpaper | grep -q "kurulu değil"'
check "kurulu değilken tema değiştirmek hata verir" '! "$R" wallpaper theme fire 2>/dev/null'

APP="$HOME/Applications/ASCII Wallpaper.app"
mkdir -p "$APP/Contents/Resources/web"
printf 'lake\tGece Gölü\nmatrix\tMatrix\nfire\tŞömine\n' >"$APP/Contents/Resources/web/themes.tsv"

check "temalar listelenir, etkin tema işaretli" '"$R" wallpaper themes | grep -q "^\* lake"'
check "--tsv makine çıktısı" '[ "$("$R" wallpaper themes --tsv | sed -n 3p)" = "$(printf "fire\tŞömine\t0")" ]'
check "bilinmeyen tema reddedilir" '! "$R" wallpaper theme yok 2>/dev/null'
check "kapalıyken tema ayara yazılır" '"$R" wallpaper theme fire >/dev/null && [ "$(cat "$PREFS/theme")" = fire ]'
check "kapalıyken sonraki tema baştan döner" '"$R" wallpaper next | grep -q "Gece Gölü (lake)"'
check "kapalıyken tema adı ayarı yazılır" '"$R" wallpaper name off >/dev/null && [ "$(cat "$PREFS/showThemeName")" = 0 ]'
check "rotate sayı ister" '! "$R" wallpaper rotate abc 2>/dev/null'
check "start uygulamayı açar" '"$R" wallpaper start >/dev/null && grep -q "^open .*ASCII Wallpaper.app" "$LOG"'
check "çalışırken tema bildirimle gönderilir" '"$R" wallpaper theme matrix >/dev/null && grep -q "^notify theme matrix$" "$LOG"'
check "çalışırken sonraki tema bildirimle" '"$R" wallpaper next >/dev/null && grep -q "^notify next 1$" "$LOG"'
check "çalışırken panel bildirimle" '"$R" wallpaper panel off >/dev/null && grep -q "^notify panel 0$" "$LOG"'
check "durum çalışıyor der" '"$R" wallpaper status | grep -q "çalışıyor"'
check "durum --tsv" '"$R" wallpaper status --tsv | grep -q "^wallpaper.running	1$"'
check "stop uygulamayı kapatır" '"$R" wallpaper stop >/dev/null && ! [ -f "$PREFS/RUNNING" ]'
check "genel durum --tsv duvar kağıdını içerir" '"$R" status --tsv | grep -q "^wallpaper.theme	"'
check "path binds" '[ "$("$R" path binds)" = "$HOME/.skhdrc" ]'
check "gui kurulu değilse yol gösterir" '"$R" gui 2>&1 | grep -q install.sh'

[ "$fails" -eq 0 ] || { printf '%s test başarısız\n' "$fails"; exit 1; }
printf 'Tümü geçti.\n'
