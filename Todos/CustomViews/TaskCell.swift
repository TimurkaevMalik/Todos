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
        label.numberOfLines = 1
        label.font = .regular12()
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with task: TaskDTO, delegate: TaskCellDelegate) {
        self.delegate = delegate
        titleLabel.text = task.title
        descriptionLabel.text = task.todo
        dateLabel.text = "\(task.createdAt)"
        
        configureViews(by: task.isCompleted)
    }
    
    private func configureViews(by isCompleted: Bool) {
        checkMarkButton.isMarked = isCompleted

        let textColor: UIColor = isCompleted ? .appGrayMedium : .appWhite
        titleLabel.textColor =  textColor
        descriptionLabel.textColor = textColor
        
        dateLabel.textColor = .appGrayMedium
        
        if isCompleted {
            titleLabel.attributedText = titleLabel.text?.strikeThrough()
        } else {
            titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "")
        }
    }
    
    private func toggleTaskCompletion() {
        guard let delegate else { return }
        
        let isCompleted = delegate.shouldSetTaskAsDone(for: self)
        configureViews(by: isCompleted)
    }
}

private extension TaskCell {
    func setupCell() {
        backgroundColor = .appBlack
        
        addSubview(checkMarkButton)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(dateLabel)
        addSubview(taskEditorButton)
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
