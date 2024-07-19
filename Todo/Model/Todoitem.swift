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
}
