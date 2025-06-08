//
//  TaskDTOTests.swift
//  Todos
//
//  Created by Malik Timurkaev on 07.06.2025.
//

import XCTest
@testable import Todos

final class TaskDTOTests: XCTestCase {
    
    func testTaskDTODefaultValues() {
        // Given
        let jsonData = """
        {
            "todo": "This is a very long task description that should be truncated",
            "completed": false
        }
        """.data(using: .utf8)!
        
        // When
        let task = try? JSONDecoder().decode(TaskDTO.self, from: jsonData)
        
        // Then
        XCTAssertNotNil(task)
        XCTAssertEqual(task!.title, "This is a very long ...")
        XCTAssertFalse(task!.isCompleted)
        XCTAssertNotNil(task!.id)
        XCTAssertNotNil(task!.createdAt)
    }
}
