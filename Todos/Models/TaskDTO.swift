//
//  TaskDTO.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

struct TaskDTO: Decodable {
    let id: UUID
    let createdAt: Date
    var title: String
    var todo: String
    var isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        ///Свойства которые имеются в JSON (нету даты создания и title)
        case id, todo
        case isCompleted = "completed"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        ///Парсим только необходимые свойства из JSON
        self.todo = try container.decode(String.self, forKey: .todo)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        
        ///Задаем дефолтные значения, потому что в JSON нету этих переменных
        self.id = UUID()
        self.createdAt = Date()
        self.title = "\(todo.prefix(20))..."
    }
    
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
