import Foundation
import FileCacheUnit

extension Todoitem: CsvCompatible {
    var csv: String {
        let deadline = deadline?.timeIntervalSince1970.description ?? ""
        let dateChanged = dateChanged?.timeIntervalSince1970.description ?? ""
        return "\(id),\"\(text)\",\(importance.rawValue),\(deadline),\(isDone),\(dateCreated.timeIntervalSince1970),\(dateChanged)\n"
    }
    
    static func parse(csv: Substring) -> Todoitem? {
        let columns = csv.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        guard columns.count == 7 else { return nil }

        let id = columns[0]
        let text = columns[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let importance = Importance(rawValue: columns[2]) ?? .basic
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
}
