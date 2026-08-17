# riceutil

`yabai`, `skhd`, Kitty, Zsh ve Homebrew için küçük bir macOS terminal yardımcısı.

## Kurulum

```sh
cd /riceutil/klasorunun/yolu
./install.sh
```

Varsayılan kurulum yolu `~/.local/bin/riceutil`'dır. Farklı bir prefix için:

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
```

- `binds`: Kullanılabilen skhd alt komutlarını gösterir.
- `wm`: Kullanılabilen yabai alt komutlarını gösterir.
- `reload`: skhd ve yabai config'lerini birlikte yeniler.
- `kitty`: `KITTY_CONFIG_DIRECTORY` ve XDG ayarlarını dikkate alarak `kitty.conf` dosyasını Vim'de açar. Config klasörü yoksa oluşturur.
- `zsh`: `ZDOTDIR` ayarını dikkate alarak `.zshrc` dosyasını Vim'de açar.
- `doctor`: yabai/skhd sürüm ve servis durumlarını, bilinen config/LaunchAgent dosyalarını ve bulunan log dosyalarının tam içeriğini terminale basar.
- `update`: Sırayla `brew update` ve `brew upgrade` çalıştırır. `brew cleanup` çalıştırmaz.

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
```

## Lisans

[MIT](LICENSE) © 2026 Eymen Yıldırım
