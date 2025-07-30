import Foundation

protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAdd()
    func didTapTask(_ task: Task)
    func didTapEdit(_ task: Task)
    func didSelectTask(_ task: Task)
    func didSwipeToDelete(task: Task)
    func didToggleTaskCompletion(_ task: Task)
    func didTapShare(_ task: Task)
}
