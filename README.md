# riceutil

`yabai`, `skhd` ve Homebrew için küçük bir macOS terminal yardımcısı.

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
riceutil doctor
riceutil update
```

- `binds`: Var olan config'i önce `~/.skhdrc`, sonra `$XDG_CONFIG_HOME/skhd/skhdrc` altında arar ve Vim'de açar. Hiçbiri yoksa `~/.skhdrc` için yeni Vim tamponu açar.
- `wm`: Var olan config'i önce `~/.yabairc`, sonra `$XDG_CONFIG_HOME/yabai/yabairc` altında arar ve Vim'de açar. Hiçbiri yoksa `~/.yabairc` için yeni Vim tamponu açar.
- `doctor`: yabai/skhd sürüm ve servis durumlarını, bilinen config/LaunchAgent dosyalarını ve bulunan log dosyalarının tam içeriğini terminale basar.
- `update`: Sırayla `brew update` ve `brew upgrade` çalıştırır. `brew cleanup` çalıştırmaz.

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
```

## Lisans

[MIT](LICENSE) © 2026 Eymen Yıldırım
