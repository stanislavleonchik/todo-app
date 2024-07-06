import SwiftUI

@main
struct TodoApp: App {
    @StateObject private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            TodoView()
                .environmentObject(viewModel)
        }
    }
}
