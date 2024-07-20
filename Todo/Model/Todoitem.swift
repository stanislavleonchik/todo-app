import Foundation

struct Todoitem: Identifiable {
    enum Importance: String {
        case low = "low"
        case basic = "basic"
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
         importance: Importance = .basic,
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
    
    init?(dto: TodoitemDTO) {
        self.id = dto.id
        self.text = dto.text
        self.importance = Importance(rawValue: dto.importance) ?? .basic
        self.deadline = dto.deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        self.isDone = dto.done
        self.dateCreated = Date(timeIntervalSince1970: TimeInterval(dto.created_at))
        self.dateChanged = Date(timeIntervalSince1970: TimeInterval(dto.changed_at))
        self.color = dto.color
        self.category = .other
    }
}

extension Todoitem {
    func toDTO() -> TodoitemDTO {
        return TodoitemDTO(
            id: id,
            text: text,
            importance: importance.rawValue,
            deadline: deadline,
            done: isDone,
            color: color,
            created_at: dateCreated,
            changed_at: dateChanged ?? dateCreated,
            last_updated_by: "device_id"
        )
    }
}

extension Todoitem {
    func copyWith(isDone: Bool? = nil) -> Todoitem {
        return Todoitem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone ?? self.isDone,
            dateCreated: dateCreated,
            dateChanged: Date(),
            category: category
        )
    }
}
