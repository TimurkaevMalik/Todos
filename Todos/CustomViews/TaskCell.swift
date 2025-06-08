//
//  TaskCell.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func shouldSetTaskAsDone(for cell: TaskCell)
    func deleteTask(for cell: TaskCell)
    func shareTask(for cell: TaskCell)
    func editTask(for cell: TaskCell)
}

final class TaskCell: UITableViewCell {
    
    private struct HorizontalAnchors {
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
    }
    
    static let identifier = String(describing: TaskCell.self)
    
    private weak var delegate: TaskCellDelegate?
    private var titleLabelAnchorsH: HorizontalAnchors?
    
    private lazy var contextMenu = createContextMenu()
    
    private lazy var checkMarkButton = {
        let button = CheckMarkButton()
        button.translatesAutoresizingMaskIntoConstraints = false
                
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
        label.textColor = .appGrayDark
        label.numberOfLines = 1
        label.font = .regular12()
        return label
    }()
      
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addInteraction(UIContextMenuInteraction(delegate: self))
        setupCell()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        willHideMenu()
    }
        
    func configureCell(with task: TaskDTO, delegate: TaskCellDelegate) {
        self.delegate = delegate
        
        titleLabel.attributedText = nil
        
        titleLabel.text = task.title
        descriptionLabel.text = task.todo
        dateLabel.text = CustomDateFormatter.shared.string(from: task.createdAt)
        configureViews(by: task.isCompleted)
        
        ///descriptionLabel перекрывает dateLabel при первой загрузке ячейки. Этот метод решает проблему
        dateLabel.layoutIfNeeded()
    }
    
    private func configureViews(by isCompleted: Bool) {
        checkMarkButton.isMarked = isCompleted
        let color: UIColor = isCompleted ? .appGrayDark : .appWhite
        let text = titleLabel.text ?? ""
        
        titleLabel.attributedText = isCompleted ? text.strikeThrough() : text.normal()
        
        titleLabel.textColor =  color
        descriptionLabel.textColor = color
    }
    
    private func toggleTaskCompletion() {
        guard let delegate else { return }
        delegate.shouldSetTaskAsDone(for: self)
    }
}

// MARK: - ContextMenu setup
private extension TaskCell {
    private func willShowMenu() {
        checkMarkButton.isHidden = true
        dateLabel.textColor = .appGray
        backgroundColor = .appGrayDark
        
        titleLabelAnchorsH?.left.constant = -8
        titleLabelAnchorsH?.right.constant = -16
        
        if checkMarkButton.isMarked {
            titleLabel.textColor = .appWhite
            descriptionLabel.textColor = .appWhite
        }
    }

    private func willHideMenu() {
        checkMarkButton.isHidden = false
        dateLabel.textColor = .appGrayDark
        backgroundColor = .appBlack
        
        titleLabelAnchorsH?.left.constant = 8
        titleLabelAnchorsH?.right.constant = 16
        
        if checkMarkButton.isMarked {
            titleLabel.textColor = .appGrayDark
            descriptionLabel.textColor = .appGrayDark
        }
    }

    private func createContextMenu() -> UIMenu {
        let editAction = UIAction(
            title: "Редактировать",
            image: UIImage.redactingPencil
        ) { [weak self] _ in
            guard let self else { return }
            
            self.willHideMenu()
            self.delegate?.editTask(for: self)
        }

        let shareAction = UIAction(
            title: "Поделиться",
            image: UIImage.share
        ) { [weak self] _ in
            guard let self else { return }
            
            self.willHideMenu()
            self.delegate?.shareTask(for: self)
        }
        
        let deleteAction = UIAction(
            title: "Удалить",
            image: UIImage.trashBin,
            attributes: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            
            self.willHideMenu()
            self.delegate?.deleteTask(for: self)
        }
        
        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }
}

// MARK: - ContextMenu setup
extension TaskCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else { return UIMenu() }
            
            self.willShowMenu()
            return self.contextMenu
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        
        willHideMenu()
    }
}

private extension TaskCell {
    
    func setupCell() {
        selectionStyle = .none
        backgroundColor = .appBlack
        
        contentView.addSubview(checkMarkButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        
        let topAnchorConstant: CGFloat = 6
        let verticalSpacing: CGFloat = 12
                
        let leftAnchor = titleLabel.leadingAnchor.constraint(equalTo: checkMarkButton.trailingAnchor, constant: 8)
        let rightAnchor = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
           
        leftAnchor.isActive = true
        rightAnchor.isActive = true
        titleLabelAnchorsH = HorizontalAnchors(left: leftAnchor,
                                                 right: rightAnchor)
        
        NSLayoutConstraint.activate([
            checkMarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkMarkButton.heightAnchor.constraint(equalTo: checkMarkButton.widthAnchor),
            
            checkMarkButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            checkMarkButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: topAnchorConstant),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: topAnchorConstant),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalSpacing),
        ])
    }
    
    func setupActions() {
        checkMarkButton.addAction(
            UIAction{ [weak self] _ in
                guard let self else { return }
                
                self.toggleTaskCompletion()
            },
            for: .touchUpInside)
    }
}
