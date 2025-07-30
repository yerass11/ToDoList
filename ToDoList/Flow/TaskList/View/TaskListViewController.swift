import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [Task])
    func showError(_ message: String)
}

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterProtocol!
    
    private var tasks: [Task] = []

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        setupTableView()
        presenter.viewDidLoad()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        view.addSubview(tableView)
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func showTasks(_ tasks: [Task]) {
        self.tasks = tasks
        tableView.reloadData()
    }

    func showError(_ message: String) {
        // alert
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.description
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        return cell
    }
}
