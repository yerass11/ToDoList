import Foundation

final class TaskAPIService {
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }

        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No data", code: 2)))
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(TaskListResponse.self, from: data)
                    let tasks = decoded.todos.map { $0.toDomainModel() }
                    DispatchQueue.main.async {
                        completion(.success(tasks))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
}
