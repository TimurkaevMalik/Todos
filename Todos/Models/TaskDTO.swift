//
//  TaskDTO.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

struct TaskDTO {
    let id: UUID
    let createdAt: Date
    
    var title: String
    var todo: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(),
         createdAt: Date = Date(),
         title: String,
         todo: String,
         isCompleted: Bool = false) {
        
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.todo = todo
        self.isCompleted = isCompleted
    }
}
