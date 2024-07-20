import FileCacheUnit
import Foundation
import SwiftUI
import Combine

final class ViewModel: ObservableObject {
    @Published var todoitems = FileCache<Todoitem>()
    @Published var categories: [TodoCategory] = []
    @Published var isShown: Bool = false
    @Published var sortOption: SortOption = .none
    @Published var filteredSortedItems: [Todoitem] = []

    var data = [
        Todoitem(text: "Hello", isDone: true),
        Todoitem(text: "Hello", isDone: false),
        Todoitem(text: "Hello", importance: .important, isDone: true),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", importance: .important, isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", deadline: Date(), isDone: false),
        Todoitem(text: "Hello\nabacaba\nabacaba\nabacaba", importance: .low, isDone: false),
        Todoitem(text: "Купить бобы", importance: .low, deadline: Date(), isDone: false),
        Todoitem(text: "Купить сыр", importance: .low, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить молоко", importance: .low, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить йогурт", importance: .low, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .low, deadline: Date(timeIntervalSince1970: 150000000), isDone: false, category: .study),
        Todoitem(text: "Купить фарш", importance: .low, deadline: Date(timeIntervalSince1970: 150000000), isDone: false, category: .study),
        Todoitem(text: "Купить фарш", importance: .low, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false, category: .study),
        Todoitem(text: "Купить фарш", importance: .low, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false, category: .study),
        Todoitem(text: "Купить фарш", importance: .low, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false, category: .study),
    ]

    init() {
        categories = [
            TodoCategory(name: "Work", color: .red),
            TodoCategory(name: "Personal", color: .blue),
            TodoCategory(name: "Study", color: .green)
        ]
        for i in data {
            todoitems[i.id] = i
        }
        updateFilteredSortedItems()
    }

    var items: [Todoitem] {
        todoitems.items
    }

    func toggleItem(_ id: String) {
        DispatchQueue.main.async {
            self.todoitems[id]?.isDone.toggle()
            self.updateFilteredSortedItems()
        }
    }

    func completeItem(_ id: String) {
        DispatchQueue.main.async {
            self.todoitems[id]?.isDone = true
            self.updateFilteredSortedItems()
        }
    }

    func activateItem(_ id: String) {
        DispatchQueue.main.async {
            self.todoitems[id]?.isDone = false
            self.updateFilteredSortedItems()
        }
    }

    func addItem(_ item: Todoitem) {
        DispatchQueue.main.async {
            self.todoitems[item.id] = item
            self.updateFilteredSortedItems()
        }
    }

    func removeItem(_ id: String) {
        DispatchQueue.main.async {
            self.todoitems[id] = nil
            self.updateFilteredSortedItems()
        }
    }

    func updateItem(_ id: String, _ item: Todoitem) {
        DispatchQueue.main.async {
            self.todoitems[id] = item
            self.updateFilteredSortedItems()
        }
    }

    func updateFilteredSortedItems() {
        DispatchQueue.main.async {
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
    }

    func toggleShowCompleted() {
        DispatchQueue.main.async {
            self.isShown.toggle()
            self.updateFilteredSortedItems()
        }
    }

    func sortBy(_ option: SortOption) {
        DispatchQueue.main.async {
            self.sortOption = option
            self.updateFilteredSortedItems()
        }
    }

    var completedCount: Int {
        return items.filter { $0.isDone }.count
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

    func addCategory(_ category: TodoCategory) {
        DispatchQueue.main.async {
            self.categories.append(category)
        }
    }

    func removeCategory(_ category: TodoCategory) {
        DispatchQueue.main.async {
            self.categories.removeAll { $0.id == category.id }
        }
    }

    func updateCategory(_ category: TodoCategory) {
        DispatchQueue.main.async {
            if let index = self.categories.firstIndex(where: { $0.id == category.id }) {
                self.categories[index] = category
            }
        }
    }
}
