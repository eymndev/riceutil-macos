import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var model: AppModel
    @Binding var page: Page?

    private let columns = [GridItem(.adaptive(minimum: 260), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                tool("yabai", symbol: "rectangle.split.3x1", page: .configs)
                tool("skhd", symbol: "command", page: .configs)
                Card(title: "Homebrew", symbol: "shippingbox") {
                    if model.value("brew.path").isEmpty {
                        Text("Kurulu değil").foregroundStyle(.secondary)
                        Link("brew.sh", destination: URL(string: "https://brew.sh")!)
                    } else {
                        Text(model.value("brew.version")).foregroundStyle(.secondary)
                        Button("Paketleri güncelle…") { page = .homebrew }
                    }
                }
                Card(title: "Duvar Kağıdı", symbol: "photo.on.rectangle") {
                    if model.wallpaperInstalled {
                        StatusBadge(on: model.wallpaperRunning, text: model.wallpaperRunning ? "Çalışıyor" : "Kapalı")
                        Text("Tema: \(model.value("wallpaper.theme_name").isEmpty ? model.currentTheme : model.value("wallpaper.theme_name"))")
                        HStack {
                            Button("Sonraki tema") { Task { await model.nextTheme() } }
                            Button("Ayarlar…") { page = .wallpaper }
                        }
                    } else {
                        Text("ASCII Wallpaper kurulu değil").foregroundStyle(.secondary)
                        Button("Kur…") { page = .wallpaper }
                    }
                }
            }
            .padding(20)

            if !model.value("version").isEmpty {
                Text("riceutil \(model.value("version"))")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 16)
            }
        }
    }

    private func tool(_ name: String, symbol: String, page target: Page) -> some View {
        Card(title: name, symbol: symbol) {
            if model.value("\(name).path").isEmpty {
                Text("Kurulu değil").foregroundStyle(.secondary)
                Text("brew install koekeishiya/formulae/\(name)")
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
            } else {
                StatusBadge(on: model.flag("\(name).running"), text: model.flag("\(name).running") ? "Çalışıyor" : "Çalışmıyor")
                Text(model.value("\(name).version")).foregroundStyle(.secondary)
                Button("Config'i düzenle…") { page = target }
            }
        }
    }
}
