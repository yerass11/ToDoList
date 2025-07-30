import UIKit
import SnapKit

final class TaskDetailViewController: UIViewController {
    private let task: Task
    
    var onSave: ((Task) -> Void)?

    private lazy var titleView = makeTitleView()
    private lazy var dateLabel = makeDateLabel()
    private lazy var descriptionView = makeDescriptionView()

    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        setup()
        populateData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let updatedTask = Task(
            id: task.id,
            title: titleView.text ?? "",
            description: descriptionView.text ?? "",
            dateCreated: task.dateCreated,
            isCompleted: task.isCompleted
        )
        
        onSave?(updatedTask)
    }

    private func setup() {
        [titleView, dateLabel, descriptionView].forEach { view.addSubview($0) }
        view.backgroundColor = .black
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(8)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.directionalHorizontalEdges.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }

    private func populateData() {
        titleView.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        dateLabel.text = formatter.string(from: task.dateCreated)

        descriptionView.text = task.description
    }
    
    private func makeTitleView() -> UITextView {
        let titleView = UITextView()
        titleView.backgroundColor = .clear
        titleView.font = .boldSystemFont(ofSize: 30)
        titleView.isEditable = true
        titleView.isScrollEnabled = false
        titleView.textColor = .white
        titleView.textContainer.lineFragmentPadding = 0
        titleView.textContainerInset = .zero
        return titleView
    }
    
    private func makeDateLabel() -> UILabel {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 15)
        dateLabel.textColor = .gray
        return dateLabel
    }
    
    private func makeDescriptionView() -> UITextView {
        let descriptionView = UITextView()
        descriptionView.backgroundColor = .clear
        descriptionView.font = .systemFont(ofSize: 17)
        descriptionView.isEditable = true
        descriptionView.isScrollEnabled = false
        descriptionView.textColor = .white
        descriptionView.textContainer.lineFragmentPadding = 0
        descriptionView.textContainerInset = .zero
        return descriptionView
    }
}
