import Foundation

struct ImageFormat: Identifiable, Hashable, Codable {
    let id: String
    let description: String
    let fileExtension: String

    init(id: String, description: String) {
        self.id = id.uppercased()
        self.description = description
        self.fileExtension = ImageFormat.extensionForFormat(id)
    }

    static let defaultVisibleFormatIDs = [
        "PNG", "JPEG", "GIF", "WEBP", "HEIC", "SVG", "TIFF", "AVIF"
    ]

    static func extensionForFormat(_ formatID: String) -> String {
        switch formatID.uppercased() {
        case "JPEG", "JPG": return "jpg"
        case "TIF": return "tif"
        default: return formatID.lowercased()
        }
    }

    var displayName: String {
        id
    }
}
