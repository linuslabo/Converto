import SwiftUI

struct AppSettingsView: View {
    @Bindable var viewModel: ConverterViewModel
    @State private var customPath: String = ImageMagickLocator.customPath ?? ""

    var body: some View {
        Form {
            Section {
                if let magickURL = viewModel.magickURL {
                    LabeledContent(String(localized: .detected)) {
                        Text(magickURL.path)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                } else {
                    Text(.notDetected)
                        .foregroundStyle(.secondary)
                }

                TextField(
                    String(localized: .customMagickPath),
                    text: $customPath,
                    prompt: Text(.magickPathPlaceholder)
                )
                .textFieldStyle(.roundedBorder)

                HStack {
                    Button {
                        viewModel.setCustomMagickPath(customPath)
                    } label: {
                        Text(.apply)
                    }
                    Button {
                        customPath = ""
                        viewModel.setCustomMagickPath("")
                    } label: {
                        Text(.clear)
                    }
                    Spacer()
                    Button {
                        viewModel.refreshImageMagick()
                    } label: {
                        Text(.refresh)
                    }
                }
            } header: {
                Text(.sectionImageMagick)
            }

            Section {
                Link(destination: URL(string: "https://imagemagick.org")!) {
                    Text(.imageMagickDocs)
                }
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
