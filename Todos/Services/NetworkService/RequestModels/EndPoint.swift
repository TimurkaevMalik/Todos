//
//  EndPoint.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//


import Foundation

public enum EndPoint {
    static let baseURL = "https://dummyjson.com/todos"
    
    case baseServer
    
    var url: URL? {
        switch self {
        case .baseServer:
            URL(string: EndPoint.baseURL)
        }
    }
}
