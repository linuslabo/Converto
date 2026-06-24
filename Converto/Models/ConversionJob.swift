import Foundation

enum ConversionJobStatus: Equatable {
    case pending
    case converting
    case done(outputURL: URL)
    case failed(message: String)
}

struct ConversionJob: Identifiable {
    let id = UUID()
    let inputURL: URL
    var status: ConversionJobStatus = .pending

    var fileName: String {
        inputURL.lastPathComponent
    }
}
