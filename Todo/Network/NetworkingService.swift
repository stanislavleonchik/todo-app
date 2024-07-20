import Foundation

protocol NetworkingService {
    func fetchTodoList() async throws -> [TodoitemDTO]
    func updateTodoList(with items: [TodoitemDTO], revision: Int) async throws -> [TodoitemDTO]
    func fetchTodoItem(by id: String) async throws -> TodoitemDTO
    func addTodoItem(_ item: TodoitemDTO) async throws -> TodoitemDTO
    func updateTodoItem(_ item: TodoitemDTO) async throws -> TodoitemDTO
    func deleteTodoItem(by id: String) async throws -> TodoitemDTO
    func fetchRevision() async throws -> Int
}
