//
//  TaskCD.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

extension TaskCD {
    func toDTO() -> TaskDTO {
        TaskDTO(
            id: id ?? UUID(),
            createdAt: createdAt ?? Date(),
            title: title ?? "",
            todo: todo ?? "",
            isCompleted: isCompleted
        )
    }
}
