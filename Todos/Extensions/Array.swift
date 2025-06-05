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
}
