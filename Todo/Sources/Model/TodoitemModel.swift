import Foundation
import SwiftData

@MainActor
final class TodoitemModel {
    private var container: ModelContainer
    private let sqliteManager = SQLiteManager()
    
    public init() {
        do {
            self.container = try ModelContainer(for: Todoitem.self, TodoCategory.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    @MainActor public func insert(_ todoItem: Todoitem) throws {
        container.mainContext.insert(todoItem)
        try container.mainContext.save()
    }
    
    @MainActor public func fetch() throws -> [Todoitem] {
        let request = FetchDescriptor<Todoitem>()
        let results = try container.mainContext.fetch(request)
        return results
    }
    
    @MainActor public func delete(_ todoItem: Todoitem) throws {
        container.mainContext.delete(todoItem)
        try container.mainContext.save()
    }
    
    @MainActor public func update(_ todoItem: Todoitem) throws {
        if let existingItem = try container.mainContext.fetch(FetchDescriptor<Todoitem>()).first(where: { $0.id == todoItem.id }) {
            existingItem.text = todoItem.text
            existingItem.importance = todoItem.importance
            existingItem.deadline = todoItem.deadline
            existingItem.isDone = todoItem.isDone
            existingItem.dateChanged = Date()
            try container.mainContext.save()
        }
    }
}



extension TodoitemModel {
    @MainActor public func fetchFilteredSorted(
        predicate: Predicate<Todoitem>,
        sortDescriptor: FetchDescriptor<Todoitem>
    ) throws -> [Todoitem] {
        let request = FetchDescriptor<Todoitem>(
            predicate: predicate
        )
        return try container.mainContext.fetch(
            request
        )
    }
}

extension TodoitemModel {
    public func insertToSQLite(_ todoItem: Todoitem) {
        sqliteManager.insert(todoItem: todoItem)
    }

    public func fetchFromSQLite() -> [Todoitem] {
        return sqliteManager.fetch()
    }

    public func deleteFromSQLite(_ todoItem: Todoitem) {
        sqliteManager.delete(todoItem: todoItem)
    }

    public func updateToSQLite(_ todoItem: Todoitem) {
        sqliteManager.update(todoItem: todoItem)
    }
}
