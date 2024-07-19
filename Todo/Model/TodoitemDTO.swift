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
}
