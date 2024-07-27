import FileCacheUnit
import Foundation
import Combine
import SwiftUI

@MainActor
final class ListTodoitemsViewModel: ObservableObject {
    @Published var todoitems = FileCache<Todoitem>()
    @Published var categories: [TodoCategory] = []
    @Published var isShown: Bool = false
    @Published var sortOption: SortOption = .none
    @Published var filteredSortedItems: [Todoitem] = []
    @Published var isNetworkBusy: Bool = false

    private let networkingService: NetworkingService
    private var cancellables: Set<AnyCancellable> = []

    init(networkingService: NetworkingService = DefaultNetworkingService()) {
        self.networkingService = networkingService
        self.categories = [
            .work, .personal, .study, .other
        ]
        loadData()
        updateFilteredSortedItems()
    }

    var items: [Todoitem] {
        todoitems.items
    }

    private func loadData() {
        Task {
            isNetworkBusy = true
            defer { isNetworkBusy = false }
            do {
                let dtos = try await networkingService.fetchTodoList()
                let items = dtos.compactMap { Todoitem(dto: $0) }
                for item in items {
                    self.todoitems.addItem(item)
                }
                self.todoitems.revision = try await networkingService.fetchRevision()
                self.updateFilteredSortedItems()
            } catch {
                handleError(error)
            }
        }
    }

    func toggleItem(_ id: String) {
        if let item = self.todoitems[id] {
            let newItem = item.copyWith(isDone: !item.isDone)
            self.updateItem(id, newItem)
        }
    }

    func completeItem(_ id: String) {
        if let item = self.todoitems[id] {
            let newItem = item.copyWith(isDone: true)
            self.updateItem(id, newItem)
        }
    }

    func activateItem(_ id: String) {
        if let item = self.todoitems[id] {
            let newItem = item.copyWith(isDone: false)
            self.updateItem(id, newItem)
        }
    }

    func addItem(_ item: Todoitem) {
        self.todoitems[item.id] = item
        self.updateFilteredSortedItems()
        self.syncWithServer()
    }

    func removeItem(_ id: String) {
        self.todoitems[id] = nil
        self.updateFilteredSortedItems()
        self.syncWithServer()
    }

    func updateItem(_ id: String, _ item: Todoitem) {
        self.todoitems[id] = item
        self.updateFilteredSortedItems()
        self.syncWithServer()
    }

    private func updateFilteredSortedItems() {
        var filteredItems = self.isShown ? self.items.filter { !$0.isDone } : self.items
        switch self.sortOption {
        case .none:
            break
        case .addition:
            filteredItems.sort { $0.dateCreated < $1.dateCreated }
        case .importance:
            filteredItems.sort { $0.importance.rawValue > $1.importance.rawValue }
        }
        self.filteredSortedItems = filteredItems
    }

    func toggleShowCompleted() {
        self.isShown.toggle()
        updateFilteredSortedItems()
    }

    func sortBy(_ option: SortOption) {
        self.sortOption = option
        updateFilteredSortedItems()
    }

    func validateTodoitemDTO(_ dto: TodoitemDTO) -> Bool {
        guard !dto.id.isEmpty, !dto.text.isEmpty, !dto.importance.isEmpty, !dto.last_updated_by.isEmpty else {
            return false
        }
        return true
    }

    public func syncWithServer() {
        isNetworkBusy = true
        Task {
            defer { isNetworkBusy = false }
            do {
                let dtos = todoitems.items.map { $0.toDTO() }.filter { validateTodoitemDTO($0) }
                guard !dtos.isEmpty else {
                    throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid data in DTOs"])
                }
                let updatedItems = try await networkingService.updateTodoList(with: dtos, revision: todoitems.revision)
                let items = updatedItems.compactMap { Todoitem(dto: $0) }
                for item in items {
                    self.todoitems.addItem(item)
                }
                self.todoitems.revision = try await networkingService.fetchRevision()
                self.updateFilteredSortedItems()
                self.isNetworkBusy = false
                print("Sync with server successful")
            } catch {
                handleError(error)
                self.isNetworkBusy = false
                print("Sync with server failed: \(error.localizedDescription)")
            }
        }
    }

    private func handleError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
        if let urlError = error as? URLError {
            switch urlError.code {
            case .badServerResponse:
                print("Bad server response")
            case .timedOut:
                print("Request timed out")
            case .networkConnectionLost:
                print("Network connection lost")
            default:
                print("Other URL error: \(urlError.code)")
            }
        }
    }

    enum SortOption {
        case none, addition, importance
    }

    struct Section {
        let title: String
        var items: [Todoitem]
    }

    var sections: [Section] {
        let groupedItems = Dictionary(grouping: filteredSortedItems) { (item: Todoitem) -> String in
            if let date = item.deadline {
                return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            } else {
                return "Other"
            }
        }
        
        let sortedKeys = groupedItems.keys.sorted {
            if $0 == "Other" {
                return false
            }
            if $1 == "Other" {
                return true
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            guard let date1 = dateFormatter.date(from: $0), let date2 = dateFormatter.date(from: $1) else {
                return false
            }
            return date1 < date2
        }

        return sortedKeys.map { Section(title: $0, items: groupedItems[$0] ?? []) }
    }

    func addCategory(_ category: TodoCategory) -> Bool {
        guard !category.name.isEmpty else {
            print("Категория не может быть с пустым названием")
            return false
        }
        
        guard !categories.contains(where: { $0.name == category.name }) else {
            print("Категория с таким названием уже существует")
            return false
        }
        
        self.categories.append(category)
        return true
    }

    func removeCategory(_ category: TodoCategory) {
        self.categories.removeAll { $0.id == category.id }
    }

    func updateCategory(_ category: TodoCategory) {
        if let index = self.categories.firstIndex(where: { $0.id == category.id }) {
            self.categories[index] = category
        }
    }

    var completedCount: Int {
        return items.filter { $0.isDone }.count
    }
}
