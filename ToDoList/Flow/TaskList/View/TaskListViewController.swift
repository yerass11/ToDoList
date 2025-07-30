import UIKit

protocol TaskListViewProtocol: AnyObject {
    func showTasks(_ tasks: [Task])
    func showError(_ message: String)
}

import UIKit

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterProtocol!
    
    private var tasks: [Task] = []

    private lazy var searchController = makeSearchController()
    private lazy var tableView = makeTableView()
    private lazy var bottomBar = makeBottomBar()
    private lazy var taskCountLabel = makeTaskCountLabel()
    private lazy var addButton = makeAddButton()
    
    private var filteredTasks: [Task] = []

    private var isSearchActive: Bool {
        return !(searchController.searchBar.text?.isEmpty ?? true) && searchController.isActive
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBar.snp.updateConstraints { make in
            make.height.equalTo(49 + view.safeAreaInsets.bottom)
        }
    }

    @objc
    private func didTapAdd() {
        presenter.didTapAdd()
    }
    
    private func setup() {
        title = "Задачи"
        navigationItem.backButtonTitle = "Назад"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        [tableView, bottomBar].forEach { view.addSubview($0)}
        [taskCountLabel, addButton].forEach { bottomBar.addSubview($0) }

        presenter.viewDidLoad()
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
        bottomBar.snp.makeConstraints { make in
            make.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(49 + view.safeAreaInsets.bottom)
        }
        taskCountLabel.snp.makeConstraints { make in
            make.top.equalTo(bottomBar.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        addButton.snp.makeConstraints { make in
            make.top.equalTo(bottomBar.snp.top).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(28)
        }
    }
    
    private func makeSearchController() -> UISearchController {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search"
        search.searchBar.searchTextField.backgroundColor = .secondarySystemBackground
        search.searchBar.tintColor = .gray
        return search
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")
        return tableView
    }
    
    private func makeBottomBar() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BottomBarColor")
        return view
    }
    
    private func makeTaskCountLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor(named: "PrimaryColor")
        return label
    }

    private func makeAddButton() -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        button.tintColor = .systemYellow
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        return button
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func showTasks(_ tasks: [Task]) {
        self.tasks = tasks.sorted { $0.dateCreated > $1.dateCreated }
        taskCountLabel.text = "\(tasks.count) Задач"
        tableView.reloadData()
    }

    func showError(_ message: String) {}
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredTasks.count : tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = isSearchActive ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        cell.configure(with: task)

        cell.onContextMenuRequested = { [weak self] in
            guard let self = self else { return nil }
            
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.presenter.didTapTask(task)
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.presenter.didTapShare(task)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter.didSwipeToDelete(task: task)
            }
            
            return UIMenu(title: "", children: [edit, share, delete])
        }
        cell.onTapDetails = { [weak self] in
            self?.presenter.didTapTask(task)
        }
        cell.onToggleCompletion = { [weak self] updatedTask in
            self?.presenter.didToggleTaskCompletion(updatedTask)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        presenter.didTapTask(task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completionHandler in
            self?.presenter.didSwipeToDelete(task: task)
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            filteredTasks = []
            tableView.reloadData()
            return
        }

        filteredTasks = tasks.filter {
            $0.title.lowercased().contains(text) ||
            $0.description.lowercased().contains(text)
        }
        tableView.reloadData()
    }
}

