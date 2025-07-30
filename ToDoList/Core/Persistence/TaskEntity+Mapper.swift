import Foundation

extension TaskEntity {
    func toDomainModel() -> Task {
        Task(
            id: self.id,
            title: self.title ?? "",
            description: self.descText ?? "",
            dateCreated: self.dateCreated ?? Date(),
            isCompleted: self.isCompleted
        )
    }
}
