import Foundation


final class FileCache {
    var todoitems: [String: Todoitem] = [:]
    var items: [Todoitem] {
        return Array(todoitems.values)
    }

    func addItem(_ item: Todoitem) {
        todoitems[item.id] = item
    }
    
    func removeItem(_ id: String) {
        todoitems[id] = nil
    }
    
    func updateItem(_ id: String, _ item: Todoitem) {
        todoitems[id] = item
    }
    
    subscript(id: String) -> Todoitem? {
        get {
            return todoitems[id]
        }
        set {
            todoitems[id] = newValue
        }
    }
    
    func save(to fileName: String) throws {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        guard let fileURL = getCacheDirectory()?.appendingPathComponent(fileName) else { return }

        switch fileExtension {
        case "json":
            let jsonData = try JSONSerialization.data(withJSONObject: todoitems.values.map { $0.json }, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
        case "csv":
            var csvString = "id,text,importance,deadline,isDone,dateCreated,dateChanged\n"
                    
            for item in items {
                let deadline = item.deadline?.timeIntervalSince1970.description ?? ""
                let dateChanged = item.dateChanged?.timeIntervalSince1970.description ?? ""
                csvString.append("\(item.id),\"\(item.text)\",\(item.importance.rawValue),\(deadline),\(item.isDone),\(item.dateCreated.timeIntervalSince1970),\(dateChanged)\n")
            }

            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        default:
            throw NSError(domain: "FileCacheError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
        }
    }
    
    func load(from fileName: String) throws {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        guard let fileURL = getCacheDirectory()?.appendingPathComponent(fileName) else { return }

        switch fileExtension {
        case "json":
            guard let jsonArray = try JSONSerialization.jsonObject(with: try Data(contentsOf: fileURL), options: []) as? [[String: Any]] else { return }
            for json in jsonArray {
                let temp = Todoitem.parse(json: json)
                if let id = temp?.id {
                    todoitems[id] = temp
                }
            }
            
        case "csv":
            let csvString = try String(contentsOf: fileURL)
            let rows = csvString.split(separator: "\n").dropFirst()

            var loadedItems: [String: Todoitem] = [:]
            for row in rows {
                guard let temp = Todoitem.parse(csv: row) else { continue }
                loadedItems[temp.id] = temp
            }

            for (id, item) in loadedItems {
                todoitems[id] = item
            }
        default:
            throw NSError(domain: "FileCacheError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
        }
    }
    
    private func getCacheDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[safe: 0]
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
