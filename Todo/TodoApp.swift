import SwiftUI

@main
struct TodoApp: App {
    @StateObject private var viewModel = ListTodoitemsViewModel()

    var body: some Scene {
        WindowGroup {
            TodoView()
                .environmentObject(viewModel)
        }
    }
}
