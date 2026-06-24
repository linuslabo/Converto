import SwiftUI

struct SidebarView: View {
    @Bindable var viewModel: ConverterViewModel

    var body: some View {
        Form {
            Section("Output") {
                Picker("Format", selection: $viewModel.selectedFormatID) {
                    ForEach(viewModel.visibleFormats) { format in
                        Text(format.displayName).tag(format.id)
                    }
                }

                Picker("Folder", selection: $viewModel.folderMode) {
                    Text("Same as source").tag(OutputFolderMode.sameAsSource)
                    Text("Choose folder…").tag(OutputFolderMode.custom)
                }

                if viewModel.folderMode == .custom {
                    HStack {
                        Text(viewModel.customOutputFolder?.path ?? "No folder selected")
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Browse…") {
                            chooseOutputFolder()
                        }
                    }
                }
            }

            Section("Quality") {
                HStack {
                    Slider(value: $viewModel.quality, in: 0...100, step: 1)
                    Text("\(Int(viewModel.quality.rounded()))")
                        .monospacedDigit()
                        .frame(width: 28, alignment: .trailing)
                }
                Text("Maps to ImageMagick -quality. Effect varies by format.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                if viewModel.isConverting {
                    ProgressView(value: viewModel.progress) {
                        Text("Converting \(viewModel.completedCount) of \(viewModel.jobs.count)")
                    }
                }

                Button {
                    Task { await viewModel.convertAll() }
                } label: {
                    let count = viewModel.convertibleJobCount
                    if count == 0 {
                        Text("Convert")
                    } else {
                        Text("Convert \(count) image\(count == 1 ? "" : "s")")
                    }
                }
                .disabled(!viewModel.canConvert)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Converto")
    }

    private func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Choose"
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.customOutputFolder = url
        }
    }
}

#Preview {
    SidebarView(viewModel: ConverterViewModel())
        .frame(width: 260)
}
