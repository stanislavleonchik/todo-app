//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

struct TodoItem {
    enum Importance: String {
        case unimportant = "unimportant",
             ordinary = "ordinary",
             important = "important"
    }
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .ordinary,
         deadline: Date? = nil,
         isDone: Bool,
         dateCreated: Date = Date(),
         dateChanged: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any],
              let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let creationTimestamp = dict["dateCreated"] as? TimeInterval else { return nil }
        
        let importance = Importance(rawValue: dict["importance"] as? String ?? "ordinary") ?? .ordinary
        var deadline: Date? = nil
        if let deadlineTimestamp = dict["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        }
        var dateChanged: Date? = nil
        if let changeTimestamp = dict["dateChanged"] as? TimeInterval {
            dateChanged = Date(timeIntervalSince1970: changeTimestamp)
        }

        return TodoItem(id: id, 
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        isDone: isDone,
                        dateCreated: Date(timeIntervalSince1970: creationTimestamp),
                        dateChanged: dateChanged
        )
    }
    
    var json: Any {
        var result: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "dateCreated": dateCreated.timeIntervalSince1970
        ]
        if importance != .ordinary {
            result["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            result["deadline"] = deadline.timeIntervalSince1970
        }
        if let dateChanged = dateChanged {
            result["dateChanged"] = dateChanged.timeIntervalSince1970
        }
        return result
    }
}

class FileCache {
    private var todoItems: [String: TodoItem] = [:]
    var items: [TodoItem] {
        return Array(todoItems.values)
    }

    func addItem(_ item: TodoItem) {
        todoItems[item.id] = item
    }
    
    func removeItem(_ id: String) {
        todoItems.removeValue(forKey: id)
    }
    
    func save(to fileName: String) throws {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        let fileURL = getCacheDirectory().appendingPathComponent(fileName)

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
        let fileURL = getCacheDirectory().appendingPathComponent(fileName)

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
    
    private func getCacheDirectory() -> URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
