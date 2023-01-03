//
//  CVHeader.swift
//  LTK - Sample App
//
//  Created by Brandon Bravos on 12/14/22.
//

import UIKit

class BlankReusableCollectionView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderReusableCollectionView"
    func configure() {
        self.backgroundColor = .systemGreen
    }
}
