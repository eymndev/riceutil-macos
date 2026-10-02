# riceutil

`yabai`, `skhd`, Homebrew ve [ASCII Wallpaper](https://github.com/eymndev/Wallpaper) için küçük bir macOS yardımcısı. Hem terminal komutu hem de aynı işleri yapan bir SwiftUI uygulaması (Riceutil GUI) var.

## Kurulum

```sh
cd /riceutil/klasorunun/yolu
./install.sh
```

Varsayılan kurulum yolu `~/.local/bin/riceutil`'dır. Swift (Xcode Command Line Tools, `xcode-select --install`) kuruluysa GUI de derlenip `~/Applications/Riceutil.app` olarak kurulur; yalnızca komutu istiyorsan `./install.sh --no-gui`. Güncellemek için depoda `git pull` sonrası `./install.sh` yeter. Farklı bir prefix için:

```sh
RICEUTIL_PREFIX=/usr/local ./install.sh
```

Fish kullanıyorsan ve kurucu dizinin PATH içinde olmadığını söylerse şu komutu bir kez çalıştır:

```fish
fish_add_path ~/.local/bin
```

## Komutlar

```sh
riceutil binds
riceutil wm
riceutil doctor
riceutil update
riceutil status
riceutil gui
riceutil wallpaper ...
```

- `binds`: Var olan config'i önce `~/.skhdrc`, sonra `$XDG_CONFIG_HOME/skhd/skhdrc` altında arar ve Vim'de açar. Hiçbiri yoksa `~/.skhdrc` için yeni Vim tamponu açar.
- `wm`: Var olan config'i önce `~/.yabairc`, sonra `$XDG_CONFIG_HOME/yabai/yabairc` altında arar ve Vim'de açar. Hiçbiri yoksa `~/.yabairc` için yeni Vim tamponu açar.
- `doctor`: yabai/skhd sürüm ve servis durumlarını, bilinen config/LaunchAgent dosyalarını ve bulunan log dosyalarının tam içeriğini terminale basar.
- `update`: Sırayla `brew update` ve `brew upgrade` çalıştırır. `brew cleanup` çalıştırmaz.
- `status`: yabai, skhd, Homebrew ve duvar kağıdının kısa durumu (`--tsv` ile makine okunur çıktı).
- `gui`: Riceutil uygulamasını açar.

## Duvar kağıdı

[ASCII Wallpaper](https://github.com/eymndev/Wallpaper)'ı kurar ve yönetir (`riceutil wp` kısaltması da çalışır):

```sh
riceutil wallpaper install          # indirir, derler, ~/Applications'a kurar, ekran koruyucuyu kurar ve başlatır
riceutil wallpaper update           # depoyu çekip yeniden derler ve kurar
riceutil wallpaper                  # durum
riceutil wallpaper start | stop | restart
riceutil wallpaper themes           # temalar, * = etkin tema
riceutil wallpaper theme fire       # temayı değiştirir
riceutil wallpaper next             # sonraki tema
riceutil wallpaper panel on|off     # sistem paneli
riceutil wallpaper clock on|off     # saat
riceutil wallpaper name on|off      # köşedeki tema adı
riceutil wallpaper rotate 30        # temayı 30 dakikada bir değiştirir (0 = kapalı)
riceutil wallpaper saver            # ekran koruyucuyu kurar ve Ekran Koruyucu ayarlarını açar
```

Uygulama çalışırken ayarlar anında değişir; kapalıyken bir sonraki açılışta geçerli olur. Depo varsayılan olarak `~/.local/share/riceutil/Wallpaper` içine indirilir. Kendi klonunu kullanmak için:

```sh
export RICEUTIL_WALLPAPER_DIR="$HOME/kod/Wallpaper"
```

## GUI

`riceutil gui` ya da Uygulamalar'dan Riceutil. Bölümler:

- **Genel**: yabai, skhd, Homebrew ve duvar kağıdının durumu
- **Duvar Kağıdı**: kur/güncelle, başlat/durdur, tıklayınca değişen tema listesi, panel/saat/tema adı ve sırayla değiştirme ayarları, ekran koruyucu kurulumu
- **Kısayollar ve WM**: skhd ve yabai config'lerini Terminal'de (Vim) ya da varsayılan düzenleyicide açma
- **Tanılama**: `riceutil doctor` çıktısı, kopyalama ve dosyaya kaydetme
- **Homebrew**: `brew update` ve `brew upgrade`, çıktısı canlı akar

GUI her işi kendi paketindeki `riceutil` betiğiyle yapar, bu yüzden komut satırıyla aynı davranır. Elle derlemek için `./scripts/build-gui.sh` (çıktı: `build/Riceutil.app`).

## Tanılama

Tanılama raporunu dosyaya almak için:

```sh
riceutil doctor > riceutil-doctor.txt 2>&1
```

Config dosyalarında özel bilgiler varsa bu raporu paylaşmadan önce gözden geçir.

## İsteğe bağlı ayarlar

```sh
export RICEUTIL_EDITOR=nvim
export RICEUTIL_SKHD_CONFIG="$HOME/.config/skhd/skhdrc"
export RICEUTIL_YABAI_CONFIG="$HOME/.config/yabai/yabairc"
export RICEUTIL_WALLPAPER_DIR="$HOME/.local/share/riceutil/Wallpaper"
export RICEUTIL_WALLPAPER_REF=main   # belirli bir dal ya da etiket
```

## Lisans

[MIT](LICENSE) © 2026 Eymen Yıldırım
