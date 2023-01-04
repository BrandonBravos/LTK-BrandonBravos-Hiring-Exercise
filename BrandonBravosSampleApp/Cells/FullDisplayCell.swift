//
//  FollowedFullCell.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/17/22.
//

import UIKit

class FullDisplayCell: UICollectionViewCell {
    let postImageView = UIImageView()
    static let reuseIdentifier = "FollowedFullCell"
    private let userFollowBar = UserFollowBarView()
    var profile: Profile?
    var products: [Product] = []

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpView()
    }

    func setProducts(products: [Product]) {
        self.products = products
        self.collectionView.reloadData()
    }

    func configure(profile: Profile, withPostImage image: UIImage?) {
        self.userFollowBar.setProfileImage(nil)
        self.profile = profile
        postImageView.image = image
        profile.getProfileImage { profileImage in
            DispatchQueue.main.async {
                self.userFollowBar.setProfileImage(profileImage)
            }
        }
        DispatchQueue.main.async {
            self.userFollowBar.setUsername(profile.displayName)
            self.collectionView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        userFollowBar.backgroundColor = .white
        addSubview(userFollowBar)
        userFollowBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userFollowBar.topAnchor.constraint(equalTo: topAnchor),
            userFollowBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            userFollowBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            userFollowBar.heightAnchor.constraint(equalToConstant: 50)
        ])

        collectionView.register(LtkImageCell.self, forCellWithReuseIdentifier: LtkImageCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 90)
        ])

        let shopThePostLabel = UILabel()
        shopThePostLabel.text = "Shop this post"
        shopThePostLabel.font = UIFont.montserratFont(withMontserrat: .bold, withSize: 13)
        shopThePostLabel.sizeToFit()
        addSubview(shopThePostLabel)
        shopThePostLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shopThePostLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -150),
            shopThePostLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -5),
            shopThePostLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15)
        ])

        postImageView.backgroundColor = .systemMint
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10
        addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: userFollowBar.bottomAnchor),
            postImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            postImageView.bottomAnchor.constraint(equalTo: shopThePostLabel.topAnchor, constant: 0)
        ])
    }
}

extension FullDisplayCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // on press open safari
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: products[indexPath.row].hyperlink!) {
            UIApplication.shared.open(url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let shopCell = collectionView.dequeueReusableCell(withReuseIdentifier: LtkImageCell.reuseIdentifier, for: indexPath) as? LtkImageCell else {
            print("FullDisplayCell: Problem dequeueing LtkImageCell")
            let cell = LtkImageCell()
            return cell
        }
        shopCell.imageView.layer.borderWidth = 0.35
        shopCell.imageView.layer.borderColor = UIColor.lightGray.cgColor
        products[indexPath.row].getProductImage(completion: { image in
            shopCell.setImageView(image)
        })
        return shopCell
    }
    
}
