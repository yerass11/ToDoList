import Foundation
import UIKit

final class TaskListPresenter: TaskListPresenterProtocol {
    weak var viewController: UIViewController?
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?


    func viewDidLoad() {
        interactor?.fetchTasks()
    }
    
    func didTapAdd() {
        guard let view = view as? UIViewController else { return }

        router?.openNewTask(from: view) { [weak self] newTask in
            self?.interactor?.add(with: newTask)
        }
    }
    
    func didTapTask(_ task: Task) {
        openTaskEditor(with: task)
    }
    
    func didTapEdit(_ task: Task) {
        openTaskEditor(with: task)
    }

    func didSelectTask(_ task: Task) {
        openTaskEditor(with: task)
    }
    
    func didSwipeToDelete(task: Task) {
        interactor?.delete(with: task)
    }
    
    func didToggleTaskCompletion(_ task: Task) {
        interactor?.toggleCompletion(with: task)
    }

    func didTapShare(_ task: Task) {
        let activityVC = UIActivityViewController(
            activityItems: ["Задача: \(task.title)\nОписание: \(task.description)\nДата: \(task.dateCreated)"],
            applicationActivities: nil
        )
        viewController?.present(activityVC, animated: true)
    }
    
    private func openTaskEditor(with task: Task) {
        guard let view = view as? UIViewController else { return }
        router?.openTaskDetail(from: view, task: task) { [weak self] updatedTask in
            self?.interactor?.update(with: updatedTask)
        }
    }
}

extension TaskListPresenter: TaskListInteractorOutput {
    func tasksFetched(_ tasks: [Task]) {
        view?.showTasks(tasks)
    }

    func tasksFetchFailed(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
