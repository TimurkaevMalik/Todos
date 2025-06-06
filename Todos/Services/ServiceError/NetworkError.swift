//
//  NetworkError.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//


enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed(_ code: Int)
    case serverError(Int)
    
    var message: String {
        switch self {
        case .invalidURL: 
            return "Invalid URL"
            
        case .noData:
            return "No data received"
            
        case .decodingFailed(let error):
            return "Decoding failed: \(error)"
            
        case .serverError(let code):
            return "Server error with code \(code)"
        }
    }
}
