import UIKit

final class TaskListAssembly {
    static func assemble() -> UIViewController {
        let viewController = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()

        viewController.presenter = presenter

        presenter.interactor = interactor
        presenter.view = viewController
        presenter.viewController = viewController
        presenter.router = router

        interactor.output = presenter
        router.viewController = viewController

        return viewController
    }
}
