import Foundation
import SwiftUI

struct TodoCategory: Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var color: UIColor
    
    static let work = TodoCategory(name: "Work", color: .red)
    static let personal = TodoCategory(name: "Personal", color: .blue)
    static let study = TodoCategory(name: "Study", color: .green)
    static let other = TodoCategory(name: "Other", color: .clear)
}

struct Todoitem: Identifiable {
    enum Importance: String {
        case unimportant = "unimportant"
        case ordinary = "ordinary"
        case important = "important"
    }
    
    let id: String
    var text: String
    var importance: Importance
    var deadline: Date?
    var isDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    var color: String?
    var category: TodoCategory
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .ordinary,
         deadline: Date? = nil,
         isDone: Bool,
         dateCreated: Date = Date(),
         dateChanged: Date? = nil,
         category: TodoCategory = .other) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
        self.category = category
    }
}

extension Todoitem {
    static func parse(json: Any) -> Todoitem? {
        guard let dict = json as? [String: Any],
              let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let creationTimestamp = dict["dateCreated"] as? TimeInterval else { return nil }
        
        let importance = (dict["importance"] as? String).flatMap{ Importance(rawValue: $0) } ?? .ordinary
        var deadline: Date?
        if let deadlineTimestamp = dict["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        }
        var dateChanged: Date?
        if let changeTimestamp = dict["dateChanged"] as? TimeInterval {
            dateChanged = Date(timeIntervalSince1970: changeTimestamp)
        }

        return Todoitem(id: id,
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        isDone: isDone,
                        dateCreated: Date(timeIntervalSince1970: creationTimestamp),
                        dateChanged: dateChanged
        )
    }
    
    static func parse(csv: Substring) -> Todoitem? {
        let columns = csv.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        guard columns.count == 7 else { return nil }

        let id = columns[0]
        let text = columns[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let importance = Todoitem.Importance(rawValue: columns[2]) ?? .ordinary
        let deadline = TimeInterval(columns[3])
        let isDone = Bool(columns[4]) ?? false
        let dateCreated = Date(timeIntervalSince1970: TimeInterval(columns[5])!)
        let dateChanged = TimeInterval(columns[6]).map { Date(timeIntervalSince1970: $0) }

        return Todoitem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline.map { Date(timeIntervalSince1970: $0) },
            isDone: isDone,
            dateCreated: dateCreated,
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
