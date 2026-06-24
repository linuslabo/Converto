import Foundation

enum OutputFolderMode: String, CaseIterable {
    case sameAsSource
    case custom
}

struct ConversionSettings {
    var outputFormat: ImageFormat
    var folderMode: OutputFolderMode
    var customOutputFolder: URL?
    var quality: Int

    func outputURL(for inputURL: URL) throws -> URL {
        let stem = inputURL.deletingPathExtension().lastPathComponent
        let ext = outputFormat.fileExtension
        let fileName = "\(stem).\(ext)"

        let directory: URL
        switch folderMode {
        case .sameAsSource:
            directory = inputURL.deletingLastPathComponent()
        case .custom:
            guard let customOutputFolder else {
                throw ConversionError.missingOutputFolder
            }
            directory = customOutputFolder
        }

        return directory.appendingPathComponent(fileName)
    }
}

enum ConversionError: LocalizedError {
    case missingOutputFolder
    case imageMagickNotFound
    case conversionFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingOutputFolder:
            return "Choose an output folder."
        case .imageMagickNotFound:
            return "ImageMagick was not found. Install it with: brew install imagemagick"
        case .conversionFailed(let message):
            return message
        }
    }
}
