//
//  MoreToShopHeaderReusableView.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/16/22.
//

import UIKit

class ShopThePicHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "ShopThePicHeaderReusableView"

    let centerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
        centerLabel.font = UIFont.montserratFont(withMontserrat: .light, withSize: 16)
        centerLabel.text = "SHOP THE PIC"
        centerLabel.textAlignment = .center
        centerLabel.backgroundColor = .white
        centerLabel.sizeToFit()
        addSubview(centerLabel)
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerLabel.widthAnchor.constraint(equalToConstant: 150),
            centerLabel.heightAnchor.constraint(equalToConstant: 35)
        ])

        let shopExactLabel = UILabel()
        shopExactLabel.text = "Shop exact products"
        shopExactLabel.font = UIFont.montserratFont(withMontserrat: .regular, withSize: 12)
        shopExactLabel.sizeToFit()
        addSubview(shopExactLabel)
        shopExactLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shopExactLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            shopExactLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ])

        addSideBars()
    }

    func addSideBars() {
        let sideBar = UIView()
        sideBar.backgroundColor = .gray
        addSubview(sideBar)
        sideBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideBar.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor),
            sideBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            sideBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            sideBar.heightAnchor.constraint(equalToConstant: 0.35)
        ])
        bringSubviewToFront(centerLabel)
    }
}
