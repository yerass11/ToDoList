import UIKit
import SnapKit
 
final class TaskTableViewCell: UITableViewCell {
    var onToggleCompletion: ((Task) -> Void)?
    var onTapDetails: (() -> Void)?
    var onContextMenuRequested: (() -> UIMenu?)?

    var task: Task?

    private lazy var circleImageView = makeCircleImageView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var descriptionLabel = makeDescriptionLabel()
    private lazy var dateLabel = makeDateLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
        self.addInteraction(UIContextMenuInteraction(delegate: self))
    }

    required init?(coder: NSCoder) {
        nil
    }
    
    @objc
    private func handleToggleCompletion() {
        guard var task = task else {
            return
        }

        task.isCompleted.toggle()
        onToggleCompletion?(task)
    }

    @objc
    private func handleTapDetails() {
        onTapDetails?()
    }

    private func setup() {
        [circleImageView, titleLabel, descriptionLabel, dateLabel].forEach { contentView.addSubview($0) }
        selectionStyle = .default
        
        setupGestures()
        setupConstraints()
    }
    
    private func setupConstraints() {
        circleImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(circleImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(circleImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-20)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            make.left.equalTo(circleImageView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func setupGestures() {
        circleImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleToggleCompletion)
            )
        )
    }

    func configure(with task: Task) {
        self.task = task

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        
        dateLabel.text = formatter.string(from: task.dateCreated)

        circleImageView.image = nil
        titleLabel.attributedText = nil
        titleLabel.textColor = .label
        titleLabel.text = nil
        descriptionLabel.attributedText = nil
        descriptionLabel.textColor = UIColor(named: "PrimaryColor")
        descriptionLabel.text = nil

        if task.isCompleted {
            circleImageView.image = UIImage(named: "circle-done")
            titleLabel.attributedText = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.tertiaryLabel
                ]
            )
            descriptionLabel.attributedText = NSAttributedString(
                string: task.description,
                attributes: [
                    .foregroundColor: UIColor.tertiaryLabel
                ]
            )
        } else {
            circleImageView.image = UIImage(named: "circle-ongoing")
            titleLabel.text = task.title
            descriptionLabel.text = task.description
        }
    }

    private func makeCircleImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 1
        label.textColor = UIColor(named: "PrimaryColor")
        return label
    }
    
    private func makeDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor(named: "PrimaryColor")
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        return label
    }
    
    private func makeDateLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }
}

extension TaskTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.onContextMenuRequested?()
        }
    }
}
