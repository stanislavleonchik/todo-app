import SwiftUI
import SwiftData

@main
struct TodoApp: App {
    @StateObject private var viewModel = ListTodoitemsViewModel()
    private let modelContainer = try! ModelContainer(for: Todoitem.self)


    var body: some Scene {
        WindowGroup {
            TodoView()
                .environmentObject(viewModel)
        }
        .modelContainer(modelContainer)
    }
}
