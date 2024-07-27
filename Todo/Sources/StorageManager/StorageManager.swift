import Foundation

class StorageManager {
    static let shared = StorageManager()
    private var storageType: String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "storageType") ?? "swiftdata"
    }
    
    @MainActor func insert(todoItem: Todoitem) {
        if storageType == "swiftdata" {
            try? TodoitemModel().insert(todoItem)
        } else {
            TodoitemModel().insertToSQLite(todoItem)
        }
    }
    
    @MainActor func fetch() -> [Todoitem] {
        if storageType == "swiftdata" {
            return (try? TodoitemModel().fetch()) ?? []
        } else {
            return TodoitemModel().fetchFromSQLite()
        }
    }
    
    @MainActor func delete(todoItem: Todoitem) {
        if storageType == "swiftdata" {
            try? TodoitemModel().delete(todoItem)
        } else {
            TodoitemModel().deleteFromSQLite(todoItem)
        }
    }
    
    @MainActor func update(todoItem: Todoitem) {
        if storageType == "swiftdata" {
            try? TodoitemModel().update(todoItem)
        } else {
            TodoitemModel().updateToSQLite(todoItem)
        }
    }
}
