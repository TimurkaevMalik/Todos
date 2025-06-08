//
//  String.swift
//  Todos
//
//  Created by Malik Timurkaev on 03.06.2025.
//

import UIKit

extension String {
    
    func strikeThrough() -> NSAttributedString {
        
        if let cached = Cache.strikedStringsCache[self] { return cached }
        
        let attributedString = NSMutableAttributedString(string: self)
        
        attributedString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length))
        
        Cache.strikedStringsCache[self] = attributedString
        
        return attributedString
    }
    
    func normal() -> NSAttributedString {
        NSAttributedString(string: self)
    }
}
