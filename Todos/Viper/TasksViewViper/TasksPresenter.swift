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
    
    private func filterBySearchedText() {
        if !searchedText.isEmpty {
            visibleTasks = tasks.filter({
                $0.title.lowercased().contains(searchedText.lowercased())
            })
        } else {
            visibleTasks = tasks
        }
    }
}

extension TasksPresenter: TasksViewOutput {
    func viewDidLoad() {
        interactor.fetchTasks()
    }
    
    func toggleTaskCompletion(at indexPath: IndexPath) {
        ///Операция быстрая и занимает O(1) - можно на главном потоке проводить
        guard var task = visibleTasks[safe: indexPath.row] else { return }
        
        task.isCompleted.toggle()
        interactor.updateTask(task)
        
        visibleTasks.safeRemove(at: indexPath.row)
        visibleTasks.insert(task, at: indexPath.row)
        view?.updateTasks()
        
        ///Операция занимает O(n), поэтому перевожу на фоновый поток
        DispatchQueue.global(qos: .userInitiated).async {
            self.tasksLock.lock()
            if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                
                self.tasks.safeRemove(at: index)
                self.tasks.insert(task, at: index)
            }
            self.tasksLock.unlock()
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        guard let id = visibleTasks[safe: indexPath.row]?.id else { return }
        
        visibleTasks.safeRemove(at: indexPath.row)
        self.view?.updateTasks()
        
        ///Операция занимает O(n), поэтому перевожу на фоновый поток
        DispatchQueue.global(qos: .userInteractive).async {
            self.tasksLock.lock()
            if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                
                self.interactor.deleteTask(id)
                self.tasks.safeRemove(at: index)
            }
            self.tasksLock.unlock()
        }
    }
    
    func editTask(at indexPath: IndexPath) {
        if let task = visibleTasks[safe: indexPath.row] {
            router.showTaskDetail(for: task, delegate: self)
        }
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
        
        filterBySearchedText()
        view?.updateTasks()
    }
    
    func createTaskButtonTap() {
        let newTask = TaskDTO(title: "Title",
                              todo: "Description")
        router.showTaskDetail(for: newTask, delegate: self)
    }
}

extension TasksPresenter: TasksInteractorOutput {
    func didReceiveTasks(_ tasks: [TaskDTO]) {
        tasksLock.lock()
        self.tasks = tasks
        tasksLock.unlock()
        
        filterBySearchedText()
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
    ///Операция занимает O(n), поэтому перевожу на фоновый поток
    func didUpdateTask(_ task: TaskDTO) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.tasksLock.lock()
            if let index = self.tasks.firstIndex(where: { $0.id == task.id}) {
                
                self.tasks[index] = task
                
            } else {
                self.tasks.append(task)
            }
            
            DispatchQueue.main.async {
                self.filterBySearchedText()
                self.view?.updateTasks()
            }
            
            self.tasksLock.unlock()
        }
    }
}
