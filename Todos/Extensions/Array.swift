//
//  Array.swift
//  Todos
//
//  Created by Malik Timurkaev on 05.06.2025.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    mutating func safeRemove(at index: Index) {
        if indices.contains(index) {
            remove(at: index)
        }
    }
}
