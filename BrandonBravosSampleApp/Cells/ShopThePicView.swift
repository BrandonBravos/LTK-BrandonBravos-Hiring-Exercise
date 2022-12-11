//
//  File.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit


// a reusable header for our LTK post
class ShopThePicView: UICollectionReusableView{
    static let reuseIdentifier = "ShopThePicView"
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.montserratFont(withMontserrat: .light, withSize: 18)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    func config(){
        label.text = "SHOP THE PIC"
        addSubview(label)
    }
}
