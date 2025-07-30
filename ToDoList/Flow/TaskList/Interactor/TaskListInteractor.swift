import Foundation

final class TaskListInteractor: TaskListInteractorProtocol {
    weak var output: TaskListInteractorOutput?
    private let apiService = TaskAPIService()
    private let coreDataService = TaskCoreDataService()

    func fetchTasks() {
        if coreDataService.isDataAlreadyLoaded() {
            coreDataService.fetchTasks { [weak self] tasks in
                self?.output?.tasksFetched(tasks)
            }
        } else {
            apiService.fetchTasks { [weak self] result in
                switch result {
                case .success(let tasks):
                    self?.coreDataService.saveTasks(tasks) {
                        self?.output?.tasksFetched(tasks)
                    }
                case .failure(let error):
                    self?.output?.tasksFetchFailed(error: error)
                }
            }
        }
    }
    
    func add(with task: Task) {
        coreDataService.saveTask(task) { [weak self] in
            self?.fetchTasks()
        }
    }
    
    func update(with task: Task) {
        coreDataService.updateTask(task) { [weak self] in
            self?.fetchTasks()
        }
    }
    
    func delete(with task: Task) {
        coreDataService.deleteTask(task) { [weak self] in
            self?.fetchTasks()
        }
    }
    
    func toggleCompletion(with task: Task) {
        coreDataService.toggleTaskCompletion(task) { [weak self] in
            self?.fetchTasks()
        }
    }
}
