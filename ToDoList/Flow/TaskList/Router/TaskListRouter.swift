import UIKit

protocol TaskListRouterProtocol: AnyObject {}

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?
}
