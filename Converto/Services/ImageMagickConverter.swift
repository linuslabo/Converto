import Foundation

struct ImageMagickConverter {
    let magickURL: URL

    func convert(inputURL: URL, outputURL: URL, quality: Int) throws {
        let outputDirectory = outputURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = magickURL
        process.arguments = [
            inputURL.path,
            "-quality", String(quality),
            outputURL.path
        ]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stderr = String(data: stderrData, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            let message = stderr.isEmpty
                ? "Conversion failed with exit code \(process.terminationStatus)."
                : stderr
            throw ConversionError.conversionFailed(message)
        }
    }
}
