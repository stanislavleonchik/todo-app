import Foundation

public struct TodoitemDTO: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int64?
    let done: Bool
    let color: String?
    let created_at: Int64
    let changed_at: Int64
    let last_updated_by: String

    init(id: String, text: String, importance: String, deadline: Date?, done: Bool, color: String?, created_at: Date, changed_at: Date, last_updated_by: String) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline?.timeIntervalSince1970.toInt64()
        self.done = done
        self.color = color
        self.created_at = created_at.timeIntervalSince1970.toInt64()
        self.changed_at = changed_at.timeIntervalSince1970.toInt64()
        self.last_updated_by = last_updated_by
    }
}

extension TimeInterval {
    func toInt64() -> Int64 {
        return Int64(self)
    }
}
