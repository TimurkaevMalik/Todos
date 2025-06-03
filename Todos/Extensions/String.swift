//
//  String.swift
//  Todos
//
//  Created by Malik Timurkaev on 03.06.2025.
//

import UIKit

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        attributedString.addAttribute(
            .strikethroughStyle,
            value: NSUnderlineStyle.single.rawValue,
            range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
