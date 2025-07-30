import Foundation

protocol TaskListInteractorOutput: AnyObject {
    func tasksFetched(_ tasks: [Task])
    func tasksFetchFailed(error: Error)
}
