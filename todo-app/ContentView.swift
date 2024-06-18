//
//  ContentView.swift
//  todo-app
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

struct TodoItem {
    enum Importance: String {
        case unimportant = "unimportant",
             ordinary = "ordinary",
             important = "important"
    }
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let dateCreated: Date
    let dateChanged: Date?
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Importance = .ordinary,
         deadline: Date? = nil,
         isDone: Bool,
         dateCreated: Date = Date(),
         dateChanged: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.dateCreated = dateCreated
        self.dateChanged = dateChanged
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let dict = json as? [String: Any],
              let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let creationTimestamp = dict["dateCreated"] as? TimeInterval else { return nil }
        
        let importance = Importance(rawValue: dict["importance"] as? String ?? "ordinary") ?? .ordinary
        var deadline: Date? = nil
        if let deadlineTimestamp = dict["deadline"] as? TimeInterval {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp)
        }
        var dateChanged: Date? = nil
        if let changeTimestamp = dict["dateChanged"] as? TimeInterval {
            dateChanged = Date(timeIntervalSince1970: changeTimestamp)
        }

        
        return TodoItem(id: id, 
                        text: text,
                        importance: importance,
                        deadline: deadline,
                        isDone: isDone,
                        dateCreated: Date(timeIntervalSince1970: creationTimestamp),
                        dateChanged: dateChanged
        )
    }
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
