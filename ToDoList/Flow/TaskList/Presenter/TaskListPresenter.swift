import Foundation

final class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorProtocol?
    var router: TaskListRouterProtocol?

    func viewDidLoad() {
        interactor?.fetchTasks()
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
