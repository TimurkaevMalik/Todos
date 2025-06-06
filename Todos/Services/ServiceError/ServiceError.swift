//
//  ServiceError.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import Foundation

enum ServiceError: Error {
    case taskAlreadyExists
    case operation(_ type: ServiceOperation,
                   code: String = "uknown")
    
    public var message: String {
        switch self {
            
        case .taskAlreadyExists:
            "Task already exists"
            
        case .operation(let type, let code):
            "Task \(type.rawValue) operation failed. Error: \(code)"
        }
    }
    
    enum ServiceOperation: String {
        case insertion
        case retrieve
        case deletion
        case update
        case decode
    }
}
