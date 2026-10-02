import Foundation

/// riceutil betiğini çalıştırır. GUI her zaman uygulama paketindeki kopyayı kullanır; böylece
/// GUI ile komut satırı aracı aynı sürümde kalır.
enum Runner {
    struct Result {
        let status: Int32
        let output: String
        var ok: Bool { status == 0 }
    }

    /// Paket içindeki betik; `swift run` ile geliştirirken depodaki betik.
    static var scriptPath: String {
        if let bundled = Bundle.main.url(forResource: "riceutil", withExtension: nil) {
            return bundled.path
        }
        let repo = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("riceutil")
        return repo.path
    }

    /// Uygulamalar Finder'dan açılınca PATH çok kısa olur; Homebrew ve ~/.local/bin eklenir.
    static var environment: [String: String] {
        var env = ProcessInfo.processInfo.environment
        let home = NSHomeDirectory()
        let paths = [
            "\(home)/.local/bin", "/opt/homebrew/bin", "/opt/homebrew/sbin", "/usr/local/bin",
            "/usr/bin", "/bin", "/usr/sbin", "/sbin", env["PATH"] ?? "",
        ]
        env["PATH"] = paths.filter { !$0.isEmpty }.joined(separator: ":")
        env["GIT_TERMINAL_PROMPT"] = "0" // parola sorusu GUI'de takılı kalmasın
        env["HOMEBREW_NO_COLOR"] = "1"
        env["NO_COLOR"] = "1"
        return env
    }

    private static func makeProcess(_ args: [String]) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath] + args
        process.environment = environment
        process.currentDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
        process.standardInput = FileHandle.nullDevice
        return process
    }

    /// Komutu çalıştırıp bütün çıktıyı (stdout + stderr) döner.
    static func run(_ args: [String]) async -> Result {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = makeProcess(args)
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                do {
                    try process.run()
                } catch {
                    continuation.resume(returning: Result(status: -1, output: error.localizedDescription))
                    return
                }
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                continuation.resume(returning: Result(status: process.terminationStatus, output: String(decoding: data, as: UTF8.self)))
            }
        }
    }

    /// Uzun süren komutlar için: çıktı geldikçe `onOutput` ana iş parçacığında çağrılır.
    static func stream(_ args: [String], onOutput: @escaping (String) -> Void) async -> Int32 {
        await withCheckedContinuation { continuation in
            let process = makeProcess(args)
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            let reader = pipe.fileHandleForReading
            reader.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty else { return }
                let text = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async { onOutput(text) }
            }
            process.terminationHandler = { process in
                reader.readabilityHandler = nil
                let rest = reader.readDataToEndOfFile()
                let text = String(decoding: rest, as: UTF8.self)
                DispatchQueue.main.async {
                    if !text.isEmpty { onOutput(text) }
                    continuation.resume(returning: process.terminationStatus)
                }
            }
            do {
                try process.run()
            } catch {
                reader.readabilityHandler = nil
                DispatchQueue.main.async {
                    onOutput(error.localizedDescription + "\n")
                    continuation.resume(returning: -1)
                }
            }
        }
    }

    /// `anahtar<TAB>değer` satırlarını sözlüğe çevirir.
    static func parsePairs(_ text: String) -> [String: String] {
        var result: [String: String] = [:]
        for line in text.split(separator: "\n", omittingEmptySubsequences: true) {
            let parts = line.split(separator: "\t", maxSplits: 1, omittingEmptySubsequences: false)
            guard let key = parts.first else { continue }
            result[String(key)] = parts.count > 1 ? String(parts[1]) : ""
        }
        return result
    }
}
