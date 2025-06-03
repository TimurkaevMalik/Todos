//
//  CheckMarkButton.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

final class CheckMarkButton: UIButton {
    
    var isMarked: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        backgroundColor = .appBlack
        layer.masksToBounds = true
        layer.cornerRadius = 12
        layer.borderWidth = 1
        
        setImage(UIImage(systemName: "checkmark"), for: .normal)
        imageView?.contentMode = .scaleAspectFit
        updateAppearance()
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 12),
            heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    private func updateAppearance() {
        layer.borderColor = isMarked ? UIColor.appYellow.cgColor : UIColor.appGrayMedium.cgColor
        
        imageView?.isHidden = isMarked
    }
}
