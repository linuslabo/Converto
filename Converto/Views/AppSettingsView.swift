import SwiftUI

struct AppSettingsView: View {
    @Bindable var viewModel: ConverterViewModel
    @State private var customPath: String = ImageMagickLocator.customPath ?? ""

    var body: some View {
        Form {
            Section("ImageMagick") {
                if let magickURL = viewModel.magickURL {
                    LabeledContent("Detected") {
                        Text(magickURL.path)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                } else {
                    Text("Not detected")
                        .foregroundStyle(.secondary)
                }

                TextField("Custom magick path", text: $customPath, prompt: Text("/opt/homebrew/bin/magick"))
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Apply") {
                        viewModel.setCustomMagickPath(customPath)
                    }
                    Button("Clear") {
                        customPath = ""
                        viewModel.setCustomMagickPath("")
                    }
                    Spacer()
                    Button("Refresh") {
                        viewModel.refreshImageMagick()
                    }
                }
            }

            Section {
                Link("ImageMagick documentation", destination: URL(string: "https://imagemagick.org")!)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480, height: 220)
        .padding()
    }
}

#Preview {
    AppSettingsView(viewModel: ConverterViewModel())
}
