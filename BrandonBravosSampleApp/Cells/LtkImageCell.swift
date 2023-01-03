//
//  HeroCell.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

// a simple cell containing an image view
class LtkImageCell: UICollectionViewCell {
    static let reuseIdentifier = "LTKCell"
    public let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    public func setImageView(_ image: UIImage?) {
        guard let image = image else {
            print("LTKImageCell: Error Setting Image")
            return
        }
        imageView.image = image
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
