import Foundation

struct FormatRegistry {
    static let visibleFormatsKey = "visibleFormatIDs"

    static func loadVisibleFormatIDs() -> [String] {
        if let stored = UserDefaults.standard.stringArray(forKey: visibleFormatsKey), !stored.isEmpty {
            return stored.map { $0.uppercased() }
        }
        return ImageFormat.defaultVisibleFormatIDs
    }

    static func saveVisibleFormatIDs(_ ids: [String]) {
        UserDefaults.standard.set(ids.map { $0.uppercased() }, forKey: visibleFormatsKey)
    }

    static func fetchWritableFormats(magickURL: URL) throws -> [ImageFormat] {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = magickURL
        process.arguments = ["-list", "format"]
        process.standardOutput = pipe
        process.standardError = Pipe()

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ConversionError.conversionFailed(L10n.listFormatsFailed())
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        return parseFormats(from: output)
    }

    static func parseFormats(from output: String) -> [ImageFormat] {
        var formats: [ImageFormat] = []
        var seen = Set<String>()

        for line in output.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("Format"), !trimmed.hasPrefix("-") else {
                continue
            }

            let parts = trimmed.split(whereSeparator: { $0.isWhitespace })
            guard parts.count >= 2 else { continue }

            let rawID = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "*"))
            let id = rawID.uppercased()
            let mode: String
            let description: String

            if parts.count >= 3, String(parts[2]).contains(where: { "rw+-".contains($0) }) {
                mode = String(parts[2])
                description = parts.count > 3 ? parts.dropFirst(3).joined(separator: " ") : id
            } else {
                mode = String(parts[1])
                description = parts.count > 2 ? parts.dropFirst(2).joined(separator: " ") : id
            }

            guard mode.contains("w"), !seen.contains(id) else { continue }

            formats.append(ImageFormat(id: id, description: String(description)))
            seen.insert(id)
        }

        return formats.sorted { $0.id < $1.id }
    }
}
