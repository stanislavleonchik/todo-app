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
        Todoitem(text: "Купить", importance: .unimportant, deadline: Date(), isDone: false)
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
}
