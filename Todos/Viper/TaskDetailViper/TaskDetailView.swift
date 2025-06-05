//
//  TaskDetailViewInput.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

protocol TaskDetailViewInput: AnyObject {
    func showTask(_ task: TaskDTO)
}

protocol TaskDetailViewOutput: AnyObject {
    func viewDidLoad()
}

final class TaskDetailView: UIViewController, TaskDetailViewInput {
    weak var presenter: TaskDetailViewOutput?
    
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    func showTask(_ task: TaskDTO) {
        titleLabel.text = task.title
    }
    
    private func setupUI() {
        view.backgroundColor = .appBlack
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
