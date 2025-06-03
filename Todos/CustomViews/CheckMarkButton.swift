//
//  CheckMarkButton.swift
//  Todos
//
//  Created by Malik Timurkaev on 02.06.2025.
//

import UIKit

final class CheckMarkButton: UIButton {
    
    var isMarked: Bool = false {
        didSet { updateAppearance() }
    }
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appYellow
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .appBlack
        layer.masksToBounds = true
        layer.cornerRadius = 12
        layer.borderWidth = 1
        
        addSubview(checkmarkImageView)
                
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            checkmarkImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4)
        ])
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        layer.borderColor = isMarked ? UIColor.appYellow.cgColor : UIColor.appGrayMedium.cgColor
        checkmarkImageView.isHidden = !isMarked
    }
}
