//
//  TaskServiceCD.swift
//  Todos
//
//  Created by Malik Timurkaev on 08.06.2025.
//

import XCTest
@testable import Todos

import CoreData

class TaskServiceCDTests: XCTestCase {
    
    var sut: TaskServiceCD!
    var mockContainer: MockTaskModelContainer!
    
    override func setUp() {
        super.setUp()
        mockContainer = MockTaskModelContainer()
        sut = TaskServiceCD(stackCD: mockContainer)
    }
    
    override func tearDown() {
        sut = nil
        mockContainer = nil
        super.tearDown()
    }
    
    private func clearDatabase() {
        
        mockContainer.backgroundContext.perform {
            do {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaskCD.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try self.mockContainer.backgroundContext.execute(deleteRequest)
                try self.mockContainer.backgroundContext.save()
            } catch {
                XCTFail("Failed to clear database: \(error)")
            }
        }
    }
    
    // MARK: - Create Tests
    func testCreateTasksSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "Create tasks success")
        let tasks = [
            TaskDTO(id: UUID(), createdAt: Date(), title: "Task 1", todo: "Do something", isCompleted: false),
            TaskDTO(id: UUID(), createdAt: Date(), title: "Task 2", todo: "Do something else", isCompleted: true)
        ]
        
        sut.createTasks(tasks) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure(let error):
                XCTFail("Expected success, got failure: \(error.message)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTasksWithExistingID() {
        let expectation = XCTestExpectation(description: "Create tasks with existing ID")
        let existingID = UUID()
        let existingTask = TaskDTO(id: existingID, createdAt: Date(), title: "Existing", todo: "Task", isCompleted: false)
        
        sut.createTasks([existingTask]) { _ in

            self.sut.createTasks([existingTask]) { result in

                switch result {
                case .success:
                    XCTAssertTrue(true)
                case .failure:
                    XCTFail("Should filter out duplicates without error")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
        
    // MARK: - Fetch Tests
    func testFetchAllTasksSuccess() {
        let expectation = XCTestExpectation(description: "Fetch all tasks success")
        let tasks = [
            TaskDTO(id: UUID(), createdAt: Date(), title: "Task 1", todo: "Do something", isCompleted: false),
            TaskDTO(id: UUID(), createdAt: Date(), title: "Task 2", todo: "Do something else", isCompleted: true)
        ]
        
        sut.createTasks(tasks) { _ in

            self.sut.fetchAllTasks { result in

                switch result {
                case .success(let fetchedTasks):
                    XCTAssertEqual(fetchedTasks.count, tasks.count)
                case .failure(let error):
                    XCTFail("Expected success, got failure: \(error.message)")
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllTasksEmpty() {
        let expectation = XCTestExpectation(description: "Fetch all tasks empty")
        
        sut.fetchAllTasks { result in
            switch result {
            case .success(let tasks):
                XCTAssertTrue(tasks.isEmpty)
            case .failure(let error):
                XCTFail("Expected success, got failure: \(error.message)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllTasksWithCoreDataError() {
        let expectation = XCTestExpectation(description: "Fetch all tasks with CoreData error")
        
//        mockContainer.shouldThrowError = true
        
        sut.fetchAllTasks { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                if case .operation(let type, _) = error {
                    XCTAssertEqual(type, .retrieve)
                } else {
                    XCTFail("Unexpected error type")
                }
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock CoreData Stack
final class MockTaskModelContainer: AnyTaskModelContainer {
    private let shouldThrowError: Bool
    
    private let persistentContainer: NSPersistentContainer
    
    lazy var backgroundContext: NSManagedObjectContext = {
        
        if shouldThrowError {
            let context = MockManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.shouldThrowError = true
            return context
        }
        
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    init(throwError: Bool = false) {
        shouldThrowError = throwError
        
        persistentContainer = NSPersistentContainer(name: "TaskModel")
        let description = persistentContainer.persistentStoreDescriptions.first
        
        description?.type = NSInMemoryStoreType
                
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}


class MockManagedObjectContext: NSManagedObjectContext {
    var shouldThrowError = false
    
    override func performAndWait(_ block: () -> Void) {
        if shouldThrowError {
            return
        }
        super.performAndWait(block)
    }
    
    override func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 999, userInfo: nil)
        }
        try super.save()
    }
}

//// MARK: - Update Tests
//
//func testUpdateTaskSuccess() {
//    // Given
//    let expectation = XCTestExpectation(description: "Update task success")
//    let taskID = UUID()
//    let originalTask = TaskDTO(id: taskID, createdAt: Date(), title: "Original", todo: "Task", isCompleted: false)
//    let updatedTask = TaskDTO(id: taskID, createdAt: Date(), title: "Updated", todo: "Task", isCompleted: true)
//    
//    // First create a task
//    sut.createTasks([originalTask]) { _ in
//        // Then update it
//        self.sut.updateTask(updatedTask) { result in
//            // Then
//            switch result {
//            case .success:
//                // Verify the update
//                self.sut.fetchAllTasks { result in
//                    if case .success(let tasks) = result {
//                        XCTAssertEqual(tasks.first?.title, "Updated")
//                        XCTAssertEqual(tasks.first?.isCompleted, true)
//                    } else {
//                        XCTFail("Failed to verify update")
//                    }
//                    expectation.fulfill()
//                }
//            case .failure(let error):
//                XCTFail("Expected success, got failure: \(error.message)")
//            }
//        }
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
//
//func testUpdateNonExistingTask() {
//    // Given
//    let expectation = XCTestExpectation(description: "Update non-existing task")
//    let nonExistingTask = TaskDTO(id: UUID(), createdAt: Date(), title: "Non-existing", todo: "Task", isCompleted: false)
//    
//    // When
//    sut.updateTask(nonExistingTask) { result in
//        // Then
//        switch result {
//        case .success:
//            XCTFail("Expected failure, got success")
//        case .failure(let error):
//            if case .operation(let type, let code) = error {
//                XCTAssertEqual(type, .update)
//                XCTAssertEqual(code, "404")
//            } else {
//                XCTFail("Unexpected error type")
//            }
//        }
//        expectation.fulfill()
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
//
//func testUpdateTaskWithCoreDataError() {
//    // Given
//    let expectation = XCTestExpectation(description: "Update task with CoreData error")
//    let taskID = UUID()
//    let task = TaskDTO(id: taskID, createdAt: Date(), title: "Task", todo: "To update", isCompleted: false)
//    
//    // First create a task
//    sut.createTasks([task]) { _ in
//        // Then try to update with error
//        self.mockContainer.shouldThrowError = true
//        self.sut.updateTask(task) { result in
//            // Then
//            switch result {
//            case .success:
//                XCTFail("Expected failure, got success")
//            case .failure(let error):
//                if case .operation(let type, _) = error {
//                    XCTAssertEqual(type, .update)
//                } else {
//                    XCTFail("Unexpected error type")
//                }
//            }
//            expectation.fulfill()
//        }
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
//
//// MARK: - Delete Tests
//
//func testDeleteTaskSuccess() {
//    // Given
//    let expectation = XCTestExpectation(description: "Delete task success")
//    let taskID = UUID()
//    let task = TaskDTO(id: taskID, createdAt: Date(), title: "To delete", todo: "Task", isCompleted: false)
//    
//    // First create a task
//    sut.createTasks([task]) { _ in
//        // Then delete it
//        self.sut.deleteTask(by: taskID) { result in
//            // Then
//            switch result {
//            case .success:
//                // Verify deletion
//                self.sut.fetchAllTasks { result in
//                    if case .success(let tasks) = result {
//                        XCTAssertTrue(tasks.isEmpty)
//                    } else {
//                        XCTFail("Failed to verify deletion")
//                    }
//                    expectation.fulfill()
//                }
//            case .failure(let error):
//                XCTFail("Expected success, got failure: \(error.message)")
//            }
//        }
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
//
//func testDeleteNonExistingTask() {
//    // Given
//    let expectation = XCTestExpectation(description: "Delete non-existing task")
//    let nonExistingID = UUID()
//    
//    // When
//    sut.deleteTask(by: nonExistingID) { result in
//        // Then
//        switch result {
//        case .success:
//            XCTFail("Expected failure, got success")
//        case .failure(let error):
//            if case .operation(let type, let code) = error {
//                XCTAssertEqual(type, .deletion)
//                XCTAssertEqual(code, "404")
//            } else {
//                XCTFail("Unexpected error type")
//            }
//        }
//        expectation.fulfill()
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
//
//func testDeleteTaskWithCoreDataError() {
//    // Given
//    let expectation = XCTestExpectation(description: "Delete task with CoreData error")
//    let taskID = UUID()
//    let task = TaskDTO(id: taskID, createdAt: Date(), title: "Task", todo: "To delete", isCompleted: false)
//    
//    // First create a task
//    sut.createTasks([task]) { _ in
//        // Then try to delete with error
//        self.mockContainer.shouldThrowError = true
//        self.sut.deleteTask(by: taskID) { result in
//            // Then
//            switch result {
//            case .success:
//                XCTFail("Expected failure, got success")
//            case .failure(let error):
//                if case .operation(let type, _) = error {
//                    XCTAssertEqual(type, .deletion)
//                } else {
//                    XCTFail("Unexpected error type")
//                }
//            }
//            expectation.fulfill()
//        }
//    }
//    
//    wait(for: [expectation], timeout: 1.0)
//}
