//
//  TasksView.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

protocol TasksViewInput: AnyObject {
    var presenter: TasksViewOutput? { get set }
    
    func showTasks(_ tasks: [TaskDTO])
}

protocol TasksViewOutput {
    func viewDidLoad()
    func didSelectRow(at indexPath: IndexPath)
    func task(at indexPath: IndexPath) -> TaskDTO?
    func numberOfTasks() -> Int
}

final class TasksView: UIViewController, TasksViewInput {
    var presenter: TasksViewOutput?
    
    private lazy var tableView = {
        let uiView = UITableView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
//        uiView.delegate = self
        uiView.dataSource = self
        uiView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.identifier)
        
        return uiView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        setupUI()
        presenter?.viewDidLoad()
    }
    
    func showTasks(_ tasks: [TaskDTO]) {
        tableView.reloadData()
    }
}

private extension TasksView {
    func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Задачи"
        
        view.addSubview(tableView)
        
        let horizontalSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
        ])
    }
}

extension TasksView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfTasks() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell,
            let presenter,
            let task = presenter.task(at: indexPath)
        else {
            return UITableViewCell()
        }
        
        cell.configureCell(with: task, delegate: self)
        return cell
    }
}

extension TasksView: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presenter?.didSelectRow(at: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
}

extension TasksView: TaskCellDelegate {
    func showTaskDetails(for cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        presenter?.didSelectRow(at: indexPath)
    }
    
    func shouldSetTaskAsDone(for cell: TaskCell) -> Bool {
        return true
    }
}
