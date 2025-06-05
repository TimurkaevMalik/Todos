//
//  TasksView.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

protocol TasksViewInput: AnyObject {
    var presenter: TasksViewOutput? { get set }
    
    func showTasks()
}

protocol TasksViewOutput {
    func viewDidLoad()
    func didSelectRow(at indexPath: IndexPath)
    func deleteTask(at indexPath: IndexPath)
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
        config.baseBackgroundColor = .appGray
        
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
//        uiView.delegate = self
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
        
    func showTasks() {
        tableView.reloadData()
    }
    
    private func setTextForTasksAmountLabel(_ amount: Int) {
        if amount == 0 {
            tasksAmountLabel.text = "Нет задач"
        } else {
            tasksAmountLabel.text = "\(amount) Задач"
        }
    }
}



extension TasksView: TaskCellDelegate {
    func deleteTask(for cell: TaskCell) {
        
    }
    
    func shareTask(for cell: TaskCell) {
        
    }
    
    func editTask(for cell: TaskCell) {
        
    }
    
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
        cell.configureCell(with: task, delegate: self)
        
        return cell
    }
    
    func setEdgeInsets(for row: Int) -> UIEdgeInsets {
        if row != presenter?.numberOfTasks() {
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }
}

extension TasksView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            guard let self = self,
                  let task = self.presenter?.task(at: indexPath) else { return nil }
            
            return self.createContextMenu(for: task, at: indexPath)
        }
    }
    
    private func createContextMenu(for task: TaskDTO, at indexPath: IndexPath) -> UIMenu {
        // 1. Действие "Редактировать"
        let editAction = UIAction(
            title: "Редактировать",
            image: UIImage(systemName: "pencil"),
            identifier: nil
        ) { [weak self] _ in
            self?.presenter?.editTask(at: indexPath)
        }
        
        // 2. Действие "Поделиться"
        let shareAction = UIAction(
            title: "Поделиться",
            image: UIImage(systemName: "square.and.arrow.up"),
            identifier: nil
        ) { [weak self] _ in
            self?.shareTask(task)
        }
        
        // 3. Действие "Удалить"
        let deleteAction = UIAction(
            title: "Удалить",
            image: UIImage(systemName: "trash"),
            identifier: nil,
            attributes: .destructive
        ) { [weak self] _ in
            self?.presenter?.deleteTask(at: indexPath)
        }
        
        // Собираем меню
        return UIMenu(
            title: task.title,
            children: [editAction, shareAction, deleteAction]
        )
    }
    
    private func shareTask(_ task: TaskDTO) {
        let textToShare = "Задача: \(task.title)\nОписание: \(task.todo)"
        let activityVC = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}

private extension TasksView {
    func setupUI() {
        configureSearchController()
        configureNavController()
        
        bottomBarContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomBarContainer.backgroundColor = .appGray
        
        view.addSubview(tableView)
        view.addSubview(bottomBarContainer)
        view.addSubview(editButton)
        view.addSubview(tasksAmountLabel)
        
        let horizontalSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalSpacing),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalSpacing),
            
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
        let placeHolder = NSLocalizedString("searchBar.placeholder", comment: "Text displayed inside of searchBar as placeholder")
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appGray,
            .font: UIFont.regular17()
        ]
        
        let atributedString = NSMutableAttributedString(string: placeHolder,
                                                        attributes: attributes)
        
        
        searchController.searchBar.searchTextField.attributedPlaceholder = atributedString
        searchController.searchBar.searchTextField.leftView?.tintColor = .appGray
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.layer.cornerRadius = 10
        searchController.searchBar.layer.masksToBounds = true
        searchController.searchBar.isTranslucent = false
        
        navigationItem.searchController = searchController
    }
}
