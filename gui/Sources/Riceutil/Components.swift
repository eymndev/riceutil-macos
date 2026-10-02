import AppKit
import SwiftUI

/// Durum noktası ve metni
struct StatusBadge: View {
    let on: Bool
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(on ? Color.green : Color.secondary.opacity(0.5)).frame(width: 8, height: 8)
            Text(text).foregroundStyle(.secondary)
        }
    }
}

/// Komut çıktısı: eş aralıklı, seçilebilir, kendiliğinden sona kayan metin
struct LogView: View {
    let text: String

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(text.isEmpty ? " " : text)
                    .font(.system(.callout, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                Color.clear.frame(height: 1).id("end")
            }
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.25)))
            .onChange(of: text) { _ in
                proxy.scrollTo("end", anchor: .bottom)
            }
        }
    }
}

/// Başlıklı kart
struct Card<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol).font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2)))
    }
}
