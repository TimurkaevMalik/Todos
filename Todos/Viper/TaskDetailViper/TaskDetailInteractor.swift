//
//  TaskDetailInteractor.swift
//  Todos
//
//  Created by Malik Timurkaev on 06.06.2025.
//

import Foundation

protocol TaskDetailInteractorInput {
    var presenter: TaskDetailInteractorOutput? { get set }
    func updateTask(_ task: TaskDTO)
}

protocol TaskDetailInteractorOutput: AnyObject {
    func didUpdateTask()
}

final class TaskDetailInteractor: TaskDetailInteractorInput {
    weak var presenter: TaskDetailInteractorOutput?
    
    private let dataBase: TaskDataBaseServiceProtocol
    
    init(dataBase: TaskDataBaseServiceProtocol) {
        self.dataBase = dataBase
    }
    
    func updateTask(_ task: TaskDTO) {
        
        dataBase.updateTask(task) { result in
            
            switch result {
            case .success:
                self.presenter?.didUpdateTask()
            case .failure:
                break
            }
        }
    }
}
