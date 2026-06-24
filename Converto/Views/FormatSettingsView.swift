import SwiftUI

struct FormatSettingsView: View {
    @Bindable var viewModel: ConverterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if filteredFormats.isEmpty {
                    ContentUnavailableView(
                        "No formats found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search or refresh ImageMagick.")
                    )
                } else {
                    List {
                        ForEach(filteredFormats, id: \.id) { (format: ImageFormat) in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(format.displayName)
                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                if isEnabled(format) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggle(format)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Visible Formats")
            .searchable(text: $searchText, prompt: "Search formats")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu("Presets") {
                        Button("Common formats") {
                            applyPreset(ImageFormat.defaultVisibleFormatIDs)
                        }
                        Button("Select all") {
                            applyPreset(viewModel.allFormats.map(\.id))
                        }
                        Button("Clear all") {
                            selectedIDs = []
                            persist()
                        }
                    }
                }
            }
            .onAppear {
                selectedIDs = Set(viewModel.visibleFormatIDs.map { $0.uppercased() })
            }
        }
        .frame(minWidth: 420, minHeight: 480)
    }

    private var filteredFormats: [ImageFormat] {
        let formats = viewModel.allFormats
        guard !searchText.isEmpty else { return formats }
        let query = searchText.lowercased()
        return formats.filter {
            $0.id.lowercased().contains(query) || $0.description.lowercased().contains(query)
        }
    }

    private func isEnabled(_ format: ImageFormat) -> Bool {
        selectedIDs.contains(format.id)
    }

    private func toggle(_ format: ImageFormat) {
        if selectedIDs.contains(format.id) {
            selectedIDs.remove(format.id)
        } else {
            selectedIDs.insert(format.id)
        }
        persist()
    }

    private func applyPreset(_ ids: [String]) {
        selectedIDs = Set(ids.map { $0.uppercased() })
        persist()
    }

    private func persist() {
        let sorted = viewModel.allFormats
            .map(\.id)
            .filter { selectedIDs.contains($0) }
        viewModel.updateVisibleFormats(sorted.isEmpty ? ImageFormat.defaultVisibleFormatIDs : sorted)
    }
}

#Preview {
    FormatSettingsView(viewModel: ConverterViewModel())
}
