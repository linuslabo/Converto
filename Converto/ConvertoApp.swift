import SwiftUI

@main
struct ConvertoApp: App {
    @State private var viewModel = ConverterViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 720, minHeight: 480)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            AppSettingsView(viewModel: viewModel)
        }
    }
}
