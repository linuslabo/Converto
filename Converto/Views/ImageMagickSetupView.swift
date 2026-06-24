import SwiftUI

struct ImageMagickSetupView: View {
    @Bindable var viewModel: ConverterViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Label("ImageMagick required", systemImage: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)

                Text(viewModel.imageMagickError ?? "ImageMagick 7 was not found on this Mac.")
                    .foregroundStyle(.secondary)

                Text("Install with Homebrew:")
                    .font(.headline)

                Text("brew install imagemagick")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text("Or set a custom path in Converto → Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Spacer()
                    Button("Open Settings") {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    Button("Retry") {
                        viewModel.refreshImageMagick()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
            .frame(maxWidth: 420)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 20)
            .padding()
        }
    }
}

#Preview {
    ImageMagickSetupView(viewModel: ConverterViewModel())
}
