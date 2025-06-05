//
//  TaskCell.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func shouldSetTaskAsDone(for cell: TaskCell) -> Bool
    func showTaskDetails(for cell: TaskCell)
    func deleteTask(for cell: TaskCell)
    func shareTask(for cell: TaskCell)
    func editTask(for cell: TaskCell)
}

final class TaskCell: UITableViewCell {
    
    static let identifier = String(describing: TaskCell.self)
    
    private weak var delegate: TaskCellDelegate?
    
    private lazy var taskEditorButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self else { return }
                
                self.delegate?.showTaskDetails(for: self)
            }),
            for: .touchUpInside)
                
        return button
    }()
    
    private lazy var checkMarkButton = {
        let button = CheckMarkButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(
            UIAction{ [weak self] _ in
                guard let self else { return }
                
                self.toggleTaskCompletion()
            },
            for: .touchUpInside)
        
        return button
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .medium15()
        return label
    }()
    
    private let descriptionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .regular12()
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appGray
        label.numberOfLines = 1
        label.font = .regular12()
        return label
    }()
    
    private lazy var menuBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appGray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupInteraction()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hideMenu()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with task: TaskDTO, delegate: TaskCellDelegate) {
        self.delegate = delegate
        
        titleLabel.attributedText = nil
        
        titleLabel.text = task.title
        descriptionLabel.text = task.todo
        dateLabel.text = CustomDateFormatter.shared.string(from: task.createdAt)
        
        configureViews(by: task.isCompleted)
    }
    
    private func configureViews(by isCompleted: Bool) {
        checkMarkButton.isMarked = isCompleted
        let color: UIColor = isCompleted ? .appGray : .appWhite
        let text = titleLabel.text ?? ""
        
        titleLabel.attributedText = isCompleted ? text.strikeThrough() : text.normal()
        
        titleLabel.textColor =  color
        descriptionLabel.textColor = color
    }
    
    private func toggleTaskCompletion() {
        guard let delegate else { return }
        
        let isCompleted = delegate.shouldSetTaskAsDone(for: self)
        configureViews(by: isCompleted)
    }
}

private extension TaskCell {
    func setupCell() {
        contentView.isUserInteractionEnabled = false
        selectionStyle = .none
        backgroundColor = .appBlack
        
        addSubview(checkMarkButton)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(dateLabel)
        addSubview(taskEditorButton)
        sendSubviewToBack(taskEditorButton)
        
        taskEditorButton.backgroundColor = .appBlack
        
        let topAnchorConstant: CGFloat = 6
        let verticalSpacing: CGFloat = 12
        
        NSLayoutConstraint.activate([
            checkMarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkMarkButton.heightAnchor.constraint(equalTo: checkMarkButton.widthAnchor),
            
            checkMarkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkMarkButton.topAnchor.constraint(equalTo: topAnchor, constant: verticalSpacing),
            
            titleLabel.centerYAnchor.constraint(equalTo: checkMarkButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkMarkButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: topAnchorConstant),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: topAnchorConstant),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalSpacing),
            
            taskEditorButton.topAnchor.constraint(equalTo: topAnchor, constant: verticalSpacing),
            taskEditorButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalSpacing),
            taskEditorButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            taskEditorButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

private extension TaskCell {
    private func setupMenuUI() {
        addSubview(menuBackgroundView)
        
        // Переносим лейблы на menuBackgroundView когда активно
        menuBackgroundView.addSubview(titleLabel)
        menuBackgroundView.addSubview(descriptionLabel)
        menuBackgroundView.addSubview(dateLabel)
        menuBackgroundView.addSubview(checkMarkButton)
        
        NSLayoutConstraint.activate([
            menuBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            menuBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            menuBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            menuBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Констрейнты для лейблов внутри menuBackgroundView
            checkMarkButton.leadingAnchor.constraint(equalTo: menuBackgroundView.leadingAnchor, constant: 16),
            checkMarkButton.topAnchor.constraint(equalTo: menuBackgroundView.topAnchor, constant: 16),
            checkMarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkMarkButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: checkMarkButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: menuBackgroundView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: menuBackgroundView.topAnchor, constant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: menuBackgroundView.bottomAnchor, constant: -16)
        ])
    }

    private func setupInteraction() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        // Показываем меню
        showMenu()
        
        // Создаем и показываем UIMenu
        let menu = createContextMenu()
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return menu
        }
        
        if let view = gesture.view {
            let menuController = UIContextMenuInteraction(delegate: self)
            view.addInteraction(menuController)
            
            let location = gesture.location(in: view)
            UIView.performWithoutAnimation {
                menuController.perform(Selector(("_presentMenuAtLocation:")), with: NSValue(cgPoint: location))
            }
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        hideMenu()
    }

    private func showMenu() {
        menuBackgroundView.isHidden = false
    }

    private func hideMenu() {
        menuBackgroundView.isHidden = true
    }

    private func createContextMenu() -> UIMenu {
        let editAction = UIAction(
            title: "Редактировать",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.hideMenu()
            guard let self else { return }
            self.delegate?.editTask(for: self)
        }

        let shareAction = UIAction(
            title: "Поделиться",
            image: UIImage(systemName: "square.and.arrow.up")
        ) { [weak self] _ in
            self?.hideMenu()
            guard let self else { return }
            self.delegate?.shareTask(for: self)
        }
        
        let deleteAction = UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.hideMenu()
            guard let self else { return }
            self.delegate?.deleteTask(for: self)
        }
        
        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }
}

extension TaskCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return self.createContextMenu()
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        hideMenu()
    }
}
