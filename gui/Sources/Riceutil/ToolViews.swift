import AppKit
import SwiftUI

struct ConfigsView: View {
    @EnvironmentObject private var model: AppModel

    private let modes = [("mac", "macOS"), ("yabai", "yabai"), ("stage-manager", "Stage Manager")]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                row(kind: "binds", title: "skhd kısayolları", symbol: "command", reload: "binds")
                row(kind: "wm", title: "yabai pencere yöneticisi", symbol: "rectangle.split.3x1", reload: "wm")
                Card(title: "Pencere yöneticisi modu", symbol: "macwindow.on.rectangle") {
                    Text("macOS ve Stage Manager modları yabai'yi durdurur; Stage Manager değişince Dock kısa süre yeniden başlar.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        ForEach(modes, id: \.0) { mode in
                            Button(mode.1) { Task { await model.stream("Mod: \(mode.1)", ["wm", "mode", mode.0]) } }
                        }
                        Spacer()
                        Button("skhd ve yabai'yi yeniden yükle") { Task { await model.stream("Yeniden yükleniyor", ["reload"]) } }
                    }
                    .disabled(model.busy != nil)
                }
                row(kind: "kitty", title: "Kitty", symbol: "terminal", reload: nil)
                row(kind: "zsh", title: "Zsh", symbol: "chevron.left.forwardslash.chevron.right", reload: nil)
                if !model.log.isEmpty {
                    LogView(text: model.log).frame(minHeight: 140, maxHeight: 260)
                }
            }
            .padding(20)
        }
    }

    private func row(kind: String, title: String, symbol: String, reload: String?) -> some View {
        let path = model.configPath(kind)
        let exists = !path.isEmpty && FileManager.default.fileExists(atPath: path)
        return Card(title: title, symbol: symbol) {
            Text(path.isEmpty ? "…" : path)
                .font(.system(.callout, design: .monospaced))
                .textSelection(.enabled)
            if !exists {
                Text("Dosya henüz yok, açınca oluşturulur.").font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Button("Terminalde aç") { model.openInTerminal(kind) }
                Button("Düzenleyicide aç") { model.openInEditor(kind) }
                Button("Finder'da göster") { model.revealInFinder(kind) }.disabled(!exists)
                if let reload {
                    Button("Yeniden yükle") { Task { await model.stream("Yeniden yükleniyor", [reload, "reload"]) } }
                        .disabled(model.busy != nil)
                }
            }
        }
    }
}

struct DoctorView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Tanılamayı çalıştır") { Task { await model.runDoctor() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy != nil)
                Button("Kopyala") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(model.doctorOutput, forType: .string)
                }
                .disabled(model.doctorOutput.isEmpty)
                Button("Kaydet…") { model.saveDoctor() }.disabled(model.doctorOutput.isEmpty)
                Spacer()
            }
            Text("yabai/skhd sürümleri, servisleri, config dosyaları ve logları. Paylaşmadan önce config içindeki özel bilgileri gözden geçir.")
                .font(.callout)
                .foregroundStyle(.secondary)
            LogView(text: model.doctorOutput)
        }
        .padding(20)
    }
}

struct HomebrewView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("brew update ve upgrade") { Task { await model.stream("Homebrew", ["update"]) } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy != nil || model.value("brew.path").isEmpty)
                Spacer()
            }
            Text(model.value("brew.path").isEmpty
                 ? "Homebrew bulunamadı: https://brew.sh"
                 : "Sırayla brew update ve brew upgrade çalışır; brew cleanup çalışmaz.")
                .font(.callout)
                .foregroundStyle(.secondary)
            LogView(text: model.log)
        }
        .padding(20)
    }
}
