import AppKit
import SwiftUI

/// Config dosyasını düz UTF-8 metin olarak okur ve yazar. Zengin metin (RTF) hiç devreye girmez.
struct ConfigFile {
    let url: URL

    init(path: String) {
        // Dotfile depolarında config çoğu zaman bir bağlantıdır: bağlantının kendisini değil, hedefini yaz
        url = URL(fileURLWithPath: path).resolvingSymlinksInPath()
    }

    var exists: Bool { FileManager.default.fileExists(atPath: url.path) }

    /// TextEdit'in yanına bırakmış olabileceği zengin metin kopyası (ör. skhdrc.rtf)
    var rtfSibling: URL? {
        let sibling = url.appendingPathExtension("rtf")
        return FileManager.default.fileExists(atPath: sibling.path) ? sibling : nil
    }

    func read() throws -> String {
        guard exists else { return "" }
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw ConfigError.notUTF8(url.path)
        }
        return text
    }

    func write(_ text: String) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data(text.utf8).write(to: url, options: .atomic)
    }

    static func isRTF(_ text: String) -> Bool { text.hasPrefix("{\\rtf") }

    /// RTF içeriğinden düz metni çıkarır
    static func plainText(fromRTF text: String) -> String? {
        guard let data = text.data(using: .utf8),
              let attributed = NSAttributedString(rtf: data, documentAttributes: nil) else { return nil }
        return attributed.string
    }
}

enum ConfigError: LocalizedError {
    case notUTF8(String)

    var errorDescription: String? {
        switch self {
        case .notUTF8(let path): return "\(path) UTF-8 düz metin değil; bozulmasın diye açılmadı."
        }
    }
}

/// Config düzenleme penceresi: eş aralıklı yazı, akıllı tırnak ve otomatik düzeltme kapalı.
struct ConfigEditorSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    let kind: String
    let title: String
    let reload: String?

    @State private var text = ""
    @State private var original = ""
    @State private var loadError: String?
    @State private var saveError: String?
    @State private var confirmClose = false

    private var file: ConfigFile { ConfigFile(path: model.configPath(kind)) }
    private var dirty: Bool { text != original }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.headline)
                Text(file.url.path)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
                Spacer()
                if dirty { Text("Kaydedilmedi").font(.caption).foregroundStyle(.orange) }
            }

            if let loadError {
                Label(loadError, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
            } else {
                if ConfigFile.isRTF(text) {
                    HStack {
                        Label("Bu dosya RTF (zengin metin) olarak kaydedilmiş; skhd/yabai bunu okuyamaz.", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Düz metne çevir") {
                            if let plain = ConfigFile.plainText(fromRTF: text) { text = plain }
                        }
                    }
                }
                if let sibling = file.rtfSibling {
                    HStack {
                        Text("Yanında \(sibling.lastPathComponent) var; o bir TextEdit kopyası, kullanılmıyor.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Finder'da göster") { NSWorkspace.shared.activateFileViewerSelecting([sibling]) }
                            .controlSize(.small)
                    }
                }
                PlainTextEditor(text: $text)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.25)))
            }

            if let saveError {
                Text(saveError).font(.caption).foregroundStyle(.red)
            }

            HStack {
                Button("Terminalde aç") { model.openInTerminal(kind) }
                Spacer()
                Button("Kapat") {
                    if dirty { confirmClose = true } else { dismiss() }
                }
                .keyboardShortcut(.cancelAction)
                Button("Kaydet") { save() }
                    .keyboardShortcut("s", modifiers: .command)
                    .disabled(!dirty || loadError != nil)
                if let reload {
                    Button("Kaydet ve yeniden yükle") {
                        if save() {
                            dismiss()
                            Task { await model.stream("Yeniden yükleniyor", [reload, "reload"]) }
                        }
                    }
                    // Return'e bağlanmaz: editörde Return yeni satır olmalı
                    .disabled(loadError != nil || model.busy != nil)
                }
            }
        }
        .padding(16)
        .frame(minWidth: 720, idealWidth: 880, minHeight: 480, idealHeight: 640)
        .onAppear(perform: load)
        .confirmationDialog("Değişiklikler kaydedilmedi", isPresented: $confirmClose) {
            Button("Kaydet ve kapat") { if save() { dismiss() } }
            Button("Kaydetmeden kapat", role: .destructive) { dismiss() }
            Button("Vazgeç", role: .cancel) {}
        }
    }

    private func load() {
        do {
            text = try file.read()
            original = text
        } catch {
            loadError = error.localizedDescription
        }
    }

    @discardableResult
    private func save() -> Bool {
        do {
            try file.write(text)
            original = text
            saveError = nil
            Task { await model.refresh() }
            return true
        } catch {
            saveError = "Kaydedilemedi: \(error.localizedDescription)"
            return false
        }
    }
}

/// Düz metin düzenleyici. SwiftUI TextEditor akıllı tırnak/tire ve otomatik düzeltmeyi
/// kapatmaya izin vermediği için doğrudan NSTextView kullanılır.
struct PlainTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }

        textView.isRichText = false
        textView.importsGraphics = false
        textView.usesFontPanel = false
        textView.usesRuler = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.smartInsertDeleteEnabled = false

        let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.font = font
        textView.typingAttributes = [.font: font, .foregroundColor: NSColor.textColor]
        textView.textContainerInset = NSSize(width: 6, height: 8)

        // Satırları kaydırma: config satırları olduğu gibi kalsın, yatay kaydırılsın
        textView.isHorizontallyResizable = true
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        textView.string = text
        textView.delegate = context.coordinator
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        private var text: Binding<String>

        init(text: Binding<String>) { self.text = text }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}
