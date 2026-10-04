# AGENTS.md — riceutil

Bu depoda çalışacak geliştiriciler ve kodlama agent'ları (Codex, Claude vb.) için proje bağlamı, kalıcı kurallar ve önemli çalışma kayıtları. Ayrıntılı kullanım için `README.md`'ye bak.

## Proje özeti

`yabai`, `skhd`, Kitty, Zsh, Homebrew ve [ASCII Wallpaper](https://github.com/eymndev/Wallpaper) için macOS yardımcısı: tek dosyalık bir Bash komutu (`riceutil`, sürüm `VERSION` değişkeninde, şu an 1.5.0) ve aynı işleri yapan bir SwiftUI uygulaması (Riceutil GUI). Eymen Yıldırım'ın kendi projesi; sonradan eklenen duvar kağıdı komutları ve GUI AI (Claude) yardımıyla yazıldı. Proje "tamamen AI Generated" olarak etiketlenmez.

## Dizin yapısı

- `riceutil`: Komut satırı aracının tamamı (Bash). Alt komutlar: `binds`, `wm` (`config`, `reload`, `mode mac|yabai|stage-manager`), `reload`, `kitty`, `zsh`, `doctor`, `update`, `status [--tsv]`, `gui`, `path`, `wallpaper`/`wp`.
- `install.sh`: Komutu `$RICEUTIL_PREFIX/bin` (varsayılan `~/.local/bin`) içine kurar; Swift varsa GUI'yi derleyip `~/Applications/Riceutil.app` (ya da `RICEUTIL_GUI_DIR`) olarak kurar. `--no-gui` yalnızca komutu kurar.
- `gui/`: SwiftUI uygulaması (SwiftPM, `gui/Sources/Riceutil/`). Her işi `Runner` ile kendi paketindeki `riceutil` betiğini çalıştırarak yapar; böylece GUI ve komut aynı sürümde ve aynı davranışta kalır.
- `scripts/build-gui.sh`: `build/Riceutil.app` üretir (yalnızca macOS).
- `tests/cli.sh`: macOS araçlarını (`defaults`, `pgrep`, `osascript`, `open`, `mdfind` ...) sahte sürümlerle değiştirip komutları dener; Linux'ta da çalışır.

## Komutlar

- `./tests/cli.sh`: Komut testleri.
- `shellcheck riceutil install.sh scripts/*.sh tests/*.sh`: CI'daki lint.
- `./scripts/build-gui.sh`: GUI derlemesi (macOS).
- `./install.sh`: Kurulum/güncelleme.

## CI

`.github/workflows/ci.yml`: Ubuntu'da shellcheck + `tests/cli.sh`; `macos-15`'te testler, `install.sh` ile kurulum, GUI'nin açıldığının kontrolü, Wallpaper deposu erişilebilirse uçtan uca `riceutil wallpaper install` ve tema/ayar komutları, ekran görüntüleri ve `Riceutil.zip` artifact'ı.

Swift kodu Linux/bulut ortamında derlenemez; GUI değişiklikleri yalnızca macOS CI'da doğrulanır.

## Kalıcı kurallar ve mimari kararlar

- **Duvar kağıdıyla iletişim:** `riceutil wallpaper` ayarı `dev.eymn.ascii-wallpaper` UserDefaults alanına yazar ve çalışan uygulamaya `dev.eymn.ascii-wallpaper.command` dağıtık bildirimini `osascript -l JavaScript` ile gönderir (userInfo değerleri string). Bildirimin `object`'i string olmalı (`"riceutil"`); JXA `null`'u NSNull yapıp uygulamayı çökertir. Tema listesi kurulu uygulamanın içindeki `web/themes.tsv`'den, GUI tema önizlemeleri `web/previews/<kimlik>.jpg`'den okunur.
- Wallpaper deposu varsayılan olarak `~/.local/share/riceutil/Wallpaper` içine klonlanır (`RICEUTIL_WALLPAPER_DIR`, `RICEUTIL_WALLPAPER_REPO`, `RICEUTIL_WALLPAPER_REF` ile değişir); kurulum Wallpaper'ın `scripts/install.sh` betiğiyle yapılır.
- **Config dosyalarını TextEdit veya varsayılan uygulamayla açma.** TextEdit dosyayı RTF olarak kaydedebilir. GUI config'leri uygulamanın içinde düz metin olarak düzenler ve her zaman UTF-8 düz metin kaydeder; komut satırı `RICEUTIL_EDITOR` (varsayılan `vim`) kullanır.
- Yeni ortam değişkeni veya alt komut eklenirse `print_usage`, `README.md` ve gerekiyorsa `tests/cli.sh` güncellenir.
- **Kullanıcıya verilen terminal komutlarında yer tutucu yol kullanma** (`/klasorunun/yolu` gibi); kullanıcı komutları olduğu gibi yapıştırır. Gerçek yollar ver (ör. `~/riceutil-macos`).
- Varsayılan dal `main`.

## Bilinen sorunlar

- `README.md`'nin "Kurulum" bölümünde hâlâ bir yer tutucu yol var (`cd /riceutil/klasorunun/yolu`). Bu çalışmanın kapsamı dışında bırakıldı.
- Kullanıcının bilgisayarındaki eski riceutil'de bulunan `menubar` (SketchyBar) komutu bu depoda yok; yalnızca yerel yedekte (`~/riceutil-eski-yedek`) duruyor. `Belirsiz`: geri eklenmesi istenip istenmediği.
- Wallpaper deposu özel olduğu sürece CI'daki uçtan uca duvar kağıdı testi uyarıyla atlanır.

## Çalışma kuralları

Bu kurallar bu depodaki tüm kodlama görevleri için geçerlidir: yeni kod, değişiklik, hata düzeltme, refactor, yeni özellik, test ve yapılandırma.

### 1. Talimat önceliği

1. Kullanıcının mevcut mesajındaki açık istek ve kısıtlamalar.
2. Kullanıcının bu konuşmada mevcut görev için verdiği ek açıklama ve düzeltmeler.
3. Projenin teknik olarak geçerli kuralları ve mevcut mimarisi.
4. Bu `AGENTS.md`.
5. Bu dosyadaki geçmiş çalışma kayıtları.

Mevcut kullanıcı isteği her zaman eski kayıtlardan önceliklidir. Eski hedefleri, TODO'ları ve yarım kalmış işleri kendiliğinden aktif görev sayma; kullanıcı açıkça istemedikçe geçmiş bir görevi yeniden başlatma.

### 2. Bu dosyanın rolü

`AGENTS.md`; proje bağlamı, mimari kararlar, kalıcı kurallar, önemli çalışma kayıtları ve doğrulanmış teknik bilgiler içindir. **Otomatik görev kuyruğu değildir.** `[ ]` olarak duran bir hedef yalnızca geçmiş çalışmanın durumunu gösterir; mevcut isteğin parçası değilse üzerinde çalışma.

Göreve başlamadan önce:

1. Proje yapısını incele, bu dosyayı ve `README.md`'yi oku.
2. Mevcut isteği geçmiş görevlerden ayır; amacını, kabul kriterlerini, kapsamını ve kapsam dışını belirle.
3. Gerekiyorsa mevcut görevin hedeflerini bu dosyaya ekle.

Küçük görevde de bu kontrolü atlama, ama gereksiz günlük veya anlamsız kayıt üretme.

### 3. Kapsam

Yalnızca mevcut isteği yerine getirmek için gereken değişiklikleri yap. Kullanıcı istemedikçe yapma: kapsam dışı refactor, ilgisiz bug düzeltme, mimariyi yeniden tasarlama, gereksiz dependency güncelleme, toplu lint temizliği, ilgisiz testleri düzeltme, dosya yeniden adlandırma, stil değişiklikleri, "hazır buradayken" ek özellikler.

Başka bir sorun fark edersen ve mevcut görevi engellemiyorsa düzeltme; gerekiyorsa aşağıdaki "Bilinen sorunlar" bölümüne ya da çalışma kaydına not et, önemliyse son cevapta belirt. Görevin başarılı olması için tüm projenin kusursuz olması gerekmez.

### 4. Takılıp kalmayı önleme

Bir eylemi tekrar etmeden önce sor: **"Son denemeden beri yeni bir bilgi, kod, durum veya hipotez var mı?"** Yoksa tekrar etme.

- Aynı başarısız yaklaşımı yeni bilgi olmadan ikinci kez deneme; aynı hata için en fazla 3 anlamlı alternatif dene.
- Aynı komutu aynı kod durumunda, aynı testi kod değişmeden tekrar tekrar çalıştırma; dosyaları "emin olmak için" yeniden okuma.
- Aynı permission isteğini tekrar tetikleme; network/tool hatasında sonsuz retry yapma; sınırsız araştırma yapma.

İki ardışık adımda kodda, test sonucunda, repo durumunda veya teşhiste anlamlı ilerleme yoksa bu **no-progress** durumudur: yeni kanıt sağlayacak tek bir farklı yaklaşım varsa onu dene, yoksa blokeri açıkça belirt ve dur.

### 5. Ne zaman bitti

İstenen değişiklik uygulanmış, kabul kriterleri karşılanmış, uygulanabilir doğrulamalar yapılmış, bu dosya gerektiği kadar güncellenmiş ve istenmeyen iş kalmamışsa **daha fazla değişiklik yapma.** Yeni problem arama, genel review başlatma, ek refactor ya da "bir iyileştirme daha" döngüsüne girme, geçmiş TODO'lara geçme; doğrudan final cevabını hazırla.

### 6. Compaction, reconnect, resume

Geçmişi eksik hatırlıyorsan eski görevi sıfırdan başlatma. Durumu şuradan yeniden kur: kullanıcının en güncel mesajı, `git status`, `git diff`, dosyaların gerçek içeriği, en son ilgili kayıt, mevcut test sonuçları. Özet ile repo çelişirse **repo esastır.** Eski bir promptun yeniden görünmesi onu yeniden çalıştırmak gerektiği anlamına gelmez. Uygulanmış işlemi, oluşturulmuş dosyayı veya migration'ı tekrar yapma; repo durumunun doğruladığı `[x]` hedefi yeniden yapma; `[ ]` hedef mevcut isteğin parçası değilse dokunma.

### 7. Kullanıcı düzeltmeleri

"Bunu yapma", "şunu kullan", "X yerine Y", "bu dosyaya dokunma", "bu kapsam dışında" gibi düzeltmeler mevcut görev için güçlü kısıttır; eski plan veya kayıtlarla çelişirse yenisi geçerlidir, compaction sonrasında da korunur. Yasaklanan bir yaklaşımı "alternatif çözüm" diye yeniden uygulama.

### 8. Tool, permission ve environment blokları

Permission, authentication, credential, network, olmayan tool, dış servis veya kullanıcı kararı gerektiren bir engeli kod yazarak ya da sürekli retry ederek aşmaya çalışma. Aynı engel aynı nedenle ikinci kez çıkarsa tekrarları durdur, bağımsız işleri bitir, engeli açıkça raporla. Gerçekleştiğini doğrulayamadığın bir işlemi gerçekleşmiş gibi sunma.

### 9. Review sınırı

Kod bitince ilgili değişiklikler için bir ana review, gerekli düzeltmeler ve bir final verification yeterlidir. Sınırsız `review → fix → review` döngüsü kurma; final verification'dan sonra yeni ve kritik bir sorun yoksa tekrar genel review başlatma. Kapsam dışı iyileştirmeleri yeni görevlere dönüştürme.

### 10. Testler

En ilgili ve en küçük doğrulamayla başla, gerekirse genişlet. Başarısız testin önce nedenini analiz et; kod veya environment değişmeden yeniden çalıştırma. Flaky olduğuna dair gerçek bir neden varsa sınırlı sayıda yeniden dene ve bunu belirt. Çalıştırılmamış, environment yüzünden çalıştırılamamış, yarıda kalmış veya sonucu belirsiz testi başarılı diye kaydetme; gerektiğinde `Doğrulanması gerekiyor`, `Çalıştırılamadı`, `Environment nedeniyle doğrulanamadı`, `Belirsiz`, `Kısmen doğrulandı` ifadelerini kullan.

### 11. Kod değişiklikleri ve belgeleme

Mevcut mimari ve kod stiline uy. Önemli bir teknik kararın ne olduğunu, nedenini ve etkisini bu dosyaya kısaca yaz. Yeni dosya, modül, endpoint, migration/şema değişikliği, dependency, environment variable, CLI komutu, önemli yapılandırma veya kullanım kuralı eklenirse gerektiği ölçüde burada belgele.

### 12. Hedef durumları

Gerçekten tamamlanan hedef `[x]`; kısmen tamamlanmış veya doğrulanmamış hedef `[x]` olmaz. Devam eden veya bekleyen hedef `[ ]` kalabilir, ama bunlar ileride otomatik sürdürülecek işler değil, yalnızca durum kaydıdır.

### 13. Bu dosyayı güncelleme

Dosyayı gereksiz yere silme veya baştan yazma; faydalı bilgiyi koru, yalnızca güncel olmayan, hatalı, eksik veya mevcut çalışmayla doğrudan ilgili yerleri düzenle. Aynı bilgiyi tekrar ekleme, dosyayı kontrolsüz büyütme. Uzun reasoning, geçici düşünce, ham terminal çıktısı, tekrar eden veya doğrulanmamış bilgi ekleme. Normalde görev başında kontrol et, kalıcı bir karar gerektiğinde güncelle, görev sonunda son kez kontrol et.

### 14. Çalışma kaydı biçimi

Anlamlı çalışmalar en alttaki "Çalışma kayıtları" bölümüne şu biçimde eklenir (aynı gün aynı çalışma için tekrar eden kayıt açma, mevcut kaydı güncelle):

```markdown
### YYYY-MM-DD — Kısa çalışma başlığı

#### Amaç
Çözülmek istenen problem ve görevin sınırları.

#### Yapılanlar
- `dosya/yolu`: Değişiklik ve amacı.

#### Hedef durumu
- [x] Gerçekten tamamlanan hedef.
- [ ] Devam eden veya bekleyen hedef.

#### Teknik kararlar
- Karar ve gerekçesi.

#### Testler
- `komut`: Sonuç. Çalıştırılamayan test varsa nedeni.

#### Bilinen sorunlar ve sonraki adımlar
- Kalan sorun, risk veya ileride ele alınabilecek iş.
```

### 15. Belirsizlik ve doğruluk

Sorunları, belirsizlikleri, teknik borçları, riskleri ve doğrulanamayan varsayımları gizleme; ama yalnızca ihtimal olanı kesin problem gibi de sunma. Emin olmadığını `Belirsiz` veya `Doğrulanması gerekiyor` diye işaretle.

### 16. AI Generated şeffaflığı

Proje tamamen veya neredeyse tamamen AI ile ("vibe coding") yazıldıysa README'de görünür bir `AI Generated` işareti bulunur. Bu bir şeffaflık politikasıdır; doğrulanmış bir hukuki gereklilik olmadıkça "EU AI Act zorunlu kılıyor" diye sunma (hukuki uyum istenirse güncel resmi EU kaynaklarından doğrula). Etiket zaten varsa ikincisini ekleme, depoda olmayan bir görsele (ör. `assets/ai-generated.svg`) referans verme. Önemli ölçüde insan tarafından yazılmış projeyi kullanıcı istemedikçe "tamamen AI Generated" diye etiketleme.

### 17. Görev sonu kontrolü

Final cevabından önce: isteği tekrar oku; değişikliklerin isteği karşıladığını doğrula; `git diff` ile gereksiz değişiklik olup olmadığına bak; test durumunu kontrol et; bu dosyayı kontrol edip gerekiyorsa güncelle; tamamlanmış işi yeniden açacak yeni bir döngü başlatma.

### 18. Final cevap

Kısa ve somut: yapılan değişiklikler; `AGENTS.md` güncellendi mi; çalıştırılan testler ve sonuçları; çalıştırılamayan testler; kalan blocker, risk veya gerçekten kullanıcı kararı gereken noktalar. Görev bittiyse bunu açıkça söyle ve kendiliğinden yeni hedef üretme.

### Kaynak kodunu okuma politikası

Bütün kaynak kodunu baştan sona okuma. Önce `README.md`, bu dosya, dizin yapısı, gerekiyorsa dependency/yapılandırma dosyaları ve görevle doğrudan ilgili entry point ve modüllerle bağlamı kur; sonra kodu ihtiyaç oldukça ve seçici oku. Bir dosyayı yalnızca görevin davranışını doğrudan etkiliyorsa, değişmesi gerekebilecekse, çağrı zincirinin parçasıysa, kullanılan bir API/veri modelini tanımlıyorsa, hatayı anlamak ya da test/build davranışını açıklamak için gerekiyorsa oku. Tamamı gerekmiyorsa ilgili fonksiyon, sınıf veya bölümle yetin. Değişmemiş bir dosyayı yeniden okuma; compaction sonrasında projeyi baştan tarama, önce görev durumu, `git diff` ve ilgili dosyalarla bağlamı geri kazan.

**Amaç maksimum kod okumak değil, görevi güvenilir biçimde tamamlamak için gereken minimum yeterli bağlamı toplamaktır.**

## Çalışma kayıtları

### 2026-10-04 — AGENTS.md oluşturuldu

#### Amaç
Kullanıcının "Codex Proje Çalışma Talimatları"na uygun bir `AGENTS.md` oluşturmak (`/init`). Kod davranışı değişmez; kapsam yalnızca belgeler.

#### Yapılanlar
- `AGENTS.md`: Proje özeti, dizin yapısı, komutlar, CI, kalıcı kurallar, bilinen sorunlar ve kullanıcının çalışma kuralları.
- `CLAUDE.md`: Claude oturumlarının da bu dosyayı okuması için `@AGENTS.md` yönlendirmesi.

#### Hedef durumu
- [x] `AGENTS.md` ve `CLAUDE.md` oluşturuldu.

#### Teknik kararlar
- Kurallar tek kaynak olsun diye `AGENTS.md`'de tutulur; `CLAUDE.md` yalnızca ona yönlendirir.
- README'ye `AI Generated` işareti eklenmedi: proje kullanıcının kendi koduyla başladı, yalnızca bir kısmı AI yardımıyla yazıldı (kural 16).

#### Testler
- `./tests/cli.sh`: Tümü geçti.
- `shellcheck`: Bulut ortamında kurulu olmadığı için yerelde çalıştırılamadı; CI'da çalışır. Betiklere dokunulmadı.

#### Bilinen sorunlar ve sonraki adımlar
- Yukarıdaki "Bilinen sorunlar" bölümüne bak.
