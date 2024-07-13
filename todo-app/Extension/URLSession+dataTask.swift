import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        var task: URLSessionTask?
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { contination in
                task = dataTask(with: urlRequest) { data, response, error in
                    do {
                        try Task.checkCancellation()
                    } catch {
                        contination.resume(throwing: error)
                        return
                    }
                    
                    if let error {
                        contination.resume(throwing: error)
                        return
                    }
                    
                    guard let data, let response else {
                        fatalError("Nil in data or response in dataTask")
                    }
                    
                    contination.resume(returning: (data, response))
                }
                
                do {
                    try Task.checkCancellation()
                } catch {
                    task?.cancel()
                    contination.resume(throwing: error)
                    return
                }
                
                task?.resume()
            }
        } onCancel: { [weak task] in
            task?.cancel()
        }
    }
}
