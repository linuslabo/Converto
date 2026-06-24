import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct DropZoneView: View {
    @Bindable var viewModel: ConverterViewModel
    @State private var isTargeted = false

    private let dropTypes: [UTType] = [.fileURL, .image, .url]

    var body: some View {
        VStack(spacing: 0) {
            dropArea
            Divider()
            jobList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .onDrop(of: dropTypes, delegate: FileDropDelegate(isTargeted: $isTargeted) { urls in
            viewModel.addFiles(urls: urls)
        })
    }

    private var dropArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.4),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isTargeted ? Color.accentColor.opacity(0.08) : Color.clear)
                )
                .padding()

            VStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("Drop images here")
                    .font(.title3)
                Text("or click to browse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 160)
        .contentShape(Rectangle())
        .onTapGesture { openFilePanel() }
    }

    private var jobList: some View {
        Group {
            if viewModel.jobs.isEmpty {
                VStack {
                    Spacer()
                    Text("No images added yet")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.jobs) { job in
                        JobRowView(job: job)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.removeJob(id: viewModel.jobs[index].id)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if !viewModel.jobs.isEmpty {
                    Button("Clear") {
                        viewModel.clearJobs()
                    }
                    .disabled(viewModel.isConverting)
                }
            }
        }
    }

    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [.image]
        if panel.runModal() == .OK {
            viewModel.addFiles(urls: panel.urls)
        }
    }
}

private struct FileDropDelegate: DropDelegate {
    @Binding var isTargeted: Bool
    let onURLsDropped: ([URL]) -> Void

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.fileURL, .image, .url])
    }

    func dropEntered(info: DropInfo) {
        isTargeted = true
    }

    func dropExited(info: DropInfo) {
        isTargeted = false
    }

    func performDrop(info: DropInfo) -> Bool {
        isTargeted = false
        let providers = info.itemProviders(for: [.fileURL, .image, .url])
        guard !providers.isEmpty else { return false }

        let group = DispatchGroup()
        var collected: [URL] = []
        let lock = NSLock()

        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                group.enter()
                provider.loadObject(ofClass: URL.self) { object, _ in
                    defer { group.leave() }
                    guard let url = object as? URL else { return }
                    lock.lock()
                    collected.append(url)
                    lock.unlock()
                }
                continue
            }

            for type in [UTType.fileURL, UTType.url, UTType.image] {
                guard provider.hasItemConformingToTypeIdentifier(type.identifier) else { continue }
                group.enter()
                provider.loadItem(forTypeIdentifier: type.identifier, options: nil) { item, _ in
                    defer { group.leave() }
                    guard let url = urlFromDropItem(item) else { return }
                    lock.lock()
                    collected.append(url)
                    lock.unlock()
                }
                break
            }
        }

        group.notify(queue: .main) {
            onURLsDropped(collected)
        }

        return true
    }

    private func urlFromDropItem(_ item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }
        if let nsurl = item as? NSURL {
            return nsurl as URL
        }
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }
        return nil
    }
}

private struct JobRowView: View {
    let job: ConversionJob

    var body: some View {
        HStack(spacing: 10) {
            FileThumbnailView(url: job.inputURL)
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(job.fileName)
                    .lineLimit(1)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch job.status {
        case .pending: return "clock"
        case .converting: return "arrow.triangle.2.circlepath"
        case .done: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch job.status {
        case .pending: return .secondary
        case .converting: return .accentColor
        case .done: return .green
        case .failed: return .orange
        }
    }

    private var subtitle: String? {
        switch job.status {
        case .pending, .converting:
            return nil
        case .done(let outputURL):
            return outputURL.path
        case .failed(let message):
            return message
        }
    }
}

private struct FileThumbnailView: View {
    let url: URL
    @State private var thumbnail: NSImage?

    var body: some View {
        Group {
            if let thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 36, height: 36)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color.secondary.opacity(0.2))
        )
        .task(id: url) {
            thumbnail = NSImage(contentsOf: url)
        }
    }
}

#Preview {
    DropZoneView(viewModel: ConverterViewModel())
}
