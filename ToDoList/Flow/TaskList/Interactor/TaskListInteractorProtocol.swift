import Foundation

protocol TaskListInteractorProtocol: AnyObject {
    func fetchTasks()
    func add(with task: Task)
    func update(with task: Task)
    func delete(with task: Task)
    func toggleCompletion(with task: Task)
}
