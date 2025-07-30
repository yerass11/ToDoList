import Foundation

struct TaskNetworkModel: Codable {
    let id: Int64
    let todo: String
    let completed: Bool
    let userId: Int
}

extension TaskNetworkModel {
    func toDomainModel() -> Task {
        Task(
            id: self.id,
            title: self.todo,
            description: "",
            dateCreated: Date(),
            isCompleted: self.completed
        )
    }
}
