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
    
    init(interactor: TasksInteractorInput,
         router: TasksRouterInput) {
        
        self.interactor = interactor
        self.router = router
    }
}

extension TasksPresenter: TasksViewOutput {
    func didSelectRow(at indexPath: IndexPath) {
        if let task = tasks[safe: indexPath.row] {
            router.showTaskDetail(for: task)
        }
    }
    
    func task(at indexPath: IndexPath) -> TaskDTO? {
        tasks[safe: indexPath.row]
    }
    
    func numberOfTasks() -> Int {
        print(tasks.count)
        return tasks.count
    }
    
    func viewDidLoad() {
        interactor.fetchTasks()
    }
}

extension TasksPresenter: TasksInteractorOutput {
    func didReceiveTasks(_ tasks: [TaskDTO]) {
        self.tasks = tasks
        view?.showTasks(tasks)
    }
    
    func tasksFetchFailed(_ error: any Error) {
        print(error)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
