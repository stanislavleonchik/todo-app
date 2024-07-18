import SwiftUI
import FileCacheUnit

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var selectedItem: Todoitem?
    @Binding var showModal: Bool

    func makeUIViewController(context: Context) -> CalendarViewController {
        let calendarVC = CalendarViewController()
        calendarVC.viewModel = viewModel
        calendarVC.delegate = context.coordinator
        return calendarVC
    }

    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CalendarViewControllerDelegate {
        var parent: CalendarViewControllerWrapper

        init(_ parent: CalendarViewControllerWrapper) {
            self.parent = parent
        }

        func didSelectTodoItem(_ item: Todoitem) {
            parent.selectedItem = item
            parent.showModal = true
        }
    }
}
