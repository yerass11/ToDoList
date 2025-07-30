import UIKit

protocol TaskListRouterProtocol: AnyObject {
    func openTaskDetail(from view: UIViewController?, task: Task, onSave: @escaping (Task) -> Void)
    func openNewTask(from view: UIViewController?, onSave: @escaping (Task) -> Void)
}

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?

    func openTaskDetail(from view: UIViewController?, task: Task, onSave: @escaping (Task) -> Void) {
        let detailViewController = TaskDetailViewController(task: task)
        detailViewController.onSave = onSave
        view?.navigationController?.pushViewController(detailViewController, animated: true)
    }

    func openNewTask(from view: UIViewController?, onSave: @escaping (Task) -> Void) {
        let detailViewController = TaskDetailViewController(task: Task.empty())
        detailViewController.onSave = onSave
        view?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension Task {
    static func empty() -> Task {
        Task(
            id: Int64(Date().timeIntervalSince1970 * 1000),
            title: "",
            description: "",
            dateCreated: Date(),
            isCompleted: false
        )
    }
}
