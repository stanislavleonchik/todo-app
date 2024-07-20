import Foundation
import SwiftUI

public struct TodoCategory: Identifiable, Hashable {
    public let id = UUID()
    public var name: String
    public var color: Color

    public static let work = TodoCategory(name: "Work", color: .red)
    public static let personal = TodoCategory(name: "Personal", color: .blue)
    public static let study = TodoCategory(name: "Study", color: .green)
    public static let other = TodoCategory(name: "Other", color: .clear)

    public init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}
