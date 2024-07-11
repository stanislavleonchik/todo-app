import Foundation

extension Todoitem {
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
}
