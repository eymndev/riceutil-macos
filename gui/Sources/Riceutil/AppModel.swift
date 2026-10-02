import AppKit
import Foundation
import UniformTypeIdentifiers

struct WallpaperTheme: Identifiable, Hashable {
    let id: String
    let name: String
}

/// GUI'nin durumu. Her işlem riceutil komutuyla yapılır, sonra durum yeniden okunur.
@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var status: [String: String] = [:]
    @Published private(set) var themes: [WallpaperTheme] = []
    @Published private(set) var busy: String?
    @Published var log = ""
    @Published var doctorOutput = ""
    @Published var lastError: String?

    // MARK: Durum

    func value(_ key: String) -> String { status[key] ?? "" }
    func flag(_ key: String) -> Bool { value(key) == "1" }

    var wallpaperInstalled: Bool { !value("wallpaper.app").isEmpty }
    var wallpaperRunning: Bool { flag("wallpaper.running") }
    var currentTheme: String { value("wallpaper.theme") }
    var rotateMinutes: Int { Int(value("wallpaper.rotate")) ?? 0 }

    func refresh() async {
        let result = await Runner.run(["status", "--tsv"])
        status = Runner.parsePairs(result.output)
        if wallpaperInstalled {
            let list = await Runner.run(["wallpaper", "themes", "--tsv"])
            if list.ok {
                themes = list.output.split(separator: "\n").compactMap { line in
                    let parts = line.split(separator: "\t", omittingEmptySubsequences: false)
                    guard parts.count >= 2 else { return nil }
                    return WallpaperTheme(id: String(parts[0]), name: String(parts[1]))
                }
            }
        } else {
            themes = []
        }
    }

    /// Kısa bir komut çalıştırır; hata olursa mesajı gösterir, ardından durumu tazeler.
    func perform(_ args: [String]) async {
        let result = await Runner.run(args)
        if !result.ok {
            lastError = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        await refresh()
    }

    /// Uzun süren komut: çıktı `log`'a akar.
    func stream(_ title: String, _ args: [String]) async {
        guard busy == nil else { return }
        busy = title
        log = "$ riceutil \(args.joined(separator: " "))\n"
        let status = await Runner.stream(args) { [weak self] text in
            self?.log += text
        }
        log += status == 0 ? "\n✓ Bitti.\n" : "\n✗ Çıkış kodu \(status).\n"
        busy = nil
        await refresh()
    }

    // MARK: Duvar kağıdı

    func setTheme(_ id: String) async { await perform(["wallpaper", "theme", id]) }
    func nextTheme() async { await perform(["wallpaper", "next"]) }
    func setSwitch(_ name: String, _ on: Bool) async { await perform(["wallpaper", name, on ? "on" : "off"]) }
    func setRotation(_ minutes: Int) async { await perform(["wallpaper", "rotate", String(minutes)]) }
    func startWallpaper() async { await perform(["wallpaper", "start"]) }
    func stopWallpaper() async { await perform(["wallpaper", "stop"]) }
    func restartWallpaper() async { await perform(["wallpaper", "restart"]) }

    // MARK: Tanılama

    func runDoctor() async {
        guard busy == nil else { return }
        busy = "Tanılama"
        doctorOutput = await Runner.run(["doctor"]).output
        busy = nil
    }

    func saveDoctor() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "riceutil-doctor.txt"
        panel.allowedContentTypes = [.plainText]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try doctorOutput.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            lastError = error.localizedDescription
        }
    }

    // MARK: Config dosyaları

    /// kind: "binds" (skhd), "wm" (yabai), "kitty" ya da "zsh"
    func configPath(_ kind: String) -> String { value("\(kind).path") }

    /// Config'i açan riceutil komutunu Terminal'de çalıştırır (Vim ya da RICEUTIL_EDITOR).
    func openInTerminal(_ kind: String) {
        let command = kind == "binds" || kind == "wm" ? "\(kind) config" : kind
        let script = FileManager.default.temporaryDirectory.appendingPathComponent("riceutil-\(kind).command")
        let body = "#!/bin/bash\nexport PATH=\(shellQuote(Runner.environment["PATH"] ?? ""))\nexec /bin/bash \(shellQuote(Runner.scriptPath)) \(command)\n"
        do {
            try body.write(to: script, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: script.path)
            NSWorkspace.shared.open(script)
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Dosyayı varsayılan metin düzenleyicisinde açar; yoksa boş olarak oluşturur.
    func openInEditor(_ kind: String) {
        let path = configPath(kind)
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: path, contents: Data())
        }
        let editor = NSWorkspace.shared.urlForApplication(toOpen: url)
            ?? URL(fileURLWithPath: "/System/Applications/TextEdit.app")
        NSWorkspace.shared.open([url], withApplicationAt: editor, configuration: NSWorkspace.OpenConfiguration())
    }

    func revealInFinder(_ kind: String) {
        let path = configPath(kind)
        guard FileManager.default.fileExists(atPath: path) else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }

    private func shellQuote(_ s: String) -> String {
        "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
