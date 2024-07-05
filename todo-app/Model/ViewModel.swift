import SwiftUI


final class ViewModel: ObservableObject {
    @Published var todoitems = FileCache()
    @Published var isShown: Bool = false
    @Published var sortOption: SortOption = .none
    
    var data = [
        Todoitem(text: "Hello", isDone: true),
        Todoitem(text: "Hello", isDone: false),
        Todoitem(text: "Hello", importance: .important, isDone: true),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", importance: .important, isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", isDone: false),
        Todoitem(text: "Купить что-то, где-то, зачем-то, но зачем не очень понятно, но точно чтобы показать как обреза…", deadline: Date(), isDone: false),
        Todoitem(text: "Hello\nabacaba\nabacaba\nabacaba", importance: .unimportant, isDone: false),
        Todoitem(text: "Купить бобы", importance: .unimportant, deadline: Date(), isDone: false),
        Todoitem(text: "Купить сыр", importance: .unimportant, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить молоко", importance: .unimportant, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить йогурт", importance: .unimportant, deadline: Date(timeIntervalSince1970: 10000), isDone: false),
        Todoitem(text: "Купить хлеб", importance: .unimportant, deadline: Date(timeIntervalSince1970: 500000), isDone: false),
        Todoitem(text: "Купить макароны", importance: .unimportant, deadline: Date(timeIntervalSince1970: 500000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 500000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 50000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 50000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 50000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 150000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 150000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 150000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false),
        Todoitem(text: "Купить фарш", importance: .unimportant, deadline: Date(timeIntervalSince1970: 1150000000), isDone: false),
    ]
    
    init() {
        for i in data {
            todoitems[i.id] = i
        }
        updateFilteredSortedItems()
    }
    
    var items: [Todoitem] {
        todoitems.items
    }
    
    @Published  var filteredSortedItems: [Todoitem] = []
    
    func toggleItem(_ id: String) {
        todoitems[id]?.isDone.toggle()
        updateFilteredSortedItems()
    }
    
    func completeItem(_ id: String) {
        todoitems[id]?.isDone = true
        updateFilteredSortedItems()
    }
    
    func activateItem(_ id: String) {
        todoitems[id]?.isDone = false
        updateFilteredSortedItems()
    }
    
    func addItem(_ item: Todoitem) {
        todoitems[item.id] = item
        updateFilteredSortedItems()
    }
    
    func removeItem(_ id: String) {
        todoitems[id] = nil
        updateFilteredSortedItems()
    }
    
    func updateItem(_ id: String, _ item: Todoitem) {
        todoitems[id] = item
        updateFilteredSortedItems()
    }
    
    func updateFilteredSortedItems() {
        var filteredItems = isShown ? items.filter { !$0.isDone } : items
        switch sortOption {
        case .none:
            break
        case .addition:
            filteredItems.sort { $0.dateCreated < $1.dateCreated }
        case .importance:
            filteredItems.sort { $0.importance.rawValue > $1.importance.rawValue }
        }
        filteredSortedItems = filteredItems
    }
    
    func toggleShowCompleted() {
        isShown.toggle()
        updateFilteredSortedItems()
    }
    
    func sortBy(_ option: SortOption) {
        sortOption = option
        updateFilteredSortedItems()
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
}
