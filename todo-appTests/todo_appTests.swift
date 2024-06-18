//
//  todo_appTests.swift
//  todo-appTests
//
//  Created by Stanislav Leonchik on 18.06.2024.
//

import XCTest
@testable import todo_app

final class todo_appTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonSerialization() {
        let dateCreated = Date()
        let item = TodoItem(id: "1", text: "Test Task", importance: .important, deadline: Date().addingTimeInterval(3600), isDone: false, dateCreated: dateCreated, dateChanged: nil)

        let json = item.json as? [String: Any]

        XCTAssertEqual(json?["id"] as? String, "1")
        XCTAssertEqual(json?["text"] as? String, "Test Task")
        XCTAssertEqual(json?["importance"] as? String, TodoItem.Importance.important.rawValue)
        XCTAssertEqual(json?["isDone"] as? Bool, false)
        XCTAssertEqual(json?["dateCreated"] as? TimeInterval, dateCreated.timeIntervalSince1970)

        if let deadlineTimestamp = json?["deadline"] as? TimeInterval {
            XCTAssertEqual(Date(timeIntervalSince1970: deadlineTimestamp), item.deadline)
        }

        XCTAssertNil(json?["dateChanged"])
    }

    func testJsonParsing() {
        let json: [String: Any] = [
            "id": "2",
            "text": "Another Task",
            "importance": TodoItem.Importance.ordinary.rawValue,
            "isDone": true,
            "dateCreated": Date().timeIntervalSince1970
        ]

        guard let item = TodoItem.parse(json: json) else {
            XCTFail("Failed to parse JSON")
            return
        }

        XCTAssertEqual(item.id, "2")
        XCTAssertEqual(item.text, "Another Task")
        XCTAssertEqual(item.importance, TodoItem.Importance.ordinary)
        XCTAssertEqual(item.isDone, true)
        XCTAssertEqual(item.dateCreated.timeIntervalSince1970, json["dateCreated"] as? TimeInterval)

        XCTAssertNil(item.deadline)
        XCTAssertNil(item.dateChanged)
    }
}
