import Foundation

struct ImageMagickLocator {
    private static let customPathKey = "customMagickPath"

    static var customPath: String? {
        get {
            let value = UserDefaults.standard.string(forKey: customPathKey)
            return value?.isEmpty == true ? nil : value
        }
        set {
            if let newValue, !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: customPathKey)
            } else {
                UserDefaults.standard.removeObject(forKey: customPathKey)
            }
        }
    }

    static func locate() -> URL? {
        if let custom = customPath {
            let url = URL(fileURLWithPath: custom)
            if FileManager.default.isExecutableFile(atPath: url.path) {
                return url
            }
        }

        let candidates = [
            "/opt/homebrew/bin/magick",
            "/usr/local/bin/magick",
            "/opt/local/bin/magick"
        ]

        for path in candidates {
            if FileManager.default.isExecutableFile(atPath: path) {
                return URL(fileURLWithPath: path)
            }
        }

        if let whichPath = runWhich("magick") {
            return URL(fileURLWithPath: whichPath)
        }

        return nil
    }

    static func verify(at url: URL) -> Bool {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = url
        process.arguments = ["-version"]
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return false }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            return output.contains("ImageMagick")
        } catch {
            return false
        }
    }

    private static func runWhich(_ command: String) -> String? {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [command]
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let path = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let path, !path.isEmpty else { return nil }
            return path
        } catch {
            return nil
        }
    }
}
