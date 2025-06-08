//
//  TaskModelContainer.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import CoreData

protocol AnyTaskModelContainer {
    var backgroundContext: NSManagedObjectContext { get }
}

final class TaskModelContainer: AnyTaskModelContainer {
    
    static let shared = TaskModelContainer()
    
    private let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TaskModel")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Catched error while loading Persistent Stores. Error: \(error.localizedDescription)")
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
