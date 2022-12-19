//
//  SimpleHeaderReusableView.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

class SimpleHeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "SimpleHeaderReusableView"

    private let titleLabel = UILabel()
    
    func setTitle(_ title: String){
        titleLabel.text = title
    }
    
    override func layoutSubviews() {
        titleLabel.font = UIFont.montserratFont(withMontserrat: .bold, withSize: 15)
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
