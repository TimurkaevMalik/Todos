//
//  CustomDateFormatter.swift
//  Todos
//
//  Created by Malik Timurkaev on 05.06.2025.
//

import Foundation

final class CustomDateFormatter {
    static let shared = CustomDateFormatter()
    private let formatter = DateFormatter()
    
    private init() {
        formatter.dateFormat = "dd/MM/yy"
    }
    
    func string(from date: Date) -> String {
        return formatter.string(from: date)
    }
}
