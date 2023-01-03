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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
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
