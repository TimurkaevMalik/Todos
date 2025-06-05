//
//  UIFont.swift
//  Todos
//
//  Created by Malik Timurkaev on 03.06.2025.
//

import UIKit

extension UIFont {
    static func customFont(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
    
    static func regular11() -> UIFont {
        return customFont(weight: .regular, size: 11)
    }
    
    static func regular12() -> UIFont {
        return customFont(weight: .regular, size: 12)
    }
    
    static func regular17() -> UIFont {
        return customFont(weight: .regular, size: 17)
    }
    
    static func medium15() -> UIFont {
        return customFont(weight: .medium, size: 15)
    }
}
