import Foundation
import AppKit
import Observation

@Observable
@MainActor
final class ConverterViewModel {
    var jobs: [ConversionJob] = []
    var allFormats: [ImageFormat] = []
    var visibleFormatIDs: [String] = FormatRegistry.loadVisibleFormatIDs()
    var selectedFormatID: String = "JPEG"
    var folderMode: OutputFolderMode = .sameAsSource
    var customOutputFolder: URL?
    var quality: Double = 85
    var isConverting = false
    var magickURL: URL?
    var imageMagickError: String?
    var showFormatSettings = false
    var showOutputFolderButton = false

    var visibleFormats: [ImageFormat] {
        let idSet = Set(visibleFormatIDs.map { $0.uppercased() })
        let filtered = allFormats.filter { idSet.contains($0.id) }
        if filtered.isEmpty {
            return allFormats.filter { ImageFormat.defaultVisibleFormatIDs.contains($0.id) }
        }
        return filtered
    }

    var selectedFormat: ImageFormat? {
        visibleFormats.first { $0.id == selectedFormatID.uppercased() }
            ?? visibleFormats.first
    }

    var canConvert: Bool {
        convertibleJobCount > 0 && !isConverting && magickURL != nil && selectedFormat != nil
            && (folderMode == .sameAsSource || customOutputFolder != nil)
    }

    var convertibleJobCount: Int {
        jobs.filter {
            switch $0.status {
            case .pending, .failed: return true
            default: return false
            }
        }.count
    }

    var completedCount: Int {
        jobs.filter {
            if case .done = $0.status { return true }
            return false
        }.count
    }

    var progress: Double {
        guard !jobs.isEmpty else { return 0 }
        let finished = jobs.filter {
            switch $0.status {
            case .done, .failed: return true
            default: return false
            }
        }.count
        return Double(finished) / Double(jobs.count)
    }

    init() {
        refreshImageMagick()
    }

    func refreshImageMagick() {
        guard let url = ImageMagickLocator.locate(), ImageMagickLocator.verify(at: url) else {
            magickURL = nil
            imageMagickError = ConversionError.imageMagickNotFound.errorDescription
            allFormats = fallbackFormats()
            normalizeSelectedFormat()
            return
        }

        magickURL = url
        imageMagickError = nil

        do {
            allFormats = try FormatRegistry.fetchWritableFormats(magickURL: url)
        } catch {
            allFormats = fallbackFormats()
            imageMagickError = error.localizedDescription
        }

        normalizeSelectedFormat()
    }

    func setCustomMagickPath(_ path: String) {
        ImageMagickLocator.customPath = path
        refreshImageMagick()
    }

    func addFiles(urls: [URL]) {
        for url in urls where isImageFile(url) {
            let normalized = normalizedURL(url)
            if let index = jobs.firstIndex(where: { normalizedURL($0.inputURL) == normalized }) {
                if case .converting = jobs[index].status { continue }
                jobs[index].status = .pending
            } else {
                jobs.append(ConversionJob(inputURL: url))
            }
        }
    }

    func removeJob(id: UUID) {
        removeJobs(ids: [id])
    }

    func removeJobs(ids: Set<UUID>) {
        jobs.removeAll { job in
            guard ids.contains(job.id) else { return false }
            if case .converting = job.status { return false }
            return true
        }
    }

    func clearJobs() {
        guard !isConverting else { return }
        jobs.removeAll()
        showOutputFolderButton = false
    }

    func updateVisibleFormats(_ ids: [String]) {
        visibleFormatIDs = ids.map { $0.uppercased() }
        FormatRegistry.saveVisibleFormatIDs(visibleFormatIDs)
        normalizeSelectedFormat()
    }

    func convertAll() async {
        guard let magickURL, let format = selectedFormat else { return }
        guard folderMode == .sameAsSource || customOutputFolder != nil else { return }

        isConverting = true
        showOutputFolderButton = false

        let settings = ConversionSettings(
            outputFormat: format,
            folderMode: folderMode,
            customOutputFolder: customOutputFolder,
            quality: Int(quality.rounded())
        )

        let converter = ImageMagickConverter(magickURL: magickURL)
        let maxConcurrency = min(4, ProcessInfo.processInfo.activeProcessorCount)
        let pendingWork: [(index: Int, inputURL: URL)] = jobs.indices.compactMap { index in
            guard case .pending = jobs[index].status else { return nil }
            return (index, jobs[index].inputURL)
        }

        for item in pendingWork {
            jobs[item.index].status = .converting
        }

        await withTaskGroup(of: (Int, Result<URL, Error>).self) { group in
            var iterator = pendingWork.makeIterator()
            var inFlight = 0

            func enqueueNext() {
                guard inFlight < maxConcurrency, let item = iterator.next() else { return }
                inFlight += 1
                let index = item.index
                let inputURL = item.inputURL

                group.addTask {
                    do {
                        let outputURL = try settings.outputURL(for: inputURL)
                        try converter.convert(
                            inputURL: inputURL,
                            outputURL: outputURL,
                            quality: settings.quality
                        )
                        return (index, .success(outputURL))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }

            for _ in 0..<maxConcurrency {
                enqueueNext()
            }

            while let result = await group.next() {
                inFlight -= 1
                let index = result.0

                switch result.1 {
                case .success(let outputURL):
                    jobs[index].status = .done(outputURL: outputURL)
                case .failure(let error):
                    jobs[index].status = .failed(message: error.localizedDescription)
                }

                enqueueNext()
            }
        }

        isConverting = false
        showOutputFolderButton = completedCount > 0
    }

    func openOutputFolder() {
        let outputURLs = jobs.compactMap { job -> URL? in
            if case .done(let url) = job.status { return url }
            return nil
        }
        guard !outputURLs.isEmpty else { return }

        if folderMode == .custom, let customOutputFolder {
            NSWorkspace.shared.open(customOutputFolder)
        } else if outputURLs.count == 1, let url = outputURLs.first {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.activateFileViewerSelecting(outputURLs)
        }
    }

    private func normalizeSelectedFormat() {
        if visibleFormats.contains(where: { $0.id == selectedFormatID.uppercased() }) {
            selectedFormatID = selectedFormatID.uppercased()
            return
        }
        selectedFormatID = visibleFormats.first?.id ?? "JPEG"
    }

    private func normalizedURL(_ url: URL) -> URL {
        url.standardizedFileURL.resolvingSymlinksInPath()
    }

    private func isImageFile(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            return false
        }
        return true
    }

    private func fallbackFormats() -> [ImageFormat] {
        ImageFormat.defaultVisibleFormatIDs.map {
            ImageFormat(id: $0, description: $0)
        }
    }
}
