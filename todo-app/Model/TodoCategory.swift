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
