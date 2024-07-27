import SQLite3
import Foundation

class SQLiteManager {
    private var db: OpaquePointer?
    private let dbPath: String = "todos.sqlite"

    init() {
        openDatabase()
        createTable()
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("error opening database")
        }
    }

    private func createTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Todoitem(
        id TEXT PRIMARY KEY,
        text TEXT,
        importance TEXT,
        deadline DOUBLE,
        isDone INTEGER,
        dateCreated DOUBLE,
        dateChanged DOUBLE);
        """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Todoitem table created.")
            } else {
                print("Todoitem table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    func insert(todoItem: Todoitem) {
        let insertStatementString = "INSERT INTO Todoitem (id, text, importance, deadline, isDone, dateCreated, dateChanged) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, todoItem.id, -1, nil)
            sqlite3_bind_text(insertStatement, 2, todoItem.text, -1, nil)
            sqlite3_bind_text(insertStatement, 3, todoItem.importance.rawValue, -1, nil)
            if let deadline = todoItem.deadline {
                sqlite3_bind_double(insertStatement, 4, deadline.timeIntervalSince1970)
            }
            sqlite3_bind_int(insertStatement, 5, todoItem.isDone ? 1 : 0)
            sqlite3_bind_double(insertStatement, 6, todoItem.dateCreated.timeIntervalSince1970)
            if let dateChanged = todoItem.dateChanged {
                sqlite3_bind_double(insertStatement, 7, dateChanged.timeIntervalSince1970)
            }

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    func fetch() -> [Todoitem] {
        let queryStatementString = "SELECT * FROM Todoitem;"
        var queryStatement: OpaquePointer?
        var todoItems: [Todoitem] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let text = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let importance = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let deadline = sqlite3_column_double(queryStatement, 3)
                let isDone = sqlite3_column_int(queryStatement, 4)
                let dateCreated = sqlite3_column_double(queryStatement, 5)
                let dateChanged = sqlite3_column_double(queryStatement, 6)

                let todoItem = Todoitem(id: id,
                                        text: text,
                                        importance: Importance(rawValue: importance) ?? Importance.basic,
                                        deadline: Date(timeIntervalSince1970: deadline),
                                        isDone: isDone == 1,
                                        dateCreated: Date(timeIntervalSince1970: dateCreated),
                                        dateChanged: Date(timeIntervalSince1970: dateChanged))
                todoItems.append(todoItem)
            }
        }
        sqlite3_finalize(queryStatement)
        return todoItems
    }

    func delete(todoItem: Todoitem) {
        let deleteStatementString = "DELETE FROM Todoitem WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(deleteStatement, 1, todoItem.id, -1, nil)

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }

    func update(todoItem: Todoitem) {
        let updateStatementString = "UPDATE Todoitem SET text = ?, importance = ?, deadline = ?, isDone = ?, dateChanged = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, todoItem.text, -1, nil)
            sqlite3_bind_text(updateStatement, 2, todoItem.importance.rawValue, -1, nil)
            if let deadline = todoItem.deadline {
                sqlite3_bind_double(updateStatement, 3, deadline.timeIntervalSince1970)
            }
            sqlite3_bind_int(updateStatement, 4, todoItem.isDone ? 1 : 0)
            sqlite3_bind_double(updateStatement, 5, Date().timeIntervalSince1970)
            sqlite3_bind_text(updateStatement, 6, todoItem.id, -1, nil)

            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
}
