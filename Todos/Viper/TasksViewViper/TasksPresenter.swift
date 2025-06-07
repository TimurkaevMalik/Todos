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
    
    ///Добавил lock для tasks, потому что массив может меняться с двух потоков
    private let tasksLock = NSLock()
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
    func toggleTaskCompletion(at indexPath: IndexPath) {
        
        if var task = visibleTasks[safe: indexPath.row] {
            
            task.isCompleted.toggle()
            interactor.updateTask(task)
            
            visibleTasks.safeRemove(at: indexPath.row)
            visibleTasks.insert(task, at: indexPath.row)
            view?.updateCell(at: indexPath)
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        if let id = visibleTasks[safe: indexPath.row]?.id {
            
            interactor.deleteTask(id)
            visibleTasks.safeRemove(at: indexPath.row)
            view?.updateTasks()
        }
    }
    
    func editTask(at indexPath: IndexPath) {
        if let task = visibleTasks[safe: indexPath.row] {
            router.showTaskDetail(for: task, delegate: self)
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
        visibleTasks.count
    }
        
    func didSearchText(_ text: String) {
        searchedText = text
        
        filterTitles(by: searchedText)
        view?.updateTasks()
    }
}

extension TasksPresenter: TasksInteractorOutput {
    func didReceiveTasks(_ tasks: [TaskDTO]) {
        tasksLock.lock()
        self.tasks = tasks
        tasksLock.unlock()
        
        filterTitles(by: searchedText)
        view?.updateTasks()
    }
    
    func tasksFetchFailed(_ error: NetworkError) {
        router.showErrorAlert(with: error.message)
    }
}

extension TasksPresenter: TasksRouterOutput {
    func retryTasksRequest() {
        interactor.fetchTasks()
    }
}

extension TasksPresenter: TaskDetailModuleDelegate {
    ///Первожу на фоновый поток, потому что операция занимает O(n)
    func didUpdateTask(_ task: TaskDTO) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.tasksLock.lock()
            if let index = self.tasks.firstIndex(where: { $0.id == task.id}) {
                
                self.tasks[index] = task
            }
            self.tasksLock.unlock()
            
            DispatchQueue.main.async {
                self.filterTitles(by: self.searchedText)
                self.view?.updateTasks()
            }
        }
    }
}
