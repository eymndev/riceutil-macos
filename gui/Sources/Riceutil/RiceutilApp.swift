import SwiftUI

@main
struct RiceutilApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("Riceutil") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 860, minHeight: 560)
        }
        .windowResizability(.contentMinSize)
    }
}

enum Page: String, CaseIterable, Identifiable {
    case overview, wallpaper, configs, doctor, homebrew

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Genel"
        case .wallpaper: return "Duvar Kağıdı"
        case .configs: return "Kısayollar ve WM"
        case .doctor: return "Tanılama"
        case .homebrew: return "Homebrew"
        }
    }

    var symbol: String {
        switch self {
        case .overview: return "gauge"
        case .wallpaper: return "photo.on.rectangle"
        case .configs: return "keyboard"
        case .doctor: return "stethoscope"
        case .homebrew: return "shippingbox"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: AppModel
    @State private var page: Page? = .overview

    var body: some View {
        NavigationSplitView {
            List(Page.allCases, selection: $page) { page in
                Label(page.title, systemImage: page.symbol).tag(page)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            Group {
                switch page ?? .overview {
                case .overview: OverviewView(page: $page)
                case .wallpaper: WallpaperView()
                case .configs: ConfigsView()
                case .doctor: DoctorView()
                case .homebrew: HomebrewView()
                }
            }
            .navigationTitle((page ?? .overview).title)
            .toolbar {
                ToolbarItem {
                    if let busy = model.busy {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(busy).foregroundStyle(.secondary)
                        }
                    }
                }
                ToolbarItem {
                    Button {
                        Task { await model.refresh() }
                    } label: {
                        Label("Yenile", systemImage: "arrow.clockwise")
                    }
                    .keyboardShortcut("r")
                }
            }
        }
        .task { await model.refresh() }
        .alert("riceutil", isPresented: Binding(
            get: { model.lastError != nil },
            set: { if !$0 { model.lastError = nil } }
        )) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(model.lastError ?? "")
        }
    }
}
