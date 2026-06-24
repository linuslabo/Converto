import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: ConverterViewModel

    var body: some View {
        Form {
            Section {
                Picker(selection: $viewModel.selectedFormatID) {
                    ForEach(viewModel.visibleFormats) { format in
                        Text(format.displayName).tag(format.id)
                    }
                } label: {
                    Text(.format)
                }

                Picker(selection: $viewModel.folderMode) {
                    Text(.sameAsSource).tag(OutputFolderMode.sameAsSource)
                    Text(.chooseFolder).tag(OutputFolderMode.custom)
                } label: {
                    Text(.folder)
                }

                if viewModel.folderMode == .custom {
                    HStack {
                        Text(viewModel.customOutputFolder?.path ?? String(localized: .noFolderSelected))
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            chooseOutputFolder()
                        } label: {
                            Text(.browse)
                        }
                    }
                }
            } header: {
                Text(.sectionOutput)
            }

            Section {
                HStack {
                    Slider(value: $viewModel.quality, in: 0...100, step: 1)
                    Text("\(Int(viewModel.quality.rounded()))")
                        .monospacedDigit()
                        .frame(width: 28, alignment: .trailing)
                }
                Text(.qualityHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(.sectionQuality)
            }

            Section {
                if viewModel.isConverting {
                    ProgressView(value: viewModel.progress) {
                        Text(L10n.convertingProgress(
                            completed: viewModel.completedCount,
                            total: viewModel.jobs.count
                        ))
                    }
                }

                Button {
                    Task { await viewModel.convertAll() }
                } label: {
                    let count = viewModel.convertibleJobCount
                    if count == 0 {
                        Text(.convert)
                    } else {
                        Text(L10n.convertImages(count: count))
                    }
                }
                .disabled(!viewModel.canConvert)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                if viewModel.showOutputFolderButton {
                    Button {
                        viewModel.openOutputFolder()
                    } label: {
                        Label {
                            Text(.openOutputFolder)
                        } icon: {
                            Image(systemName: "folder")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: .appName))
    }

    private func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = String(localized: .browse)
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.customOutputFolder = url
        }
    }
}

#Preview {
    SidebarView(viewModel: ConverterViewModel())
        .frame(width: 260)
}
