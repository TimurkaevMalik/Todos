//
//  TaskDetailModuleBuilder.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

final class TaskDetailModuleBuilder {
    static func build(with task: TaskDTO) -> UIViewController {
        let view = TaskDetailView()
        let presenter = TaskDetailPresenter(task: task)
        view.presenter = presenter
        presenter.view = view
        return view
    }
}
