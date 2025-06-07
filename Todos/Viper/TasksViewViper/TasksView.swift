//
//  TasksView.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

protocol TasksViewInput: AnyObject {
    var presenter: TasksViewOutput? { get set }
    
    func updateTasks()
    func updateCell(at indexPath: IndexPath)
    func showShareMenu(for text: String)
}

protocol TasksViewOutput {
    func viewDidLoad()
    
    func toggleTaskCompletion(at indexPath: IndexPath)
    func deleteTask(at indexPath: IndexPath)
    func shareTask(at indexPath: IndexPath)
    func editTask(at indexPath: IndexPath)
    
    func task(at indexPath: IndexPath) -> TaskDTO?
    func numberOfTasks() -> Int
    
    func didSearchText(_ text: String)
}

final class TasksView: UIViewController, TasksViewInput {
    var presenter: TasksViewOutput?
    
    private let bottomBarContainer = UIView()
    private let tasksAmountLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appWhite
        label.font = .regular11()
        label.text = "0 Задач"
        
        return label
    }()
    
    private let editButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "square.and.pencil")
        config.baseForegroundColor = .appYellow
        config.baseBackgroundColor = .appGrayDark
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var searchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
    private lazy var tableView = {
        let uiView = UITableView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.showsVerticalScrollIndicator = false
        uiView.backgroundColor = .appBlack
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
        
    func updateTasks() {
        tableView.reloadData()
    }
    
    func updateCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func showShareMenu(for text: String) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
    
    private func setTextForTasksAmountLabel(_ amount: Int) {
        if amount == 0 {
            tasksAmountLabel.text = "Нет задач"
        } else {
            tasksAmountLabel.text = "\(amount) Задач"
        }
    }
    
    private func setEdgeInsets(for row: Int) -> UIEdgeInsets {
        if row != presenter?.numberOfTasks() {
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}

extension TasksView: TaskCellDelegate {
    func deleteTask(for cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.deleteTask(at: indexPath)
    }
    
    func shareTask(for cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.shareTask(at: indexPath)
    }
    
    func editTask(for cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.editTask(at: indexPath)
    }
    
    func shouldSetTaskAsDone(for cell: TaskCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter?.toggleTaskCompletion(at: indexPath)
    }
}

extension TasksView: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController){
        
        if let searchText = searchController.searchBar.text {
            presenter?.didSearchText(searchText)
        }
    }
}

extension TasksView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let tasksAmount = presenter?.numberOfTasks() ?? 0
        setTextForTasksAmountLabel(tasksAmount)
        return tasksAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as? TaskCell,
            let presenter,
            let task = presenter.task(at: indexPath)
        else {
            return UITableViewCell()
        }
        
        cell.separatorInset = setEdgeInsets(for: indexPath.row)
        cell.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cell.preservesSuperviewLayoutMargins = false
        cell.configureCell(with: task, delegate: self)
        
        return cell
    }
}

private extension TasksView {
    func setupUI() {
        configureSearchController()
        configureNavController()
        
        bottomBarContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomBarContainer.backgroundColor = .appGrayDark
        
        tableView.backgroundColor = .red
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 20,
                                              bottom: 0,
                                              right: -20)
        
        view.addSubview(tableView)
        view.addSubview(bottomBarContainer)
        view.addSubview(editButton)
        view.addSubview(tasksAmountLabel)
                
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomBarContainer.heightAnchor.constraint(equalToConstant: 84),
            bottomBarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            editButton.heightAnchor.constraint(equalToConstant: 28),
            editButton.widthAnchor.constraint(equalTo: editButton.heightAnchor),
            editButton.trailingAnchor.constraint(equalTo: bottomBarContainer.trailingAnchor, constant: -20),
            editButton.topAnchor.constraint(equalTo: bottomBarContainer.topAnchor, constant: 12),
            
            tasksAmountLabel.centerYAnchor.constraint(equalTo: editButton.centerYAnchor),
            tasksAmountLabel.centerXAnchor.constraint(equalTo: bottomBarContainer.centerXAnchor)
            ])
    }

    func configureNavController() {
        navigationItem.title = "Задачи"
        navigationController?.navigationBar.tintColor = .appYellow
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appGray,
            .font: UIFont.regular17()
        ]
        
        let atributedString = NSMutableAttributedString(string: "Search",
                                                        attributes: attributes)
        
        searchController.searchBar.searchTextField.attributedPlaceholder = atributedString
        searchController.searchBar.searchTextField.leftView?.tintColor = .appGray
        searchController.searchBar.searchTextField.backgroundColor = .appGrayDark
        searchController.searchBar.barStyle = .black
        searchController.searchBar.layer.cornerRadius = 10
        searchController.searchBar.layer.masksToBounds = true
        
        navigationItem.searchController = searchController
    }
}
