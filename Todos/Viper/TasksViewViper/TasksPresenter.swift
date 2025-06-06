//
//  TasksPresenter.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import Foundation

final class TasksPresenter {
    
    private var interactor: TasksInteractorInput
    private var router: TasksRouterInput
    weak var view: TasksViewInput?
    
    private var tasks = [TaskDTO]()
    private var visibleTasks = [TaskDTO]()
    private var searchedText = ""
    
    init(interactor: TasksInteractorInput,
         router: TasksRouterInput) {
        
        self.interactor = interactor
        self.router = router
    }
    
    private func filterTitles(by text: String) {
        if !text.isEmpty {
            visibleTasks = tasks.filter({
                $0.title.lowercased().contains(text.lowercased())
            })
        } else {
            visibleTasks = tasks
        }
    }
}

extension TasksPresenter: TasksViewOutput {
    func deleteTask(at indexPath: IndexPath) {
        print(indexPath)
    }
    
    func editTask(at indexPath: IndexPath) {
        if let task = tasks[safe: indexPath.row] {
            router.showTaskDetail(for: task)
        }
    }
    
    func viewDidLoad() {
        interactor.fetchTasks()
    }

    func shareTask(at indexPath: IndexPath) {
        guard let task = visibleTasks[safe: indexPath.row] else { return }
        let textToShare = "Задача: \(task.title)\nОписание: \(task.todo)"
        view?.showShareMenu(for: textToShare)
    }
    
    func task(at indexPath: IndexPath) -> TaskDTO? {
        visibleTasks[safe: indexPath.row]
    }
    
    func numberOfTasks() -> Int {
        return visibleTasks.count
    }
        
    func didSearchText(_ text: String) {
        searchedText = text
        
        filterTitles(by: searchedText)
        view?.showTasks()
    }
}

extension TasksPresenter: TasksInteractorOutput {
    func didReceiveTasks(_ tasks: [TaskDTO]) {
        self.tasks = tasks
        
        filterTitles(by: searchedText)
        view?.showTasks()
    }
    
    func tasksFetchFailed(_ error: NetworkError) {
        router.showErrorAlert(with: error)
    }
}

extension TasksPresenter: TasksRouterOutput {
    func retryTasksRequest() {
        interactor.fetchTasks()
    }
}
