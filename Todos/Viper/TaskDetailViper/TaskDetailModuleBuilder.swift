//
//  TaskDetailModuleBuilder.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

final class TaskDetailModuleBuilder {
    static func build(with task: TaskDTO, delegate: TaskDetailModuleDelegate) -> UIViewController {
        let view = TaskDetailView()
        let interactor = TaskDetailInteractor(dataBase: TaskServiceCD())
        let presenter = TaskDetailPresenter(task: task,
                                            interactor: interactor,
                                            delegate: delegate)
        
        view.presenter = presenter
        presenter.view = view
        interactor.presenter = presenter
        
        return view
    }
}
