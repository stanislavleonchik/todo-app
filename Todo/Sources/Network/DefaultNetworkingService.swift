import Foundation
import CocoaLumberjackSwift

class DefaultNetworkingService: NetworkingService {
    private let baseURL = URL(string: Configuration.baseURL)!
    private let token = Configuration.token
    private var isDirty = false
    private var revision: Int = 0
    private var pendingRequests: [() async throws -> Void] = []
    
    private var delay: Double = 2.0
    private let maxDelay: Double = 120.0
    private let factor: Double = 1.5
    private let jitter: Double = 0.05
    
    private var isNetworkBusy: Bool = false {
        didSet {
            DispatchQueue.main.async {
                // TODO: Update the UIActivityIndicator state here
            }
        }
    }
    
    private func performRequest<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        print("Current revision before request: \(revision)")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("Response status code: \(httpResponse.statusCode)")
        if let dataString = String(data: data, encoding: .utf8) {
            print("Response data: \(dataString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decodedResponse = try JSONDecoder().decode(T.self, from: data)
        if let todoListResponse = decodedResponse as? TodoListResponse {
            revision = todoListResponse.revision
        } else if let todoItemResponse = decodedResponse as? TodoItemResponse {
            revision = todoItemResponse.revision
        }
        print("Updated revision after request: \(revision)")
        return decodedResponse
    }
    
    func fetchRevision() async throws -> Int {
        let request = try makeURLRequest(path: "list", method: "GET")
        let response: TodoListResponse = try await performRequest(request)
        return response.revision
    }
    
    func fetchTodoList() async throws -> [TodoitemDTO] {
        let request = try makeURLRequest(path: "list", method: "GET")
        let response: TodoListResponse = try await performRequest(request)
        revision = response.revision
        return response.list
    }
    
    func updateTodoList(with items: [TodoitemDTO], revision: Int) async throws -> [TodoitemDTO] {
        var request = try makeURLRequest(path: "list", method: "PATCH")
        request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let body = TodoListUpdateRequest(list: items)
        request.httpBody = try JSONEncoder().encode(body)

        print("PATCH Request Body: \(String(data: request.httpBody!, encoding: .utf8)!)")

        let response: TodoListResponse = try await performRequest(request)
        self.revision = response.revision
        isDirty = false
        return response.list
    }
    
    func fetchTodoItem(by id: String) async throws -> TodoitemDTO {
        let request = try makeURLRequest(path: "list/\(id)", method: "GET")
        let response: TodoItemResponse = try await performRequest(request)
        return response.element
    }
    
    func addTodoItem(_ item: TodoitemDTO) async throws -> TodoitemDTO {
        let request = try makeURLRequest(path: "list", method: "POST", body: item)
        let response: TodoItemResponse = try await performRequest(request)
        revision = response.revision
        return response.element
    }
    
    func updateTodoItem(_ item: TodoitemDTO) async throws -> TodoitemDTO {
        let request = try makeURLRequest(path: "list/\(item.id)", method: "PUT", body: item)
        let response: TodoItemResponse = try await performRequest(request)
        revision = response.revision
        return response.element
    }
    
    func deleteTodoItem(by id: String) async throws -> TodoitemDTO {
        let request = try makeURLRequest(path: "list/\(id)", method: "DELETE")
        let response: TodoItemResponse = try await performRequest(request)
        revision = response.revision
        return response.element
    }
    
    private func makeURLRequest(path: String, method: String, body: Encodable? = nil) throws -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(body)
            request.httpBody = jsonData

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(jsonString)")
            }
        }
        
        print("Request URL: \(url.absoluteString)")
        print("Request Method: \(method)")
        if let headers = request.allHTTPHeaderFields {
            print("Request Headers: \(headers)")
        }

        return request
    }

    
    private func executePendingRequests() async {
        for request in pendingRequests {
            do {
                try await request()
                delay = 2.0
            } catch {
                await handleError(error)
            }
        }
        pendingRequests.removeAll()
    }
    
    private func handleError(_ error: Error) async {
        if (error as? URLError)?.code == .timedOut || (error as? URLError)?.code == .networkConnectionLost {
            isDirty = true
            delay = min(delay * factor, maxDelay)
            let jitteredDelay = delay + Double.random(in: -jitter...jitter) * delay
            try? await Task.sleep(nanoseconds: UInt64(jitteredDelay * 1_000_000_000))
            await executePendingRequests()
        }
    }
}

struct TodoListResponse: Decodable {
    let status: String
    let list: [TodoitemDTO]
    let revision: Int
}

struct TodoItemResponse: Decodable {
    let status: String
    let element: TodoitemDTO
    let revision: Int
}

struct TodoListUpdateRequest: Encodable {
    let list: [TodoitemDTO]
}
