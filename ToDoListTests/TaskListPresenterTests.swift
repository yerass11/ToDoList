import XCTest
@testable import ToDoList

final class TaskListPresenterTests: XCTestCase {
    final class MockView: TaskListViewProtocol {
        var shownTasks: [Task] = []
        var shownError: String?
        
        func showTasks(_ tasks: [Task]) {
            shownTasks = tasks
        }
        
        func showError(_ message: String) {
            shownError = message
        }
    }
    
    class MockInteractor: TaskListInteractorProtocol {
        weak var output: TaskListInteractorOutput?
        
        func fetchTasks() {
            let oldTask = Task(id: 1, title: "Old", description: "", dateCreated: Date(), isCompleted: false)
            let newTask = Task(id: 2, title: "New", description: "", dateCreated: Date(timeIntervalSince1970: 0), isCompleted: false)
            output?.tasksFetched([oldTask, newTask])
        }
        
        func add(with task: Task) {}
        func update(with task: Task) {}
        func delete(with task: Task) {}
        func toggleCompletion(with task: Task) {}
    }
    
    final class MockRouter: TaskListRouterProtocol {
        var didCallOpenNewTask = false
        
        func openTaskDetail(from view: UIViewController?, task: Task, onSave: @escaping (Task) -> Void) {}
        
        func openNewTask(from view: UIViewController?, onSave: @escaping (Task) -> Void) {
            didCallOpenNewTask = true
        }
    }
    
    func test_viewDidLoad_showsSortedTasks() {
        let view = MockView()
        let presenter = TaskListPresenter()
        let interactor = MockInteractor()
        presenter.view = view
        presenter.interactor = interactor
        interactor.output = presenter
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(view.shownTasks.count, 2)
        XCTAssertTrue(view.shownTasks[0].dateCreated > view.shownTasks[1].dateCreated)
    }
    
    func test_viewDidLoad_showsError_onFailure() {
        class FailingInteractor: TaskListInteractorProtocol {
            weak var output: TaskListInteractorOutput?
            
            func fetchTasks() {
                output?.tasksFetchFailed(error: NSError(domain: "TestError", code: -1))
            }
            
            func add(with task: Task) {}
            func update(with task: Task) {}
            func delete(with task: Task) {}
            func toggleCompletion(with task: Task) {}
        }
        
        let view = MockView()
        let presenter = TaskListPresenter()
        let interactor = FailingInteractor()
        
        presenter.view = view
        presenter.interactor = interactor
        interactor.output = presenter
        
        presenter.viewDidLoad()
        
        XCTAssertEqual(view.shownError, "Произошла ошибка при загрузке задач.")
    }
    
    func test_didTapAdd_callsRouter() {
        let presenter = TaskListPresenter()
        let router = MockRouter()
        let viewController = UIViewController()
        presenter.router = router
        presenter.viewController = viewController

        presenter.didTapAdd()

        XCTAssertTrue(router.didCallOpenNewTask)
    }
    
    func test_didToggleTaskCompletion_callsInteractor() {
        class TrackingInteractor: TaskListInteractorProtocol {
            weak var output: TaskListInteractorOutput?
            var didToggle = false

            func fetchTasks() {}
            func add(with task: Task) {}
            func update(with task: Task) {}
            func delete(with task: Task) {}
            func toggleCompletion(with task: Task) {
                didToggle = true
            }
        }

        let interactor = TrackingInteractor()
        let presenter = TaskListPresenter()
        presenter.interactor = interactor

        let task = Task(id: 1, title: "Test", description: "", dateCreated: Date(), isCompleted: false)
        presenter.didToggleTaskCompletion(task)

        XCTAssertTrue(interactor.didToggle)
    }
    
    func test_didTapTask_callsRouterOpenTaskDetail() {
        class TrackingRouter: TaskListRouterProtocol {
            var didCallOpenDetail = false

            func openTaskDetail(from view: UIViewController?, task: Task, onSave: @escaping (Task) -> Void) {
                didCallOpenDetail = true
            }

            func openNewTask(from view: UIViewController?, onSave: @escaping (Task) -> Void) {}
        }

        let presenter = TaskListPresenter()
        let router = TrackingRouter()
        let viewController = UIViewController()
        presenter.router = router
        presenter.viewController = viewController

        presenter.didTapTask(Task(id: 42, title: "Test", description: "", dateCreated: Date(), isCompleted: false))

        XCTAssertTrue(router.didCallOpenDetail)
    }
}
