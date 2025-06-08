//
//  TaskDetailPresenter.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import Foundation

protocol TaskDetailModuleDelegate: AnyObject {
    func didUpdateTask(_ task: TaskDTO)
}

final class TaskDetailPresenter {
    weak var view: TaskDetailViewInput?
    weak var delegate: TaskDetailModuleDelegate?
    private var interactor: TaskDetailInteractorInput
    private var task: TaskDTO
    
    init(task: TaskDTO,
         interactor: TaskDetailInteractorInput,
         delegate: TaskDetailModuleDelegate? = nil) {
        self.task = task
        self.interactor = interactor
        self.delegate = delegate
    }
}

extension TaskDetailPresenter: TaskDetailViewOutput {
    func viewDidLoad() {
        view?.showTask(task)
    }
    
    func updateTask(title: String, description: String) {
        
        if task.title != title || task.todo != description {
            task.title = title
            task.todo = description
            interactor.updateTask(task)
        }
    }
}

extension TaskDetailPresenter: TaskDetailInteractorOutput {
    func didUpdateTask() {
        delegate?.didUpdateTask(task)
    }
}
