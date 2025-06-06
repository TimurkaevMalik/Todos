//
//  TasksModuleBuilder.swift
//  Todos
//
//  Created by Malik Timurkaev on 04.06.2025.
//

import UIKit

typealias EntryPoint = TasksViewInput & UIViewController

final class TasksModuleBuilder {
    
    static func build() -> EntryPoint {
        
        let view = TasksView()
        let router = TasksRouter()
        
        let networkService = NetworkServiceTasks()
        let dataBase = TaskServiceCD(coreDataStack: TaskModelContainer.shared)
        let interactor = TasksInteractor(networkService: networkService,
                                         dataBaseService: dataBase)
        
        let presenter = TasksPresenter(interactor: interactor,
                                       router: router)
        
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.presenter = presenter
        router.viewController = view
        
        return view
    }
}
