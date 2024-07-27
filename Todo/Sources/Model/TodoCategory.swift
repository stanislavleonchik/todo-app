import Foundation
import SwiftData

// MARK: - Category
@Model
final class TodoCategory {

    @Attribute(.unique) 
    let id: String
    var name: String
    var color: String?

    init(id: String = UUID().uuidString, name: String = "", color: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
    }

    enum Keys: String {
        case id, text, color, createdAt
    }

    public static let work = TodoCategory(name: "Work", color: "#FF3B30")
    public static let personal = TodoCategory(name: "Personal", color: "#007AFF")
    public static let study = TodoCategory(name: "Study", color: "#33C759")
    public static let other = TodoCategory(name: "Other")
}
