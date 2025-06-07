//
//  CoreDataTaskService.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//


import CoreData

protocol TaskDataBaseServiceProtocol {
    func createTasks(_ tasks: [TaskDTO],
                    completion: @escaping (Result<Void, ServiceError>) -> Void)
    
    func fetchAllTasks(completion: @escaping(Result<[TaskDTO], ServiceError>) -> Void)
    
    func updateTask(_ task: TaskDTO,
                    completion: @escaping (Result<Void, ServiceError>) -> Void)
    
    func deleteTask(by id: UUID,
                    completion: @escaping (Result<Void, ServiceError>) -> Void)
}

final class TaskServiceCD: TaskDataBaseServiceProtocol {
    
    private let coreDataStack: AnyTaskModelContainer
    private let serialQueue = DispatchQueue(label: "TaskServiceCD.queue",
                                            qos: .userInitiated)
    
    init() {
        self.coreDataStack = TaskModelContainer.shared
    }
    
    // MARK: - Create
    func createTasks(_ tasks: [TaskDTO], completion: @escaping (Result<Void, ServiceError>) -> Void) {
        serialQueue.async {
            let backgroundContext = self.coreDataStack.newBackgroundContext()
            
            backgroundContext.performAndWait {
                do {
                    let request: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
                    request.propertiesToFetch = ["id"]
                    
                    let existingTasks = try backgroundContext.fetch(request)
                    let existingIDs = Set(existingTasks.compactMap({ $0.id }))
                    
                    let newTasks = tasks.filter({
                        !existingIDs.contains($0.id)
                    })
                    
                    for task in newTasks {
                        _ = TaskCD.create(from: task, on: backgroundContext)
                    }
                    
                    
                    try backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        completion(.failure(
                            ServiceError.operation(.insertion,
                                                   code: "\(error.code)")))
                    }
                }
            }
        }
    }
    
    // MARK: - Read
    func fetchAllTasks(completion: @escaping (Result<[TaskDTO], ServiceError>) -> Void) {
        
        serialQueue.async {
            let backgroundContext = self.coreDataStack.newBackgroundContext()
            
            backgroundContext.performAndWait {
                do {
                    let request: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
                    
                    let tasksCD = try backgroundContext.fetch(request)
                    let tasksDTO = tasksCD.map { $0.toDTO() }
                    
                    DispatchQueue.main.async {
                        completion(.success(tasksDTO))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        
                        completion(.failure(
                            .operation(.retrieve,
                                       code: "\(error.code)")))
                    }
                }
            }
        }
    }
    
    // MARK: - Update
    func updateTask(_ task: TaskDTO,
                    completion: @escaping (Result<Void, ServiceError>) -> Void) {
        
        serialQueue.async {
            let backgroundContext = self.coreDataStack.newBackgroundContext()
            
            backgroundContext.performAndWait {
                do {
                    let request: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
                    
                    guard let taskCD = try backgroundContext.fetch(request).first else {
                        throw NSError(domain: "TaskNotFound", code: 404, userInfo: nil)
                    }
                    
                    taskCD.title = task.title
                    taskCD.todo = task.todo
                    taskCD.isCompleted = task.isCompleted
                    
                    try backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        
                        completion(.failure(
                            .operation(.update,
                                       code: "\(error.code)")))
                    }
                }
            }
        }
    }
    
    // MARK: - Delete
    func deleteTask(by id: UUID, completion: @escaping (Result<Void, ServiceError>) -> Void) {
        
        serialQueue.async {
            let backgroundContext = self.coreDataStack.newBackgroundContext()
            
            backgroundContext.performAndWait {
                do {
                    let request: NSFetchRequest<TaskCD> = TaskCD.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                    
                    guard let taskCD = try backgroundContext.fetch(request).first else {
                        throw NSError(domain: "TaskNotFound", code: 404, userInfo: nil)
                    }
                    
                    backgroundContext.delete(taskCD)
                    try backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        
                        completion(.failure(
                            .operation(.deletion,
                                       code: "\(error.code)")))
                    }
                }
            }
        }
    }
}
