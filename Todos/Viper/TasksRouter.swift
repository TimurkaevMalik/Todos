//
//  TasksRouter.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

protocol TasksRouterInput {
    var presenter: TasksRouterOutput? { get set }
    var viewController: UIViewController? { get set }
    func showTaskDetail(for task: TaskDTO)
    func showErrorAlert(with error: NetworkError)
}

protocol TasksRouterOutput: AnyObject {
    func retryTasksRequest()
}

final class TasksRouter: TasksRouterInput {
    weak var presenter: TasksRouterOutput?
    weak var viewController: UIViewController?
    
    func showTaskDetail(for task: TaskDTO) {
        
        guard let viewController else { return }
        let detailVC = TaskDetailModuleBuilder.build(with: task)
        viewController.navigationController?.pushViewController(detailVC,
                                                                animated: true)
    }
    
    func showErrorAlert(with error: NetworkError) {
        let alert = UIAlertController(title: "Could not load tasks",
                                      message: error.message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let repeatRequest = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            
            guard let self else { return }
            self.presenter?.retryTasksRequest()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(repeatRequest)
        
        viewController?.present(alert, animated: true)
    }
}
