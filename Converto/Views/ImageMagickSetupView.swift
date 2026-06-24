import SwiftUI

struct ImageMagickSetupView: View {
    @Bindable var viewModel: ConverterViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Label {
                    Text(.imageMagickRequired)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                .font(.title2)
                .foregroundStyle(.primary)

                Text(viewModel.imageMagickError ?? L10n.imageMagickNotFoundOnMac)
                    .foregroundStyle(.secondary)

                Text(.installWithHomebrew)
                    .font(.headline)

                Text(L10n.brewInstallCommand)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(.customPathHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Spacer()
                    Button {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } label: {
                        Text(.openSettings)
                    }
                    Button {
                        viewModel.refreshImageMagick()
                    } label: {
                        Text(.retry)
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
