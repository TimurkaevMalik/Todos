//
//  TaskModelContainer.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import CoreData

final class TaskModelContainer {
    static let shared = TaskModelContainer()
    
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
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
