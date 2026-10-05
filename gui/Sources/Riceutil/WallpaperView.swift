import AppKit
import SwiftUI

struct WallpaperView: View {
    @EnvironmentObject private var model: AppModel

    private let columns = [GridItem(.adaptive(minimum: 210), spacing: 12)]
    private let rotations = [(0, "Kapalı"), (10, "10 dakika"), (30, "30 dakika"), (60, "1 saat")]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if model.wallpaperInstalled {
                    settings
                    packList
                    themeGrid
                }
                if !model.log.isEmpty {
                    LogView(text: model.log).frame(minHeight: 180, maxHeight: 320)
                }
            }
            .padding(20)
        }
    }

    private var header: some View {
        Card(title: "ASCII Wallpaper", symbol: "photo.on.rectangle") {
            if model.wallpaperInstalled {
                StatusBadge(on: model.wallpaperRunning, text: model.wallpaperRunning ? "Çalışıyor" : "Kapalı")
                Text(model.value("wallpaper.app"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            } else {
                Text("Henüz kurulu değil. Kur'a basınca depo indirilir, derlenir ve ~/Applications içine kurulur (Xcode Command Line Tools gerekir).")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                if model.wallpaperInstalled {
                    if model.wallpaperRunning {
                        Button("Durdur") { Task { await model.stopWallpaper() } }
                        Button("Yeniden başlat") { Task { await model.restartWallpaper() } }
                    } else {
                        Button("Başlat") { Task { await model.startWallpaper() } }
                            .keyboardShortcut(.defaultAction)
                    }
                    Button("Güncelle") { Task { await model.stream("Güncelleniyor", ["wallpaper", "update"]) } }
                    Button("Ekran koruyucuyu kur") { Task { await model.stream("Ekran koruyucu", ["wallpaper", "saver"]) } }
                } else {
                    Button("Kur") { Task { await model.stream("Kuruluyor", ["wallpaper", "install"]) } }
                        .keyboardShortcut(.defaultAction)
                }
            }
            .disabled(model.busy != nil)
        }
    }

    private var settings: some View {
        Card(title: "Görünüm", symbol: "slider.horizontal.3") {
            Toggle("Sistem paneli", isOn: binding("panel", key: "wallpaper.panel"))
            Toggle("Saat", isOn: binding("clock", key: "wallpaper.clock"))
            Toggle("Köşede tema adı", isOn: binding("name", key: "wallpaper.name"))
            Picker("Temaları sırayla değiştir", selection: Binding(
                get: { model.rotateMinutes },
                set: { minutes in Task { await model.setRotation(minutes) } }
            )) {
                ForEach(rotations, id: \.0) { option in
                    Text(option.1).tag(option.0)
                }
            }
            .frame(maxWidth: 360)
        }
    }

    /// Klasik temalar uygulamayla gelir; Hyprland, Anime gibi paketler ayrı indirilir ve kaldırılabilir
    private var packList: some View {
        Card(title: "Tema paketleri", symbol: "shippingbox") {
            if model.packs.isEmpty {
                Text("Paketleri görmek için duvar kağıdını güncelle.")
                    .foregroundStyle(.secondary)
            }
            ForEach(model.packs) { pack in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pack.name).font(.body.weight(.semibold))
                        Text("\(pack.themeCount) tema · \(pack.summary)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    switch pack.state {
                    case .builtin:
                        Text("Dahili").foregroundStyle(.secondary)
                    case .installed:
                        Label("Kurulu", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                        Button("Kaldır") { Task { await model.removePack(pack.id) } }
                    case .available:
                        Button("İndir") { Task { await model.addPack(pack.id) } }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .disabled(model.busy != nil)
    }

    private struct ThemeGroup: Identifiable {
        let id: String // paket
        var themes: [WallpaperTheme]
    }

    /// Temalar paketlerine göre gruplanır (Klasik, sonra kurulu paketler)
    private var themeGroups: [ThemeGroup] {
        var groups: [ThemeGroup] = []
        for theme in model.themes {
            if let i = groups.firstIndex(where: { $0.id == theme.pack }) {
                groups[i].themes.append(theme)
            } else {
                groups.append(ThemeGroup(id: theme.pack, themes: [theme]))
            }
        }
        return groups
    }

    private var themeGrid: some View {
        Card(title: "Tema", symbol: "paintpalette") {
            HStack {
                Text("Tıklayınca hemen değişir.").foregroundStyle(.secondary)
                Spacer()
                Button("Sonraki tema") { Task { await model.nextTheme() } }
            }
            let groups = themeGroups
            ForEach(groups) { group in
                if groups.count > 1 {
                    Text(model.packName(group.id)).font(.subheadline.weight(.semibold)).padding(.top, 6)
                }
                LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                    ForEach(group.themes) { theme in
                        ThemeButton(theme: theme, preview: model.preview(for: theme), selected: theme.id == model.currentTheme) {
                            Task { await model.setTheme(theme.id) }
                        }
                    }
                }
            }
        }
    }

    private func binding(_ name: String, key: String) -> Binding<Bool> {
        Binding(
            get: { model.flag(key) },
            set: { on in Task { await model.setSwitch(name, on) } }
        )
    }
}

private struct ThemeButton: View {
    let theme: WallpaperTheme
    let preview: NSImage?
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(theme.name).font(.body.weight(selected ? .semibold : .regular)).lineLimit(1)
                Text(theme.id).font(.caption.monospaced()).foregroundStyle(.secondary)
                previewImage.padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(selected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? Color.accentColor : Color.clear, lineWidth: 1.5))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(theme.name)
    }

    /// Ekran oranında (16:10) küçük görsel; önizleme yoksa (eski kurulum) düz bir kutu
    private var previewImage: some View {
        Color.black
            .aspectRatio(16 / 10, contentMode: .fit)
            .overlay {
                if let preview {
                    Image(nsImage: preview).resizable().scaledToFill()
                } else {
                    Text("Önizleme için duvar kağıdını güncelle")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary.opacity(0.25)))
    }
}
