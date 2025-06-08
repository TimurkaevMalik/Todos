//
//  MockTaskModelContainer.swift
//  Todos
//
//  Created by Malik Timurkaev on 08.06.2025.
//

import CoreData
@testable import Todos

final class MockTaskModelContainer: AnyTaskModelContainer {
    
    private let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TaskModel")
        let description = persistentContainer.persistentStoreDescriptions.first
        
        description?.type = NSInMemoryStoreType
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
