import UIKit

class ActionSheetViewController: UIViewController {

    var onDelete: (() -> Void)?
    var onShare: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Actions"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let deleteButton = ActionSheetButton(iconName: "trash", title: "Delete")
    private let shareButton = ActionSheetButton(iconName: "square.and.arrow.up", title: "Share")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        
        setupLayout()
        setupActions()
    }

    private func setupLayout() {
        // MARK: - Header view (Actions + X)
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Title label (centered in headerView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // Close button (right side)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closeButton)

        // Separator line
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)

        // Action buttons
        let buttonStack = UIStackView(arrangedSubviews: [deleteButton, shareButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            // Header layout
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            // Separator
            separator.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            // Buttons
            buttonStack.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    @objc private func dismissSheet() {
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        dismiss(animated: true)
        onDelete?()
    }

    @objc private func shareTapped() {
        dismiss(animated: true)
        onShare?()
    }
}

class ActionSheetButton: UIButton {
    init(iconName: String, title: String) {
        super.init(frame: .zero)
        
        let icon = UIImage(systemName: iconName)
        setImage(icon, for: .normal)
        setTitle(title, for: .normal)
        
        tintColor = .black
        setTitleColor(.black, for: .normal)
        contentHorizontalAlignment = .left
        spacingBetweenIconAndText()
        heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func spacingBetweenIconAndText() {
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
    }
}
