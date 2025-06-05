//
//  TaskDetailPresenter.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import Foundation

final class TaskDetailPresenter {
    weak var view: TaskDetailViewInput?
    private let task: TaskDTO
    
    init(task: TaskDTO) {
        self.task = task
    }
}

extension TaskDetailPresenter: TaskDetailViewOutput {
    func viewDidLoad() {
        view?.showTask(task)
    }
}
