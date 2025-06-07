//
//  TasksInteractor.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import Foundation

protocol TasksInteractorInput {
    var presenter: TasksInteractorOutput? { get set }
    func fetchTasks()
    func deleteTask(_ id: UUID)
    func updateTask(_ task: TaskDTO)
}
protocol TasksInteractorOutput: AnyObject {
    func didReceiveTasks(_ tasks: [TaskDTO])
    func tasksFetchFailed(_ error: NetworkError)
}

final class TasksInteractor: TasksInteractorInput {
    
    weak var presenter: TasksInteractorOutput?
    
    private let networkService: NetworkServiceTasksProtocol
    private let dataBaseService: TaskDataBaseServiceProtocol
    
    init(output: TasksInteractorOutput? = nil,
         networkService: NetworkServiceTasksProtocol,
         dataBaseService: TaskDataBaseServiceProtocol) {
        
        self.presenter = output
        self.networkService = networkService
        self.dataBaseService = dataBaseService
    }
    
    func fetchTasks() {
        dataBaseTaskRequest()
    }
    
    private func dataBaseTaskRequest() {
        dataBaseService.fetchAllTasks { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let tasks):
                
                if !tasks.isEmpty {
                    self.presenter?.didReceiveTasks(tasks)
                } else {
                    self.networkTaskRequest()
                }
                
            case .failure(let failure):
                assertionFailure(failure.message)
                self.networkTaskRequest()
            }
        }
    }
    
    private func networkTaskRequest() {
        networkService.fetchTasks { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let tasks):
                
                if !tasks.isEmpty {
                    self.presenter?.didReceiveTasks(tasks)
                    self.saveTasks(tasks)
                }
            case .failure(let failure):
                self.presenter?.tasksFetchFailed(failure)
            }
        }
    }
    
    private func saveTasks(_ tasks: [TaskDTO]) {
        dataBaseService.createTasks(tasks) { result in
            
            switch result {
            case .success:
                break
            case .failure(let failure):
                assertionFailure(failure.message)
            }
        }
    }
    
    func updateTask(_ task: TaskDTO) {
        dataBaseService.updateTask(task) { result in
            
            switch result {
            case .success:
                break
            case .failure(let failure):
                assertionFailure(failure.message)
            }
        }
    }
    
    func deleteTask(_ id: UUID) {
        dataBaseService.deleteTask(by: id) { result in
            
            switch result {
            case .success:
                break
            case .failure(let failure):
                assertionFailure(failure.message)
            }
        }
    }
}
