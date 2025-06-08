//
//  TaskListDTO.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

struct TaskListDTO: Decodable {
    let todos: [TaskDTO]
}
