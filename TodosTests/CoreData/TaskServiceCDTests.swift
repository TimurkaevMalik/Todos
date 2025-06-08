//
//  TaskServiceCDTests.swift
//  Todos
//
//  Created by Malik Timurkaev on 08.06.2025.
//

import XCTest
@testable import Todos

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
    
    // MARK: - Create Tests
    func testCreateTasksSuccess() {
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
        
        wait(for: [expectation], timeout: 1)
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
        
        wait(for: [expectation], timeout: 1)
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
        
        wait(for: [expectation], timeout: 1)
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
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Update Tests
    func testUpdateTaskSuccess() {
        let expectation = XCTestExpectation(description: "Update task success")
        
        let taskID = UUID()
        let originalTask = TaskDTO(id: taskID, createdAt: Date(), title: "Original", todo: "Task", isCompleted: false)
        let updatedTask = TaskDTO(id: taskID, createdAt: Date(), title: "Updated", todo: "Task", isCompleted: true)
    
        sut.createTasks([originalTask]) { _ in
            self.sut.updateTask(updatedTask) { result in

                switch result {
                case .success:
                    self.sut.fetchAllTasks { result in
                        if case .success(let tasks) = result {
                            XCTAssertEqual(tasks.first?.title, "Updated")
                            XCTAssertEqual(tasks.first?.isCompleted, true)
                        } else {
                            XCTFail("Failed to verify update")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Expected success, got failure: \(error.message)")
                }
            }
        }
    
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Delete Tests
    func testDeleteTaskSuccess() {
        let expectation = XCTestExpectation(description: "Delete task success")
        
        let task = TaskDTO(id: UUID(), createdAt: Date(), title: "To delete", todo: "Task", isCompleted: false)
        
        sut.createTasks([task]) { _ in

            self.sut.deleteTask(by: task.id) { result in

                switch result {
                case .success:
                    self.sut.fetchAllTasks { result in
                        if case .success(let tasks) = result {
                            XCTAssertTrue(tasks.isEmpty)
                        } else {
                            XCTFail("Failed to verify deletion")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Expected success, got failure: \(error.message)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
