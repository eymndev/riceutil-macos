# riceutil

`yabai`, `skhd`, Kitty, Zsh, Homebrew ve [ASCII Wallpaper](https://github.com/eymndev/Wallpaper) için küçük bir macOS yardımcısı. Hem terminal komutu hem de aynı işleri yapan bir SwiftUI uygulaması (Riceutil GUI) var.

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
riceutil reload
riceutil kitty
riceutil zsh
riceutil doctor
riceutil update
riceutil status
riceutil gui
riceutil wallpaper ...
```

- `binds`: Kullanılabilen skhd alt komutlarını gösterir.
- `wm`: Kullanılabilen yabai alt komutlarını gösterir.
- `reload`: skhd ve yabai config'lerini birlikte yeniler.
- `kitty`: `KITTY_CONFIG_DIRECTORY` ve XDG ayarlarını dikkate alarak `kitty.conf` dosyasını Vim'de açar. Config klasörü yoksa oluşturur.
- `zsh`: `ZDOTDIR` ayarını dikkate alarak `.zshrc` dosyasını Vim'de açar.
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
riceutil wallpaper themes           # kurulu temalar, * = etkin tema
riceutil wallpaper packs            # tema paketleri: Klasik (dahili), Hyprland, Anime ...
riceutil wallpaper pack add anime   # paketi indirir ve kurar
riceutil wallpaper pack remove anime
riceutil wallpaper theme fire       # temayı değiştirir
riceutil wallpaper next             # sonraki tema
riceutil wallpaper panel on|off     # sistem paneli
riceutil wallpaper clock on|off     # saat
riceutil wallpaper name on|off      # köşedeki tema adı
riceutil wallpaper rotate 30        # temayı 30 dakikada bir değiştirir (0 = kapalı)
riceutil wallpaper saver            # ekran koruyucuyu kurar ve Ekran Koruyucu ayarlarını açar
```

Uygulama çalışırken ayarlar anında değişir; kapalıyken bir sonraki açılışta geçerli olur. Depo varsayılan olarak `~/.local/share/riceutil/Wallpaper` içine indirilir.

Temalar paketlere ayrılmıştır: Klasik temalar uygulamayla gelir, Hyprland ve Anime gibi paketler `riceutil wallpaper pack add <paket>` ile ayrı indirilir. riceutil depoyu seyrek (sparse) ve dosyasız (`--filter=blob:none`) klonlar; bir paketin görselleri ancak o paket eklenince iner. Kurulu paketler `~/Library/Application Support/ASCII Wallpaper/packs` içindedir ve `riceutil wallpaper update` onları da günceller. Paketlerden önceki bir sürümden güncellerken o an depoda olan paketlerin hepsi kurulur, yani kullandığın temalar kaybolmaz. Kendi klonunu kullanmak için:

```sh
export RICEUTIL_WALLPAPER_DIR="$HOME/kod/Wallpaper"
```

## GUI

`riceutil gui` ya da Uygulamalar'dan Riceutil. Bölümler:

- **Genel**: yabai, skhd, Homebrew ve duvar kağıdının durumu
- **Duvar Kağıdı**: kur/güncelle, başlat/durdur, tema paketlerini indirme/kaldırma, paketlere göre gruplanmış önizlemeli ve tıklayınca değişen tema listesi, panel/saat/tema adı ve sırayla değiştirme ayarları, ekran koruyucu kurulumu
- **Config ve WM**: skhd, yabai, Kitty ve Zsh config'lerini uygulamanın içinde düz metin olarak düzenleme (eş aralıklı yazı, akıllı tırnak ve otomatik düzeltme yok, her zaman UTF-8 düz metin kaydeder) ya da Terminal'de (Vim) açma, skhd/yabai'yi yeniden yükleme, pencere yöneticisi modu (macOS / yabai / Stage Manager)
- **Tanılama**: `riceutil doctor` çıktısı, kopyalama ve dosyaya kaydetme
- **Homebrew**: `brew update` ve `brew upgrade`, çıktısı canlı akar

GUI her işi kendi paketindeki `riceutil` betiğiyle yapar, bu yüzden komut satırıyla aynı davranır. Elle derlemek için `./scripts/build-gui.sh` (çıktı: `build/Riceutil.app`).

## skhd ve yabai

skhd veya yabai üzerinde tek başına işlem yapmak için:

```sh
riceutil binds config
riceutil binds reload
riceutil wm config
riceutil wm reload
riceutil wm mode mac
riceutil wm mode yabai
riceutil wm mode stage-manager
```

Düz `riceutil binds` ve `riceutil wm` çağrıları ilgili alt komut yardımını gösterir.

### Pencere yöneticisi modları

```sh
riceutil wm mode mac
riceutil wm mode yabai
riceutil wm mode stage-manager
```

- `mac`: yabai servisini durdurur ve Stage Manager'ı kapatır.
- `yabai`: Stage Manager'ı kapatır; yabai çalışıyorsa yeniden başlatır, çalışmıyorsa başlatır.
- `stage-manager`: yabai servisini durdurur ve Stage Manager'ı açar.

Stage Manager tercihini uygulamak için Dock işlemi yeniden başlatılır; ekran öğeleri kısa süreliğine kaybolup geri gelebilir. skhd servisi mod geçişlerinden etkilenmez.

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
export RICEUTIL_KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"
export RICEUTIL_ZSH_CONFIG="$HOME/.zshrc"
export RICEUTIL_WALLPAPER_DIR="$HOME/.local/share/riceutil/Wallpaper"
export RICEUTIL_WALLPAPER_REF=main   # belirli bir dal ya da etiket
```

## Lisans

[MIT](LICENSE) © 2026 Eymen Yıldırım
