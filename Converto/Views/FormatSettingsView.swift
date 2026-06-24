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
                        String(localized: .noFormatsFound),
                        systemImage: "magnifyingglass",
                        description: Text(.formatSearchHint)
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
            .navigationTitle(String(localized: .visibleFormats))
            .searchable(text: $searchText, prompt: String(localized: .searchFormats))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(.done)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            applyPreset(ImageFormat.defaultVisibleFormatIDs)
                        } label: {
                            Text(.commonFormats)
                        }
                        Button {
                            applyPreset(viewModel.allFormats.map(\.id))
                        } label: {
                            Text(.selectAll)
                        }
                        Button {
                            selectedIDs = []
                            persist()
                        } label: {
                            Text(.clearAll)
                        }
                    } label: {
                        Text(.presets)
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
