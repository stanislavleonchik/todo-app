//
//  todo_appTests.swift
//  todo-appTests
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import XCTest
import todo_app

final class todo_appTests: XCTestCase {
    func test_json_serialization() {
        let dateCreated = Date()
        let item = TodoItem(id: "1", text: "Test Task", importance: .important, deadline: Date(timeIntervalSince1970: 0), isDone: false, dateCreated: dateCreated, dateChanged: nil)

        let json = item.json as? [String: Any]

        XCTAssertEqual(json?["id"] as? String, "1")
        XCTAssertEqual(json?["text"] as? String, "Test Task")
        XCTAssertEqual(json?["importance"] as? String, TodoItem.Importance.important.rawValue)
        XCTAssertEqual(json?["isDone"] as? Bool, false)
        XCTAssertEqual(json?["dateCreated"] as? TimeInterval, dateCreated.timeIntervalSince1970)

        if let deadlineTimestamp = json?["deadline"] as? TimeInterval {
            XCTAssertEqual(deadlineTimestamp, item.deadline?.timeIntervalSince1970)
        }

        XCTAssertNil(json?["dateChanged"])
    }

    func test_json_parsing() throws {
        let json: [String: Any] = [
            "id": "2",
            "text": "Another Task",
            "importance": TodoItem.Importance.ordinary.rawValue,
            "isDone": true,
            "dateCreated": Date().timeIntervalSince1970
        ]

        let item = try XCTUnwrap(TodoItem.parse(json: json))

        XCTAssertEqual(item.id, "2")
        XCTAssertEqual(item.text, "Another Task")
        XCTAssertEqual(item.importance, TodoItem.Importance.ordinary)
        XCTAssertEqual(item.isDone, true)
        XCTAssertEqual(item.dateCreated.timeIntervalSince1970, json["dateCreated"] as? TimeInterval)

        XCTAssertNil(item.deadline)
        XCTAssertNil(item.dateChanged)
    }
}
