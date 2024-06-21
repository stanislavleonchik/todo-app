//
//  FileCache.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 21.06.2024.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

final class FileCache {
    private(set) var todoItems: [String: TodoItem] = [:]
    var items: [TodoItem] {
        return Array(todoItems.values) // O(n)
    }

    func addItem(_ item: TodoItem) {
        todoItems[item.id] = item
    }
    
    func removeItem(_ id: String) {
        todoItems[id] = nil
    }
    
    func save(to fileName: String) throws {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        guard let fileURL = getCacheDirectory()?.appendingPathComponent(fileName) else { return }

        switch fileExtension {
        case "json":
            let jsonData = try JSONSerialization.data(withJSONObject: todoItems.values.map { $0.json }, options: .prettyPrinted)
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
                let temp = TodoItem.parse(json: json)
                if let id = temp?.id {
                    todoItems[id] = temp
                }
            }
            
        case "csv":
            let csvString = try String(contentsOf: fileURL)
            let rows = csvString.split(separator: "\n").dropFirst()

            var loadedItems: [String: TodoItem] = [:]
            for row in rows {
                let columns = row.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
                guard columns.count == 7 else { continue }

                let id = columns[0]
                let text = columns[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let importance = TodoItem.Importance(rawValue: columns[2]) ?? .ordinary
                let deadline = TimeInterval(columns[3])
                let isDone = Bool(columns[4]) ?? false
                let dateCreated = Date(timeIntervalSince1970: TimeInterval(columns[5])!)
                let dateChanged = TimeInterval(columns[6]).map { Date(timeIntervalSince1970: $0) }

                let item = TodoItem(id: id, text: text, importance: importance, deadline: deadline.map { Date(timeIntervalSince1970: $0) }, isDone: isDone, dateCreated: dateCreated, dateChanged: dateChanged)
                loadedItems[item.id] = item
            }

            for (id, item) in loadedItems {
                todoItems[id] = item
            }
        default:
            throw NSError(domain: "FileCacheError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file format"])
        }
    }
    
    private func getCacheDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[safe: 0]
    }
}
