//
//  TaskModelContainer.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import CoreData

protocol AnyTaskModelContainer {
    func newBackgroundContext() -> NSManagedObjectContext
}

final class TaskModelContainer: AnyTaskModelContainer {
    
    static let shared = TaskModelContainer()
    
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskModel")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Catched error while loading Persistent Stores. Error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
