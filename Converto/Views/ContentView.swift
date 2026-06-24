import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Bindable var viewModel: ConverterViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 320)
        } detail: {
            DropZoneView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Formats…") {
                    viewModel.showFormatSettings = true
                }
            }
        }
        .sheet(isPresented: $viewModel.showFormatSettings) {
            FormatSettingsView(viewModel: viewModel)
        }
        .overlay {
            if viewModel.magickURL == nil {
                ImageMagickSetupView(viewModel: viewModel)
            }
        }
        .task {
            viewModel.refreshImageMagick()
        }
    }
}

#Preview {
    ContentView(viewModel: ConverterViewModel())
        .frame(width: 800, height: 500)
}
