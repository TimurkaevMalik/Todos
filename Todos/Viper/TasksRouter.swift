//
//  TasksRouter.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

protocol TasksRouterInput {
    var viewController: UIViewController? { get set }
    func showTaskDetail(for task: TaskDTO)
}

final class TasksRouter: TasksRouterInput {
    weak var viewController: UIViewController?
    
    func showTaskDetail(for task: TaskDTO) {
        
        guard let viewController else { return }
        print(viewController)
        let detailVC = TaskDetailModuleBuilder.build(with: task)
        viewController.navigationController?.pushViewController(detailVC,
                                                                animated: true)
    }
}
